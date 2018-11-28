
#import "NSAttributedString+HHToolKit.h"

@implementation NSAttributedString (HHToolKit)
+(NSAttributedString*)hh_attributedString:(NSString*)string withRegExp:(NSString*)regExp normalColor:(UIColor*)normalColor normalFont:(UIFont*)normalFont highlightColor:(UIColor*)highlightColor highlightFont:(UIFont*)highlightFont{
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:regExp options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray* resultArr = [reg matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    [attributeString addAttribute:NSForegroundColorAttributeName value:normalColor range:NSMakeRange(0, string.length)];
    [attributeString addAttribute:NSFontAttributeName value:normalFont range:NSMakeRange(0, string.length)];
    
    for (NSTextCheckingResult* result in resultArr) {
        [attributeString addAttribute:NSForegroundColorAttributeName value:highlightColor range:result.range];
        [attributeString addAttribute:NSFontAttributeName value:highlightFont range:result.range];
    }
    return attributeString;
}

+(NSAttributedString*)hh_attributedString:(NSString*)string withInfo:(NSArray*)highlightTuples normalColor:(UIColor*)normalColor normalFont:(UIFont*)normalFont{
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributeString addAttribute:NSForegroundColorAttributeName value:normalColor range:NSMakeRange(0, string.length)];
    [attributeString addAttribute:NSFontAttributeName value:normalFont range:NSMakeRange(0, string.length)];
    
    for (HHAttributedStringInfo* info in highlightTuples) {
        NSString* tmp = [info.regPattern stringByReplacingOccurrencesOfString:@"+" withString:@"\\+"];
        
        NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:tmp options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray* resultArr = [reg matchesInString:string options:0 range:NSMakeRange(0, string.length)];
        
        
        for (NSTextCheckingResult* result in resultArr) {
            [attributeString addAttribute:NSForegroundColorAttributeName value:info.hightlightColor range:result.range];
            [attributeString addAttribute:NSFontAttributeName value:info.hightlightFont range:result.range];
        }
    }
    return attributeString;
}

@end
