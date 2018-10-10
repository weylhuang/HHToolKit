
#import <Foundation/Foundation.h>


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
@property (nonatomic) BOOL success;
@property (nonatomic, assign) BOOL isResultFromCache;
@property (nonatomic) BOOL usingMultiform;

@property (nonatomic,strong) NSDictionary* responseHeaders;
@property (nonatomic,strong) NSArray* responseCookies;
@property (nonatomic,strong) NSMutableDictionary* requestHeaders;
@property (nonatomic,strong) NSMutableArray* requestCookies;
@property (nonatomic, strong) id responseStruct;
@property (nonatomic, copy) NSString* responseStructKey;



+(HHNetHelper*)defaultConfig;
+(void)getRequest:(HHNetHelper*)reqObj;
+(void)postRequest:(HHNetHelper*)reqObj;
+(void)request:(HHNetHelper*)reqObj Body:(NSString *)body;
+(BOOL)downloadFile:(HHNetHelper*)reqObj destPath:(NSString*)destPath;
- (HHNetHelper *)refresh;
+ (NSString *) param2String:(NSDictionary*)parameters;
-(BOOL)success;
-(id)result;

@end



