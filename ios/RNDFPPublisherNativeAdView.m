#import "RNDFPPublisherNativeAdView.h"
#import "RNAdMobUtils.h"
#import <React/RCTConvert.h>

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

@implementation RNDFPPublisherNativeAdView
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

- (void)createAdView:(GADUnifiedNativeAd *)nativeAd {
    UIView *nativeAdPlaceholder=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 359, 100)];
    [nativeAdPlaceholder setBackgroundColor:[UIColor yellowColor]];
    [nativeAdPlaceholder setTranslatesAutoresizingMaskIntoConstraints:NO];
    nativeAdPlaceholder.userInteractionEnabled = NO;
    nativeAdPlaceholder.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:nativeAdPlaceholder];

    UIImageView *iconPlaceholder=[[UIImageView alloc] initWithImage:nativeAd.icon.image];
    iconPlaceholder.translatesAutoresizingMaskIntoConstraints = NO;
    iconPlaceholder.contentMode = UIViewContentModeScaleAspectFill;
    iconPlaceholder.clipsToBounds = YES;
//    iconPlaceholder.image = nativeAd.icon.image;
//    iconPlaceholder.hidden = nativeAd.icon ? NO : YES;
    [nativeAdPlaceholder addSubview:iconPlaceholder];

    UILabel *headlinePlaceholder=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 359, 40)];
    [headlinePlaceholder setTranslatesAutoresizingMaskIntoConstraints:NO];
    headlinePlaceholder.numberOfLines = 0;
    headlinePlaceholder.textColor = [UIColor blackColor];
    headlinePlaceholder.text = nativeAd.headline;
    [nativeAdPlaceholder addSubview:headlinePlaceholder];

    NSDictionary *viewDictionary =  @{
                           @"headlinePlaceholder" : headlinePlaceholder,
                           @"iconPlaceholder" : iconPlaceholder
    };
    [nativeAdPlaceholder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[headlinePlaceholder]|" options:0 metrics:nil views:viewDictionary]];
    [nativeAdPlaceholder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[iconPlaceholder]|" options:0 metrics:nil views:viewDictionary]];
    
//    [nativeAdPlaceholder sizeToFit];
//    [nativeAdPlaceholder invalidateIntrinsicContentSize];
    [self sizeToFit];
//    [self invalidateIntrinsicContentSize];

    NSDictionary<GADUnifiedNativeAssetIdentifier, UIView *> *clickableAssetViews =  @{
                           GADUnifiedNativeCallToActionAsset : nativeAdPlaceholder
    };
    NSDictionary<GADUnifiedNativeAssetIdentifier, UIView *> *nonclickableAssetViews =  @{
                           GADUnifiedNativeHeadlineAsset : headlinePlaceholder,
                           GADUnifiedNativeIconAsset : iconPlaceholder
    };
    [nativeAd registerAdView:nativeAdPlaceholder
       clickableAssetViews:clickableAssetViews
    nonclickableAssetViews:nonclickableAssetViews];

    NSLog(@"self.frame.size.width: %f", self.frame.size.width);
    NSLog(@"self.frame.size.height: %f", self.frame.size.height);
    NSLog(@"self.bounds.size.width: %f", self.bounds.size.width);
    NSLog(@"self.bounds.size.height: %f", self.bounds.size.height);
    NSLog(@"self.intrinsicContentSize.width: %f", self.intrinsicContentSize.width);
    NSLog(@"self.intrinsicContentSize.height: %f", self.intrinsicContentSize.height);

    self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                300);
    if (self.onSizeChange) {
        self.onSizeChange(@{
                            @"type": @"native",
                            @"width": @(self.frame.size.width),
                            @"height": @(self.frame.size.height) });
    }
}

- (void)applyStyles:(UIView *)view styles:(NSDictionary *)styles {
    if (styles[@"backgroundColor"]) {
        view.backgroundColor = [RCTConvert UIColor:styles[@"backgroundColor"]];
    }
    if (styles[@"visibility"]) {
        NSString *visibility = [RCTConvert NSString:styles[@"visibility"]];
        if ([visibility  isEqual: @"hidden"]) {
            view.hidden =  YES;
        }
    }

    NSMutableDictionary *padding = [[NSMutableDictionary alloc] init];
    padding[@"top"] = @((CGFloat)0);
    padding[@"right"] = @((CGFloat)0);
    padding[@"bottom"] = @((CGFloat)0);
    padding[@"left"] = @((CGFloat)0);
    if (styles[@"padding"]) {
        NSNumber *paddingAll = [RCTConvert NSNumber:styles[@"padding"]];
        padding[@"top"] = @((CGFloat)[paddingAll floatValue]);
        padding[@"right"] = @((CGFloat)[paddingAll floatValue]);
        padding[@"bottom"] = @((CGFloat)[paddingAll floatValue]);
        padding[@"left"] = @((CGFloat)[paddingAll floatValue]);
    }
    if (styles[@"paddingTop"]) {
        NSNumber* paddingTop = [RCTConvert NSNumber:styles[@"paddingTop"]];
        padding[@"top"] = @((CGFloat)[paddingTop floatValue]);
    }
    if (styles[@"paddingRight"]) {
        NSNumber* paddingRight = [RCTConvert NSNumber:styles[@"paddingRight"]];
        padding[@"right"] = @((CGFloat)[paddingRight floatValue]);
    }
    if (styles[@"paddingBottom"]) {
        NSNumber* paddingBottom = [RCTConvert NSNumber:styles[@"paddingBottom"]];
        padding[@"bottom"] = @((CGFloat)[paddingBottom floatValue]);
    }
    if (styles[@"paddingLeft"]) {
        NSNumber* paddingLeft = [RCTConvert NSNumber:styles[@"paddingLeft"]];
        padding[@"left"] = @((CGFloat)[paddingLeft floatValue]);
    }
    CGFloat top = [RCTConvert CGFloat:padding[@"top"]];
    CGFloat left = [RCTConvert CGFloat:padding[@"left"]];
    CGFloat bottom = [RCTConvert CGFloat:padding[@"bottom"]];
    CGFloat right = [RCTConvert CGFloat:padding[@"right"]];
    view.bounds = UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsetsMake(-top, -left, -bottom, -right));
//    view.bounds = CGRectInset(view.frame, top, right);

    NSMutableDictionary *margin = [[NSMutableDictionary alloc] init];
    margin[@"top"] = @((CGFloat)0);
    margin[@"right"] = @((CGFloat)0);
    margin[@"bottom"] = @((CGFloat)0);
    margin[@"left"] = @((CGFloat)0);
    if (styles[@"margin"]) {
        NSNumber* marginAll = [RCTConvert NSNumber:styles[@"margin"]];
        margin[@"top"] = @((CGFloat)[marginAll floatValue]);
        margin[@"right"] = @((CGFloat)[marginAll floatValue]);
        margin[@"bottom"] = @((CGFloat)[marginAll floatValue]);
        margin[@"left"] = @((CGFloat)[marginAll floatValue]);
    }
    if (styles[@"marginTop"]) {
        NSNumber* marginTop = [RCTConvert NSNumber:styles[@"marginTop"]];
        margin[@"top"] = @((CGFloat)[marginTop floatValue]);
    }
    if (styles[@"marginRight"]) {
        NSNumber* marginRight = [RCTConvert NSNumber:styles[@"marginRight"]];
        margin[@"right"] = @((CGFloat)[marginRight floatValue]);
    }
    if (styles[@"marginBottom"]) {
        NSNumber* marginBottom = [RCTConvert NSNumber:styles[@"marginBottom"]];
        margin[@"bottom"] = @((CGFloat)[marginBottom floatValue]);
    }
    if (styles[@"margingLeft"]) {
        NSNumber* margingLeft = [RCTConvert NSNumber:styles[@"margingLeft"]];
        margin[@"left"] = @((CGFloat)[margingLeft floatValue]);
    }
    CGFloat mtop = [RCTConvert CGFloat:margin[@"top"]];
    CGFloat mleft = [RCTConvert CGFloat:margin[@"left"]];
    CGFloat mbottom = [RCTConvert CGFloat:margin[@"bottom"]];
    CGFloat mright = [RCTConvert CGFloat:margin[@"right"]];
    view.layoutMargins = UIEdgeInsetsMake(mtop, mleft, mbottom, mright);

    if (styles[@"width"]) {
        NSNumber* width = [RCTConvert NSNumber:styles[@"width"]];
        view.frame = CGRectMake(view.frame.origin.x,
                                view.frame.origin.y,
                                [width intValue],
                                view.frame.size.height);
    }
    if (styles[@"height"]) {
        NSNumber* height = [RCTConvert NSNumber:styles[@"height"]];
        view.frame = CGRectMake(view.frame.origin.x,
                                view.frame.origin.y,
                                view.frame.size.width,
                                [height intValue]);
    }
    if ([view isKindOfClass:[UILabel class]]) {
        if (styles[@"color"]) {
            UIColor* color = [RCTConvert UIColor:styles[@"color"]];
            [(UILabel *)view setTextColor:color];
        }
        if (styles[@"fontSize"]) {
            [(UILabel *)view setFont: [((UILabel *)view).font fontWithSize:[RCTConvert NSInteger:styles[@"fontSize"]]]];
        }
        if (styles[@"lineHeight"]) {
            NSMutableAttributedString* attrString = [[NSMutableAttributedString  alloc] initWithString:((UILabel *)view).text];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            [style setLineSpacing:[RCTConvert NSInteger:styles[@"lineHeight"]]];
            [attrString addAttribute:NSParagraphStyleAttributeName
                value:style
                range:NSMakeRange(0, attrString.length)];
            ((UILabel *)view).attributedText = attrString;
        }
        if (styles[@"fontFamily"]) {
            UIFont* currentFont = ((UILabel *)view).font;
            [(UILabel *)view setFont: [UIFont
                                       fontWithName:[RCTConvert NSString:styles[@"fontFamily"]]
                                       size:currentFont.pointSize]];
        }
        if (styles[@"textTransform"]) {
            NSString* text = ((UILabel *)view).text;
            NSString *key = [RCTConvert NSString:styles[@"textTransform"]];
            ((void (^)(void))@{
                @"uppercase" : ^{
                    [(UILabel *)view setText:[text uppercaseString]];
                },
                @"lowercase" : ^{
                    [(UILabel *)view setText:[text lowercaseString]];
                },
                @"capitalize" : ^{
                    [(UILabel *)view setText:[text capitalizedString]];
                },
            }[key] ?: ^{
                /// do nothing
            })();
        }
    }
}

- (void)setAdView:(GADUnifiedNativeAd *)nativeAd {
    // Create and place ad in view hierarchy.
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

//    [self createAdView:nativeAd];

    [self setAdView:nativeAd];
}

- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeAd:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"Ad is Loaded: %@", nativeAd);
    if (self.onAdLoaded) {
        /*
         





         if (unifiedNativeAd.getIcon() == null) {
             ad.putString("icon", null);
         } else {
             WritableMap icon = Arguments.createMap();
             icon.putString("uri", unifiedNativeAd.getIcon().getUri().toString());
             icon.putInt("width", unifiedNativeAd.getIcon().getWidth());
             icon.putInt("height", unifiedNativeAd.getIcon().getHeight());
             icon.putDouble("scale", unifiedNativeAd.getIcon().getScale());
             ad.putMap("icon", icon);
         }

         if (unifiedNativeAd.getImages().size() == 0) {
             ad.putArray("images", null);
         } else {
             WritableArray images = Arguments.createArray();
             for (NativeAd.Image image : unifiedNativeAd.getImages()) {
                 WritableMap imageMap = Arguments.createMap();
                 imageMap.putString("uri", image.getUri().toString());
                 imageMap.putInt("width", image.getWidth());
                 imageMap.putInt("height", image.getHeight());
                 imageMap.putDouble("scale", image.getScale());
                 images.pushMap(imageMap);
             }
             ad.putArray("images", images);
         }
         *headline;

         */
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

@end
