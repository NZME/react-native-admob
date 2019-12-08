import { NativeModules, NativeEventEmitter } from 'react-native';

const RNNativeAdsManager = NativeModules.RNNativeAdsManager;

/*
TODO:
done RNNativeAdsManager
done init
done registerViewsForInteraction

done - RNNativeAdsAdView
public static final String EVENT_AD_LOADED = "onAdLoaded";
public static final String EVENT_AD_FAILED_TO_LOAD = "onAdFailed";
 */

export default class NativeAdsManager {
  constructor(adUnitID, testDevices) {
    // Indicates whether AdsManager is ready to serve ads
    this.isValid = true;
    this.adUnitID = adUnitID;
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
   * Set the native ads manager.
   */
  toJSON() {
    return this.adUnitID;
  }
}
