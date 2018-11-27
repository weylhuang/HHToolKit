//
//  NSDate+HHToolKit.m
//  FMDB
//
//  Created by weyl on 2018/11/27.
//

#import "NSDate+HHToolKit.h"

@implementation NSDate (HHToolKit)

-(NSInteger)milliSecond{
    return (NSInteger)([self timeIntervalSince1970] * 1000);
}


@end
