#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MPBaseAdapterConfiguration.h"
#import "MPLogging.h"
#endif

NS_ASSUME_NONNULL_BEGIN

// The is a required key that represents the SnapKit App ID of the app that displays the ad.
extern NSString * const kSAKAppId;

@interface SnapAdAdapterConfiguration : MPBaseAdapterConfiguration

+ (void)updateInitializationParameters:(NSDictionary *)parameters;

@property (nonatomic, copy, readonly) NSString * adapterVersion;
@property (nonatomic, copy, readonly) NSString * moPubNetworkName;
@property (nonatomic, copy, readonly) NSString * networkSdkVersion;

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete;

+ (void)initSnapAdKit:(NSDictionary *)info complete:(void(^)(NSError *))complete;

@end

NS_ASSUME_NONNULL_END
