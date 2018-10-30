

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ContainerStyle) {
    // bit 0 & 1
    ContainerStyleLeftAlign = 0x0,
    ContainerStyleCenterXAlign = 0x1,
    ContainerStyleRightAlign =0x2,
    // bit 2 & 3
    ContainerStyleTopAlign = 0x00,
    ContainerStyleCenterYAlign = 0x04,
    ContainerStyleBottomAlign = 0x08,
    // bit 4 & 5
    ContainerStyleWidthEqual = 0x00,
    ContainerStyleWidthAny = 0x10,
    ContainerStyleWidthGreater = 0x20,
    // bit 6 & 7
    ContainerStyleHeightEqual = 0x00,
    ContainerStyleHeightAny = 0x40,
    ContainerStyleHeightGreater = 0x80,
    
    // short cut
    ContainerStyleCenterAlign = ContainerStyleCenterYAlign | ContainerStyleCenterXAlign,
};

@interface UIView (HHToolKit)

+(UIView*)hh_horizontalLinearLayoutWith:(NSArray*)viewArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip;
+(UIView*)hh_horizontalGroupWith:(NSArray*)viewArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip weightArr:(NSArray*)weightArr;

+(UIView*)hh_horizontalGroupFullScreenForIOS7:(NSArray*)controlArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip weightArr:(NSArray*)weightArr;

-(UIView*)hh_addSubviewsWithVerticalLayout:(NSArray*)controlArr;

-(UIView*)hh_addSubviewsWithVerticalLayout:(NSArray*)viewArr offsets:(NSArray*)offsetArr;

-(UIView*)hh_wrapperWithStyle:(ContainerStyle)style;

-(UIView*)hh_wrapperWithEdgeInsets:(UIEdgeInsets)insets;

-(UIView*)hh_wrapper;

-(UIView*)hh_wrapperVertical;
-(UIView*)hh_wrapperHorizontal;

-(UIButton*)hh_wrapperWithButton;

-(UIScrollView*)hh_wrapperWithHorizontalScrollView;

-(UIScrollView*)hh_wrapperWithScrollView;

-(UIView*)hh_withHeight:(double)height;
-(UIView*)hh_withWidth:(double)width;

-(UIView*)hh_withSize:(CGSize)size;

-(UIView*)hh_withBackgroundColor:(UIColor*)color;

-(UIView*)hh_withBorderWidth:(double)width color:(UIColor*)color;

-(UIView*)hh_withCornerRadius:(double)radius;
-(UIView*)hh_withGradientBackgroundColor:(CGRect)rect colors:(NSArray*)colors;

-(UITableViewCell*)hh_seperateLineWithEdgeInsets:(UIEdgeInsets)edgeInsets;
-(UITableViewCell*)hh_withFullSeperateLine;
+(UIView*)hh_commonHeaderBackground:(CGSize)size;
+ (UIView *)hh_topWindow;
-(UIViewController*)hh_correspondController;

@end
