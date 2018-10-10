
#import <Foundation/Foundation.h>
#import "ASICacheDelegate.h"

@interface ASIDownloadCache : NSObject <ASICacheDelegate> {
	
	// The default cache policy for this cache
	// Requests that store data in the cache will use this cache policy if their cache policy is set to ASIUseDefaultCachePolicy
	// Defaults to ASIAskServerIfModifiedWhenStaleCachePolicy
	ASICachePolicy defaultCachePolicy;
	
	// The directory in which cached data will be stored
	// Defaults to a directory called 'ASIHTTPRequestCache' in the temporary directory
	NSString *storagePath;
	
	// Mediates access to the cache
	NSRecursiveLock *accessLock;
	
	// When YES, the cache will look for cache-control / pragma: no-cache headers, and won't reuse store responses if it finds them
	BOOL shouldRespectCacheControlHeaders;
}




+ (id)sharedCache;


+ (BOOL)serverAllowsResponseCachingForRequest:(ASIHTTPRequest *)request;



+ (NSArray *)fileExtensionsToHandleAsHTML;

@property (assign, nonatomic) ASICachePolicy defaultCachePolicy;
@property (retain, nonatomic) NSString *storagePath;
@property (atomic, retain) NSRecursiveLock *accessLock;
@property (atomic, assign) BOOL shouldRespectCacheControlHeaders;
@end
