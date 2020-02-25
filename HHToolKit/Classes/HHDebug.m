//
//  HHDebug.m
//  FMDB
//
//  Created by weyl on 2018/10/14.
//

#import "HHDebug.h"
#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
@implementation HHDebug
static BOOL debugMode = FALSE;
+(void)openDebugMode:(BOOL)flag{
    debugMode = flag;
}


+(BOOL)currentDebugMode{
    return debugMode;
}

+ (NSString *)platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    if (machine == NULL) {
        return nil;
    }
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+(bool)deleteDirectory:(NSString*)path{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:path error:&error]) {
        BOOL isDir;
        NSString* absolutePath = [path stringByAppendingPathComponent:file];
        [[NSFileManager defaultManager] fileExistsAtPath:absolutePath isDirectory:&isDir];
        BOOL success = false;
        if (isDir) {
            success = [HHDebug deleteDirectory:absolutePath];
            NSLog(@"HHDebug: delete dir %@ %d",absolutePath, success);
        }else{
            success = [fm removeItemAtPath:absolutePath error:&error];
            //            NSLog(@"HHDebug: delete file %@ %d",absolutePath, success);
        }
        
        if (!success) {
            //            NSLog(@"HHDebug: delete file %@ fail", file);
            return false;
        }
    }
    return true;
}

+(bool)deleteFilesInDirectory:(NSString*)path{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:path error:&error]) {
        BOOL isDir;
        NSString* absolutePath = [path stringByAppendingPathComponent:file];
        [[NSFileManager defaultManager] fileExistsAtPath:absolutePath isDirectory:&isDir];
        if (!isDir){
            BOOL success = [fm removeItemAtPath:absolutePath error:&error];
            if (!success || error != nil) {
                NSLog(@"HHDebug: delete file %@ fail, reason: %@", file, error.debugDescription);
                return false;
            }
        }
    }
    return true;
}


+(long long) fileSize:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }else{
        return 0;
    }
}

+(void)listDirectory:(NSString*)path{
    NSArray* arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSLog(@"files under directory %@", path);
    for (NSString* file in arr) {
        NSLog(@"%@, size: %llu",file, [self fileSize:[path stringByAppendingPathComponent:file]]);
    }
}

+(UIViewController*)getCorrespondController:(UIView*)view{
    id responder = view.nextResponder;
    while (![responder isKindOfClass: [UIViewController class]] && ![responder isKindOfClass: [UIWindow class]])
    {
        responder = [responder nextResponder];
    }
    if ([responder isKindOfClass: [UIViewController class]])
    {
        return responder;
    }else{
        return nil;
    }
}

+(NSArray *)listFileAtPath:(NSString *)path
{
    NSLog(@"===================");
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (NSObject* file in directoryContent) {
        NSLog(@"%@", file);
    }
    return directoryContent;
}
@end
