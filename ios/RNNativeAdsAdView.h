#import "RNNativeAdsManager.h"

#import <React/RCTView.h>
#import <React/RCTBridge.h>
#import <React/RCTComponent.h>

@import GoogleMobileAds;

@class RCTEventDispatcher;

@interface RNNativeAdsAdView : RCTView <GADUnifiedNativeAdLoaderDelegate, GADUnifiedNativeAdDelegate, DFPBannerAdLoaderDelegate, GADNativeCustomTemplateAdLoaderDelegate, GADVideoControllerDelegate>

/// You must keep a strong reference to the GADAdLoader during the ad loading process.
@property(nonatomic, strong) GADAdLoader *adLoader;

/// The native ad that is being loaded.
@property(nonatomic, strong) GADUnifiedNativeAd *nativeAd;

/// The native ad view that is being presented.
@property(nonatomic, strong) GADUnifiedNativeAdView *nativeAdView;

@property (nonatomic, copy) NSString *customTemplateId;
@property (nonatomic, copy) NSString *adSize;
@property (nonatomic, copy) NSArray *validAdSizes;
@property (nonatomic, copy) NSDictionary *targeting;

@property (nonatomic, copy) RCTBubblingEventBlock onSizeChange;
@property (nonatomic, copy) RCTBubblingEventBlock onAppEvent;
@property (nonatomic, copy) RCTBubblingEventBlock onAdLoaded;
@property (nonatomic, copy) RCTBubblingEventBlock onAdFailedToLoad;
@property (nonatomic, copy) RCTBubblingEventBlock onAdOpened;
@property (nonatomic, copy) RCTBubblingEventBlock onAdClosed;
@property (nonatomic, copy) RCTBubblingEventBlock onAdLeftApplication;

- (void)registerViewsForInteraction:(NSArray<UIView *> *)clickableViews;
- (void)reloadAd;
- (void)loadAd:(RNNativeAdsManager *)adManager;

@end
