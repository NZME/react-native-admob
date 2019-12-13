#if __has_include(<React/RCTView.h>)
#import <React/RCTView.h>
#else
#import "RCTView.h"
#endif

@import GoogleMobileAds;

@class RCTEventDispatcher;

@interface RNDFPPublisherNativeAdView : RCTView <GADUnifiedNativeAdLoaderDelegate, GADUnifiedNativeAdDelegate, DFPBannerAdLoaderDelegate, GADVideoControllerDelegate>

/// You must keep a strong reference to the GADAdLoader during the ad loading process.
@property(nonatomic, strong) GADAdLoader *adLoader;

/// The native ad that is being loaded.
@property(nonatomic, strong) GADUnifiedNativeAd *nativeAd;

/// The native ad view that is being presented.
@property(nonatomic, strong) UIView *nativeAdView;

@property (nonatomic, copy) NSString *adSize;
@property (nonatomic, copy) NSArray *validAdSizes;
@property (nonatomic, copy) NSDictionary *adStyles;
@property (nonatomic, copy) NSArray *testDevices;
@property (nonatomic, copy) NSString *adUnitID;
@property (nonatomic, copy) NSDictionary *targeting;

@property (nonatomic, copy) RCTBubblingEventBlock onSizeChange;
@property (nonatomic, copy) RCTBubblingEventBlock onAppEvent;
@property (nonatomic, copy) RCTBubblingEventBlock onAdLoaded;
@property (nonatomic, copy) RCTBubblingEventBlock onAdFailedToLoad;
@property (nonatomic, copy) RCTBubblingEventBlock onAdOpened;
@property (nonatomic, copy) RCTBubblingEventBlock onAdClosed;
@property (nonatomic, copy) RCTBubblingEventBlock onAdLeftApplication;

- (void)loadBanner;

@end
