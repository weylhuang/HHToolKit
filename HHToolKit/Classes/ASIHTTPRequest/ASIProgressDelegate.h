
@class ASIHTTPRequest;

@protocol ASIProgressDelegate <NSObject>

@optional



#if TARGET_OS_IPHONE
- (void)setProgress:(float)newProgress;
#else
- (void)setDoubleValue:(double)newProgress;
- (void)setMaxValue:(double)newMax;
#endif


- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes;




- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes;


- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength;



- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength;
@end
