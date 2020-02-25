//
//  HHDebug.h
//  FMDB
//
//  Created by weyl on 2018/10/14.
//

#import <Foundation/Foundation.h>

#define PERFORMANCE_START(name)\
double startTime##name = [NSDate date].timeIntervalSince1970;\
HHNetPerformance* perf = [HHNetPerformance new];\
perf.reachability = [HHNetHelper getNetworkType];\


#define PERFORMANCE_END(name)\
double endTime##name = [NSDate date].timeIntervalSince1970;\
NSLog(@"%s, %.3lf seconds", #name, endTime##name-startTime##name);\

#define NET_PERFORMANCE_LOG(name, reqObj)\
perf.path = reqObj.path;\
perf.method = reqObj.method;\
perf.responseCode = reqObj.responseCode;\
perf.calledDate = reqObj.calledDate;\
perf.reqSuccess = reqObj.reqSuccess;\
perf.requestHeaders = reqObj.requestHeaders;\
perf.duration = endTime##name-startTime##name;\
if (error != nil) {\
perf.error = [NSString stringWithFormat:@"%@ | %@",error.userInfo[@"NSLocalizedDescription"], [error.userInfo[@"NSUnderlyingError"] localizedDescription]];\
}\
[perf saveToDB];

NS_ASSUME_NONNULL_BEGIN

@interface HHDebug : NSObject
+(void)openDebugMode:(BOOL)flag;
+(BOOL)currentDebugMode;
+ (NSString *)platform;
+(bool)deleteDirectory:(NSString*)path;
+(bool)deleteFilesInDirectory:(NSString*)path;
+(long long) fileSize:(NSString*) filePath;
+(void)listDirectory:(NSString*)path;
+(UIViewController*)getCorrespondController:(UIView*)view;
+(NSArray *)listFileAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
