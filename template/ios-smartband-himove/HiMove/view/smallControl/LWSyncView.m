//
//  LWSyncView.m
//  Lovewell
//
//  Created by qf on 14-8-6.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//
// 已经不再使用此页面

#import "LWSyncView.h"

@implementation LWSyncView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.commondata = [IRKCommonData SharedInstance];
        self.fontsize = 12;
//#ifdef CUSTOM_API2
        NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
        double lasttime = [[bi objectForKey:BONGINFO_KEY_LASTSYNCTIME] doubleValue];
        self.lasttime = lasttime;
        double offset = [[NSDate date] timeIntervalSince1970]-self.lasttime;
        
        if (offset>8*24*60*60) {
            NSDate* dayago = [NSDate dateWithTimeIntervalSinceNow:-HJT_MAX_STORE_DATA_TIME];
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
            [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            [format setTimeZone:[NSTimeZone systemTimeZone]];
            
            [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
            
            NSString* lastday = [format stringFromDate:dayago];
            NSDate* lastdate = [format dateFromString:lastday];
            self.lasttime = [lastdate timeIntervalSince1970];
        }
        self.totaltime = [[NSDate date] timeIntervalSince1970] - self.lasttime;
//#else
//        self.lasttime = self.commondata.lastReadDataTime;
//        self.totaltime = [[NSDate date] timeIntervalSince1970] - self.commondata.lastReadDataTime;
//#endif
//        self.lasttime = self.commondata.lastReadDataTime;
//        self.totaltime = [[NSDate date] timeIntervalSince1970] - self.commondata.lastReadDataTime;
        
        
 //       self.backgroundColor = [UIColor blackColor];
        self.progressbar = [[IRKProgressBar alloc] initWithFrame:CGRectMake(50, 150, CGRectGetWidth(self.frame)-100, 20)];
        self.progressbar.delegate = self;
        self.progressbar.delegate = self;
        [self addSubview:self.progressbar];
        self.label_rate = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.progressbar.frame)+10, CGRectGetWidth(self.frame), 40)];
        self.label_rate.textColor = [UIColor whiteColor];
        self.label_rate.textAlignment = NSTextAlignmentCenter;
        self.label_rate.font = [self.commondata getFontbySize:28 isBold:NO];
        self.label_rate.text = [NSString stringWithFormat:@"0%%"];
        [self.progressbar reload];
        [self.progressbar setProgress:0 animated:YES];
        [self addSubview:self.label_rate];
/*
        self.progressbar = [[IRKProgressBar alloc] initWithFrame:CGRectMake(frame.size.width*0.1, frame.size.height*0.2, frame.size.width*0.8, 15)];
        self.progressbar.delegate = self;
        self.progressbar.conerRadius = 15/2.0;
        self.progressbar.animationtime = 0.2;
        [self.progressbar setClipsToBounds:NO];
        [self addSubview:self.progressbar];
        [self.progressbar reload];
 */
        
        self.tip = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.label_rate.frame)+10, frame.size.width, self.fontsize)];
        self.tip.textAlignment = NSTextAlignmentCenter;
        self.tip.textColor = [UIColor whiteColor];
        self.tip.font = [self.commondata getFontbySize:self.fontsize isBold:NO];
        self.tip.text = NSLocalizedString(@"Sync_tip", nil);
        self.tip.adjustsFontSizeToFitWidth = YES;
        self.tip.minimumScaleFactor = 0.5;
        self.tip.numberOfLines = 0;
        [self addSubview:self.tip];
        
        self.timelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tip.frame)+10, frame.size.width, self.fontsize)];
        self.timelabel.textAlignment = NSTextAlignmentCenter;
        self.timelabel.textColor = [UIColor whiteColor];
        
        self.timelabel.font = [self.commondata getFontbySize:self.fontsize isBold:NO];
        self.timelabel.text = [self maketimestr];
        [self addSubview:self.timelabel];
        
        /*
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width*0.2, frame.size.height*0.75, frame.size.width*0.6, frame.size.height*0.2)];
        self.button.layer.cornerRadius = self.button.frame.size.height/4.0;
        self.button.backgroundColor = [UIColor greenColor];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.button setTitle:@"OK" forState:UIControlStateNormal];
        self.button.hidden = YES;
        [self.button addTarget:self action:@selector(onclickOK) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
         */
        
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

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeviceSync:) name:notify_key_did_recv_device_sync_data object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectTimeout:) name:notify_key_connect_timeout object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinish:) name:notify_key_did_finish_device_sync object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSyncKickoff:) name:notify_band_has_kickoff object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetPersonInfo:) name:notify_key_start_set_personinfo object:nil];
        
        self.layer.cornerRadius = 0;
        
        if (offset<10*60) {
            [self.progressbar setProgress:1];
        }
        
    }
    return self;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(NSString*)maketimestr{
//#ifdef CUSTOM_API2
    NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    double lasttime = [[bi objectForKey:BONGINFO_KEY_LASTSYNCTIME] doubleValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:lasttime];
    [date dateByAddingTimeInterval:[NSTimeZone systemTimeZone].secondsFromGMT];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    
    if(self.commondata.is24time)
    {
        format.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    else
    {
        format.dateFormat = @"yyyy-MM-dd hh:mm a";
    }
    
    return [NSString stringWithFormat:@"%@",[format stringFromDate:date]];
//#else
//    NSDate* date = [NSDate dateWithTimeIntervalSince1970:self.commondata.lastReadDataTime];
//    [date dateByAddingTimeInterval:[NSTimeZone systemTimeZone].secondsFromGMT];
//    NSDateFormatter* format = [[NSDateFormatter alloc] init];
//    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    [format setTimeZone:[NSTimeZone systemTimeZone]];
//    
//    format.dateFormat = @"yyyy-MM-dd HH:mm";
//    
//    return [NSString stringWithFormat:@"%@",[format stringFromDate:date]];
//#endif

}
-(CGFloat)getProgress{
//#ifdef CUSTOM_API2
    NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    double lasttime = [[bi objectForKey:BONGINFO_KEY_LASTSYNCTIME] doubleValue];
    double now = lasttime - self.lasttime;
//#else
//    double now = self.commondata.lastReadDataTime - self.lasttime;
//#endif
    float progress =  now/(self.totaltime*1.0);
    if (progress >1) {
        progress = 1;
    }
    if (progress<0){
        progress = 0;
    }
    return progress;
    
}

-(void)didDeviceSync:(NSNotification*)notify{
    self.tip.text = NSLocalizedString(@"Sync_syncdata", nil);
    self.timelabel.text = [self maketimestr];
    [self.progressbar setProgress:[self getProgress] animated:YES];
    self.label_rate.text = [NSString stringWithFormat:@"%.0f%%",[self getProgress]*100];
    
}
-(void)didConnectTimeout:(NSNotification*)notify{
    self.tip.text = NSLocalizedString(@"sync_connecterr", nil);
    self.timelabel.text = [self maketimestr];
//    [self onClickBack];
    [(UIView*)self dismissPresentingPopup];

//    self.button.hidden = NO;
}
-(void)didFinish:(NSNotification*)notify{
    NSLog(@"didFinish!!!!!!!!!!!");
    self.tip.text = NSLocalizedString(@"Sync_finish", nil);
    self.timelabel.text = [self maketimestr];
//    [self.progressbar setProgress:1 animated:NO];
    self.label_rate.text = [NSString stringWithFormat:@"100%%"];

//    [self onClickBack];
//    self.button.hidden = NO;
}
-(void)didSyncKickoff:(NSNotification*)notify{
    self.tip.text = NSLocalizedString(@"Sync_connected", nil);
    self.timelabel.text = [self maketimestr];
    [self.progressbar setProgress:0 animated:NO];
    self.label_rate.text = @"0%";
}
-(void)didSetPersonInfo:(NSNotification*)notify{
    self.tip.text = NSLocalizedString(@"Sync_setpersoninfo", nil);
}


-(UIColor*)getBarColor:(IRKProgressBar*)Progress withProgress:(CGFloat)progress{
    return [UIColor greenColor];
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
-(void)onClickBack{
    [(UIView*)self dismissPresentingPopup];

//    [self.delegate LWSyncViewClickClose:self];
}

@end
