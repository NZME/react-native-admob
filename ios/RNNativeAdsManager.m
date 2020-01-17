#import "RNNativeAdsManager.h"
#import "RNNativeAdsAdView.h"

#import "RNAdMobUtils.h"

#import <React/RCTUtils.h>
#import <React/RCTAssert.h>
#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridgeModule.h>

#import <React/RCTLog.h>

@interface RNNativeAdsManager ()

//@property (nonatomic, strong) NSMutableDictionary<NSString*, RNNativeAdsManager*> *adsManagers;
//@property (nonatomic, strong) NSMutableDictionary<NSString*, GADAdLoader*> *adLoaders;
@property (nonatomic, strong) NSString *myAdChoiceViewAdUnitID;

@end

@implementation RNNativeAdsManager

RCT_EXPORT_MODULE(RNNativeAdsManager)

@synthesize bridge = _bridge;

- (instancetype)init
{
  self = [super init];
  if (self) {
      if (adsManagers == nil) {
          adsManagers = [NSMutableDictionary new];
      }
      if (adLoaders == nil) {
          adLoaders = [NSMutableDictionary new];
      }
  }
  return self;
}

static NSMutableDictionary<NSString*, RNNativeAdsManager*> *adsManagers;
static NSMutableDictionary<NSString*, GADAdLoader*> *adLoaders;

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
    RNNativeAdsManager *adsManager = [RNNativeAdsManager alloc];

    adsManager.adUnitID = adUnitID;
    adsManager.testDevices = RNAdMobProcessTestDevices(testDevices, kGADSimulatorID);
    
    _myAdChoiceViewAdUnitID = adUnitID;

    [adsManagers setValue:adsManager forKey:adUnitID];
}

- (RNNativeAdsManager *) getAdsManager:(NSString *)adUnitID
{
    return adsManagers[adUnitID];
}

- (GADAdLoader *) getAdLoader:(NSString *)adUnitID validAdTypes:(NSArray *)validAdTypes
{
    NSString *adLoaderKey = adUnitID;
    if ([validAdTypes containsObject:@"native"]) {
        adLoaderKey = [NSString stringWithFormat:@"%@%@", adLoaderKey, @"native"];
    }
    if ([validAdTypes containsObject:@"banner"]) {
        adLoaderKey = [NSString stringWithFormat:@"%@%@", adLoaderKey, @"banner"];
    }
    if ([validAdTypes containsObject:@"template"]) {
        adLoaderKey = [NSString stringWithFormat:@"%@%@", adLoaderKey, @"template"];
    }

    GADAdLoader *adLoader = [adLoaders objectForKey:adLoaderKey];
    if (adLoader == nil) {
        // Loads an ad for any of app install, content, or custom native ads.
        NSMutableArray *adTypes = [[NSMutableArray alloc] init];
        if ([validAdTypes containsObject:@"native"]) {
            [adTypes addObject:kGADAdLoaderAdTypeUnifiedNative];
        }
        if ([validAdTypes containsObject:@"banner"]) {
            [adTypes addObject:kGADAdLoaderAdTypeDFPBanner];
        }
        if ([validAdTypes containsObject:@"template"]) {
            [adTypes addObject:kGADAdLoaderAdTypeNativeCustomTemplate];
        }

        GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
        videoOptions.startMuted = YES;

        adLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnitID
                                           rootViewController:[UIApplication sharedApplication].delegate.window.rootViewController
                                                      adTypes:adTypes
                                                      options:@[ videoOptions ]];

        [adLoaders setValue:adLoader forKey:adLoaderKey];
    }

    return adLoader;
}

@end
