//
//  InMobiNativeCustomEvent.h
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MPNativeCustomEvent.h"
#endif

#import <InMobiSDK/IMNative.h>
#import "MPMoPubNativeCustomEvent.h"


@interface InMobiNativeCustomEvent : MPMoPubNativeCustomEvent<IMNativeDelegate>

@end
