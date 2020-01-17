#import "RNDFPBannerView.h"
#import "RNAdMobUtils.h"

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/UIView+React.h>
#import <React/RCTLog.h>
#else
#import "RCTBridgeModule.h"
#import "UIView+React.h"
#import "RCTLog.h"
#endif

#include "RCTConvert+GADAdSize.h"

@implementation RNDFPBannerView
{
    BOOL isAdLoading;
}

- (void)dealloc
{
    self.bannerView.delegate = nil;
    self.bannerView.adSizeDelegate = nil;
    self.bannerView.appEventDelegate = nil;
    self.bannerView.rootViewController = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        super.backgroundColor = [UIColor clearColor];
        //    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        //    UIViewController *rootViewController = [keyWindow rootViewController];
        DFPBannerView *bannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        self.bannerView = bannerView;
        self.bannerView.delegate = self;
        self.bannerView.adSizeDelegate = self;
        self.bannerView.appEventDelegate = self;
        self.bannerView.rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        self.bannerView.translatesAutoresizingMaskIntoConstraints = YES;
        [self addSubview:self.bannerView];
    }

    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
    RCTLogError(@"RNDFPBannerView cannot have subviews");
}
#pragma clang diagnostic pop

- (void)loadBanner {
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = _testDevices;
    DFPRequest *request = [DFPRequest request];

    if (_targeting != nil) {
        NSDictionary *customTargeting = [_targeting objectForKey:@"customTargeting"];
        if (customTargeting != nil) {
            request.customTargeting = customTargeting;
        }
        NSArray *categoryExclusions = [_targeting objectForKey:@"categoryExclusions"];
        if (categoryExclusions != nil) {
            request.categoryExclusions = categoryExclusions;
        }
        NSArray *keywords = [_targeting objectForKey:@"keywords"];
        if (keywords != nil) {
            request.keywords = keywords;
        }
        NSString *contentURL = [_targeting objectForKey:@"contentURL"];
        if (contentURL != nil) {
            request.contentURL = contentURL;
        }
        NSString *publisherProvidedID = [_targeting objectForKey:@"publisherProvidedID"];
        if (publisherProvidedID != nil) {
            request.publisherProvidedID = publisherProvidedID;
        }
        NSDictionary *location = [_targeting objectForKey:@"location"];
        if (location != nil) {
            CGFloat latitude = [[location objectForKey:@"latitude"] doubleValue];
            CGFloat longitude = [[location objectForKey:@"longitude"] doubleValue];
            CGFloat accuracy = [[location objectForKey:@"accuracy"] doubleValue];
            [request setLocationWithLatitude:latitude longitude:longitude accuracy:accuracy];
        }
    }
    
    isAdLoading = YES;

    GADAdSize adSize = [RCTConvert GADAdSize:_adSize];
    if (!GADAdSizeEqualToSize(adSize, kGADAdSizeInvalid)) {
        self.bannerView.adSize = adSize;
    }
    
    self.bannerView.adUnitID = _adUnitID;
    
    self.bannerView.validAdSizes = _validAdSizes;
    [self.bannerView loadRequest:request];
}

- (void)setValidAdSizes:(NSArray *)adSizes
{
    __block NSMutableArray *validAdSizes = [[NSMutableArray alloc] initWithCapacity:adSizes.count];
    [adSizes enumerateObjectsUsingBlock:^(id jsonValue, NSUInteger idx, __unused BOOL *stop) {
        GADAdSize adSize = [RCTConvert GADAdSize:jsonValue];
        if (GADAdSizeEqualToSize(adSize, kGADAdSizeInvalid)) {
            RCTLogWarn(@"Invalid adSize %@", jsonValue);
        } else {
            [validAdSizes addObject:NSValueFromGADAdSize(adSize)];
        }
    }];

    _validAdSizes = validAdSizes;
}

- (void)setAdSize:(NSString *)adSize
{
    _adSize = adSize;
}

- (void)setTestDevices:(NSArray *)testDevices
{
    _testDevices = RNAdMobProcessTestDevices(testDevices, kDFPSimulatorID);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.bannerView.frame = self.bounds;
}

# pragma mark GADBannerViewDelegate

/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(DFPBannerView *)adView
{
    if (isAdLoading == NO) {
        return;
    }
    if (self.onSizeChange) {
        self.onSizeChange(@{
                            @"type": @"banner",
                            @"width": @(adView.frame.size.width),
                            @"height": @(adView.frame.size.height) });
    }
    if (self.onAdLoaded) {
        self.onAdLoaded(@{});
    }
    isAdLoading = NO;
}

/// Tells the delegate an ad request failed.
- (void)adView:(DFPBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    if (self.onAdFailedToLoad) {
        self.onAdFailedToLoad(@{ @"error": @{ @"message": [error localizedDescription] } });
    }
    self.bannerView.delegate = nil;
    self.bannerView.adSizeDelegate = nil;
    self.bannerView.appEventDelegate = nil;
    self.bannerView.rootViewController = nil;
    self.bannerView = nil;
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(DFPBannerView *)adView
{
    if (self.onAdOpened) {
        self.onAdOpened(@{});
    }
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(__unused DFPBannerView *)adView
{
    if (self.onAdClosed) {
        self.onAdClosed(@{});
    }
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(DFPBannerView *)adView
{
    if (self.onAdLeftApplication) {
        self.onAdLeftApplication(@{});
    }
}

# pragma mark GADAdSizeDelegate

- (void)adView:(GADBannerView *)bannerView willChangeAdSizeTo:(GADAdSize)size
{
    CGSize adSize = CGSizeFromGADAdSize(size);
    self.onSizeChange(@{
                        @"type": @"banner",
                        @"width": @(adSize.width),
                        @"height": @(adSize.height) });
}

# pragma mark GADAppEventDelegate

- (void)adView:(GADBannerView *)banner didReceiveAppEvent:(NSString *)name withInfo:(NSString *)info
{
    if (self.onAppEvent) {
        self.onAppEvent(@{ @"name": name, @"info": info });
    }
}

@end
