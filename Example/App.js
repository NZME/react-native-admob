import React, { Component } from 'react';
import {
  Button,
  Platform,
  ScrollView,
  StyleSheet,
  Text,
  View
} from 'react-native';
import {
  AdMobBanner,
  AdMobInterstitial,
  AdMobRewarded,
  PublisherBanner,
  PublisherNativeAd,
  NativeAdsManager,
} from 'react-native-admob';
import NativeAdView from './NativeAdView';

const BannerExample = ({ style, title, children, ...props }) => (
  <View {...props} style={[styles.example, style]}>
    <Text style={styles.title}>{title}</Text>
    <View>{children}</View>
  </View>
);

const bannerWidths = [200, 250, 320];

export default class Example extends Component {
  constructor() {
    super();
    this.state = {
      fluidSizeIndex: 0,
    };
  }

  componentDidMount() {
    AdMobInterstitial.setTestDevices([AdMobInterstitial.simulatorId]);
    AdMobInterstitial.setAdUnitID('/83069739/jeff');

    AdMobInterstitial.addEventListener('adLoaded', () =>
      console.log('AdMobInterstitial adLoaded'),
    );
    AdMobInterstitial.addEventListener('adFailedToLoad', error =>
      console.warn(error),
    );
    AdMobInterstitial.addEventListener('adOpened', () =>
      console.log('AdMobInterstitial => adOpened'),
    );
    AdMobInterstitial.addEventListener('adClosed', () => {
      console.log('AdMobInterstitial => adClosed');
      AdMobInterstitial.requestAd().catch(error => console.warn(error));
    });
    AdMobInterstitial.addEventListener('adLeftApplication', () =>
      console.log('AdMobInterstitial => adLeftApplication'),
    );

    AdMobInterstitial.requestAd().catch(error => console.warn(error));
  }

  componentWillUnmount() {
    AdMobRewarded.removeAllListeners();
    AdMobInterstitial.removeAllListeners();
  }

  showRewarded() {
    AdMobRewarded.showAd().catch(error => console.warn(error));
  }

  showInterstitial() {
    AdMobInterstitial.showAd().catch(error => console.warn(error));
  }

  onAdLoaded = nativeAd => {
    // console.log(nativeAd);
  };

  showBanner = () => {
    return <BannerExample title="DFP - Fluid Ad Size">
      <View
        style={[
          { backgroundColor: '#f3f', paddingVertical: 10 },
          {alignItems: 'center', width: '100%'}
        ]}>
        <PublisherBanner
          onAdLoaded={this.onAdLoaded}
          adSize="mediumRectangle"
          validAdSizes={['mediumRectangle']}
          adUnitID={'/83069739/jeff'}
          targeting={{
            customTargeting: { group: 'nzme_user_test' },
            categoryExclusions: ['media'],
            contentURL: 'nzmetest://',
            publisherProvidedID: 'provider_id_nzme',
          }}
        />
      </View>
    </BannerExample>;
  };

  showNative = adsManager => {
    return <BannerExample
      style={{ padding: 20}}
      title="DFP - Native ad">
      <View style={{alignItems: 'center', width: '100%'}}>
        <NativeAdView
          targeting={{
            customTargeting: { group: 'nzme_user_test' },
            categoryExclusions: ['media'],
            contentURL: 'nzmetest://',
            publisherProvidedID: 'provider_id_nzme',
          }}
          style={{ width: '100%'}}
          adsManager={adsManager}
          // adLayout={'horizontal'}
          validAdTypes={['native', 'template']}
          customTemplateId="11891103"
          onAdLoaded={this.onAdLoaded}
          adUnitID={'/83069739/jeff'}
          onAdFailedToLoad={error => {
            console.log(error);
          }}
        />
      </View>
    </BannerExample>;
  };

  render() {
    // const adsManager = new NativeAdsManager("/6499/example/native", [AdMobInterstitial.simulatorId]);
    const adsManager = new NativeAdsManager("/83069739/jeff", [AdMobInterstitial.simulatorId]);
    const adsList = [
      // {type: 'banner'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
      {type: 'native'},
    ];
    console.log('test');
    return (
      <View style={styles.container}>
        <ScrollView>
          <BannerExample title="Interstitial">
            <Button
              title="Show Interstitial and preload next"
              onPress={this.showInterstitial}
            />
          </BannerExample>
          {adsList?.map((curItem, index) => {
            if (curItem.type === 'banner') {
              return <View key={index}>{this.showBanner()}</View>;
            } else {
              return <View key={index}>{this.showNative(adsManager)}</View>;
            }
          })}
        </ScrollView>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    marginTop: Platform.OS === 'ios' ? 30 : 10,
  },
  example: {
    paddingVertical: 10,
  },
  title: {
    margin: 10,
    fontSize: 20,
  },
  button: {
    backgroundColor: "#CC5500"
  }
});
