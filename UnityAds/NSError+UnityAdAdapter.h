#import <Foundation/Foundation.h>
#import <UnityAds/UnityAds.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (UnityAdAdapter)

+ (NSError *)errorWithBannerCode:(UADSBannerErrorCode)code;
+ (NSError *)errorWithDescription:(NSString *)description;
+ (NSError *)errorWithDescription:(NSString *)description reason:(NSString *)reason suggestion:(NSString *)suggestion;
+ (NSError *)errorWithAdAdapterErrorCode:(NSInteger)code description:(NSString *)description;
+ (NSError *)errorWithAdAdapterErrorCode:(NSInteger)code description:(NSString *)description suggestion:(NSString *)suggestion;
+ (NSError *)errorWithAdAdapterErrorCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason suggestion:(NSString *)suggestion;

@end

NS_ASSUME_NONNULL_END
