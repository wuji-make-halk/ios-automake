//
//  IRKCommonData.m
//  IntelligentRingKing
//
//  Created by qf on 14-5-30.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "IRKCommonData.h"
#import "CommonDefine.h"
@implementation IRKCommonData

+(IRKCommonData *)SharedInstance
{
    static IRKCommonData *irkcommondata = nil;
    if (irkcommondata == nil) {
        irkcommondata = [[IRKCommonData alloc] init];
    }
    return irkcommondata;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.savequeue = dispatch_queue_create("com.sxr.loveswell.save", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void)loadconfig{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL first = [ud boolForKey:CONFIG_KEY_FIRST_RUN];
    if (!first) {
        [ud setBool:YES forKey:CONFIG_KEY_FIRST_RUN];
        self.is_first_run = YES;
        self.is_first_add = YES;
        //初次运行，赋予默认值
        
        
        self.is_enable_autoheart  =YES;//自动检测心率
        self.is_enable_antilost            = NO;
        self.is_enable_bringScreen        = NO;
        self.is_enable_righthand           = NO;
        self.is_enable_nodistrub           = NO;
        self.is_enable_takephoto           = YES;
        double version = [[UIDevice currentDevice].systemVersion doubleValue];
        if (version >= 9.0){
            self.is_enable_incomingcall    = NO;
        }else{
            self.is_enable_incomingcall    = YES;
        }
        
        self.is_enable_facebooknotify      = NO;
        self.is_enable_twitternotify       = NO;
        self.is_enable_skypenotify         = NO;
        self.is_enable_linenotify          = NO;
        
        self.is_enable_whatsappnotify      = NO;
        self.is_enable_qqnotify            = NO;
        self.is_enable_wechatnotify        = NO;
        self.is_enable_mailnotify          = NO;
        self.is_enable_bongcontrolmusic    = NO;   //现在还没做，暂时默认NO
        self.is_enable_projectalert        = NO;

        self.is_enable_remindernotify      = NO;
        
        self.is_enable_devicecall          = NO;
        self.alarmUrl                      = [NSURL URLWithString:@"file:///System/Library/Audio/UISounds/alarm.caf"];
        self.target_runsteps               = 10000;
        self.is_enable_smsnotify           = NO;
        self.is_enable_lowbatteryalarm     = NO;
        self.is_enable_longsitalarm        = NO;

        self.target_steps                  = 10000;
        self.target_distance               = 10;
        self.target_calorie                = 500;
        self.male                          = 1;
        self.target_sleeptime              = 60*60*8;
        self.height                        = DEFAULT_HEIGHT;
        self.weight                        = DEFAULT_WEIGHT;
        self.birthyear                     = DEFAULT_BIRTH;
        self.stride                        = DEFAULT_STRIDE;
        self.measureunit                   = MEASURE_UNIT_METRIX;
        self.lastBongUUID                  = @"";
        self.nickname                      = @"";
        self.is_need_sycn_persondata       = NO;
        self.current_steps                 = 0;
        self.current_heartRate             = 0;
        self.current_cal                   = 0;
        self.current_distance              = 0;
        self.lastLat                       = 0;
        self.lastLong                      = 0;
        self.lastCity                      = @"";
        self.lastLocationDetail            = @"";
        self.is_login                      = NO;
        self.account                       = @"";
        self.password                      = @"";
        self.token                         = @"";
        self.longsit_time                  = 0;
        self.lastLoginTime                 = 0;
        self.is_enable_clock               = NO;
        self.clock_hour                    = 0;
        self.clock_minute                  = 0;
        self.clock_period                  = 0;
        self.target_activity               = 30;
        self.longsit_period                = 0;
        self.clock_smart                   = 0;
        self.longsit_starthour             = 0;
        self.longsit_endhour               = 0;
        self.is_sleepmode                  = NO;
        self.is_enable_shock               = YES;
        self.lastLoginUsername             = @"";
        self.bloodtype                     = DEFAULT_BLOODTYPE;
        self.uid                           = @"";
        self.headimg_url                   = @"male.png";
        self.has_custom_headimage          = NO;
        self.is_memberinfo_change          = NO;
        self.forbbiden_flag                = 0;
        self.last_c6date                   = [NSDate date];
        self.last_c6steps                  = 0;
        self.gear_subtype                  = @"";
        self.screentime                    = 10;
        self.memberid                      = @"";
        
        //读取数据点为7天前
        NSDate* sevendayago = [NSDate dateWithTimeIntervalSinceNow:-HJT_MAX_STORE_DATA_TIME];
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [format setTimeZone:[NSTimeZone systemTimeZone]];
        
        [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
        
        NSString* lastday = [format stringFromDate:sevendayago];
        NSDate* lastdate = [format dateFromString:lastday];
        self.lastReadDataTime              = [lastdate timeIntervalSince1970];
        
        //sports的默认读取时间点为三天前
        NSDate *threeDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-HJT_MAX_STORE_SPORT_DATA_TIME];
        NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
        [format2 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [format2 setTimeZone:[NSTimeZone systemTimeZone]];
        
        [format2 setDateFormat:@"yyyy-MM-dd 00:00:00"];
        NSString *lastStr = [format2 stringFromDate:threeDaysAgo];
        NSDate *lastDate = [format2 dateFromString:lastStr];
        self.lastReadSportDataTime = [lastDate timeIntervalSince1970];
        
        [self saveconfig];
        
    }else{
        //初次运行，赋予默认值
        self.is_first_run                  = NO;
        
//        self.is_in_factory        =     [ud boolForKey:CONFIG_KEY_IN_FACTORY];
        self.is_enable_autoheart  =     [ud boolForKey:CONFIG_KEY_ENABLE_AUTOHEART];
        
        self.is_enable_antilost            = [ud boolForKey:CONFIG_KEY_ENABLE_ANTILOST];
        self.is_enable_bringScreen        = [ud boolForKey:CONFIG_KEY_ENABLE_BRIGHTSCREEN];
        self.is_enable_nodistrub           = [ud boolForKey:CONFIG_KEY_ENABLE_NODISTURB];
        self.is_enable_righthand           = [ud boolForKey:CONFIG_KEY_ENABLE_RIGHTHAND];
        
        
        self.is_enable_takephoto           = [ud boolForKey:CONFIG_KEY_ENABLE_TAKEPHOTO];
        self.is_enable_whatsappnotify            = [ud boolForKey:CONFIG_KEY_ENABLE_WHATSAPP];
        self.is_enable_qqnotify            = [ud boolForKey:CONFIG_KEY_ENABLE_QQ];
        
        self.is_enable_facebooknotify      = [ud boolForKey:CONFIG_KEY_ENABLE_FACEBOOK];
        self.is_enable_twitternotify      = [ud boolForKey:CONFIG_KEY_ENABLE_TWITTER];
        self.is_enable_skypenotify      = [ud boolForKey:CONFIG_KEY_ENABLE_SKYPE];
        self.is_enable_linenotify      = [ud boolForKey:CONFIG_KEY_ENABLE_LINE];
        
        self.is_enable_wechatnotify        = [ud boolForKey:CONFIG_KEY_ENABLE_WECHAT];
        self.is_enable_mailnotify          = [ud boolForKey:CONFIG_KEY_ENABLE_MAILALERT];
        self.is_enable_bongcontrolmusic    = [ud boolForKey:CONFIG_KEY_ENABLE_BONGCONTROLMUSIC];   //现在还没做，暂时默认NO
        self.is_enable_projectalert        = [ud boolForKey:CONFIG_KEY_ENABLE_PROJECT_ALERT];
        self.is_enable_incomingcall        = [ud boolForKey:CONFIG_KEY_ENABLE_INCOMING_CALL];
        self.is_enable_remindernotify      = [ud boolForKey:CONFIG_KEY_ENABLE_REMINDER_NOTIFY];
        self.is_enable_smsnotify           = [ud boolForKey:CONFIG_KEY_ENABLE_SMS_NOTIFY];
        self.is_enable_devicecall          = [ud boolForKey:CONFIG_KEY_ENABLE_DEVICE_CALL];
        self.is_enable_longsitalarm        = [ud boolForKey:CONFIG_KEY_ENABLE_LONGSIT];
        self.is_enable_lowbatteryalarm     = [ud boolForKey:CONFIG_KEY_ENABLE_LOWBATTERY];
        self.target_steps                  = [ud integerForKey:CONFIG_KEY_TARGET_STEPS];
        self.target_runsteps               = [ud integerForKey:CONFIG_KEY_TARGET_RUNSTEPS];
        self.measureunit                   = [ud integerForKey:CONFIG_KEY_MEASUREUNIT];
        self.target_distance               = [ud floatForKey:CONFIG_KEY_TARGET_DISTANCE];
        self.target_calorie                = [ud floatForKey:CONFIG_KEY_TARGET_CAROLIE];
        self.target_sleeptime              = [ud doubleForKey:CONFIG_KEY_TARGET_SLEEPTIME];
        self.male                          = [ud integerForKey:CONFIG_KEY_PERSON_INFO_MALE];
        self.birthyear                     = [ud stringForKey:CONFIG_KEY_PERSON_INFO_BIRTHYEAR];
        self.height                        = [ud floatForKey:CONFIG_KEY_PERSON_INFO_HEIGHT];
        self.weight                        = [ud floatForKey:CONFIG_KEY_PERSON_INFO_WEIGHT];
        self.stride                        = [ud floatForKey:CONFIG_KEY_PERSON_INFO_STRIDE];
        self.lastBongUUID                  = [ud stringForKey:CONFIG_KEY_LAST_CONNECT_BONG_UUID];
        self.target_activity               = [ud integerForKey:CONFIG_KEY_TARGET_ACTIVITY];
        
         self.auto_sync                    = [ud boolForKey:CONFIG_KEY_AUTOSYNC];
//        self.BongServiceUUID               = [ud stringForKey:CONFIG_KEY_BONG_SERVICE_UUID];
//        self.BongNotifyCharacterUUID       = [ud stringForKey:CONFIG_KEY_BONG_NOTIFYCHARACTER_UUID];
//        self.BongWriteCharacterUUID        = [ud stringForKey:CONFIG_KEY_BONG_WRITECHARACTER_UUID];
//        self.BongBatteryCharacterUUID      = [ud stringForKey:CONFIG_KEY_BONG_BATTERYCHARACTER_UUID];
        self.lastReadDataTime              = [ud doubleForKey:CONFIG_KEY_LAST_READ_DETAIL_DATATIME];
        self.lastReadSportDataTime         = [ud doubleForKey:CONFIG_KEY_LAST_READ_SPORT_DATA_TIME];
        self.nickname                      = [ud stringForKey:CONFIG_KEY_NICKNAME];
        self.is_need_sycn_persondata       = [ud boolForKey:CONFIG_KEY_SYNC_PERSONDATA];
        self.current_steps                 = [ud integerForKey:CONFIG_KEY_CURRENT_STEPS];
        self.current_heartRate             = [ud integerForKey:CONFIG_KEY_CURRENT_HAERT];
        self.current_cal                   = [ud floatForKey:CONFIG_KEY_CURRENT_CAL];
        self.current_distance              = [ud floatForKey:CONFIG_KEY_CURRENT_DISTANCE];
        self.lastCity                      = [ud objectForKey:CONFIG_KEY_LAST_CITY];
        if (self.lastCity == nil) {
            self.lastCity = @"";
        }
        self.lastLocationDetail            = [ud objectForKey:CONFIG_KEY_LAST_LOCATION_DETAIL];
        if (self.lastLocationDetail == nil) {
            self.lastLocationDetail = @"";
        }
        self.lastLong                      = [ud floatForKey:CONFIG_KEY_LAST_LONG];
        self.lastLat                       = [ud floatForKey:CONFIG_KEY_LAST_LAT];
        self.is_login                      = [ud boolForKey:CONFIG_KEY_IS_REGIST];
        self.account                       = [ud objectForKey:CONFIG_KEY_ACCOUNT];
        self.password                      = [ud objectForKey:CONFIG_KEY_PASSWORD];
        self.token                         = [ud objectForKey:CONFIG_KEY_TOKEN];
        self.longsit_time                  = [ud integerForKey:CONFIG_KEY_LONGSIT_TIME];
        self.lastLoginTime                 = [ud doubleForKey:CONFIG_KEY_LASTLOGIN_TIME];
        self.lastLoginUsername             = [ud objectForKey:CONFIG_KEY_LASTLOGIN_USERNAME];
        if (self.lastLoginUsername == nil) {
            self.lastLoginUsername = @"";
        }
        self.is_enable_clock               = [ud boolForKey:CONFIG_KEY_ENABLE_CLOCK];
        self.clock_hour                    = [ud integerForKey:CONFIG_KEY_CLOCK_HOUR];
        self.clock_minute                  = [ud integerForKey:CONFIG_KEY_CLOCK_MIN];
        self.clock_period                  = [ud integerForKey:CONFIG_KEY_CLOCK_PERIOD];
        self.longsit_period                = [ud integerForKey:CONFIG_KEY_LONGSIT_PERIOD];
        self.clock_smart                   = [ud integerForKey:CONFIG_KEY_CLOCK_SMART];
        self.longsit_starthour             = [ud integerForKey:CONFIG_KEY_LONGSIT_START];
        self.longsit_endhour               = [ud integerForKey:CONFIG_KEY_LONGSIT_END];
        self.is_enable_shock               = [ud boolForKey:CONFIG_KEY_ENABLE_SHOCK];
        self.is_sleepmode                  = [ud boolForKey:CONFIG_KEY_SLEEPMODE];
        self.bloodtype                     = [ud objectForKey:CONFIG_KEY_PERSON_INFO_BLOODTYPE];
        self.uid                           = [ud objectForKey:CONFIG_KEY_UID];
        self.headimg_url                   = [ud objectForKey:CONFIG_KEY_PERSON_INFO_HEADIMGURL];
        if (self.headimg_url == nil) {
            self.headimg_url = @"";
        }
        self.has_custom_headimage          = [ud boolForKey:CONFIG_KEY_PERSON_INFO_HAS_CUSTOM_HEADIMG];
        self.is_memberinfo_change          = [ud boolForKey:CONFIG_KEY_PERSON_INFO_IS_MEMBERINFO_CHANGE];
        self.forbbiden_flag                = [ud integerForKey:CONFIG_KEY_FOBBIDEN_FLAG];
        self.last_c6steps                  = [ud integerForKey:CONFIG_KEY_LAST_C6_VALUE];
        self.last_c6date                   = [ud objectForKey:CONFIG_KEY_LAST_C6_TIME];
        self.gear_subtype                  = [ud objectForKey:CONFIG_KEY_GEARSUBTYPE];
        self.screentime                    = [ud integerForKey:CONFIG_KEY_SCREENTIME];
        if (self.screentime == 0) {
            self.screentime = 10;
        }
        
        self.alarmUrl                      = [ud URLForKey:CONFIG_KEY_ALARM_URL];
        self.memberid                = [ud objectForKey:RESPONE_KEY_MEMBERID];
        if (self.memberid == nil) {
            self.memberid = @"";
        }

    }/*
    self.is_incoming_call              = NO;
    self.is_incoming_email             = NO;
    self.is_incoming_sms               = NO;
    self.is_calendar_event             = NO;
    self.is_phone_low_power            = NO;
*/    
    self.is_access_to_reminder         = NO;
    self.colorSleep                       = [UIColor colorWithRed:0xe0/255.0 green:0xe0/255.0 blue:0xe0/255.0 alpha:1.0];
    self.colorGold                        = [UIColor colorWithRed:195/255.0 green:181/255.0 blue:119/255.0 alpha:1.0];
    self.colorSilver                      = [UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1.0];
    self.colorLack                        = [UIColor colorWithRed:196/255.0 green:0/255.0 blue:40/255.0 alpha:1.0];
    
//#ifdef CUSTOM_YFT
//    self.colorActivity                    = [UIColor colorWithRed:0xFE/255.0 green:0xBA/255.0 blue:0x59/255.0 alpha:1.0];
//    self.colorSteps                       = [UIColor colorWithRed:0xC2/255.0 green:0xE9/255.0 blue:0xEE/255.0 alpha:1.0];
//    self.colorDistance                    = [UIColor colorWithRed:0xFB/255.0 green:0x8B/255.0 blue:0x8C/255.0 alpha:1.0];
//    self.colorCal                         = [UIColor colorWithRed:0xFE/255.0 green:0xF4/255.0 blue:0xA2/255.0 alpha:1.0];
//    self.colorSleeptime                   = [UIColor colorWithRed:0x55/255.0 green:0xBB/255.0 blue:0xF2/255.0 alpha:1.0];
//    self.colorSleepDeep                   = [UIColor colorWithRed:0x6C/255.0 green:0x70/255.0 blue:0xFF/255.0 alpha:1.0];
//    self.colorSleepLight                  = [UIColor colorWithRed:0x47/255.0 green:0xB8/255.0 blue:0x7C/255.0 alpha:1.0];
//    self.colorSleepExlight                = [UIColor colorWithRed:0x63/255.0 green:0xD2/255.0 blue:0xD7/255.0 alpha:1.0];
//    self.colorLight                       = [UIColor colorWithRed:0xFD/255.0 green:0xD1/255.0 blue:0x2E/255.0 alpha:1.0];
//    self.colorDeep                        = [UIColor colorWithRed:0xF0/255.0 green:0x3C/255.0 blue:0x4C/255.0 alpha:1.0];
//    self.colorAwake                       = [UIColor whiteColor];
//    self.colorExlight                     = [UIColor colorWithRed:0x88/255.0 green:0xA8/255.0 blue:0xBD/255.0 alpha:1.0];
//#elif CUSTOM_PUZZLE || CUSTOM_NOMI || CUSTOM_HIMOVE
    self.colorActivity                    = [UIColor colorWithRed:0xFE/255.0 green:0xBA/255.0 blue:0x59/255.0 alpha:1.0];
    self.colorSteps                       = [UIColor colorWithRed:0xC0/255.0 green:0xD8/255.0 blue:0xEF/255.0 alpha:1.0];
    self.colorDistance                    = [UIColor colorWithRed:0xB8/255.0 green:0xE1/255.0 blue:0x8E/255.0 alpha:1.0];
    self.colorCal                         = [UIColor colorWithRed:0xA2/255.0 green:0x79/255.0 blue:0xC2/255.0 alpha:1.0];
    self.colorSleeptime                   = [UIColor colorWithRed:0x7E/255.0 green:0x92/255.0 blue:0x71/255.0 alpha:1.0];
    self.colorSleepDeep                   = [UIColor colorWithRed:0x5F/255.0 green:0xA6/255.0 blue:0x86/255.0 alpha:1.0];
    self.colorSleepLight                  = [UIColor colorWithRed:0x47/255.0 green:0xB8/255.0 blue:0x7C/255.0 alpha:1.0];
    self.colorSleepExlight                = [UIColor colorWithRed:0x63/255.0 green:0xD2/255.0 blue:0xD7/255.0 alpha:1.0];
//#ifdef CUSTOM_PUZZLE
//    self.colorLight                       = [UIColor colorWithRed:222/255.0 green:0/255.0 blue:84/255.0 alpha:1.0];
//    self.colorDeep                        = [UIColor colorWithRed:0x7e/255.0 green:0x2e/255.0 blue:0x80/255.0 alpha:1.0];
//    self.colorAwake                       = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
//    self.colorExlight                     = [UIColor colorWithRed:239/255.0 green:124/255.0 blue:174/255.0 alpha:1.0];
//#elif defined(CUSTOM_HIMOVE)
    self.colorLight                       = [UIColor colorWithRed:222/255.0 green:0/255.0 blue:84/255.0 alpha:1.0];
    self.colorDeep                        = [UIColor colorWithRed:0x7e/255.0 green:0x2e/255.0 blue:0x80/255.0 alpha:1.0];
    self.colorAwake                       = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
    self.colorExlight                     = [UIColor colorWithRed:239/255.0 green:124/255.0 blue:174/255.0 alpha:1.0];
//#else
//    self.colorLight                       = [UIColor colorWithRed:0x3D/255.0 green:0xBB/255.0 blue:0xBA/255.0 alpha:1.0];
//    self.colorDeep                        = [UIColor colorWithRed:0x7e/255.0 green:0x2e/255.0 blue:0x80/255.0 alpha:1.0];
//    self.colorAwake                       = [UIColor colorWithRed:0xFC/255.0 green:0xB8/255.0 blue:0xBD/255.0 alpha:1.0];
//    self.colorExlight                     = [UIColor colorWithRed:0x7C/255.0 green:0x9D/255.0 blue:0xFC/255.0 alpha:1.0];
//#endif
    
//#elif CUSTOM_FITRIST
//    self.colorActivity                    = [UIColor colorWithRed:0xFE/255.0 green:0xBA/255.0 blue:0x59/255.0 alpha:1.0];
//    self.colorSteps                       = [UIColor colorWithRed:0xC0/255.0 green:0xD8/255.0 blue:0xEF/255.0 alpha:1.0];
//    self.colorDistance                    = [UIColor colorWithRed:0xB8/255.0 green:0xE1/255.0 blue:0x8E/255.0 alpha:1.0];
//    self.colorCal                         = [UIColor colorWithRed:0xA2/255.0 green:0x79/255.0 blue:0xC2/255.0 alpha:1.0];
//    self.colorSleeptime                   = [UIColor colorWithRed:0x7E/255.0 green:0x92/255.0 blue:0x71/255.0 alpha:1.0];
//    self.colorSleepDeep                   = [UIColor colorWithRed:0x5F/255.0 green:0xA6/255.0 blue:0x86/255.0 alpha:1.0];
//    self.colorSleepLight                  = [UIColor colorWithRed:0x47/255.0 green:0xB8/255.0 blue:0x7C/255.0 alpha:1.0];
//    self.colorSleepExlight                = [UIColor colorWithRed:0x63/255.0 green:0xD2/255.0 blue:0xD7/255.0 alpha:1.0];
//    self.colorLight                       = [UIColor colorWithRed:0x3D/255.0 green:0xBB/255.0 blue:0xBA/255.0 alpha:1.0];
//    self.colorDeep                        = [UIColor colorWithRed:0x21/255.0 green:0x99/255.0 blue:0x98/255.0 alpha:1.0];
//    self.colorAwake                       = [UIColor colorWithRed:0xFC/255.0 green:0xB8/255.0 blue:0xBD/255.0 alpha:1.0];
//    self.colorExlight                     = [UIColor colorWithRed:0x7C/255.0 green:0x9D/255.0 blue:0xFC/255.0 alpha:1.0];
//#else
//    self.colorActivity                    = [UIColor colorWithRed:0xcc/255.0 green:0xff/255.0 blue:0xcc/255.0 alpha:1.0];
//    self.colorSteps                       = [UIColor colorWithRed:0xcc/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:1.0];
//    self.colorDistance                    = [UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0x75/255.0 alpha:1.0];
//    self.colorCal                         = [UIColor colorWithRed:253/255.0 green:94/255.0 blue:99/255.0 alpha:1.0];
//    self.colorSleeptime                   = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
//    self.colorLight                       = [UIColor colorWithRed:0xd5/255.0 green:0xd1/255.0 blue:0x10/255.0 alpha:1.0];
//    self.colorDeep                        = [UIColor colorWithRed:0x02/255.0 green:0/255.0 blue:0xfe/255.0 alpha:1.0];
//    self.colorAwake                       = [UIColor colorWithRed:197/255.0 green:217/255.0 blue:241/255.0 alpha:1.0];
//    self.colorExlight                     = [UIColor colorWithRed:0xff/255.0 green:0x7b/255.0 blue:0x02/255.0 alpha:1.0];
//#endif
    /*
    self.colorLight                       = [UIColor colorWithRed:53/255.0 green:128/255.0 blue:227/255.0 alpha:1.0];
    self.colorDeep                        = [UIColor colorWithRed:0/255.0 green:85/255.0 blue:209/255.0 alpha:1.0];
    self.colorAwake                       = [UIColor colorWithRed:211/255.0 green:255/255.0 blue:212/255.0 alpha:1.0];
     */
//#if defined(CUSTOM_GETFIT)
//    self.colorNav                         = [UIColor colorWithRed:0x6f/255.0 green:0xc8/255.0 blue:0xec/255.0 alpha:1.0];
//#elif defined(CUSTOM_GOBAND)
//    self.colorMenuBackground              = [UIColor colorWithRed:0x42/255.0 green:0xca/255.0 blue:0x44/255.0 alpha:1.0];
//    self.colorNav                         = [UIColor colorWithRed:0x42/255.0 green:0xca/255.0 blue:0x44/255.0 alpha:1.0];
//#elif defined(CUSTOM_ZZB)
//    self.colorMenuBackground              = [UIColor colorWithRed:0/255.0 green:0xac/255.0 blue:0xe1/255.0 alpha:1.0];
//    self.colorNav                         = [UIColor colorWithRed:0/255.0 green:0xac/255.0 blue:0xe1/255.0 alpha:1.0];
//#elif defined(CUSTOM_CCBAND)
//    self.colorNav = [UIColor colorWithRed:0x51/255.0 green:0x58/255.0 blue:0x60/255.0 alpha:1.0];
//    
//    self.colorLight                       = [UIColor colorWithRed:0xbe/255.0 green:0xe5/255.0 blue:0xf5/255.0 alpha:1.0];
//    self.colorDeep                        = [UIColor colorWithRed:0x91/255.0 green:0xa9/255.0 blue:0xd5/255.0 alpha:1.0];
//    self.colorAwake                       = [UIColor colorWithRed:197/255.0 green:217/255.0 blue:241/255.0 alpha:1.0];
//    self.colorExlight                     = [UIColor colorWithRed:0xb2/255.0 green:0xfa/255.0 blue:0xd7/255.0 alpha:1.0];
//#elif defined(CUSTOM_SPRINFIT)
//    self.colorMenuBackground              = [UIColor whiteColor];
//    self.colorNav                         = [UIColor redColor];
//    self.colorLoginText                   = [UIColor colorWithRed:0x53/255.0 green:0x53/255.0 blue:0x53/255.0 alpha:1.0];
//#elif defined(CUSTOM_BLOX)
//    self.colorMenuBackground              = [UIColor colorWithRed:0x42/255.0 green:0xca/255.0 blue:0x44/255.0 alpha:1.0];
//    self.colorNav                         = [UIColor colorWithRed:0x42/255.0 green:0xca/255.0 blue:0x44/255.0 alpha:1.0];
//#elif defined(CUSTOM_YFT)
//    self.colorMenuBackground              = [UIColor colorWithRed:0x42/255.0 green:0xca/255.0 blue:0x44/255.0 alpha:1.0];
//    self.colorNav                         = [UIColor colorWithRed:0x2E/255.0 green:0x34/255.0 blue:0x3D/255.0 alpha:1.0];
//    self.colorLoginText                   = [UIColor blackColor];
//    self.colorMainText                    = [UIColor whiteColor];
//#elif CUSTOM_FITGO
//    self.colorNav                         = [UIColor colorWithRed:0xFF/255.0 green:0xFF/255.0 blue:0xFF/255.0 alpha:1.0];
//    self.colorMainText                    = [UIColor colorWithRed:0x87/255.0 green:0x7f/255.0 blue:0xc0/255.0 alpha:1.0];
//    self.colorSync                        = [UIColor colorWithRed:0xf1/255.0 green:0x3d/255.0 blue:0x6d/255.0 alpha:1.0];
//    self.colorWeeks                       = [UIColor colorWithRed:208%256/255.0 green:59%256/255.0 blue:109%256/255.0 alpha:1.0];
//    self.colorWeeksBackground             = [UIColor colorWithRed:244%256/255.0 green:244%256/255.0 blue:244%256/255.0 alpha:1.0];
//
//#elif CUSTOM_PUZZLE 
//    self.colorMenuBackground              = [UIColor colorWithRed:0x42/255.0 green:0xca/255.0 blue:0x44/255.0 alpha:1.0];
//    self.colorNav                         = [UIColor colorWithRed:0/255.0 green:32/255.0 blue:79/255.0 alpha:1.0];
//    self.colorLoginText                   = [UIColor whiteColor];
////    self.colorMainText                    = [UIColor colorWithRed:0x4D/255.0 green:0xD1/255.0 blue:0xC1/255.0 alpha:1.0];
////    self.colorMainText                    = [UIColor colorWithRed:0x7e/255.0 green:0x2e/255.0 blue:0x80/255.0 alpha:1.0];
//    self.colorMainText                    = [UIColor whiteColor];
//#elif CUSTOM_HIMOVE
//#if CUSTOM_MGCOOLBAND2
//    self.colorMenuBackground              = [UIColor colorWithRed:0x42/255.0 green:0xca/255.0 blue:0x44/255.0 alpha:1.0];
//    self.colorNav                         = [UIColor colorWithRed:255/255.0 green:110/255.0 blue:0/255.0 alpha:1.0];
//    self.colorLoginText                   = [UIColor whiteColor];
//    self.colorMainText                    = [UIColor whiteColor];
//#else
    self.colorMenuBackground              = [UIColor colorWithRed:0x42/255.0 green:0xca/255.0 blue:0x44/255.0 alpha:1.0];
    self.colorNav                         = [UIColor colorWithRed:0x01/255.0 green:0x72/255.0 blue:0xfe/255.0 alpha:1.0];
    self.colorLoginText                   = [UIColor whiteColor];
    self.colorMainText                    = [UIColor whiteColor];
//#endif
    
//#elif CUSTOM_NOMI
//    self.colorMenuBackground              = [UIColor colorWithRed:0x42/255.0 green:0xca/255.0 blue:0x44/255.0 alpha:1.0];
//    //self.colorNav                         = [UIColor colorWithRed:0xd8/255.0 green:0xc0/255.0 blue:0xd9/255.0 alpha:1.0];
//    self.colorNav                         = [UIColor colorWithRed:0x80/255.0 green:0xb5/255.0 blue:0xc7/255.0 alpha:1.0];
//    self.colorLoginText                   = [UIColor whiteColor];
//    //self.colorMainText                    = [UIColor colorWithRed:0x4D/255.0 green:0xD1/255.0 blue:0xC1/255.0 alpha:1.0];
//    self.colorMainText                    = [UIColor colorWithRed:0x00/255.0 green:0x6b/255.0 blue:0x8d/255.0 alpha:1.0];//[UIColor colorWithRed:0x7e/255.0 green:0x2e/255.0 blue:0x80/255.0 alpha:1.0];
//
//#elif CUSTOM_FITRIST
//    self.colorMenuBackground              = [UIColor colorWithRed:0x42/255.0 green:0xca/255.0 blue:0x44/255.0 alpha:1.0];
//    self.colorNav                         = [UIColor colorWithRed:25/255.0 green:133/255.0 blue:181/255.0 alpha:1.0];
//    self.colorLoginText                   = [UIColor whiteColor];
//    self.colorMainText                    = [UIColor colorWithRed:0x4D/255.0 green:0xD1/255.0 blue:0xC1/255.0 alpha:1.0];
//#else
//    self.colorMenuBackground              = [UIColor colorWithRed:0x57/255.0 green:0xdd/255.0 blue:0xdc/255.0 alpha:1.0];
//    self.colorNav                         = [UIColor colorWithRed:0x96/255.0 green:0xcc/255.0 blue:0x70/255.0 alpha:1.0];
//#endif
    
//#if CUSTOM_FITGO
//    self.colorLogin                       = [UIColor colorWithRed:238/255.0 green:96/255.0 blue:35/255.0 alpha:1.0];
//#elif CUSTOM_PUZZLE || CUSTOM_NOMI || CUSTOM_HIMOVE
    self.colorLogin                       = [UIColor redColor];
//#else
//    self.colorLogin                       = [UIColor colorWithRed:238/255.0 green:96/255.0 blue:35/255.0 alpha:1.0];
//#endif
    self.colorPersonText                  = [UIColor darkGrayColor];
    self.colorSingalText                  = [UIColor whiteColor];
//#ifdef CUSTOM_PUZZLE
//    self.colorTextColor                   = [UIColor whiteColor];
//#elif defined(CUSTOM_HIMOVE)
    self.colorTextColor                   = [UIColor whiteColor];
//#else
//    self.colorTextColor                   = [UIColor darkGrayColor];
//#endif
    
    self.temp                             = 0;
    self.tempmax                          = 0;
    self.tempmin                          = 0;
    self.weathertype                      = [[NSMutableArray alloc] init];
    IRKPhone2DeviceAlarms alarms;
    self.alarmEvent = &alarms;
    self.alarmEvent->is_calendar = NO;
    self.alarmEvent->is_call = NO;
    self.alarmEvent->is_email = NO;
    self.alarmEvent->is_phone_lowpower = NO;
    self.alarmEvent->is_sms = NO;
    self.lastWeatherTime = 0;
    self.current_macid = @"";
    self.current_firmware = @"";
    self.batterylevel                  = 0;
    
    self.BongServiceUUID               = @"FFF0";
    self.BongNotifyCharacterUUID       = @"FFF1";
    self.BongWriteCharacterUUID        = @"FFF2";
    self.BongBatteryCharacterUUID      = @"2A19";
    self.BongAdvNotifyCharacterUUID    = @"FFF3";
    self.BongAdvWriteCharacterUUID     = @"FFF4";
    self.BongOtaSericeUUID             = @"FEBA";
    self.BongOtaCMDCharaterUUID        = @"FA11";
    self.BongOtaDataCharaterUUID       = @"FA10";
    
    
    
    self.colorTabBackground = [UIColor whiteColor];
    self.colorTabTexHighlight = [UIColor colorWithRed:0x67/255.0 green:0x67/255.0 blue:0x67/255.0 alpha:1.0];
    self.colorTabTextNormal = [UIColor colorWithRed:0x67/255.0 green:0x67/255.0 blue:0x67/255.0 alpha:1.0];
    self.colorMapLine = [UIColor colorWithRed:0x2e/255.0 green:0xb8/255.0 blue:0x32/255.0 alpha:1.0];
    self.zcchina = [ZCChinaLocation shared];
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_location_update object:nil userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notify_key_UV_update" object:nil userInfo:nil];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    self.vid = [data objectForKey:@"vid"];
    self.bleName = [data objectForKey:@"bleName"];
    self.shareKey = [data objectForKey:@"shareKey"];
    //self.shareDict = [data objectForKey:@"share"];
    self.qqDict = [data objectForKey:@"qq"];
    self.weiboDict = [data objectForKey:@"weibo"];
    self.wechatDict = [data objectForKey:@"wechat"];
    self.mailDict = [data objectForKey:@"mail"];
    self.facebookDict = [data objectForKey:@"facebook"];
    self.twitterDict = [data objectForKey:@"twitter"];
    self.healthkitArr = (NSMutableArray*)[data objectForKey:@"HealthKit"];
    self.is_in_factory = NO;
    //取消防丢功能
    self.is_enable_antilost = NO;
    NSLog(@"%@ %@",self.vid, self.bleName);

}
-(void)saveconfig{
    dispatch_sync(self.savequeue, ^{
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setBool:self.is_enable_antilost forKey:CONFIG_KEY_ENABLE_ANTILOST];
        [ud setBool:self.is_enable_bringScreen forKey:CONFIG_KEY_ENABLE_BRIGHTSCREEN];
//        [ud setBool:self.is_in_factory forKey:CONFIG_KEY_IN_FACTORY];
        [ud setBool:self.is_enable_autoheart forKey:CONFIG_KEY_ENABLE_AUTOHEART];
        [ud setBool:self.is_enable_nodistrub forKey:CONFIG_KEY_ENABLE_NODISTURB];
        [ud setBool:self.is_enable_righthand forKey:CONFIG_KEY_ENABLE_RIGHTHAND];
        
        
        [ud setBool:self.is_enable_takephoto forKey:CONFIG_KEY_ENABLE_TAKEPHOTO];
        [ud setBool:self.is_enable_whatsappnotify forKey:CONFIG_KEY_ENABLE_WHATSAPP];
        [ud setBool:self.is_enable_qqnotify forKey:CONFIG_KEY_ENABLE_QQ];
        
        [ud setBool:self.is_enable_facebooknotify forKey:CONFIG_KEY_ENABLE_FACEBOOK];
        [ud setBool:self.is_enable_twitternotify forKey:CONFIG_KEY_ENABLE_TWITTER];
        [ud setBool:self.is_enable_skypenotify forKey:CONFIG_KEY_ENABLE_SKYPE];
        [ud setBool:self.is_enable_linenotify forKey:CONFIG_KEY_ENABLE_LINE];
        
        [ud setBool:self.is_enable_wechatnotify forKey:CONFIG_KEY_ENABLE_WECHAT];
        [ud setBool:self.is_enable_mailnotify forKey:CONFIG_KEY_ENABLE_MAILALERT];
        [ud setBool:self.is_enable_bongcontrolmusic forKey:CONFIG_KEY_ENABLE_BONGCONTROLMUSIC];
        [ud setBool:self.is_enable_remindernotify forKey:CONFIG_KEY_ENABLE_REMINDER_NOTIFY];
        [ud setBool:self.is_enable_projectalert forKey:CONFIG_KEY_ENABLE_PROJECT_ALERT];
        [ud setBool:self.is_enable_incomingcall forKey:CONFIG_KEY_ENABLE_INCOMING_CALL];
        [ud setBool:self.is_enable_smsnotify forKey:CONFIG_KEY_ENABLE_SMS_NOTIFY];
        [ud setBool:self.is_enable_devicecall forKey:CONFIG_KEY_ENABLE_DEVICE_CALL];
        [ud setInteger:self.target_steps forKey:CONFIG_KEY_TARGET_STEPS];
        [ud setInteger:self.target_runsteps forKey:CONFIG_KEY_TARGET_RUNSTEPS];
        [ud setInteger:self.measureunit forKey:CONFIG_KEY_MEASUREUNIT];
        [ud setFloat:self.target_distance forKey:CONFIG_KEY_TARGET_DISTANCE];
        [ud setFloat:self.target_calorie forKey:CONFIG_KEY_TARGET_CAROLIE];
        [ud setDouble:self.target_sleeptime forKey:CONFIG_KEY_TARGET_SLEEPTIME];
        [ud setInteger:self.male forKey:CONFIG_KEY_PERSON_INFO_MALE];
        [ud setFloat:self.stride forKey:CONFIG_KEY_PERSON_INFO_STRIDE];
        [ud setObject:self.birthyear forKey:CONFIG_KEY_PERSON_INFO_BIRTHYEAR];
        [ud setFloat:self.height forKey:CONFIG_KEY_PERSON_INFO_HEIGHT];
        [ud setFloat:self.weight forKey:CONFIG_KEY_PERSON_INFO_WEIGHT];
        [ud setObject:self.lastBongUUID forKey:CONFIG_KEY_LAST_CONNECT_BONG_UUID];
//        [ud setObject:self.BongServiceUUID forKey:CONFIG_KEY_BONG_SERVICE_UUID];
//        [ud setObject:self.BongNotifyCharacterUUID forKey:CONFIG_KEY_BONG_NOTIFYCHARACTER_UUID];
//        [ud setObject:self.BongWriteCharacterUUID forKey:CONFIG_KEY_BONG_WRITECHARACTER_UUID];
//        [ud setObject:self.BongBatteryCharacterUUID forKey:CONFIG_KEY_BONG_BATTERYCHARACTER_UUID];
        [ud setObject:self.nickname forKey:CONFIG_KEY_NICKNAME];
        [ud setDouble:self.lastReadDataTime forKey:CONFIG_KEY_LAST_READ_DETAIL_DATATIME];
        [ud setDouble:self.lastReadSportDataTime forKey:CONFIG_KEY_LAST_READ_SPORT_DATA_TIME];
        [ud setBool:self.is_need_sycn_persondata forKey:CONFIG_KEY_SYNC_PERSONDATA];
        [ud setFloat:self.lastLat forKey:CONFIG_KEY_LAST_LAT];
        [ud setFloat:self.lastLong forKey:CONFIG_KEY_LAST_LONG];
        [ud setObject:self.lastCity forKey:CONFIG_KEY_LAST_CITY];
        [ud setObject:self.lastLocationDetail forKey:CONFIG_KEY_LAST_LOCATION_DETAIL];
        [ud setFloat:self.current_cal forKey:CONFIG_KEY_CURRENT_CAL];
        [ud setInteger:self.current_steps forKey:CONFIG_KEY_CURRENT_STEPS];
        [ud setInteger:self.current_heartRate forKey:CONFIG_KEY_CURRENT_HAERT];
        [ud setFloat:self.current_distance forKey:CONFIG_KEY_CURRENT_DISTANCE];
        [ud setBool:self.is_login forKey:CONFIG_KEY_IS_REGIST];
        [ud setObject:self.account forKey:CONFIG_KEY_ACCOUNT];
        [ud setObject:self.password forKey:CONFIG_KEY_PASSWORD];
        [ud setObject:self.token forKey:CONFIG_KEY_TOKEN];
        [ud setBool:self.is_enable_longsitalarm forKey:CONFIG_KEY_ENABLE_LONGSIT];
        [ud setBool:self.is_enable_lowbatteryalarm forKey:CONFIG_KEY_ENABLE_LOWBATTERY];
        [ud setInteger:self.longsit_time forKey:CONFIG_KEY_LONGSIT_TIME];
        [ud setDouble:self.lastLoginTime forKey:CONFIG_KEY_LASTLOGIN_TIME];
        [ud setObject:self.lastLoginUsername forKey:CONFIG_KEY_LASTLOGIN_USERNAME];
        [ud setBool:self.is_enable_clock forKey:CONFIG_KEY_ENABLE_CLOCK];
        [ud setInteger:self.clock_hour forKey:CONFIG_KEY_CLOCK_HOUR];
        [ud setInteger:self.clock_minute forKey:CONFIG_KEY_CLOCK_MIN];
        [ud setInteger:self.clock_period forKey:CONFIG_KEY_CLOCK_PERIOD];
        [ud setInteger:self.longsit_period forKey:CONFIG_KEY_LONGSIT_PERIOD];
        [ud setInteger:self.clock_smart forKey:CONFIG_KEY_CLOCK_SMART];
        [ud setInteger:self.longsit_endhour forKey:CONFIG_KEY_LONGSIT_END];
        [ud setInteger:self.longsit_starthour forKey:CONFIG_KEY_LONGSIT_START];
        [ud setBool:self.is_sleepmode forKey:CONFIG_KEY_SLEEPMODE];
        [ud setBool:self.is_enable_shock forKey:CONFIG_KEY_ENABLE_SHOCK];
        [ud setObject:self.bloodtype forKey:CONFIG_KEY_PERSON_INFO_BLOODTYPE];
        [ud setObject:self.uid forKey:CONFIG_KEY_UID];
        [ud setObject:self.headimg_url forKey:CONFIG_KEY_PERSON_INFO_HEADIMGURL];
        [ud setBool:self.has_custom_headimage forKey:CONFIG_KEY_PERSON_INFO_HAS_CUSTOM_HEADIMG];
        [ud setBool:self.is_memberinfo_change forKey:CONFIG_KEY_PERSON_INFO_IS_MEMBERINFO_CHANGE];
        [ud setInteger:self.forbbiden_flag forKey:CONFIG_KEY_FOBBIDEN_FLAG];
        [ud setObject:self.gear_subtype forKey:CONFIG_KEY_GEARSUBTYPE];
        [ud setInteger:self.screentime forKey:CONFIG_KEY_SCREENTIME];
        [ud setInteger:self.target_activity forKey:CONFIG_KEY_TARGET_ACTIVITY];
        [ud setObject:self.memberid forKey:RESPONE_KEY_MEMBERID];

        [ud setURL:self.alarmUrl forKey:CONFIG_KEY_ALARM_URL];
    //    NSLog(@"saveconfig::%@,%@,%@",self.BongServiceUUID,self.BongNotifyCharacterUUID,self.BongWriteCharacterUUID);
        [ud synchronize];
    });
}
-(void)saveconfig:(id)obj forkey:(NSString*)key{
    dispatch_sync(self.savequeue, ^{
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:obj forKey:key];
        [ud synchronize];
        
    });
}

- (void)refreshNickName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.nickname =  [ud stringForKey:CONFIG_KEY_NICKNAME];
}

-(void)saveC6{
    dispatch_sync(self.savequeue, ^{
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setInteger:self.last_c6steps forKey:CONFIG_KEY_LAST_C6_VALUE];
        [ud setObject:[self.last_c6date copy] forKey:CONFIG_KEY_LAST_C6_TIME];
        [ud synchronize];
        
    });
}
-(UIFont*)getFontbySize2:(CGFloat)size isBold:(BOOL)bold{
#ifdef CUSTOM_SPRINFIT
    return [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:size];
#else
    if([NSLocalizedString(@"lang", nil) isEqualToString:@"eng"]){
        if (bold) {
            return [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:size];
        }else{
            return [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:size];
        }
    }else{
        if (bold) {
            return [UIFont boldSystemFontOfSize:size];
        }else{
            return [UIFont systemFontOfSize:size];
        }
    }
#endif
//    if (bold) {
//        return [UIFont fontWithName:@"AvenirNext-Bold" size:size];
//    }else{
//        return [UIFont fontWithName:@"Avenir Next" size:size];
//    }
    

}

-(UIFont*)getFontbySize:(CGFloat)size isBold:(BOOL)bold{
//#ifdef CUSTOM_SPRINFIT
//    if (bold) {
//        return [UIFont fontWithName:@"AvenirNext-Bold" size:size];
//    }else{
//        return [UIFont fontWithName:@"Avenir Next" size:size];
//    }
//
//#else
    if([NSLocalizedString(@"lang", nil) isEqualToString:@"eng"]){
        if (bold) {
            return [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:size];
        }else{
            return [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:size];
        }
    }else{
        if (bold) {
            return [UIFont boldSystemFontOfSize:size];
        }else{
            return [UIFont systemFontOfSize:size];
        }
    }
//#endif
}

-(UIImage*)getHeadimage{
    if (self.has_custom_headimage) {
        NSString *filename = [NSString stringWithFormat:@"%@.jpg",self.uid];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
        UIImage * image = [UIImage imageWithContentsOfFile:filePath];
        if (image) {
            return image;
        }else{
            return [UIImage imageNamed:@"icon_menu_headimg.png"];
        }
    }else{
        return [UIImage imageNamed:@"icon_menu_headimg.png"];
    }
    
}

-(NSString*)getSeqid{
    return [NSString stringWithFormat:@"%d", arc4random()/100000];
}


-(NSMutableDictionary*)getBongInformation:(NSString*)uuid{
    if (uuid == nil) {
        return nil;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dict = (NSMutableDictionary*)[ud objectForKey:uuid];
    if(dict){
        return [dict mutableCopy];
    }else{
        return nil;
    }
}

-(void)setBongInformation:(NSString*)uuid Information:(NSMutableDictionary*)info{
    if (uuid == nil || info == nil) {
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:info forKey:uuid];
    [ud synchronize];
}

-(NSMutableDictionary*)getMemberInfo:(NSString *)username{
    if (username == nil) {
        return nil;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dict = (NSMutableDictionary*)[ud objectForKey:username];
    if(dict){
        return [dict mutableCopy];
    }else{
        return nil;
    }
}

-(void)setMemberInfo:(NSString *)username Information:(NSMutableDictionary *)info{
    if (username == nil || info == nil) {
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:info forKey:username];
    [ud synchronize];
}

-(NSMutableDictionary*)getUserInfo:(NSString *)uid{
    if (uid == nil) {
        return nil;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dict = (NSMutableDictionary*)[ud objectForKey:uid];
    if(dict){
        return [dict mutableCopy];
    }else{
        return nil;
    }
}

-(void)setUserInfo:(NSString *)uid Information:(NSMutableDictionary *)info{
    if (uid == nil || info == nil) {
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:info forKey:uid];
    [ud synchronize];
}

-(NSString*)gen_uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}

-(NSString*)getVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *label = [NSString stringWithFormat:@"%@ v%@ (build %@)", name, version, build];
    return label;
}
-(NSString*)getPhoneType{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
//    return [[UIDevice currentDevice] model];
}
-(NSString*)getPhoneOS{
    return [NSString stringWithFormat:@"%@:%@",[[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
}
-(NSString*)getPhoneName{
    return [[UIDevice currentDevice] name];
}
-(NSString*)getPhoneId{
    //    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return  [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

-(BOOL)isDateInToday:(NSDate*)currentdate{
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    
    format.dateFormat = @"yyyy-MM-dd";
    NSDate* today = [NSDate date];
    NSString* todaystr = [format stringFromDate:today];
    NSString* currentstr = [format stringFromDate:currentdate];
    if ([todaystr isEqualToString:currentstr]) {
        return YES;
    }else{
        return NO;
    }
    
}
-(CGSize)getStringSize:(NSString*)str byFont:(UIFont*)font{
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version >= 7.0){
        return [str sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    }else{
        return [str sizeWithFont:font];
    }
    
}

-(BOOL)is24time{
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    BOOL is24Hour = ([format rangeOfString:@"a"].location == NSNotFound);
    if (is24Hour) {
        return YES;
    }else{
        return NO;
    }

}

-(CGFloat)getDistance:(NSInteger)steps{

    int stride;
//    int weight;
    if (self.measureunit == MEASURE_UNIT_US){
//        weight = (Byte)ceil(self.weight)/KM2MILE;
//        stride = (Byte)ceil(self.stride*KM2MILE);
        stride = (Byte)ceil(self.stride*KM2MILE);
    }else{
//        weight = (Byte)ceil(self.weight);
//        stride = (Byte)ceil(self.stride);
        stride = (Byte)ceil(self.stride);
        
    }
    if (self.measureunit == MEASURE_UNIT_METRIX) {
        return floor((floor(stride*steps/100.0)/1000.0)*1000)/1000.0;
    }else{
        //        return floor(stride*steps/100.0)/1000.0;
        return floor((floor(stride*steps/100.0)/1000.0)*1000)/1000.0;
    }
}

-(CGFloat)getCal:(NSInteger)steps{
    int stride;
    int weight;
    if (self.measureunit == MEASURE_UNIT_US){
        weight = (Byte)ceil(self.weight)/KM2MILE;
        stride = (Byte)ceil(self.stride*KM2MILE);
        stride = (Byte)ceil(self.stride*KM2MILE);
    }else{
        weight = (Byte)ceil(self.weight);
        stride = (Byte)ceil(self.stride);
        stride = (Byte)ceil(self.stride);
        
    }
    if (self.measureunit == MEASURE_UNIT_METRIX) {
        return floor(CALQUOTE*(stride/100.0)*steps*weight/1000.0);
    }else{
        return floor(CALQUOTE*(stride/100.0)*steps*weight/1000.0);
    }
}
-(NSString*)formatterInt:(int)value{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    return [formatter stringFromNumber:@(value)];
}

-(CLLocationCoordinate2D)convert_wgs2gcj:(CLLocationCoordinate2D)orgin{
    
    CLLocationCoordinate2D pt = CLLocationCoordinate2DMake(0, 0);
    if (![self isChinabyLng:orgin.longitude andLat:orgin.latitude])
    {
        pt.latitude = orgin.latitude;
        pt.longitude = orgin.longitude;
        return pt;
    }
    double dLat = transformLat(orgin.longitude - 105.0, orgin.latitude - 35.0);
    double dLon = transformLon(orgin.longitude - 105.0, orgin.latitude - 35.0);
    double radLat = orgin.latitude / 180.0 * pi;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    pt.latitude = orgin.latitude + dLat;
    pt.longitude = orgin.longitude + dLon;
    NSLog(@"IN {%f,%f}, OUT{%f,%f}",orgin.latitude,orgin.longitude,pt.latitude,pt.longitude);
    return pt;
}
-(CLLocationCoordinate2D)convert_gcj2wgs:(CLLocationCoordinate2D)orgin{
    CLLocationCoordinate2D wgLoc = orgin;
    CLLocationCoordinate2D currGcLoc, dLoc;
    while (1) {
        currGcLoc = [self convert_wgs2gcj:wgLoc];
        dLoc.latitude = orgin.latitude - currGcLoc.latitude;
        dLoc.longitude = orgin.longitude - currGcLoc.longitude;
        if (fabs(dLoc.latitude) < 1e-7 && fabs(dLoc.longitude) < 1e-7) {  // 1e-7 ~ centimeter level accuracy
            // Result of experiment:
            //   Most of the time 2 iterations would be enough for an 1e-8 accuracy (milimeter level).
            //
            return wgLoc;
        }
        wgLoc.latitude += dLoc.latitude;
        wgLoc.longitude += dLoc.longitude;
    }
    
    return wgLoc;
    
}
-(BOOL)isChinabyLng:(double)lng andLat:(double)lat{
    if ([self.zcchina isInsideChina:CLLocationCoordinate2DMake(lat, lng)]) {
        NSLog(@"In china");
        return YES;
    }else{
        NSLog(@"Out china");
        return NO;
    }
//    if ((lng > 72.004 && lng < 137.8347) && (lat > 0.8293 && lat < 55.8271)){
//        NSLog(@"In china");
//        NSString* local = [NSLocale currentLocale].localeIdentifier;
//        if (![local isEqualToString:@"en_CN"]) {
//            return NO;
//        }
//        return YES;
//    }
//    //    if (lat < 0.8293 || lat > 55.8271)
//    //        return YES;
//    NSLog(@"Out china");
//    return NO;
}
const double pi = 3.14159265358979324;
const double a = 6378245.0;
const double ee = 0.00669342162296594323;

double transformLat(double x, double y)
{
    
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(x > 0 ? x:-x);
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 *sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
}

double transformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(x > 0 ? x:-x);
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
}

-(id)getValueFromBonginfoByKey:(NSString*)key{
    if (self.lastBongUUID == nil || [self.lastBongUUID isEqualToString:@""]) {
        return nil;
    }
    NSDictionary* bi = [self getBongInformation:self.lastBongUUID];
    if(bi == nil){
        return nil;
    }
    if ([[bi allKeys] containsObject:key]) {
        return [bi objectForKey:key];
    }else{
        return nil;
    }
}

- (int)intervalTimeForDays:(NSDate *)beginTime endTime:(NSDate *)endTime
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [date setTimeZone:[NSTimeZone systemTimeZone]];
    
    [date setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSDate *d=[date dateFromString:beginTime];
    
    
    //转换成系统时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval1 = [zone secondsFromGMTForDate:d];
    NSDate *begindate = [d dateByAddingTimeInterval:interval1];
    NSTimeInterval begin=[begindate timeIntervalSince1970]*1;
    
    NSDate *e = [date dateFromString:endTime];
    NSInteger interval2 = [zone secondsFromGMTForDate:e];
    NSDate *enddate = [e dateByAddingTimeInterval:interval2];
    NSTimeInterval end=[enddate timeIntervalSince1970]*1;
    
//    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
//    NSInteger interval2 = [zone secondsFromGMTForDate:dat];
//    NSDate *enddate = [dat dateByAddingTimeInterval:interval2];
//    
//    NSTimeInterval now=[enddate timeIntervalSince1970]*1;
    
    
    NSString *timeString=@"";
    
    NSTimeInterval interval3=end - begin;
    
    if (interval3/86400 > 1)
    {
        timeString = [NSString stringWithFormat:@"%f", interval3/86400];
        //timeString = [timeString substringToIndex:timeString.length-7];
        return [timeString intValue] + 1;
    }
    return -1;
    
    //return 0;
}

- (void)playSound
{
    NSLog(@"%@",self.alarmUrl);
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)self.alarmUrl,&soundID);
    AudioServicesPlaySystemSound(soundID);
    
}

- (void)playSoundWithName:(NSString *)soundName
{
    NSString *soundPath=[[NSBundle mainBundle] pathForResource:@"alarm" ofType:@"caf"];
    NSURL *soundUrl=[[NSURL alloc] initFileURLWithPath:soundPath];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
//    _player.volume = 1.0;

//    AVAudioSession *session = [AVAudioSession sharedInstance];
//
//    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(audioRouteOverride),&audioRouteOverride);
//    [session setActive:YES error:nil];

    [_player play];
}


+ (NSString *)getCountryNum
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *country = [locale localeIdentifier];
    NSLog(@"国家：%@", country); //en_US
    //zh_CN
    NSArray *array = [country componentsSeparatedByString:@"_"]; //从字符A中分隔成2个元素的数组
    NSLog(@"array:%@",array);
    if (array == nil || array.count<2) {
        return @"CN";
    }
    NSString *code = [array objectAtIndex:1];
    
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    if ([dictCodes.allKeys containsObject:code]) {
        NSString *countryNum = [dictCodes objectForKey:code];
        if(!countryNum)
            countryNum = @"";
        
        return countryNum;
        
    }else{
        return @"CN";
    }
    
}

+ (NSString *)getCountryCode
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *country = [locale localeIdentifier];
    NSLog(@"国家：%@", country); //en_US
    //zh_CN
    NSArray *array = [country componentsSeparatedByString:@"_"]; //从字符A中分隔成2个元素的数组
    NSLog(@"array:%@",array);
    
    NSString *countryCode = nil;
    if([array count] >= 2)
        countryCode = [array objectAtIndex:1];
    
    return countryCode == nil ? @"" : countryCode;
}

+ (NSString *)getSysLanguage
{
    NSArray *languageArray = [NSLocale preferredLanguages];
    if (languageArray == nil || languageArray.count<=0) {
        return @"en";
    }
    NSString *language = [languageArray objectAtIndex:0];
    NSLog(@"语言：%@", language);//en
    return language;
}

-(NSString*)getdid{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString* did = [ud objectForKey:CONFIG_KEY_DEVICEID];
    if(did == nil){
        CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
        CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
        CFRelease(uuid_ref);
        NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
        CFRelease(uuid_string_ref);
        [ud setObject:uuid forKey:CONFIG_KEY_DEVICEID];
        [ud synchronize];
        return uuid;
    }else{
        return did;
    }
    
}

-(BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end
