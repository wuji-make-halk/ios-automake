//
//  HMTabBarController.m
//  CZJKBand
//
//  Created by 周凯伦 on 17/3/15.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "HMTabBarController.h"
#import "HMHomeViewController.h"
#import "HMPlayViewController.h"
#import "HMChartViewController.h"
#import "HMSetViewController.h"
#import "HMTabbarButton.h"
@interface HMTabBarController ()
@property(nonatomic,strong) UIImageView *tabBarView;
@property(nonatomic,strong) HMTabbarButton *presentBtn;
@end

@implementation HMTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tabBar setHidden:YES];
    UINavigationController *c1=[[UINavigationController alloc]initWithRootViewController:[HMHomeViewController new]];
    UINavigationController *c2=[[UINavigationController alloc]initWithRootViewController:[HMPlayViewController new]];
    UINavigationController *c3=[[UINavigationController alloc]initWithRootViewController:[HMChartViewController new]];
    UINavigationController *c4=[[UINavigationController alloc]initWithRootViewController:[HMSetViewController new]];
    self.viewControllers=@[c1,c2,c3,c4];
    
    self.tabBarView=[[UIImageView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-49, self.view.frame.size.width, 49)];
    self.tabBarView.backgroundColor=[UIColor whiteColor];
    self.tabBarView.userInteractionEnabled = YES;
    [self.view addSubview:self.tabBarView];
    
    CGFloat width=self.tabBarView.frame.size.width/4.0;
    NSMutableArray *btnarray=[[NSMutableArray alloc]init];
    for (int i=0; i<4; i++) {
        HMTabbarButton *tabBtn=[[HMTabbarButton alloc]initWithFrame:CGRectMake(i*width, 0, width, 49)];
        tabBtn.imageView.contentMode=UIViewContentModeScaleAspectFit;
        NSString *key=[NSString stringWithFormat:@"Tabbar_Title_%d",i];
        [tabBtn setTitle:NSLocalizedString(key, nil) forState:UIControlStateNormal];
        tabBtn.titleLabel.font=[UIFont systemFontOfSize:11];
        tabBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
        [tabBtn setTitleColor:[UIColor colorWithRed:152/255.0 green:152/255.0 blue:152/255.0 alpha:1] forState:UIControlStateNormal];
        [tabBtn setTitleColor:[UIColor colorWithRed:56/255.0 green:164/255.0 blue:232/255.0 alpha:1] forState:UIControlStateSelected];
        [tabBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"tabbar_%d_0",i]] forState:UIControlStateNormal];
        [tabBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"tabbar_%d_1",i]] forState:UIControlStateSelected];
        [tabBtn addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        tabBtn.tag=i;
        [self.tabBarView addSubview:tabBtn];
        [btnarray addObject:tabBtn];
    }
    [self onClickBtn:btnarray[0]];
}
-(void)onClickBtn:(HMTabbarButton*)sender{
    if (self.presentBtn==sender) {
        return;
    }
    self.selectedIndex = sender.tag;
    UIViewController* view = [self.viewControllers objectAtIndex:self.selectedIndex];
    if ([view isKindOfClass:[UINavigationController class]]) {
        UINavigationController* c = (UINavigationController*)view;
        [c popToRootViewControllerAnimated:YES];
    }
    sender.selected = YES;
    self.presentBtn.selected = NO;
    self.presentBtn = sender;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
