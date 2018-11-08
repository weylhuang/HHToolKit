#import "UIView+HHToolKit.h"
#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import <Masonry/Masonry.h>
#import "HHToolKit.h"
@implementation UIView (HHLayout)

- (UIView*)hh_verticalLayoutSubviews:(NSArray*)controlArr {
    NSMutableArray* offsetArr = [NSMutableArray array];
    for (int i=0; i<controlArr.count; i++) {
        [offsetArr addObject:@0];
    }
    return [self hh_verticalLayoutSubviews:controlArr offsets:offsetArr];
}

-(UIView*)hh_verticalLayoutSubviews:(NSArray*)controlArr offsets:(NSArray*)offsetArr {
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger n = controlArr.count;
    if (n > 0) {
        UIView* lastView = controlArr[0];
        for (int i=0; i<n; i++) {
            UIView* v = controlArr[i];
            [self addSubview:v];
            double offset = [offsetArr[i] doubleValue];
            
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                if (i==0) {
                    make.top.equalTo(self).offset(offset);
                }else{
                    
                    make.top.equalTo(lastView.mas_bottom).offset(offset);
                }
                if (i==n-1){
                    make.bottom.equalTo(self);
                }
            }];
            
            lastView = v;
        }
    }
    
    
    return self;
}

+(UIView*)hh_horizontalLayoutSubviews:(NSArray*)controlArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip weightArr:(NSArray*)weightArr{
    
    UIView* ret = [[UIView alloc] init];
    UIView* lastView = controlArr[0];
    [ret addSubview:lastView];
    [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.height.equalTo(ret);
    }];
    
    double vWidth = [weightArr[0] doubleValue];
    
    for (int i=1; i<controlArr.count; i++) {
        double proportion = [weightArr[i] doubleValue] / vWidth;
        UIView* v = controlArr[i];
        [ret addSubview:v];
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lastView.mas_right).offset(ip);
            make.width.equalTo(((UIView*)controlArr[0]).mas_width).multipliedBy(proportion);
            make.height.centerY.equalTo(ret);
        }];
        
        lastView = v;
    }
    
    [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(ret);
    }];
    
    ret = [ret hh_containerWithEdgeInsets:UIEdgeInsetsMake(vp, hp, vp, hp)];
    
    return ret;
}



+(UIView*)hh_horizontalLinearLayoutWith:(NSArray*)viewArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip{
    
    UIView* ret = [[UIView alloc] init];
    
    UIView* lastView = viewArr[0];
    [ret addSubview:lastView];
    [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.height.equalTo(ret);
    }];
    
    for (int i=1; i<viewArr.count; i++) {
        UIView* v = viewArr[i];
        [ret addSubview:v];
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lastView.mas_right).offset(ip);
            make.centerY.height.equalTo(ret);
        }];
        
        lastView = v;
    }
    
    [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(ret);
    }];
    
    ret = [ret hh_containerWithEdgeInsets:UIEdgeInsetsMake(vp, hp, vp, hp)];
    
    return ret;
}


#pragma mark - 松弛wrapper

-(UIView*)hh_containerWithStyle:(ContainerStyle)style{
    UIView* ret = [[UIView alloc] init];
    [ret addSubview:self];
    ret.userInteractionEnabled = NO;
    
    NSInteger horizontalAlign = style & 0x03;
    NSInteger horizontalConstraint = style & 0x30;
    NSInteger verticalAlign = style & 0x0c;
    NSInteger verticalConstraint = style & 0xc0;
    
    switch (horizontalAlign) {
        case ContainerStyleLeftAlign:
        {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(ret);
            }];
            break;
        }
        case ContainerStyleRightAlign:
        {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(ret);
            }];
            break;
        }
        case ContainerStyleCenterXAlign:
        {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(ret);
            }];
            break;
        }
        default:
            break;
    }
    
    switch (horizontalConstraint) {
        case ContainerStyleWidthAny:
        {
            break;
        }
        case ContainerStyleWidthGreater:
        {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.lessThanOrEqualTo(ret);
            }];
            break;
        }
        case ContainerStyleWidthEqual:
        {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(ret);
            }];
            break;
        }
        default:
            break;
    }
    
    switch (verticalAlign) {
        case ContainerStyleTopAlign:
        {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(ret);
            }];
            break;
        }
        case ContainerStyleBottomAlign:
        {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(ret);
            }];
            break;
        }
        case ContainerStyleCenterYAlign:
        {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(ret);
            }];
            break;
        }
        default:
            break;
    }
    
    switch (verticalConstraint) {
        case ContainerStyleHeightAny:
        {
            break;
        }
        case ContainerStyleHeightGreater:
        {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.lessThanOrEqualTo(ret);
            }];
            break;
        }
        case ContainerStyleHeightEqual:
        {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(ret);
            }];
            break;
        }
        default:
            break;
    }
    
    return ret;
}

-(UIView*)hh_containerWithEdgeInsets:(UIEdgeInsets)insets{
    UIView* ret = [[UIView alloc] init];
    [ret addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ret).with.insets(insets);
    }];
    return ret;
}

-(UIView*)hh_container{
    return [self hh_containerWithStyle:ContainerStyleCenterXAlign | ContainerStyleCenterYAlign | ContainerStyleHeightGreater | ContainerStyleWidthGreater];
}


-(UIView*)hh_containerVertical{
    return [self hh_containerWithStyle:ContainerStyleCenterXAlign | ContainerStyleCenterYAlign | ContainerStyleHeightGreater | ContainerStyleWidthEqual];
}

-(UIView*)hh_containerHorizontal{
    return [self hh_containerWithStyle:ContainerStyleCenterXAlign | ContainerStyleCenterYAlign | ContainerStyleHeightEqual | ContainerStyleWidthGreater];
}

-(UIScrollView*)hh_containerHorizontalScrollView{
    UIScrollView* scroll = [[UIScrollView alloc] init];
    scroll.showsVerticalScrollIndicator = NO;
    scroll.bounces = YES;
    
    [scroll addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.height.right.equalTo(scroll);
    }];
    return scroll;
}

-(UIScrollView*)hh_containerVerticalScrollView{
    UIScrollView* scroll = [[UIScrollView alloc] init];
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.bounces = YES;
    
    [scroll addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.bottom.equalTo(scroll);
    }];
    return scroll;
}


-(UIView*)hh_withHeight:(double)height{
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
    }];
    return self;
}

-(UIView*)hh_withWidth:(double)width{
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(width));
    }];
    return self;
}

-(UIView*)hh_withSize:(CGSize)size{
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(size));
    }];
    return self;
}


@end



@implementation UIView (HHAppearance)

-(UIView*)hh_withBackgroundColor:(UIColor*)color{
    self.backgroundColor = color;
    return self;
}

-(UIView*)hh_withBorderWidth:(double)width color:(UIColor*)color{
    self.layer.borderWidth = width;
    self.layer.borderColor = [color CGColor];
    return self;
}

-(UIView*)hh_withCornerRadius:(double)radius{
    self.layer.cornerRadius = radius;
    self.clipsToBounds = YES;
    return self;
}

-(UIView*)hh_withGradientBackgroundColor:(CGRect)rect colors:(NSArray*)colors{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1.0, 0);
    gradientLayer.frame = rect;
    [self.layer addSublayer:gradientLayer];
    return self;
}
-(UIView*)hh_withFullSeperateLine{
    return [self hh_withSeperateLine:UIEdgeInsetsZero];
}

-(UIView*)hh_withSeperateLine:(UIEdgeInsets)edgeInsets{
    UIView* sepLine = [[UIView alloc] init];
    sepLine.backgroundColor = RGB2UIColor(0xe5e5e5);
    [self addSubview:sepLine];
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.height.equalTo(@(.5f));
        make.left.equalTo(@(edgeInsets.left));
        make.right.equalTo(@(-edgeInsets.right));
    }];
    
    return self;
}

@end

@implementation UIView (HHHelper)
-(UIViewController*)hh_correspondController{
    id responder = self.nextResponder;
    while (![responder isKindOfClass: [UIWindow class]] && ![responder isKindOfClass: [UIViewController class]])
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


@end
