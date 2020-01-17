#import "RNNativeAdsManager.h"

#import <React/RCTView.h>
#import <React/RCTBridge.h>
#import <React/RCTComponent.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

@class RCTEventDispatcher;

@interface RNNativeAdsAdView : RCTView <GADUnifiedNativeAdLoaderDelegate, GADUnifiedNativeAdDelegate, DFPBannerAdLoaderDelegate, GADNativeCustomTemplateAdLoaderDelegate, GADVideoControllerDelegate>

/// You must keep a strong reference to the GADAdLoader during the ad loading process.
@property(nonatomic, weak) IBOutlet GADAdLoader *adLoader;

/// The native ad that is being loaded.
@property(nonatomic, weak) IBOutlet GADUnifiedNativeAd *nativeAd;

/// The native ad view
@property(nonatomic, weak) IBOutlet GADUnifiedNativeAdView *nativeAdView;

/// The DFP banner view.
@property(nonatomic, weak) IBOutlet DFPBannerView *bannerView;

/// The native custom template ad
@property(nonatomic, weak) IBOutlet GADNativeCustomTemplateAd *nativeCustomTemplateAd;

@property (nonatomic, copy) NSString *customTemplateId;
@property (nonatomic, copy) NSArray *validAdTypes;
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
