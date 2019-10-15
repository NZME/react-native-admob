import { arrayOf, func, string } from 'prop-types';
import React, { Component } from 'react';
import {
  findNodeHandle,
  requireNativeComponent,
  UIManager,
  ViewPropTypes,
  View,
  Text
} from 'react-native';
import { createErrorFromErrorData } from './utils';

class PublisherNativeAd extends Component {
  constructor() {
    super();
    this.handleAdLoaded = this.handleAdLoaded.bind(this);
    this.handleAdClicked = this.handleAdClicked.bind(this);
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
      UIManager.getViewManagerConfig('RNDFPPublisherNativeAdView').Commands.loadBanner,
      null
    );
  }

  handleAdLoaded(event) {
    if (this.props.onAdLoaded) {
      this.props.onAdLoaded(event.nativeEvent);
    }
  }

  handleAdClicked(event) {
    if (this.props.onAdClicked) {
      this.props.onAdClicked(event.nativeEvent);
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

  render() {
    return (
      <View><Text>sag</Text>
      <RNDFPPublisherNativeAdView
        {...this.props}
        style={[this.props.style, this.state.style]}
        onAdLoaded={this.handleAdLoaded}
        onAdClicked={this.handleAdClicked}
        onAdFailedToLoad={this.handleAdFailedToLoad}
        onAppEvent={this.handleAppEvent}
        ref={(el) => (this._bannerView = el)}
      /></View>
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
   * Array of test devices. Use PublisherNativeAd.simulatorId for the simulator
   */
  testDevices: arrayOf(string),

  /**
   * DFP library events
   */
  onAdLoaded: func,
  onAdClicked: func,
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
