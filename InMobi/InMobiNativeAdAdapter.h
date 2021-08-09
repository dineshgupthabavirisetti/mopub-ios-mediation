//
//  InMobiNativeAdAdapter.h
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//
#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPNativeAdAdapter.h"
#endif

#import <InMobiSDK/IMNative.h>

@interface InMobiNativeAdAdapter : NSObject <MPNativeAdAdapter,IMNativeDelegate>
- (instancetype)initWithInMobiNativeAd:(IMNative *)nativeAd;
@property (nonatomic, strong) IMNative* nativeAd;
/// MoPub native ad adapter delegate instance.
@property(nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;
@end
