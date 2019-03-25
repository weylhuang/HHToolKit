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
        NSLog(@"%@",file);
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
