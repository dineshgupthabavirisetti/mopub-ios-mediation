#import "UnityAdsInterstitialCustomEvent.h"

@implementation UnityAdsInterstitialCustomEvent

#pragma mark - UnityFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return NO;
}

- (NSString *)adType {
    return @"Interstitial";
}

@end
