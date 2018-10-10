
@class ASIHTTPRequest;

@protocol ASIHTTPRequestDelegate <NSObject>

@optional



- (void)requestStarted:(ASIHTTPRequest *)request;
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders;
- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (void)requestRedirected:(ASIHTTPRequest *)request;




- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data;




- (void)authenticationNeededForRequest:(ASIHTTPRequest *)request;
- (void)proxyAuthenticationNeededForRequest:(ASIHTTPRequest *)request;

@end
