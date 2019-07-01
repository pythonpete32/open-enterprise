/*
 * SPDX-License-Identitifer: GPL-3.0-or-later
 */

pragma solidity 0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";


/**
  * @title AddressBook App
  * @author Autark
  * @dev Defines an address book (registry) that allows the
  * association of an ethereum address with an IPFS cID pointing to JSON content
  */
contract AddressBook is AragonApp {

    /// Hardcoded constants to save gas
    /// bytes32 public constant ADD_ENTRY_ROLE = keccak256("ADD_ENTRY_ROLE");
    bytes32 public constant ADD_ENTRY_ROLE = 0x4a167688760e93a8dd0a899c70e125af7d665ed37fd06496b8c83ce9fdac41bd;
    /// bytes32 public constant REMOVE_ENTRY_ROLE = keccak256("REMOVE_ENTRY_ROLE");
    bytes32 public constant REMOVE_ENTRY_ROLE = 0x4bf67e2ff5501162fc2ee020c851b17118c126a125e7f189b1c10056a35a8ed1;

    /// Error string constants
    string private constant ERROR_NOT_FOUND = "ENTRY_DOES_NOT_EXIST";
    string private constant ERROR_EXISTS = "ENTRY_ALREADY_EXISTS";
    string private constant ERROR_CID_MALFORMED = "CID_MALFORMED";

    /// The entries in the registry
    mapping(address => string) entries;

    /// Events
    event EntryAdded(address addr); /// Fired when an entry is added to the registry
    event EntryRemoved(address addr); /// Fired when an entry is removed from the registry


    function initialize() external onlyInit {
        initialized();
    }

    /**
     * @notice Add the address `_addr` to the registry.
     * @param _addr The address of the entry to add to the registry
     * @param _cid The IPFS hash of the entry to add to the registry
     */
    function addEntry(
        address _addr,
        string _cid
    ) public auth(ADD_ENTRY_ROLE)
    {
        require(bytes(entries[_addr]).length == 0, "entry exists with that address");
        require(bytes(_cid).length == 46, "CID malformed");

        entries[_addr] = _cid;

        emit EntryAdded(_addr);
    }

    /**
     * @notice Remove address `_addr` from the registry.
     * @param _addr The ID of the entry to remove
     */
    function removeEntry(
        address _addr
    ) public auth(REMOVE_ENTRY_ROLE)
    {
        require(bytes(entries[_addr]).length != 0, "entry does not exist");

        delete entries[_addr];
        emit EntryRemoved(_addr);
    }

    /**
     * Get an entry from the registry.
     * @param _addr The ID of the entry to get
     */
    function getEntry(
        address _addr
    ) public view returns (string contentId)
    {
        contentId = entries[_addr];
    }
}
