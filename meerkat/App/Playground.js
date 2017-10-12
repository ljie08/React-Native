var React = require('React');
import {AppRegistry, Text, View} from 'react-native';

class Playground extends React.Component {
  render() {
    return (
      <View style={{backgroundColor: '#336699', flex: 1,}}>
        <Text> Some Text</Text>
      </View>
    );
  }
}

AppRegistry.registerComponent('TC168', ()=>Playground)