
#import <Foundation/Foundation.h>

@interface HHMultipart : NSObject
@property (nonatomic,strong) NSString* keyname;
@property (nonatomic,strong) NSString* remoteFilename;
@property (nonatomic,strong) NSString* localFilepath;
@property (nonatomic,strong) NSString* ContentType;

@end


@interface HHNetHelper : NSObject
@property (nonatomic, copy) id (^postProcessBlock)(NSDictionary*);

@property (nonatomic,strong) NSString* cache;
@property (nonatomic,strong) NSString* path;
@property (nonatomic,strong) NSDictionary* parameters;
@property (nonatomic,strong) NSString* method;
@property (nonatomic,strong) NSString* errInfo;
@property (nonatomic) NSInteger responseCode;
@property (nonatomic) double calledDate;
@property (nonatomic) NSInteger expirePeriod;
@property (nonatomic) NSInteger timeout;
@property (nonatomic) NSInteger retryCount;
@property (nonatomic) BOOL reqSuccess;
@property (nonatomic) BOOL networkFail;
@property (nonatomic, assign) BOOL isResultFromCache;
@property (nonatomic) BOOL useCacheForGetWhenFail;
@property (nonatomic) BOOL usingMultiform;
@property (nonatomic) NSInteger postBodyEncode;  // 0: json, 1: form,
@property (nonatomic,strong) NSDictionary* responseHeaders;
@property (nonatomic,strong) NSArray* responseCookies;
@property (nonatomic,strong) NSMutableDictionary* requestHeaders;
@property (nonatomic,strong) NSMutableArray* requestCookies;
@property (nonatomic, strong) id responseStruct;
@property (nonatomic, copy) NSString* responseStructKey;


+ (NSString *)getNetworkType;
+(HHNetHelper*)defaultConfig;
+(void)getRequest:(HHNetHelper*)reqObj;
+(void)postRequest:(HHNetHelper*)reqObj;
+(void)putRequest:(HHNetHelper*)reqObj;
+(BOOL)downloadFile:(HHNetHelper*)reqObj destPath:(NSString*)destPath;
- (HHNetHelper *)refresh;
+ (NSString *) param2String:(NSDictionary*)parameters;
-(BOOL)success;
-(id)result;

-(HHNetHelper*)setUrl:(NSString *)path;
-(HHNetHelper*)setHttpMethod:(NSString *)method;
@end

@interface HHNetPerformance : NSObject
@property (nonatomic,strong) NSString* path;
@property (nonatomic,strong) NSString* method;
@property (nonatomic,strong) NSDictionary* requestHeaders;
@property (nonatomic) double duration;
@property (nonatomic) BOOL reqSuccess;
@property (nonatomic) NSInteger responseCode;
@property (nonatomic) double calledDate;
@property (nonatomic,strong) NSString* reachability;
@property (nonatomic,strong) NSString* error;
@end



extern NSString* hh_network_speed_detect_notification;

@interface HHNetSpeedDetector : NSObject
+(HHNetSpeedDetector*)getInstance;
-(void)startDetect:(NSString*)testDownloadFilepath;
@end

