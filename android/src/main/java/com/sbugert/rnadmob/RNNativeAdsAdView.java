package com.sbugert.rnadmob;

import android.util.Log;
import android.view.View;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.facebook.react.views.view.ReactViewGroup;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdLoader;
import com.google.android.gms.ads.VideoOptions;
import com.google.android.gms.ads.doubleclick.AppEventListener;
import com.google.android.gms.ads.doubleclick.PublisherAdRequest;
import com.google.android.gms.ads.formats.NativeAd;
import com.google.android.gms.ads.formats.NativeAdOptions;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;

import java.util.List;

public class RNNativeAdsAdView extends ReactViewGroup implements AppEventListener, LifecycleEventListener, UnifiedNativeAd.OnUnifiedNativeAdLoadedListener {
  protected AdLoader adLoader;
  protected ReactApplicationContext applicationContext;
  protected UnifiedNativeAdView adView;

  String[] testDevices;
  String adUnitID;

  /**
   * @{RCTEventEmitter} instance used for sending events back to JS
   **/
  private RCTEventEmitter mEventEmitter;

  /**
   * Creates new RNNativeAdsAdView instance and retrieves event emitter
   *
   * @param context
   */
  public RNNativeAdsAdView(ThemedReactContext context, ReactApplicationContext applicationContext) {
    super(context);
    this.applicationContext = applicationContext;
    this.applicationContext.addLifecycleEventListener(this);

    this.adView =  new UnifiedNativeAdView(context);

    mEventEmitter = context.getJSModule(RCTEventEmitter.class);
  }

  public void loadAd(RNNativeAdsManager.AdsManagerProperties adsManagerProperties) {
    Log.w("adsManagerProperties", adsManagerProperties.toString());

    final ReactApplicationContext reactContext = this.applicationContext;

    this.testDevices = adsManagerProperties.getTestDevices();
    this.adUnitID = adsManagerProperties.getAdUnitID();

    UiThreadUtil.runOnUiThread(new Runnable() {
      @Override
      public void run() {
        VideoOptions videoOptions = new VideoOptions.Builder()
          .setStartMuted(true)
          .build();

        NativeAdOptions adOptions = new NativeAdOptions.Builder()
          .setVideoOptions(videoOptions)
          .build();

        adLoader = new AdLoader.Builder(reactContext, adUnitID)
          .forUnifiedNativeAd(RNNativeAdsAdView.this)
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
              sendEvent(RNNativeAdsAdViewManager.EVENT_AD_FAILED_TO_LOAD, event);
            }

            @Override
            public void onAdLoaded() {
//              sendEvent(RNNativeAdsAdViewManager.EVENT_AD_LOADED, null);
            }

            @Override
            public void onAdClicked() {
              // Log the click event or other custom behavior.
            }

            @Override
            public void onAdOpened() {
              sendEvent(RNNativeAdsAdViewManager.EVENT_AD_OPENED, null);
            }

            @Override
            public void onAdClosed() {
              sendEvent(RNNativeAdsAdViewManager.EVENT_AD_CLOSED, null);
            }

            @Override
            public void onAdLeftApplication() {
              sendEvent(RNNativeAdsAdViewManager.EVENT_AD_LEFT_APPLICATION, null);
            }
          })
          .withNativeAdOptions(adOptions)
          .build();

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
        adLoader.loadAd(adRequest);
      }
    });
  }

  @Override
  public void onUnifiedNativeAdLoaded(UnifiedNativeAd unifiedNativeAd) {
    adView.setNativeAd(unifiedNativeAd);
    removeAllViews();
    addView(adView);

    setNativeAd(unifiedNativeAd);
  }

  /**
   * Called by the view manager when ad is loaded. Sends serialised
   * version of a native ad back to Javascript.
   *
   * @param unifiedNativeAd
   */
  private void setNativeAd(UnifiedNativeAd unifiedNativeAd) {
    if (unifiedNativeAd == null) {
      sendEvent(RNNativeAdsAdViewManager.EVENT_AD_LOADED, null);
      return;
    }

    WritableMap ad = Arguments.createMap();

    if (unifiedNativeAd.getHeadline() == null) {
      ad.putString("headline", null);
    } else {
      ad.putString("headline", unifiedNativeAd.getHeadline());
    }

    if (unifiedNativeAd.getBody() == null) {
      ad.putString("bodyText", null);
    } else {
      ad.putString("bodyText", unifiedNativeAd.getBody());
    }

    if (unifiedNativeAd.getCallToAction() == null) {
      ad.putString("callToActionText", null);
    } else {
      ad.putString("callToActionText", unifiedNativeAd.getCallToAction());
    }

    if (unifiedNativeAd.getAdvertiser() == null) {
      ad.putString("advertiserName", null);
    } else {
      ad.putString("advertiserName", unifiedNativeAd.getAdvertiser());
    }

    if (unifiedNativeAd.getStarRating() == null) {
      ad.putString("starRating", null);
    } else {
      ad.putDouble("starRating", unifiedNativeAd.getStarRating());
    }

    if (unifiedNativeAd.getStore() == null) {
      ad.putString("storeName", null);
    } else {
      ad.putString("storeName", unifiedNativeAd.getStore());
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
      for (NativeAd.Image image: unifiedNativeAd.getImages()) {
        WritableMap imageMap = Arguments.createMap();
        imageMap.putString("uri", image.getUri().toString());
        imageMap.putInt("width", image.getWidth());
        imageMap.putInt("height", image.getHeight());
        imageMap.putDouble("scale", image.getScale());
        images.pushMap(imageMap);
      }
      ad.putArray("images", images);
    }

    sendEvent(RNNativeAdsAdViewManager.EVENT_AD_LOADED, ad);
  }

  private void sendEvent(String name, @Nullable WritableMap event) {
    mEventEmitter.receiveEvent(getId(), name, event);
  }

  public void registerViewsForInteraction(List<View> clickableViews) {
    Log.w("ViewsForInteraction", Integer.toString(clickableViews.size()));
    if (adView != null) {
      for (View view: clickableViews)
      adView.setCallToActionView(view);
    }
//    mNativeAd.registerViewForInteraction(this, mediaView, adIconView, clickableViews);
  }

  @Override
  public void onAppEvent(String name, String info) {
    WritableMap event = Arguments.createMap();
    event.putString("name", name);
    event.putString("info", info);
    sendEvent(RNNativeAdsAdViewManager.EVENT_APP_EVENT, event);
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
  }

//  @Override
//  public void addView(View child, int index) {
//    super.addView(child, index);
//  }
//
//  @Override
//  public int getChildCount() {
//    return this.adView.getChildCount();
//  }
//
//  @Override
//  public View getChildAt(int index) {
//    return this.adView.getChildAt(index);
//  }
//
//  @Override
//  public void removeViewAt(int index) {
//    this.adView.removeViewAt(index);
//  }
}
