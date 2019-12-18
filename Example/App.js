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
    /*AdMobRewarded.setTestDevices([AdMobRewarded.simulatorId]);
    AdMobRewarded.setAdUnitID('/83069739/jeff');

    AdMobRewarded.addEventListener('rewarded', reward =>
      console.log('AdMobRewarded => rewarded', reward),
    );
    AdMobRewarded.addEventListener('adLoaded', () =>
      console.log('AdMobRewarded => adLoaded'),
    );
    AdMobRewarded.addEventListener('adFailedToLoad', error =>
      console.warn(error),
    );
    AdMobRewarded.addEventListener('adOpened', () =>
      console.log('AdMobRewarded => adOpened'),
    );
    AdMobRewarded.addEventListener('videoStarted', () =>
      console.log('AdMobRewarded => videoStarted'),
    );
    AdMobRewarded.addEventListener('adClosed', () => {
      console.log('AdMobRewarded => adClosed');
      AdMobRewarded.requestAd().catch(error => console.warn(error));
    });
    AdMobRewarded.addEventListener('adLeftApplication', () =>
      console.log('AdMobRewarded => adLeftApplication'),
    );

    AdMobRewarded.requestAd().catch(error => console.warn(error));

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

    AdMobInterstitial.requestAd().catch(error => console.warn(error));*/
  }

  componentWillUnmount() {
/*    AdMobRewarded.removeAllListeners();
    AdMobInterstitial.removeAllListeners();*/
  }

  showRewarded() {
    // AdMobRewarded.showAd().catch(error => console.warn(error));
  }

  showInterstitial() {
    // AdMobInterstitial.showAd().catch(error => console.warn(error));
  }

  render() {
    // const adsManager = new NativeAdsManager("/6499/example/native", [AdMobInterstitial.simulatorId]);
    const adsManager = new NativeAdsManager("/83069739/jeff", [AdMobInterstitial.simulatorId]);

    return (
      <View style={styles.container}>
        <ScrollView>
          {/*<BannerExample title="AdMob - Basic">
            <AdMobBanner
              adSize="banner"
              adUnitID="/83069739/jeff"
              ref={el => (this._basicExample = el)}
            />
            <Button
              title="Reload"
              onPress={() => this._basicExample.loadBanner()}
            />
          </BannerExample>
          <BannerExample title="Smart Banner">
            <AdMobBanner
              adSize="smartBannerPortrait"
              adUnitID="/83069739/jeff"
              ref={el => (this._smartBannerExample = el)}
            />
            <Button
              title="Reload"
              onPress={() => this._smartBannerExample.loadBanner()}
            />
          </BannerExample>
          <BannerExample title="Rewarded">
            <Button
              title="Show Rewarded Video and preload next"
              onPress={this.showRewarded}
            />
          </BannerExample>
          <BannerExample title="Interstitial">
            <Button
              title="Show Interstitial and preload next"
              onPress={this.showInterstitial}
            />
          </BannerExample>
          <BannerExample title="DFP - Multiple Ad Sizes">
            <PublisherBanner
              adSize="300x600"
              validAdSizes={['banner', 'largeBanner', 'mediumRectangle', 'fullBanner', 'leaderboard', 'smartBannerPortrait', 'smartBannerLandscape', '300x600']}
              adUnitID="/83069739/jeff"
              targeting={{
                customTargeting:  {
                  group: 'nzme_user_test',
                  av: "1.0",
                  pos: 1,
                  pt: "homepage",
                  subscriber: "true",
                  arc_uuid: "b4894035-dd00-49da-8883-921387f0bb35",
                  mb: {
                    mb: "0433802",
                    sa2: "132700"
                  },
                  location: {
                    speed: 0,
                    heading: 0,
                    accuracy: 20,
                    altitude: 0,
                    longitude: 174.76333000000002,
                    latitude: -36.84845833333333
                  }
                },
                categoryExclusions: ['media'],
                contentURL: 'nzmetest://',
                publisherProvidedID: 'provider_id_nzme',
              }}
              ref={el => (this._adSizesExample = el)}
            />
            <Button
              title="Reload"
              onPress={() => this._adSizesExample.loadBanner()}
            />
          </BannerExample>
          <BannerExample
            title="DFP - App Events"
            style={this.state.appEventsExampleStyle}>
            <PublisherBanner
              style={{ height: 50 }}
              adUnitID="/83069739/jeff"
              onAdFailedToLoad={error => {
                console.warn(error);
              }}
              onAppEvent={event => {
                if (event.name === 'color') {
                  this.setState({
                    appEventsExampleStyle: { backgroundColor: event.info },
                  });
                }
              }}
              ref={el => (this._appEventsExample = el)}
            />
            <Button
              title="Reload"
              onPress={() => this._appEventsExample.loadBanner()}
              style={styles.button}
            />
          </BannerExample>
          <BannerExample title="DFP - Fluid Ad Size">
            <View
              style={[
                { backgroundColor: '#f3f', paddingVertical: 10 },
                this.state.fluidAdSizeExampleStyle,
              ]}>
              <PublisherBanner
                adSize="fluid"
                adUnitID="/83069739/jeff"
                ref={el => (this._appFluidAdSizeExample = el)}
                style={{ flex: 1 }}
              />
            </View>
            <Button
              title="Change Banner Width"
              onPress={() =>
                this.setState(prevState => ({
                  fluidSizeIndex: prevState.fluidSizeIndex + 1,
                  fluidAdSizeExampleStyle: {
                    width:
                      bannerWidths[
                      prevState.fluidSizeIndex % bannerWidths.length
                        ],
                  },
                }))
              }
              style={styles.button}
            />
            <Button
              title="Reload"
              onPress={() => this._appFluidAdSizeExample.loadBanner()}
              style={styles.button}
            />
          </BannerExample>
          <BannerExample
            style={{ paddingTop: 5, paddingBottom: 10, paddingRight: 2, paddingLeft: 3, backgroundColor: '#A5A4A8' }}
            title="DFP - Native ad">
            <View style={{alignItems: 'center', width: '100%'}}>
              <PublisherNativeAd
                style={{ width: '100%'}}
                onSizeChange={(data) => console.log(data)}
                adSize="300x600"
                validAdSizes={['banner', 'largeBanner', 'mediumRectangle', 'fullBanner', 'leaderboard', 'smartBannerPortrait', 'smartBannerLandscape', '300x600']}
                adUnitID="/83069739/jeff"
                adStyles={adStyles}
                onAdFailedToLoad={error => {
                  console.log(error);
                }}
                ref={el => (this._appNativeExample = el)}
              >
              </PublisherNativeAd>
            </View>
            <Button
              title="Reload"
              onPress={() => this._appNativeExample.loadBanner()}
              style={styles.button}
            />
          </BannerExample>*/}
          <BannerExample
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
                onSizeChange={(data) => console.log(data)}
                customTemplateId="11891103"
                // adSize="300x600"
                // validAdSizes={['banner', 'largeBanner', 'mediumRectangle', 'fullBanner', 'leaderboard', 'smartBannerPortrait', 'smartBannerLandscape', '300x600']}
                adUnitID="/83069739/jeff"
                onAdFailedToLoad={error => {
                  console.log(error);
                }}
                ref={el => (this._appReactNativeExample = el)} />
            </View>
            <Button
              title="Reload"
              onPress={() => this._appReactNativeExample.reloadAd()}
              style={styles.button}
            />
          </BannerExample>
        </ScrollView>
      </View>
    );
  }
}

const adStyles = {
  ad_sponsored: {
    fontSize: 10,
    lineHeight: 12,
    padding: 5,
    fontFamily: 'Stag-Medium',
    textTransform: 'uppercase',
    color: '#2F74BA',
    backgroundColor: '#ECEDE9',
  },
  ad_headline: {
    fontSize: 19,
    lineHeight: 22,
    paddingTop: 3,
    paddingBottom: 3,
    fontFamily: 'Stag-Medium',
    color: '#4C585E',
  },
  ad_body: {
    // padding:5,
    fontSize: 16,
    fontFamily: 'SourceSansPro-Regular',
    color: '#4C585E',
  },
  ad_app_icon: {
    width: 111,
    height: 88,
  },
  ad_call_to_action: {
    paddingLeft: 10,
    paddingTop: 10,
    paddingRight: 10,
    paddingBottom: 10,
    backgroundColor: "#FFFFFF"
  },
};

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
