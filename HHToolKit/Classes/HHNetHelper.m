#import "HHNetHelper.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "NSObject+HHToolKit.h"
#import "NSString+HHToolKit.h"

#import <LKDBHelper/LKDBHelper.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import "HHMacro.h"
#import "HHDebug.h"
#import <Reachability/Reachability.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

NSString* hh_network_speed_detect_notification = @"hh_network_speed_detect_notification";

@implementation HHMultipart

@end

@implementation HHNetPerformance
//+(NSArray*)getAPIStatistics{
//    NSArray* arr = [HHNetPerformance searchWithSQL:@"select path, method, AVG(requestTime) as avgRequestTime, MAX(requestTime) as maxRequestTime from HHNetPerformance group by path,method"];
//    return arr;
//}
@end


@implementation HHNetHelper
- (id)userGetValueForModel:(LKDBProperty*)property
{
    if ([property.propertyType isEqualToString:@"NSDictionary"]) {
        NSDictionary* s = [self valueForKey:property.propertyName];
        NSString* d = [s hh_JSONRepresentation];
        return d;
    }
    
    return nil;
}


- (void)userSetValueForModel:(LKDBProperty*)property value:(id)value{
    if ([property.propertyType isEqualToString:@"NSDictionary"]) {
        [self setValue:[value hh_JSONValue] forKey:property.propertyName];
    }
}

+ (NSString *)getNetworkType{
    NSString *netconnType = @"";
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:// 没有网络
            netconnType = @"NotReachable";
            break;
        case ReachableViaWiFi:// Wifi
            netconnType = @"WIFI";
            break;
        case ReachableViaWWAN:// 手机自带网络
        {
            // 获取手机网络类型
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentStatus = info.currentRadioAccessTechnology;
            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                netconnType = @"2G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                netconnType = @"2G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
                netconnType = @"2G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
                netconnType = @"4G";
            }else{
                netconnType = currentStatus;
            }
        }
            break;
        default:
            break;
    }
    
    return netconnType;
}

+(void)postRequest:(HHNetHelper*)reqObj{
    
    PERFORMANCE_START(post_request)
    reqObj.method = @"POST";
    
    
    NSString* urlFullPath = reqObj.path;
    ASIFormDataRequest *request = nil;
    
    for (int i=0; i<reqObj.retryCount+1; i++) {
        startTimepost_request = [[NSDate date] timeIntervalSince1970];
        request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlFullPath]];
        if (reqObj.requestHeaders!=nil) {
            [request setRequestHeaders:reqObj.requestHeaders];
        }
        if (reqObj.requestCookies!=nil) {
            [request setRequestCookies:reqObj.requestCookies];
        }
        
        if (reqObj.usingMultiform) {
            
            for (NSString* key in reqObj.parameters.allKeys) {
                id value = reqObj.parameters[key];
                if ([value isKindOfClass:[HHMultipart class]]) {
                    [request addFile:[value localFilepath]  withFileName:[value remoteFilename] andContentType:[value ContentType] forKey:[value keyname]];
                    //                [request addData:value forKey:key];
                }else{
                    [request addPostValue:value forKey:key];
                }
            }
            [request setPostFormat:ASIMultipartFormDataPostFormat];
        }else{
            NSString *parameterString = reqObj.postBodyEncode==1? [HHNetHelper param2String:reqObj.parameters]: [reqObj.parameters hh_JSONRepresentation];
            NSMutableData *parameterData = [[parameterString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
            [request setPostBody:parameterData];
            
        }
        [request setAllowCompressedResponse:YES];
        [request setTimeOutSeconds:10];
        [request startSynchronous];
        if ([request error] == nil) {
            NSLog(@"fullpath: %@, %dth time request success", urlFullPath, i+1);
            break;
        }else{
            NSLog(@"fullpath: %@, %dth time request fail, error: %@", urlFullPath, i+1, [request error]);
            if (i < reqObj.retryCount) {
                [NSThread sleepForTimeInterval:20];
            }
            
        }
    }
    
    
    NSError* error = [request error];
    if (error.code == ASIAuthenticationErrorType) {
        error = nil;
    }
    reqObj.responseCode = request.responseStatusCode;
    if (error != nil) {
        reqObj.networkFail = YES;
        reqObj.cache = error.debugDescription;
        NSLog(@"request network fails for post: %@", urlFullPath);
    }else if (error == nil && request.responseStatusCode >= 200 && request.responseStatusCode < 400) {
        reqObj.reqSuccess = YES;
        
        reqObj.cache = [request responseString];
        reqObj.responseHeaders = [request responseHeaders];
        reqObj.responseCookies = [request responseCookies];
        reqObj.isResultFromCache = NO;
        NSLog(@"HHNetHelper success for post %@",reqObj.path);
    }else{
        reqObj.reqSuccess = NO;
        reqObj.cache =[request responseString];
        NSLog(@"request backend fails for post: %@, %@", urlFullPath, reqObj.cache);
    }
    [HHNetHelper updateCache:reqObj];
    PERFORMANCE_END(post_request)
    NET_PERFORMANCE_LOG(post_request, reqObj)
}

+(void)putRequest:(HHNetHelper*)reqObj{
    reqObj.method = @"PUT";
    PERFORMANCE_START(put_request)
    NSString* urlFullPath = reqObj.path;
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlFullPath]];
    [request setRequestMethod:reqObj.method];
    if (reqObj.requestHeaders!=nil) {
        [request setRequestHeaders:reqObj.requestHeaders];
    }
    if (reqObj.requestCookies!=nil) {
        [request setRequestCookies:reqObj.requestCookies];
    }
    
    NSString *parameterString = reqObj.postBodyEncode==1? [HHNetHelper param2String:reqObj.parameters]: [reqObj.parameters hh_JSONRepresentation];
    NSMutableData *parameterData = [[parameterString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    [request setPostBody:parameterData];
    
    
    [request setAllowCompressedResponse:YES];
    [request setTimeOutSeconds:10];
    [request startSynchronous];
    
    
    NSError* error = [request error];
    if (error.code == ASIAuthenticationErrorType) {
        error = nil;
    }
    reqObj.responseCode = request.responseStatusCode;
    if (error != nil) {
        reqObj.networkFail = YES;
        reqObj.cache = error.debugDescription;
        NSLog(@"request network fails for put: %@", urlFullPath);
    }else if (error == nil && request.responseStatusCode >= 200 && request.responseStatusCode < 400) {
        reqObj.reqSuccess = YES;
        reqObj.cache = [request responseString];
        reqObj.responseHeaders = [request responseHeaders];
        reqObj.responseCookies = [request responseCookies];
        NSLog(@"HHNetHelper success for put %@",reqObj.path);
    }else{
        reqObj.reqSuccess = NO;
        reqObj.cache =[request responseString];
        NSLog(@"request backend fails for put: %@, %@", urlFullPath, reqObj.cache);
    }
    [HHNetHelper updateCache:reqObj];
    PERFORMANCE_END(put_request)
    NET_PERFORMANCE_LOG(put_request, reqObj)
}

+(HHNetHelper*)defaultConfig{
    HHNetHelper* ret = [[HHNetHelper alloc] init];
    
    ret.cache = nil;
    ret.expirePeriod = -1;
    ret.parameters = [NSMutableDictionary dictionary];
    ret.reqSuccess = NO;
    ret.networkFail = NO;
    ret.usingMultiform = NO;
    ret.retryCount = 0;
    
    return ret;
    
    
}

-(BOOL)success{
    if (self.reqSuccess) {
        NSInteger result = [[[self.cache hh_JSONValue] valueForKey:@"res"] integerValue];
        if (result == 2000) {
            return YES;
        }
    }
    return NO;
}



-(id)result{
    return [[self.cache hh_JSONValue] valueForKey:@"res"];
}


-(void)resolve{
    self.responseStruct = [[self.cache hh_JSONValue] valueForKey:self.responseStructKey];
}

+(BOOL)hitInCache:(HHNetHelper*)reqObj{
    NSString* str = [NSString stringWithFormat:@"select * from HHNetHelper where path=\'%@\' and method = \'%@\' and reqSuccess = 1 order by calledDate desc", reqObj.path, reqObj.method];
    NSArray* arr = [HHNetHelper searchWithSQL:str];
    NSLog(@"total %ld records in db for %@", arr.count, reqObj.path);
    for (HHNetHelper* tmp in arr) {
        if ([tmp.parameters isEqualToDictionary:reqObj.parameters]) {
            if ([[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:tmp.calledDate ] ] < reqObj.expirePeriod) {
                reqObj.cache = tmp.cache;
                reqObj.reqSuccess = YES;
                reqObj.networkFail = NO;
                reqObj.isResultFromCache = YES;
                return YES;
            }
        }
    }
    return NO;
}

+(BOOL)hitInCacheForFailReq:(HHNetHelper*)reqObj{
    NSString* str = [NSString stringWithFormat:@"select * from HHNetHelper where path=\'%@\' and method = \'%@\' and reqSuccess = 1 order by calledDate desc", reqObj.path, reqObj.method];
    NSArray* arr = [HHNetHelper searchWithSQL:str];
    NSLog(@"total %ld records in db for %@", arr.count, reqObj.path);
    for (HHNetHelper* tmp in arr) {
        if ([tmp.parameters isEqualToDictionary:reqObj.parameters]) {
            reqObj.cache = tmp.cache;
            reqObj.reqSuccess = YES;
            reqObj.networkFail = NO;
            reqObj.isResultFromCache = YES;
            return YES;
        }
    }
    return NO;
}


+(void)updateCache:(HHNetHelper*)reqObj{
    if (![HHDebug currentDebugMode]) {
        NSString* str = [NSString stringWithFormat:@"path=\'%@\' and method = \'%@\' and reqSuccess = %@ and networkFail = %@", reqObj.path, reqObj.method, @(reqObj.reqSuccess), @(reqObj.networkFail)];
        NSArray* entrys = [HHNetHelper searchWithWhere:str];
        NSLog(@"total %ld records in db for %@", entrys.count, reqObj.path);
        for (HHNetHelper* config in entrys) {
            if ([config.parameters isEqualToDictionary:reqObj.parameters]) {
                [config deleteToDB];
            }
        }
    }
    reqObj.calledDate = [[NSDate date] timeIntervalSince1970];
    [reqObj saveToDB];
}


+ (NSString *) param2String:(NSDictionary*)parameters
{
    if (parameters==nil) {
        return @"";
    }
    NSString *result = @"";
    for (NSString* key in parameters.allKeys) {
        result = [result stringByAppendingFormat:@"%@=%@&", key, [parameters valueForKey:key]];
    }
    if ([result length] >= 2){
        result = [result substringToIndex:[result length] - 1];
    }
    return [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
}

- (HHNetHelper *)refresh {
    if (!self.isResultFromCache) return self;
    self.expirePeriod = -1;
    if ([self.method isEqualToString:@"GET"]) {
        [HHNetHelper getRequest:self];
    }
    return self;
}

+(void)accessUrl:(NSString*)urlString{
    if (urlString == nil) {
        return;
    }
    HHNetHelper* reqObj = [HHNetHelper defaultConfig];
    reqObj.path = urlString;
    reqObj.expirePeriod = 0;
    [HHNetHelper getRequest:reqObj];
}

+(void)getRequest:(HHNetHelper*)reqObj{
    reqObj.method = @"GET";
    
    if ([HHNetHelper hitInCache:reqObj]) {
        // 命中，reqObj中信息已更新可直接返回
        NSLog(@"HHNetHelper hit! for %@",reqObj.path);
        [reqObj resolve];
        
        return;
    }else{
        PERFORMANCE_START(get_request)
        NSString* urlFullPath = reqObj.path;
        if (reqObj.parameters && reqObj.parameters.count > 0) {
            urlFullPath = [urlFullPath stringByAppendingString:[NSString stringWithFormat:@"?%@", [HHNetHelper param2String:reqObj.parameters]]];
        }
        ASIHTTPRequest *request = nil;
        for (int i=0; i<reqObj.retryCount+1; i++) {
            startTimeget_request = [[NSDate date] timeIntervalSince1970];
            request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlFullPath]];
            if (reqObj.requestHeaders!=nil) {
                [request setRequestHeaders:reqObj.requestHeaders];
            }
            
            [request setAllowCompressedResponse:YES]; //默认是YES
            [request setTimeOutSeconds:reqObj.timeout ? : 10];
            [request startSynchronous];
            
            if ([request error] == nil || [request error].code == ASIAuthenticationErrorType) {
                NSLog(@"fullpath: %@, %dth time request success", urlFullPath, i+1);
                break;
            }else{
                NSLog(@"fullpath: %@, %dth time request fail, error: %@", urlFullPath, i+1, [request error]);
                if (i < reqObj.retryCount) {
                    [NSThread sleepForTimeInterval:20];
                }
            }
        }
        
        NSError* error = [request error];
        if (error.code == ASIAuthenticationErrorType) {
            error = nil;
        }
        reqObj.responseCode = request.responseStatusCode;
        if (error != nil) {
            reqObj.networkFail = YES;
            reqObj.cache = error.debugDescription;
            NSLog(@"request network fails for get: %@", urlFullPath);
        }else if (error == nil && request.responseStatusCode >= 200 && request.responseStatusCode < 400) {
            reqObj.reqSuccess = YES;
            reqObj.cache =[request responseString];
            [reqObj resolve];
            reqObj.isResultFromCache = NO;
            // 请求成功则更新cache
            NSLog(@"HHNetHelper success for get %@",reqObj.path);
        }else{
            reqObj.reqSuccess = NO;
            reqObj.cache =[request responseString];
            NSLog(@"request backend fails for get: %@, %@", urlFullPath, reqObj.cache);
        }
        [HHNetHelper updateCache:reqObj];
        PERFORMANCE_END(get_request)
        NET_PERFORMANCE_LOG(get_request, reqObj)
        if (reqObj.reqSuccess == NO && reqObj.useCacheForGetWhenFail) {
            [self hitInCacheForFailReq:reqObj];
        }
    }
    return;
}


+(BOOL)downloadFile:(HHNetHelper*)reqObj destPath:(NSString*)destPath{
    // destPath is the end-point file path
    NSString* urlFullPath = reqObj.path;
    if (reqObj.parameters && reqObj.parameters.count > 0) {
        urlFullPath = [urlFullPath stringByAppendingString:[NSString stringWithFormat:@"?%@", [HHNetHelper param2String:reqObj.parameters]]];
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlFullPath]];
    [request setTimeOutSeconds:30.f];
    [request setDownloadDestinationPath:destPath];
    [request startSynchronous];
    
    NSError* error = [request error];
    if (!error) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
            return YES;
        }
    }
    NSLog(@"HHNetHelper, download fail: %@, error: %@", urlFullPath, error);
    return NO;
    
}

@end


@interface HHNetSpeedDetector ()
@property (nonatomic,strong) NSURLConnection* connection;
@property (nonatomic,strong) NSMutableData* data;
@property (nonatomic,strong) NSTimer* timer;
@property (nonatomic) double startTimestamp;
@end

@implementation HHNetSpeedDetector
+(void)load{
    //    [[self getInstance] startDetect:@"https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.2.dmg"];
}
+(HHNetSpeedDetector*)getInstance{
    static HHNetSpeedDetector* detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detector = [HHNetSpeedDetector new];
        
    });
    return detector;
}

-(void)startDetect:(NSString*)testDownloadFilepath{
    @synchronized (self) {
        if (self.connection!=nil) {
            NSLog(@"HHNetSpeedDetector: 测速进行中");
            return;
        }
        static int tick;
        self.data = [NSMutableData data];
        self.startTimestamp = [[NSDate date] timeIntervalSince1970];
        self.connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:testDownloadFilepath]] delegate:self startImmediately:YES];
        tick = 0;
        WEAK(self)
        self.timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            tick ++;
            double speed = weakself.data.length / tick;
            NSLog(@"HHNetSpeedDetector: speed = %.1lfK", speed / 1024 );
            if (tick == 5) {
                [weakself finishDetect];
            }
        }];
    }
    
}

-(void)finishDetect{
    double time = [[NSDate date] timeIntervalSince1970] - self.startTimestamp;
    double speed = self.data.length / time;
    NSLog(@"HHNetSpeedDetector: 平均速度 = %.1lfK/s", speed / 1024 );
    [[NSNotificationCenter defaultCenter] postNotificationName:hh_network_speed_detect_notification object:@(speed/1024)];
    [self.timer invalidate];
    self.timer = nil;
    [self.connection cancel];
    self.connection = nil;
    self.data = nil;
}

#pragma mark - urlconnect delegate methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.data appendData:data];
}





- (void) connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"HHNetSpeedDetector: connectionDidFinishLoading");
    [self finishDetect];
}

@end
