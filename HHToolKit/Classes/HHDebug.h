//
//  HHDebug.h
//  FMDB
//
//  Created by weyl on 2018/10/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HHDebug : NSObject
+(UIViewController*)getCorrespondController:(UIView*)view;
+(NSArray *)listFileAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
