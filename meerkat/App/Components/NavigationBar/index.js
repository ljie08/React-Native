import React from 'react'
import { View, Image, Animated, TouchableOpacity, Text } from 'react-native'
import { Images, Colors } from '../../Themes'
import Styles from './CustomNavBarStyles'
import Icon from 'react-native-vector-icons/Ionicons'
import { Actions as NavigationActions } from 'react-native-router-flux'

export default class CustomNavBar extends React.Component {
  renderLeftItem() {
    switch (this.props.leftItem) {
      case 'BACK':
        return (
          <TouchableOpacity style={Styles.leftButton} onPress={NavigationActions.pop}>
            <Icon name='ios-arrow-back' size={34} color={Colors.snow} />
          </TouchableOpacity>
        );
      case 'LOGGEDIN':
        return (
          <TouchableOpacity style={Styles.leftButton} onPress={NavigationActions.pop}>
            <Icon name='contact' size={34} color={Colors.snow} />
          </TouchableOpacity>
        );
      case 'REGISTER':
        return (
          <TouchableOpacity style={Styles.leftButton} onPress={NavigationActions.pop}>
            <Text style={Styles.barText}>注册</Text>
          </TouchableOpacity>
        )
      default:
        return;
    }
  }
  renderRightItem() {
    switch (this.props.rightItem) {
      case 'SWITCH':
        return (
          <TouchableOpacity style={Styles.leftButton} onPress={NavigationActions.pop}>
            <Icon name='ios-arrow-back' size={34} color={Colors.snow} />
          </TouchableOpacity>
        );
      case 'LOGIN':
        return (
          <TouchableOpacity style={Styles.leftButton} onPress={NavigationActions.pop}>
            <Text style={Styles.barText}>登录</Text>
          </TouchableOpacity>
        );
      default:
        return;
    }
  }
  renderMiddleItem() {
    switch (this.props.middleItem) {
      case 'IMAGE':
        return (
          <Image style={Styles.logo} source={Images.clearLogo} />
        );
    }
  }
  render() {
    return (
      <Animated.View style={Styles.container}>
        {this.renderLeftItem()}
        {this.renderMiddleItem()}
        {this.renderRightItem()}
      </Animated.View>
    )
  }
}
