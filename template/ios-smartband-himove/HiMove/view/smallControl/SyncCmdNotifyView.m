//
//  SyncCmdNotifyView.m
//  SXRBand
//
//  Created by qf on 16/4/12.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "SyncCmdNotifyView.h"
#import "IRKCommonData.h"

@interface SyncCmdNotifyView()
@property(nonatomic, strong)UIButton* btn_back;
@property(nonatomic, strong)UILabel* tip1;
@property(nonatomic, strong)IRKCommonData* commondata;
@end

@implementation SyncCmdNotifyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.commondata = [IRKCommonData SharedInstance];
        
        self.tip1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, CGRectGetWidth(self.frame)-20, CGRectGetHeight(self.frame)*0.5)];
        self.tip1.textColor = [UIColor whiteColor];
        self.tip1.numberOfLines = 0;
        self.tip1.textAlignment = NSTextAlignmentCenter;
        self.tip1.font = [self.commondata getFontbySize:18 isBold:NO];
        self.tip1.text = @"";
        [self addSubview:self.tip1];
        
        
        self.btn_back = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.frame)-50, 20, 30, 30)];
        self.btn_back.layer.cornerRadius = 15;
        self.btn_back.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.btn_back.layer.borderWidth = 2;
        self.btn_back.clipsToBounds = YES;
        self.btn_back.backgroundColor = [UIColor redColor];
        [self.btn_back setTitle:@"X" forState:UIControlStateNormal];
        [self.btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        self.btn_back.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [self.btn_back addTarget:self action:@selector(onClickBack) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btn_back];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectTimeout:) name:notify_key_connect_timeout object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishModeset:) name:notify_key_did_finish_modeset object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailedModeset:) name:notify_key_did_finish_modeset_err object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinish:) name:notify_key_did_finish_send_cmd object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailed:) name:notify_key_did_finish_send_cmd_err object:nil];
        
    }
    return self;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)onClickBack{
    if (self.delegate) {
        [self.delegate SyncCmdNotifyViewClickBackBtn:self];

    }
}

-(void)ShowString:(NSString *)str{
    self.tip1.text = str;
}

-(void)didConnectTimeout:(NSNotification*)notify{

    self.tip1.text = NSLocalizedString(@"sync_connecterr", nil);
}
-(void)didFinish:(NSNotification*)notify{

    self.tip1.text = NSLocalizedString(@"ModeSet_Finish", nil);
}
-(void)didFinishModeset:(NSNotification*)notify{
    self.tip1.text = NSLocalizedString(@"ModeSet_Finish", nil);
}
-(void)didFailedModeset:(NSNotification*)notify{
    self.tip1.text = NSLocalizedString(@"ModeSet_Fail", nil);
}

-(void)didFailed:(NSNotification*)notify{
    self.tip1.text = NSLocalizedString(@"ModeSet_Fail", nil);
}
-(void)didSyncKickoff:(NSNotification*)notify{
    self.tip1.text = NSLocalizedString(@"Sync_connected", nil);
}
-(void)didSetPersonInfo:(NSNotification*)notify{
    self.tip1.text = NSLocalizedString(@"Sync_setpersoninfo", nil);
}

@end
