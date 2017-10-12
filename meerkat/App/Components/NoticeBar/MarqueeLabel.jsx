import React, { Component,PropTypes } from 'react';
import {View, requireNativeComponent } from 'react-native';

class MarqueeLabel extends Component {
  render() {
    const {children, ...props} = this.props;
    const nativeProps = Object.assign({}, props, {text: children});
    return (
        <RCTMarqueeLabel  {...nativeProps}/>
    );
  }
}

MarqueeLabel.propTypes = {
  ...View.propTypes,
  text : PropTypes.string.isRequired,
  scrollDuration : PropTypes.number, //秒
  marqueeType : PropTypes.number, //ios
  fadeLength : PropTypes.number, //ios
  leadingBuffer : PropTypes.number, //ios
  trailingBuffer : PropTypes.number, //ios
  animationDelay : PropTypes.number, //ios
  isRepeat : PropTypes.bool, //android
  startPoint : PropTypes.number, //android
  direction : PropTypes.number, //android
}

var RCTMarqueeLabel = requireNativeComponent('RCTMarqueeLabel', MarqueeLabel);
export default MarqueeLabel;
