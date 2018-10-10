
#import "NSString+HHToolKit.h"

@implementation NSString (HHToolKit)

- (id)hh_JSONValue
{
    NSData *data= [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments||NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"[%@]", error.localizedDescription);
        return nil;
    }else{
        return jsonObject;
    }
    
}



@end
