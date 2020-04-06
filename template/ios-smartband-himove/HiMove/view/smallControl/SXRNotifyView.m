//
//  SXRNotifyView.m
//  SXRBand
//
//  Created by qf on 14-8-14.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "SXRNotifyView.h"

@implementation SXRNotifyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.commondata = [IRKCommonData SharedInstance];
        self.fontsize = 12;
        
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        
        self.tip = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height/3.0, frame.size.width, self.fontsize)];
        self.tip.textAlignment = NSTextAlignmentCenter;
        self.tip.textColor = [UIColor whiteColor];
        self.tip.font = [UIFont fontWithName:@"Heiti SC" size:self.fontsize];
        self.tip.text = NSLocalizedString(@"ModeSet_start", nil);
        [self addSubview:self.tip];
        
        
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width*0.2, frame.size.height*0.6, frame.size.width*0.6, frame.size.height*0.3)];
        self.button.layer.cornerRadius = self.button.frame.size.height/4.0;
        self.button.backgroundColor = [UIColor greenColor];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.button setTitle:@"OK" forState:UIControlStateNormal];
        self.button.hidden = YES;
        [self.button addTarget:self action:@selector(onclickOK) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectTimeout:) name:notify_key_connect_timeout object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishModeset:) name:notify_key_did_finish_modeset object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailedModeset:) name:notify_key_did_finish_modeset_err object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinish:) name:notify_key_did_finish_send_cmd object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailed:) name:notify_key_did_finish_send_cmd_err object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSyncKickoff:) name:notify_band_has_kickoff object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetPersonInfo:) name:notify_key_start_set_personinfo object:nil];
        
        self.layer.cornerRadius = 10;
        
        
    }
    return self;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)didConnectTimeout:(NSNotification*)notify{
    if ([self delegate]) {
        self.tip.text = [self.delegate SXRNotifyView:self stringByAction:notify_key_connect_timeout];
    }else{
        self.tip.text = NSLocalizedString(@"sync_connecterr", nil);
    }
    self.button.hidden = NO;
}
-(void)didFinish:(NSNotification*)notify{
    if ([self delegate]) {
        self.tip.text = [self.delegate SXRNotifyView:self stringByAction:notify_key_did_finish_send_cmd];
    }else{
        self.tip.text = NSLocalizedString(@"ModeSet_Finish", nil);
    }
    self.button.hidden = NO;
}
-(void)didFinishModeset:(NSNotification*)notify{
    if ([self delegate]) {
        self.tip.text = [self.delegate SXRNotifyView:self stringByAction:notify_key_did_finish_modeset];
    }else{
        self.tip.text = NSLocalizedString(@"ModeSet_Finish", nil);
    }
    self.button.hidden = NO;
    
}
-(void)didFailedModeset:(NSNotification*)notify{
    if ([self delegate]) {
        self.tip.text = [self.delegate SXRNotifyView:self stringByAction:notify_key_did_finish_modeset_err];
    }else{
        self.tip.text = NSLocalizedString(@"ModeSet_Fail", nil);
    }
    self.button.hidden = NO;
}

-(void)didFailed:(NSNotification*)notify{
    if ([self delegate]) {
        self.tip.text = [self.delegate SXRNotifyView:self stringByAction:notify_key_did_finish_send_cmd_err];
    }else{
        self.tip.text = NSLocalizedString(@"ModeSet_Fail", nil);
    }
    self.button.hidden = NO;
}
-(void)didSyncKickoff:(NSNotification*)notify{
    if ([self delegate]) {
        self.tip.text = [self.delegate SXRNotifyView:self stringByAction:notify_band_has_kickoff];
    }else{
        self.tip.text = NSLocalizedString(@"Sync_connected", nil);
    }
}
-(void)didSetPersonInfo:(NSNotification*)notify{
    if ([self delegate]) {
        self.tip.text = [self.delegate SXRNotifyView:self stringByAction:notify_key_start_set_personinfo];
    }else{
        self.tip.text = NSLocalizedString(@"Sync_setpersoninfo", nil);
    }
}

-(void)onclickOK{
    [(UIView*)self dismissPresentingPopup];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
