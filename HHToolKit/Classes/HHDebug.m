//
//  HHDebug.m
//  FMDB
//
//  Created by weyl on 2018/10/14.
//

#import "HHDebug.h"
#import <UIKit/UIKit.h>
@implementation HHDebug
static BOOL debugMode = FALSE;
+(void)openDebugMode:(BOOL)flag{
    debugMode = flag;
}


+(BOOL)currentDebugMode{
    return debugMode;
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
