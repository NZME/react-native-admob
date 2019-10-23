//
//  GADUnifiedNativeAdViewSmall.m
//  DoubleConversion
//
//  Created by Matej Drobnic on 23/10/19.
//

#import "GADUnifiedNativeAdViewSmall.h"

@interface MySimpleNativeAdView ()

/// The custom native ad that populated this view.
@property(nonatomic, strong) GADNativeCustomTemplateAd *customNativeAd;

@end

@implementation GADUnifiedNativeAdViewSmall
    var nativeAdAssets: NativeAdAssets?

    private let myImageView: UIImageView = {
        let myImageView = UIImageView()
        myImageView.translatesAutoresizingMaskIntoConstraints = false
        myImageView.contentMode = .scaleAspectFill
        myImageView.clipsToBounds = true
        return myImageView
    }()

    private let myHeadlineView: UILabel = {
        let myHeadlineView = UILabel()
        myHeadlineView.translatesAutoresizingMaskIntoConstraints = false
        myHeadlineView.numberOfLines = 0
        myHeadlineView.textColor = .black
        return myHeadlineView
    }()

    private let tappableOverlay: UIView = {
        let tappableOverlay = UIView()
        tappableOverlay.translatesAutoresizingMaskIntoConstraints = false
        tappableOverlay.isUserInteractionEnabled = true
        return tappableOverlay
    }()

    private let adAttribution: UILabel = {
        let adAttribution = UILabel()
        adAttribution.translatesAutoresizingMaskIntoConstraints = false
        adAttribution.text = "Ad"
        adAttribution.textColor = .white
        adAttribution.textAlignment = .center
        adAttribution.backgroundColor = UIColor(red: 1, green: 0.8, blue: 0.4, alpha: 1)
        adAttribution.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.semibold)
        return adAttribution
    }()

    override var nativeContentAd: GADNativeContentAd? {
        didSet {
            if let nativeContentAd = nativeContentAd, let callToActionView = callToActionView {
                nativeContentAd.register(self,
                                         clickableAssetViews: [GADNativeContentAdAssetID.callToActionAsset: callToActionView],
                                         nonclickableAssetViews: [:])
            }
        }
    }

    init() {
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        isUserInteractionEnabled = true
        callToActionView = tappableOverlay
        headlineView = myHeadlineView
        imageView = myImageView
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        addSubview(myHeadlineView)
        addSubview(myImageView)
        addSubview(adAttribution)
        addSubview(tappableOverlay)
    }

//    override func updateConstraints() {
//          ....
//    }
@end
