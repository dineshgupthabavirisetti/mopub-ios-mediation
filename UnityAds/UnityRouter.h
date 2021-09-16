#import <Foundation/Foundation.h>
#import <UnityAds/UnityAds.h>

@class UnityAdsInstanceMediationSettings;

@interface UnityRouter : NSObject

@property NSString* _Nonnull currentPlacementId;

+ (UnityRouter *_Nonnull)sharedRouter;

- (void)initializeWithGameId:(NSString *_Nonnull)gameId withCompletionHandler:(void (^ _Nullable)(NSError *_Nullable))complete;

@end
