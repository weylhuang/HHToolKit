
#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>
@interface HHAttributedStringInfo : NSObject
@property (nonatomic, strong) NSString* regPattern;
@property (nonatomic, strong) UIFont* hightlightFont;
@property (nonatomic, strong) UIColor* hightlightColor;

@end


@interface NSAttributedString (HHToolKit)
+(NSAttributedString*)hh_attributedString:(NSString*)string withRegExp:(NSString*)regExp normalColor:(UIColor*)normalColor normalFont:(UIFont*)normalFont highlightColor:(UIColor*)hc highlightFont:(UIFont*)highlightFont;

+(NSAttributedString*)hh_attributedString:(NSString*)string withInfo:(NSArray*)highlightTuples normalColor:(UIColor*)normalColor normalFont:(UIFont*)normalFont;
@end
