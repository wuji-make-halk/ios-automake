//
//  SXRUsermanualViewController.m
//  SXRBand
//
//  Created by qf on 14-7-24.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "SXRUsermanualViewController.h"
#import "IRKCommonData.h"
@interface SXRUsermanualViewController ()
@property (nonatomic, strong) IRKCommonData* commondata;
@property (nonatomic, strong) UIWebView* webview;
@end

@implementation SXRUsermanualViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor =[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
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
    label.text=NSLocalizedString(@"UserManual_Title", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}
-(void)initcontrol{
//    self.view.backgroundColor=[UIColor whiteColor];
    self.webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-65)];
    [self.view addSubview:self.webview];
    NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    NSString *filePath = @"";
    NSString *productCode = [bi objectForKey:BONGINFO_KEY_PRODUCTCODE];
//    NSString *versionCode = [bi objectForKey:BONGINFO_KEY_VERSIONCODE];
    if(productCode == nil)
    {
        UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alerview show];
    }
    else
    {
        filePath = [NSString stringWithFormat:USERMANUAL_URL,[productCode lowercaseString],NSLocalizedString(@"language", nil)];
    }

    NSURL *url = [NSURL URLWithString:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
}

-(void)onClickBack:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
