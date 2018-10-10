#import "HHNetHelper.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "NSObject+HHToolKit.h"
#import "NSString+HHToolKit.h"

#import <LKDBHelper/LKDBHelper.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

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



+(void)request:(HHNetHelper*)reqObj method:(NSString *)method{
    reqObj.method = method;
    
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
            if ([value isKindOfClass:[NSData class]]) {
                [request addData:value forKey:key];
            }else{
                [request addPostValue:value forKey:key];
            }
        }
        [request setPostFormat:ASIMultipartFormDataPostFormat];
    }else{
        NSString *parameterString = [reqObj.parameters hh_JSONRepresentation];
        NSMutableData *parameterData = [[parameterString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
        [request setPostBody:parameterData];
        
    }
    
    
    [request setAllowCompressedResponse:YES];
    [request setTimeOutSeconds:10];
    [request startSynchronous];
    
    NSError* error = [request error];
    if (!error) {
        reqObj.success = YES;
        reqObj.cache = [request responseString];
        reqObj.responseHeaders = [request responseHeaders];
        reqObj.responseCookies = [request responseCookies];
        
        reqObj.isResultFromCache = NO;
        [HHNetHelper updateCache:reqObj];
    }else{
        reqObj.success = NO;
        
    }
    
    if (!reqObj.success && reqObj.bUseCacheWhenFail) {
        [HHNetHelper hitInCacheForFail:reqObj];
    }
    
    if (!reqObj.success) {
        
    }
    
}


+(HHNetHelper*)defaultConfig{
    HHNetHelper* ret = [[HHNetHelper alloc] init];
    
    ret.cache = nil;
    ret.expirePeriod = -1;
    ret.parameters = [NSMutableDictionary dictionary];
    ret.success = NO;
    ret.usingMultiform = NO;
    
    return ret;
    
    
}

-(BOOL)success{
    if (self.success) {
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
    
    NSArray* arr = [HHNetHelper searchWithSQL:[NSString stringWithFormat:@"select * from HHNetHelper where path=\'%@\' and parameters = \'%@\' and method = \'%@\'", reqObj.path, [reqObj.parameters hh_JSONRepresentation], reqObj.method]];
    if (arr.count > 0) {
        HHNetHelper* tmp = [arr firstObject];
        if ([[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:tmp.calledDate ] ] < reqObj.expirePeriod) {
            reqObj.cache = tmp.cache;
            reqObj.success = YES;
            return YES;
        }
    }
    return NO;
}

+(void)hitInCacheForFail:(HHNetHelper*)reqObj{
    NSString* query = [NSString stringWithFormat:@"select * from HHNetHelper where path=\'%@\' and parameters = \'%@\' and method = \'%@\'", reqObj.path, [reqObj.parameters hh_JSONRepresentation], reqObj.method];
    NSArray* arr = [HHNetHelper searchWithSQL:query];
    if (arr.count > 0) {
        HHNetHelper* tmp = [arr firstObject];
        reqObj.cache = tmp.cache;
        reqObj.success = YES;
        reqObj.isResultFromCache = YES;
    }
}


+(void)updateCache:(HHNetHelper*)reqObj{
    [HHNetHelper deleteWithWhere:[NSString stringWithFormat:@"path=\'%@\' and parameters = \'%@\' and method = \'%@\'", reqObj.path, [reqObj.parameters hh_JSONRepresentation], reqObj.method]];
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
        result = [@"?" stringByAppendingString:result];
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
        NSString* urlFullPath = [NSString stringWithFormat:@"%@%@",reqObj.path, [HHNetHelper param2String:reqObj.parameters]];;
        NSLog(@"fullpath: %@", urlFullPath);
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlFullPath]];
        
        [request setAllowCompressedResponse:YES]; //默认是YES
        [request setTimeOutSeconds:reqObj.timeout ? : 5];
        [request startSynchronous];
        
        NSError* error = [request error];
        if (!error) {
            NSDictionary *dic = [[request responseString] hh_JSONValue];
            // dic != nil是为了预防404
            if (dic != nil) {
                reqObj.success = YES;
                reqObj.cache =[request responseString];
                [reqObj resolve];
                reqObj.isResultFromCache = NO;
                // 请求成功则更新cache
                [HHNetHelper updateCache:reqObj];
                NSLog(@"HHNetHelper cached for %@",reqObj.path);
            }
            else{
                
                reqObj.success = NO;
            }
            
        }else{
            reqObj.success = NO;
        }
        
        if (!reqObj.success && reqObj.bUseCacheWhenFail) {
            [HHNetHelper hitInCacheForFail:reqObj];
        }
        
        if (!reqObj.success) {
            
        }
    }
    
    
    return;
    
}

+(void)postRequest:(HHNetHelper*)reqObj{
    [self request:reqObj method:@"POST"];
}




+(BOOL)downloadFile:(HHNetHelper*)reqObj destPath:(NSString*)destPath{

    NSString* urlFullPath = [NSString stringWithFormat:@"%@%@",reqObj.path, [HHNetHelper param2String:reqObj.parameters]];;
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlFullPath]];

    [request setDownloadDestinationPath:destPath];
    [request startSynchronous];
    
    NSError* error = [request error];
    if (!error) {
        return YES;
    }else{
        return NO;
    }
}

@end

