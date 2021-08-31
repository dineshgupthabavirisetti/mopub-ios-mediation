//
//  InMobiNativeCustomEvent.m
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InMobiNativeCustomEvent.h"
#import "InMobiNativeAdAdapter.h"
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPNativeAd.h"
    #import "MPNativeAdError.h"
    #import "MPNativeAdConstants.h"
    #import "MPNativeAdUtils.h"
    #import "MPConstants.h"
#endif

#import <InMobiSDK/IMSdk.h>
#import "InMobiAdapterConfiguration.h"
#import "InMobiNativeAdAdapter.h"

@interface InMobiNativeCustomEvent ()

@property (nonatomic, strong) IMNative *nativeAd;
@property (nonatomic, strong) InMobiNativeAdAdapter *adAdapter;
@property (nonatomic, copy) NSString *placementId;

@end

@implementation InMobiNativeCustomEvent

- (NSString *) getAdNetworkId {
    return _placementId;
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString * const placementId = info[kIMPlacementIdKey];
    
    if (![InMobiAdapterConfiguration isInMobiSDKInitialized]) {
        NSString *message = @"Native ad request";
        [self failLoadWithError: [InMobiAdapterConfiguration createInitializationError: message]];
        [InMobiAdapterConfiguration initializeInMobiSDK:[info valueForKey:kIMAccountIdKey]];
        return;
    }
    
    self.placementId = placementId;
    long long placementIdLong = [placementId longLongValue];
    [InMobiAdapterConfiguration setCachedInitializationParameters: info];

    NSError * placementIdError = [InMobiAdapterConfiguration validatePlacementId:placementId forOperation:@"native ad request"];
    if (placementIdError) {
        [self failLoadWithError:placementIdError];
        return;
    }
    
    self.nativeAd = [[IMNative alloc] initWithPlacementId:placementIdLong delegate:self];
    
    // Mandatory params to be set by the publisher to identify the supply source type
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:@"c_mopub" forKey:@"tp"];
    [paramsDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];
    self.nativeAd.extras = paramsDict; // For supply source identification
    
    IMCompletionBlock completionBlock = ^{
        if ([adMarkup isKindOfClass:[NSString class]] && adMarkup.length > 0 && [self.nativeAd respondsToSelector:@selector(load:)]) {
            [self.nativeAd load:[adMarkup dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [self.nativeAd load];
        }
    };
    
    [InMobiAdapterConfiguration invokeOnMainThreadAsSynced:YES withCompletionBlock:completionBlock];
}

- (void)failLoadWithError:(NSError *)error {
    IMCompletionBlock completionBlock = ^{
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
    };
    [InMobiAdapterConfiguration invokeOnMainThreadAsSynced:NO withCompletionBlock:completionBlock];
}

- (NSString *) adapterName {
    return NSStringFromClass(self.adAdapter.class);
}

#pragma mark - IMNativeDelegate

- (void)nativeDidFinishLoading:(IMNative *)imnative {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogInfo(@"[InMobi] custom ad content:%@",[imnative customAdContent]);
    
    self.adAdapter = [[InMobiNativeAdAdapter alloc] initWithInMobiNativeAd:self.nativeAd];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:self.adAdapter];
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

- (void)native:(IMNative*)native didFailToLoadWithError:(IMRequestStatus*)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(error.description)];
}

- (void)nativeWillPresentScreen:(IMNative*)native{
    MPLogAdEvent([MPLogEvent adWillPresentModalForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.adAdapter.delegate nativeAdWillPresentModalForAdapter:self.adAdapter];
}

- (void)nativeDidPresentScreen:(IMNative*)native{
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)nativeWillDismissScreen:(IMNative*)native{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)nativeDidDismissScreen:(IMNative*)native{
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.adAdapter.delegate nativeAdDidDismissModalForAdapter:self.adAdapter];
}

- (void)userWillLeaveApplicationFromNative:(IMNative*)native{
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.adAdapter.delegate nativeAdWillLeaveApplicationFromAdapter:self.adAdapter];
}

- (void)native:(IMNative *)native didInteractWithParams:(NSDictionary *)params{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)nativeAdImpressed:(IMNative *)native{
    MPLogInfo(@"InMobi impression tracked successfully");
}

- (void)nativeDidFinishPlayingMedia:(IMNative*)native{
    MPLogInfo(@"[InMobi] Native video did finish playing media");
}

- (void)userDidSkipPlayingMediaFromNative:(IMNative *)native {
    MPLogInfo(@"[InMobi] User did skip the media from Native AD");
}

@end
