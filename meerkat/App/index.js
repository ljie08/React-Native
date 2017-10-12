import React from 'react'
import { AppRegistry, AsyncStorage } from 'react-native'
import dva from 'dva/mobile'
import { persistStore, autoRehydrate } from 'redux-persist'
// import GlobeConst from './Config/GlobalConst'
// import AppConfig from './Config/AppConfig'
import { registerModels } from './Models'
import NavigationRouter from './router'
const app = dva({
  initialState: {},
  extraEnhancers: [autoRehydrate()],
  onError(e) {
    console.log('onError', e)
  },
})
// Load models
registerModels(app)

// Load routers
app.router(() => <NavigationRouter />)
const App = app.start()

// eslint-disable-next-line no-underscore-dangle
persistStore(app._store, {storage: AsyncStorage})

AppRegistry.registerComponent('TC168', () => App)
