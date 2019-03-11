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

NSString* hh_network_speed_detect_notification = @"hh_network_speed_detect_notification";

@implementation HHMultipart

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



+(void)postRequest:(HHNetHelper*)reqObj{
    PERFORMANCE_START(post_request)
    reqObj.method = @"POST";
    
    NSString* urlFullPath = reqObj.path;
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlFullPath]];
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
    PERFORMANCE_END(post_request)
    NSError* error = [request error];
    reqObj.responseCode = request.responseStatusCode;
    if (error != nil) {
        reqObj.networkFail = YES;
    }else if (error == nil && request.responseStatusCode >= 200 && request.responseStatusCode < 400) {
        reqObj.reqSuccess = YES;
        
        reqObj.cache = [request responseString];
        reqObj.responseHeaders = [request responseHeaders];
        reqObj.responseCookies = [request responseCookies];
        reqObj.isResultFromCache = NO;
    }else{
        reqObj.reqSuccess = NO;
        reqObj.cache =[request responseString];
    }
    [HHNetHelper updateCache:reqObj];
}

+(void)putRequest:(HHNetHelper*)reqObj{
    reqObj.method = @"PUT";
    
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
    reqObj.responseCode = request.responseStatusCode;
    if (error != nil) {
        reqObj.networkFail = YES;
    }else if (error == nil && request.responseStatusCode >= 200 && request.responseStatusCode < 400) {
        reqObj.reqSuccess = YES;
        reqObj.cache = [request responseString];
        reqObj.responseHeaders = [request responseHeaders];
        reqObj.responseCookies = [request responseCookies];
    }else{
        reqObj.reqSuccess = NO;
        reqObj.cache =[request responseString];
    }
    [HHNetHelper updateCache:reqObj];
    
}

+(HHNetHelper*)defaultConfig{
    HHNetHelper* ret = [[HHNetHelper alloc] init];
    
    ret.cache = nil;
    ret.expirePeriod = -1;
    ret.parameters = [NSMutableDictionary dictionary];
    ret.reqSuccess = NO;
    ret.networkFail = NO;
    ret.usingMultiform = NO;
    
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
    NSArray* arr = [HHNetHelper searchWithSQL:[NSString stringWithFormat:@"select * from HHNetHelper where path=\'%@\' and parameters = \'%@\' and method = \'%@\' and reqSuccess = 1", reqObj.path, [reqObj.parameters hh_JSONRepresentation], reqObj.method]];
    if (arr.count > 0) {
        HHNetHelper* tmp = [arr firstObject];
        if ([[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:tmp.calledDate ] ] < reqObj.expirePeriod) {
            reqObj.cache = tmp.cache;
            reqObj.reqSuccess = YES;
            return YES;
        }
    }
    return NO;
}

+(void)updateCache:(HHNetHelper*)reqObj{
    [HHNetHelper deleteWithWhere:[NSString stringWithFormat:@"path=\'%@\' and parameters = \'%@\' and method = \'%@\' and reqSuccess = %@ and networkFail = %@", reqObj.path, [reqObj.parameters hh_JSONRepresentation], reqObj.method, @(reqObj.reqSuccess), @(reqObj.networkFail)]];
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
        reqObj.isResultFromCache = YES;
        return;
    }else{
        PERFORMANCE_START(get_request)
        NSString* urlFullPath = reqObj.path;
        if (reqObj.parameters && reqObj.parameters.count > 0) {
            urlFullPath = [urlFullPath stringByAppendingString:[NSString stringWithFormat:@"?%@", [HHNetHelper param2String:reqObj.parameters]]];
        }
        NSLog(@"fullpath: %@", urlFullPath);
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlFullPath]];
        if (reqObj.requestHeaders!=nil) {
            [request setRequestHeaders:reqObj.requestHeaders];
        }
        
        [request setAllowCompressedResponse:YES]; //默认是YES
        [request setTimeOutSeconds:reqObj.timeout ? : 5];
        [request startSynchronous];
        PERFORMANCE_END(get_request)
        
        NSError* error = [request error];
        reqObj.responseCode = request.responseStatusCode;
        if (error != nil) {
            reqObj.networkFail = YES;
        }else if (error == nil && request.responseStatusCode >= 200 && request.responseStatusCode < 400) {
            reqObj.reqSuccess = YES;
            reqObj.cache =[request responseString];
            [reqObj resolve];
            reqObj.isResultFromCache = NO;
            // 请求成功则更新cache
            NSLog(@"HHNetHelper cached for %@",reqObj.path);
        }else{
            reqObj.reqSuccess = NO;
            reqObj.cache =[request responseString];
        }
        [HHNetHelper updateCache:reqObj];
        
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
            NSDictionary *fileDic = [[NSFileManager defaultManager] attributesOfItemAtPath:destPath error:nil];
            unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
            if (size == request.contentLength) {
                return YES;
            }else{
                NSLog(@"download: file size mismatch");
                [[NSFileManager defaultManager] removeItemAtPath:destPath error:nil];
            }
        }
    }
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
