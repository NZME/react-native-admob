import { NativeModules, NativeEventEmitter } from 'react-native';
// import { EventEmitter } from 'fbemitter';

const RNNativeAdsManager = NativeModules.RNNativeAdsManager;

const nativeAdEmitter = new NativeEventEmitter(RNNativeAdsManager);
/*
TODO:
RNNativeAdsManager
init
registerViewsForInteraction
changed: 'RNNativeAdsManagerChanged',
onAdError: 'RNNativeAdsManagerOnAdError',

done - RNNativeAdsAdView
public static final String EVENT_AD_LOADED = "onAdLoaded";
public static final String EVENT_AD_FAILED_TO_LOAD = "onAdFailed";
 */
const eventMap = {
  didBecomeValid: 'RNNativeAdsManagerDidBecomeValid',
  didBecomeInvalid: 'RNNativeAdsManagerDidBecomeInvalid',
  changed: 'RNNativeAdsManagerChanged',
  onAdError: 'RNNativeAdsManagerOnAdError',
};

export default class NativeAdsManager {
  constructor(adUnitID, testDevices) {
    // Indicates whether AdsManager is ready to serve ads
    this.isValid = true;
    // this.eventEmitter = new EventEmitter();
    this.adUnitID = adUnitID;
    //this.listenForStateChanges();
    //this.listenForErrors();
    RNNativeAdsManager.init(adUnitID, testDevices);
  }

  static async registerViewsForInteractionAsync(nativeAdViewTag, clickable) {
    const result = await RNNativeAdsManager.registerViewsForInteraction(
      nativeAdViewTag,
      clickable
    );
    return result;
  }

  /**
   * Listens for AdManager state changes and updates internal state. When it changes,
   * callers will be notified of a change
   */
  // listenForStateChanges() {
  //   nativeAdEmitter.addListener(eventMap.changed, (managers) => {
  //     const isValidNow = managers[this.adUnitID];
  //     if (this.isValid !== isValidNow && isValidNow) {
  //       this.isValid = true;
  //       this.eventEmitter.emit(eventMap.didBecomeValid);
  //     }
  //   });
  // }
  /**
   * Listens for AdManager errors. When error occures,
   * callers will be notified of it
   */
  // listenForErrors() {
  //   nativeAdEmitter.addListener(eventMap.onAdError, (error) => {
  //     this.isValid = false;
  //     this.eventEmitter.emit(eventMap.didBecomeInvalid, error);
  //   });
  // }
  /**
   * Used to listening for state changes
   *
   * If manager already became valid, it will call the function w/o registering
   * handler for events
   */
  onAdsLoaded(func) {
    if (this.isValid) {
      setTimeout(func);
      return {
        context: null,
        listener: () => { },
        remove: () => { }
      };
    }
    // return this.eventEmitter.once(eventMap.didBecomeValid, func);
  }
  /**
   * Used to listening for errors from this native ad manager
   */
  onAdsError(func) {
    // return this.eventEmitter.once(eventMap.didBecomeInvalid, func);
  }
  /**
   * Set the native ads manager caching policy. This controls which media from
   * the native ads are cached before the onAdsLoaded is called.
   * The default is to not block on caching.
   */
  toJSON() {
    return this.adUnitID;
  }
}
