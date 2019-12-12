#import "RNNativeAdsManager.h"
#import "RNNativeAdsAdView.h"

#import "RNAdMobUtils.h"

#import <React/RCTUtils.h>
#import <React/RCTAssert.h>
#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridgeModule.h>

@interface RNNativeAdsManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString*, RNNativeAdsManager*> *adsManagers;
@property (nonatomic, strong) NSString *myAdChoiceViewAdUnitID;

@end

@implementation RNNativeAdsManager
{
    NSString *_adUnitID;
    NSArray *_testDevices;
}

RCT_EXPORT_MODULE(RNNativeAdsManager)

@synthesize bridge = _bridge;

- (instancetype)init
{
  self = [super init];
  if (self) {
    _adsManagers = [NSMutableDictionary new];
  }
  return self;
}

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

RCT_EXPORT_METHOD(registerViewsForInteraction:(nonnull NSNumber *)nativeAdViewTag
                            clickableViewsTags:(nonnull NSArray *)tags
                            resolve:(RCTPromiseResolveBlock)resolve
                            reject:(RCTPromiseRejectBlock)reject)
{
  [_bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    RNNativeAdsAdView *nativeAdView = nil;

    if ([viewRegistry objectForKey:nativeAdViewTag] == nil) {
      reject(@"E_NO_NATIVEAD_VIEW", @"Could not find nativeAdView", nil);
      return;
    }

    if ([[viewRegistry objectForKey:nativeAdViewTag] isKindOfClass:[RNNativeAdsAdView class]]) {
      nativeAdView = (RNNativeAdsAdView *)[viewRegistry objectForKey:nativeAdViewTag];
    } else {
      reject(@"E_INVALID_VIEW_CLASS", @"View returned for passed native ad view tag is not an instance of RNNativeAdsAdView", nil);
      return;
    }

    NSMutableArray<UIView *> *clickableViews = [NSMutableArray new];
    for (id tag in tags) {
      if ([viewRegistry objectForKey:tag]) {
        [clickableViews addObject:[viewRegistry objectForKey:tag]];
      } else {
        reject(@"E_INVALID_VIEW_TAG", [NSString stringWithFormat:@"Could not find view for tag:  %@", [tag stringValue]], nil);
        return;
      }
    }

    [nativeAdView registerViewsForInteraction:clickableViews];
    resolve(@[]);
  }];
}

RCT_EXPORT_METHOD(init:(NSString *)adUnitID testDevices:(NSArray *)testDevices)
{
   _testDevices = RNAdMobProcessTestDevices(testDevices, kGADSimulatorID);
   _adUnitID = adUnitID;

    RNNativeAdsManager *adsManager = [RNNativeAdsManager alloc];

    _myAdChoiceViewAdUnitID = adUnitID;

    [_adsManagers setValue:adsManager forKey:adUnitID];
}

- (RNNativeAdsManager *) getAdsManager:(NSString *)adUnitID
{
    return _adsManagers[adUnitID];
}

@end
