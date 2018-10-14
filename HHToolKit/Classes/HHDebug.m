//
//  HHDebug.m
//  FMDB
//
//  Created by weyl on 2018/10/14.
//

#import "HHDebug.h"
#import <UIKit/UIKit.h>
@implementation HHDebug
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
