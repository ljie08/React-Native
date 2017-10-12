import React, { Component } from 'react'
import { StyleSheet, View, Button } from 'react-native'
import { connect } from 'dva'

import { NavigationActions } from '../utils'

class Detail extends Component {
  static navigationOptions = {
    title: 'Detail',
  }

  gotoDetail = () => {
    this.props.dispatch(NavigationActions.navigate({ routeName: 'Detail' }))
  }

  goBack = () => {
    this.props.dispatch(NavigationActions.back({ routeName: 'Account' }))
  }

  render() {
    return (
      <View style={styles.container}>
        <Button title="Goto Detail" onPress={this.gotoDetail} />
        <Button title="Go Back" onPress={this.goBack} />
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
})

export default connect(mapStateToProps)(Detail);
