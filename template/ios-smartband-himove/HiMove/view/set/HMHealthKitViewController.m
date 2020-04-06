//
//  HMHealthKitViewController.m
//  HiMove
//
//  Created by qf on 2017/9/5.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "HMHealthKitViewController.h"

@interface HMHealthKitViewController ()

@end

@implementation HMHealthKitViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor =[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initNav];
    [self initcontrol];
}
-(void)initNav{
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    UIImageView * backimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 22, 18)];
    backimg.image = [UIImage imageNamed:@"icon_back_white.png"];
    backimg.contentMode = UIViewContentModeScaleAspectFit;
    [btn addSubview:backimg];
    [btn addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectZero];
    label.textColor=[UIColor whiteColor];
    label.text=NSLocalizedString(@"Config_Cell_HealthKit", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}
-(void)onClickBack:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initcontrol{
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*0.7-65-49)];
    imgview.contentMode = UIViewContentModeScaleAspectFit;
    imgview.image = [UIImage imageNamed:@"icon_setting_healthkit_tip.png"];
    [self.view addSubview:imgview];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.1, CGRectGetMaxY(imgview.frame), CGRectGetWidth(self.view.frame)*0.8, CGRectGetHeight(self.view.frame)*0.3)];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    label.text = NSLocalizedString(@"Config_Cell_HealthKit_tip", nil);
    [self.view addSubview:label];
}


@end
