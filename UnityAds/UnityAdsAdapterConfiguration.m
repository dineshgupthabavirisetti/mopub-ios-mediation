#import <UnityAds/UnityAds.h>
#import "UnityAdsAdapterConfiguration.h"
#import "UnityRouter.h"
#import "NSError+UnityAdAdapter.h"
#if __has_include("MoPub.h")
#import "MoPub.h"
#import "MPLogging.h"
#endif

//Adapter version
NSString *const ADAPTER_VERSION = @"3.7.5.2";

// Initialization configuration keys
static NSString * const kUnityAdsGameId = @"gameId";

typedef NS_ENUM(NSInteger, UnityAdsAdapterErrorCode) {
    UnityAdsAdapterErrorCodeMissingGameId,
};

@implementation UnityAdsAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * gameId = parameters[kUnityAdsGameId];
    
    if (gameId != nil) {
        NSDictionary * configuration = @{ kUnityAdsGameId: gameId };
        [UnityAdsAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

+ (void)initializeIfNeeded:(NSString *)gameId complete:(void(^ _Nullable)(NSError * _Nullable))complete; {
    if (![UnityAds isInitialized]) {
        [[UnityRouter sharedRouter] initializeWithGameId:gameId withCompletionHandler:^(NSError * _Nullable error) {
            complete(error);
        }];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return ADAPTER_VERSION;
}

- (NSString *)biddingToken {
    return [UnityAds getToken];
}

- (NSString *)moPubNetworkName {
    return @"unity";
}

- (NSString *)networkSdkVersion {
    return [UnityAds getVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    NSString * gameId = configuration[kUnityAdsGameId];
    if (gameId == nil) {
        NSError * error = [NSError errorWithAdAdapterErrorCode: UnityAdsAdapterErrorCodeMissingGameId
                                                   description: @"Initialization skipped. The gameId is empty."
                                                    suggestion: @"Ensure it is properly configured on the MoPub dashboard."];
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        return;
    }
    
    [[UnityRouter sharedRouter] initializeWithGameId:gameId withCompletionHandler:^(NSError * _Nullable error) {
        complete(error);
    }];
}

@end
