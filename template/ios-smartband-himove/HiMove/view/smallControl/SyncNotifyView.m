//
//  SyncNotifyView.m
//  Walknote
//
//  Created by qf on 15/4/21.
//  Copyright (c) 2015年 SXR. All rights reserved.
//

#import "SyncNotifyView.h"
#import "IRKProgressBar.h"

@interface SyncNotifyView()<IRKProgressBarDelegate>
@property(nonatomic, strong)IRKProgressBar* progressbar;
@property(nonatomic, strong)UILabel* label_rate;
@property(nonatomic, strong)UIButton* btn_back;
@property(nonatomic, strong)UILabel* tip1;
@property(nonatomic, strong)UILabel* tip2;
@property(nonatomic, strong)IRKCommonData* commondata;
@property(nonatomic, assign)double lasttime;
@property(nonatomic, assign)double totaltime;

@end

@implementation SyncNotifyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.commondata = [IRKCommonData SharedInstance];
//#ifdef CUSTOM_API2
        NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
        double lasttime;
        NSNumber* nlasttime = [bi objectForKey:BONGINFO_KEY_LASTSYNCTIME];
        if (nlasttime) {
            lasttime = [[bi objectForKey:BONGINFO_KEY_LASTSYNCTIME] doubleValue];
        }else{
//#ifdef CUSTOM_JJT_COMMON
            
            NSDate* dayago = [NSDate dateWithTimeIntervalSinceNow:-24*60*60];
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
            
            NSString* lastday = [format stringFromDate:dayago];
            NSDate* lastdate = [format dateFromString:lastday];
            double tmplast = [lastdate timeIntervalSince1970];
            if (tmplast > self.commondata.lastReadDataTime) {
                lasttime = tmplast;
            }
//#else
//            lasttime = 0;
//#endif

        }
//        double lasttime = [[bi objectForKey:BONGINFO_KEY_LASTSYNCTIME] doubleValue];
        self.lasttime = lasttime;
        double offset = [[NSDate date] timeIntervalSince1970]-self.lasttime;

        if (offset>8*24*60*60) {
            NSDate* dayago = [NSDate dateWithTimeIntervalSinceNow:-HJT_MAX_STORE_DATA_TIME];
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
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
        self.progressbar = [[IRKProgressBar alloc] initWithFrame:CGRectMake(50, 150, CGRectGetWidth(self.frame)-100, 20)];
        self.progressbar.delegate = self;
        self.progressbar.delegate = self;
        [self addSubview:self.progressbar];
        self.label_rate = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.progressbar.frame)+10, CGRectGetWidth(self.frame), 40)];
        self.label_rate.textColor = [UIColor whiteColor];
        self.label_rate.textAlignment = NSTextAlignmentCenter;
        self.label_rate.font = [UIFont systemFontOfSize:28];
        self.label_rate.text = [NSString stringWithFormat:@"0%%"];
        [self.progressbar reload];
        if (offset<10*60) {
            [self.progressbar setProgress:1 animated:YES];
            self.label_rate.text = [NSString stringWithFormat:@"100%%"];
        }else{
            [self.progressbar setProgress:0 animated:YES];
        }
        [self addSubview:self.label_rate];
        
        self.tip1 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.label_rate.frame)+20, CGRectGetWidth(self.frame), 40)];
        self.tip1.textColor = [UIColor whiteColor];
        self.tip1.textAlignment = NSTextAlignmentCenter;
        self.tip1.font = [UIFont systemFontOfSize:24];
        self.tip1.adjustsFontSizeToFitWidth = YES;
        self.tip1.minimumScaleFactor = 0.5;
        self.tip1.text = NSLocalizedString(@"Sync_tip", nil);
        [self addSubview:self.tip1];

        self.tip2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tip1.frame)+20, CGRectGetWidth(self.frame), 30)];
        self.tip2.textColor = [UIColor whiteColor];
        self.tip2.textAlignment = NSTextAlignmentCenter;
        self.tip2.numberOfLines = 2;
        self.tip2.font = [UIFont systemFontOfSize:12];
        self.tip2.text = [self maketimestr];
        [self addSubview:self.tip2];

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectTimeout:) name:notify_key_connect_timeout object:nil];
 //       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinish:) name:notify_key_did_finish_device_sync object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSyncKickoff:) name:notify_band_has_kickoff object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetPersonInfo:) name:notify_key_start_set_personinfo object:nil];
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
    NSDate* date ;
    if (lasttime == 0) {
        date = [NSDate dateWithTimeIntervalSinceNow:-HJT_MAX_STORE_DATA_TIME];
    }else{
        date = [NSDate dateWithTimeIntervalSince1970:lasttime];
    }
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
    self.tip2.text = NSLocalizedString(@"Sync_syncdata", nil);
    self.tip2.text = [self maketimestr];
    [self.progressbar setProgress:[self getProgress] animated:YES];
    self.label_rate.text = [NSString stringWithFormat:@"%.0f%%",[self getProgress]*100];
    
}
-(void)didConnectTimeout:(NSNotification*)notify{
    self.tip1.text = NSLocalizedString(@"sync_connecterr", nil);
    self.tip2.text = [self maketimestr];
    //    [self onClickBack];
    [(UIView*)self dismissPresentingPopup];
    
    //    self.button.hidden = NO;
}

-(void)didSyncKickoff:(NSNotification*)notify{
    self.tip1.text = NSLocalizedString(@"Sync_connected", nil);
}

-(void)refreshSyncProgress:(CGFloat)progress{
    self.label_rate.text = [NSString stringWithFormat:@"%.0f%%",progress*100];
    [self.progressbar setProgress:progress animated:YES];
    
    
}
////////////////////////
-(UIColor*)getBarColor:(IRKProgressBar*)Progress withProgress:(CGFloat)progress{
    return [UIColor colorWithRed:0x14/255.0 green:0x73/255.0 blue:0xd5/255.0 alpha:1.0];
}

-(void)onClickBack{
    [self.delegate SyncNotifyViewClickBackBtn:self];
}
@end
