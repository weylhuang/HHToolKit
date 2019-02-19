
#import "NSObject+HHToolKit.h"

@implementation NSObject (HHToolKit)
- (NSString *)hh_JSONRepresentation
{
    if (![NSJSONSerialization isValidJSONObject:self]) {

        return nil;
    }
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:nil error:&error];
    if (error) {
        return nil;
    }else
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)hh_JSONPrettyRepresentation
{
    if (![NSJSONSerialization isValidJSONObject:self]) {
        
        return nil;
    }
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return nil;
    }else
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
