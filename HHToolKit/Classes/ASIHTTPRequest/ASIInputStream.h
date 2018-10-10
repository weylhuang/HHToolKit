
#import <Foundation/Foundation.h>

@class ASIHTTPRequest;





@interface ASIInputStream : NSObject {
	NSInputStream *stream;
	ASIHTTPRequest *request;
}
+ (id)inputStreamWithFileAtPath:(NSString *)path request:(ASIHTTPRequest *)request;
+ (id)inputStreamWithData:(NSData *)data request:(ASIHTTPRequest *)request;

@property (retain, nonatomic) NSInputStream *stream;
@property (assign, nonatomic) ASIHTTPRequest *request;
@end
