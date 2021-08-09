//
//  InMobiNativeAdAdapter.m
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//

#import "InMobiNativeAdAdapter.h"

#import <InMobiSDK/IMSdk.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPNativeAdError.h"
    #import "MPNativeAdConstants.h"
#endif

#import "InMobiAdapterConfiguration.h"

static NSString *gInMobiIconKey = @"icon";
static NSString *gInMobiLandingURLKey = @"landingURL";

//InMobi Key - Do Not Change.
static NSString *const kInMobiIconImageURL = @"url";

@interface InMobiNativeAdAdapter ()
@property (nonatomic, copy)   NSString       * placementId;
@property (nonatomic, copy)   NSString       * accountId;
@property (nonatomic, strong) UIView* adView;

+ (void)setCustomKeyForIcon:(NSString *)key;
+ (void)setCustomKeyForLandingURL:(NSString *)key;
@end

@implementation InMobiNativeAdAdapter

@synthesize  adView = _adView;
@synthesize properties = _properties;
@synthesize defaultActionURL = _defaultActionURL;

+ (void)setCustomKeyForIcon:(NSString *)key {
    gInMobiIconKey = [key copy];
}

+ (void)setCustomKeyForLandingURL:(NSString *)key {
    gInMobiLandingURLKey = [key copy];
}

- (instancetype)initWithInMobiNativeAd:(IMNative *)nativeAd {
    self = [super init];
    if (self) {
        self.nativeAd = nativeAd;
        
        NSDictionary *inMobiProperties = [self inMobiProperties];
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        
        if ([self.nativeAd adRating]) {
            [properties setObject:[self.nativeAd adRating] forKey:kAdStarRatingKey];
        }
        
        if ([[self.nativeAd adTitle] length]) {
            [properties setObject:[self.nativeAd adTitle] forKey:kAdTitleKey];
        }
        
        if ([[self.nativeAd adDescription] length]) {
            [properties setObject:[self.nativeAd adDescription] forKey:kAdTextKey];
        }

        if ([[self.nativeAd adCtaText] length]) {
            [properties setObject:[self.nativeAd adCtaText] forKey:kAdCTATextKey];
        }

        NSDictionary *iconDictionary = [inMobiProperties objectForKey:gInMobiIconKey];

        if ([[iconDictionary objectForKey:kInMobiIconImageURL] length]) {
            [properties setObject:[iconDictionary objectForKey:kInMobiIconImageURL] forKey:kAdIconImageKey];
        }

       _properties = properties;

        if ([self.nativeAd adLandingPageUrl]) {
            _defaultActionURL = [self.nativeAd adLandingPageUrl];
        } else {
            // Log a warning if we can't find the landing URL since the key can either be "landing_url", "landingURL", or a custom key depending on the date the property was created.
            MPLogWarn(@"WARNING: Couldn't find landing url with key: %@ for InMobi network.  Double check your ad property and call setCustomKeyForLandingURL: with the correct key if necessary.", gInMobiLandingURLKey);
        }
    }
    return self;
}

- (NSDictionary *)inMobiProperties {
    NSData *data = [self.nativeAd.customAdContent dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSDictionary *propertyDictionary = nil;
    if (data) {
        propertyDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    if (propertyDictionary && !error) {
        return propertyDictionary;
    }
    else {
        return nil;
    }
}

- (NSString *) adapterName {
    return NSStringFromClass(self.class);
}

#pragma mark - <MPNativeAdAdapter>

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller {
    if (!controller) {
        return;
    }
    
    if (![URL isKindOfClass:[NSURL class]] || ![URL.absoluteString length]) {
        return;
    }
    __weak __typeof__(self) weakSelf = self;
    IMCompletionBlock completionBlock = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
            // Sending click to MoPub SDK.
            MPLogEvent([MPLogEvent adTappedForAdapter:[self adapterName]]);
            [weakSelf.delegate nativeAdDidClick:weakSelf];
        }
        [weakSelf.delegate nativeAdWillPresentModalForAdapter:self];
    };
    [InMobiAdapterConfiguration invokeOnMainThreadAsSynced:NO withCompletionBlock:completionBlock];
}

- (void)willAttachToView:(UIView *)view {
    NSString *name = [self adapterName];
    MPLogEvent([MPLogEvent adWillAppearForAdapter:name]);
    MPLogEvent([MPLogEvent adShowAttemptForAdapter:name]);
    MPLogEvent([MPLogEvent adShowSuccessForAdapter:name]);
    MPLogEvent([MPLogEvent adDidAppearForAdapter:name]);
    // Sending impression to MoPub SDK.
    [self.delegate nativeAdWillLogImpression:self];
    self.adView = view;
}

- (void)trackClick {
    [self.nativeAd reportAdClickAndOpenLandingPage];
}

- (void)trackImpression {
    [self.delegate nativeAdWillLogImpression:self];
}

- (UIView *)mainMediaView {
    UIView *view = [self.delegate viewControllerForPresentingModalView].view;
    CGFloat width = view.frame.size.width;
    return [self.nativeAd primaryViewOfWidth:width];
}

@end
