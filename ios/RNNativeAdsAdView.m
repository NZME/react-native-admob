#import "RNNativeAdsAdView.h"
#import "RNNativeAdsManager.h"
#import "RNAdMobUtils.h"
#import <React/RCTConvert.h>

#import <React/RCTBridgeModule.h>
#import <React/UIView+React.h>
#import <React/RCTLog.h>

#include "RCTConvert+GADAdSize.h"

static NSString *const kAdTypeBanner = @"banner";
static NSString *const kAdTypeNative = @"native";
static NSString *const kAdTypeTemplate = @"template";

@implementation RNNativeAdsAdView
{
    /// You must keep a strong reference to the GADAdLoader during the ad loading process.
    GADAdLoader *_adLoader;
    /// The native ad that is being loaded.
    GADUnifiedNativeAd *_nativeAd;
    /// The native ad view that is being presented.
    GADUnifiedNativeAdView *_nativeAdView;
    DFPBannerView *_bannerView;
    GADNativeCustomTemplateAd *_nativeCustomTemplateAd;
    NSString *_nativeCustomTemplateAdClickableAsset;
    NSString *_adUnitID;
    NSArray *_testDevices;
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

- (void)loadAd:(RNNativeAdsManager *)adManager {
    _adUnitID = adManager.adUnitID;
    _testDevices = adManager.testDevices;

    if (_validAdTypes == nil) {
        _validAdTypes = @[
            kAdTypeBanner,
            kAdTypeNative,
            kAdTypeTemplate
        ];
    }

    // Loads an ad for any of app install, content, or custom native ads.
    NSMutableArray *adTypes = [[NSMutableArray alloc] init];
    if ([_validAdTypes containsObject:kAdTypeNative]) {
        [adTypes addObject:kGADAdLoaderAdTypeUnifiedNative];
    }
    if ((_validAdSizes != nil || _adSize != nil) && [_validAdTypes containsObject:kAdTypeBanner]) {
        [adTypes addObject:kGADAdLoaderAdTypeDFPBanner];
    }
    if (_customTemplateId != nil && [_validAdTypes containsObject:kAdTypeTemplate]) {
        [adTypes addObject:kGADAdLoaderAdTypeNativeCustomTemplate];
    }

    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
    videoOptions.startMuted = true;

    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = [keyWindow rootViewController];

    _adLoader = [[GADAdLoader alloc] initWithAdUnitID:_adUnitID
                                       rootViewController:rootViewController
                                                  adTypes:adTypes
                                                  options:@[ videoOptions ]];

    _adLoader.delegate = self;

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

    [_adLoader loadRequest:request];
}

- (void)reloadAd {
    if (_adLoader == nil) {
        return;
    }

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

    [_adLoader loadRequest:request];
}

- (void)setCustomTemplateId:(NSString *)customTemplateId
{
    _customTemplateId = customTemplateId;
}

- (void)setValidAdTypes:(NSArray *)adTypes
{
    __block NSMutableArray *validAdTypes = [[NSMutableArray alloc] initWithCapacity:adTypes.count];
    [adTypes enumerateObjectsUsingBlock:^(id jsonValue, NSUInteger idx, __unused BOOL *stop) {
        [validAdTypes addObject:[RCTConvert NSString:jsonValue]];
    }];
    _validAdTypes = validAdTypes;
}

- (void)setAdSize:(NSString *)adSize
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
    _nativeAdView = nil;
    _bannerView = nil;
    _nativeCustomTemplateAd = nil;
    if (_adLoader != nil) {
        _adLoader.delegate = nil;
        _adLoader = nil;
    }
    if (_nativeAd != nil) {
        _nativeAd.delegate = nil;
        _nativeAd = nil;
    }
}

#pragma mark GADUnifiedNativeAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd {
    [_bannerView removeFromSuperview];
    [_nativeAdView removeFromSuperview];

    _nativeAdView = [[GADUnifiedNativeAdView alloc] init];

    _nativeAdView.translatesAutoresizingMaskIntoConstraints = NO;
    _nativeAdView.contentMode = UIViewContentModeScaleAspectFit;
    _nativeAdView.clipsToBounds = YES;

    _nativeAd = nativeAd;
    _nativeAdView.nativeAd = _nativeAd;

    [self addSubview:_nativeAdView];

    // Set ourselves as the ad delegate to be notified of native ad events.
    _nativeAd.delegate = self;

    [self triggerAdLoadedEvent:_nativeAd];

    _bannerView = nil;
    _nativeCustomTemplateAd = nil;
    if (_adLoader != nil) {
        _adLoader.delegate = nil;
        _adLoader = nil;
    }
}

- (void)triggerAdLoadedEvent:(GADUnifiedNativeAd *)nativeAd {
    if (self.onAdLoaded) {
        NSMutableDictionary *ad = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   kAdTypeNative, @"type",
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
                nativeAd.icon.imageURL.absoluteString, @"uri",
                [[NSNumber numberWithFloat:nativeAd.icon.image.size.width] stringValue], @"width",
                [[NSNumber numberWithFloat:nativeAd.icon.image.size.height] stringValue], @"height",
                [[NSNumber numberWithFloat:nativeAd.icon.scale] stringValue], @"scale",
                nil];
        }

        if (nativeAd.images != nil) {
            NSMutableArray *images = [[NSMutableArray alloc] init];
            [nativeAd.images enumerateObjectsUsingBlock:^(GADNativeAdImage *value, NSUInteger idx, __unused BOOL *stop) {
                [images addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                    value.imageURL.absoluteString, @"uri",
                    [[NSNumber numberWithFloat:value.image.size.width] stringValue], @"width",
                    [[NSNumber numberWithFloat:value.image.size.height] stringValue], @"height",
                    [[NSNumber numberWithFloat:value.scale] stringValue], @"scale",
                    nil]];
            }];
            ad[@"images"] = images;
        }

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
    [_bannerView removeFromSuperview];
    [_nativeAdView removeFromSuperview];
    _bannerView = bannerView;

    [self addSubview:bannerView];

//    bannerView.delegate = self;
//    bannerView.adSizeDelegate = self;
//    bannerView.appEventDelegate = self;

    if (self.onSizeChange) {
        self.onSizeChange(@{
                            @"type": kAdTypeBanner,
                            @"width": @(bannerView.frame.size.width),
                            @"height": @(bannerView.frame.size.height) });
    }
    if (self.onAdLoaded) {
        self.onAdLoaded(@{
            @"type": kAdTypeBanner,
            @"gadSize": NSValueFromGADAdSize(bannerView.adSize),
        });
    }

    _nativeAdView = nil;
    _nativeCustomTemplateAd = nil;
    if (_adLoader != nil) {
        _adLoader.delegate = nil;
        _adLoader = nil;
    }
    if (_nativeAd != nil) {
        _nativeAd.delegate = nil;
        _nativeAd = nil;
    }
}

#pragma mark GADNativeCustomTemplateAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeCustomTemplateAd:(GADNativeCustomTemplateAd *)nativeCustomTemplateAd {
    [_bannerView removeFromSuperview];
    [_nativeAdView removeFromSuperview];

    _nativeCustomTemplateAd = nativeCustomTemplateAd;

    [self triggerCustomAdLoadedEvent:_nativeCustomTemplateAd];

    [_nativeCustomTemplateAd recordImpression];

    _nativeAdView = nil;
    _bannerView = nil;
    if (_adLoader != nil) {
        _adLoader.delegate = nil;
        _adLoader = nil;
    }
    if (_nativeAd != nil) {
        _nativeAd.delegate = nil;
        _nativeAd = nil;
    }
}

- (NSArray *)nativeCustomTemplateIDsForAdLoader:(GADAdLoader *)adLoader {
    return @[ _customTemplateId ];
}

- (void)triggerCustomAdLoadedEvent:(GADNativeCustomTemplateAd *)nativeCustomTemplateAd {
    if (self.onAdLoaded) {
        NSMutableDictionary *ad = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   kAdTypeTemplate, @"type",
                                   nil];

        [nativeCustomTemplateAd.availableAssetKeys enumerateObjectsUsingBlock:^(NSString *value, NSUInteger idx, __unused BOOL *stop) {
            if ([nativeCustomTemplateAd stringForKey:value] != nil) {
                NSString *assetVal = [nativeCustomTemplateAd stringForKey:value];
                if (_nativeCustomTemplateAdClickableAsset == nil && assetVal.length > 2) {
                    _nativeCustomTemplateAdClickableAsset = value;
                }
                ad[value] = assetVal;
            } else if ([nativeCustomTemplateAd imageForKey:value] != nil) {
                GADNativeAdImage *image = [nativeCustomTemplateAd imageForKey:value];
                ad[value] = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                             image.imageURL.absoluteString, @"uri",
                             [[NSNumber numberWithFloat:image.image.size.width] stringValue], @"width",
                             [[NSNumber numberWithFloat:image.image.size.height] stringValue], @"height",
                             [[NSNumber numberWithFloat:image.scale] stringValue], @"scale",
                             nil];
            }
        }];

        self.onAdLoaded(ad);
    }
}

#pragma mark GADVideoControllerDelegate implementation

//- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}

#pragma mark GADUnifiedNativeAdDelegate

//- (void)nativeAdDidRecordClick:(GADUnifiedNativeAd *)nativeAd {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)nativeAdDidRecordImpression:(GADUnifiedNativeAd *)nativeAd {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}

- (void)nativeAdWillPresentScreen:(GADUnifiedNativeAd *)nativeAd {
    if (self.onAdOpened) {
        self.onAdOpened(@{});
    }
}

//- (void)nativeAdWillDismissScreen:(GADUnifiedNativeAd *)nativeAd {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}

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

- (void)registerViewsForInteraction:(NSArray<UIView *> *)clickableViews {
    if (_nativeCustomTemplateAd != nil && _nativeCustomTemplateAdClickableAsset != nil) {
        [clickableViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, __unused BOOL *stop) {
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                        initWithTarget:self
                                        action:@selector(performClickOnCustomAd)]];
            view.userInteractionEnabled = YES;
        }];
    } else if (_nativeAdView != nil) {
        [clickableViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, __unused BOOL *stop) {
            [view removeFromSuperview];
            view.userInteractionEnabled = NO;
            [_nativeAdView addSubview:view];
            _nativeAdView.callToActionView = view;
        }];
    }
}

- (void)performClickOnCustomAd {
    if (_nativeCustomTemplateAd != nil) {
        [_nativeCustomTemplateAd performClickOnAssetWithKey:_nativeCustomTemplateAdClickableAsset];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
    if (_nativeAdView != nil) {
        [subview removeFromSuperview];
        subview.userInteractionEnabled = NO;
        [_nativeAdView addSubview:subview];
        _nativeAdView.callToActionView = subview;
    } else {
        [super insertReactSubview:subview atIndex:atIndex];
    }
}
#pragma clang diagnostic pop

@end
