//
//  InMobiNativeAdRenderer.m
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//

#import "InMobiNativeAdRenderer.h"
#import "InMobiNativeAdAdapter.h"

@interface InMobiNativeAdRenderer ()

@property (nonatomic, strong) UIView<MPNativeAdRendering> *adView;
@property (nonatomic) BOOL adViewInViewHierarchy;
@property (nonatomic, strong) InMobiNativeAdAdapter *adapter;
@property (nonatomic, strong) Class renderingViewClass;
@property (nonatomic, strong) IMNative* nativeAdView;
@end

@implementation InMobiNativeAdRenderer
@synthesize viewSizeHandler = _viewSizeHandler;

- (instancetype)initWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    if(self = [super init]) {
        MPStaticNativeAdRendererSettings *settings = (MPStaticNativeAdRendererSettings *)rendererSettings;
        _renderingViewClass = settings.renderingViewClass;
        _viewSizeHandler = [settings.viewSizeHandler copy];
    }
    return self;
}

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    MPNativeAdRendererConfiguration* config = [[MPNativeAdRendererConfiguration alloc] init];
    config.rendererClass = [self class];
    config.rendererSettings = rendererSettings;
    config.supportedCustomEvents = @[@"InMobiNativeCustomEvent"];
    return config;
}

- (UIView *)retrieveViewWithAdapter:(id<MPNativeAdAdapter>)adapter error:(NSError *__autoreleasing *)error {
    if (![adapter isKindOfClass:[InMobiNativeAdAdapter class]]) {
        if (error) {
            *error = MPNativeAdNSErrorForRenderValueTypeError();
        }
        return nil;
    }
    
    self.adapter = (InMobiNativeAdAdapter *)adapter;
    self.nativeAdView = self.adapter.nativeAd;
    
    
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
       self.adView = (UIView<MPNativeAdRendering> *)[[[self.renderingViewClass nibForAd]
           instantiateWithOwner:nil
                        options:nil] firstObject];
     } else {
         self.adView = [[self.renderingViewClass alloc] init];
     }

     self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
     MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], nil);
     MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], nil);
     [self renderUnifiedAdViewWithAdapter:self.adapter];
    return self.adView;
}

// Creates Unified Native AdView with adapter.
- (void)renderUnifiedAdViewWithAdapter:(id<MPNativeAdAdapter>)adapter {
    UIView *mainView = adapter.mainMediaView;
    [self.adView addSubview:mainView];
    
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)]) {
        self.adView.nativeTitleTextLabel.text = [adapter.properties objectForKey:kAdTitleKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)]) {
        self.adView.nativeMainTextLabel.text = [adapter.properties objectForKey:kAdTextKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeCallToActionTextLabel)]) {
        self.adView.nativeCallToActionTextLabel.text = [adapter.properties objectForKey:kAdCTATextKey];
    }
    
    if ([self.adView respondsToSelector:@selector(layoutStarRating:)]) {
        if([[adapter.properties objectForKey:kAdStarRatingKey] isKindOfClass:[NSNumber class]]) {
            NSNumber *starRatingNum = [adapter.properties objectForKey:kAdStarRatingKey];
            
            if (starRatingNum.floatValue >= kStarRatingMinValue && starRatingNum.floatValue <= kStarRatingMaxValue) {
                [self.adView layoutStarRating:starRatingNum];
            }
        } else if([[adapter.properties objectForKey:kAdStarRatingKey] isKindOfClass:[NSString class]]) {
            NSString *starRating = [adapter.properties objectForKey:kAdStarRatingKey];
            if (starRating.floatValue >= kStarRatingMinValue && starRating.floatValue <= kStarRatingMaxValue) {
                NSNumber *number = @([starRating floatValue]);
                [self.adView layoutStarRating:number];
            }
        }
    }
    
    if ([self.adView respondsToSelector:@selector(nativeMainImageView)]) {
        UIView *mediaView = mainView;
        UIView *mainImageView = [self.adView nativeMainImageView];
        
        mediaView.frame = mainImageView.bounds;
        mediaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        mediaView.userInteractionEnabled = YES;
        mainImageView.userInteractionEnabled = YES;
        
        [mainImageView addSubview:mediaView];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeIconImageView)]) {
        UIImageView *iconImageView = [self.adView nativeIconImageView];
        iconImageView.userInteractionEnabled = YES;
        InMobiNativeAdAdapter *imadapter = (InMobiNativeAdAdapter*)adapter;
        iconImageView.image = imadapter.nativeAd.adIcon;
    }
}

- (void)adViewWillMoveToSuperview:(UIView *)superview
{
    self.adViewInViewHierarchy = (superview != nil);
    
    if (superview) {
        if ([self.adView respondsToSelector:@selector(layoutCustomAssetsWithProperties:imageLoader:)]) {
            [self.adView layoutCustomAssetsWithProperties:self.adapter.properties imageLoader:nil];
        }
    }
}


@end
