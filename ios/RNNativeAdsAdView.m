#import "RNNativeAdsAdView.h"
#import "RNAdMobUtils.h"
#import <React/RCTConvert.h>

#import <React/RCTBridgeModule.h>
#import <React/UIView+React.h>
#import <React/RCTLog.h>

#include "RCTConvert+GADAdSize.h"

@implementation RNNativeAdsAdView
{
    DFPBannerView  *_bannerView;
}

- (void)dealloc
{
    _adLoader.delegate = nil;
    _nativeAd.delegate = nil;
//    _bannerView.delegate = nil;
//    _bannerView.adSizeDelegate = nil;
//    _bannerView.appEventDelegate = nil;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _nativeAdView.frame = self.bounds;
}

- (void)loadBanner {
_testDevices = testDevices;
_adUnitID = adUnitID;


    // Loads an ad for any of app install, content, or custom native ads.
    NSMutableArray *adTypes = [[NSMutableArray alloc] init];
    [adTypes addObject:kGADAdLoaderAdTypeUnifiedNative];
    if (_validAdSizes != nil || _adSize != nil) {
        [adTypes addObject:kGADAdLoaderAdTypeDFPBanner];
    }

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

- (void)setAdView:(GADUnifiedNativeAd *)nativeAd {
    /* // Create and place ad in view hierarchy.
    GADUnifiedNativeAdView *nativeAdView = [[NSBundle mainBundle] loadNibNamed:@"UnifiedNativeAdViewSmall" owner:nil options:nil].firstObject;

    nativeAdView.translatesAutoresizingMaskIntoConstraints = NO;
    nativeAdView.contentMode = UIViewContentModeScaleAspectFit;
    nativeAdView.clipsToBounds = YES;

    nativeAdView.nativeAd = nativeAd;

    // Populate the native ad view with the native ad assets.
    // The headline and mediaContent are guaranteed to be present in every native ad.
    if (nativeAdView.headlineView) {
        ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
        if (_adStyles[@"ad_headline"]) {
            [self applyStyles:nativeAdView.headlineView styles:(NSDictionary *)_adStyles[@"ad_headline"]];
        }
    }

    if (nativeAdView.advertiserView) {
        ((UILabel *)nativeAdView.advertiserView).text = @"Sponsored";
        if (_adStyles[@"ad_sponsored"]) {
            [self applyStyles:nativeAdView.advertiserView styles:(NSDictionary *)_adStyles[@"ad_sponsored"]];
        }
    }

    if (nativeAdView.mediaView) {
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
    }

    // These assets are not guaranteed to be present. Check that they are before
    // showing or hiding them.
    if (nativeAdView.bodyView) {
        ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
        nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;
        if (_adStyles[@"ad_body"]) {
            [self applyStyles:nativeAdView.bodyView styles:(NSDictionary *)_adStyles[@"ad_body"]];
        }
    }

    if (nativeAdView.callToActionView) {
        if ([nativeAdView.callToActionView isKindOfClass:[UIButton class]]) {
            [((UIButton *)nativeAdView.callToActionView) setTitle:nativeAd.callToAction forState:UIControlStateNormal];

            nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;
        }

        // In order for the SDK to process touch events properly, user interaction
        // should be disabled.
        nativeAdView.callToActionView.userInteractionEnabled = NO;

        if (_adStyles[@"ad_call_to_action"]) {
            [self applyStyles:nativeAdView.callToActionView styles:(NSDictionary *)_adStyles[@"ad_call_to_action"]];
        }
    }

    if (nativeAdView.iconView) {
        ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
        nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;
        if (_adStyles[@"ad_app_icon"]) {
            [self applyStyles:nativeAdView.iconView styles:(NSDictionary *)_adStyles[@"ad_app_icon"]];
        }
    }

    if (nativeAdView.storeView) {
        ((UILabel *)nativeAdView.storeView).text = nativeAd.store;
        nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;
        if (_adStyles[@"ad_store"]) {
            [self applyStyles:nativeAdView.storeView styles:(NSDictionary *)_adStyles[@"ad_store"]];
        }
    }

    if (nativeAdView.priceView) {
        ((UILabel *)nativeAdView.priceView).text = nativeAd.price;
        nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;
        if (_adStyles[@"ad_price"]) {
            [self applyStyles:nativeAdView.priceView styles:(NSDictionary *)_adStyles[@"ad_price"]];
        }
    }

//    if (nativeAdView.advertiserView) {
//        ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
//        nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;
//        if (_adStyles[@"ad_advertiser"]) {
//            [self applyStyles:nativeAdView.advertiserView styles:(NSDictionary *)_adStyles[@"ad_advertiser"]];
//        }
//    }

    // Remove previous ad view.
    [_bannerView removeFromSuperview];
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nativeAdView;

    [self addSubview:nativeAdView];

    CGFloat subViewHeight = nativeAdView.iconView.frame.size.height + nativeAdView.iconView.frame.origin.y;
    if (nativeAdView.bodyView.frame.size.height + nativeAdView.bodyView.frame.origin.y > subViewHeight) {
        subViewHeight = nativeAdView.bodyView.frame.size.height + nativeAdView.bodyView.frame.origin.y;
    }

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_nativeAdView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nativeAdView]|" options:0 metrics:nil views:viewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nativeAdView]|" options:0 metrics:nil views:viewDictionary]];

//    NSLog(@"intrinsicContentSize.height: %f", nativeAdView.intrinsicContentSize.height);

    self.bounds = CGRectMake(self.frame.origin.x,
        self.frame.origin.y,
        self.frame.size.width,
        subViewHeight);

    if (self.onSizeChange) {
        self.onSizeChange(@{
                            @"type": @"native",
                            @"width": @(self.frame.size.width),
                            @"height": @(self.frame.size.height) });
    } */
}

- (void)setadSize:(NSString *)adSize
{
    _adSize = adSize;
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

#pragma mark GADAdLoaderDelegate implementation

/// Tells the delegate an ad request failed.UnifiedNativeAdView
- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
    if (self.onAdFailedToLoad) {
        self.onAdFailedToLoad(@{ @"error": @{ @"message": [error localizedDescription] } });
    }
}

#pragma mark GADUnifiedNativeAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"Received unified native ad: %@", nativeAd);

    self.nativeAd = nativeAd;

    // Set ourselves as the ad delegate to be notified of native ad events.
    nativeAd.delegate = self;

    [self setAdView:nativeAd];
}

- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeAd:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"Ad is Loaded: %@", nativeAd);
    if (self.onAdLoaded) {
        NSMutableDictionary *ad = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   @"native", @"type",
                                   nativeAd.headline, @"headline",
                                   nativeAd.body, @"bodyText",
                                   nativeAd.callToAction, @"callToActionText",
                                   nativeAd.advertiser, @"advertiserName",
                                   nativeAd.starRating, @"starRating",
                                   nativeAd.store, @"storeName",
                                   nativeAd.price, @"price",
                                   nil, @"icon",
                                   nil, @"images",
                                   nil];

        if (nativeAd.icon != nil) {
            ad[@"icon"] = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                           nativeAd.icon.imageURL, @"uri",
                           nativeAd.icon.image.size.width, @"width",
                           nativeAd.icon.image.size.height, @"height",
                           nativeAd.icon.scale, @"scale",
                           nil];
        }

        if (nativeAd.images != nil) {
            NSMutableArray *images = [NSMutableArray init];
            [nativeAd.images enumerateObjectsUsingBlock:^(GADNativeAdImage *value, NSUInteger idx, __unused BOOL *stop) {
                [images addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   value.imageURL, @"uri",
                                   value.image.size.width, @"width",
                                   value.image.size.height, @"height",
                                   value.scale, @"scale",
                                   nil]];
            }];
            ad[@"images"] = images;
        }

        RCTLogWarn(@"Invalid adSize %@", ad);

        self.onAdLoaded(ad);
    }
}

#pragma mark DFPBannerAdLoaderDelegate implementation

- (nonnull NSArray<NSValue *> *)validBannerSizesForAdLoader:
(nonnull GADAdLoader *)adLoader {
    NSMutableArray *validAdSizes = [NSMutableArray arrayWithArray:_validAdSizes];
    if (_adSize != nil) {
        GADAdSize adSize = [RCTConvert GADAdSize:_adSize];
        if (GADAdSizeEqualToSize(adSize, kGADAdSizeInvalid)) {
            RCTLogWarn(@"Invalid adSize %@", _adSize);
        } else {
            [validAdSizes addObject:NSValueFromGADAdSize(adSize)];
        }
    }
    return validAdSizes;
}

- (void)adLoader:(nonnull GADAdLoader *)adLoader
didReceiveDFPBannerView:(nonnull DFPBannerView *)bannerView {
    NSLog(@"banner is Loaded: %@", bannerView);
    [_bannerView removeFromSuperview];
    [_nativeAdView removeFromSuperview];
    _bannerView = bannerView;

    [self addSubview:bannerView];

//    bannerView.delegate = self;
//    bannerView.adSizeDelegate = self;
//    bannerView.appEventDelegate = self;

    if (self.onSizeChange) {
        self.onSizeChange(@{
                            @"type": @"banner",
                            @"width": @(bannerView.frame.size.width),
                            @"height": @(bannerView.frame.size.height) });
    }
    if (self.onAdLoaded) {
        self.onAdLoaded(@{
            @"type": @"banner",
            @"gadSize": NSValueFromGADAdSize(bannerView.adSize),
        });
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

- (void)registerViewsForInteraction:(NSArray<UIView *> *)clickableViews
{
//   [_nativeAd registerViewForInteraction:self
//                              viewController:RCTKeyWindow().rootViewController
//                              clickableViews:clickableViews];
}

@end
