#import "UnityAdsRewardedVideoCustomEvent.h"

@implementation UnityAdsRewardedVideoCustomEvent

#pragma mark - UnityFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return YES;
}

- (void)unityAdsShowComplete:(NSString *)placementId withFinishState:(UnityAdsShowCompletionState)state {
    if (state == kUnityShowCompletionStateCompleted) {
        MPReward *reward = [[MPReward alloc] initWithCurrencyType:kMPRewardCurrencyTypeUnspecified
                                                           amount:@(kMPRewardCurrencyAmountUnspecified)];
        [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
    }
    
    [super unityAdsShowComplete: placementId withFinishState: state];
}

- (NSString *)adType {
    return @"Rewarded";
}

@end
