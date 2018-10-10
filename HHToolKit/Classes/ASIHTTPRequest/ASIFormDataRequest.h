
#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequestConfig.h"

typedef enum _ASIPostFormat {
    ASIMultipartFormDataPostFormat = 0,
    ASIURLEncodedPostFormat = 1
	
} ASIPostFormat;

@interface ASIFormDataRequest : ASIHTTPRequest <NSCopying> {

	// Parameters that will be POSTed to the url
	NSMutableArray *postData;
	
	// Files that will be POSTed to the url
	NSMutableArray *fileData;
	
	ASIPostFormat postFormat;
	
	NSStringEncoding stringEncoding;
	
#if DEBUG_FORM_DATA_REQUEST
	// Will store a string version of the request body that will be printed to the console when ASIHTTPREQUEST_DEBUG is set in GCC_PREPROCESSOR_DEFINITIONS
	NSString *debugBodyString;
#endif
	
}

#pragma mark utilities 
- (NSString*)encodeURL:(NSString *)string; 
 
#pragma mark setup request


- (void)addPostValue:(id <NSObject>)value forKey:(NSString *)key;


- (void)setPostValue:(id <NSObject>)value forKey:(NSString *)key;


- (void)addFile:(NSString *)filePath forKey:(NSString *)key;


- (void)addFile:(NSString *)filePath withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key;


- (void)setFile:(NSString *)filePath forKey:(NSString *)key;


- (void)setFile:(NSString *)filePath withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key;


- (void)addData:(NSData *)data forKey:(NSString *)key;


- (void)addData:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key;


- (void)setData:(NSData *)data forKey:(NSString *)key;


- (void)setData:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key;

@property (atomic, assign) ASIPostFormat postFormat;
@property (atomic, assign) NSStringEncoding stringEncoding;
@end
