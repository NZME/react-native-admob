import { arrayOf, func, string, object } from 'prop-types';
import React, { Component } from 'react';
import {
  findNodeHandle,
  requireNativeComponent,
  UIManager,
  ViewPropTypes,
  processColor,
  StyleSheet,
} from 'react-native';
import { createErrorFromErrorData } from './utils';

class PublisherNativeAd extends Component {
  constructor() {
    super();
    this.handleAdLoaded = this.handleAdLoaded.bind(this);
    this.handleSizeChange = this.handleSizeChange.bind(this);
    this.handleAppEvent = this.handleAppEvent.bind(this);
    this.handleAdFailedToLoad = this.handleAdFailedToLoad.bind(this);
    this.state = {
      style: {},
    };
  }

  componentDidMount() {
    this.loadBanner();
  }

  loadBanner() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this._bannerView),
      UIManager.getViewManagerConfig('RNDFPPublisherNativeAdView').Commands
        .loadBanner,
      null
    );
  }

  handleAdLoaded(event) {
    if (this.props.onAdLoaded) {
      this.props.onAdLoaded(event.nativeEvent);
    }
  }

  handleSizeChange(event) {
    const { height, width } = event.nativeEvent;
    this.setState({ style: { width, height } });
    if (this.props.onSizeChange) {
      this.props.onSizeChange({ width, height });
    }
  }

  handleAppEvent(event) {
    if (this.props.onAppEvent) {
      const { name, info } = event.nativeEvent;
      this.props.onAppEvent({ name, info });
    }
  }

  handleAdFailedToLoad(event) {
    if (this.props.onAdFailedToLoad) {
      this.props.onAdFailedToLoad(
        createErrorFromErrorData(event.nativeEvent.error)
      );
    }
  }

  recursivelyProcessStyles(obj) {
    var newObj = {};
    var colors = ["color", "backgroundColor"];
    for (var k in obj) {
      if (typeof obj[k] == "object" && obj[k] !== null) {
        newObj[k] = this.recursivelyProcessStyles(obj[k]);
      } else if (colors.includes(k)) {
        newObj[k] = processColor(obj[k]);
      } else {
        newObj[k] = obj[k];
      }
    }
    return newObj;
  }

  getValidProps() {
    if (Platform.OS === 'ios' && this.props.adStyles !== null) {
      var props = {};
      for (var k in this.props) {
        props[k] = this.props[k]
      }
      props.adStyles = this.recursivelyProcessStyles(this.props.adStyles);
      console.log(props.adStyles);
    } else {
      var props = this.props;
    }
    return props;
  }

  render() {
    return (
      <RNDFPPublisherNativeAdView
        {...this.getValidProps()}
        style={[this.props.style, this.state.style]}
        onAdLoaded={this.handleAdLoaded}
        onSizeChange={this.handleSizeChange}
        onAdFailedToLoad={this.handleAdFailedToLoad}
        onAppEvent={this.handleAppEvent}
        ref={(el) => (this._bannerView = el)}
      />
    );
  }
}

PublisherNativeAd.simulatorId = 'SIMULATOR';

PublisherNativeAd.propTypes = {
  ...ViewPropTypes,

  /**
   * DFP ad unit ID
   */
  adUnitID: string,

  /**
   * DFP ad unit styles
   */
  adStyles: object,

  /**
   * Array of test devices. Use PublisherNativeAd.simulatorId for the simulator
   */
  testDevices: arrayOf(string),

  /**
   * DFP library events
   */
  onAdLoaded: func,
  onSizeChange: func,
  onAdFailedToLoad: func,
  onAdOpened: func,
  onAdClosed: func,
  onAdLeftApplication: func,
  onAppEvent: func,
};

const RNDFPPublisherNativeAdView = requireNativeComponent(
  'RNDFPPublisherNativeAdView',
  PublisherNativeAd
);

export default PublisherNativeAd;
