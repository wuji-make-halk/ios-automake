//
//  FRTipsViewController.m
//  CZJKBand
//
//  Created by 张志鹏 on 16/7/4.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "FRTipsViewController.h"
#import "UIView+Frame.h"

@interface FRTipsViewController ()

@property (nonatomic, strong) UIImageView *tipView;
@property (nonatomic, strong) UIButton *btnSetting;
@property (nonatomic, strong) UIButton *btnGotIt;

@end

@implementation FRTipsViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setHidden:YES];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tipView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    NSString *imageStr = [NSString stringWithFormat:@"ANCS_TIP%ld",(long)_tipIndex];
//    [self.tipView setImage:[UIImage imageNamed:NSLocalizedString(imageStr, nil)]];
    self.tipView.image=[UIImage imageNamed:NSLocalizedString(imageStr, nil)];
    [self.view addSubview:self.tipView];
    
    CGFloat btnWidth = 110;
    CGFloat xOffset1 = 0;
    CGFloat yOffset1 = CGRectGetHeight(self.view.frame) / 1.4;
    //CGFloat xOffset2 = (CGRectGetWidth(self.view.frame) - btnWidth) / 2.0;
    
    if(_tipIndex == 1){
        xOffset1 = (CGRectGetWidth(self.view.frame) - btnWidth) / 2.0;
    }else{
        yOffset1 = CGRectGetHeight(self.view.frame) / 1.2 + 10;
        
        xOffset1 = CGRectGetWidth(self.view.frame) - 40 - btnWidth;
        
        self.btnSetting = [[UIButton alloc] initWithFrame:CGRectMake(40, yOffset1, btnWidth, 35)];
        [self.btnSetting setBackgroundColor:[UIColor clearColor]];
        self.btnSetting.layer.borderWidth = 1;
        self.btnSetting.layer.borderColor = [UIColor whiteColor].CGColor;
        self.btnSetting.layer.cornerRadius = 5;
        [self.btnSetting addTarget:self action:@selector(onClickedSetting:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.btnSetting setTitle:NSLocalizedString(@"ANCS_Setting_Title", nil) forState:UIControlStateNormal];
        
//        [self.view addSubview:self.btnSetting];
    }
    
    self.btnGotIt = [[UIButton alloc] initWithFrame:CGRectMake((self.view.width-btnWidth)/2, yOffset1, btnWidth, 35)];
    [self.btnGotIt setBackgroundColor:[UIColor clearColor]];
    self.btnGotIt.layer.borderWidth = 1;
    self.btnGotIt.layer.cornerRadius = 5;
    self.btnGotIt.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.btnGotIt addTarget:self action:@selector(onClickedGotIt:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnGotIt setTitle:NSLocalizedString(@"Got_It_Title", nil) forState:UIControlStateNormal];
    
    [self.view addSubview:self.btnGotIt];
    
}

- (void)onClickedSetting:(id)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(DidClickedTipButton:)]){
        [self.delegate DidClickedTipButton:1];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)onClickedGotIt:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
