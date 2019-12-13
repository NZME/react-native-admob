#import <React/RCTViewManager.h>

@interface RNNativeAdsManager : RCTViewManager

@property (strong, nonatomic) NSString *adUnitID;
@property (strong, nonatomic) NSArray *testDevices;

- (RNNativeAdsManager *) getAdsManager:(NSString *)adUnitID;

@end
