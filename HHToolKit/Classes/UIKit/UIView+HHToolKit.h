

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

- (UIView*)hh_verticalLayoutSubviews:(NSArray*)controlArr;
-(UIView*)hh_verticalLayoutSubviews:(NSArray*)controlArr offsets:(NSArray*)offsetArr;
+(UIView*)hh_horizontalLayoutSubviews:(NSArray*)controlArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip weightArr:(NSArray*)weightArr;
+(UIView*)hh_horizontalLinearLayoutWith:(NSArray*)viewArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip;

-(UIView*)hh_containerWithStyle:(ContainerStyle)style;
-(UIView*)hh_containerWithEdgeInsets:(UIEdgeInsets)insets;
-(UIView*)hh_container;
-(UIView*)hh_containerVertical;
-(UIView*)hh_containerHorizontal;
-(UIScrollView*)hh_containerHorizontalScrollView;
-(UIScrollView*)hh_containerVerticalScrollView;

-(UIView*)hh_withHeight:(double)height;
-(UIView*)hh_withWidth:(double)width;
-(UIView*)hh_withSize:(CGSize)size;


@end

@interface UIView (HHAppearance)

-(UIView*)hh_withBackgroundColor:(UIColor*)color;
-(UIView*)hh_withBorderWidth:(double)width color:(UIColor*)color;
-(UIView*)hh_withCornerRadius:(double)radius;
-(UIView*)hh_withGradientBackgroundColor:(CGRect)rect colors:(NSArray*)colors;
@end

@interface UIView (HHHelper)
-(UIViewController*)hh_correspondController;
@end
