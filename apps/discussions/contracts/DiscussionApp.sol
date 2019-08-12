pragma solidity ^0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/lib/math/SafeMath.sol";
import "@aragon/os/contracts/common/IForwarder.sol";


contract DiscussionApp is IForwarder, AragonApp {
    using SafeMath for uint256;

    event Post(address indexed author, string postCid, uint discussionThreadId, uint postId, uint createdAt);
    event Revise(address indexed author, string revisedPostCid, uint discussionThreadId, uint postId, uint createdAt, uint revisedAt);
    event Hide(address indexed author, uint discussionThreadId, uint postId, uint hiddenAt);
    event CreateDiscussionThread(uint actionId, bytes _evmScript);

    bytes32 constant public DISCUSSION_POSTER_ROLE = keccak256("DISCUSSION_POSTER_ROLE");
    string private constant ERROR_CAN_NOT_FORWARD = "DISCUSSIONS_CAN_NOT_FORWARD";

    struct DiscussionPost {
        address author;
        string postCid;
        uint discussionThreadId;
        uint id;
        uint createdAt;
        bool show;
        string[] revisionCids;
    }

    uint discussionThreadId;

    mapping(uint => DiscussionPost[]) public discussionThreadPosts;

    function initialize() public onlyInit {
        discussionThreadId = 0;
        initialized();
    }

    /**
     * @notice Create discussion post with an IPFS content hash '`postCid`'.
     * @param postCid The IPFS content hash of the discussion post data
     * @param discussionThreadId The thread to post this discussion to
     */
    function post(string postCid, uint discussionThreadId) external auth(DISCUSSION_POSTER_ROLE) {
        DiscussionPost storage post;
        post.author = msg.sender;
        post.postCid = postCid;
        post.discussionThreadId = discussionThreadId;
        post.createdAt = now;
        post.show = true;
        uint postId = discussionThreadPosts[discussionThreadId].length;
        post.id = postId;
        discussionThreadPosts[discussionThreadId].push(post);
        emit Post(msg.sender, postCid, discussionThreadId, postId, now);
    }

    /**
     * @notice Hide a discussion post with ID '`postId`'.
     * @param postId The postId to hide
     * @param discussionThreadId The thread to hide this discussion from
     */
    function hide(uint postId, uint discussionThreadId) external auth(DISCUSSION_POSTER_ROLE) {
        DiscussionPost storage post = discussionThreadPosts[discussionThreadId][postId];
        require(post.author == msg.sender, "You cannot hide a post you did not author.");
        post.show = false;
        emit Hide(msg.sender, discussionThreadId, postId, now);
    }
    /**
     * @notice Revise a discussion post with ID '`postId`'.
     * @param revisedPostCid The cid of the pre-revised post
     * @param postId The postId to revise
     * @param discussionThreadId The thread to hide this discussion from
     */
    function revise(string revisedPostCid, uint postId, uint discussionThreadId) external auth(DISCUSSION_POSTER_ROLE) {
        DiscussionPost storage post = discussionThreadPosts[discussionThreadId][postId];
        require(post.author == msg.sender, "You cannot revise a post you did not author.");
        // add the current post to the revision history
        // should we limit the number of revisions you can make to save storage?
        post.revisionCids.push(post.postCid);
        post.postCid = revisedPostCid;
        emit Revise(msg.sender, revisedPostCid, discussionThreadId, postId, post.createdAt, now);
    }

    // Forwarding fns

    /**
    * @notice Tells whether the Discussion app is a forwarder or not
    * @dev IForwarder interface conformance
    * @return Always true
    */
    function isForwarder() external pure returns (bool) {
        return true;
    }

    /**
    * @notice Creates a discussion thread around the desired action
    * @dev IForwarder interface conformance
    * @param _evmScript Start vote with script
    */
    function forward(bytes _evmScript) public {
        require(canForward(msg.sender, _evmScript), ERROR_CAN_NOT_FORWARD);
        bytes memory input = new bytes(0); // TODO: Consider input for this
        address[] memory blacklist = new address[](1);
        CreateDiscussionThread(discussionThreadId, _evmScript);
        discussionThreadId = discussionThreadId + 1;
        runScript(_evmScript, input, blacklist);
    }

    /**
    * @notice Tells whether `_sender` can forward actions or not
    * @dev IForwarder interface conformance
    * @param _sender Address of the account intending to forward an action
    * @return True (eventually we should return if the given address can create a discussion thread, false otherwise)
    */
    function canForward(address _sender, bytes) public view returns (bool) {
        return true;
    }
}
