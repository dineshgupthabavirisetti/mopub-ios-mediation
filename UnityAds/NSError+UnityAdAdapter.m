#import "NSError+UnityAdAdapter.h"

static NSString * const kUnityAdAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-unity-adapters";

@interface NSString (Prefix)
- (NSString *)addUnityPrefix;
@end

@implementation NSString (Prefix)
- (NSString *)addUnityPrefix {
    return [NSString stringWithFormat:@"[Unity Ads] %@", self];
}
@end

@implementation NSError (UnityAdAdapter)

+ (NSError *)errorWithBannerCode:(UADSBannerErrorCode)code {
    switch (code) {
        case UADSBannerErrorCodeUnknown:
            return [NSError errorWithDescription:@"Banner returned unknown error"];
            
        case UADSBannerErrorCodeNativeError:
            return [NSError errorWithDescription:@"Banner returned native error. Failed to initialize."];
            
        case UADSBannerErrorCodeWebViewError:
            return [NSError errorWithDescription:@"Banner returned WebView error. Failed to fetch banner size."];
            
        case UADSBannerErrorCodeNoFillError:
            return [NSError errorWithDescription:@"Banner returned no fill"];
    }
}

+ (NSError *)errorWithDescription:(NSString *)description {
    return [NSError errorWithDescription:description reason:@"" suggestion:@""];
}

+ (NSError *)errorWithDescription:(NSString *)description reason:(NSString *)reason suggestion:(NSString *)suggestion {
    return [NSError errorWithAdAdapterErrorCode:0 description:description reason:reason suggestion:suggestion];
}

+ (NSError *)errorWithAdAdapterErrorCode:(NSInteger)code description:(NSString *)description {
    return [NSError errorWithAdAdapterErrorCode:code description:description reason:@"" suggestion:@""];
}

+ (NSError *)errorWithAdAdapterErrorCode:(NSInteger)code description:(NSString *)description suggestion:(NSString *)suggestion {
    return [NSError errorWithAdAdapterErrorCode:code description:description reason:@"" suggestion:suggestion];
}

+ (NSError *)errorWithAdAdapterErrorCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason suggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: [NSLocalizedString(description, nil) addUnityPrefix],
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(reason, nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
    };
    return [NSError errorWithDomain:kUnityAdAdapterErrorDomain code:code userInfo:userInfo];
}

@end
