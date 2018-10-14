
#import <Foundation/Foundation.h>

@interface HHMultipart : NSObject
@property (nonatomic,strong) NSString* keyname;
@property (nonatomic,strong) NSString* remoteFilename;
@property (nonatomic,strong) NSString* localFilepath;
@property (nonatomic,strong) NSString* ContentType;

@end


@interface HHNetHelper : NSObject

@property (nonatomic) BOOL bUseCacheWhenFail;
@property (nonatomic,strong) NSString* cache;
@property (nonatomic,strong) NSString* path;
@property (nonatomic,strong) NSDictionary* parameters;
@property (nonatomic,strong) NSString* method;
@property (nonatomic,strong) NSString* errInfo;
@property (nonatomic) double calledDate;
@property (nonatomic) NSInteger expirePeriod;
@property (nonatomic) NSInteger timeout;
@property (nonatomic) BOOL reqSuccess;
@property (nonatomic, assign) BOOL isResultFromCache;
@property (nonatomic) BOOL usingMultiform;
@property (nonatomic) NSInteger postBodyEncode;  // 0: json, 1: form,
@property (nonatomic,strong) NSDictionary* responseHeaders;
@property (nonatomic,strong) NSArray* responseCookies;
@property (nonatomic,strong) NSMutableDictionary* requestHeaders;
@property (nonatomic,strong) NSMutableArray* requestCookies;
@property (nonatomic, strong) id responseStruct;
@property (nonatomic, copy) NSString* responseStructKey;



+(HHNetHelper*)defaultConfig;
+(void)getRequest:(HHNetHelper*)reqObj;
+(void)postRequest:(HHNetHelper*)reqObj;
+(BOOL)downloadFile:(HHNetHelper*)reqObj destPath:(NSString*)destPath;
- (HHNetHelper *)refresh;
+ (NSString *) param2String:(NSDictionary*)parameters;
-(BOOL)success;
-(id)result;

@end



