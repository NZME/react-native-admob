import React, { Component } from 'react';
import { Text, View, Dimensions, Image, TouchableWithoutFeedback } from 'react-native';
import {
  withNativeAd,
  TriggerableView,
} from 'react-native-admob';

const { width } = Dimensions.get('window');

export class NativeAdView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      nativeAd: props?.nativeAd,
    };
  }

  render() {
    const { nativeAd } = this.state;
    if (nativeAd?.type !== 'native') {
      return null;
    }
    return (
      <View style={{ flexDirection: 'column', borderWidth: 1, position: 'relative' }}>
        <TriggerableView style={{backgroundColor: 'rgba(52, 52, 52, 0.0)', position: 'absolute', top:0, left:0, width: '100%', height: '100%'}} />
        <View style={{ flexDirection: 'row', padding: 10 }}>
          <View
            style={{ flexDirection: 'column', flex: 1 }}
          >
            {nativeAd?.headline && (<Text style={{ fontSize: 18 }}>
              {nativeAd.headline}
            </Text>)}
            {nativeAd?.bodyText && (<Text style={{ fontSize: 10 }}>
              {nativeAd.bodyText}
            </Text>)}
            <View style={{ flexDirection: 'row' }}>
              <Text>{nativeAd?.advertiserName}</Text>
              <Text>{nativeAd?.starRating}</Text>
              <Text>{nativeAd?.storeName}</Text>
              <Text>{nativeAd?.price}</Text>
            </View>
          </View>
          {nativeAd?.icon?.uri && (<Image style={{ width: 80, height: 80 }} source={{uri: nativeAd.icon.uri}} />)}
        </View>
        {nativeAd?.callToActionText && (<View style={{ alignItems: 'center' }}>
          <View
            ref={el => (this._triggerView = el)}>
            <Text
              style={{
                fontSize: 15,
                color: '#a70f0a',
                paddingVertical: 10,
                paddingHorizontal: 30,
                elevation: 3,
                borderTopWidth: 0,
                margin: 10,
                borderRadius: 6,
              }}
            >
              {nativeAd.callToActionText}
            </Text>
          </View>
        </View>)}
      </View>
    );
  }
}

export default withNativeAd(NativeAdView);
