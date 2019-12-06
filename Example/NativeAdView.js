import React, { Component } from 'react';
import { Text, View, Dimensions, Image, TouchableWithoutFeedback } from 'react-native';
import {
  withNativeAd,
  TriggerableView,
} from 'react-native-admob';

const { width } = Dimensions.get('window');
/*

    if (unifiedNativeAd.getPrice() == null) {
      ad.putString("price", null);
    } else {
      ad.putString("price", unifiedNativeAd.getPrice());
    }

    if (unifiedNativeAd.getIcon() == null) {
      ad.putString("icon", null);
    } else {
      WritableMap icon = Arguments.createMap();
      icon.putString("uri", unifiedNativeAd.getIcon().getUri().toString());
      icon.putInt("width", unifiedNativeAd.getIcon().getWidth());
      icon.putInt("height", unifiedNativeAd.getIcon().getHeight());
      icon.putDouble("scale", unifiedNativeAd.getIcon().getScale());
      ad.putMap("icon", icon);
    }

    if (unifiedNativeAd.getImages().size() == 0) {
      ad.putArray("images", null);
    } else {
      WritableArray images = Arguments.createArray();
      for (NativeAd.Image image: unifiedNativeAd.getImages()) {
        WritableMap imageMap = Arguments.createMap();
        imageMap.putString("uri", image.getUri().toString());
        imageMap.putInt("width", image.getWidth());
        imageMap.putInt("height", image.getHeight());
        imageMap.putDouble("scale", image.getScale());
        images.pushMap(imageMap);
      }
      ad.putArray("images", images);
    }
 */
export class NativeAdView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      nativeAd: props?.nativeAd,
    };
  }
  onPress = () => {
    console.log(this._triggerView);
  };

  render() {
    console.log('NativeAdView', this.props.nativeAd);
    const { nativeAd } = this.state;
    if (nativeAd?.type !== 'native') {
      return null;
    }
    return (
      <View onPress={this.onPress} style={{ flexDirection: 'column', borderWidth: 1 }}>
        <TriggerableView style={{backgroundColor: 'rgba(52, 52, 52, 0.5)', position: 'absolute', top:0, left:0, width: '100%', height: '100%'}}/>
          <View>
            <Image style={{ width: 80, height: 80 }} />
            <Text>icon.uri: {nativeAd?.icon.uri}</Text>
            <View
              style={{ flexDirection: 'column', paddingHorizontal: 10, flex: 1 }}
            >
              <Text style={{ fontSize: 18 }}>
                headline: {nativeAd?.headline}
              </Text>
              <Text>advertiserName: {nativeAd?.advertiserName}</Text>
              <Text>starRating: {nativeAd?.starRating}</Text>
              <Text>storeName: {nativeAd?.storeName}</Text>
              <Text>price: {nativeAd?.price}</Text>
              <Text style={{ fontSize: 10 }}>
                bodyText: {nativeAd?.bodyText}
              </Text>
            </View>
          </View>
          <View style={{ alignItems: 'center' }}>
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
                callToActionText: {nativeAd?.callToActionText}
              </Text>
            </View>
          </View>
      </View>
    );
  }
}

export default withNativeAd(NativeAdView);
