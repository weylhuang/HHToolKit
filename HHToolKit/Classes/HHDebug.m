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


+(void)redirectNSlogToDocumentFolder
{
    NSString *logFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"ios.log"];
    [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:nil];
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stderr);
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
