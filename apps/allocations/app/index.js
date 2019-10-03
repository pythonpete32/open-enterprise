/* eslint-disable import/no-unused-modules */
import React from 'react'
import ReactDOM from 'react-dom'
import { AragonApi } from '@aragon/api-react'
import { Main } from '@aragon/ui'
import appStateReducer from './app-state-reducer'
import App from './components/App/App'

// TODO: Profile App with React.StrictMode, perf and why-did-you-update, apply memoization
ReactDOM.render(
  <AragonApi reducer={appStateReducer}>
    <Main>
      <App />
    </Main>
  </AragonApi>,
  document.querySelector('#allocations')
)
