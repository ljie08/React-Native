import React, { Component } from 'react';
import {
  AppState,
  Text,
} from 'react-native';
import { CodePush } from 'react-native-code-push';

// import ListviewGridExample from '../Containers/ListviewGridExample';
import Home from '../Containers/Home';
// import PushNotificationsController from './utils/PushNotificationsController';


class NavigationRouter extends Component {
  componentDidMount() {
    AppState.addEventListener('change', this.handleAppStateChange);
    // updateInstallation({version});
    // CodePush.sync({installMode: CodePush.InstallMode.ON_NEXT_RESUME});
  }
  componentWillUnmount() {
    AppState.removeEventListener('change', this.handleAppStateChange);
  }
  handleAppStateChange(appState) {
    if (appState === 'active' ) {
      // this.props.dispatch()
      // CodePush.sync({installMode: CodePush.InstallMode.ON_NEXT_RESUME});
    }
  }
  render() {
    return (
      <Text>
        Test something
      </Text>
    );
  }
}

export default NavigationRouter;
