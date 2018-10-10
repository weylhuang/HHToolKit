
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
	#import <CFNetwork/CFNetwork.h>
	#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	#import <UIKit/UIKit.h> // Necessary for background task support
	#endif
#endif

#import <stdio.h>
#import "ASIHTTPRequestConfig.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIProgressDelegate.h"
#import "ASICacheDelegate.h"

@class ASIDataDecompressor;

extern NSString *ASIHTTPRequestVersion;



#ifndef __IPHONE_3_2
	#define __IPHONE_3_2 30200
#endif
#ifndef __IPHONE_4_0
	#define __IPHONE_4_0 40000
#endif
#ifndef __MAC_10_5
	#define __MAC_10_5 1050
#endif
#ifndef __MAC_10_6
	#define __MAC_10_6 1060
#endif

typedef enum _ASIAuthenticationState {
	ASINoAuthenticationNeededYet = 0,
	ASIHTTPAuthenticationNeeded = 1,
	ASIProxyAuthenticationNeeded = 2
} ASIAuthenticationState;

typedef enum _ASINetworkErrorType {
    ASIConnectionFailureErrorType = 1,
    ASIRequestTimedOutErrorType = 2,
    ASIAuthenticationErrorType = 3,
    ASIRequestCancelledErrorType = 4,
    ASIUnableToCreateRequestErrorType = 5,
    ASIInternalErrorWhileBuildingRequestType  = 6,
    ASIInternalErrorWhileApplyingCredentialsType  = 7,
	ASIFileManagementError = 8,
	ASITooMuchRedirectionErrorType = 9,
	ASIUnhandledExceptionError = 10,
	ASICompressionError = 11
	
} ASINetworkErrorType;



extern NSString* const NetworkRequestErrorDomain;




extern unsigned long const ASIWWANBandwidthThrottleAmount;

#if NS_BLOCKS_AVAILABLE
typedef void (^ASIBasicBlock)(void);
typedef void (^ASIHeadersBlock)(NSDictionary *responseHeaders);
typedef void (^ASISizeBlock)(long long size);
typedef void (^ASIProgressBlock)(unsigned long long size, unsigned long long total);
typedef void (^ASIDataBlock)(NSData *data);
#endif

@interface ASIHTTPRequest : NSOperation <NSCopying> {
	
	// The url for this operation, should include GET parameters in the query string where appropriate
	NSURL *url; 
	
	// Will always contain the original url used for making the request (the value of url can change when a request is redirected)
	NSURL *originalURL;
	
	// Temporarily stores the url we are about to redirect to. Will be nil again when we do redirect
	NSURL *redirectURL;

	// The delegate - will be notified of various changes in state via the ASIHTTPRequestDelegate protocol
	id <ASIHTTPRequestDelegate> delegate;
	
	// Another delegate that is also notified of request status changes and progress updates
	// Generally, you won't use this directly, but ASINetworkQueue sets itself as the queue so it can proxy updates to its own delegates
	// NOTE: WILL BE RETAINED BY THE REQUEST
	id <ASIHTTPRequestDelegate, ASIProgressDelegate> queue;
	
	// HTTP method to use (eg: GET / POST / PUT / DELETE / HEAD etc). Defaults to GET
	NSString *requestMethod;
	
	// Request body - only used when the whole body is stored in memory (shouldStreamPostDataFromDisk is false)
	NSMutableData *postBody;
	
	// gzipped request body used when shouldCompressRequestBody is YES
	NSData *compressedPostBody;
	
	// When true, post body will be streamed from a file on disk, rather than loaded into memory at once (useful for large uploads)
	// Automatically set to true in ASIFormDataRequests when using setFile:forKey:
	BOOL shouldStreamPostDataFromDisk;
	
	// Path to file used to store post body (when shouldStreamPostDataFromDisk is true)
	// You can set this yourself - useful if you want to PUT a file from local disk 
	NSString *postBodyFilePath;
	
	// Path to a temporary file used to store a deflated post body (when shouldCompressPostBody is YES)
	NSString *compressedPostBodyFilePath;
	
	// Set to true when ASIHTTPRequest automatically created a temporary file containing the request body (when true, the file at postBodyFilePath will be deleted at the end of the request)
	BOOL didCreateTemporaryPostDataFile;
	
	// Used when writing to the post body when shouldStreamPostDataFromDisk is true (via appendPostData: or appendPostDataFromFile:)
	NSOutputStream *postBodyWriteStream;
	
	// Used for reading from the post body when sending the request
	NSInputStream *postBodyReadStream;
	
	// Dictionary for custom HTTP request headers
	NSMutableDictionary *requestHeaders;
	
	// Set to YES when the request header dictionary has been populated, used to prevent this happening more than once
	BOOL haveBuiltRequestHeaders;
	
	// Will be populated with HTTP response headers from the server
	NSDictionary *responseHeaders;
	
	// Can be used to manually insert cookie headers to a request, but it's more likely that sessionCookies will do this for you
	NSMutableArray *requestCookies;
	
	// Will be populated with cookies
	NSArray *responseCookies;
	
	// If use useCookiePersistence is true, network requests will present valid cookies from previous requests
	BOOL useCookiePersistence;
	
	// If useKeychainPersistence is true, network requests will attempt to read credentials from the keychain, and will save them in the keychain when they are successfully presented
	BOOL useKeychainPersistence;
	
	// If useSessionPersistence is true, network requests will save credentials and reuse for the duration of the session (until clearSession is called)
	BOOL useSessionPersistence;
	
	// If allowCompressedResponse is true, requests will inform the server they can accept compressed data, and will automatically decompress gzipped responses. Default is true.
	BOOL allowCompressedResponse;
	
	// If shouldCompressRequestBody is true, the request body will be gzipped. Default is false.
	// You will probably need to enable this feature on your webserver to make this work. Tested with apache only.
	BOOL shouldCompressRequestBody;
	
	// When downloadDestinationPath is set, the result of this request will be downloaded to the file at this location
	// If downloadDestinationPath is not set, download data will be stored in memory
	NSString *downloadDestinationPath;
	
	// The location that files will be downloaded to. Once a download is complete, files will be decompressed (if necessary) and moved to downloadDestinationPath
	NSString *temporaryFileDownloadPath;
	
	// If the response is gzipped and shouldWaitToInflateCompressedResponses is NO, a file will be created at this path containing the inflated response as it comes in
	NSString *temporaryUncompressedDataDownloadPath;
	
	// Used for writing data to a file when downloadDestinationPath is set
	NSOutputStream *fileDownloadOutputStream;
	
	NSOutputStream *inflatedFileDownloadOutputStream;
	
	// When the request fails or completes successfully, complete will be true
	BOOL complete;
	
    // external "finished" indicator, subject of KVO notifications; updates after 'complete'
    BOOL finished;
    
    // True if our 'cancel' selector has been called
    BOOL cancelled;
    
	// If an error occurs, error will contain an NSError
	// If error code is = ASIConnectionFailureErrorType (1, Connection failure occurred) - inspect [[error userInfo] objectForKey:NSUnderlyingErrorKey] for more information
	NSError *error;
	
	// Username and password used for authentication
	NSString *username;
	NSString *password;
	
	// User-Agent for this request
	NSString *userAgentString;
	
	// Domain used for NTLM authentication
	NSString *domain;
	
	// Username and password used for proxy authentication
	NSString *proxyUsername;
	NSString *proxyPassword;
	
	// Domain used for NTLM proxy authentication
	NSString *proxyDomain;
	
	// Delegate for displaying upload progress (usually an NSProgressIndicator, but you can supply a different object and handle this yourself)
	id <ASIProgressDelegate> uploadProgressDelegate;
	
	// Delegate for displaying download progress (usually an NSProgressIndicator, but you can supply a different object and handle this yourself)
	id <ASIProgressDelegate> downloadProgressDelegate;
	
	// Whether we've seen the headers of the response yet
    BOOL haveExaminedHeaders;
	
	// Data we receive will be stored here. Data may be compressed unless allowCompressedResponse is false - you should use [request responseData] instead in most cases
	NSMutableData *rawResponseData;
	
	// Used for sending and receiving data
    CFHTTPMessageRef request;	
	NSInputStream *readStream;
	
	// Used for authentication
    CFHTTPAuthenticationRef requestAuthentication; 
	NSDictionary *requestCredentials;
	
	// Used during NTLM authentication
	int authenticationRetryCount;
	
	// Authentication scheme (Basic, Digest, NTLM)
	// If you are using Basic authentication and want to force ASIHTTPRequest to send an authorization header without waiting for a 401, you must set this to (NSString *)kCFHTTPAuthenticationSchemeBasic
	NSString *authenticationScheme;
	
	// Realm for authentication when credentials are required
	NSString *authenticationRealm;
	
	// When YES, ASIHTTPRequest will present a dialog allowing users to enter credentials when no-matching credentials were found for a server that requires authentication
	// The dialog will not be shown if your delegate responds to authenticationNeededForRequest:
	// Default is NO.
	BOOL shouldPresentAuthenticationDialog;
	
	// When YES, ASIHTTPRequest will present a dialog allowing users to enter credentials when no-matching credentials were found for a proxy server that requires authentication
	// The dialog will not be shown if your delegate responds to proxyAuthenticationNeededForRequest:
	// Default is YES (basically, because most people won't want the hassle of adding support for authenticating proxies to their apps)
	BOOL shouldPresentProxyAuthenticationDialog;	
	
	// Used for proxy authentication
    CFHTTPAuthenticationRef proxyAuthentication; 
	NSDictionary *proxyCredentials;
	
	// Used during authentication with an NTLM proxy
	int proxyAuthenticationRetryCount;
	
	// Authentication scheme for the proxy (Basic, Digest, NTLM)
	NSString *proxyAuthenticationScheme;	
	
	// Realm for proxy authentication when credentials are required
	NSString *proxyAuthenticationRealm;
	
	// HTTP status code, eg: 200 = OK, 404 = Not found etc
	int responseStatusCode;
	
	// Description of the HTTP status code
	NSString *responseStatusMessage;
	
	// Size of the response
	unsigned long long contentLength;
	
	// Size of the partially downloaded content
	unsigned long long partialDownloadSize;
	
	// Size of the POST payload
	unsigned long long postLength;	
	
	// The total amount of downloaded data
	unsigned long long totalBytesRead;
	
	// The total amount of uploaded data
	unsigned long long totalBytesSent;
	
	// Last amount of data read (used for incrementing progress)
	unsigned long long lastBytesRead;
	
	// Last amount of data sent (used for incrementing progress)
	unsigned long long lastBytesSent;
	
	// This lock prevents the operation from being cancelled at an inopportune moment
	NSRecursiveLock *cancelledLock;
	
	// Called on the delegate (if implemented) when the request starts. Default is requestStarted:
	SEL didStartSelector;
	
	// Called on the delegate (if implemented) when the request receives response headers. Default is request:didReceiveResponseHeaders:
	SEL didReceiveResponseHeadersSelector;

	// Called on the delegate (if implemented) when the request receives a Location header and shouldRedirect is YES
	// The delegate can then change the url if needed, and can restart the request by calling [request redirectToURL:], or simply cancel it
	SEL willRedirectSelector;

	// Called on the delegate (if implemented) when the request completes successfully. Default is requestFinished:
	SEL didFinishSelector;
	
	// Called on the delegate (if implemented) when the request fails. Default is requestFailed:
	SEL didFailSelector;
	
	// Called on the delegate (if implemented) when the request receives data. Default is request:didReceiveData:
	// If you set this and implement the method in your delegate, you must handle the data yourself - ASIHTTPRequest will not populate responseData or write the data to downloadDestinationPath
	SEL didReceiveDataSelector;
	
	// Used for recording when something last happened during the request, we will compare this value with the current date to time out requests when appropriate
	NSDate *lastActivityTime;
	
	// Number of seconds to wait before timing out - default is 10
	NSTimeInterval timeOutSeconds;
	
	// Will be YES when a HEAD request will handle the content-length before this request starts
	BOOL shouldResetUploadProgress;
	BOOL shouldResetDownloadProgress;
	
	// Used by HEAD requests when showAccurateProgress is YES to preset the content-length for this request
	ASIHTTPRequest *mainRequest;
	
	// When NO, this request will only update the progress indicator when it completes
	// When YES, this request will update the progress indicator according to how much data it has received so far
	// The default for requests is YES
	// Also see the comments in ASINetworkQueue.h
	BOOL showAccurateProgress;
	
	// Used to ensure the progress indicator is only incremented once when showAccurateProgress = NO
	BOOL updatedProgress;
	
	// Prevents the body of the post being built more than once (largely for subclasses)
	BOOL haveBuiltPostBody;
	
	// Used internally, may reflect the size of the internal buffer used by CFNetwork
	// POST / PUT operations with body sizes greater than uploadBufferSize will not timeout unless more than uploadBufferSize bytes have been sent
	// Likely to be 32KB on iPhone 3.0, 128KB on Mac OS X Leopard and iPhone 2.2.x
	unsigned long long uploadBufferSize;
	
	// Text encoding for responses that do not send a Content-Type with a charset value. Defaults to NSISOLatin1StringEncoding
	NSStringEncoding defaultResponseEncoding;
	
	// The text encoding of the response, will be defaultResponseEncoding if the server didn't specify. Can't be set.
	NSStringEncoding responseEncoding;
	
	// Tells ASIHTTPRequest not to delete partial downloads, and allows it to use an existing file to resume a download. Defaults to NO.
	BOOL allowResumeForFileDownloads;
	
	// Custom user information associated with the request (not sent to the server)
	NSDictionary *userInfo;
	NSInteger tag;
	
	// Use HTTP 1.0 rather than 1.1 (defaults to false)
	BOOL useHTTPVersionOne;
	
	// When YES, requests will automatically redirect when they get a HTTP 30x header (defaults to YES)
	BOOL shouldRedirect;
	
	// Used internally to tell the main loop we need to stop and retry with a new url
	BOOL needsRedirect;
	
	// Incremented every time this request redirects. When it reaches 5, we give up
	int redirectCount;
	
	// When NO, requests will not check the secure certificate is valid (use for self-signed certificates during development, DO NOT USE IN PRODUCTION) Default is YES
	BOOL validatesSecureCertificate;
    
    // If not nil and the URL scheme is https, CFNetwork configured to supply a client certificate
    SecIdentityRef clientCertificateIdentity;
	NSArray *clientCertificates;
	
	// Details on the proxy to use - you could set these yourself, but it's probably best to let ASIHTTPRequest detect the system proxy settings
	NSString *proxyHost;
	int proxyPort;
	
	// ASIHTTPRequest will assume kCFProxyTypeHTTP if the proxy type could not be automatically determined
	// Set to kCFProxyTypeSOCKS if you are manually configuring a SOCKS proxy
	NSString *proxyType;

	// URL for a PAC (Proxy Auto Configuration) file. If you want to set this yourself, it's probably best if you use a local file
	NSURL *PACurl;
	
	// See ASIAuthenticationState values above. 0 == default == No authentication needed yet
	ASIAuthenticationState authenticationNeeded;
	
	// When YES, ASIHTTPRequests will present credentials from the session store for requests to the same server before being asked for them
	// This avoids an extra round trip for requests after authentication has succeeded, which is much for efficient for authenticated requests with large bodies, or on slower connections
	// Set to NO to only present credentials when explicitly asked for them
	// This only affects credentials stored in the session cache when useSessionPersistence is YES. Credentials from the keychain are never presented unless the server asks for them
	// Default is YES
	// For requests using Basic authentication, set authenticationScheme to (NSString *)kCFHTTPAuthenticationSchemeBasic, and credentials can be sent on the very first request when shouldPresentCredentialsBeforeChallenge is YES
	BOOL shouldPresentCredentialsBeforeChallenge;
	
	// YES when the request hasn't finished yet. Will still be YES even if the request isn't doing anything (eg it's waiting for delegate authentication). READ-ONLY
	BOOL inProgress;
	
	// Used internally to track whether the stream is scheduled on the run loop or not
	// Bandwidth throttling can unschedule the stream to slow things down while a request is in progress
	BOOL readStreamIsScheduled;
	
	// Set to allow a request to automatically retry itself on timeout
	// Default is zero - timeout will stop the request
	int numberOfTimesToRetryOnTimeout;

	// The number of times this request has retried (when numberOfTimesToRetryOnTimeout > 0)
	int retryCount;

	// Temporarily set to YES when a closed connection forces a retry (internally, this stops ASIHTTPRequest cleaning up a temporary post body)
	BOOL willRetryRequest;

	// When YES, requests will keep the connection to the server alive for a while to allow subsequent requests to re-use it for a substantial speed-boost
	// Persistent connections will not be used if the server explicitly closes the connection
	// Default is YES
	BOOL shouldAttemptPersistentConnection;

	// Number of seconds to keep an inactive persistent connection open on the client side
	// Default is 60
	// If we get a keep-alive header, this is this value is replaced with how long the server told us to keep the connection around
	// A future date is created from this and used for expiring the connection, this is stored in connectionInfo's expires value
	NSTimeInterval persistentConnectionTimeoutSeconds;
	
	// Set to yes when an appropriate keep-alive header is found
	BOOL connectionCanBeReused;
	
	// Stores information about the persistent connection that is currently in use.
	// It may contain:
	// * The id we set for a particular connection, incremented every time we want to specify that we need a new connection
	// * The date that connection should expire
	// * A host, port and scheme for the connection. These are used to determine whether that connection can be reused by a subsequent request (all must match the new request)
	// * An id for the request that is currently using the connection. This is used for determining if a connection is available or not (we store a number rather than a reference to the request so we don't need to hang onto a request until the connection expires)
	// * A reference to the stream that is currently using the connection. This is necessary because we need to keep the old stream open until we've opened a new one.
	//   The stream will be closed + released either when another request comes to use the connection, or when the timer fires to tell the connection to expire
	NSMutableDictionary *connectionInfo;
	
	// When set to YES, 301 and 302 automatic redirects will use the original method and and body, according to the HTTP 1.1 standard
	// Default is NO (to follow the behaviour of most browsers)
	BOOL shouldUseRFC2616RedirectBehaviour;
	
	// Used internally to record when a request has finished downloading data
	BOOL downloadComplete;
	
	// An ID that uniquely identifies this request - primarily used for debugging persistent connections
	NSNumber *requestID;
	
	// Will be ASIHTTPRequestRunLoopMode for synchronous requests, NSDefaultRunLoopMode for all other requests
	NSString *runLoopMode;
	
	// This timer checks up on the request every 0.25 seconds, and updates progress
	NSTimer *statusTimer;
	
	// The download cache that will be used for this request (use [ASIHTTPRequest setDefaultCache:cache] to configure a default cache
	id <ASICacheDelegate> downloadCache;
	
	// The cache policy that will be used for this request - See ASICacheDelegate.h for possible values
	ASICachePolicy cachePolicy;
	
	// The cache storage policy that will be used for this request - See ASICacheDelegate.h for possible values
	ASICacheStoragePolicy cacheStoragePolicy;
	
	// Will be true when the response was pulled from the cache rather than downloaded
	BOOL didUseCachedResponse;

	// Set secondsToCache to use a custom time interval for expiring the response when it is stored in a cache
	NSTimeInterval secondsToCache;

	#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	BOOL shouldContinueWhenAppEntersBackground;
	UIBackgroundTaskIdentifier backgroundTask;
	#endif
	
	// When downloading a gzipped response, the request will use this helper object to inflate the response
	ASIDataDecompressor *dataDecompressor;
	
	// Controls how responses with a gzipped encoding are inflated (decompressed)
	// When set to YES (This is the default):
	// * gzipped responses for requests without a downloadDestinationPath will be inflated only when [request responseData] / [request responseString] is called
	// * gzipped responses for requests with a downloadDestinationPath set will be inflated only when the request completes
	//
	// When set to NO
	// All requests will inflate the response as it comes in
	// * If the request has no downloadDestinationPath set, the raw (compressed) response is discarded and rawResponseData will contain the decompressed response
	// * If the request has a downloadDestinationPath, the raw response will be stored in temporaryFileDownloadPath as normal, the inflated response will be stored in temporaryUncompressedDataDownloadPath
	//   Once the request completes successfully, the contents of temporaryUncompressedDataDownloadPath are moved into downloadDestinationPath
	//
	// Setting this to NO may be especially useful for users using ASIHTTPRequest in conjunction with a streaming parser, as it will allow partial gzipped responses to be inflated and passed on to the parser while the request is still running
	BOOL shouldWaitToInflateCompressedResponses;

	// Will be YES if this is a request created behind the scenes to download a PAC file - these requests do not attempt to configure their own proxies
	BOOL isPACFileRequest;

	// Used for downloading PAC files from http / https webservers
	ASIHTTPRequest *PACFileRequest;

	// Used for asynchronously reading PAC files from file:// URLs
	NSInputStream *PACFileReadStream;

	// Used for storing PAC data from file URLs as it is downloaded
	NSMutableData *PACFileData;

	// Set to YES in startSynchronous. Currently used by proxy detection to download PAC files synchronously when appropriate
	BOOL isSynchronous;

	#if NS_BLOCKS_AVAILABLE
	//block to execute when request starts
	ASIBasicBlock startedBlock;

	//block to execute when headers are received
	ASIHeadersBlock headersReceivedBlock;

	//block to execute when request completes successfully
	ASIBasicBlock completionBlock;

	//block to execute when request fails
	ASIBasicBlock failureBlock;

	//block for when bytes are received
	ASIProgressBlock bytesReceivedBlock;

	//block for when bytes are sent
	ASIProgressBlock bytesSentBlock;

	//block for when download size is incremented
	ASISizeBlock downloadSizeIncrementedBlock;

	//block for when upload size is incremented
	ASISizeBlock uploadSizeIncrementedBlock;

	//block for handling raw bytes received
	ASIDataBlock dataReceivedBlock;

	//block for handling authentication
	ASIBasicBlock authenticationNeededBlock;

	//block for handling proxy authentication
	ASIBasicBlock proxyAuthenticationNeededBlock;
	
    //block for handling redirections, if you want to
    ASIBasicBlock requestRedirectedBlock;
	#endif
}

#pragma mark init / dealloc


- (id)initWithURL:(NSURL *)newURL;


+ (id)requestWithURL:(NSURL *)newURL;

+ (id)requestWithURL:(NSURL *)newURL usingCache:(id <ASICacheDelegate>)cache;
+ (id)requestWithURL:(NSURL *)newURL usingCache:(id <ASICacheDelegate>)cache andCachePolicy:(ASICachePolicy)policy;

#if NS_BLOCKS_AVAILABLE
- (void)setStartedBlock:(ASIBasicBlock)aStartedBlock;
- (void)setHeadersReceivedBlock:(ASIHeadersBlock)aReceivedBlock;
- (void)setCompletionBlock:(ASIBasicBlock)aCompletionBlock;
- (void)setFailedBlock:(ASIBasicBlock)aFailedBlock;
- (void)setBytesReceivedBlock:(ASIProgressBlock)aBytesReceivedBlock;
- (void)setBytesSentBlock:(ASIProgressBlock)aBytesSentBlock;
- (void)setDownloadSizeIncrementedBlock:(ASISizeBlock) aDownloadSizeIncrementedBlock;
- (void)setUploadSizeIncrementedBlock:(ASISizeBlock) anUploadSizeIncrementedBlock;
- (void)setDataReceivedBlock:(ASIDataBlock)aReceivedBlock;
- (void)setAuthenticationNeededBlock:(ASIBasicBlock)anAuthenticationBlock;
- (void)setProxyAuthenticationNeededBlock:(ASIBasicBlock)aProxyAuthenticationBlock;
- (void)setRequestRedirectedBlock:(ASIBasicBlock)aRedirectBlock;
#endif

#pragma mark setup request


- (void)addRequestHeader:(NSString *)header value:(NSString *)value;


- (void)applyCookieHeader;


- (void)buildRequestHeaders;


- (void)applyAuthorizationHeader;



- (void)buildPostBody;


- (void)appendPostData:(NSData *)data;
- (void)appendPostDataFromFile:(NSString *)file;

#pragma mark get information about this request


- (NSString *)responseString;


- (NSData *)responseData;


- (BOOL)isResponseCompressed;

#pragma mark running a request



- (void)startSynchronous;


- (void)startAsynchronous;


- (void)clearDelegatesAndCancel;

#pragma mark HEAD request


- (ASIHTTPRequest *)HEADRequest;

#pragma mark upload/download progress


- (void)updateProgressIndicators;


- (void)updateUploadProgress;


- (void)updateDownloadProgress;


- (void)removeUploadProgressSoFar;


- (void)incrementDownloadSizeBy:(long long)length;



- (void)incrementUploadSizeBy:(long long)length;


+ (void)updateProgressIndicator:(id *)indicator withProgress:(unsigned long long)progress ofTotal:(unsigned long long)total;


+ (void)performSelector:(SEL)selector onTarget:(id *)target withObject:(id)object amount:(void *)amount callerToRetain:(id)caller;

#pragma mark talking to delegates


- (void)requestStarted;


- (void)requestReceivedResponseHeaders:(NSDictionary *)newHeaders;


- (void)requestFinished;


- (void)failWithError:(NSError *)theError;




- (BOOL)retryUsingNewConnection;


- (void)redirectToURL:(NSURL *)newURL;

#pragma mark parsing HTTP response headers




- (void)readResponseHeaders;


- (void)parseStringEncodingFromHeaders;

+ (void)parseMimeType:(NSString **)mimeType andResponseEncoding:(NSStringEncoding *)stringEncoding fromContentType:(NSString *)contentType;

#pragma mark http authentication stuff


- (BOOL)applyCredentials:(NSDictionary *)newCredentials;
- (BOOL)applyProxyCredentials:(NSDictionary *)newCredentials;


- (NSMutableDictionary *)findCredentials;
- (NSMutableDictionary *)findProxyCredentials;



- (void)retryUsingSuppliedCredentials;


- (void)cancelAuthentication;


- (void)attemptToApplyCredentialsAndResume;
- (void)attemptToApplyProxyCredentialsAndResume;



- (BOOL)showProxyAuthenticationDialog;
- (BOOL)showAuthenticationDialog;



- (void)addBasicAuthenticationHeaderWithUsername:(NSString *)theUsername andPassword:(NSString *)thePassword;

#pragma mark stream status handlers


- (void)handleNetworkEvent:(CFStreamEventType)type;
- (void)handleBytesAvailable;
- (void)handleStreamComplete;
- (void)handleStreamError;

#pragma mark cleanup



- (void)markAsFinished;




- (BOOL)removeTemporaryDownloadFile;


- (BOOL)removeTemporaryUncompressedDownloadFile;


- (BOOL)removeTemporaryUploadFile;


- (BOOL)removeTemporaryCompressedUploadFile;


+ (BOOL)removeFileAtPath:(NSString *)path error:(NSError **)err;

#pragma mark persistent connections


- (NSNumber *)connectionID;


+ (void)expirePersistentConnections;

#pragma mark default time out

+ (NSTimeInterval)defaultTimeOutSeconds;
+ (void)setDefaultTimeOutSeconds:(NSTimeInterval)newTimeOutSeconds;

#pragma mark client certificate

- (void)setClientCertificateIdentity:(SecIdentityRef)anIdentity;

#pragma mark session credentials

+ (NSMutableArray *)sessionProxyCredentialsStore;
+ (NSMutableArray *)sessionCredentialsStore;

+ (void)storeProxyAuthenticationCredentialsInSessionStore:(NSDictionary *)credentials;
+ (void)storeAuthenticationCredentialsInSessionStore:(NSDictionary *)credentials;

+ (void)removeProxyAuthenticationCredentialsFromSessionStore:(NSDictionary *)credentials;
+ (void)removeAuthenticationCredentialsFromSessionStore:(NSDictionary *)credentials;

- (NSDictionary *)findSessionProxyAuthenticationCredentials;
- (NSDictionary *)findSessionAuthenticationCredentials;

#pragma mark keychain storage


- (void)saveCredentialsToKeychain:(NSDictionary *)newCredentials;


+ (void)saveCredentials:(NSURLCredential *)credentials forHost:(NSString *)host port:(int)port protocol:(NSString *)protocol realm:(NSString *)realm;
+ (void)saveCredentials:(NSURLCredential *)credentials forProxy:(NSString *)host port:(int)port realm:(NSString *)realm;


+ (NSURLCredential *)savedCredentialsForHost:(NSString *)host port:(int)port protocol:(NSString *)protocol realm:(NSString *)realm;
+ (NSURLCredential *)savedCredentialsForProxy:(NSString *)host port:(int)port protocol:(NSString *)protocol realm:(NSString *)realm;


+ (void)removeCredentialsForHost:(NSString *)host port:(int)port protocol:(NSString *)protocol realm:(NSString *)realm;
+ (void)removeCredentialsForProxy:(NSString *)host port:(int)port realm:(NSString *)realm;


+ (void)setSessionCookies:(NSMutableArray *)newSessionCookies;
+ (NSMutableArray *)sessionCookies;


+ (void)addSessionCookie:(NSHTTPCookie *)newCookie;


+ (void)clearSession;

#pragma mark get user agent



+ (NSString *)defaultUserAgentString;
+ (void)setDefaultUserAgentString:(NSString *)agent;

#pragma mark mime-type detection


+ (NSString *)mimeTypeForFileAtPath:(NSString *)path;

#pragma mark bandwidth measurement / throttling



+ (unsigned long)maxBandwidthPerSecond;
+ (void)setMaxBandwidthPerSecond:(unsigned long)bytes;


+ (unsigned long)averageBandwidthUsedPerSecond;

- (void)performThrottling;


+ (BOOL)isBandwidthThrottled;


+ (void)incrementBandwidthUsedInLastSecond:(unsigned long)bytes;



#if TARGET_OS_IPHONE

+ (void)setShouldThrottleBandwidthForWWAN:(BOOL)throttle;


+ (void)throttleBandwidthForWWANUsingLimit:(unsigned long)limit;

#pragma mark reachability


+ (BOOL)isNetworkReachableViaWWAN;

#endif

#pragma mark queue


+ (NSOperationQueue *)sharedQueue;

#pragma mark cache

+ (void)setDefaultCache:(id <ASICacheDelegate>)cache;
+ (id <ASICacheDelegate>)defaultCache;


+ (unsigned long)maxUploadReadLength;

#pragma mark network activity

+ (BOOL)isNetworkInUse;

+ (void)setShouldUpdateNetworkActivityIndicator:(BOOL)shouldUpdate;


+ (void)showNetworkActivityIndicator;


+ (void)hideNetworkActivityIndicator;

#pragma mark miscellany



+ (NSString *)base64forData:(NSData *)theData;




+ (NSDate *)expiryDateForRequest:(ASIHTTPRequest *)request maxAge:(NSTimeInterval)maxAge;


+ (NSDate *)dateFromRFC1123String:(NSString *)string;



#if TARGET_OS_IPHONE
+ (BOOL)isMultitaskingSupported;
#endif

#pragma mark threading behaviour








+ (NSThread *)threadForRequest:(ASIHTTPRequest *)request;


#pragma mark ===

@property (atomic, retain) NSString *username;
@property (atomic, retain) NSString *password;
@property (atomic, retain) NSString *userAgentString;
@property (atomic, retain) NSString *domain;

@property (atomic, retain) NSString *proxyUsername;
@property (atomic, retain) NSString *proxyPassword;
@property (atomic, retain) NSString *proxyDomain;

@property (atomic, retain) NSString *proxyHost;
@property (atomic, assign) int proxyPort;
@property (atomic, retain) NSString *proxyType;

@property (retain,setter=setURL:, nonatomic) NSURL *url;
@property (atomic, retain) NSURL *originalURL;
@property (assign, nonatomic) id delegate;
@property (retain, nonatomic) id queue;
@property (assign, nonatomic) id uploadProgressDelegate;
@property (assign, nonatomic) id downloadProgressDelegate;
@property (atomic, assign) BOOL useKeychainPersistence;
@property (atomic, assign) BOOL useSessionPersistence;
@property (atomic, retain) NSString *downloadDestinationPath;
@property (atomic, retain) NSString *temporaryFileDownloadPath;
@property (atomic, retain) NSString *temporaryUncompressedDataDownloadPath;
@property (atomic, assign) SEL didStartSelector;
@property (atomic, assign) SEL didReceiveResponseHeadersSelector;
@property (atomic, assign) SEL willRedirectSelector;
@property (atomic, assign) SEL didFinishSelector;
@property (atomic, assign) SEL didFailSelector;
@property (atomic, assign) SEL didReceiveDataSelector;
@property (atomic, retain,readonly) NSString *authenticationRealm;
@property (atomic, retain,readonly) NSString *proxyAuthenticationRealm;
@property (atomic, retain) NSError *error;
@property (atomic, assign,readonly) BOOL complete;
@property (atomic, retain) NSDictionary *responseHeaders;
@property (atomic, retain) NSMutableDictionary *requestHeaders;
@property (atomic, retain) NSMutableArray *requestCookies;
@property (atomic, retain,readonly) NSArray *responseCookies;
@property (atomic, assign) BOOL useCookiePersistence;
@property (atomic, retain) NSDictionary *requestCredentials;
@property (atomic, retain) NSDictionary *proxyCredentials;
@property (atomic, assign,readonly) int responseStatusCode;
@property (atomic, retain,readonly) NSString *responseStatusMessage;
@property (atomic, retain) NSMutableData *rawResponseData;
@property (atomic, assign) NSTimeInterval timeOutSeconds;
@property (retain, nonatomic) NSString *requestMethod;
@property (atomic, retain) NSMutableData *postBody;
@property (atomic, assign) unsigned long long contentLength;
@property (atomic, assign) unsigned long long postLength;
@property (atomic, assign) BOOL shouldResetDownloadProgress;
@property (atomic, assign) BOOL shouldResetUploadProgress;
@property (atomic, assign) ASIHTTPRequest *mainRequest;
@property (atomic, assign) BOOL showAccurateProgress;
@property (atomic, assign) unsigned long long totalBytesRead;
@property (atomic, assign) unsigned long long totalBytesSent;
@property (atomic, assign) NSStringEncoding defaultResponseEncoding;
@property (atomic, assign) NSStringEncoding responseEncoding;
@property (atomic, assign) BOOL allowCompressedResponse;
@property (atomic, assign) BOOL allowResumeForFileDownloads;
@property (atomic, retain) NSDictionary *userInfo;
@property (atomic, assign) NSInteger tag;
@property (atomic, retain) NSString *postBodyFilePath;
@property (atomic, assign) BOOL shouldStreamPostDataFromDisk;
@property (atomic, assign) BOOL didCreateTemporaryPostDataFile;
@property (atomic, assign) BOOL useHTTPVersionOne;
@property (atomic, assign, readonly) unsigned long long partialDownloadSize;
@property (atomic, assign) BOOL shouldRedirect;
@property (atomic, assign) BOOL validatesSecureCertificate;
@property (atomic, assign) BOOL shouldCompressRequestBody;
@property (atomic, retain) NSURL *PACurl;
@property (atomic, retain) NSString *authenticationScheme;
@property (atomic, retain) NSString *proxyAuthenticationScheme;
@property (atomic, assign) BOOL shouldPresentAuthenticationDialog;
@property (atomic, assign) BOOL shouldPresentProxyAuthenticationDialog;
@property (atomic, assign, readonly) ASIAuthenticationState authenticationNeeded;
@property (atomic, assign) BOOL shouldPresentCredentialsBeforeChallenge;
@property (atomic, assign, readonly) int authenticationRetryCount;
@property (atomic, assign, readonly) int proxyAuthenticationRetryCount;
@property (atomic, assign) BOOL haveBuiltRequestHeaders;
@property (assign, nonatomic) BOOL haveBuiltPostBody;
@property (atomic, assign, readonly) BOOL inProgress;
@property (atomic, assign) int numberOfTimesToRetryOnTimeout;
@property (atomic, assign, readonly) int retryCount;
@property (atomic, assign) BOOL shouldAttemptPersistentConnection;
@property (atomic, atomic, assign) NSTimeInterval persistentConnectionTimeoutSeconds;
@property (atomic, assign) BOOL shouldUseRFC2616RedirectBehaviour;
@property (atomic, assign, readonly) BOOL connectionCanBeReused;
@property (atomic, retain, readonly) NSNumber *requestID;
@property (atomic, assign) id <ASICacheDelegate> downloadCache;
@property (atomic, assign) ASICachePolicy cachePolicy;
@property (atomic, assign) ASICacheStoragePolicy cacheStoragePolicy;
@property (atomic, assign, readonly) BOOL didUseCachedResponse;
@property (atomic, assign) NSTimeInterval secondsToCache;
@property (atomic, retain) NSArray *clientCertificates;
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
@property (atomic, assign) BOOL shouldContinueWhenAppEntersBackground;
#endif
@property (atomic, retain) ASIDataDecompressor *dataDecompressor;
@property (atomic, assign) BOOL shouldWaitToInflateCompressedResponses;

@end
