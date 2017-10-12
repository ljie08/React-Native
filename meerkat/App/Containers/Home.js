import React, { Component } from 'react'
import { StyleSheet, View, Button } from 'react-native'
import { connect } from 'dva';

// import { NavigationActions } from '../utils';
import AppConfig from '../Config/AppConfig'


class Home extends Component {
  static navigationOptions = {
    title: AppConfig.appName,
    tabBarLabel: 'Home',

  }

  // gotoDetail = () => {
  //   this.props.dispatch(NavigationActions.navigate({ routeName: 'Detail' }))
  // }

  render() {
    return (
      <View style={styles.container}>
        <Button title="出奇迹了!!! 居然更新失败，请彻底退出APP后重新打开。 等你哟~~" onPress={ () => console.log('pressed')}/>
      </View>
    )
  }
}

function mapStateToProps({ router }) {
  return { router }
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

export default connect(mapStateToProps)(Home)
