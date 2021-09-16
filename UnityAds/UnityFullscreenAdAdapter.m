#import "UnityFullscreenAdAdapter.h"
#import "UnityAdsInstanceMediationSettings.h"
#import "UnityAdsAdapterConfiguration.h"
#import "UnityRouter.h"
#import "NSError+UnityAdAdapter.h"
#if __has_include("MoPub.h")
#import "MPAdAdapterError.h"
#import "MPReward.h"
#import "MPLogging.h"
#endif

static NSString *const kMPUnityRewardedVideoGameId = @"gameId";
static NSString *const kUnityAdsOptionPlacementIdKey = @"placementId";
static NSString *const kUnityAdsOptionZoneIdKey = @"zoneId";

@interface UnityFullscreenAdAdapter ()

@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, assign) int impressionOrdinal;
@property (nonatomic, assign) int missedImpressionOrdinal;

@end

@implementation UnityFullscreenAdAdapter
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

- (NSString *)getAdNetworkId {
    return (self.placementId != nil) ? self.placementId : @"";
}

- (NSString *)adType {
    return nil;
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return _placementId != nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    NSString *gameId = [info objectForKey:kMPUnityRewardedVideoGameId];
    
    if (!(gameId.length > 0)) {
        NSError *error = [NSError errorWithAdAdapterErrorCode: MPAdAdapterErrorCodeInvalidAdapter
                                                  description: @"Custom event class data did not contain gameId."
                                                   suggestion: @"Update your MoPub custom event class data to contain a valid Unity Ads gameId."];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    // Only need to cache game ID for SDK initialization
    [UnityAdsAdapterConfiguration updateInitializationParameters:info];
    
    [UnityAdsAdapterConfiguration initializeIfNeeded:gameId complete:^(NSError * _Nullable error) {
        if (error != nil) {
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
            [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        }
    }];
    
    NSString *placementId = [info objectForKey:kUnityAdsOptionPlacementIdKey] ?:  [info objectForKey:kUnityAdsOptionZoneIdKey];
    
    if (!(placementId.length > 0)) {
        NSError *error = [NSError errorWithAdAdapterErrorCode: MPAdAdapterErrorCodeInvalidAdapter
                                                  description: @"no placementId found."
                                                   suggestion: @"Update your MoPub dashboard to contain a valid Unity Ads placementId."];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], placementId);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    UADSLoadOptions *options = [UADSLoadOptions new];
    if (adMarkup.length > 0) {
        _objectId = [[NSUUID UUID] UUIDString];
        [options setObjectId:_objectId];
        [options setAdMarkup:adMarkup];
    }
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], placementId);
    [UnityAds load:placementId options:options loadDelegate:self];
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
    if (![self hasAdAvailable]) {
        NSError *showError = [NSError errorWithAdAdapterErrorCode:MPAdAdapterErrorCodeUnknown
                                                      description:[NSString stringWithFormat:@"Unity Ads received call to show before successfully loading an ad"]];
        
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:showError], _placementId);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:showError];
        return;
    }
    
    UADSShowOptions *options = [UADSShowOptions new];
    if (_objectId != nil) {
        [options setObjectId:_objectId];
    }
    
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [UnityAds show:viewController placementId:_placementId options:options showDelegate:self];
}

- (void)handleDidInvalidateAd
{
    // Nothing to clean up.
}

- (void)sendMetadataAdShownCorrect: (BOOL)isAdShown {
    UADSMediationMetaData *headerBiddingMeta = [[UADSMediationMetaData alloc] init];
    
    if (isAdShown) {
        [headerBiddingMeta setOrdinal: ++_impressionOrdinal];
    } else {
        [headerBiddingMeta setMissedImpressionOrdinal: ++_missedImpressionOrdinal];
    }
    
    [headerBiddingMeta commit];
}

#pragma mark - UnityAdsLoadDelegate Methods

- (void)unityAdsAdLoaded:(nonnull NSString *)placementId {
    self.placementId = placementId;
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], placementId);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
    
    [self sendMetadataAdShownCorrect:YES];
}

- (void)unityAdsAdFailedToLoad:(nonnull NSString *)placementId withError:(UnityAdsLoadError)error withMessage:(NSString *)message {
    self.placementId = placementId;
    
    NSError *loadError = [NSError errorWithAdAdapterErrorCode:MPAdAdapterErrorCodeUnknown
                                                  description:[NSString stringWithFormat:@"Failed to load a %@ video ad for placement %@, with error message: %@", self.adType, placementId, message]];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:loadError], placementId);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:loadError];
    
    [self sendMetadataAdShownCorrect:NO];
}

#pragma mark - UnityAdsShowDelegate Methods

- (void)unityAdsShowStart:(nonnull NSString *)placementId {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], placementId);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], placementId);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], placementId);
    
    [self.delegate fullscreenAdAdapterAdWillPresent:self];
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
    
}

- (void)unityAdsShowClick:(NSString *)placementId {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], placementId);
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], placementId);
    
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)unityAdsShowComplete:(NSString *)placementId withFinishState:(UnityAdsShowCompletionState)state {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], placementId);
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], placementId);
    
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (void)unityAdsShowFailed:(NSString *)placementId withError:(UnityAdsShowError)error withMessage:(NSString *)message {
    if (error == kUnityShowErrorNotReady) {
        // If we no longer have an ad available, report back up to the application that this ad expired.
        // We receive this message only when this ad has reported an ad has loaded and another ad unit
        // has played a video for the same ad network.
        NSError *showError =[NSError errorWithAdAdapterErrorCode:MPAdAdapterErrorCodeUnknown
                                                     description:[NSString stringWithFormat:@"%@ ad has expired with error message: %@", self.adType, message]];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:showError], placementId);
        [self.delegate fullscreenAdAdapterDidExpire:self];
        return;
    }
    
    NSError *showError = [NSError errorWithAdAdapterErrorCode:MPAdAdapterErrorCodeUnknown
                                                  description:[NSString stringWithFormat:@"Failed to show a %@ ad for %@, with error message: %@", self.adType, placementId, message]];
    
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:showError], placementId);
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:showError];
}

@end

