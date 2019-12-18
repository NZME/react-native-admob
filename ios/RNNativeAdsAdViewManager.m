#import "RNNativeAdsManager.h"
#import "RNNativeAdsAdViewManager.h"
#import "RNNativeAdsAdView.h"

#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>

@implementation RNNativeAdsAdViewManager

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

- (UIView *)view
{
  return [RNNativeAdsAdView new];
}

RCT_EXPORT_METHOD(reloadAd:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNNativeAdsAdView *> *viewRegistry) {
        RNNativeAdsAdView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNNativeAdsAdView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNNativeAdsAdView, got: %@", view);
        } else {
            [view reloadAd];
        }
    }];
}

RCT_CUSTOM_VIEW_PROPERTY(adsManager, NSString, RNNativeAdsAdView)
{
    RNNativeAdsManager *nativeAdManager = [_bridge moduleForClass:[RNNativeAdsManager class]];
    RNNativeAdsManager *_adsManager = [nativeAdManager getAdsManager:json];
    [view loadAd:_adsManager];
}

RCT_EXPORT_VIEW_PROPERTY(customTemplateId, NSString)
RCT_EXPORT_VIEW_PROPERTY(adSize, NSString)
RCT_EXPORT_VIEW_PROPERTY(validAdSizes, NSArray)
RCT_EXPORT_VIEW_PROPERTY(targeting, NSDictionary)

RCT_EXPORT_VIEW_PROPERTY(onSizeChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAppEvent, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdLoaded, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdFailedToLoad, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdOpened, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdClosed, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdLeftApplication, RCTBubblingEventBlock)

@end
