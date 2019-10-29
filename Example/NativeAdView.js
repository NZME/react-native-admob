import React, { Component } from 'react';
import { Text, View, Dimensions, Image } from 'react-native';
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
  render() {
    return (
      <View style={{ flexDirection: 'column', borderWidth: 1 }}>
        <View>
          <Image style={{ width: 80, height: 80 }} />
          <Text>icon.uri: {this.props.nativeAd.icon.uri}</Text>
          <View
            style={{ flexDirection: 'column', paddingHorizontal: 10, flex: 1 }}
          >
            <TriggerableView style={{ fontSize: 18 }}>
              headline: {this.props.nativeAd.headline}
            </TriggerableView>
            <Text>advertiserName: {this.props.nativeAd.advertiserName}</Text>
            <Text>starRating: {this.props.nativeAd.starRating}</Text>
            <Text>storeName: {this.props.nativeAd.storeName}</Text>
            <Text>price: {this.props.nativeAd.price}</Text>
            <TriggerableView style={{ fontSize: 10 }}>
              bodyText: {this.props.nativeAd.bodyText}
            </TriggerableView>
          </View>
        </View>
        <View style={{ alignItems: 'center' }}>
          <TriggerableView
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
            callToActionText: {this.props.nativeAd.callToActionText}
          </TriggerableView>
        </View>
      </View>
    );
  }
}

export default withNativeAd(NativeAdView);
