#import <UnityAds/UnityAds.h>
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPFullscreenAdAdapter.h"
#endif

@interface UnityFullscreenAdAdapter : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter, UnityAdsLoadDelegate, UnityAdsShowDelegate>

@end
