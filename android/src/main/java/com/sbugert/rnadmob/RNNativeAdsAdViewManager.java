package com.sbugert.rnadmob;

import androidx.annotation.Nullable;

import android.content.Context;
import android.util.Log;
import android.view.View;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableNativeArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.google.android.gms.ads.AdSize;

import java.util.ArrayList;
import java.util.Map;

public class RNNativeAdsAdViewManager extends ViewGroupManager<RNNativeAdsAdView> {
    public static final String PROP_AD_MANAGER = "adsManager";
    public static final String PROP_AD_SIZE = "adSize";
    public static final String PROP_VALID_AD_SIZES = "validAdSizes";
    public static final String EVENT_AD_LOADED = "onAdLoaded";
    public static final String EVENT_SIZE_CHANGE = "onSizeChange";
    public static final String EVENT_AD_FAILED_TO_LOAD = "onAdFailedToLoad";
    public static final String EVENT_AD_OPENED = "onAdOpened";
    public static final String EVENT_AD_CLOSED = "onAdClosed";
    public static final String EVENT_AD_CLICKED = "onAdClicked";
    public static final String EVENT_AD_LEFT_APPLICATION = "onAdLeftApplication";
    public static final String EVENT_APP_EVENT = "onAppEvent";
    public static final int COMMAND_RELOAD_AD = 1;
    private static String REACT_CLASS = "RNNativeAdsAdView";
    private ReactApplicationContext applicationContext;

    public RNNativeAdsAdViewManager(ReactApplicationContext context) {
        super();
        this.applicationContext = context;
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected RNNativeAdsAdView createViewInstance(ThemedReactContext reactContext) {
        return new RNNativeAdsAdView(reactContext, applicationContext);
    }

    @ReactProp(name = PROP_AD_MANAGER)
    public void setAdsManager(final RNNativeAdsAdView view, final String adUnitID) {
        Context viewContext = view.getContext();
        if (viewContext instanceof ReactContext) {
            ReactContext reactContext = (ReactContext) viewContext;
            RNNativeAdsManager adManager = reactContext.getNativeModule(RNNativeAdsManager.class);
            RNNativeAdsManager.AdsManagerProperties adsManagerProperties = adManager.getAdsManagerProperties(adUnitID);

            view.loadAd(adsManagerProperties);
        } else {
            Log.e("E_NOT_RCT_CONTEXT", "View's context is not a ReactContext, so it's not possible to get AdLoader.");
        }
    }

    @Override
    @Nullable
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        MapBuilder.Builder<String, Object> builder = MapBuilder.builder();
        String[] events = {
                EVENT_AD_LOADED,
                EVENT_SIZE_CHANGE,
                EVENT_AD_FAILED_TO_LOAD,
                EVENT_AD_OPENED,
                EVENT_AD_CLOSED,
                EVENT_AD_CLICKED,
                EVENT_AD_LEFT_APPLICATION,
                EVENT_APP_EVENT
        };
        for (int i = 0; i < events.length; i++) {
            builder.put(events[i], MapBuilder.of("registrationName", events[i]));
        }
        return builder.build();
    }

    @ReactProp(name = PROP_AD_SIZE)
    public void setPropAdSize(final RNNativeAdsAdView view, final String sizeString) {
        AdSize adSize = getAdSizeFromString(sizeString);
        view.setAdSize(adSize);
    }

    @ReactProp(name = PROP_VALID_AD_SIZES)
    public void setPropValidAdSizes(final RNNativeAdsAdView view, final ReadableArray adSizeStrings) {
        ReadableNativeArray nativeArray = (ReadableNativeArray)adSizeStrings;
        ArrayList<Object> list = nativeArray.toArrayList();
        String[] adSizeStringsArray = list.toArray(new String[list.size()]);
        AdSize[] adSizes = new AdSize[list.size()];

        for (int i = 0; i < adSizeStringsArray.length; i++) {
            String adSizeString = adSizeStringsArray[i];
            adSizes[i] = getAdSizeFromString(adSizeString);
        }
        view.setValidAdSizes(adSizes);
    }

    @Override
    public void addView(RNNativeAdsAdView parent, View child, int index) {
        parent.addView(child, index);
    }

    @Override
    public int getChildCount(RNNativeAdsAdView parent) {
        return parent.getChildCount();
    }

    @Override
    public View getChildAt(RNNativeAdsAdView parent, int index) {
        return parent.getChildAt(index);
    }

    @Override
    public void removeViewAt(RNNativeAdsAdView parent, int index) {
        parent.removeViewAt(index);
    }

    @Nullable
    @Override
    public Map<String, Integer> getCommandsMap() {
        return MapBuilder.of(
                "reloadAd", COMMAND_RELOAD_AD
        );
    }

    @Override
    public void receiveCommand(RNNativeAdsAdView root, int commandId, @javax.annotation.Nullable ReadableArray args) {
        switch (commandId) {
            case COMMAND_RELOAD_AD:
                root.reloadAd();
                break;
        }
    }

    private AdSize getAdSizeFromString(String adSize) {
        switch (adSize) {
            case "banner":
                return AdSize.BANNER;
            case "largeBanner":
                return AdSize.LARGE_BANNER;
            case "mediumRectangle":
                return AdSize.MEDIUM_RECTANGLE;
            case "fullBanner":
                return AdSize.FULL_BANNER;
            case "leaderBoard":
                return AdSize.LEADERBOARD;
            case "smartBannerPortrait":
                return AdSize.SMART_BANNER;
            case "smartBannerLandscape":
                return AdSize.SMART_BANNER;
            case "smartBanner":
                return AdSize.SMART_BANNER;
            case "300x600":
                return new AdSize(300, 600);
            default:
                return AdSize.BANNER;
        }
    }
}
