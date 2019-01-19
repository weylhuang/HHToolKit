

#import "UILabel+HHToolKit.h"

@implementation UILabel (HHToolKit)

-(UILabel*)hh_withText:(NSString*)text color:(UIColor*)color font:(UIFont*)font{
    self.text = text;
    self.textColor = color;
    self.font = font;
    return self;
}

@end
