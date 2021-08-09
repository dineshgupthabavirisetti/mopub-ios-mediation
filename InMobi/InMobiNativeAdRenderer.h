//
//  InMobiNativeAdRenderer.h
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPNativeAdRenderer.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class MPNativeAdRendererConfiguration;
@class MPStaticNativeAdRendererSettings;

@interface InMobiNativeAdRenderer : NSObject <MPNativeAdRendererSettings>

/// The viewSizeHandler is used to allow the app to configure its native ad view size.
@property(nonatomic, readwrite, copy) MPNativeViewSizeHandler viewSizeHandler;

/// Constructs and returns an MPNativeAdRendererConfiguration object specific for the
/// MPGoogleAdMobNativeRenderer. You must set all the properties on the configuration object.
/// @param rendererSettings Application defined settings.
/// @return A configuration object for MPGoogleAdMobNativeRenderer.
+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:
    (id<MPNativeAdRendererSettings>)rendererSettings;

@end

NS_ASSUME_NONNULL_END
