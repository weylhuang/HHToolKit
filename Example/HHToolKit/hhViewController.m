//
//  hhViewController.m
//  HHToolKit
//
//  Created by weylhuang on 10/10/2018.
//  Copyright (c) 2018 weylhuang. All rights reserved.
//

#import "hhViewController.h"
#import "HHToolKit.h"
#import <Masonry/Masonry.h>
@interface hhViewController ()

@end

@implementation hhViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UILabel* l = [UILabel new];
    l.text = @"aaaaaaaa";
    ;
    
    UILabel* l2 = [UILabel new];
    l2.text = @"bbbbbbbb";
    l2.backgroundColor = [UIColor redColor];
    
    UIView* v = [[UIView new] hh_verticalLayoutSubviews:@[[l hh_withSize:CGSizeMake(100, 30)],[l2 hh_withSize:CGSizeMake(100, 30)]]];
    
    [self.view addSubview:v];
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
