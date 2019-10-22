#import "RNDFPPublisherNativeAdView.h"
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

@implementation RNDFPPublisherNativeAdView

- (void)dealloc
{
    _adLoader.delegate = nil;
    _nativeAd.delegate = nil;
}

- (void)loadBanner {
    // Loads an ad for any of app install, content, or custom native ads.
    NSMutableArray *adTypes = [[NSMutableArray alloc] init];
    [adTypes addObject:kGADAdLoaderAdTypeUnifiedNative];

    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
    videoOptions.startMuted = true;

    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = [keyWindow rootViewController];

    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:_adUnitID
                                       rootViewController:rootViewController
                                                  adTypes:adTypes
                                                  options:@[ videoOptions ]];

    self.adLoader.delegate = self;

    GADRequest *request = [GADRequest request];
    request.testDevices = _testDevices;
    [self.adLoader loadRequest:request];
}

- (void)setAdView:(UIView *)view {
    // Remove previous ad view.
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = view;

//    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
//    UIViewController *rootViewController = [keyWindow rootViewController];
//
//    view.rootViewController = rootViewController;

    [self addSubview:view];

    CGFloat subViewHeight = 0;
    for (UIView *subview in view.subviews)
    {
        subViewHeight = subViewHeight + subview.frame.size.height;

        NSLog(@"subview: %@", subview);
        NSLog(@"subview height: %f", subview.frame.size.height);
    }
    NSLog(@"all subview height: %f", subViewHeight);

    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.width/view.frame.size.width*subViewHeight);

    view.frame = self.bounds;

    [self.nativeAdView setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_nativeAdView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nativeAdView]|" options:0 metrics:nil views:viewDictionary]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nativeAdView]|" options:0 metrics:nil views:viewDictionary]];

    if (self.onSizeChange) {
        self.onSizeChange(@{
                            @"width": @(view.frame.size.width),
                            @"height": @(view.frame.size.height) });
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
    RCTLogError(@"RNDFPPublisherNativeAdView cannot have subviews");
}
#pragma clang diagnostic pop

- (void)setAdStyles:(NSDictionary *)adStyles
{
    __block NSMutableDictionary *tmpAdStyles = [adStyles mutableCopy];

    _adStyles = tmpAdStyles;
}

- (void)setTestDevices:(NSArray *)testDevices
{
    _testDevices = RNAdMobProcessTestDevices(testDevices, kDFPSimulatorID);
}

- (void)setAdUnitID:(NSString *)adUnitID
{
    _adUnitID = adUnitID;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _nativeAdView.frame = self.bounds;
}

#pragma mark GADAdLoaderDelegate implementation

/// Tells the delegate an ad request failed.
- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
    if (self.onAdFailedToLoad) {
        self.onAdFailedToLoad(@{ @"error": @{ @"message": [error localizedDescription] } });
    }
}

#pragma mark GADUnifiedNativeAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"Received unified native ad: %@", nativeAd);
    self.nativeAd = nativeAd;

    // Create and place ad in view hierarchy.
    GADUnifiedNativeAdView *nativeAdView = [[NSBundle mainBundle] loadNibNamed:@"UnifiedNativeAdViewSmall" owner:nil options:nil].firstObject;

    nativeAdView.nativeAd = nativeAd;

    // Set ourselves as the ad delegate to be notified of native ad events.
    nativeAd.delegate = self;

    // Populate the native ad view with the native ad assets.
    // The headline and mediaContent are guaranteed to be present in every native ad.
    ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
    nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;

    // This app uses a fixed width for the GADMediaView and changes its height
    // to match the aspect ratio of the media content it displays.
    if (nativeAd.mediaContent.aspectRatio > 0) {
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:nativeAdView.mediaView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nativeAdView.mediaView
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:(1 / nativeAd.mediaContent.aspectRatio)
                                      constant:0];
        heightConstraint.active = YES;
    }

    if (nativeAd.mediaContent.hasVideoContent) {
        // By acting as the delegate to the GADVideoController, this ViewController
        // receives messages about events in the video lifecycle.
        nativeAd.mediaContent.videoController.delegate = self;
    }

    // These assets are not guaranteed to be present. Check that they are before
    // showing or hiding them.
    ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
    nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;

//    [((UIButton *)nativeAdView.callToActionView) setTitle:nativeAd.callToAction
//                                               forState:UIControlStateNormal];
//
//    nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;

    ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
    nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;

    ((UILabel *)nativeAdView.storeView).text = nativeAd.store;
    nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;

    ((UILabel *)nativeAdView.priceView).text = nativeAd.price;
    nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;

    ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
    nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;

    // In order for the SDK to process touch events properly, user interaction
    // should be disabled.
    nativeAdView.callToActionView.userInteractionEnabled = NO;

    [self setAdView:nativeAdView];
}

- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeAd:(GADUnifiedNativeAd *)nativeAd {
    if (self.onAdLoaded) {
        self.onAdLoaded(@{});
    }
}

#pragma mark GADVideoControllerDelegate implementation

- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark GADUnifiedNativeAdDelegate

- (void)nativeAdDidRecordClick:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdDidRecordImpression:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillPresentScreen:(GADUnifiedNativeAd *)nativeAd {
    if (self.onAdOpened) {
        self.onAdOpened(@{});
    }
}

- (void)nativeAdWillDismissScreen:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdDidDismissScreen:(GADUnifiedNativeAd *)nativeAd {
    if (self.onAdClosed) {
        self.onAdClosed(@{});
    }
}

- (void)nativeAdWillLeaveApplication:(GADUnifiedNativeAd *)nativeAd {
    if (self.onAdLeftApplication) {
        self.onAdLeftApplication(@{});
    }
}

@end
