#import <React/RCTViewManager.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface RNNativeAdsManager : RCTViewManager

@property (strong, nonatomic) NSString *adUnitID;
@property (strong, nonatomic) NSArray *testDevices;

- (RNNativeAdsManager *) getAdsManager:(NSString *)adUnitID;
- (GADAdLoader *) getAdLoader:(NSString *)adUnitID validAdTypes:(NSArray *)validAdTypes;

@end
