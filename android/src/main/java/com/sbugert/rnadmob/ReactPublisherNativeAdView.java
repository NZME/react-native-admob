package com.sbugert.rnadmob;

import java.util.Arrays;
import java.util.List;
import java.io.IOException;

import android.content.Context;

import androidx.annotation.Nullable;

import android.util.Log;
import android.view.View;
import android.graphics.Color;
import android.view.Choreographer;
import android.view.LayoutInflater;
import android.widget.TextView;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.graphics.Typeface;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.PixelUtil;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.facebook.react.views.view.ReactViewGroup;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.doubleclick.AppEventListener;
import com.google.android.gms.ads.doubleclick.PublisherAdRequest;
import com.google.android.gms.ads.doubleclick.PublisherAdView;
import com.google.android.gms.ads.AdLoader;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.formats.NativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;
import com.google.android.gms.ads.formats.OnPublisherAdViewLoadedListener;
import com.google.android.gms.ads.formats.MediaView;
import com.google.android.gms.ads.VideoController;
import com.google.android.gms.ads.VideoOptions;
import com.google.android.gms.ads.formats.NativeAdOptions;

import java.util.ArrayList;


class ReactPublisherNativeAdView extends ReactViewGroup implements AppEventListener, LifecycleEventListener, UnifiedNativeAd.OnUnifiedNativeAdLoadedListener, OnPublisherAdViewLoadedListener {
    protected AdLoader adLoader;
    protected WritableMap ad;
    protected UnifiedNativeAdView adView;
    protected PublisherAdView publisherAdView;
    protected ReactApplicationContext applicationContext;

    String[] testDevices;
    ReadableMap adStyles;
    String adUnitID;
    AdSize[] validAdSizes;
    AdSize adSize;

    public ReactPublisherNativeAdView(final ThemedReactContext context, ReactApplicationContext applicationContext) {
        super(context);
        this.applicationContext = applicationContext;
        this.applicationContext.addLifecycleEventListener(this);
        this.requestLayout();
        setupLayoutHack();

        this.createAdView();
    }

    private void processUnifiedNativeAd(UnifiedNativeAd unifiedNativeAd) {
        ad = Arguments.createMap();

        if (unifiedNativeAd.getHeadline() == null) {
            ad.putString("headline", null);
        } else {
            ad.putString("headline", unifiedNativeAd.getHeadline());
        }

        if (unifiedNativeAd.getBody() == null) {
            ad.putString("body", null);
        } else {
            ad.putString("body", unifiedNativeAd.getBody());
        }

        if (unifiedNativeAd.getCallToAction() == null) {
            ad.putString("callToAction", null);
        } else {
            ad.putString("callToAction", unifiedNativeAd.getCallToAction());
        }

        if (unifiedNativeAd.getAdvertiser() == null) {
            ad.putString("advertiser", null);
        } else {
            ad.putString("advertiser", unifiedNativeAd.getAdvertiser());
        }

        if (unifiedNativeAd.getStarRating() == null) {
            ad.putString("starRating", null);
        } else {
            ad.putDouble("starRating", unifiedNativeAd.getStarRating());
        }

        if (unifiedNativeAd.getStore() == null) {
            ad.putString("store", null);
        } else {
            ad.putString("store", unifiedNativeAd.getStore());
        }

        if (unifiedNativeAd.getPrice() == null) {
            ad.putString("price", null);
        } else {
            ad.putString("price", unifiedNativeAd.getPrice());
        }

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
    }

    private void applyStyle(View view, ReadableMap styles) {
        if (styles.hasKey("backgroundColor") && styles.getString("backgroundColor") != null) {
            int backgroundColor = Color.parseColor(styles.getString("backgroundColor"));
            view.setBackgroundColor(backgroundColor);
        }
        if (styles.hasKey("visibility") && styles.getString("visibility") != null && styles.getString("visibility").equals("hidden")) {
            view.setVisibility(View.INVISIBLE);
        }
        WritableMap padding = Arguments.createMap();
        padding.putInt("top", 0);
        padding.putInt("right", 0);
        padding.putInt("bottom", 0);
        padding.putInt("left", 0);
        if (styles.hasKey("padding")) {
            int paddingAll = Math.round(PixelUtil.toPixelFromDIP(styles.getInt("padding")));
            padding.putInt("top", paddingAll);
            padding.putInt("right", paddingAll);
            padding.putInt("bottom", paddingAll);
            padding.putInt("left", paddingAll);
        }
        if (styles.hasKey("paddingTop")) {
            padding.putInt("top", Math.round(PixelUtil.toPixelFromDIP(styles.getInt("paddingTop"))));
        }
        if (styles.hasKey("paddingRight")) {
            padding.putInt("right", Math.round(PixelUtil.toPixelFromDIP(styles.getInt("paddingRight"))));
        }
        if (styles.hasKey("paddingBottom")) {
            padding.putInt("bottom", Math.round(PixelUtil.toPixelFromDIP(styles.getInt("paddingBottom"))));
        }
        if (styles.hasKey("paddingLeft")) {
            padding.putInt("left", Math.round(PixelUtil.toPixelFromDIP(styles.getInt("paddingLeft"))));
        }
        WritableMap margin = Arguments.createMap();
        margin.putInt("top", 0);
        margin.putInt("right", 0);
        margin.putInt("bottom", 0);
        margin.putInt("left", 0);
        if (styles.hasKey("margin")) {
            int marginAll = Math.round(PixelUtil.toPixelFromDIP(styles.getInt("margin")));
            margin.putInt("top", marginAll);
            margin.putInt("right", marginAll);
            margin.putInt("bottom", marginAll);
            margin.putInt("left", marginAll);
        }
        if (styles.hasKey("marginTop")) {
            margin.putInt("top", Math.round(PixelUtil.toPixelFromDIP(styles.getInt("marginTop"))));
        }
        if (styles.hasKey("marginRight")) {
            margin.putInt("right", Math.round(PixelUtil.toPixelFromDIP(styles.getInt("marginRight"))));
        }
        if (styles.hasKey("marginBottom")) {
            margin.putInt("bottom", Math.round(PixelUtil.toPixelFromDIP(styles.getInt("marginBottom"))));
        }
        if (styles.hasKey("marginLeft")) {
            margin.putInt("left", Math.round(PixelUtil.toPixelFromDIP(styles.getInt("marginLeft"))));
        }

        padding.putInt("top", padding.getInt("top") + margin.getInt("top"));
        padding.putInt("right", padding.getInt("right") + margin.getInt("right"));
        padding.putInt("bottom", padding.getInt("bottom") + margin.getInt("bottom"));
        padding.putInt("left", padding.getInt("left") + margin.getInt("left"));

        view.setPadding(padding.getInt("left"), padding.getInt("top"), padding.getInt("right"), padding.getInt("bottom"));

        if (styles.hasKey("width")) {
            view.getLayoutParams().width = Math.round(PixelUtil.toPixelFromDIP(styles.getInt("width")));
        }
        if (styles.hasKey("height")) {
            view.getLayoutParams().height = Math.round(PixelUtil.toPixelFromDIP(styles.getInt("height")));
        }
        if (view instanceof TextView) {
            if (styles.hasKey("color") && styles.getString("color") != null) {
                int color = Color.parseColor(styles.getString("color"));
                ((TextView) view).setTextColor(color);
            }
            if (styles.hasKey("fontSize")) {
                int fontSize = styles.getInt("fontSize");
                ((TextView) view).setTextSize(fontSize);
            }
            if (styles.hasKey("lineHeight")) {
                int fontSize = styles.getInt("lineHeight");
                ((TextView) view).setTextSize(fontSize);
            }
            if (styles.hasKey("fontFamily")) {
                String fontFamily = styles.getString("fontFamily");
                try {
                    List<String> mapList = Arrays.asList(applicationContext.getAssets().list("fonts/"));
                    if (mapList.contains(fontFamily + ".ttf")) {
                        Typeface font = Typeface.createFromAsset(applicationContext.getAssets(), "fonts/" + fontFamily + ".ttf");
                        ((TextView) view).setTypeface(font);
                    } else if (mapList.contains(fontFamily + ".otf")) {
                        Typeface font = Typeface.createFromAsset(applicationContext.getAssets(), "fonts/" + fontFamily + ".otf");
                        ((TextView) view).setTypeface(font);
                    }
                } catch (IOException ex) {
                }
            }
            if (styles.hasKey("textTransform") && styles.getString("textTransform") != null) {
                String textTransform = styles.getString("textTransform");
                if (textTransform.equals("uppercase")) {
                    ((TextView) view).setText(((TextView) view).getText().toString().toUpperCase());
                } else if (textTransform.equals("lowercase")) {
                    ((TextView) view).setText(((TextView) view).getText().toString().toLowerCase());
                }
            }
        }
    }

    private void populateUnifiedNativeAdView(UnifiedNativeAd nativeAd, UnifiedNativeAdView nativeAdView) {
        MediaView adMediaView = (MediaView) nativeAdView.findViewById(R.id.ad_media);
        if (adMediaView != null && nativeAd.getMediaContent() != null) {
            // Set the media view.
            nativeAdView.setMediaView(adMediaView);
            nativeAdView.getMediaView().setMediaContent(nativeAd.getMediaContent());
        }

        // Set other ad assets.

        TextView adHeadlineView = (TextView) nativeAdView.findViewById(R.id.ad_headline);
        if (adHeadlineView != null) {
            if (this.adStyles.hasKey("ad_headline")) {
                applyStyle(adHeadlineView, this.adStyles.getMap("ad_headline"));
            }
            nativeAdView.setHeadlineView(adHeadlineView);
            if (nativeAd.getHeadline() != null) {
                // The headline and mediaContent are guaranteed to be in every UnifiedNativeAd.
                ((TextView) nativeAdView.getHeadlineView()).setText(nativeAd.getHeadline());
            } else {
                nativeAdView.getHeadlineView().setVisibility(View.INVISIBLE);
            }
        }

        TextView adSponsored = (TextView) nativeAdView.findViewById(R.id.ad_sponsored);
        if (adSponsored != null) {
            ((TextView) adSponsored).setText("Sponsored");
            if (this.adStyles.hasKey("ad_sponsored")) {
                applyStyle(adSponsored, this.adStyles.getMap("ad_sponsored"));
            }
        }

        // Set other ad assets.
        // These assets aren't guaranteed to be in every UnifiedNativeAd, so it's important to
        // check before trying to display them.
        TextView adBodyView = (TextView) nativeAdView.findViewById(R.id.ad_body);
        if (adBodyView != null) {
            if (this.adStyles.hasKey("ad_body")) {
                applyStyle(adBodyView, this.adStyles.getMap("ad_body"));
            }
            nativeAdView.setBodyView(adBodyView);
            if (nativeAd.getBody() == null) {
                nativeAdView.getBodyView().setVisibility(View.INVISIBLE);
            } else {
                nativeAdView.getBodyView().setVisibility(View.VISIBLE);
                ((TextView) nativeAdView.getBodyView()).setText(nativeAd.getBody());
            }
        }

        View adCallToActionView = (View) nativeAdView.findViewById(R.id.ad_call_to_action);
        if (adCallToActionView != null) {
            if (this.adStyles.hasKey("ad_call_to_action")) {
                applyStyle(adCallToActionView, this.adStyles.getMap("ad_call_to_action"));
            }
            nativeAdView.setCallToActionView(adCallToActionView);
            if (nativeAd.getCallToAction() == null) {
                nativeAdView.getCallToActionView().setVisibility(View.INVISIBLE);
            } else {
                nativeAdView.getCallToActionView().setVisibility(View.VISIBLE);

                TextView adCallToActionTextView = (TextView) nativeAdView.findViewById(R.id.ad_call_to_action_text);
                if (adCallToActionTextView != null) {
                    adCallToActionTextView.setText(nativeAd.getCallToAction());
                }
            }
        }

        ImageView adAppIconView = (ImageView) nativeAdView.findViewById(R.id.ad_app_icon);
        if (adAppIconView != null) {
            if (this.adStyles.hasKey("ad_app_icon")) {
                applyStyle(adAppIconView, this.adStyles.getMap("ad_app_icon"));
            }
            nativeAdView.setIconView(adAppIconView);
            if (nativeAd.getIcon() == null) {
                nativeAdView.getIconView().setVisibility(View.GONE);
            } else {
                ((ImageView) nativeAdView.getIconView()).setImageDrawable(
                        nativeAd.getIcon().getDrawable());
                nativeAdView.getIconView().setVisibility(View.VISIBLE);
            }
        }

        TextView adPriceView = (TextView) nativeAdView.findViewById(R.id.ad_price);
        if (adPriceView != null) {
            if (this.adStyles.hasKey("ad_price")) {
                applyStyle(adPriceView, this.adStyles.getMap("ad_price"));
            }
            nativeAdView.setPriceView(adPriceView);
            if (nativeAd.getPrice() == null) {
                nativeAdView.getPriceView().setVisibility(View.INVISIBLE);
            } else {
                nativeAdView.getPriceView().setVisibility(View.VISIBLE);
                ((TextView) nativeAdView.getPriceView()).setText(nativeAd.getPrice());
            }
        }

        RatingBar adStarsView = (RatingBar) nativeAdView.findViewById(R.id.ad_stars);
        if (adStarsView != null) {
            if (this.adStyles.hasKey("ad_stars")) {
                applyStyle(adStarsView, this.adStyles.getMap("ad_stars"));
            }
            nativeAdView.setStarRatingView(adStarsView);
            if (nativeAd.getStarRating() == null) {
                nativeAdView.getStarRatingView().setVisibility(View.INVISIBLE);
            } else {
                ((RatingBar) nativeAdView.getStarRatingView())
                        .setRating(nativeAd.getStarRating().floatValue());
                nativeAdView.getStarRatingView().setVisibility(View.VISIBLE);
            }
        }

        TextView adStoreView = (TextView) nativeAdView.findViewById(R.id.ad_store);
        if (adStoreView != null) {
            if (this.adStyles.hasKey("ad_store")) {
                applyStyle(adStoreView, this.adStyles.getMap("ad_store"));
            }
            nativeAdView.setStoreView(adStoreView);
            if (nativeAd.getStore() == null) {
                nativeAdView.getStoreView().setVisibility(View.INVISIBLE);
            } else {
                nativeAdView.getStoreView().setVisibility(View.VISIBLE);
                ((TextView) nativeAdView.getStoreView()).setText(nativeAd.getStore());
            }
        }

        TextView adAdvertiserView = (TextView) nativeAdView.findViewById(R.id.ad_advertiser);
        if (adAdvertiserView != null) {
            if (this.adStyles.hasKey("ad_advertiser")) {
                applyStyle(adAdvertiserView, this.adStyles.getMap("ad_advertiser"));
            }
            nativeAdView.setAdvertiserView(adAdvertiserView);
            if (nativeAd.getAdvertiser() == null) {
                nativeAdView.getAdvertiserView().setVisibility(View.INVISIBLE);
            } else {
                ((TextView) nativeAdView.getAdvertiserView()).setText(nativeAd.getAdvertiser());
                nativeAdView.getAdvertiserView().setVisibility(View.VISIBLE);
            }
        }


        // This method tells the Google Mobile Ads SDK that you have finished populating your
        // native ad view with this native ad.
        nativeAdView.setNativeAd(nativeAd);

        // Get the video controller for the ad. One will always be provided, even if the ad doesn't
        // have a video asset.
        VideoController vc = nativeAd.getVideoController();

        // Updates the UI to say whether or not this ad has a video asset.
        if (vc.hasVideoContent()) {
            // Create a new VideoLifecycleCallbacks object and pass it to the VideoController. The
            // VideoController will call methods on this object when events occur in the video
            // lifecycle.
            vc.setVideoLifecycleCallbacks(new VideoController.VideoLifecycleCallbacks() {
                @Override
                public void onVideoEnd() {
                    // Publishers should allow native ads to complete video playback before
                    // refreshing or replacing them with another ad in the same UI location.
                    super.onVideoEnd();
                }
            });
        }
    }

    private void fixLayout() {
        if (this.adView != null) {
            int viewWidth;
            int viewHeight;

            this.adView.measure(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);

            viewWidth = this.getMeasuredWidth();
            viewHeight = this.adView.getMeasuredHeight();

            int left = this.adView.getLeft();
            int top = this.adView.getTop();
            this.adView.measure(viewWidth, viewHeight);
            this.adView.layout(left, top, left + viewWidth, top + viewHeight);

            sendOnSizeChangeEvent();
        }
    }

    private void setupLayoutHack() {
        Choreographer.getInstance().postFrameCallback(new Choreographer.FrameCallback() {
            @Override
            public void doFrame(long frameTimeNanos) {
                manuallyLayoutChildren();
                getViewTreeObserver().dispatchOnGlobalLayout();
                Choreographer.getInstance().postFrameCallback(this);
            }
        });
    }

    private void manuallyLayoutChildren() {
        for (int i = 0; i < getChildCount(); i++) {
            View child = getChildAt(i);
            child.measure(MeasureSpec.makeMeasureSpec(getMeasuredWidth(), MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(getMeasuredHeight(), MeasureSpec.EXACTLY));
            child.layout(0, 0, child.getMeasuredWidth(), child.getMeasuredHeight());
        }
    }

    private void sendOnSizeChangeEvent() {
        WritableMap event = Arguments.createMap();
        int width = this.adView.getWidth();
        int height = this.adView.getHeight();

        event.putDouble("width", PixelUtil.toDIPFromPixel(width));
        event.putDouble("height", PixelUtil.toDIPFromPixel(height));
        sendEvent(RNPublisherNativeAdViewManager.EVENT_SIZE_CHANGE, event);
    }

    private void sendOnSizeChangeEvent(PublisherAdView adView) {
        int width;
        int height;
        ReactContext reactContext = (ReactContext) getContext();
        WritableMap event = Arguments.createMap();
        AdSize adSize = adView.getAdSize();
        if (adSize == AdSize.SMART_BANNER) {
            width = (int) PixelUtil.toDIPFromPixel(adSize.getWidthInPixels(reactContext));
            height = (int) PixelUtil.toDIPFromPixel(adSize.getHeightInPixels(reactContext));
        } else {
            width = adSize.getWidth();
            height = adSize.getHeight();
        }
        event.putDouble("width", width);
        event.putDouble("height", height);
        sendEvent(RNPublisherBannerViewManager.EVENT_SIZE_CHANGE, event);
    }

    private void createAdView() {
        final ReactContext reactContext = (ReactContext) getContext();
        final ReactPublisherNativeAdView parent = this;

        VideoOptions videoOptions = new VideoOptions.Builder()
                .setStartMuted(true)
                .build();

        NativeAdOptions adOptions = new NativeAdOptions.Builder()
                .setVideoOptions(videoOptions)
                .build();

        ArrayList<AdSize> adSizes = new ArrayList<AdSize>();
        if (this.adSize != null) {
            adSizes.add(this.adSize);
        }
        if (this.validAdSizes != null) {
            for (int i = 0; i < this.validAdSizes.length; i++) {
                adSizes.add(this.validAdSizes[i]);
            }
        }

        if (adSizes.size() == 0) {
            adSizes.add(AdSize.BANNER);
        }

        AdSize[] adSizesArray = adSizes.toArray(new AdSize[adSizes.size()]);

        /*
        AdSize.BANNER, AdSize.FULL_BANNER,
                        AdSize.LARGE_BANNER,
                        AdSize.LEADERBOARD,
                        AdSize.MEDIUM_RECTANGLE,
                        AdSize.WIDE_SKYSCRAPER,
                        AdSize.SMART_BANNER,
                        AdSize.FLUID
         */
        this.adLoader = new AdLoader.Builder(reactContext, this.adUnitID)
                .forUnifiedNativeAd(ReactPublisherNativeAdView.this)
                .forPublisherAdView(ReactPublisherNativeAdView.this, adSizesArray)
                .withAdListener(new AdListener() {
                    @Override
                    public void onAdFailedToLoad(int errorCode) {
                        String errorMessage = "Unknown error";
                        switch (errorCode) {
                            case PublisherAdRequest.ERROR_CODE_INTERNAL_ERROR:
                                errorMessage = "Internal error, an invalid response was received from the ad server.";
                                break;
                            case PublisherAdRequest.ERROR_CODE_INVALID_REQUEST:
                                errorMessage = "Invalid ad request, possibly an incorrect ad unit ID was given.";
                                break;
                            case PublisherAdRequest.ERROR_CODE_NETWORK_ERROR:
                                errorMessage = "The ad request was unsuccessful due to network connectivity.";
                                break;
                            case PublisherAdRequest.ERROR_CODE_NO_FILL:
                                errorMessage = "The ad request was successful, but no ad was returned due to lack of ad inventory.";
                                break;
                        }
                        WritableMap event = Arguments.createMap();
                        WritableMap error = Arguments.createMap();
                        error.putString("message", errorMessage);
                        event.putMap("error", error);
                        sendEvent(RNPublisherNativeAdViewManager.EVENT_AD_FAILED_TO_LOAD, event);
                    }

                    @Override
                    public void onAdLoaded() {
                        sendEvent(RNPublisherNativeAdViewManager.EVENT_AD_LOADED, null);
                    }

                    @Override
                    public void onAdClicked() {
                        // Log the click event or other custom behavior.
                    }

                    @Override
                    public void onAdOpened() {
                        sendEvent(RNPublisherNativeAdViewManager.EVENT_AD_OPENED, null);
                    }

                    @Override
                    public void onAdClosed() {
                        sendEvent(RNPublisherNativeAdViewManager.EVENT_AD_CLOSED, null);
                    }

                    @Override
                    public void onAdLeftApplication() {
                        sendEvent(RNPublisherNativeAdViewManager.EVENT_AD_LEFT_APPLICATION, null);
                    }
                })
                .withNativeAdOptions(adOptions)
                .build();
    }

    @Override
    public void onUnifiedNativeAdLoaded(UnifiedNativeAd unifiedNativeAd) {
        if (adView != null) adView.destroy();
        final ReactContext reactContext = (ReactContext) getContext();

        LayoutInflater inflater = LayoutInflater.from(reactContext);
        adView = (UnifiedNativeAdView) inflater.inflate(R.layout.ad_small, this, false);

        populateUnifiedNativeAdView(unifiedNativeAd, adView);

        removeAllViews();
        addView(adView);
        fixLayout();
    }

    @Override
    public void onPublisherAdViewLoaded(PublisherAdView adView) {
        if (publisherAdView != null) publisherAdView.destroy();

        final Context context = getContext();
        publisherAdView = adView;
        removeAllViews();
        this.addView(adView);
        int width = adView.getAdSize().getWidthInPixels(context);
        int height = adView.getAdSize().getHeightInPixels(context);
        int left = adView.getLeft();
        int top = adView.getTop();
        adView.measure(width, height);
        adView.layout(left, top, left + width, top + height);
        sendOnSizeChangeEvent(adView);
    }

    private void sendEvent(String name, @Nullable WritableMap event) {
        ReactContext reactContext = (ReactContext) getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                name,
                event);
    }

    public void loadBanner() {
        PublisherAdRequest.Builder adRequestBuilder = new PublisherAdRequest.Builder();
        if (testDevices != null) {
            for (int i = 0; i < testDevices.length; i++) {
                String testDevice = testDevices[i];
                if (testDevice == "SIMULATOR") {
                    testDevice = PublisherAdRequest.DEVICE_ID_EMULATOR;
                }
                adRequestBuilder.addTestDevice(testDevice);
            }
        }
        PublisherAdRequest adRequest = adRequestBuilder.build();
        this.adLoader.loadAd(adRequest);
    }

    public void setAdUnitID(String adUnitID) {
        if (this.adUnitID == null || !this.adUnitID.equals(adUnitID)) {
            // We can only set adUnitID once, so when it was previously set we have
            // to recreate the view
            this.adUnitID = adUnitID;
            this.createAdView();
        }
    }

    public void setAdStyles(ReadableMap adStyles) {
        this.adStyles = adStyles;
    }

    public void setTestDevices(String[] testDevices) {
        this.testDevices = testDevices;
    }

    public void setAdSize(AdSize adSize) {
        this.adSize = adSize;
    }

    public void setValidAdSizes(AdSize[] adSizes) {
        this.validAdSizes = adSizes;
    }

    @Override
    public void onAppEvent(String name, String info) {
        WritableMap event = Arguments.createMap();
        event.putString("name", name);
        event.putString("info", info);
        sendEvent(RNPublisherNativeAdViewManager.EVENT_APP_EVENT, event);
    }

    @Override
    public void onHostResume() {
    }

    @Override
    public void onHostPause() {
    }

    @Override
    public void onHostDestroy() {
        if (this.adView != null) {
            this.adView.destroy();
        }
        if (this.publisherAdView != null) {
            this.publisherAdView.destroy();
        }
    }
}