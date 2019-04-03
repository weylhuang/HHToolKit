//
//  HHDebug.h
//  FMDB
//
//  Created by weyl on 2018/10/14.
//

#import <Foundation/Foundation.h>

#define PERFORMANCE_START(name)\
double startTime##name = [NSDate date].timeIntervalSince1970;\

#define PERFORMANCE_END(name)\
double endTime##name = [NSDate date].timeIntervalSince1970;\
NSLog(@"%s, %.3lf seconds", #name, endTime##name-startTime##name);\

#define NET_PERFORMANCE_LOG(name, reqObj)\
HHNetPerformance* perf = [HHNetPerformance new];\
perf.path = reqObj.path;\
perf.method = reqObj.method;\
perf.requestHeaders = reqObj.requestHeaders;\
perf.requestTime = endTime##name-startTime##name;\
[perf saveToDB];

NS_ASSUME_NONNULL_BEGIN

@interface HHDebug : NSObject
+(void)openDebugMode:(BOOL)flag;
+(BOOL)currentDebugMode;
+ (NSString *)platform;
+(long long) fileSize:(NSString*) filePath;
+(void)listDirectory:(NSString*)path;
+(UIViewController*)getCorrespondController:(UIView*)view;
+(NSArray *)listFileAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
