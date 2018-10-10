
#import <Foundation/Foundation.h>
@class ASIHTTPRequest;





typedef enum _ASICachePolicy {

	// The default cache policy. When you set a request to use this, it will use the cache's defaultCachePolicy
	// ASIDownloadCache's default cache policy is 'ASIAskServerIfModifiedWhenStaleCachePolicy'
	ASIUseDefaultCachePolicy = 0,

	// Tell the request not to read from the cache
	ASIDoNotReadFromCacheCachePolicy = 1,

	// The the request not to write to the cache
	ASIDoNotWriteToCacheCachePolicy = 2,

	// Ask the server if there is an updated version of this resource (using a conditional GET) ONLY when the cached data is stale
	ASIAskServerIfModifiedWhenStaleCachePolicy = 4,

	// Always ask the server if there is an updated version of this resource (using a conditional GET)
	ASIAskServerIfModifiedCachePolicy = 8,

	// If cached data exists, use it even if it is stale. This means requests will not talk to the server unless the resource they are requesting is not in the cache
	ASIOnlyLoadIfNotCachedCachePolicy = 16,

	// If cached data exists, use it even if it is stale. If cached data does not exist, stop (will not set an error on the request)
	ASIDontLoadCachePolicy = 32,

	// Specifies that cached data may be used if the request fails. If cached data is used, the request will succeed without error. Usually used in combination with other options above.
	ASIFallbackToCacheIfLoadFailsCachePolicy = 64
} ASICachePolicy;



typedef enum _ASICacheStoragePolicy {
	ASICacheForSessionDurationCacheStoragePolicy = 0,
	ASICachePermanentlyCacheStoragePolicy = 1
} ASICacheStoragePolicy;


@protocol ASICacheDelegate <NSObject>

@required


- (ASICachePolicy)defaultCachePolicy;


- (NSDate *)expiryDateForRequest:(ASIHTTPRequest *)request maxAge:(NSTimeInterval)maxAge;


- (void)updateExpiryForRequest:(ASIHTTPRequest *)request maxAge:(NSTimeInterval)maxAge;


- (BOOL)canUseCachedDataForRequest:(ASIHTTPRequest *)request;


- (void)removeCachedDataForRequest:(ASIHTTPRequest *)request;



- (BOOL)isCachedDataCurrentForRequest:(ASIHTTPRequest *)request;



- (void)storeResponseForRequest:(ASIHTTPRequest *)request maxAge:(NSTimeInterval)maxAge;


- (void)removeCachedDataForURL:(NSURL *)url;


- (NSDictionary *)cachedResponseHeadersForURL:(NSURL *)url;


- (NSData *)cachedResponseDataForURL:(NSURL *)url;


- (NSString *)pathToCachedResponseDataForURL:(NSURL *)url;


- (NSString *)pathToCachedResponseHeadersForURL:(NSURL *)url;


- (NSString *)pathToStoreCachedResponseHeadersForRequest:(ASIHTTPRequest *)request;


- (NSString *)pathToStoreCachedResponseDataForRequest:(ASIHTTPRequest *)request;


- (void)clearCachedResponsesForStoragePolicy:(ASICacheStoragePolicy)cachePolicy;

@end
