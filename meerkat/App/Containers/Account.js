import React, { Component } from 'react'
import { StyleSheet, View, Button } from 'react-native'

import { NavigationActions } from '../utils'
import AppConfig from '../Config/AppConfig'

class Account extends Component {
  static navigationOptions = {
    title: AppConfig.appName,
    tabBarLabel: 'Account',

  }

  gotoLogin = () => {
    this.props.dispatch(NavigationActions.navigate({ routeName: 'Login' }))
  }

  render() {
    return (
      <View style={styles.container}>
        <Button title="换个网络，运气更好哦~" onPress={ () => console.log('pressed')}/>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  icon: {
    width: 32,
    height: 32,
  },
})

export default Account
