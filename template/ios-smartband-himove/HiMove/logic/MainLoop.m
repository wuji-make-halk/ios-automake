//
//  MainLoop.m
//  IntelligentRingKing
//
//  Created by qf on 14-5-30.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "MainLoop.h"
#import "DataCenter.h"
#import "BandInfo.h"
#import "RunRecord+CoreDataClass.h"
#import "CZJKOTAViewController.h"
#import "IRKCommonData.h"
#import "CommonDefine.h"
#import "TaskManager.h"
#import "SXRPhoto2ViewController.h"
#import "Health_data_history+CoreDataClass.h"



#define TWO_BYTE(HIGH_BYTE,LOW_BYTE) ((HIGH_BYTE << 8) & 0xFF00) | LOW_BYTE
#define THREE_BYTE(BYTE1,BYTE2,BYTE3) ((BYTE1 << 16) & 0xFF0000) | ((BYTE2 << 8) & 0xFF00) | (BYTE3 & 0xFF)

@interface MainLoop()<SyncNotifyViewDelegate>
@property(nonatomic,strong)KLCPopup* popup;
@property(nonatomic,strong)SyncNotifyView* notifyView;
@property (nonatomic, strong)NSMutableArray* commandlist;
@property (nonatomic, assign)int sub_state;
@property (nonatomic, strong)NSString* current_command;
@property (nonatomic, assign)int expect_response_count;
@property (nonatomic, assign)int current_response_count;
@property (nonatomic, strong)NSMutableData* cachedata;
@property (nonatomic, assign)NSInteger getfwtimeout;
@property (nonatomic, assign)NSInteger getmactimeout;

@property (nonatomic, strong)NSDate *curSyncSprotDate;
@property (nonatomic, strong)NSDate *lastSyncSprotDate;

@property (nonatomic, assign) NSUInteger setAlarmNameIndex;

@property (nonatomic, strong) IRKCommonData* commondata;
@property (nonatomic, strong) DataCenter* datacenter;
@property (nonatomic, strong) BleControl* blecontrol;
@end

@implementation MainLoop

+(MainLoop *)SharedInstance
{
    static MainLoop *mainloop = nil;
    if (mainloop == nil) {
        mainloop = [[MainLoop alloc] init];
    }
    return mainloop;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.waitStableTmr = nil;
        self.commondata = [IRKCommonData SharedInstance];
        self.datacenter = [DataCenter SharedInstance];
        self.commandlist = [[NSMutableArray alloc] init];
//        [self.commondata loadconfig];
        self.blecontrol = [BleControl SharedInstance];
        self.blecontrol.delegate = self;
        self.is_thread_run = YES;
        self.rssilist = [[NSMutableArray alloc] init];
        self.is_send_alarm = NO;
        self.playmusicType = PLAYMUSICTYPE_STOP;
        self.backgroundIdentifier = UIBackgroundTaskInvalid;
        self.antilost_relay_timer = nil;
        self.getfwtimeout = 0;
        self.getmactimeout = 0;
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = appdelegate.managedObjectContext;
        
        [self initplayer];
        
        //连接默认手环
        //注册进入前台和后台的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Foreground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResigActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Background) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        double version = [[UIDevice currentDevice].systemVersion doubleValue];
        if (version >= 7.0){
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lanchcbp:) name:UIApplicationLaunchOptionsBluetoothPeripheralsKey object:nil];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preparetoplay:) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTakePhoto:) name:notify_key_take_photo object:nil];//手环控制手机拍照

//        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(connectDefaultDevice:) userInfo:nil repeats:YES];
//        [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(sendReadDetailData:) userInfo:nil repeats:YES];
        
        //       [NSThread detachNewThreadSelector:@selector(mainloop:) toTarget:self withObject:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calldisconnect:) name:notify_key_event_call_disconnected object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callconnect:) name:notify_key_event_call_connected object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callincoming:) name:notify_key_event_call_incoming object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HasReminder:) name:notify_key_has_reminder object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWeatherUpdate:) name:notify_key_weather_update object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayMusicStateChange:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SyncHsitoryData) name:notify_key_start_sync_history object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onheartbeat:) name:notify_key_heartbeat object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidFinishSendCmd) name:notify_key_did_finish_send_cmd object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidFinishSendCmd) name:notify_key_did_finish_send_cmd_err object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidFinishSendWeather) name:notify_key_did_finish_weather_cmd object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSendNextCommand:) name:notify_key_next_command object:nil];

//        self.center = [[CTCallCenter alloc] init];
//        self.center.callEventHandler = ^(CTCall *call) {
//            if (call.callState == CTCallStateDisconnected) {
//                NSLog(@"Call is Disconnect!");
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_event_call_disconnected object:nil];
//            } else if (call.callState == CTCallStateConnected) {
//                NSLog(@"Call is Connect!");
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_event_call_connected object:nil];
//            } else if(call.callState == CTCallStateIncoming) {
//                NSLog(@"Call is Incoming!");
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_event_call_incoming object:nil];
//            } else if (call.callState == CTCallStateDialing) {
//                NSLog(@"Call is Dialing!");
//            } else {
//                //NSLog(@"None of the conditions");
//            }
//        };
        
    }
    return self;
}

-(void) initplayer{
    //for device simulator
    //   return;
    if(self.musicplayer == nil){
        self.musicplayer = [MPMusicPlayerController systemMusicPlayer];
        self.musicplayer.repeatMode = MPMusicRepeatModeAll;
        [self.musicplayer beginGeneratingPlaybackNotifications];
        NSUInteger p = [self.musicplayer indexOfNowPlayingItem];
        if (p == NSNotFound) {
            MPMediaQuery* query = [MPMediaQuery songsQuery];
            [self.musicplayer setQueueWithQuery:query];
        }
        
    }

}

-(void)Foreground
{
    //初始化一遍播放器：放到viewWillAppear里以后就不会执行
//    [self initplayer];
    self.runmode = RUNMODE_ACTIVE;
    NSLog(@"Foreground");
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_start_location object:nil];
//#ifdef CUSTOM_API2
//    [self SyncCurrentData];
    [self.blecontrol connectDefaultDevice];
//#else
//    [self SyncCurrentData];
//#endif
//    if (self.backgroundtimer) {
//        [self.backgroundtimer invalidate];
//        self.backgroundtimer = nil;
//    }
}
-(void)Background{
}
-(void)lanchcbp:(NSNotification*)notify{
    NSLog(@"lanchcbp %@",notify);
}

//-(void)onheartbeat:(NSNotification*)notify{
////    [self startReadCurrentData];
//}
-(void)willResigActive{
    NSLog(@"willResigActive");

    self.runmode = RUNMODE_BACKGROUD;
//    self.commondata.is_enable_incomingcall = YES;
    if (self.commondata.is_enable_incomingcall) {
        //不用app再做来电通知功能了
        //判断ios版本和firmware是否支持ANCS
//        double version = [[UIDevice currentDevice].systemVersion doubleValue];
//        if (version >= 9.0){
//            return;
//        }else{
//            NSDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
//            if (bonginfo) {
//                NSString* versioncode = [bonginfo objectForKey:BONGINFO_KEY_VERSIONCODE];
//                if (versioncode) {
//                    int version = versioncode.intValue;
//                    if (version>=ANCS_SUPPORT_VERSIONCODE) {
//                        
//                        return;
//                    }
//
//                }
//
//            }
//
//        }

//        UIApplication *app = [UIApplication sharedApplication];
//        UIBackgroundTaskIdentifier taskID;
//        taskID = [app beginBackgroundTaskWithExpirationHandler:^{
//            //如果系统觉得我们还是运行了太久，将执行这个程序块，并停止运行应用程序
//            NSLog(@"--------end now-------------");
//            [app endBackgroundTask:taskID];
//        }];
//        if (taskID == UIBackgroundTaskInvalid) {
//            NSLog(@"Failed to start background task!");
//            return;
//        }
//        self.backgroundIdentifier = taskID;
//        static dispatch_once_t onceToken;
//        static int is_send_heartbeat = 0;
//        dispatch_once(&onceToken, ^{
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                NSLog(@"oncetoken = %ld",onceToken);
//                while (1) {
//                    [NSThread sleepForTimeInterval:1];
//                    if (self.commondata.is_enable_incomingcall == NO) {
//                        NSLog(@"is_enable_incomingcall=no");
//                        break;
//                    }
//                    NSTimeInterval backgroundTimeRemaining = [[UIApplication sharedApplication] backgroundTimeRemaining];
//                    //                NSLog(@"Finishing background task with %f seconds remaining",backgroundTimeRemaining);
//                    
//                    //应用处于前台时，backgroundTimeRemaining值weiDBL_MAX
//                    if (backgroundTimeRemaining == DBL_MAX) {
////                        NSLog(@"Background time remaining = Undetermined");
//                        is_send_heartbeat = 0;
//                        
//                    } else {
////                        NSLog(@"Background time remaining = %.02f seconds", backgroundTimeRemaining);
//                        if (is_send_heartbeat == 0 && backgroundTimeRemaining <30) {
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_heartbeat object:nil];
//                                
//                            });
//                            is_send_heartbeat = 1;
//                        }
//                    }
//                }
//                onceToken = 0;
//                [[UIApplication sharedApplication] endBackgroundTask:self.backgroundIdentifier];
//                
//            });
//        });
//        NSLog(@"Starting background task with %f seconds remaining", app.backgroundTimeRemaining);
    }
    
    
//    [self sendReadData:nil];
//    if (self.backgroundtimer) {
//        [self.backgroundtimer invalidate];
//        self.backgroundtimer = nil;
//    }
//    self.backgroundtimer = [NSTimer scheduledTimerWithTimeInterval:HJT_C6_TIMEOUT target:self selector:@selector(sendReadData:) userInfo:nil repeats:YES];
}

-(void)connectDefaultDevice:(NSNotification*)notify{
    ////////////////////////////
    return;
    
    NSLog(@"MainLoop::connectDefaultDevice need to connectDefaultDevice %@",self.commondata.lastBongUUID);
//#ifdef CUSTOM_API2
//#else
//    if (self.sync_type != OPERATOR_SYNC_NIL && self.blecontrol.is_connected != IRKConnectionStateConnected) {
//        if (self.connecttimeout == nil) {
//            self.connecttimeout = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onConnectTimeout:) userInfo:self repeats:NO];
//        }
//
//    }
//    
//#endif

    [self.blecontrol connectDefaultDevice];
    return;
    
}
//
//-(void)sendReadData:(NSNotification*)notify{
//    NSLog(@"MainLoop::sendReadDeviceData");
//    [self api_read_DeviceData:HJT_PARAM_LID_CURRENT_STEPS];
//}

//-(void)HasReminder:(NSNotification*)notify{
//    NSLog(@"MainLoop::HasReminder");
//    if (self.commondata.is_enable_remindernotify) {
//        self.commondata.alarmEvent->is_calendar = YES;
//        
//       
//        [self api_send_alarm];
//        [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(stopReminder:) userInfo:nil repeats:NO];
//    }
//}

-(void)onWeatherUpdate:(NSNotification *)notify{
    NSLog(@"onWeatherUpdate");
    //创智杰科不需要天气
//    
//#ifdef CUSTOM_JJT_COMMON
//#elif defined(CUSTOM_WISTARS)
//#elif defined(CUSTOM_MGCOOLBAND2)
//#else
//    if ([self.commondata.weathertype count] == 0) {
//        return;
//    }
//#ifdef CUSTOM_API2
//#else
//    if (self.sync_type != OPERATOR_SYNC_NIL || self.current_state != CURRENT_STATE_READY) {
//        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onWeatherUpdate:) userInfo:nil repeats:NO];
//        return;
//    }
//    self.sync_type = OPERATOR_SYNC_WEATHER;
//#endif
//    NSNumber* type = [self.commondata.weathertype objectAtIndex:0];
//    IRKPhone2DeviceWeather weather;
//    weather.temperature = ceil(self.commondata.temp);
//    weather.weather_type = type.intValue;
//    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//        weather.temperature_type = TEMP_TYPE_C;
//    }else{
//        weather.temperature_type = TEMP_TYPE_F;
//    }
//   [self api_send_weather:weather];
//#endif
}


//-(void)stopReminder:(NSNotification*)notify{
//    self.commondata.alarmEvent->is_calendar = NO;
//    //    IRKPhone2DeviceAlarms alarms;
//    //    alarms.is_calendar = NO;
//    //    alarms.is_call = NO;
//    //    alarms.is_email = NO;
//    //    alarms.is_phone_lowpower = NO;
//    //    alarms.is_sms = NO;
//    
//    [self api_send_alarm];
//}
-(void)preparetoplay:(NSNotification*)notify{
    NSLog(@"preparetoplay %@",notify);
}
-(void)onPlayMusicStateChange:(NSNotification*)notify{
    
    NSLog(@"  %@",notify);
    NSNumber* state = [notify.userInfo objectForKey:@"MPMusicPlayerControllerPlaybackStateKey"];
    if (state.integerValue == MPMusicPlaybackStateInterrupted) {
        if (self.playmusicType == PLAYMUSICTYPE_PLAY) {
 //           AVAudioSession *session = [AVAudioSession sharedInstance];
            
 //           UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
 //           AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(audioRouteOverride),&audioRouteOverride);
 //           [session setActive:YES error:nil];
//            NSLog(@"play");
//            //[self.musicplayer prepareToPlay];
//            [self performSelector:@selector(rePlay) withObject:nil afterDelay:1.2];

//            [self.musicplayer pause];
//            [NSThread sleepForTimeInterval:0.5];
//            [self.musicplayer play];
        }
    }/*else if(state.integerValue == MPMusicPlaybackStatePaused){
        if (self.playmusicType == PLAYMUSICTYPE_PLAY) {
            [self.musicplayer play];
            //            [self.musicplayer play];
        }
        
    }
      */
    
}

-(void)rePlay
{
    
    [self.musicplayer play];
}

//-(void)sendReadDetailData:(NSNotification*)notify{
//    //    NSLog(@"MainLoop::sendReadDetailData");
//    NSDate* currentdate = [NSDate date];
//
//
//    NSDate* lastReadDate = [NSDate dateWithTimeIntervalSince1970:self.commondata.lastReadDataTime];
//    NSTimeInterval interval = [currentdate  timeIntervalSinceDate:lastReadDate];
//    if (interval > (HJT_MAX_STORE_DATA_TIME + 24*60*60) || interval< 0) {
//        NSDate* sevendayago = [NSDate dateWithTimeIntervalSinceNow:-HJT_MAX_STORE_DATA_TIME];
//        NSDateFormatter* format = [[NSDateFormatter alloc] init];
//        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//        [format setTimeZone:[NSTimeZone systemTimeZone]];
//        
//        [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
//        
//        NSString* lastday = [format stringFromDate:sevendayago];
//        NSDate* lastdate = [format dateFromString:lastday];
//        self.commondata.lastReadDataTime = [lastdate timeIntervalSince1970];
//        [self.commondata saveconfig];
//        lastReadDate = [NSDate dateWithTimeIntervalSince1970:self.commondata.lastReadDataTime];
//        interval = HJT_MAX_STORE_DATA_TIME;
//    }
//    NSLog(@"lastReadDate = %@",[lastReadDate descriptionWithLocale:[NSTimeZone systemTimeZone]]);
//    if(interval > 60*60){
//        
//        Byte length = 1;
//        
//        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
////        NSDateComponents *comps = [[NSDateComponents alloc] init];
//        NSInteger unitFlags = NSWeekdayCalendarUnit |NSHourCalendarUnit;
//        
//        NSDateComponents *comps = [calendar components:unitFlags fromDate:lastReadDate];
//        
//        Byte tmpweek = [comps weekday]-1;
//        if (tmpweek == 0)
//            tmpweek = 7;
//        Byte week = tmpweek;
//        Byte hour = [comps hour];
//        //        [self api_read_Sport_Data_Curve_Graph_byDate:week   Hour:hour Length:length];
//        [self api_read_Sport_Data_Curve_Graph_byDate:week   Hour:hour Length:length];
//        //        [self simudata:length]
//        
//    }
//    else{
//        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(SyncFinishDelay) userInfo:nil repeats:NO];
//        //翔德版本在此断链，不再重复连接
//        if (self.sync_type == OPERATOR_SYNC_HISTORY) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_sycn_finish_need_reloaddata object:nil];
//
//            self.sync_type = OPERATOR_SYNC_NIL;
////            [self.blecontrol disconnectDevice2];
//        }
//
////        [self startReadHistoryData];
//    }
//    
//    //    [self api_read_DeviceData:HJT_PARAM_LID_CURRENT_STEPS];
//}

-(void)SyncFinishDelay{
    //同步完C4后接着发生A2命令
//    [self sendCmd:CMD_A2];
    [[TaskManager SharedInstance] AddUpLoadTaskBySyncKey:SYNCKEY_FITNESS];

    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_device_sync object:nil];
    
    //////////for healthkit/////////////
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_syncdata_to_healthkit object:nil userInfo:@{@"tablename":@"StepHistory"}];
    
}
//-(void)calldisconnect:(NSNotification*) notify{
////#ifdef CUSTOM_API2
//    if(self.commondata.is_enable_incomingcall){
//        NSString* cmd = [NSString stringWithFormat:@"%@:0",CMD_SENDALARM];
//        [self sendCmd:cmd];
//    }
////#else
////    if (self.commondata.is_enable_incomingcall) {
////        
////        NSLog(@"calldisconnect ");
////        self.commondata.alarmEvent->is_call = NO;
////        [self api_send_alarm];
////        
////    }
////#endif
//}
//
//-(void)callconnect:(NSNotification*) notify{
////#ifdef CUSTOM_API2
//    if(self.commondata.is_enable_incomingcall){
//        NSString* cmd = [NSString stringWithFormat:@"%@:0",CMD_SENDALARM];
//        [self sendCmd:cmd];
//    }
////#else
////
////    if (self.commondata.is_enable_incomingcall) {
////        
////        NSLog(@"callconnect");
////        self.commondata.alarmEvent->is_call = NO;
////        [self api_send_alarm];
////        
////    }
////#endif
//}
//
//-(void)callincoming:(NSNotification*) notify{
//#ifdef CUSTOM_API2
//    if(self.commondata.is_enable_incomingcall){
//        NSString* cmd = [NSString stringWithFormat:@"%@:128",CMD_SENDALARM];
//        [self sendCmd:cmd];
//    }
//#else
//    if (self.commondata.is_enable_incomingcall) {
//        
//        NSLog(@"callincoming");
//        self.commondata.alarmEvent->is_call = YES;
//        [self api_send_alarm];
//        
//    }
//#endif
//}

//
//-(void)ReadBongBatteryLevel{
//    NSLog(@"MainLoop::ReadBongBatteryLevel");
//    [self api_read_BatteryLevel];
//}


//-(void) checkreminder:(id)sender{
//    NSLog(@"start checkreminders now ......");
//    while(1){
//        if (self.commondata.is_access_to_reminder) {
//            NSDate* now = [NSDate date];
//            NSDate* next = [NSDate dateWithTimeInterval:CHECK_REMINDER_TIMEINTERVAL sinceDate:now];
//            //            NSLog(@"%@,%@",now,next);
//            NSPredicate* predicate = [self.ekstore predicateForIncompleteRemindersWithDueDateStarting:now ending:next calendars:nil];
//            [self.ekstore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
//                if ([reminders count] > 0) {
//                    NSLog(@"%@",reminders);
//                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_has_reminder object:nil];
//                }
//            }];
//            [NSThread sleepForTimeInterval:CHECK_REMINDER_TIMEINTERVAL];
//            
//        }
//        else
//            [NSThread sleepForTimeInterval:10];
//    }
//}
//

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//-(void)setPersonInfo{
//    if (self.commondata.is_need_sycn_persondata) {
//        [self api_set_Personal_data];
//        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(setPersonInfo) userInfo:nil repeats:NO];
//    }
//}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma music control
-(void)music_play{
//    if(self.musicplayer){
//        self.musicplayer = nil;
 //   }
//    self.musicplayer = [MPMusicPlayerController iPodMusicPlayer];
//    self.musicplayer.repeatMode = MPMusicRepeatModeAll;

    MPMusicPlaybackState playbackState = [self.musicplayer playbackState];
    NSLog(@"playbackstate = %ld",(long)playbackState);
    if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused || playbackState == MPMusicPlaybackStateInterrupted) {
        self.playmusicType = PLAYMUSICTYPE_PLAY;
        
        [self.musicplayer play];
    } else if (playbackState == MPMusicPlaybackStatePlaying) {
        self.playmusicType = PLAYMUSICTYPE_STOP;
        [self.musicplayer pause];
    }
//    self.musicplayer = nil;
    
    
}

-(void)music_next{
    MPMusicPlaybackState playbackState = [self.musicplayer playbackState];
    NSLog(@"playbackstate = %ld",(long)playbackState);
    if (playbackState == MPMusicPlaybackStatePlaying){
        [self.musicplayer endSeeking];
        [self.musicplayer skipToNextItem];
        [self.musicplayer play];
    }
    
}

-(void)music_back{
//    [self.musicplayer endSeeking];
 //   [self.musicplayer skipToPreviousItem];
    //    if([self.musicplayer nowPlayingItem] == nil)
    //        [self.musicplayer skipToBeginning];
    
//    [self.musicplayer play];
    MPMusicPlaybackState playbackState = [self.musicplayer playbackState];
    NSLog(@"playbackstate = %ld",(long)playbackState);
    if (playbackState == MPMusicPlaybackStatePlaying){
        [self.musicplayer endSeeking];
        [self.musicplayer skipToPreviousItem];
        [self.musicplayer play];
    }    

}

-(void)start_call_phone{
    NSLog(@"start_call_phone %@ ", self.player_call);
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
//        NSDate *now=[NSDate new];
        notification.fireDate=[NSDate date];//10秒后通知
        notification.repeatInterval=0;//循环次数，kCFCalendarUnitWeekday一周一次
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.applicationIconBadgeNumber=0; //应用的红色数字
        notification.soundName= @"alarm.caf";
        //去掉下面2行就不会弹出提示框
        //                notification.alertBody=@"";//提示信息 弹出提示框
        //                notification.alertAction = NSLocalizedString(@"Notify", nil);  //提示框按钮
        //notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
        
        // NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
        //notification.userInfo = infoDict; //添加额外的信息
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    return;
    
}

-(void)stop_call_phone{
    NSLog(@"stop_call_phone %@ ", self.player_call);
    [self.player_call pause];
    self.player_call = nil;
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"audioPlayerDidFinishPlaying %@",player);
    [player stop];
    self.player_call = nil;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)send_command:(NSString*)cmdname{
    
    NSLog(@"cmdName:%@",cmdname);
    NSData* senddata = nil;
    BOOL isAdvCharacteristic = NO;
    
    if ([cmdname isEqualToString:CMD_GETMAC]) {
        senddata = [self api2_Send_GetMac];
        self.sub_state = SUB_STATE_WAIT_FA_RSP;
    }else if ([cmdname isEqualToString:CMD_GETFW]){
        senddata = [self api2_Send_GetMInfo];
        self.sub_state = SUB_STATE_WAIT_FB_RSP;
    }else if ([cmdname isEqualToString:CMD_READTIME]){
        senddata = [self api2_Send_GetDeviceTime];
        self.sub_state = SUB_STATE_WAIT_READTIME_RSP;
    }else if ([cmdname hasPrefix:CMD_ADV_MONITOR]){
        NSArray* paramlist = [cmdname componentsSeparatedByString:@":"];
        NSInteger monitortype = [[paramlist objectAtIndex:1] integerValue];
        BOOL isreport = [[paramlist objectAtIndex:2] boolValue];
        senddata = [self api2_Send_Activity_Monitor:monitortype report:isreport];
        self.sub_state = SUB_STATE_WAIT_MONITOR_RSP;
        isAdvCharacteristic = YES;
    }else if ([cmdname hasPrefix:CMD_ANTILOST]){
        NSArray* paramlist = [cmdname componentsSeparatedByString:@":"];
        int antilosttype = [[paramlist objectAtIndex:1] intValue];
        senddata = [self api2_Send_Antilost:antilosttype];
        self.sub_state = SUB_STATE_WAIT_ANTILOST_RSP;
    }else if ([cmdname isEqualToString:CMD_C4]){
        senddata = [self api2_send_C4HistoryData];
        self.sub_state = SUB_STATE_WAIT_C4_RSP;
    }else if([cmdname isEqualToString:CMD_A2]){
        senddata = [self api2_send_A2SportData];
        self.sub_state = SUB_STATE_WAIT_A2_RSP;
    }else if ([cmdname isEqualToString:CMD_C6]){
        senddata = [self api2_Send_C6CurrentStep];
        self.sub_state = SUB_STATE_WAIT_C6_RSP;
    }else if ([cmdname isEqualToString:CMD_CLEAR]){
        senddata = [self api2_Send_Clear];
        self.sub_state = SUB_STATE_WAIT_CLEAR_RSP;
    }else if ([cmdname isEqualToString:CMD_SETPARAM]){
        senddata = [self api2_Send_Bandparam];
        self.sub_state = SUB_STATE_WAIT_SETPARAM_RSP;
    }else if ([cmdname hasPrefix:CMD_NOTIFICATION]){
        NSArray* paramlist = [cmdname componentsSeparatedByString:@":"];
        int optcode = [[paramlist objectAtIndex:1] intValue];
        senddata = [self api2_Send_Notification:optcode];
        self.sub_state = SUB_STATE_WAIT_NOTIFICATION;
    }else if ([cmdname isEqualToString:CMD_SETPERSON]){
        senddata = [self api2_Send_PersonalData];
        self.sub_state = SUB_STATE_WAIT_PERSONINFO_RSP;
    }else if([cmdname isEqualToString:CMD_LONGSIT]){
        senddata = [self api2_Send_LongsitData];
        self.sub_state = SUB_STATE_WAIT_LONGSIT;
    }else if([cmdname isEqualToString:CMD_SETHYDRATION]){
        senddata = [self api2_Send_HydrationData];
        self.sub_state = SUB_STATE_WAIT_SETSYDRATION_RSP;
    }else if ([cmdname isEqualToString:CMD_SETSLEEP]){
        senddata = [self api2_Send_Sleeptime];
        self.sub_state = SUB_STATE_WAIT_SETSLEEP_RSP;
    }else if ([cmdname isEqualToString:CMD_SETTIME]){
        senddata = [self api2_Send_SetDeviceTime];
        self.sub_state = SUB_STATE_WAIT_SETTIME_RSP;
    }else if ([cmdname isEqualToString:CMD_WEATHER]){
        senddata = [self api2_Send_Weather];
        self.sub_state = SUB_STATE_WAIT_WEATHER_RSP;
    }else if ([cmdname isEqualToString:CMD_SETSCREEN]){
        //        senddata = [self api2_Send_Screentime];
        senddata = [self api2_Send_Bandparam];
        self.sub_state = SUB_STATE_WAIT_SETSCREEN_RSP;
    }else if ([cmdname hasPrefix:CMD_SENDALARM]){
        NSArray* paramlist = [cmdname componentsSeparatedByString:@":"];
        int alarmtype = [[paramlist objectAtIndex:1] intValue];
        senddata = [self api2_Send_Alarm:alarmtype];
        self.sub_state = SUB_STATE_WAIT_ALARM_RSP;
    }else if ([cmdname isEqualToString:CMD_SPORTDATA]){
        senddata = [self api2_Send_Sync_Sport_Data];
        self.sub_state = SUB_STATE_WAIT_SPORTDATA_RSP;
        isAdvCharacteristic = YES;
    }else if ([cmdname isEqualToString:CMD_PAIR]){
        senddata = [self api2_Send_Pair];
        self.sub_state = SUB_STATE_WAIT_ANCSPAIR_RSP;
        //        isAdvCharacteristic = YES;
    }else if ([cmdname hasPrefix:CMD_SENSOR_CHANGE]){
        NSArray* paramlist = [cmdname componentsSeparatedByString:@":"];
        int alarmtype = [[paramlist objectAtIndex:1] intValue];
        int ison = [[paramlist objectAtIndex:2] intValue];
        int reporttype = [[paramlist objectAtIndex:3] intValue];
        senddata = [self api2_Send_Sensor:alarmtype isON:ison isReport:reporttype];
        self.sub_state = SUB_STATE_WAIT_SENSOR_CHANGE_RSP;
        //        isAdvCharacteristic = YES;
    }else if ([cmdname hasPrefix:CMD_NORDIC_INTO_OTA]){
        senddata = [self api2_Send_Nordic_intoOTA];
        self.sub_state = SUB_STATE_WAIT_NODIC_INTO_OTA_RSP;
        //        isAdvCharacteristic = YES;
    }else if ([cmdname hasPrefix:CMD_ALARM_NAME]){
        senddata = [self api2_alarm_name];
        self.sub_state = SUB_STATE_WAIT_ALARM_NAME;
        //        isAdvCharacteristic = YES;
    }else if ([cmdname hasPrefix:CMD_SENSORDATA]){
        NSArray* paramlist = [cmdname componentsSeparatedByString:@":"];
        int sensortype = [[paramlist objectAtIndex:1] intValue];
        senddata = [self api2_send_sensordata:sensortype];
        self.sub_state = SUB_STATE_WAIT_SENSORDATA_RSP;
    }
    else{
        NSLog(@"UNSUPPORT COMMAND");
        self.sub_state = SUB_STATE_IDLE;
        [self nextCommand];
        return;
    }
    
    self.cachedata = [[NSMutableData alloc] init];
    NSLog(@"send data = %@", senddata);
    if (senddata == nil) {
        self.sub_state = SUB_STATE_IDLE;
        [self nextCommand];
        return;
        
    }
    self.cmdResendtimer = [NSTimer scheduledTimerWithTimeInterval:DEFAULT_CMD_TIMEOUT target:self selector:@selector(onCmdTimeout:) userInfo:@{@"cmdname":cmdname} repeats:NO];
    
    if (isAdvCharacteristic) {
        [self.blecontrol submit_writeData:senddata forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_ADV_CHARATERISTIC_KEY withRespon:YES protocolcmd:0];
        
    }else{
        [self.blecontrol submit_writeData:senddata forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES protocolcmd:0];
    }
    
}
-(BOOL)CheckResponValid:(int)cmdname{
    if (self.sub_state == SUB_STATE_WAIT_C4_RSP && self.current_response_count > 0) {
        return YES;
    }
    if (self.sub_state == SUB_STATE_WAIT_SPORTDATA_RSP && self.current_response_count > 0) {
        return YES;
    }
    if (self.sub_state == SUB_STATE_WAIT_A2_RSP)
        return YES;
    if (self.sub_state == SUB_STATE_WAIT_SENSORDATA_RSP && self.current_response_count > 0) {
        return YES;
    }

    switch (self.sub_state) {
        case SUB_STATE_IDLE:
            return NO;
            break;
        case SUB_STATE_WAIT_C6_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_OK||
                cmdname == HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_ERR) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_ANTILOST_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_ANTILOST) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_C4_RSP:
            if (self.current_response_count == 0) {
                if (cmdname == HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_WEEK_OK||
                    cmdname == HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_WEEK_ERR) {
                    return YES;
                }else{
                    return NO;
                }
                
            }else{
                return YES;
            }
            break;
        case SUB_STATE_WAIT_SPORTDATA_RSP:
            if (self.current_response_count == 0) {
                if (cmdname == HJT_CMD_DEVICE2PHONE_SYNC_SPORT_DATA_OK||
                    cmdname == HJT_CMD_DEVICE2PHONE_SYNC_SPORT_DATA_ERR) {
                    return YES;
                }else{
                    return NO;
                }
                
            }else{
                return YES;
            }
            break;
        case SUB_STATE_WAIT_CLEAR_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_CLEAR_DATA_ERR||
                cmdname == HJT_CMD_DEVICE2PHONE_CLEAR_DATA_OK) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_FA_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_GETMAC) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_FB_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_MINFO) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_MONITOR_RSP:
            if (cmdname == HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_MONITOR_OK||
                cmdname == HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_MONITOR_ERR) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_PERSONINFO_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_SET_PERSONINFO_ERR||
                cmdname == HJT_CMD_DEVICE2PHONE_SET_PERSONINFO_OK) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_LONGSIT:
            if (cmdname == HJT_CMD_DEVICE2PHONE_LONGSIT_OK||
                cmdname == HJT_CMD_DEVICE2PHONE_LONGSIT_ERR) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_SETSYDRATION_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_SET_HYDRATION_OK) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_READTIME_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_READ_DEVICE_TIME_OK||
                cmdname == HJT_CMD_DEVICE2PHONE_READ_DEVICE_TIME_ERR) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_RESET_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_RESET_ERR||
                cmdname == HJT_CMD_DEVICE2PHONE_RESET_OK) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_SETPARAM_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_SET_BANDPRAM_OK||
                cmdname == HJT_CMD_DEVICE2PHONE_SET_BANDPRAM_ERR) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_SETSCREEN_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_SET_BANDPRAM_OK||
                cmdname == HJT_CMD_DEVICE2PHONE_SET_BANDPRAM_ERR) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_SETSLEEP_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_SET_SLEEP_TIME_OK||
                cmdname == HJT_CMD_DEVICE2PHONE_SET_SLEEP_TIME_ERR) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_SETTIME_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_SET_DEVICE_TIME_OK||
                cmdname == HJT_CMD_DEVICE2PHONE_SET_DEVICE_TIME_ERR) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_WEATHER_RSP:
            if (cmdname == HJT_CMD_PHONE2DEVICE_WEATHER) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_ALARM_RSP:
            if (cmdname == HJT_CMD_PHONE2DEVICE_ALARM) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_ANCSPAIR_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_ANCS_OK) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_SENSOR_CHANGE_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_SENSOR_CHANGE_OK||
                cmdname == HJT_CMD_DEVICE2PHONE_SENSOR_CHANGE_ERR) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_ALARM_NAME:
            if (cmdname == HJT_CMD_DEVICE2PHONE_SETALARMNAME_OK||
                cmdname == HJT_CMD_DEVICE2PHONE_SETALARMNAME_ERR) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_NOTIFICATION:
            if (cmdname == HJT_CMD_DEVICE2PHONE_NOTIFY_OK) {
                return YES;
            }else{
                return NO;
            }
            break;
        case SUB_STATE_WAIT_SENSORDATA_RSP:
            if (cmdname == HJT_CMD_DEVICE2PHONE_SENSORDATA_OK||
                cmdname == HJT_CMD_DEVICE2PHONE_SENSORDATA_ERR) {
                return YES;
            }else{
                return NO;
            }
            break;
        default:
            return NO;
            break;
    }
    
}

-(void)ReceiveData2:(NSData*)recvdata{
    //   NSLog(@"MainLoop::bleNotifyUpdate");
    //    NSData * recvdata = (NSData*)[[notification userInfo] objectForKey:@"data"];
    //    NSLog(@"ReceiveData  :: %@", recvdata);
    NSLog(@"RecvStr2 :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    Byte cmdname = bytearray[0];
    int cmdparamlen = bytearray[1];
    if (cmdname == HJT_CMD_DEVICE2PHONE_SENSORDATA_OK) {
//        在B1的回应消息里面长度位是2个字节来表示
        cmdparamlen = bytearray[1]*0x100+bytearray[2];
    }
    //    //pulzz收到0xA2命令的body长度为18b，需要特殊处理成12
    //    if (cmdname == HJT_CMD_PHONE2DEVICE_READ_SPORT_DATA_BY_DAY) {
    //        cmdparamlen = 12;
    //    }
    //特殊处理
    if ((cmdname == HJT_CMD_DEVICE2PHONE_ANTILOST && cmdparamlen != 0)||
        cmdname == HJT_CMD_DEVICE2PHONE_PHOTO ||
        cmdname == HJT_CMD_DEVICE2PHONE_MUSIC ||
        cmdname == HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_REPORT||
        cmdname == HJT_CMD_DEVICE2PHONE_SENSOR_REPORT||
        cmdname == HJT_CMD_PHONE2DEVICE_SENSOR_CHANGE) {
        if (cmdname == HJT_CMD_DEVICE2PHONE_ANTILOST){
            [self procAlarmRequest:recvdata];
        }
        if (cmdname == HJT_CMD_DEVICE2PHONE_MUSIC) {
            [self procMusicRequest:recvdata];
        }
        if (cmdname == HJT_CMD_DEVICE2PHONE_PHOTO) {
            [self procCameraRequest:recvdata];
        }
        if (cmdname == HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_REPORT) {
            [self procMonitorDataRsp:recvdata];
        }
        if (cmdname == HJT_CMD_DEVICE2PHONE_SENSOR_REPORT) {
            [self procSensorDataReport:recvdata];
        }
        //modify:app响应手环心率开关
        if(cmdname == HJT_CMD_PHONE2DEVICE_SENSOR_CHANGE){
            [self procSensorChange:recvdata];
        }
        
        return;
    }
    if (![self CheckResponValid:cmdname]) {
        NSLog(@"ReceiveData2 invalid message:%d in State:%d-%d",cmdname,self.current_state, self.sub_state);
        return;
    }
    if (self.current_response_count == 0) {
        self.expect_response_count = [self getExpectResponseCount:cmdparamlen];
    }
    self.current_response_count += 1;
    
    switch (self.sub_state) {
        case SUB_STATE_WAIT_NOTIFICATION:
            [self procNotification:recvdata];
            break;
        case SUB_STATE_WAIT_ANTILOST_RSP:
            [self procAntiLostRsp:recvdata];
            break;
        case SUB_STATE_WAIT_C4_RSP:
            [self procC4Rsp:recvdata];
            break;
        case SUB_STATE_WAIT_A2_RSP:
            [self procA2Rsp:recvdata];
            break;
        case SUB_STATE_WAIT_C6_RSP:
            [self procC6Rsp:recvdata];
            break;
        case SUB_STATE_WAIT_CLEAR_RSP:
            [self procClearRsp:recvdata];
            break;
        case SUB_STATE_WAIT_FA_RSP:
            [self procFARsp:recvdata];
            break;
        case SUB_STATE_WAIT_FB_RSP:
            [self procFBRsp:recvdata];
            break;
        case SUB_STATE_WAIT_MONITOR_RSP:
            [self procMonitorRsp:recvdata];
            break;
        case SUB_STATE_WAIT_PERSONINFO_RSP:
            [self procPersonInfoRsp:recvdata];
            break;
        case SUB_STATE_WAIT_SETSYDRATION_RSP:
            [self procHydrationRsp:recvdata];
            break;
        case SUB_STATE_WAIT_READTIME_RSP:
            [self procReadTimeRsp:recvdata];
            break;
        case SUB_STATE_WAIT_RESET_RSP:
            [self procResetRsp:recvdata];
            break;
        case SUB_STATE_WAIT_SETPARAM_RSP:
            [self procSetParamRsp:recvdata];
            break;
        case SUB_STATE_WAIT_SETSCREEN_RSP:
            [self procSetScreenRsp:recvdata];
            break;
        case SUB_STATE_WAIT_SETSLEEP_RSP:
            [self procSetSleepRsp:recvdata];
            break;
        case SUB_STATE_WAIT_SETTIME_RSP:
            [self procSetTimeRsp:recvdata];
            break;
        case SUB_STATE_WAIT_WEATHER_RSP:
            [self procWeatherRsp:recvdata];
            break;
        case SUB_STATE_WAIT_SPORTDATA_RSP:
            [self procSyncSportData:recvdata];
            break;
        case SUB_STATE_WAIT_ANCSPAIR_RSP:
            [self procPair:recvdata];
            break;
        case SUB_STATE_WAIT_LONGSIT:
            [self procLongSitRsp:recvdata];
            break;
        case SUB_STATE_WAIT_SENSORDATA_RSP:
            [self procSensorDataRsp:recvdata];
            break;
        case SUB_STATE_WAIT_ALARM_NAME:
            self.sub_state = SUB_STATE_IDLE;
            break;
            //        case SUB_STATE_WAIT_SENSOR_CHANGE_RSP:
            //            [self procSensorChange:recvdata];
            //            break;
        default:
            break;
    }
    
    if (self.current_response_count >= self.expect_response_count && self.current_state > STATE_CONNECT_LOST) {
        if (self.cmdResendtimer) {
            [self.cmdResendtimer invalidate];
            self.cmdResendtimer = nil;
        }
        self.sub_state = SUB_STATE_IDLE;
        [self nextCommand];
    }
    
}

-(void)procNotification:(NSData*)recvdata{
    NSLog(@"procNotification:%@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    Byte cmdname = bytearray[0];
    
    if (self.commondata.is_in_factory) {
        self.commondata.is_in_factory=NO;
        [self.commondata saveconfig];
        if (cmdname==0xFF) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"notify_key_tip_factory_ok" object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"notify_key_tip_factory_err" object:nil];
        }
        
    }
}

- (void)setNotification:(int)optcode{
    NSString* sendcmd = [NSString stringWithFormat:@"%@:%d",CMD_NOTIFICATION,optcode];
    if (![self.commandlist containsObject:sendcmd]) {
        [self sendCmd:sendcmd];

    }
    
    
    
//    [self.commandlist insertObject:CMD_NOTIFICATION atIndex:0];
//    [self nextCommand];
}

//设置消息通
- (NSData *)api2_Send_Notification:(int)optcode
{
    Byte buf[20] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_NOTIFY;
    
    //长度
    buf[1] = 0x11;
    //操作标志
//    if (self.commondata.is_in_factory) {
//        buf[2] = 3;
//    }else{
//        buf[2] = 0;
//    }
    buf[2] = optcode;
    
    //提醒类型开关1
    if(self.commondata.is_enable_incomingcall)
    {
        buf[3] = 1 << 7;
    }
    
    if(self.commondata.is_enable_smsnotify)
    {
        buf[3] = buf[3] | (1 << 6);
    }
    
    if (self.commondata.is_enable_facebooknotify) {
        buf[3] = buf[3] | (1 << 2);
    }
    
    if (self.commondata.is_enable_twitternotify) {
        buf[3] = buf[3] | (1 << 1);
    }
    
    //提醒类型开关2
    if(self.commondata.is_enable_wechatnotify)
    {
        buf[4] = 1 << 7;
    }
    if(self.commondata.is_enable_qqnotify)
    {
        buf[4] = buf[4] | (1 << 6);
    }
    
    if (self.commondata.is_enable_skypenotify) {
        buf[4] = buf[4] | (1 << 5);
    }
    
    if (self.commondata.is_enable_linenotify) {
        buf[4] = buf[4] | (1 << 4);
    }
    
    if (self.commondata.is_enable_whatsappnotify) {
        buf[4] = buf[4] | (1 << 3);
    }
    //自动心率，自动体温
    NSDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    int heart = 0;
    int temp = 0;
    if (bonginfo) {
        NSNumber* bh = [bonginfo objectForKey:BONGINFO_KEY_AUTOHEART];
        if (bh) {
            heart = bh.intValue;
            
        }
        NSNumber* bt = [bonginfo objectForKey:BONGINFO_KEY_AUTOTEMP];
        if (bt) {
            temp = bt.intValue;
        }
    }
    buf[5] = 0;
    buf[6] = 0;
    buf[8] = heart;
    buf[9] = temp;
    
//    for(int i = 5; i < 19;i++)
//    {
//        buf[i] = 0x00;
//    }
    
    Byte checksum = buf[2];
    for(int i= 3; i < 19; i++){
        checksum = checksum^buf[i];
    };
    buf[19] = checksum;
    
    NSData * data = [NSData dataWithBytes:buf length:20];
    NSLog(@"send api2_Send_Notification buf = %@",data);
    return data;
}

- (void)setConfigParam
{
    if ([self.commandlist containsObject:CMD_SETPARAM]) {
        [self.commandlist removeObject:CMD_SETPARAM];
    }
    [self.commandlist insertObject:CMD_SETPARAM atIndex:0];
    
    [self nextCommand];
}

//9b命令
-(NSData*)api2_Send_Bandparam{
    Byte buf[20] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_SET_PARAM;
    buf[1] = 0x11;
    if ([self.commondata is24time]) {//时间制
        buf[2] = 1;
    }else{
        buf[2] = 0;
    }
    buf[3]=0;//温度摄氏度
    
    buf[4] = self.commondata.screentime;//灭屏时间
    buf[5]=0;//正屏
    
    //单位制
    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) buf[6] = 1;
    else buf[6] = 2;
    
    //震动
    //默认is_enable_lowbatteryalarm=YES
    //if (self.commondata.is_enable_lowbatteryalarm == YES) {
    if (self.commondata.is_enable_antilost == YES) buf[7] = 1;
    else buf[7] = 2;
    //    }else{
    //        buf[7] = 0;
    //    }
    
    buf[8] = self.commondata.is_enable_bringScreen;//翻腕亮屏
    
    NSString* lang = NSLocalizedString(@"lang", nil);
    if ([lang isEqualToString:@"chs"]) {//中文
        buf[9] = 1;
    }else if ([lang isEqualToString:@"rus"]) {//俄语
        buf[9] = 2;
    }else if ([lang isEqualToString:@"ukr"]){//乌克兰语
        buf[9] = 3;
    }else{
        buf[9] = 0;
    }
    
    buf[10] = self.commondata.is_enable_nodistrub;
    
    NSMutableDictionary* bonginfo = (NSMutableDictionary*)[self.commondata getBongInformation:self.commondata.lastBongUUID];
    
    if (bonginfo){
        NSString *beginDate = [bonginfo objectForKey:BONGINFO_KEY_DISTURB_STARTTIME];
        NSString *endDate = [bonginfo objectForKey:BONGINFO_KEY_DISTURB_ENDTIME];
        
        NSString *hour = nil;
        NSString *minute = nil;
        NSArray *array = [beginDate componentsSeparatedByString:@":"];
        if([array count] >= 2)
        {
            hour = [array objectAtIndex:0];
            minute = [array objectAtIndex:1];
        }
        
        buf[11] = hour.intValue;
        buf[12] = minute.intValue;
        
        array = [endDate componentsSeparatedByString:@":"];
        if([array count] >= 2)
        {
            hour = [array objectAtIndex:0];
            minute = [array objectAtIndex:1];
        }
        
        buf[13] = hour.intValue;
        buf[14] = minute.intValue;
    }else{
        buf[11] = 23;
        buf[12] = 0;
        buf[13] = 8;
        buf[14] = 0;
    }
    
    buf[15] = 0;//横竖屏
    buf[16] = 0;//日期显示方式
    buf[17] = 1;//系统标识1.iOS
    
    if (self.commondata.is_enable_autoheart) {
        buf[18] = 0;//心率检测模式0.自动
    }else{
        buf[18] = 1;//手动
    }
    
    
    Byte checksum = buf[2];
    for(int i= 3; i < 19; i++){
        checksum = checksum^buf[i];
    };
    buf[19] = checksum;
    
    NSData * data = [NSData dataWithBytes:buf length:20];
    NSLog(@"send api2_Send_Bandparam buf = %@",data);
    return data;
}

//88命令
-(NSData*)api2_Send_Clear{
    Byte buf[200] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_CLEAR_DATA;
    buf[1] = 0;
    buf[2] = 0;
    NSData * data = [NSData dataWithBytes:buf length:3];
    NSLog(@"send api2_Send_Clear = %@",data);
    return data;
}

-(void)procClearRsp:(NSData*)recvdata{
    NSLog(@"procClearRsp :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    Byte cmdname = bytearray[0];
    //    Byte cmdparamlen = bytearray[1];
    if (cmdname == HJT_CMD_DEVICE2PHONE_CLEAR_DATA_OK) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_clear_ok object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_clear_err object:nil];
    }
    
}

#pragma msg api
//-(int8_t)getChecksum:(NSData*)data{
//    if([data length] < 3)
//        return 0;
//    int8_t* bytearray =(int8_t*)[data bytes];
//    int8_t l = bytearray[1];
//    if(l == 0)
//        return 0;
//    int8_t checksum = bytearray[2];
//    for(int i = 3; i<l; i++){
//        checksum = checksum^bytearray[i];
//    }
//    return checksum;
//}

//-(void)api_set_Clear{
//    Byte buf[200] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_CLEAR_DATA;
//    buf[1] = 0;
//    buf[2] = 0;
//    NSData * data = [NSData dataWithBytes:buf length:3];
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES protocolcmd:HJT_CMD_PHONE2DEVICE_CLEAR_DATA];
//    
//}
//
//
//-(void)api_get_DeviceTime{
//    Byte buf[200] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_READ_DEVICE_TIME;
//    buf[1] = 0;
//    buf[2] = 0;
//    NSData * data = [NSData dataWithBytes:buf length:3];
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES protocolcmd:HJT_CMD_PHONE2DEVICE_READ_DEVICE_TIME];
//    
//}
//
//-(void)api_set_DeviceTime:(Byte)year M:(Byte)month D:(Byte)day H:(Byte)hour MM:(Byte)minute S:(Byte)second W:(Byte)week{
//    Byte buf[200] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_SET_DEVICE_TIME;
//    buf[1] = 0x07;
//    buf[2] = year;
//    buf[3] = month;
//    buf[4] = day;
//    buf[5] = hour;
//    buf[6] = minute;
//    buf[7] = second;
//    buf[8] = week;
//    buf[9] = buf[2]^buf[3]^buf[4]^buf[5]^buf[6]^buf[7]^buf[8];
//    NSData * data = [NSData dataWithBytes:buf length:10];
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES protocolcmd:HJT_CMD_PHONE2DEVICE_SET_DEVICE_TIME];
//    
//    //   [self.blecontrol writeDataToBle:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES];
//}
//
//-(void)api_read_DeviceData:(Byte)Lid{
//    Byte buf[200] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_READ_DEVICE_DATA;
//    buf[1] = 0x01;
//    buf[2] = Lid;
//    buf[3] = Lid;
//    
//    NSData * data = [NSData dataWithBytes:buf length:4];
//    //    NSLog(@"send buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES protocolcmd:HJT_CMD_PHONE2DEVICE_READ_DEVICE_DATA];
//    //    [self.blecontrol writeDataToBle:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES];
//    
//}
//
//-(void)api_read_Sport_Data_Curve_Graph_byDate:(Byte)daysofweek Hour:(Byte)hour Length:(Byte)length{
//    Byte buf[200] = {'\0'};
//    
//    buf[0] = HJT_CMD_PHONE2DEVICE_READ_DATA_CURVE_BY_WEEK;
//    buf[1] = 0x03;
//    buf[2] = daysofweek;
//    buf[3] = hour;
//    buf[4] = length;
//    buf[5] = buf[2]^buf[3]^buf[4];
//    int len = 6;
//    /*
//     buf[0] = 0xc4;
//     buf[1] = 0x03;
//     buf[2] = 0x01;
//     buf[3] = 0x06;
//     buf[4] = 0x03;
//     buf[5] = 0x04;
//     int len = 6;
//     */
//    NSData * data = [NSData dataWithBytes:buf length:len];
//    NSLog(@"send api_read_Sport_Data_Curve_Graph_byDate buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES protocolcmd:HJT_CMD_PHONE2DEVICE_READ_DATA_CURVE_BY_WEEK];
//    //    [self.blecontrol writeDataToBle:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES];
//    
//}
//
//
//-(void)api_read_BatteryLevel{
//    [self.blecontrol submit_readData:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_BATTERY_CHARATERISTIC_KEY];
//    //    [self.blecontrol readDataToBle:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_BATTERY_CHARATERISTIC_KEY];
//    
//}
//
//-(void)api_send_alarm{
//    Byte buf[20] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_ALARM;
//    buf[1] = 2;
//    buf[2] = 0;
//    buf[3] = 0;
//    if(self.commondata.alarmEvent->is_call&&self.commondata.is_enable_incomingcall){
//        buf[2] = buf[2]| 0x80;
//    }
//    //    if(self.commondata.alarmEvent->is_email && self.commondata.is_enable_mailnotify){
//    //        buf[2] = buf[2]| 0x02;
//    //    }
//    //    if(self.commondata.alarmEvent->is_sms&&self.commondata.is_enable_smsnotify){
//    //        buf[2] = buf[2]| 0x04;
//    //    }
//    //    if(self.commondata.alarmEvent->is_calendar&&self.commondata.is_enable_remindernotify){
//    //        buf[2] = buf[2]| 0x08;
//    //    }
//    //    if(self.commondata.alarmEvent->is_phone_lowpower&&self.commondata.is_enable_lowbatteryalarm){
//    //        buf[2] = buf[2]| 0x10;
//    //    }
//    buf[4] = buf[2]^buf[3];
//    NSData * data = [NSData dataWithBytes:buf length:5];
//    NSLog(@"send api_send_alarm buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:NO protocolcmd:buf[0]];
//    
//    
//}
//-(void)api_set_SleepMode:(BOOL)sleepmode ShackMode:(BOOL)shackmode{
//    Byte buf[8] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_MODESET;
//    buf[1] = 1;
//    if(sleepmode){
//        buf[2] = 0x80;
//    }else{
//        buf[2] = 0x00;
//    }
//    if(shackmode){
//        buf[2] = buf[2]+ 0x40;
//    }else{
//        buf[2] = buf[2]+ 0x00;
//    }
//    buf[3] = buf[2];
//    NSData * data = [NSData dataWithBytes:buf length:8];
//    NSLog(@"send api_send_modeset buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:NO protocolcmd:buf[0]];
//    
//}
//    


-(void)api_send_weather:(IRKPhone2DeviceWeather)evt{
//#ifdef CUSTOM_API2
    [self sendCmd:CMD_WEATHER];
//#else
//    Byte buf[8] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_WEATHER;
//    buf[1] = 0x3;
//    buf[2] = evt.weather_type;
//    if(evt.temperature >= 0)
//        buf[3] = buf[3]|0x80;
//    else
//        buf[3] = buf[3] & 0x4F;
//    if (evt.temperature_type == TEMP_TYPE_C)
//        buf[3] = buf[3] | 0x40;
//    else
//        buf[3] = buf[3] & 0xBF;
//    
//    buf[4] = abs(evt.temperature);
//    buf[5] = buf[2]^buf[3]^buf[4];
//    
//    NSData * data = [NSData dataWithBytes:buf length:8];
//    NSLog(@"send api_send_alarm buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:NO protocolcmd:buf[0]];
//#endif
    
}


-(void)api_send_antilost:(int)type{
//#ifdef CUSTOM_API2
    NSString* cmd = [NSString stringWithFormat:@"%@:%d",CMD_ANTILOST,type];
    [self sendCmd:cmd];
//#else
//    Byte buf[8] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_ANTILOST;
//    buf[1] = 0x01;
//    buf[2] = type;
//    buf[3] = type;
//    
//    NSData * data = [NSData dataWithBytes:buf length:8];
//    NSLog(@"send api_send_alarm buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:NO protocolcmd:buf[0]];
//#endif
    
}
//-(void)api_send_GetMAC{
//    Byte buf[8] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_GETMAC;
//    buf[1] = 0x00;
//    buf[2] = 0x00;
//    
//    NSData * data = [NSData dataWithBytes:buf length:3];
//    NSLog(@"send api_send_GetMAC buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:NO protocolcmd:buf[0]];
//    
//}
//-(void)api_send_GetMInfo{
//    Byte buf[8] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_MINFO;
//    buf[1] = 0x00;
//    buf[2] = 0x00;
//    
//    NSData * data = [NSData dataWithBytes:buf length:8];
//    NSLog(@"send api_send_GetMInfo buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:NO protocolcmd:buf[0]];
//    
//}
//
//-(void)api_set_Personal_data{
//    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_start_set_personinfo object:nil];
//
//    Byte buf[50] = {'\0'};
//    buf[0]=HJT_CMD_PHONE2DEVICE_SET_PERSONINFO;
//    buf[1]= 47;
//
//    /*3-7 clock*/
//    if(self.commondata.is_enable_clock)
//        buf[2] = 1;
//    else
//        buf[2] = 0;
//    buf[3] = self.commondata.clock_hour;
//    buf[4] = self.commondata.clock_minute;
//    buf[5] = self.commondata.clock_smart;
//    if ((self.commondata.clock_period & PERIOD_1) == 1) {
//        buf[6] = buf[6] | 1<<1;
//    }
//    if (((self.commondata.clock_period & PERIOD_2)>>1) == 1) {
//        buf[6] = buf[6] | 1<<2;
//    }
//    if (((self.commondata.clock_period & PERIOD_3)>>2) == 1) {
//        buf[6] = buf[6] | 1<<3;
//    }
//    if (((self.commondata.clock_period & PERIOD_4)>>3) == 1) {
//        buf[6] = buf[6] | 1<<4;
//    }
//    if (((self.commondata.clock_period & PERIOD_5)>>4) == 1) {
//        buf[6] = buf[6] | 1<<5;
//    }
//    if (((self.commondata.clock_period & PERIOD_6)>>5) == 1) {
//        buf[6] = buf[6] | 1<<6;
//    }
//    if (((self.commondata.clock_period & PERIOD_7)>>6) == 1) {
//        buf[6] = buf[6] | 1<<7;
//    }
//    /*23-27 idle alert*/
//    if (self.commondata.is_enable_longsitalarm) {
//        buf[22] = 1;
//    }
//    buf[23] = self.commondata.longsit_starthour;
//    buf[24] = self.commondata.longsit_endhour;
//    buf[25] = self.commondata.longsit_time;
//    if ((self.commondata.longsit_period & PERIOD_1) == 1) {
//        buf[26] = buf[26] | 1<<1;
//    }
//    if (((self.commondata.longsit_period & PERIOD_2)>>1) == 1) {
//        buf[26] = buf[26] | 1<<2;
//    }
//    if (((self.commondata.longsit_period & PERIOD_3)>>2) == 1) {
//        buf[26] = buf[26] | 1<<3;
//    }
//    if (((self.commondata.longsit_period & PERIOD_4)>>3) == 1) {
//        buf[26] = buf[26] | 1<<4;
//    }
//    if (((self.commondata.longsit_period & PERIOD_5)>>4) == 1) {
//        buf[26] = buf[26] | 1<<5;
//    }
//    if (((self.commondata.longsit_period & PERIOD_6)>>5) == 1) {
//        buf[26] = buf[26] | 1<<6;
//    }
//    if (((self.commondata.longsit_period & PERIOD_7)>>6) == 1) {
//        buf[26] = buf[26] | 1<<7;
//    }
//    if (self.commondata.male == 1) {
//        buf[35] = 1;
//    }else{
//        buf[35] = 0;
//    }
//    buf[36] = (Byte)ceil(self.commondata.height);
//    if (self.commondata.measureunit == MEASURE_UNIT_US){
//        buf[37] = (Byte)ceil(self.commondata.weight)/KM2MILE;
//        buf[38] = (Byte)ceil(self.commondata.stride*KM2MILE);
//        buf[39] = (Byte)ceil(self.commondata.stride*KM2MILE);
//    }else{
//        buf[37] = (Byte)ceil(self.commondata.weight);
//        buf[38] = (Byte)ceil(self.commondata.stride);
//        buf[39] = (Byte)ceil(self.commondata.stride);
//        
//    }
//    //睡眠启动时间
//    buf[40] = 23;
//    buf[41] = 0;
//    buf[42] = 7;
//    buf[43] = 0;
//    Byte tmp[4] = {'\0'};
//    *(uint16_t*)tmp = CFSwapInt16HostToBig(self.commondata.target_steps);
//    buf[44] = tmp[0];
//    buf[45] = tmp[1];
//    buf[46] = tmp[2];
//    buf[47] = 0;
//    buf[48] = 0;
//    
//    Byte checksum = buf[2];
//    for(int i= 3; i < 49; i++){
//        checksum = checksum^buf[i];
//    };
//    buf[49] = checksum;
//    NSData * data = [NSData dataWithBytes:buf length:50];
//    NSLog(@"send api_send_personinfo buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES protocolcmd:buf[0]];
//    
// 
//}
//
//-(void)api_set_sleeptime{
//    Byte buf[20] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_SET_SLEEP_TIME;
//    buf[1] = 0x0F;
//    NSDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
//    if (bonginfo == nil) {
//        buf[2] = 0;
//        buf[3] = 0;
//        buf[4] = 0;
//        buf[5] = 0;
//        buf[6] = 0;
//        buf[7] = 0;
//        buf[8] = 0;
//        buf[9] = 0;
//        buf[10] = 0;
//        buf[11] = 0;
//        buf[12] = 0;
//        buf[13] = 0;
//        buf[14] = 0;
//        buf[15] = 0;
//        buf[16] = 0;
//
//    }else{
//        NSString* enable = [bonginfo objectForKey:BONGINFO_KEY_SLEEP1_ENABLE];
//        if (enable == nil || ![enable isEqualToString:DEF_ENABLE]) {
//            buf[2] = 0;
//        }else{
//            buf[2] = 1;
//        }
//        NSNumber* val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP1_START_H];
//        if (val == nil) {
//            buf[3] = 0;
//        }else{
//            buf[3] = val.intValue;
//        }
//        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP1_START_M];
//        if (val == nil) {
//            buf[4] = 0;
//        }else{
//            buf[4] = val.intValue;
//        }
//        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP1_END_H];
//        if (val == nil) {
//            buf[5] = 0;
//        }else{
//            buf[5] = val.intValue;
//        }
//        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP1_END_M];
//        if (val == nil) {
//            buf[6] = 0;
//        }else{
//            buf[6] = val.intValue;
//        }
//        enable = [bonginfo objectForKey:BONGINFO_KEY_SLEEP2_ENABLE];
//        if (enable == nil || ![enable isEqualToString:DEF_ENABLE]) {
//            buf[7] = 0;
//        }else{
//            buf[7] = 1;
//        }
//        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP2_START_H];
//        if (val == nil) {
//            buf[8] = 0;
//        }else{
//            buf[8] = val.intValue;
//        }
//        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP2_START_M];
//        if (val == nil) {
//            buf[9] = 0;
//        }else{
//            buf[9] = val.intValue;
//        }
//        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP2_END_H];
//        if (val == nil) {
//            buf[10] = 0;
//        }else{
//            buf[10] = val.intValue;
//        }
//        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP2_END_M];
//        if (val == nil) {
//            buf[11] = 0;
//        }else{
//            buf[11] = val.intValue;
//        }
//        enable = [bonginfo objectForKey:BONGINFO_KEY_SLEEP3_ENABLE];
//        if (enable == nil || ![enable isEqualToString:DEF_ENABLE]) {
//            buf[12] = 0;
//        }else{
//            buf[12] = 1;
//        }
//        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP3_START_H];
//        if (val == nil) {
//            buf[13] = 0;
//        }else{
//            buf[13] = val.intValue;
//        }
//        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP3_START_M];
//        if (val == nil) {
//            buf[14] = 0;
//        }else{
//            buf[14] = val.intValue;
//        }
//        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP3_END_H];
//        if (val == nil) {
//            buf[15] = 0;
//        }else{
//            buf[15] = val.intValue;
//        }
//        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP3_END_M];
//        if (val == nil) {
//            buf[16] = 0;
//        }else{
//            buf[16] = val.intValue;
//        }
//
//
//        
//    }
//
//    Byte checksum = buf[2];
//    for(int i= 3; i < 17; i++){
//        checksum = checksum^buf[i];
//    };
//    buf[17] = checksum;
//    
//    NSData * data = [NSData dataWithBytes:buf length:20];
//    NSLog(@"send api_send_sleepset buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES protocolcmd:buf[0]];
//
//}
//
//
//-(void)api_set_bandparam{
//    Byte buf[20] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_SET_PARAM;
//    buf[1] = 0x05;
//    if ([self.commondata is24time]) {
//        buf[2] = 1;
//    }else{
//        buf[2] = 0;
//    }
//    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//        buf[3] = 0;
// //       buf[6] = 1;
//    }else{
//        buf[3] = 1;
// //       buf[6] = 2;
//    }
//        buf[4] = self.commondata.screentime;
//        buf[5] = 0;
//    
//    Byte checksum = buf[2];
//    for(int i= 3; i < 6; i++){
//        checksum = checksum^buf[i];
//    };
//    buf[6] = checksum;
//    
//    NSData * data = [NSData dataWithBytes:buf length:7];
//    NSLog(@"send api_send_bandparam buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:NO protocolcmd:buf[0]];
//    
//}
//
//-(void)api_set_screentime{
//    Byte buf[20] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_SET_PARAM;
//    buf[1] = 0x05;
//    if ([self.commondata is24time]) {
//        buf[2] = 1;
//    }else{
//        buf[2] = 0;
//    }
//    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//        buf[3] = 0;
//        //       buf[6] = 1;
//    }else{
//        buf[3] = 1;
//        //       buf[6] = 2;
//    }
//    buf[4] = self.commondata.screentime;
//    buf[5] = 0;
//    
//    Byte checksum = buf[2];
//    for(int i= 3; i < 6; i++){
//        checksum = checksum^buf[i];
//    };
//    buf[6] = checksum;
//    
//    NSData * data = [NSData dataWithBytes:buf length:7];
//    NSLog(@"send api_send_bandparam buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES protocolcmd:buf[0]];
//    
//}
//
//
//-(void)api_send_activity_monitor:(NSInteger)activetype report:(BOOL)reportflag{
//    Byte buf[20] = {'\0'};
//    buf[0] = HJT_ADV_CMD_PHONE2DEVICE_ACTIVITY_MONITOR;
//    buf[1] = 0x11;
//    /*    Byte tmp[4];
//     *(uint16_t*)tmp = activetype;
//     buf[2] = tmp[0];
//     buf[3] = tmp[1];
//     buf[4] = tmp[2];
//     buf[5] = tmp[3];
//     */
//    buf[2] = (Byte)activetype;
//    buf[3] = 0;
//    buf[4] = 0;
//    buf[5] = 0;
//    if (reportflag) {
//        buf[6]= 1;
//    }else{
//        buf[6] = 0;
//    }
//    
//    buf[19] = buf[2]^buf[3]^buf[4]^buf[5]^buf[6];
//    NSData * data = [NSData dataWithBytes:buf length:20];
//    NSLog(@"send api_send_activity_monitor buf = %@",data);
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_ADV_CHARATERISTIC_KEY withRespon:YES protocolcmd:buf[0]];
//    
//}
//

/////////////////////////////////////////////////////////////////////////////
#pragma bluetooth protocol
-(BOOL)CheckData:(NSData*)recvdata{
    Byte* bytearray = (Byte*)[recvdata bytes];
//    Byte cmdname = bytearray[0];
    Byte cmdparamlen = bytearray[1];
    if (cmdparamlen) {
        Byte checksum = bytearray[2];
        for (int i = 0; i< cmdparamlen-1; i++) {
            checksum = checksum^bytearray[3+i];
        }
        if (checksum == bytearray[2+cmdparamlen]) {
            return YES;
        }else{
            NSLog(@"CheckData ERROR!!!!!!!!!!!!!");
            return NO;
        }
    }
    
    return YES;
}


//-(void)ReceiveData:(NSData*)recvdata{
//    //   NSLog(@"MainLoop::bleNotifyUpdate");
//    //    NSData * recvdata = (NSData*)[[notification userInfo] objectForKey:@"data"];
//    NSLog(@"ReceiveData  :: %@", recvdata);
//    Byte* bytearray = (Byte*)[recvdata bytes];
//    Byte cmdname = bytearray[0];
//    Byte cmdparamlen = bytearray[1];
//    
//    switch (cmdname) {
//            /*
//        case HJT_CMD_PHONE2DEVICE_GETMAC:
//            [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(api_send_GetMAC) userInfo:nil repeats:NO];
//            break;
//            */
//            
//        case HJT_CMD_DEVICE2PHONE_SET_BLE_NAME_OK:
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_SET_BLE_MATCH_PASSWORD_OK:
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_SET_PERSONINFO_OK:
//            self.commondata.is_need_sycn_persondata = NO;
//            NSLog(@"SetPersonInfo OK");
////            [self.commondata saveconfig];
//            if (self.sync_type == OPERATOR_SYNC_CLOCK) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_clock_ok object:nil];
//                self.sync_type = OPERATOR_SYNC_NIL;
//                self.current_state = CURRENT_STATE_READY;
//            }
//            if (self.sync_type == OPERATOR_SYNC_LONGSIT || self.sync_type == OPERATOR_SYNC_PERSONINFO) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd object:nil];
//            }
//            if (self.sync_type == OPERATOR_SYNC_HISTORY) {
//                [self startReadHistoryData];
//            }else if(self.sync_type == OPERATOR_SYNC_CURRENT){
//                [self sendReadData:nil];
//            }
//            
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_WEEK_OK:{
//            NSLog(@"buf = %@",recvdata);
//            if(![self CheckData:recvdata]){
//                NSLog(@"RecvData Error!");
//                [self startReadHistoryData];
//                break;
//            }
//            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//            NSDateComponents *comps = [[NSDateComponents alloc] init];
//            NSInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit;
//            //先校验日期是否正确
//            NSDate* cdate = [NSDate dateWithTimeIntervalSince1970:self.commondata.lastReadDataTime];
////            NSTimeInterval  timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
////            cdate = [cdate dateByAddingTimeInterval:timeZoneOffset];
//            comps = [calendar components:unitFlags fromDate:cdate];
//            NSInteger year = [comps year];
//            NSInteger month = [comps month];
//            NSInteger day = [comps day];
//            NSInteger hour = [comps hour];
//            int res_year = bytearray[2]+2000;
//            int res_month = bytearray[3];
//            int res_day = bytearray[4];
//            int res_hour = bytearray[5];
//            NSLog(@"Currentdate = %d-%d-%d %d",year,month,day,hour);
//            NSLog(@"responesdate = %d-%d-%d %d",res_year,res_month,res_day,res_hour);
//            if (year!= res_year || month != res_month || res_day!= day || res_hour != hour) {
//                NSLog(@"INVALID HISTORY DATA");
//                self.commondata.lastReadDataTime += 60*60;
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_recv_device_sync_data object:nil];
//                [self startReadHistoryData];
//                break;
//            }
//            
//            
//            
//
//            NSDate* t1 = [NSDate date];
//            NSError * error;
//            int readoffset = 6;
//            int readtimes = cmdparamlen/6;
//            int currentreadtimes = 0;
//            int readbytes = 0;
//            NSMutableDictionary* stepday = [[NSMutableDictionary alloc] init];
//            NSMutableDictionary* stepmonth = [[NSMutableDictionary alloc] init];
//            NSMutableDictionary* stephour = [[NSMutableDictionary alloc] init];
//            NSMutableDictionary* sleephour = [[NSMutableDictionary alloc] init];
//            NSMutableDictionary* sleepday = [[NSMutableDictionary alloc] init];
//            NSMutableDictionary* sleepmonth = [[NSMutableDictionary alloc] init];
//            
//            
//            while(currentreadtimes < readtimes){
//                
//                NSLog(@"readoffset = %d, readbytes = %d, currentreadtime = %d, readtimes = %d",readoffset, readbytes, currentreadtimes, readtimes);
//                NSDate* cdate = [NSDate dateWithTimeIntervalSince1970:self.commondata.lastReadDataTime];
//                comps = [calendar components:unitFlags fromDate:cdate];
//                NSInteger year = [comps year];
//                NSInteger month = [comps month];
//                NSInteger day = [comps day];
//                NSInteger hour = [comps hour];
////                NSTimeInterval  timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
//                NSTimeInterval  timeZoneOffset= 0;
//                cdate = [cdate dateByAddingTimeInterval:timeZoneOffset];
//                
//                uint8_t tmp[2];
//                tmp[0] = bytearray[readoffset];
//                tmp[1] = bytearray[readoffset+1];
//                unsigned int mode = tmp[0] >> 6;
//                uint8_t t = tmp[0] << 2;
//                tmp[0] = t >> 2;
//                uint16_t steps = CFSwapInt16BigToHost(*(int16_t*)tmp);
//                
//                tmp[0] = bytearray[readoffset+2];
//                tmp[1] = bytearray[readoffset+3];
//                uint16_t cal = CFSwapInt16BigToHost(*(int16_t*)tmp);
//                
//                tmp[0] = bytearray[readoffset+4];
//                tmp[1] = bytearray[readoffset+5];
//                uint16_t dis = CFSwapInt16BigToHost(*(int16_t*)tmp);
//                
//                NSLog(@"steps = %d, cal=%d, dis=%d",steps, cal,dis);
//                
//                
//                StepHistory* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
//                record.cal = [NSNumber numberWithUnsignedInteger:cal];
//                record.distance = [NSNumber numberWithUnsignedInteger:dis];
//                record.mode = [NSNumber numberWithUnsignedInt:mode];
//                record.steps = [NSNumber numberWithUnsignedInt:steps];
//                record.datetime = cdate;
//                record.type = [NSNumber numberWithInt:0];
//                NSLog(@"record = %@",record);
//                
//                NSString* monthkey = [NSString stringWithFormat:@"%d-%.2d-01 00:00:00",(int)year, (int)month];
//                NSString* daykey = [NSString stringWithFormat:@"%d-%.2d-%.2d 00:00:00",(int)year, (int)month, (int)day];
//                NSString* hourkey = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:00:00",(int)year,(int)month, (int)day, (int)hour];
//                if (mode == HJT_STEP_MODE_DAILY) {
//                    NSMutableDictionary* data = [stephour objectForKey:hourkey];
//                    if (data == nil) {
//                        data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:0], @"steps", [NSNumber numberWithUnsignedInt:0], @"sport", [NSNumber numberWithUnsignedInt:0], @"cal",[NSNumber numberWithUnsignedInt:0], @"distance",nil];
//                    }
//                    NSNumber* n_steps = (NSNumber*)[data objectForKey:@"steps"];
//                    n_steps = [NSNumber numberWithUnsignedInt:n_steps.unsignedIntegerValue + (int)steps];
//                    [data setObject:n_steps forKey:@"steps"];
//                    
//                    NSNumber* n_cal = (NSNumber*)[data objectForKey:@"cal"];
//                    n_cal = [NSNumber numberWithUnsignedInt:n_cal.unsignedIntegerValue+cal];
//                    [data setObject:n_cal forKey:@"cal"];
//                    
//                    NSNumber* n_distance = (NSNumber*)[data objectForKey:@"distance"];
//                    n_distance = [NSNumber numberWithUnsignedInt:n_distance.unsignedIntegerValue+dis];
//                    [data setObject:n_distance forKey:@"distance"];
//                    
//                    [stephour setObject:data forKey:hourkey];
//                    
//                    NSMutableDictionary* data_day = [stepday objectForKey:daykey];
//                    if (data_day == nil) {
//                        data_day = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:0], @"steps", [NSNumber numberWithUnsignedInt:0], @"sport", [NSNumber numberWithUnsignedInt:0], @"cal",[NSNumber numberWithUnsignedInt:0], @"distance",nil];
//                    }
//                    NSNumber* n_steps_day = (NSNumber*)[data_day objectForKey:@"steps"];
//                    n_steps_day = [NSNumber numberWithUnsignedInt:n_steps_day.unsignedIntegerValue+steps];
//                    [data_day setObject:n_steps_day forKey:@"steps"];
//                    
//                    NSNumber* n_cal_day = (NSNumber*)[data_day objectForKey:@"cal"];
//                    n_cal_day = [NSNumber numberWithUnsignedInt:n_cal_day.unsignedIntegerValue+cal];
//                    [data_day setObject:n_cal_day forKey:@"cal"];
//                    
//                    NSNumber* n_distance_day = (NSNumber*)[data_day objectForKey:@"distance"];
//                    n_distance_day = [NSNumber numberWithUnsignedInt:n_distance_day.unsignedIntegerValue+dis];
//                    [data_day setObject:n_distance_day forKey:@"distance"];
//                    [stepday setObject:data_day forKey:daykey];
//                    
//                    NSMutableDictionary* data_month = [stepmonth objectForKey:monthkey];
//                    if (data_month == nil) {
//                        data_month = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:0], @"steps", [NSNumber numberWithUnsignedInt:0], @"sport", [NSNumber numberWithUnsignedInt:0], @"cal",[NSNumber numberWithUnsignedInt:0], @"distance", nil];
//                    }
//                    NSNumber* n_steps_month = (NSNumber*)[data_month objectForKey:@"steps"];
//                    n_steps_month = [NSNumber numberWithUnsignedInt:n_steps_month.unsignedIntegerValue+steps];
//                    [data_month setObject:n_steps_month forKey:@"steps"];
//                    NSNumber* n_cal_month = (NSNumber*)[data_month objectForKey:@"cal"];
//                    n_cal_month = [NSNumber numberWithUnsignedInt:n_cal_month.unsignedIntegerValue+cal];
//                    [data_month setObject:n_cal_month forKey:@"cal"];
//                    
//                    NSNumber* n_distance_m = (NSNumber*)[data_month objectForKey:@"distance"];
//                    n_distance_m = [NSNumber numberWithUnsignedInt:n_distance_m.unsignedIntegerValue+dis];
//                    [data_month setObject:n_distance_m forKey:@"distance"];
//                    [stepmonth setObject:data_month forKey:monthkey];
//                    
//                }else if (mode == HJT_STEP_MODE_SPORT){
//                    //处理每小时的数据
//                    NSMutableDictionary* data = [stephour objectForKey:hourkey];
//                    if (data == nil) {
//                        data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:0], @"steps", [NSNumber numberWithUnsignedInt:0], @"sport", [NSNumber numberWithUnsignedInt:0], @"cal",[NSNumber numberWithUnsignedInt:0], @"distance",nil];
//                    }
//                    NSNumber* n_steps = (NSNumber*)[data objectForKey:@"steps"];
//                    n_steps = [NSNumber numberWithUnsignedInt:n_steps.unsignedIntegerValue+steps];
//                    [data setObject:n_steps forKey:@"steps"];
//                    
//                    NSNumber* n_sport = (NSNumber*)[data objectForKey:@"sport"];
//                    n_sport = [NSNumber numberWithUnsignedInt:n_sport.unsignedIntegerValue+steps];
//                    [data setObject:n_sport forKey:@"sport"];
//                    
//                    NSNumber* n_cal = (NSNumber*)[data objectForKey:@"cal"];
//                    n_cal = [NSNumber numberWithUnsignedInt:n_cal.unsignedIntegerValue+cal];
//                    [data setObject:n_cal forKey:@"cal"];
//                    
//                    NSNumber* n_distance = (NSNumber*)[data objectForKey:@"distance"];
//                    n_distance = [NSNumber numberWithUnsignedInt:n_distance.unsignedIntegerValue+dis];
//                    [data setObject:n_distance forKey:@"distance"];
//                    
//                    [stephour setObject:data forKey:hourkey];
//                    //处理每天数据
//                    NSMutableDictionary* data_day = [stepday objectForKey:daykey];
//                    if (data_day == nil) {
//                        data_day = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:0], @"steps", [NSNumber numberWithUnsignedInt:0], @"sport", [NSNumber numberWithUnsignedInt:0], @"cal",[NSNumber numberWithUnsignedInt:0], @"distance",nil];
//                    }
//                    NSNumber* n_steps_day = (NSNumber*)[data_day objectForKey:@"steps"];
//                    n_steps_day = [NSNumber numberWithUnsignedInt:n_steps_day.unsignedIntegerValue+steps];
//                    [data_day setObject:n_steps_day forKey:@"steps"];
//                    
//                    NSNumber* n_sport_day = (NSNumber*)[data_day objectForKey:@"sport"];
//                    n_sport_day = [NSNumber numberWithUnsignedInt:n_sport_day.unsignedIntegerValue+steps];
//                    [data_day setObject:n_sport_day forKey:@"sport"];
//                    
//                    NSNumber* n_cal_day = (NSNumber*)[data_day objectForKey:@"cal"];
//                    n_cal_day = [NSNumber numberWithUnsignedInt:n_cal_day.unsignedIntegerValue+cal];
//                    [data_day setObject:n_cal_day forKey:@"cal"];
//                    
//                    NSNumber* n_distance_day = (NSNumber*)[data_day objectForKey:@"distance"];
//                    n_distance_day = [NSNumber numberWithUnsignedInt:n_distance_day.unsignedIntegerValue+dis];
//                    [data_day setObject:n_distance_day forKey:@"distance"];
//                    [stepday setObject:data_day forKey:daykey];
//                    //处理每月
//                    NSMutableDictionary* data_month = [stepmonth objectForKey:monthkey];
//                    if (data_month == nil) {
//                        data_month = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:0], @"steps", [NSNumber numberWithUnsignedInt:0], @"sport", [NSNumber numberWithUnsignedInt:0], @"cal",[NSNumber numberWithUnsignedInt:0], @"distance", nil];
//                    }
//                    NSNumber* n_steps_month = (NSNumber*)[data_month objectForKey:@"steps"];
//                    n_steps_month = [NSNumber numberWithUnsignedInt:n_steps_month.unsignedIntegerValue+steps];
//                    [data_month setObject:n_steps_month forKey:@"steps"];
//                    
//                    NSNumber* n_sport_month = (NSNumber*)[data_month objectForKey:@"sport"];
//                    n_sport_month = [NSNumber numberWithUnsignedInt:n_sport_month.unsignedIntegerValue+steps];
//                    [data_month setObject:n_sport_month forKey:@"sport"];
//                    
//                    NSNumber* n_cal_month = (NSNumber*)[data_month objectForKey:@"cal"];
//                    n_cal_month = [NSNumber numberWithUnsignedInt:n_cal_month.unsignedIntegerValue+cal];
//                    [data_month setObject:n_cal_month forKey:@"cal"];
//                    
//                    NSNumber* n_distance_m = (NSNumber*)[data_month objectForKey:@"distance"];
//                    n_distance_m = [NSNumber numberWithUnsignedInt:n_distance_m.unsignedIntegerValue+dis];
//                    [data_month setObject:n_distance_m forKey:@"distance"];
//                    
//                    [stepmonth setObject:data_month forKey:monthkey];
//                    
//                    
//                }else if (mode == HJT_STEP_MODE_SLEEP){
//                    NSMutableDictionary* data_hour = [sleephour objectForKey:hourkey];
//                    if (data_hour == nil) {
//                        data_hour = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:0], @"awake", [NSNumber numberWithFloat:0], @"light", [NSNumber numberWithFloat:0], @"deep",[NSNumber numberWithFloat:0], @"exlight",nil];
//                    }
//                    NSMutableDictionary* data_day = [sleepday objectForKey:daykey];
//                    if (data_day == nil) {
//                        data_day = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:0], @"awake", [NSNumber numberWithFloat:0], @"light", [NSNumber numberWithFloat:0], @"deep",[NSNumber numberWithFloat:0], @"exlight",nil];
//                    }
//                    NSMutableDictionary* data_month = [sleepmonth objectForKey:monthkey];
//                    if (data_month == nil) {
//                        data_month = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:0], @"awake", [NSNumber numberWithFloat:0], @"light", [NSNumber numberWithFloat:0], @"deep",[NSNumber numberWithFloat:0], @"exlight", nil];
//                    }                    //判断是什么类型的睡眠
//                    if (steps > HJT_SLEEP_MODE_AWAKE) {
//                        //NSLog(@"HJT_SLEEP_MODE_AWAKE steps = %d",steps);
//                        NSNumber* n_awake_hour = (NSNumber*)[data_hour objectForKey:@"awake"];
//                        n_awake_hour = [NSNumber numberWithFloat:n_awake_hour.floatValue + 10*60];
//                        [data_hour setObject:n_awake_hour forKey:@"awake"];
//                        NSNumber* n_awake_day = (NSNumber*)[data_day objectForKey:@"awake"];
//                        n_awake_day = [NSNumber numberWithFloat:n_awake_day.floatValue + 10*60];
//                        [data_day setObject:n_awake_day forKey:@"awake"];
//                        NSNumber* n_awake_month = (NSNumber*)[data_month objectForKey:@"awake"];
//                        n_awake_month = [NSNumber numberWithFloat:n_awake_month.floatValue + 10*60];
//                        [data_month setObject:n_awake_month forKey:@"awake"];
//                    }
//                    else if(steps > HJT_SLEEP_MODE_EXLIGHT){
//                        //NSLog(@"HJT_SLEEP_MODE_EXLIGHT steps = %d",steps);
//                        NSNumber* n_exlight_hour = (NSNumber*)[data_hour objectForKey:@"exlight"];
//                        n_exlight_hour = [NSNumber numberWithFloat:n_exlight_hour.floatValue + 10*60];
//                        [data_hour setObject:n_exlight_hour forKey:@"exlight"];
//                        NSNumber* n_exlight_day = (NSNumber*)[data_day objectForKey:@"exlight"];
//                        n_exlight_day = [NSNumber numberWithFloat:n_exlight_day.floatValue + 10*60];
//                        [data_day setObject:n_exlight_day forKey:@"exlight"];
//                        NSNumber* n_exlight_month = (NSNumber*)[data_month objectForKey:@"exlight"];
//                        n_exlight_month = [NSNumber numberWithFloat:n_exlight_month.floatValue + 10*60];
//                        [data_month setObject:n_exlight_month forKey:@"exlight"];
//                        
//                    }
//                    else if(steps > HJT_SLEEP_MODE_LIGHT){
//                        //NSLog(@"HJT_SLEEP_MODE_LIGHT steps = %d",steps);
//                        
//                        NSNumber* n_light_hour = (NSNumber*)[data_hour objectForKey:@"light"];
//                        n_light_hour = [NSNumber numberWithFloat:n_light_hour.floatValue + 10*60];
//                        [data_hour setObject:n_light_hour forKey:@"light"];
//                        NSNumber* n_light_day = (NSNumber*)[data_day objectForKey:@"light"];
//                        n_light_day = [NSNumber numberWithFloat:n_light_day.floatValue + 10*60];
//                        [data_day setObject:n_light_day forKey:@"light"];
//                        NSNumber* n_light_month = (NSNumber*)[data_month objectForKey:@"light"];
//                        n_light_month = [NSNumber numberWithFloat:n_light_month.floatValue + 10*60];
//                        [data_month setObject:n_light_month forKey:@"light"];
//                        
//                    }else{
//                        //NSLog(@"HJT_SLEEP_MODE_DEEP steps = %d",steps);
//                        
//                        NSNumber* n_deep_hour = (NSNumber*)[data_hour objectForKey:@"deep"];
//                        n_deep_hour = [NSNumber numberWithFloat:n_deep_hour.floatValue + 10*60];
//                        [data_hour setObject:n_deep_hour forKey:@"deep"];
//                        NSNumber* n_deep_day = (NSNumber*)[data_day objectForKey:@"deep"];
//                        n_deep_day = [NSNumber numberWithFloat:n_deep_day.floatValue + 10*60];
//                        [data_day setObject:n_deep_day forKey:@"deep"];
//                        NSNumber* n_deep_month = (NSNumber*)[data_month objectForKey:@"deep"];
//                        n_deep_month = [NSNumber numberWithFloat:n_deep_month.floatValue + 10*60];
//                        [data_month setObject:n_deep_month forKey:@"deep"];
//                        
//                    }
//                    [sleephour setObject:data_hour forKey:hourkey];
//                    [sleepday setObject:data_day forKey:daykey];
//                    [sleepmonth setObject:data_month forKey:monthkey];
//                }
//                
//                
//                self.commondata.lastReadDataTime+=HJT_DATA_TIME_INTERVAL;
//                readoffset += 6;
//                readbytes += 6;
//                currentreadtimes += 1;
//            }
//            [self.managedObjectContext save:&error];
//            [self.commondata saveconfig];
//            NSLog(@"stephour = %@", stephour);
//            NSLog(@"stepday = %@", stepday);
//            NSLog(@"stepmonth = %@", stepmonth);
//            NSLog(@"sleephour = %@", sleephour);
//            NSLog(@"sleepday = %@", sleepday);
//            NSLog(@"sleepmonth = %@", sleepmonth);
//            NSLog(@"%@",[stephour keyEnumerator].allObjects);
//            [self procstephour:stephour];
//            [self procstepday:stepday];
//            [self procstepmonth:stepmonth];
//        
//            [self procsleephour:sleephour];
//            [self procsleepday:sleepday];
//            [self procsleepmonth:sleepmonth];
//            NSLog(@"proc data time = %f", [[NSDate date] timeIntervalSinceDate:t1]);
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_recv_device_sync_data object:nil];
//            
//            [self startReadHistoryData];
//            break;
//        }
//        case HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_DATE_OK:
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_OK:
//            if(cmdparamlen == 9){
//                Byte buf[4];
//                buf[0] = 0;
//                buf[1] = bytearray[2];
//                buf[2] = bytearray[3];
//                buf[3] = bytearray[4];
//                
//                int steps = CFSwapInt32BigToHost(*(int*)buf);
//                buf[0] = 0;
//                buf[1] = bytearray[5];
//                buf[2] = bytearray[6];
//                buf[3] = bytearray[7];
//                int cal = CFSwapInt32BigToHost(*(int*)buf);
//                buf[0] = 0;
//                buf[1] = bytearray[8];
//                buf[2] = bytearray[9];
//                buf[3] = bytearray[10];
//                int distance = CFSwapInt32BigToHost(*(int*)buf);
//                
//                NSDictionary *userinfo = @{@"steps":[NSNumber numberWithInt:steps],@"cal":[NSNumber numberWithInt:cal],@"distance":[NSNumber numberWithInt:distance]};
//                self.commondata.current_steps = steps;
//                self.commondata.current_cal = cal;
//                self.commondata.current_distance = distance;
//                [self.commondata saveconfig];
//                
//                self.commondata.last_c6date = [NSDate date];
//                self.commondata.last_c6steps = steps;
//                
//                [self.commondata saveC6];
//
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_current_steps object:nil userInfo:userinfo];
//                NSLog(@"steps = %d, cal = %d, distance = %d",steps, cal, distance);
//                //翔德版本中，在此断链
//                if (self.sync_type == OPERATOR_SYNC_CURRENT) {
//                    self.sync_type = OPERATOR_SYNC_NIL;
// //                   [self.blecontrol disconnectDevice:0];
//                }
// //               [self startReadCurrentData];
//            }
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_AND_TOTAL_STEPS_OK:
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_RESET_OK:
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_CLEAR_DATA_OK:
//            if (self.current_state == CURRENT_STATE_WAIT_CLEAR) {
//                self.current_state = CURRENT_STATE_WAIT_FOR_SET_DEVICE_TIME;
//                [self setDeviceTime];
//            }else if (self.current_state == CURRENT_STATE_WAIT_MANUAL_CLEAR){
//                self.current_state = CURRENT_STATE_READY;
//                self.sync_type = OPERATOR_SYNC_NIL;
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_clear_ok object:nil];
//            }
//
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_SET_DEVICE_TIME_OK:{
//            NSDictionary * userinfo = @{@"result":@"OK"};
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_set_device_time object:nil userInfo:userinfo];
//            if (self.current_state == CURRENT_STATE_WAIT_FOR_SET_DEVICE_TIME) {
//                self.current_state = CURRENT_STATE_READY;
//                [self kickoff];
//                
//            }
//            break;
//        }
//        case HJT_CMD_DEVICE2PHONE_READ_DEVICE_TIME_OK:{
//
//            uint8_t year = bytearray[2];
//            uint8_t month = bytearray[3];
//            uint8_t day = bytearray[4];
//            uint8_t hour = bytearray[5];
//            uint8_t minute = bytearray[6];
//            uint8_t second = bytearray[7];
//            uint8_t week = bytearray[8];
//            
//            if(day == 0 && month == 0){
//                day = 1;
//                month = 1;
//            }
//            
//            NSDictionary *userinfo = @{@"year":[NSNumber numberWithUnsignedInt:year+2000],
//                                       @"month":[NSNumber numberWithUnsignedInt:month],
//                                       @"day":[NSNumber numberWithUnsignedInt:day],
//                                       @"hour":[NSNumber numberWithUnsignedInt:hour],
//                                       @"minute":[NSNumber numberWithUnsignedInt:minute],
//                                       @"second":[NSNumber numberWithUnsignedInt:second],
//                                       @"week":[NSNumber numberWithUnsignedInt:week]
//                                       };
//            NSLog(@"%@",userinfo);
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_read_device_time_ok object:nil userInfo:userinfo];
//            
//            NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
//            NSRange containsA = [formatStringForHours rangeOfString:@"a"];
//            BOOL hasAMPM = containsA.location != NSNotFound;
//            
//            NSDateFormatter * format = [[NSDateFormatter alloc] init];
//            [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//            [format setTimeZone:[NSTimeZone systemTimeZone]];
//            
//            if(hasAMPM){
////                [format setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
////                [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
////                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
//            }
//            format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//            NSDate* currentdate = [NSDate date];
//            NSString* timestr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:%.2d:%.2d",year+2000,month,day,hour,minute,second];
//            NSLog(@"timestr = %@",timestr);
////            [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
//            NSDate* devicedate = [format dateFromString:timestr];
//            
//            NSLog(@"devicedate = %@",devicedate);
//            NSLog(@"currentdate = %@",currentdate);
//            
//            
//            if (self.current_state == CURRENT_STATE_WAIT_FOR_DEVICE_TIME) {
//                NSTimeInterval offset = abs((int)[currentdate timeIntervalSinceDate:devicedate]);
//                NSLog(@"offset = %f",offset);
//                if (offset >= TIME_NEED_TO_RESET_DEVICE) {
//                    self.current_state = CURRENT_STATE_WAIT_CLEAR;
//                    [self api_set_Clear];
//                    
//                }
//                else if(offset >= TIME_NEED_TO_SYNC_DEVICE_TIME){
//                    self.current_state = CURRENT_STATE_WAIT_FOR_SET_DEVICE_TIME;
//                    [self setDeviceTime];
//                }else{
//                    self.current_state = CURRENT_STATE_READY;
//                    [self kickoff];
//                }
//            }
//        }
//            break;
//            
//        case HJT_CMD_DEVICE2PHONE_SET_BLE_NAME_ERR:
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_SET_BLE_MATCH_PASSWORD_ERR:
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_SET_PERSONINFO_ERR:
//            self.commondata.is_need_sycn_persondata = NO;
//            NSLog(@"SetPersonInfo ERROR");
//            //在此添加是否通知到用户
//            if (self.sync_type == OPERATOR_SYNC_CLOCK || self.sync_type == OPERATOR_SYNC_LONGSIT) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_clock_err object:nil];
//                self.sync_type = OPERATOR_SYNC_NIL;
//                self.current_state = CURRENT_STATE_READY;
//
//            }
//
// //           [self.commondata saveconfig];
//            if (self.sync_type == OPERATOR_SYNC_HISTORY) {
//                [self startReadHistoryData];
//            }else if(self.sync_type == OPERATOR_SYNC_CURRENT){
//                [self sendReadData:nil];
//            }
//
//            break;
//        case HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_WEEK_ERR:
//            [self startReadCurrentData];
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_DATE_ERR:
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_ERR:
//            [self startReadHistoryData];
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_AND_TOTAL_STEPS_ERR:
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_RESET_ERR:
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_CLEAR_DATA_ERR:
//            if (self.current_state == CURRENT_STATE_WAIT_CLEAR) {
////                self.errortimes += 1;
//                [self api_set_Clear];
//            }else if (self.current_state == CURRENT_STATE_WAIT_MANUAL_CLEAR){
//                self.current_state = CURRENT_STATE_READY;
//                self.sync_type = OPERATOR_SYNC_NIL;
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_clear_err object:nil];
//            }
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_SET_DEVICE_TIME_ERR:{
//            NSDictionary * userinfo = @{@"result":@"ERROR"};
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_set_device_time object:nil userInfo:userinfo];
//            if (self.current_state == CURRENT_STATE_WAIT_FOR_SET_DEVICE_TIME) {
////                self.errortimes += 1;
//                [self setDeviceTime];
//    
//            }
//            break;
//        }
//        case HJT_CMD_DEVICE2PHONE_READ_DEVICE_TIME_ERR:
//            
//            break;
//        case HJT_CMD_DEVICE2PHONE_ANTILOST:{
//            if (cmdparamlen == 0) {
//                break;
//            }
//            if (self.commondata.is_enable_devicecall) {
//                
//                Byte cmd = bytearray[2];
//                if(cmd == HJT_ANTILOST_CMD_CALL_PHONE) {
//                    [self start_call_phone];
//                }else if (cmd == HJT_ANTILOST_CMD_CALL_PHONE_END){
//                    [self stop_call_phone];
//                }
//            }
//            //            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//            //            AudioServicesPlayAlertSound(1000);
//            break;
//        }
//        case HJT_CMD_DEVICE2PHONE_REQUEST_TIME:{
//#if defined(CMD_HAS_RESPONSE)
//            // HJT_CMD_PHONE2DEVICE_MODESET,在有回应的机制下，认为是设置模式的响应
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_modeset object:nil];
//#endif
//            //            [self setDeviceTime];
//            break;
//        }
//        case HJT_CMD_DEVICE2PHONE_PHOTO:
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_take_photo object:nil userInfo:nil];
//            break;
//        case HJT_CMD_DEVICE2PHONE_MUSIC:{
//            if (self.commondata.is_enable_bongcontrolmusic) {
//                Byte cmd = bytearray[2];
//                if (cmd == HJT_MUSIC_CMD_PLAY) {
//                    [self music_play];
//                }else if (cmd == HJT_MUSIC_CMD_NEXT){
//                    [self music_next];
//                }else if(cmd == HJT_MUSIC_CMD_BACK){
//                    [self music_back];
//                }
//                
//            }
//            break;
//        }
//        case HJT_CMD_DEVICE2PHONE_GETMAC:{
//            uint8_t tmp[8] = {'\0'};
//            uint8_t len = bytearray[1];
//            int begin = 8-len;
//            if (len) {
//                tmp[begin+0] = bytearray[2];
//                tmp[begin+1] = bytearray[3];
//                tmp[begin+2] = bytearray[4];
//                tmp[begin+3] = bytearray[5];
//                tmp[begin+4] = bytearray[6];
//                tmp[begin+5] = bytearray[7];
//            }
//            uint64_t macid = CFSwapInt64BigToHost(*(uint64_t*)tmp);
//            NSString* macidstr = [NSString stringWithFormat:@"%qx",macid];
//            NSLog(@"macid = %lld macidstr = %@",macid,macidstr);
//            self.commondata.current_macid = [macidstr copy];
//            NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
//            if (bi == nil) {
//                bi = [[NSMutableDictionary alloc] init];
//            }
//            [bi setObject:macidstr forKey:BONGINFO_KEY_BLEADDR];
//            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bi];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_mac_id object:nil];
//            [self api_send_GetMInfo];
//
//        }
//            break;
//        case HJT_CMD_DEVICE2PHONE_MINFO:{
//        }
//
//            break;
//
//        case HJT_CMD_DEVICE2PHONE_SET_SLEEP_TIME_OK:{
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd object:nil];
//
//        }
//            break;
//        case HJT_CMD_DEVICE2PHONE_SET_SLEEP_TIME_ERR:{
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd_err object:nil];
//
//        }
//            break;
//        case HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_REPORT:{
//            uint8_t tmp[4] = {'\0'};
//            uint8_t len = bytearray[1];
//            /*
//             if (len) {
//             tmp[0] = bytearray[2];
//             tmp[1] = bytearray[3];
//             tmp[2] = bytearray[4];
//             tmp[3] = bytearray[5];
//             }
//             NSInteger activity_type = (*(NSInteger*)tmp);
//             */
//            NSInteger activity_type = bytearray[2];
//            
//            if (len) {
//                tmp[3] = bytearray[7];
//                tmp[2] = bytearray[8];
//                tmp[1] = bytearray[9];
//                tmp[0] = bytearray[10];
//            }
//            NSUInteger activity_value = (*(NSUInteger*)tmp);
//            unsigned int tempvalue = (int)activity_value;
//            
//            NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:activity_type],@"activity_type",[NSNumber numberWithUnsignedInteger:tempvalue],@"activity_value", nil];
//            NSLog(@"activity_type = %d activity_value = %d tempvalue = %d",activity_type,activity_value,tempvalue);
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_activity_report object:nil userInfo:userinfo];
//            
//            
//        }
//            break;
//        case HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_MONITOR_ERR:{
//            NSLog(@"Activity monitor ERROR");
//            self.sync_type = OPERATOR_SYNC_NIL;
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_monitor_change object:nil userInfo:@{@"state":[NSNumber numberWithBool:NO]}];
//            UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"activity_monitor_error_title", nil) message:NSLocalizedString(@"activity_monitor_error", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
//            [alerview show];
//        }
//            break;
//        case HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_MONITOR_OK:{
//            NSLog(@"Activity monitor OK");
//            self.sync_type = OPERATOR_SYNC_NIL;
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_monitor_change object:nil userInfo:@{@"state":[NSNumber numberWithBool:YES]}];
//            
//        }
//            break;
//        case HJT_CMD_DEVICE2PHONE_SET_BANDPRAM_OK:{
//            NSLog(@"Set param OK");
//            if (self.sync_type == OPERATOR_SYNC_SCREENTIME) {
//                self.sync_type = OPERATOR_SYNC_NIL;
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd object:nil userInfo:nil];
//            }
//            break;
//            
//        }
//        case HJT_CMD_DEVICE2PHONE_SET_BANDPRAM_ERR:{
//            NSLog(@"Set param Error");
//            if (self.sync_type == OPERATOR_SYNC_SCREENTIME) {
//                self.sync_type = OPERATOR_SYNC_NIL;
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd_err object:nil userInfo:nil];
//            }
//            break;
//            
//        }
//
//       default:
//            break;
//    }
//    
//}

//-(void)UpdateRSSI:(int)rssi{
//    NSLog(@"%d",rssi);
    /*
    [self.rssilist addObject:[NSNumber numberWithInt:rssi]];
    NSUInteger count = [self.rssilist count];
    if(count > MAX_RSSI_SAMPLES){
        [self.rssilist removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, (count-MAX_RSSI_SAMPLES))]];
    }
    
    int avr = 0;
    int total = 0;
    //取平均值
    for (NSNumber* nbr in self.rssilist) {
        total= total+[nbr intValue];
    }
    avr = total/(int)[self.rssilist count];
 //   NSLog(@"avr = %d",(int)avr);
    if (self.commondata.is_enable_antilost) {
        if (avr < ALARM_RSSI_VALUE && self.is_send_alarm == NO) {
            NSLog(@"send antilost to bong");
            self.is_send_alarm = YES;
            [self api_send_antilost:HJT_ANTILOST_TYPE_OUT_OF_RANGE];
            [self start_call_phone];
        }
        if (avr > NORMAL_RSSI_VALUE && self.is_send_alarm == YES){
            NSLog(@"send stop antilost to bong");
            self.is_send_alarm = NO;
            [self api_send_antilost:HJT_ANTILOST_TYPE_OUT_OF_RANGE_END];
            [self stop_call_phone];
        }
    }
     */
//}

//-(void)procstephour:(NSMutableDictionary*)dict{
//    if (dict==nil) {
//        NSLog(@"dictionary is nil");
//        return;
//    }
//    NSArray* keylist = [[dict keyEnumerator] allObjects];
//    NSDateFormatter* format = [[NSDateFormatter alloc]init];
//    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    [format setTimeZone:[NSTimeZone systemTimeZone]];
//    
//    format.dateFormat = [NSString stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
////    NSTimeInterval timezone = [[NSTimeZone systemTimeZone] secondsFromGMT];
//    NSTimeInterval timezone = 0;
//    for (NSString* key in keylist){
//        NSDate * datetime = [format dateFromString:(NSString*)key];
//        datetime = [datetime dateByAddingTimeInterval:timezone];
//        NSLog(@"datetime = %@", datetime);
//        
//        NSNumber* n_steps = (NSNumber*)[[dict objectForKey:key] objectForKey:@"steps"];
//        NSNumber* n_sport = (NSNumber*)[[dict objectForKey:key] objectForKey:@"sport"];
//        NSNumber* n_cal = (NSNumber*)[[dict objectForKey:key] objectForKey:@"cal"];
//        NSNumber* n_distance = (NSNumber*)[[dict objectForKey:key] objectForKey:@"distance"];
//        
//        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//        [fetchRequest setEntity:entity];
//        // Specify criteria for filtering which objects to fetch
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime = %@", datetime];
//        
//        [fetchRequest setPredicate:predicate];
//        // Specify how the fetched objects should be sorted
//        NSError *error = nil;
//        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
//            StepHistory_Hour* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//            record.steps = [n_steps copy];
//            record.sport = [n_sport copy];
//            record.cal = [n_cal copy];
//            record.distance = [n_distance copy];
//            record.datetime = datetime;
//            NSLog(@"new record = %@",record);
//        }
//        else{
//            StepHistory_Hour* record = [fetchedObjects objectAtIndex:0];
//            NSLog(@"old record = %@",record);
//            record.steps = [NSNumber numberWithInt:record.steps.intValue+n_steps.intValue];
//            record.sport = [NSNumber numberWithInt:record.sport.intValue+n_sport.intValue];
//            record.cal = [NSNumber numberWithFloat:record.cal.floatValue+n_cal.floatValue];
//            record.distance = [NSNumber numberWithFloat:record.distance.floatValue+n_distance.floatValue];
//            NSLog(@"update record = %@",record);
//        }
//        [self.managedObjectContext save:&error];
//    }
//}
//
//-(void)procstepday:(NSMutableDictionary*)dict{
//    if (dict==nil) {
//        NSLog(@"dictionary is nil");
//        return;
//    }
//    NSArray* keylist = [[dict keyEnumerator] allObjects];
//    NSDateFormatter* format = [[NSDateFormatter alloc]init];
//    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    [format setTimeZone:[NSTimeZone systemTimeZone]];
//    
//    format.dateFormat = [NSString stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
////    NSTimeInterval timezone = [[NSTimeZone systemTimeZone] secondsFromGMT];
//    NSTimeInterval timezone = 0;
//    for (NSString* key in keylist){
//        NSDate * datetime = [format dateFromString:(NSString*)key];
//        datetime = [datetime dateByAddingTimeInterval:timezone];
//        NSLog(@"datetime = %@", datetime);
//        
//        NSNumber* n_steps = (NSNumber*)[[dict objectForKey:key] objectForKey:@"steps"];
//        NSNumber* n_sport = (NSNumber*)[[dict objectForKey:key] objectForKey:@"sport"];
//        NSNumber* n_cal = (NSNumber*)[[dict objectForKey:key] objectForKey:@"cal"];
//        NSNumber* n_distance = (NSNumber*)[[dict objectForKey:key] objectForKey:@"distance"];
//        
//        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//        [fetchRequest setEntity:entity];
//        // Specify criteria for filtering which objects to fetch
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime = %@", datetime];
//        
//        [fetchRequest setPredicate:predicate];
//        // Specify how the fetched objects should be sorted
//        NSError *error = nil;
//        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
//            StepHistory_Day* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//            record.steps = [n_steps copy];
//            record.sport = [n_sport copy];
//            record.cal = [n_cal copy];
//            record.distance = [n_distance copy];
//            record.datetime = datetime;
//            NSLog(@"new record = %@",record);
//        }
//        else{
//            StepHistory_Day* record = [fetchedObjects objectAtIndex:0];
//            NSLog(@"old record = %@",record);
//            record.steps = [NSNumber numberWithInt:record.steps.intValue+n_steps.intValue];
//            record.sport = [NSNumber numberWithInt:record.sport.intValue+n_sport.intValue];
//            record.cal = [NSNumber numberWithFloat:record.cal.floatValue+n_cal.floatValue];
//            record.distance = [NSNumber numberWithFloat:record.distance.floatValue+n_distance.floatValue];
//            NSLog(@"update record = %@",record);
//        }
//        [self.managedObjectContext save:&error];
//    }
//}
//
//-(void)procstepmonth:(NSMutableDictionary*)dict{
//    if (dict==nil) {
//        NSLog(@"dictionary is nil");
//        return;
//    }
//    NSArray* keylist = [[dict keyEnumerator] allObjects];
//    NSDateFormatter* format = [[NSDateFormatter alloc]init];
//    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    [format setTimeZone:[NSTimeZone systemTimeZone]];
//    
//    format.dateFormat = [NSString stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
////    NSTimeInterval timezone = [[NSTimeZone systemTimeZone] secondsFromGMT];
//    NSTimeInterval timezone = 0;
//    for (NSString* key in keylist){
//        NSDate * datetime = [format dateFromString:(NSString*)key];
//        datetime = [datetime dateByAddingTimeInterval:timezone];
//        NSLog(@"datetime = %@", datetime);
//        
//        NSNumber* n_steps = (NSNumber*)[[dict objectForKey:key] objectForKey:@"steps"];
//        NSNumber* n_sport = (NSNumber*)[[dict objectForKey:key] objectForKey:@"sport"];
//        NSNumber* n_cal = (NSNumber*)[[dict objectForKey:key] objectForKey:@"cal"];
//        NSNumber* n_distance = (NSNumber*)[[dict objectForKey:key] objectForKey:@"distance"];
//        
//        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//        [fetchRequest setEntity:entity];
//        // Specify criteria for filtering which objects to fetch
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime = %@", datetime];
//        
//        [fetchRequest setPredicate:predicate];
//        // Specify how the fetched objects should be sorted
//        NSError *error = nil;
//        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
//            StepHistory_Month* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//            record.steps = [n_steps copy];
//            record.sport = [n_sport copy];
//            record.datetime = datetime;
//            record.distance = [n_distance copy];
//            record.datetime = datetime;
//            NSLog(@"new record = %@",record);
//        }
//        else{
//            StepHistory_Month* record = [fetchedObjects objectAtIndex:0];
//            NSLog(@"old record = %@",record);
//            record.steps = [NSNumber numberWithInt:record.steps.intValue+n_steps.intValue];
//            record.sport = [NSNumber numberWithInt:record.sport.intValue+n_sport.intValue];
//            record.cal = [NSNumber numberWithFloat:record.cal.floatValue+n_cal.floatValue];
//            record.distance = [NSNumber numberWithFloat:record.distance.floatValue+n_distance.floatValue];
//            NSLog(@"update record = %@",record);
//        }
//        [self.managedObjectContext save:&error];
//    }
//}
//-(void)procsleephour:(NSMutableDictionary*)dict{
//    if (dict==nil) {
//        NSLog(@"dictionary is nil");
//        return;
//    }
//    
//    NSArray* keylist = [[dict keyEnumerator] allObjects];
//    NSDateFormatter* format = [[NSDateFormatter alloc]init];
//    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    [format setTimeZone:[NSTimeZone systemTimeZone]];
//    
//    format.dateFormat = [NSString stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
//    //    NSTimeInterval timezone = [[NSTimeZone systemTimeZone] secondsFromGMT];
//    NSTimeInterval timezone = 0;
//    for (NSString* key in keylist){
//        NSDate * datetime = [format dateFromString:(NSString*)key];
//        datetime = [datetime dateByAddingTimeInterval:timezone];
//        NSLog(@"datetime = %@", datetime);
//        
//        NSNumber* n_awake = (NSNumber*)[[dict objectForKey:key] objectForKey:@"awake"];
//        NSNumber* n_light = (NSNumber*)[[dict objectForKey:key] objectForKey:@"light"];
//        NSNumber* n_exlight = (NSNumber*)[[dict objectForKey:key] objectForKey:@"exlight"];
//        NSNumber* n_deep = (NSNumber*)[[dict objectForKey:key] objectForKey:@"deep"];
//        
//        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SleepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//        [fetchRequest setEntity:entity];
//        // Specify criteria for filtering which objects to fetch
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime = %@", datetime];
//        
//        [fetchRequest setPredicate:predicate];
//        // Specify how the fetched objects should be sorted
//        NSError *error = nil;
//        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
//            SleepHistory_Hour* record = [NSEntityDescription insertNewObjectForEntityForName:@"SleepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//            record.awake = [n_awake copy];
//            record.light = [n_light copy];
//            record.exlight = [n_exlight copy];
//            record.deep = [n_deep copy];
//            record.datetime = datetime;
//            //            NSLog(@"new record = %@",record);
//        }
//        else{
//            SleepHistory_Hour* record = [fetchedObjects objectAtIndex:0];
//            NSLog(@"old record = %@",record);
//            record.awake = [NSNumber numberWithFloat:record.awake.floatValue+n_awake.floatValue];
//            record.light = [NSNumber numberWithFloat:record.light.floatValue+n_light.floatValue];
//            record.exlight = [NSNumber numberWithFloat:record.exlight.floatValue+n_exlight.floatValue];
//            record.deep = [NSNumber numberWithFloat:record.deep.floatValue+n_deep.floatValue];
//            //            NSLog(@"update record = %@",record);
//        }
//        [self.managedObjectContext save:&error];
//    }
//}
//
//
//-(void)procsleepday:(NSMutableDictionary*)dict{
//    if (dict==nil) {
//        NSLog(@"dictionary is nil");
//        return;
//    }
//    NSArray* keylist = [[dict keyEnumerator] allObjects];
//    NSDateFormatter* format = [[NSDateFormatter alloc]init];
//    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    [format setTimeZone:[NSTimeZone systemTimeZone]];
//    
//    format.dateFormat = [NSString stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
//    //    NSTimeInterval timezone = [[NSTimeZone systemTimeZone] secondsFromGMT];
//    NSTimeInterval timezone = 0;
//    for (NSString* key in keylist){
//        NSDate * datetime = [format dateFromString:(NSString*)key];
//        datetime = [datetime dateByAddingTimeInterval:timezone];
//        NSLog(@"datetime = %@", datetime);
//        
//        NSNumber* n_awake = (NSNumber*)[[dict objectForKey:key] objectForKey:@"awake"];
//        NSNumber* n_light = (NSNumber*)[[dict objectForKey:key] objectForKey:@"light"];
//        NSNumber* n_exlight = (NSNumber*)[[dict objectForKey:key] objectForKey:@"exlight"];
//        NSNumber* n_deep = (NSNumber*)[[dict objectForKey:key] objectForKey:@"deep"];
//        
//        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SleepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//        [fetchRequest setEntity:entity];
//        // Specify criteria for filtering which objects to fetch
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime = %@", datetime];
//        
//        [fetchRequest setPredicate:predicate];
//        // Specify how the fetched objects should be sorted
//        NSError *error = nil;
//        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
//            SleepHistory_Day* record = [NSEntityDescription insertNewObjectForEntityForName:@"SleepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//            record.awake = [n_awake copy];
//            record.light = [n_light copy];
//            record.exlight = [n_exlight copy];
//            record.deep = [n_deep copy];
//            record.datetime = datetime;
//            //            NSLog(@"new record = %@",record);
//        }
//        else{
//            SleepHistory_Day* record = [fetchedObjects objectAtIndex:0];
//            //NSLog(@"old record = %@",record);
//            record.awake = [NSNumber numberWithFloat:record.awake.floatValue+n_awake.floatValue];
//            record.light = [NSNumber numberWithFloat:record.light.floatValue+n_light.floatValue];
//            record.exlight = [NSNumber numberWithFloat:record.exlight.floatValue+n_exlight.floatValue];
//            record.deep = [NSNumber numberWithFloat:record.deep.floatValue+n_deep.floatValue];
//            //NSLog(@"update record = %@",record);
//        }
//        //        [self.managedObjectContext save:&error];
//    }
//}
//
//-(void)procsleepmonth:(NSMutableDictionary*)dict{
//    if (dict==nil) {
//        NSLog(@"dictionary is nil");
//        return;
//    }
//    NSArray* keylist = [[dict keyEnumerator] allObjects];
//    NSDateFormatter* format = [[NSDateFormatter alloc]init];
//    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    [format setTimeZone:[NSTimeZone systemTimeZone]];
//    
//    format.dateFormat = [NSString stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
//    //    NSTimeInterval timezone = [[NSTimeZone systemTimeZone] secondsFromGMT];
//    NSTimeInterval timezone = 0;
//    for (NSString* key in keylist){
//        NSDate * datetime = [format dateFromString:(NSString*)key];
//        datetime = [datetime dateByAddingTimeInterval:timezone];
//        NSLog(@"datetime = %@", datetime);
//        
//        NSNumber* n_awake = (NSNumber*)[[dict objectForKey:key] objectForKey:@"awake"];
//        NSNumber* n_light = (NSNumber*)[[dict objectForKey:key] objectForKey:@"light"];
//        NSNumber* n_exlight = (NSNumber*)[[dict objectForKey:key] objectForKey:@"exlight"];
//        NSNumber* n_deep = (NSNumber*)[[dict objectForKey:key] objectForKey:@"deep"];
//        
//        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SleepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//        [fetchRequest setEntity:entity];
//        // Specify criteria for filtering which objects to fetch
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime = %@", datetime];
//        
//        [fetchRequest setPredicate:predicate];
//        // Specify how the fetched objects should be sorted
//        NSError *error = nil;
//        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
//            SleepHistory_Month* record = [NSEntityDescription insertNewObjectForEntityForName:@"SleepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//            record.awake = [n_awake copy];
//            record.light = [n_light copy];
//            record.deep = [n_deep copy];
//            record.exlight = [n_exlight copy];
//            record.datetime = datetime;
//            //           NSLog(@"new record = %@",record);
//        }
//        else{
//            SleepHistory_Month* record = [fetchedObjects objectAtIndex:0];
//            //NSLog(@"old record = %@",record);
//            record.awake = [NSNumber numberWithFloat:record.awake.floatValue+n_awake.floatValue];
//            record.light = [NSNumber numberWithFloat:record.light.floatValue+n_light.floatValue];
//            record.exlight = [NSNumber numberWithFloat:record.exlight.floatValue + n_exlight.floatValue];
//            record.deep = [NSNumber numberWithFloat:record.deep.floatValue+n_deep.floatValue];
//            //NSLog(@"update record = %@",record);
//        }
//        //        [self.managedObjectContext save:&error];
//    }
//}
//

-(void)disconnect{
    if (self.waitStableTmr) {
        [self.waitStableTmr invalidate];
        self.waitStableTmr = nil;
    }
    if (self.C4Timer) {
        [self.C4Timer invalidate];
        self.C4Timer = nil;
    }
    if (self.C6Timer) {
        [self.C6Timer invalidate];
        self.C6Timer = nil;
    }
    [self.rssilist removeAllObjects];
    self.is_send_alarm = NO;
    self.current_state = CURRENT_STATE_UNCONNECTED;
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_band_has_disconnect object:nil];
//#ifdef CUSTOM_API2
    self.current_state = STATE_CONNECT_LOST;
    if(self.blecontrol.isOta == YES){
        [self reinitEnv];
    }
    [self connectDefaultDevice:nil];
//#else
//    if (self.sync_type != OPERATOR_SYNC_NIL) {
//        [self connectDefaultDevice:nil];
//    }
//#endif
    if (self.runmode == RUNMODE_BACKGROUD) {
        NSLog(@"RUNMODE_BACKGROUD");
        if (self.commondata.is_enable_antilost) {
            NSLog(@"is_enable_antilost --- start_call_phone");
            if (self.commondata.is_enable_incomingcall) {
                if (self.antilost_relay_timer) {
                    [self.antilost_relay_timer invalidate];
                    self.antilost_relay_timer = nil;
                }
                //手动断开不会响铃
                if (self.commondata.lastBongUUID.length>1) {
                    self.antilost_relay_timer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(start_call_phone) userInfo:nil repeats:NO];
                }
                
//                //很挫的做法，让alarm.caf响两次
//                self.antilost_relay_timer = [NSTimer scheduledTimerWithTimeInterval:9 target:self selector:@selector(start_call_phone) userInfo:nil repeats:NO];
                
            }else{
                UIApplication *app = [UIApplication sharedApplication];
                UIBackgroundTaskIdentifier taskID = 0;
                taskID = [app beginBackgroundTaskWithExpirationHandler:^{
                    //如果系统觉得我们还是运行了太久，将执行这个程序块，并停止运行应用程序
                    NSLog(@"--------end now-------------");
                    [app endBackgroundTask:taskID];
                }];
                if (taskID == UIBackgroundTaskInvalid) {
                    NSLog(@"Failed to start background task!");
                    return;
                }
                NSLog(@"Starting background task with %f seconds remaining", app.backgroundTimeRemaining);
                if (self.antilost_relay_timer) {
                    [self.antilost_relay_timer invalidate];
                    self.antilost_relay_timer = nil;
                }
                //手动断开不会响铃
                if (self.commondata.lastBongUUID.length>1) {
                    self.antilost_relay_timer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(start_call_phone) userInfo:nil repeats:NO];
                }
                
                //很挫的做法，让alarm.caf响两次
//                self.antilost_relay_timer = [NSTimer scheduledTimerWithTimeInterval:9 target:self selector:@selector(start_call_phone) userInfo:nil repeats:NO];
                //            [self performSelector:@selector(start_call_phone) withObject:nil afterDelay:3];
                //[self start_call_phone];
            }

//            NSLog(@"is_enable_antilost --- start_call_phone");
//            [self start_call_phone];
        }
        
    }
    else
    {
        if (self.commondata.is_enable_antilost)
        {

            if (self.antilost_relay_timer) {
                [self.antilost_relay_timer invalidate];
                self.antilost_relay_timer = nil;
            }
            //手动断开不响铃
            if (self.commondata.lastBongUUID.length>1) {

                self.antilost_relay_timer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(start_call_phone) userInfo:nil repeats:NO];
            }
                
            //很挫的做法，让alarm.caf响两次
//            self.antilost_relay_timer = [NSTimer scheduledTimerWithTimeInterval:9 target:self selector:@selector(start_call_phone) userInfo:nil repeats:NO];
            
        }
    }
    
}

- (void) endBackgroundTask{
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    __weak AppDelegate *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        AppDelegate *strongSelf = weakSelf;
        if (strongSelf != nil){
//            [strongSelf.myTimer invalidate];
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundIdentifier];
            strongSelf.backgroundIdentifier = UIBackgroundTaskInvalid;
        }
    });
}


-(void)getReady{
    //在此做同步时间
//    [self api_send_GetMAC];
    
    
    if (self.waitStableTmr) {
        [self.waitStableTmr invalidate];
        self.waitStableTmr = nil;
    }
    //先等待一段时间，板子才能稳定
    self.getfwtimeout = 0;
    self.getmactimeout = 0;
    self.current_state = CURRENT_STATE_WAIT_FOR_STABLE;
    self.waitStableTmr = [NSTimer scheduledTimerWithTimeInterval:STABLE_TIMER target:self selector:@selector(waitStableTimeout) userInfo:nil repeats:NO];
    if (self.antilost_relay_timer) {
        [self.antilost_relay_timer invalidate];
        self.antilost_relay_timer = nil;
    }

    
    /*
     NSDate* date = [NSDate date];
     NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
     NSDateComponents *comps = [[NSDateComponents alloc] init];
     NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit |NSHourCalendarUnit;
     
     comps = [calendar components:unitFlags fromDate:date];
     
     NSLog(@"year=%d",[comps year]-2000);
     NSLog(@"month=%d",[comps month]);
     NSLog(@"day=%d",[comps day]);
     NSLog(@"hour=%d",[comps hour]);
     NSLog(@"minute=%d",[comps minute]);
     NSLog(@"second=%d",[comps second]);
     NSLog(@"week=%d",[comps weekday]);
     [self api_set_DeviceTime:[comps year]-2000 M:[comps month] D:[comps day] H:[comps hour] MM:[comps minute] S:[comps second] W:[comps weekday]];
     [self.rssilist removeAllObjects];
     self.is_send_alarm = NO;
     
     [self setPersonInfo];
     */
}
-(void)waitStableTimeout{
    //等待结束，首先获取设备时间
//#ifdef CUSTOM_API2
    self.current_state = STATE_CONNECT_INIT;
    [self start_init_device];
//#else
//    self.current_state = CURRENT_STATE_WAIT_FOR_DEVICE_TIME;
//    if (self.antilost_relay_timer) {
//        [self.antilost_relay_timer invalidate];
//        self.antilost_relay_timer = nil;
//    }
//    [self stop_call_phone];
//    [self api_get_DeviceTime];
//#endif
//    self.current_state = CURRENT_STATE_READY;
//    [self kickoff];
}

-(void)kickoff{
//#ifdef CUSTOM_API2
    NSLog(@"Kickoff---->");
//    [self CheckBandInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_band_has_kickoff object:nil];
    
//#else
//    if (self.connecttimeout) {
//        [self.connecttimeout invalidate];
//        self.connecttimeout = nil;
//    }
//    if ([self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_E02PLUS] ||
//        [self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_E06PLUS] ||
//        [self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_ZTE] ||
//        [self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_E07] ||
//        [self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_TB01]) {
//        [self api_set_bandparam];
//    }
//    [self api_send_GetMAC];
//    [[NSNotificationCenter defaultCenter] postNotificationName:notify_band_has_kickoff object:nil];
//    if (self.commondata.is_need_sycn_persondata) {
//        [self api_set_Personal_data];
//        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_start_set_personinfo object:nil];
//        return;
//    }
//    if (self.sync_type == OPERATOR_SYNC_HISTORY) {
//        [self startReadHistoryData];
//    }else if(self.sync_type == OPERATOR_SYNC_CURRENT){
//        [self sendReadData:nil];
//    }else if (self.sync_type == OPERATOR_SYNC_ALARM){
//        [self SyncCmd2Band];
//    }else if (self.sync_type == OPERATOR_SYNC_LONGSIT){
//        [self SyncCmd2Band];
//    }else if (self.sync_type == OPERATOR_SYNC_CLOCK){
//        [self SyncCmd2Band];
//    }else if (self.sync_type == OPERATOR_SYNC_PERSONINFO){
//        [self SyncCmd2Band];
//    }else if (self.sync_type == OPERATOR_CLEAR){
//        [self api_set_Clear];
//    }
//#endif
    
}
//蓝牙模块收消息超时
//-(void)recvTimeout{
//#ifdef CUSTOM_API2
//#else
//    if (self.current_state == CURRENT_STATE_READY) {
//        [self startReadCurrentData];
//        [self startReadHistoryData];
//    }else if (self.current_state == CURRENT_STATE_WAIT_MANUAL_CLEAR){
//        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_clear_timeout object:nil];
//        self.current_state = CURRENT_STATE_READY;
//        self.sync_type = OPERATOR_SYNC_NIL;
//    }
//    else{
//        self.current_state = CURRENT_STATE_READY;
//        self.sync_type = OPERATOR_SYNC_NIL;
//        
////        [self.blecontrol disconnectDevice2];
//    }
//#endif
//}
//-(void)setDeviceTime{
//    NSDate* date = [NSDate date];
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *comps = [[NSDateComponents alloc] init];
//    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit |NSHourCalendarUnit;
//    
//    comps = [calendar components:unitFlags fromDate:date];
//    
//    NSLog(@"year=%ld",[comps year]-2000);
//    NSLog(@"month=%ld",[comps month]);
//    NSLog(@"day=%ld",[comps day]);
//    NSLog(@"hour=%ld",[comps hour]);
//    NSLog(@"minute=%ld",[comps minute]);
//    NSLog(@"second=%ld",[comps second]);
//    NSLog(@"week=%ld",[comps weekday]);
//    int week;
//    week = [comps weekday]-1;
//    if (week == 0) week = 7;
//    [self api_set_DeviceTime:[comps year]-2000 M:[comps month] D:[comps day] H:[comps hour] MM:[comps minute] S:[comps second] W:week];
//
//}

//-(void)startReadCurrentData{
//    if (self.current_state == CURRENT_STATE_READY) {
//
//        if (self.C6Timer) {
//            [self.C6Timer invalidate];
//            self.C6Timer = nil;
//        }
//        self.C6Timer = [NSTimer scheduledTimerWithTimeInterval:HJT_C6_TIMEOUT target:self selector:@selector(sendReadData:) userInfo:nil repeats:NO];
//    }
//}
//-(void)startReadHistoryData{
//    if (self.current_state == CURRENT_STATE_READY) {
//
//        if (self.C4Timer) {
//            [self.C4Timer invalidate];
//            self.C4Timer = nil;
//        }
//        self.C4Timer = [NSTimer scheduledTimerWithTimeInterval:HJT_C4_TIMEOUT target:self selector:@selector(sendReadDetailData:) userInfo:nil repeats:NO];
//    }
//}

//-(BOOL)isCorrectRsp:(int)response byCmdname:(int)request{
//    if (response == HJT_CMD_PHONE2DEVICE_GETMAC ||response == HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_REPORT||response == HJT_CMD_DEVICE2PHONE_MINFO)
//        return YES;
//    
//    switch (request) {
//        case HJT_CMD_PHONE2DEVICE_SET_BLE_NAME:
//            if (response == HJT_CMD_DEVICE2PHONE_SET_BLE_NAME_ERR|| response == HJT_CMD_DEVICE2PHONE_SET_BLE_NAME_OK) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_SET_BLE_MATCH_PASSWORD:
//            if (response == HJT_CMD_DEVICE2PHONE_SET_BLE_MATCH_PASSWORD_OK|| response == HJT_CMD_DEVICE2PHONE_SET_BLE_MATCH_PASSWORD_ERR) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_SET_PERSONINFO:
//            if (response == HJT_CMD_DEVICE2PHONE_SET_PERSONINFO_OK|| response == HJT_CMD_DEVICE2PHONE_SET_PERSONINFO_ERR) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_READ_DATA_CURVE_BY_WEEK:
//            if (response == HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_WEEK_OK|| response == HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_WEEK_ERR) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_READ_DATA_CURVE_BY_DATE:
//            if (response == HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_DATE_OK|| response == HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_DATE_ERR) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_READ_DEVICE_DATA:
//            if (response == HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_OK|| response == HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_ERR) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_READ_DEVICE_DATA_AND_TOTAL_STEPS:
//            if (response == HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_AND_TOTAL_STEPS_OK|| response == HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_AND_TOTAL_STEPS_ERR) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_RESET:
//            if (response == HJT_CMD_DEVICE2PHONE_RESET_OK|| response == HJT_CMD_DEVICE2PHONE_RESET_ERR) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_CLEAR_DATA:
//            if (response == HJT_CMD_DEVICE2PHONE_CLEAR_DATA_OK|| response == HJT_CMD_DEVICE2PHONE_CLEAR_DATA_ERR) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_SET_DEVICE_TIME:
//            if (response == HJT_CMD_DEVICE2PHONE_SET_DEVICE_TIME_OK|| response == HJT_CMD_DEVICE2PHONE_SET_DEVICE_TIME_ERR) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_READ_DEVICE_TIME:
//            if (response == HJT_CMD_DEVICE2PHONE_READ_DEVICE_TIME_OK|| response == HJT_CMD_DEVICE2PHONE_READ_DEVICE_TIME_ERR) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_GETMAC:
//            if (response == HJT_CMD_PHONE2DEVICE_GETMAC) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_MINFO:
//            if (response == HJT_CMD_PHONE2DEVICE_MINFO) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_ALARM:
//            if (response == HJT_CMD_PHONE2DEVICE_ALARM) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_WEATHER:
//            if (response == HJT_CMD_PHONE2DEVICE_WEATHER) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_ANTILOST:
//            if (response == HJT_CMD_PHONE2DEVICE_ANTILOST) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_MODESET:
//            if (response == HJT_CMD_PHONE2DEVICE_MODESET) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_INCOMINGCALLNBR:
//            if (response == HJT_CMD_PHONE2DEVICE_INCOMINGCALLNBR) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_LONGSIT:
//            if (response == HJT_CMD_PHONE2DEVICE_LONGSIT) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_SET_SLEEP_TIME:
//            if (response == HJT_CMD_DEVICE2PHONE_SET_SLEEP_TIME_OK || response == HJT_CMD_DEVICE2PHONE_SET_SLEEP_TIME_ERR) {
//                return YES;
//            }
//            break;
//        case HJT_ADV_CMD_PHONE2DEVICE_ACTIVITY_MONITOR:
//            if (response == HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_MONITOR_OK|| response == HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_MONITOR_ERR) {
//                return YES;
//            }
//            break;
//        case HJT_CMD_PHONE2DEVICE_SET_PARAM:
//            if (response == HJT_CMD_DEVICE2PHONE_SET_BANDPRAM_OK|| response == HJT_CMD_DEVICE2PHONE_SET_BANDPRAM_ERR) {
//                return YES;
//            }
//            break;
//        default:
//            break;
//    }
//    return NO;
//}
-(void)SyncHsitoryData{
//#ifdef CUSTOM_API2
    
    if(self.popup == nil){
        self.notifyView = [[SyncNotifyView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
        self.notifyView.delegate = self;
        self.notifyView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncFinish:) name:notify_key_did_finish_device_sync object:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //    popwindow.backgroundColor = [UIColor clearColor];
            self.popup = [KLCPopup popupWithContentView:self.notifyView showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
            [self.popup show];
            
        });
        
    }
    [self sendCmd:CMD_C4];
    NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bi) {
        NSString* versioncode = [bi objectForKey:BONGINFO_KEY_VERSIONCODE];
        if (versioncode.intValue>=20) {
            NSString* cmd1 = [NSString stringWithFormat:@"%@:%d",CMD_SENSORDATA,SENSOR_HEARTRATE];
            [self sendCmd:cmd1];
            NSString* cmd2 = [NSString stringWithFormat:@"%@:%d",CMD_SENSORDATA,SENSOR_TEMPERATURE];
            [self sendCmd:cmd2];

        }
    }
    
//#else
//    if (self.sync_type != OPERATOR_SYNC_NIL && self.sync_type!= OPERATOR_SYNC_HISTORY) {
//        //发现在同步历史数据，则10秒钟后再试
//        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(SyncHsitoryData) userInfo:nil repeats:NO];
//    }else{
//        self.sync_type = OPERATOR_SYNC_HISTORY;
//        if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//            [self connectDefaultDevice:nil];
//            
//        }else{
//            [self startReadHistoryData];
//        }
//    }
//#endif
}
-(void)SyncCurrentData{
//#ifdef CUSTOM_API2
    NSLog(@"SyncCurrentData");
    [self sendCmd:CMD_C6];
    
//#else
//    if (self.sync_type != OPERATOR_SYNC_NIL) {
//        //发现在同步历史数据，则10秒钟后再试
//        [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(SyncCurrentData) userInfo:nil repeats:NO];
//    }else{
//        self.sync_type = OPERATOR_SYNC_CURRENT;
//        if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//            [self connectDefaultDevice:nil];
//            
//        }else{
//            [self sendReadData:nil];
//        }
//    }
//#endif
    
}

//-(void)onConnectTimeout:(NSNotification*)nofity{
//    self.sync_type = OPERATOR_SYNC_NIL;
//    if (self.connecttimeout) {
//        [self.connecttimeout invalidate];
//        self.connecttimeout = nil;
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_connect_timeout object:nil];
//}

//-(void)SyncCmd2Band{
//#ifndef CUSTOM_API2
//    self.errortimes += 1;
//    if (self.errortimes >= 5) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd_err object:nil];
////        [self closeConnect];
////        [self.blecontrol disconnectDevice2];
//        return;
//    }
//    if (self.sync_type == OPERATOR_SYNC_LONGSIT) {
//        [self api_set_Personal_data];
//    }else if (self.sync_type == OPERATOR_SYNC_ALARM){
//        [self api_send_alarm];
//    }else if (self.sync_type == OPERATOR_SYNC_CLOCK){
//        [self api_set_Personal_data];
//    }else if (self.sync_type == OPERATOR_SYNC_PERSONINFO){
//        [self api_set_Personal_data];
//    }else if (self.sync_type == OPERATOR_SYNC_SLEEPTIME){
//        [self api_set_sleeptime];
//    }else if (self.sync_type == OPERATOR_SYNC_SCREENTIME){
//        [self api_set_screentime];
//    }
//    
//    if (self.cmdResendtimer) {
//        [self.cmdResendtimer invalidate];
//        self.cmdResendtimer = nil;
//    }
//    self.cmdResendtimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(SyncCmd2Band) userInfo:nil repeats:NO];
//#endif
//}
-(void)StartSetLongsit{
//#ifdef CUSTOM_API2
    [self sendCmd:CMD_SETPERSON];
//#else
//    if (self.sync_type != OPERATOR_SYNC_NIL) {
//        //发现在同步历史数据，则1秒钟后再试
//        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(StartSetLongsit) userInfo:nil repeats:NO];
//    }else{
//        self.sync_type = OPERATOR_SYNC_LONGSIT;
//        if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//            [self connectDefaultDevice:nil];
//            
//        }else{
//            [self SyncCmd2Band];
//        }
//    }
//#endif
}
-(void)StartSetClock{
//#ifdef CUSTOM_API2
    [self sendCmd:CMD_SETPERSON];
//#else
//
//    if (self.sync_type != OPERATOR_SYNC_NIL) {
//        //发现在同步历史数据，则1秒钟后再试
//        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(StartSetClock) userInfo:nil repeats:NO];
//    }else{
//        self.sync_type = OPERATOR_SYNC_CLOCK;
//        if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//            [self connectDefaultDevice:nil];
//            
//        }else{
//            [self SyncCmd2Band];
//        }
//    }
//#endif
}

- (void)setHydration{
    [self sendCmd:CMD_SETHYDRATION];
}
- (void)set_alarm_name_index:(NSInteger)index{
    self.setAlarmNameIndex  = index;
    [self sendCmd:CMD_ALARM_NAME];
}

-(void)StartSetPersonInfo{
//#ifdef CUSTOM_CCBAND
//    [self sendCmd:CMD_LONGSIT];
//#elif CUSTOM_API2
    [self sendCmd:CMD_SETPERSON];
//#else
//
//    if (self.sync_type != OPERATOR_SYNC_NIL) {
//        //发现在同步历史数据，则1秒钟后再试
//        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(StartSetPersonInfo) userInfo:nil repeats:NO];
//    }else{
//        self.sync_type = OPERATOR_SYNC_PERSONINFO;
//        if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//            [self connectDefaultDevice:nil];
//            
//        }else{
//            [self SyncCmd2Band];
//        }
//    }
//#endif
}

-(void)StartSetSleepset{
//#ifdef CUSTOM_API2
    [self sendCmd:CMD_SETSLEEP];

//#else
//
//    if (self.sync_type != OPERATOR_SYNC_NIL) {
//        //发现在同步历史数据，则1秒钟后再试
//        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(StartSetPersonInfo) userInfo:nil repeats:NO];
//    }else{
//        self.sync_type = OPERATOR_SYNC_SLEEPTIME;
//        if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//            [self connectDefaultDevice:nil];
//            
//        }else{
//            [self SyncCmd2Band];
//        }
//    }
//#endif
}

-(void)StartSetScreenTime{
//#ifdef CUSTOM_API2
    [self sendCmd:CMD_SETSCREEN];
//#else
//    if (self.sync_type != OPERATOR_SYNC_NIL) {
//        //发现在同步历史数据，则1秒钟后再试
//        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(StartSetScreenTime) userInfo:nil repeats:NO];
//    }else{
//        self.sync_type = OPERATOR_SYNC_SCREENTIME;
//        if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//            [self connectDefaultDevice:nil];
//            
//        }else{
//            [self SyncCmd2Band];
//        }
//    }
//#endif
}

-(void)HomeGetCurrentData{
//#ifdef CUSTOM_API2
    NSLog(@"HomeGetCurrentData");
    [self sendCmd:CMD_C6];
//#else
//    if (self.sync_type != OPERATOR_SYNC_NIL) {
//        //发现在同步历史数据，则10秒钟后再试
//        return;
//    }else{
//        self.sync_type = OPERATOR_SYNC_CURRENT;
//        if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//            [self connectDefaultDevice:nil];
//            
//        }else{
//            [self sendReadData:nil];
//        }
//    }
//    
//#endif
}


//-(void)StartNotify{
//    if (self.sync_type != OPERATOR_SYNC_NIL) {
//        //发现在同步历史数据，则1秒钟后再试
//        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(StartNotify) userInfo:nil repeats:NO];
//    }else{
//        self.sync_type = OPERATOR_SYNC_ALARM;
//        if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//            [self connectDefaultDevice:nil];
//            
//        }else{
//            [self SyncCmd2Band];
//        }
//    }
//    
//}
-(void)Start_clear{
    [self sendCmd:CMD_CLEAR];
}

//-(void)onDidFinishSendCmd{
//    self.sync_type = OPERATOR_SYNC_NIL;
//    self.errortimes = 0;
//    if (self.cmdResendtimer) {
//        [self.cmdResendtimer invalidate];
//        self.cmdResendtimer = nil;
//    }
//}

//-(void)onDidFinishSendWeather{
//    NSLog(@"onDidFinishSendWeather");
//    self.sync_type = OPERATOR_SYNC_NIL;
//    self.errortimes = 0;
//    if (self.cmdResendtimer) {
//        [self.cmdResendtimer invalidate];
//        self.cmdResendtimer = nil;
//    }
//}

-(void)StartOTA:(NSNotification*)notify{
    NSString* filepath = [notify.userInfo objectForKey:@"filepath"];
    self.current_ota_block = 1;
    self.current_ota_piece = 1;
    self.max_ota_block = OTA_MAX_BLOCK_COUNT;
    self.max_ota_piece = OTA_MAX_PIECE_COUNT;
    
    if (self.sync_type == OPERATOR_SYNC_NIL && self.current_state == CURRENT_STATE_READY) {
        self.sync_type = OPERATOR_SYNC_OTA;
        self.current_state = CURRENT_STATE_OTA;
        [self ProceedOTA:filepath];
    }else{
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(StartOTA:) userInfo:@{@"filepath":filepath} repeats:NO];
    }
    
    
}

-(void)ProceedOTA:(NSString*)filepath{
    NSData* originfile = [NSData dataWithContentsOfFile:filepath];
    NSData* otafile = [originfile subdataWithRange:NSMakeRange(OTA_FILE_BEGIN,([originfile length] - OTA_FILE_BEGIN))];
    NSLog(@"%@",otafile);
    
    
}

-(void)api_send_OTA_ctrl:(uint8_t)subcmd Block_ID:(uint8_t)blockid PieceCount:(uint8_t)piececount{
    Byte buf[8] = {'\0'};
    buf[0] = OTA_CMD_CTRL;
    buf[1] = subcmd;
    if (subcmd == OTA_SUB_CMD_START) {
        buf[2] = 0xCC;
        buf[3] = 0xBC;
        buf[4] = blockid;
        buf[5] = 00;
        buf[6] = piececount;
        NSData * data = [NSData dataWithBytes:buf length:7];
        NSLog(@"send api_send_OTA_Ctrl buf = %@",data);
        [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES protocolcmd:buf[0]];

    }else{
        buf[2] = 0xCC;
        
        NSData * data = [NSData dataWithBytes:buf length:3];
        NSLog(@"send api_send_OTA_Ctrl buf = %@",data);
        [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES protocolcmd:buf[0]];
    }

}

-(void)api_send_OTA_Data:(uint8_t)piece_id sendbuf:(Byte*)sbuf Length:(uint8_t)len{
    Byte buf[20] = {'\0'};
    buf[0] = OTA_CMD_SEND_DATA;
    buf[1] = piece_id;
    memcpy(&buf[2], sbuf, len);
    
    NSData * data = [NSData dataWithBytes:buf length:len+2];
    NSLog(@"send api_send_OTA_Data buf = %@",data);
    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:YES protocolcmd:buf[0]];


}


-(void)StartSwitchActivity:(NSInteger)activetype report:(BOOL)reportflag{
//#ifdef CUSTOM_API2
    NSString* cmd= [NSString stringWithFormat:@"%@:%d:%d",CMD_ADV_MONITOR,(int)activetype,reportflag];
    [self sendCmd:cmd];
//#else
//    if (self.sync_type != OPERATOR_SYNC_NIL) {
//        //发现在同步历史数据，则1秒钟后再试
//        NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:activetype],@"activetype",[NSNumber numberWithBool:reportflag],@"reportflag", nil];
//        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(StartSwitchActivity_timeout:) userInfo:userinfo repeats:NO];
//    }else{
//        self.sync_type = OPERATOR_SYNC_SWITCHACTIVITY;
//        if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//            [self connectDefaultDevice:nil];
//            
//        }else{
//            [self api_send_activity_monitor:activetype report:reportflag];
//        }
//    }
//#endif
    
    
}
//-(void)StartSwitchActivity_timeout:(NSNotification*)notify{
//    if (self.sync_type != OPERATOR_SYNC_NIL) {
//        //发现在同步历史数据，则1秒钟后再试
//        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(StartSwitchActivity_timeout:) userInfo:notify.userInfo repeats:NO];
//    }else{
//        self.sync_type = OPERATOR_SYNC_SWITCHACTIVITY;
//        if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//            [self connectDefaultDevice:nil];
//            
//        }else{
//            NSNumber* activetype = [notify.userInfo objectForKey:@"activetype"];
//            NSNumber* reportflag = [notify.userInfo objectForKey:@"reportflag"];
//            [self api_send_activity_monitor:activetype.integerValue report:reportflag.boolValue];
//        }
//    }
//    
//    
//}



//#if defined(CUSTOM_FITRIST)
//#if CUSTOM_HIMOVE
-(void)onSyncFinish:(NSNotification*)notify{
    NSLog(@"::::::::::::notify = %@",notify);
    
    
    [self.popup dismissPresentingPopup];
    self.popup = nil;
    self.notifyView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notify_key_did_finish_device_sync object:nil];
    
    
    
}
-(void)SyncNotifyViewClickBackBtn:(SyncNotifyView *)view{
    if (self.popup) {
        [self.popup dismissPresentingPopup];
    }
}

//#endif

/////////////////////////////////////////////////////////////////
#pragma new_fsm
//#if CUSTOM_API2




-(NSData*)api2_Send_GetDeviceTime{
    Byte buf[200] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_READ_DEVICE_TIME;
    buf[1] = 0;
    buf[2] = 0;
    NSData * data = [NSData dataWithBytes:buf length:3];
    NSLog(@"send api2_Send_GetDeviceTime = %@",data);
    return data;
    
}

-(NSData*)api2_Send_SetDeviceTime{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comp = [[NSDateComponents alloc] init];
    comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate date]];
    Byte buf[200] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_SET_DEVICE_TIME;
    buf[1] = 0x07;
    buf[2] = comp.year-2000;
    buf[3] = comp.month;
    buf[4] = comp.day;
    buf[5] = comp.hour;
    buf[6] = comp.minute;
    buf[7] = comp.second;
    Byte tmpweek = [comp weekday]-1;
    if (tmpweek == 0)
        tmpweek = 7;
    buf[8] = tmpweek;
    buf[9] = buf[2]^buf[3]^buf[4]^buf[5]^buf[6]^buf[7]^buf[8];
    NSData * data = [NSData dataWithBytes:buf length:10];
    NSLog(@"send api2_Send_SetDeviceTime = %@",data);
    return data;
}

-(NSData*)api2_Send_C6CurrentStep{
    Byte buf[200] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_READ_DEVICE_DATA;
    buf[1] = 0x01;
    buf[2] = HJT_PARAM_LID_CURRENT_STEPS;
    buf[3] = HJT_PARAM_LID_CURRENT_STEPS;
    
    NSData * data = [NSData dataWithBytes:buf length:4];
    NSLog(@"send api2_Send_C6CurrentStep = %@",data);
    return data;
    
}

-(NSData*)api2_send_A2SportData{
    Byte buf[20] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_READ_SPORT_DATA_BY_DAY;
    
    //data len
    buf[1] = 0x00;

    double lastTime = self.commondata.lastReadSportDataTime;
    NSDate* lastDate = [NSDate dateWithTimeIntervalSince1970:lastTime];
    
    //如果last读取时间是今天，则不再递增时间
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
    [format1 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [format1 setTimeZone:[NSTimeZone systemTimeZone]];
    
    [format1 setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSString *todayStr = [format1 stringFromDate:today];
    NSDate *todayDate = [format1 dateFromString:todayStr];
    double todayTime = [todayDate timeIntervalSince1970];
    
    if(lastTime > todayTime)
    {
        //lastDate = [NSDate dateWithTimeIntervalSince1970:todayTime];
        //如果>todayTime说明同步完,将最后同步时间修改为今天
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_read_sport_data_finish object:nil];
        
        self.commondata.lastReadSportDataTime = todayTime;
        [self.commondata saveconfig];
        
        return nil;
    }
    
    
    //如果未读取的时间超过了3天，则默认以三天前开始读取
    //sports的默认读取时间点为三天前
    NSDate *threeDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-HJT_MAX_STORE_SPORT_DATA_TIME];
    NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
    [format2 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [format2 setTimeZone:[NSTimeZone systemTimeZone]];
    
    [format2 setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSString *threeDaysStr = [format2 stringFromDate:threeDaysAgo];
    NSDate *threeDaysDate = [format2 dateFromString:threeDaysStr];
    double threeDaysTime = [threeDaysDate timeIntervalSince1970];
    
    if(lastTime < threeDaysTime)
    {
        lastDate = [NSDate dateWithTimeIntervalSince1970:threeDaysTime];
    }
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:lastDate];
    
    NSString *yearStr = [NSString stringWithFormat:@"%d",(int)[comps year]];
    int year = [yearStr substringFromIndex:(yearStr.length - 2)].intValue;
    int month = (int)[comps month];
    int day = (int)[comps day];
    
    buf[2] = year;
    buf[3] = month;
    buf[4] = day;
    
    //reserved
    for(int i = 5; i < 19; i++)
        buf[i]= 0x00;
    
    Byte checksum = buf[2];
    for(int i= 3; i < 19; i++){
        checksum = checksum^buf[i];
    };
    buf[19] = checksum;
    
    NSData * data = [NSData dataWithBytes:buf length:20];
    NSLog(@"send api2_send_A2SportData buf = %@",data);
    
    //保存last读取时间
//    if(lastTime >= todayTime)
//    {
//        self.commondata.lastReadSportDataTime = todayTime;
//        [self.commondata saveconfig];
//    }
//    else
//    {
        NSDate *nextDay = [lastDate dateByAddingTimeInterval:60 * 60 * 24];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [format setTimeZone:[NSTimeZone systemTimeZone]];
    
        [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
        NSString *nextStr = [format stringFromDate:nextDay];
        NSDate *nextDate = [format dateFromString:nextStr];
        self.commondata.lastReadSportDataTime = [nextDate timeIntervalSince1970 ];
        [self.commondata saveconfig];
//    }
    
    return data;

}

-(NSData*)api2_send_C4HistoryData{
    NSMutableDictionary* bonginfo = (NSMutableDictionary*)[self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bonginfo == nil) {
        return nil;
    }
    double lastDatetime = self.commondata.lastReadDataTime;
    NSNumber* nlasttime = [bonginfo objectForKey:BONGINFO_KEY_LASTSYNCTIME];
    if (nlasttime) {
        lastDatetime = [nlasttime doubleValue];
    }else{
//#ifdef CUSTOM_JJT_COMMON

        NSDate* dayago = [NSDate dateWithTimeIntervalSinceNow:-1*24*60*60];
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [format setTimeZone:[NSTimeZone systemTimeZone]];
        
        [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
        
        NSString* lastday = [format stringFromDate:dayago];
        NSDate* lastdate = [format dateFromString:lastday];
        double tmplast = [lastdate timeIntervalSince1970];
        if (tmplast > lastDatetime) {
            lastDatetime = tmplast;
        }
        [bonginfo setObject:[NSNumber numberWithDouble:lastDatetime] forKey:BONGINFO_KEY_LASTSYNCTIME];
        [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
//#endif
    }
    
    NSDate* currentdate = [NSDate date];

    if (lastDatetime == 0) {
        NSDate* dayago = [NSDate dateWithTimeIntervalSinceNow:-HJT_MAX_STORE_DATA_TIME];
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [format setTimeZone:[NSTimeZone systemTimeZone]];
        
        [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
        
        NSString* lastday = [format stringFromDate:dayago];
        NSDate* lastdate = [format dateFromString:lastday];
        lastDatetime = [lastdate timeIntervalSince1970];
        [bonginfo setObject:[NSNumber numberWithDouble:lastDatetime] forKey:BONGINFO_KEY_LASTSYNCTIME];
        [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
    }
    
    NSDate* lastReadDate = [NSDate dateWithTimeIntervalSince1970:lastDatetime];
    NSTimeInterval interval = [currentdate  timeIntervalSinceDate:lastReadDate];
    if (interval > (HJT_MAX_STORE_DATA_TIME + 24*60*60) || interval< 0) {
        NSDate* sevendayago = [NSDate dateWithTimeIntervalSinceNow:-HJT_MAX_STORE_DATA_TIME];
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [format setTimeZone:[NSTimeZone systemTimeZone]];
        
        [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
        
        NSString* lastday = [format stringFromDate:sevendayago];
        NSDate* lastdate = [format dateFromString:lastday];
        lastDatetime = [lastdate timeIntervalSince1970];
        lastReadDate = [NSDate dateWithTimeIntervalSince1970:lastDatetime];
        interval = HJT_MAX_STORE_DATA_TIME;
        [bonginfo setObject:[NSNumber numberWithDouble:lastDatetime] forKey:BONGINFO_KEY_LASTSYNCTIME];
        [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
    }

    NSLog(@"lastReadDate = %@",[lastReadDate descriptionWithLocale:[NSTimeZone systemTimeZone]]);
    if(interval > 12*60){
        
        Byte length = 1;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        NSInteger unitFlags = NSWeekdayCalendarUnit |NSHourCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
        
        comps = [calendar components:unitFlags fromDate:lastReadDate];
#ifdef CUSTOM_CZJK_COMMON
//        int y = comps.year%100;
//        int c = comps.year/100;
//        int m = comps.month;
//        int d = comps.day;
//        NSLog(@"y=%d,c=%d,m=%d,d=%d",y,c,m,d);
//        int t = (c/4-2*c+y+y/4+(13*(m+1)/5)+d-1);
//        int tmpweek = 0;
//        if (t>=0) {
//            tmpweek = t%7;
//        }else{
//            tmpweek = t%7+7;
//        }
//        if (tmpweek == 0)
//            tmpweek = 7;
//        NSLog(@"创智杰科的手环认为的星期是%d,%d",tmpweek,-1%7);
        
        //修复创智杰科时间算法的bug，按照时间推算时他们没有处理负数的情况，导致每年有几天的星期数不对
        int y = (int)comps.year%100;
        int c = (int)comps.year/100;
        int m = (int)comps.month;
        int d = (int)comps.day;
//            NSLog(@"y=%d,c=%d,m=%d,d=%d",y,c,m,d);
        if (m == 1||m==2) {
            m = m+12;
            y = y-1;
        }
        int t = (c/4-2*c+y+y/4+(13*(m+1)/5)+d-1);
        Byte tmpweek = 0;
        if (t>=0) {
            tmpweek = t%7;
        }else{
            tmpweek = (t&0xff)%7;
        }
        if (tmpweek == 0)
            tmpweek = 7;



//        Byte tmpweek = [comps weekday]-1;
//        if (tmpweek == 0)
//            tmpweek = 7;

#else
        Byte tmpweek = [comps weekday]-1;
        if (tmpweek == 0)
            tmpweek = 7;
#endif
        Byte week = tmpweek;
        Byte hour = [comps hour];
        
        Byte buf[200] = {'\0'};
        
        buf[0] = HJT_CMD_PHONE2DEVICE_READ_DATA_CURVE_BY_WEEK;
        buf[1] = 0x03;
        buf[2] = week;
        buf[3] = hour;
        buf[4] = length;
        buf[5] = buf[2]^buf[3]^buf[4];
        int len = 6;
        /*
         buf[0] = 0xc4;
         buf[1] = 0x03;
         buf[2] = 0x01;
         buf[3] = 0x06;
         buf[4] = 0x03;
         buf[5] = 0x04;
         int len = 6;
         */
        NSData * data = [NSData dataWithBytes:buf length:len];
        NSLog(@"send api2_send_C4HistoryData buf = %@",data);
        return data;
    }
    else{
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(SyncFinishDelay) userInfo:nil repeats:NO];
        
  //      [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_device_sync object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_sycn_finish_need_reloaddata object:nil];
        
        
        return nil;
    }
    
}
-(void)api2_read_BatteryLevel{
    [self.blecontrol submit_readData:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_BATTERY_CHARATERISTIC_KEY];
    
}


-(NSData*)api2_Send_SleepMode{
    Byte buf[8] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_MODESET;
    buf[1] = 1;
    if(!self.commondata.is_sleepmode){
        buf[2] = 0x80;
    }else{
        buf[2] = 0x00;
    }
    if(self.commondata.is_enable_shock){
        buf[2] = buf[2]+ 0x40;
    }else{
        buf[2] = buf[2]+ 0x00;
    }
    buf[3] = buf[2];
    NSData * data = [NSData dataWithBytes:buf length:8];
    NSLog(@"send api2_Send_SleepMode buf = %@",data);
    return data;
    
}



-(NSData*)api2_Send_Weather{
    if ([self.commondata.weathertype count] == 0) {
        return nil;
    }
    NSNumber* type = [self.commondata.weathertype objectAtIndex:0];
    IRKPhone2DeviceWeather weather;
    weather.temperature = ceil(self.commondata.temp);
    weather.weather_type = type.intValue;
    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
        weather.temperature_type = TEMP_TYPE_C;
    }else{
        weather.temperature_type = TEMP_TYPE_F;
    }

    Byte buf[8] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_WEATHER;
    buf[1] = 0x3;
    buf[2] = weather.weather_type;
    if(weather.temperature >= 0)
        buf[3] = buf[3]|0x80;
    else
        buf[3] = buf[3] & 0x4F;
    if (weather.temperature_type == TEMP_TYPE_C)
        buf[3] = buf[3] | 0x40;
    else
        buf[3] = buf[3] & 0xBF;
    
    buf[4] = abs(weather.temperature);
    buf[5] = buf[2]^buf[3]^buf[4];
    
    NSData * data = [NSData dataWithBytes:buf length:8];
    NSLog(@"send api2_Send_Weather buf = %@",data);
    return data;
    
}


-(NSData*)api2_Send_Antilost:(int)type{
    Byte buf[8] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_ANTILOST;
    buf[1] = 0x01;
    buf[2] = type;
    buf[3] = type;
    
    NSData * data = [NSData dataWithBytes:buf length:8];
    NSLog(@"send api2_Send_Antilost buf = %@",data);
    return data;
    
}
-(NSData*)api2_Send_GetMac{
    Byte buf[8] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_GETMAC;
    buf[1] = 0x00;
    buf[2] = 0x00;
    
    NSData * data = [NSData dataWithBytes:buf length:3];
    NSLog(@"send api2_Send_GetMac buf = %@",data);
    return data;
}

-(NSData*)api2_Send_GetMInfo{
    Byte buf[8] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_MINFO;
    buf[1] = 0x00;
    buf[2] = 0x00;
    
    NSData * data = [NSData dataWithBytes:buf length:8];
    NSLog(@"send api2_Send_GetMInfo buf = %@",data);
    return data;
    
}

- (NSData *)api2_Send_HydrationData{
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_start_set_hydration object:nil];
    
    Byte buf[20] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_SET_HYDRATION;
    buf[1] = 0x6;
 
    Alarm* alarminfo = nil;
    NSString* macid = nil;
    NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bi == nil) {
        macid = nil;
    }else{
        macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
    }
    
    alarminfo = [self.datacenter getAlarmDataByType:ALARM_TYPE_DRINK byIndex:0 byMacid:macid byUid:self.commondata.uid];
    if (alarminfo) {
        if(alarminfo.enable.intValue == 1)
            buf[2] = 1;
        else
            buf[2] = 0;
        buf[3] = alarminfo.hour.intValue;
        buf[4] = alarminfo.minute.intValue;
    
        buf[5] = alarminfo.repeat_hour.intValue;
        buf[6] = alarminfo.repeat_times.intValue;
        if ((alarminfo.weekly.intValue & PERIOD_1) == 1) {
            buf[7] = buf[7] | 1<<7;
        }
        if (((alarminfo.weekly.intValue & PERIOD_2)>>1) == 1) {
            buf[7] = buf[7] | 1<<1;
        }
        if (((alarminfo.weekly.intValue & PERIOD_3)>>2) == 1) {
            buf[7] = buf[7] | 1<<2;
        }
        if (((alarminfo.weekly.intValue & PERIOD_4)>>3) == 1) {
            buf[7] = buf[7] | 1<<3;
        }
        if (((alarminfo.weekly.intValue & PERIOD_5)>>4) == 1) {
            buf[7] = buf[7] | 1<<4;
        }
        if (((alarminfo.weekly.intValue & PERIOD_6)>>5) == 1) {
            buf[7] = buf[7] | 1<<5;
        }
        if (((alarminfo.weekly.intValue & PERIOD_7)>>6) == 1) {
            buf[7] = buf[7] | 1<<6;
        }

    }
    Byte checksum = buf[2];
    for(int i= 3; i < 7; i++){
        checksum = checksum^buf[i];
    };
    buf[8] = checksum;
    NSData * data = [NSData dataWithBytes:buf length:9];
    NSLog(@"send api2_Send_HydrationData buf = %@",data);
    
    return data;
}


- (NSData *)api2_Send_LongsitData{

    Byte buf[20] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_SET_LONGSIT;
    buf[1] = 0x5;
    
    Alarm* alarminfo = nil;
    NSString* macid = nil;
    NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bi == nil) {
        macid = nil;
    }else{
        macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
    }
    
    
    alarminfo = [self.datacenter getAlarmDataByType:ALARM_TYPE_LONGSIT byIndex:0 byMacid:macid byUid:self.commondata.uid];
    if (alarminfo) {
        if(alarminfo.enable.intValue == 1)
            buf[2] = 1;
        else
            buf[2] = 0;
//        buf[3] = alarminfo.repeat_hour.intValue;
//        buf[4] = alarminfo.hour.intValue;
//        buf[5] = alarminfo.minute.intValue;
        buf[3] = alarminfo.starthour.intValue;
        buf[4] = alarminfo.endhour.intValue;
        buf[5] = alarminfo.snooze.intValue;
        if ((alarminfo.weekly.intValue & PERIOD_1) == 1) {
            buf[6] = buf[6] | 1<<7;
        }
        if (((alarminfo.weekly.intValue & PERIOD_2)>>1) == 1) {
            buf[6] = buf[6] | 1<<1;
        }
        if (((alarminfo.weekly.intValue & PERIOD_3)>>2) == 1) {
            buf[6] = buf[6] | 1<<2;
        }
        if (((alarminfo.weekly.intValue & PERIOD_4)>>3) == 1) {
            buf[6] = buf[6] | 1<<3;
        }
        if (((alarminfo.weekly.intValue & PERIOD_5)>>4) == 1) {
            buf[6] = buf[6] | 1<<4;
        }
        if (((alarminfo.weekly.intValue & PERIOD_6)>>5) == 1) {
            buf[6] = buf[6] | 1<<5;
        }
        if (((alarminfo.weekly.intValue & PERIOD_7)>>6) == 1) {
            buf[6] = buf[6] | 1<<6;
        }
        
    }
    Byte checksum = buf[2];
    for(int i= 3; i < 6; i++){
        checksum = checksum^buf[i];
    };
    buf[7] = checksum;

    NSData * data = [NSData dataWithBytes:buf length:8];
    NSLog(@"send api2_Send_Longsit buf = %@",data);
    
    return data;
}


-(NSData*)api2_Send_PersonalData{
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_start_set_personinfo object:nil];
    
    Byte buf[50] = {'\0'};
    buf[0]=HJT_CMD_PHONE2DEVICE_SET_PERSONINFO;
    buf[1]= 47;
//#if defined(CUSTOM_FITRIST)
//#if defined(CUSTOM_CZJK_COMMON)
//#if CUSTOM_FITRIST || CUSTOM_PUZZLE || CUSTOM_GOBAND || CUSTOM_HIMOVE
    //fitrist加了闹钟，闹钟数据用MACID+USERID作为存储索引并且会同步至服务器
    Alarm* alarminfo = nil;
    NSString* macid = nil;
    NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bi == nil) {
        macid = nil;
    }else{
        macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
    }
    
    alarminfo = [self.datacenter getAlarmDataByType:ALARM_TYPE_TIMER byIndex:0 byMacid:macid byUid:self.commondata.uid];
    if (alarminfo) {
        if(alarminfo.enable.intValue == 1)
            buf[2] = 1;
        else
            buf[2] = 0;
        buf[3] = alarminfo.hour.intValue;
        buf[4] = alarminfo.minute.intValue;
        buf[5] = alarminfo.snooze.intValue;
        if ((alarminfo.weekly.intValue & PERIOD_1) == 1) {
            buf[6] = buf[6] | 1<<7;
        }
        if (((alarminfo.weekly.intValue & PERIOD_2)>>1) == 1) {
            buf[6] = buf[6] | 1<<1;
        }
        if (((alarminfo.weekly.intValue & PERIOD_3)>>2) == 1) {
            buf[6] = buf[6] | 1<<2;
        }
        if (((alarminfo.weekly.intValue & PERIOD_4)>>3) == 1) {
            buf[6] = buf[6] | 1<<3;
        }
        if (((alarminfo.weekly.intValue & PERIOD_5)>>4) == 1) {
            buf[6] = buf[6] | 1<<4;
        }
        if (((alarminfo.weekly.intValue & PERIOD_6)>>5) == 1) {
            buf[6] = buf[6] | 1<<5;
        }
        if (((alarminfo.weekly.intValue & PERIOD_7)>>6) == 1) {
            buf[6] = buf[6] | 1<<6;
        }
        
    }
    
    alarminfo = [self.datacenter getAlarmDataByType:ALARM_TYPE_TIMER byIndex:1 byMacid:macid byUid:self.commondata.uid];
    if (alarminfo) {
        if(alarminfo.enable.intValue == 1)
            buf[7] = 1;
        else
            buf[7] = 0;
        buf[8] = alarminfo.hour.intValue;
        buf[9] = alarminfo.minute.intValue;
        buf[10] = alarminfo.snooze.intValue;
        if ((alarminfo.weekly.intValue & PERIOD_1) == 1) {
            buf[11] = buf[11] | 1<<7;
        }
        if (((alarminfo.weekly.intValue & PERIOD_2)>>1) == 1) {
            buf[11] = buf[11] | 1<<1;
        }
        if (((alarminfo.weekly.intValue & PERIOD_3)>>2) == 1) {
            buf[11] = buf[11] | 1<<2;
        }
        if (((alarminfo.weekly.intValue & PERIOD_4)>>3) == 1) {
            buf[11] = buf[11] | 1<<3;
        }
        if (((alarminfo.weekly.intValue & PERIOD_5)>>4) == 1) {
            buf[11] = buf[11] | 1<<4;
        }
        if (((alarminfo.weekly.intValue & PERIOD_6)>>5) == 1) {
            buf[11] = buf[11] | 1<<5;
        }
        if (((alarminfo.weekly.intValue & PERIOD_7)>>6) == 1) {
            buf[11] = buf[11] | 1<<6;
        }
        
    }
    
    alarminfo = [self.datacenter getAlarmDataByType:ALARM_TYPE_TIMER byIndex:2 byMacid:macid byUid:self.commondata.uid];
    if (alarminfo) {
        if(alarminfo.enable.intValue == 1)
            buf[12] = 1;
        else
            buf[12] = 0;
        buf[13] = alarminfo.hour.intValue;
        buf[14] = alarminfo.minute.intValue;
        buf[15] = alarminfo.snooze.intValue;
        if ((alarminfo.weekly.intValue & PERIOD_1) == 1) {
            buf[16] = buf[16] | 1<<7;
        }
        if (((alarminfo.weekly.intValue & PERIOD_2)>>1) == 1) {
            buf[16] = buf[16] | 1<<1;
        }
        if (((alarminfo.weekly.intValue & PERIOD_3)>>2) == 1) {
            buf[16] = buf[16] | 1<<2;
        }
        if (((alarminfo.weekly.intValue & PERIOD_4)>>3) == 1) {
            buf[16] = buf[16] | 1<<3;
        }
        if (((alarminfo.weekly.intValue & PERIOD_5)>>4) == 1) {
            buf[16] = buf[16] | 1<<4;
        }
        if (((alarminfo.weekly.intValue & PERIOD_6)>>5) == 1) {
            buf[16] = buf[16] | 1<<5;
        }
        if (((alarminfo.weekly.intValue & PERIOD_7)>>6) == 1) {
            buf[16] = buf[16] | 1<<6;
        }
        
    }

    alarminfo = [self.datacenter getAlarmDataByType:ALARM_TYPE_TIMER byIndex:3 byMacid:macid byUid:self.commondata.uid];
    if (alarminfo) {
        if(alarminfo.enable.intValue == 1)
            buf[17] = 1;
        else
            buf[17] = 0;
        buf[18] = alarminfo.hour.intValue;
        buf[19] = alarminfo.minute.intValue;
        buf[20] = alarminfo.snooze.intValue;
        if ((alarminfo.weekly.intValue & PERIOD_1) == 1) {
            buf[21] = buf[21] | 1<<7;
        }
        if (((alarminfo.weekly.intValue & PERIOD_2)>>1) == 1) {
            buf[21] = buf[21] | 1<<1;
        }
        if (((alarminfo.weekly.intValue & PERIOD_3)>>2) == 1) {
            buf[21] = buf[21] | 1<<2;
        }
        if (((alarminfo.weekly.intValue & PERIOD_4)>>3) == 1) {
            buf[21] = buf[21] | 1<<3;
        }
        if (((alarminfo.weekly.intValue & PERIOD_5)>>4) == 1) {
            buf[21] = buf[21] | 1<<4;
        }
        if (((alarminfo.weekly.intValue & PERIOD_6)>>5) == 1) {
            buf[21] = buf[21] | 1<<5;
        }
        if (((alarminfo.weekly.intValue & PERIOD_7)>>6) == 1) {
            buf[21] = buf[21] | 1<<6;
        }
        
    }


//#else
//    /*3-7 clock*/
//    if(self.commondata.is_enable_clock)
//        buf[2] = 1;
//    else
//        buf[2] = 0;
//    buf[3] = self.commondata.clock_hour;
//    buf[4] = self.commondata.clock_minute;
//    buf[5] = self.commondata.clock_smart;
//    if ((self.commondata.clock_period & PERIOD_1) == 1) {
//        buf[6] = buf[6] | 1<<1;
//    }
//    if (((self.commondata.clock_period & PERIOD_2)>>1) == 1) {
//        buf[6] = buf[6] | 1<<2;
//    }
//    if (((self.commondata.clock_period & PERIOD_3)>>2) == 1) {
//        buf[6] = buf[6] | 1<<3;
//    }
//    if (((self.commondata.clock_period & PERIOD_4)>>3) == 1) {
//        buf[6] = buf[6] | 1<<4;
//    }
//    if (((self.commondata.clock_period & PERIOD_5)>>4) == 1) {
//        buf[6] = buf[6] | 1<<5;
//    }
//    if (((self.commondata.clock_period & PERIOD_6)>>5) == 1) {
//        buf[6] = buf[6] | 1<<6;
//    }
//    if (((self.commondata.clock_period & PERIOD_7)>>6) == 1) {
//        buf[6] = buf[6] | 1<<7;
//    }
//    /*23-27 idle alert*/
//    if (self.commondata.is_enable_longsitalarm) {
//        buf[22] = 1;
//    }
//    buf[23] = self.commondata.longsit_starthour;
//    buf[24] = self.commondata.longsit_endhour;
//    buf[25] = self.commondata.longsit_time;
//    if ((self.commondata.longsit_period & PERIOD_1) == 1) {
//        buf[26] = buf[26] | 1<<1;
//    }
//    if (((self.commondata.longsit_period & PERIOD_2)>>1) == 1) {
//        buf[26] = buf[26] | 1<<2;
//    }
//    if (((self.commondata.longsit_period & PERIOD_3)>>2) == 1) {
//        buf[26] = buf[26] | 1<<3;
//    }
//    if (((self.commondata.longsit_period & PERIOD_4)>>3) == 1) {
//        buf[26] = buf[26] | 1<<4;
//    }
//    if (((self.commondata.longsit_period & PERIOD_5)>>4) == 1) {
//        buf[26] = buf[26] | 1<<5;
//    }
//    if (((self.commondata.longsit_period & PERIOD_6)>>5) == 1) {
//        buf[26] = buf[26] | 1<<6;
//    }
//    if (((self.commondata.longsit_period & PERIOD_7)>>6) == 1) {
//        buf[26] = buf[26] | 1<<7;
//    }
//#endif
    if (self.commondata.male == 1) {
        buf[35] = 1;
    }else{
        buf[35] = 0;
    }
    buf[36] = (Byte)ceil(self.commondata.height);
    if (self.commondata.measureunit == MEASURE_UNIT_US){
        buf[37] = (Byte)ceil(self.commondata.weight)/KM2MILE;
        buf[38] = (Byte)ceil(self.commondata.stride*KM2MILE);
        buf[39] = (Byte)ceil(self.commondata.stride*KM2MILE);
    }else{
        buf[37] = (Byte)ceil(self.commondata.weight);
        buf[38] = (Byte)ceil(self.commondata.stride);
        buf[39] = (Byte)ceil(self.commondata.stride);
        
    }
    //睡眠启动时间
    buf[40] = 23;
    buf[41] = 0;
    buf[42] = 7;
    buf[43] = 0;
    Byte tmp[4];
    *(uint16_t*)tmp = CFSwapInt16HostToBig(self.commondata.target_steps);
    buf[44] = tmp[0];
    buf[45] = tmp[1];
    buf[46] = tmp[2];
    buf[47] = 0;
    buf[48] = 0;
    
    Byte checksum = buf[2];
    for(int i= 3; i < 49; i++){
        checksum = checksum^buf[i];
    };
    buf[49] = checksum;
    NSData * data = [NSData dataWithBytes:buf length:50];
    NSLog(@"send api2_Send_PersonalData buf = %@",data);
    /*
    Byte buf1[50] = {'\0'};
    buf1[0]=0x84;
    buf1[1]=0x2f;
    buf1[2]=0x01;
    buf1[3]=18;
    buf1[4]=25;
    buf1[5]=1;
    buf1[6]=5;
    Byte checksum2 = buf1[2];
    for(int i= 3; i < 5; i++){
        checksum2 = checksum2^buf1[i];
    };
    buf[7] = checksum2;
    NSData *data1 =[NSData dataWithBytes:buf1 length:8];
    NSLog(@"send api2_Send_PersonalData buf = %@",data1);
    */
    return data;
    
}

-(NSData*)api2_Send_Sleeptime{
    Byte buf[20] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_SET_SLEEP_TIME;
    buf[1] = 0x0F;
    NSDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bonginfo == nil) {
        buf[2] = 0;
        buf[3] = 0;
        buf[4] = 0;
        buf[5] = 0;
        buf[6] = 0;
        buf[7] = 0;
        buf[8] = 0;
        buf[9] = 0;
        buf[10] = 0;
        buf[11] = 0;
        buf[12] = 0;
        buf[13] = 0;
        buf[14] = 0;
        buf[15] = 0;
        buf[16] = 0;
        
    }else{
        NSString* enable = [bonginfo objectForKey:BONGINFO_KEY_SLEEP1_ENABLE];
        if (enable == nil || ![enable isEqualToString:DEF_ENABLE]) {
            buf[2] = 0;
        }else{
            buf[2] = 1;
        }
        NSNumber* val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP1_START_H];
        if (val == nil) {
            buf[3] = 0;
        }else{
            buf[3] = val.intValue;
        }
        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP1_START_M];
        if (val == nil) {
            buf[4] = 0;
        }else{
            buf[4] = val.intValue;
        }
        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP1_END_H];
        if (val == nil) {
            buf[5] = 0;
        }else{
            buf[5] = val.intValue;
        }
        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP1_END_M];
        if (val == nil) {
            buf[6] = 0;
        }else{
            buf[6] = val.intValue;
        }
        enable = [bonginfo objectForKey:BONGINFO_KEY_SLEEP2_ENABLE];
        if (enable == nil || ![enable isEqualToString:DEF_ENABLE]) {
            buf[7] = 0;
        }else{
            buf[7] = 1;
        }
        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP2_START_H];
        if (val == nil) {
            buf[8] = 0;
        }else{
            buf[8] = val.intValue;
        }
        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP2_START_M];
        if (val == nil) {
            buf[9] = 0;
        }else{
            buf[9] = val.intValue;
        }
        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP2_END_H];
        if (val == nil) {
            buf[10] = 0;
        }else{
            buf[10] = val.intValue;
        }
        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP2_END_M];
        if (val == nil) {
            buf[11] = 0;
        }else{
            buf[11] = val.intValue;
        }
        enable = [bonginfo objectForKey:BONGINFO_KEY_SLEEP3_ENABLE];
        if (enable == nil || ![enable isEqualToString:DEF_ENABLE]) {
            buf[12] = 0;
        }else{
            buf[12] = 1;
        }
        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP3_START_H];
        if (val == nil) {
            buf[13] = 0;
        }else{
            buf[13] = val.intValue;
        }
        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP3_START_M];
        if (val == nil) {
            buf[14] = 0;
        }else{
            buf[14] = val.intValue;
        }
        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP3_END_H];
        if (val == nil) {
            buf[15] = 0;
        }else{
            buf[15] = val.intValue;
        }
        val = [bonginfo objectForKey:BONGINFO_KEY_SLEEP3_END_M];
        if (val == nil) {
            buf[16] = 0;
        }else{
            buf[16] = val.intValue;
        }
        
        
        
    }
    
    Byte checksum = buf[2];
    for(int i= 3; i < 17; i++){
        checksum = checksum^buf[i];
    };
    buf[17] = checksum;
    
    NSData * data = [NSData dataWithBytes:buf length:20];
    NSLog(@"send api2_Send_Sleeptime buf = %@",data);
    return data;
    
}



-(NSData*)api2_Send_Alarm:(int)alarmtype{
    Byte buf[20] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_ALARM;
    buf[1] = 2;
    buf[2] = alarmtype;
    buf[3] = 0;
    
    buf[4] = buf[2]^buf[3];
    NSData * data = [NSData dataWithBytes:buf length:5];
    NSLog(@"send api2_Send_Alarm buf = %@",data);
    return data;
    //    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY withRespon:NO protocolcmd:buf[0]];
    //    
}

//-(NSData*)api2_Send_Screentime{
////#ifdef CUSTOM_FITRIST
//#if CUSTOM_FITRIST || CUSTOM_PUZZLE || CUSTOM_NOMI || CUSTOM_HIMOVE
//    //FITRIST 的9B命令增加了一个字节代表手环的震动开关
//    Byte buf[20] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_SET_PARAM;
//    buf[1] = 0x06;
//    if ([self.commondata is24time]) {
//        buf[2] = 1;
//    }else{
//        buf[2] = 0;
//    }
//    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//        buf[3] = 0;
//        //       buf[6] = 1;
//    }else{
//        buf[3] = 1;
//        //       buf[6] = 2;
//    }
//    buf[4] = self.commondata.screentime;
//    buf[5] = 8;
//    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//        buf[6] = 1;
//    }else{
//        buf[6] = 2;
//    }
//    if (self.commondata.is_enable_lowbatteryalarm == YES) {
//        buf[7] = 1;
//    }else{
//        buf[7] = 0;
//    }
//    Byte checksum = buf[2];
//    for(int i= 3; i < 8; i++){
//        checksum = checksum^buf[i];
//    };
//    buf[8] = checksum;
//    
//    NSData * data = [NSData dataWithBytes:buf length:9];
//    NSLog(@"send api2_Send_Screentime buf = %@",data);
//    return data;
//#else
//    Byte buf[20] = {'\0'};
//    buf[0] = HJT_CMD_PHONE2DEVICE_SET_PARAM;
//    buf[1] = 0x05;
//    if ([self.commondata is24time]) {
//        buf[2] = 1;
//    }else{
//        buf[2] = 0;
//    }
//    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//        buf[3] = 0;
//        //       buf[6] = 1;
//    }else{
//        buf[3] = 1;
//        //       buf[6] = 2;
//    }
//    buf[4] = self.commondata.screentime;
//    buf[5] = 0;
//    Byte checksum = buf[2];
//    for(int i= 3; i < 6; i++){
//        checksum = checksum^buf[i];
//    };
//    buf[6] = checksum;
//    
//    NSData * data = [NSData dataWithBytes:buf length:7];
//    NSLog(@"send api2_Send_Screentime buf = %@",data);
//    return data;
//#endif
//    
//}

-(NSData*)api2_Send_Activity_Monitor:(NSInteger)activetype report:(BOOL)reportflag{
    Byte buf[20] = {'\0'};
    buf[0] = HJT_ADV_CMD_PHONE2DEVICE_ACTIVITY_MONITOR;
    buf[1] = 0x11;
    /*    Byte tmp[4];
     *(uint16_t*)tmp = activetype;
     buf[2] = tmp[0];
     buf[3] = tmp[1];
     buf[4] = tmp[2];
     buf[5] = tmp[3];
     */
    buf[2] = (Byte)activetype;
    buf[3] = 0;
    buf[4] = 0;
    buf[5] = 0;
    if (reportflag) {
        buf[6]= 1;
    }else{
        buf[6] = 0;
    }
    
    buf[19] = buf[2]^buf[3]^buf[4]^buf[5]^buf[6];
    NSData * data = [NSData dataWithBytes:buf length:20];
    NSLog(@"send api2_Send_Activity_Monitor buf = %@",data);
    return data;
//    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_ADV_CHARATERISTIC_KEY withRespon:YES protocolcmd:buf[0]];
    
}

-(NSData*)api2_Send_Sync_Sport_Data{
    Byte buf[20] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_SYNC_SPORT_DATA;
    buf[1] = 0x0;
    /*    Byte tmp[4];
     *(uint16_t*)tmp = activetype;
     buf[2] = tmp[0];
     buf[3] = tmp[1];
     buf[4] = tmp[2];
     buf[5] = tmp[3];
     */
    buf[19] = 0x0;
    NSData * data = [NSData dataWithBytes:buf length:20];
    NSLog(@"send api2_Send_Sync_Sport_Data buf = %@",data);
    return data;
    //    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_ADV_CHARATERISTIC_KEY withRespon:YES protocolcmd:buf[0]];
    
}


-(NSData*)api2_Send_Pair{
    Byte buf[20] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_ANCS_PAIR;
    buf[1] = 0x1;
    buf[2] = 0x1;
    buf[3] = 0x1;
    /*    Byte tmp[4];
     *(uint16_t*)tmp = activetype;
     buf[2] = tmp[0];
     buf[3] = tmp[1];
     buf[4] = tmp[2];
     buf[5] = tmp[3];
     */
    buf[19] = 0x0;
    NSData * data = [NSData dataWithBytes:buf length:4];
    NSLog(@"send api2_Send_Pair buf = %@",data);
    return data;
    //    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_ADV_CHARATERISTIC_KEY withRespon:YES protocolcmd:buf[0]];
    
}

-(NSData*)api2_Send_Sensor:(NSUInteger)mode isON:(NSInteger)on isReport:(NSInteger)breport{
    Byte buf[20] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_SENSOR_CHANGE;
    buf[1] = 0x11;
    buf[2] = mode;
    buf[3] = 0;
    buf[4] = 0;
    buf[5] = 0;
    if (on) {
        buf[6] = 1;
    }else{
        buf[6] = 0;
    }
    if (breport) {
        buf[7] = 1;
    }else{
        buf[7] = 0;
    }
    int8_t checksum = buf[2];
    for (int i = 3; i<19; i++) {
        checksum = checksum^buf[i];
    }
    buf[19] = checksum;
    NSData * data = [NSData dataWithBytes:buf length:20];
    NSLog(@"send api2_Send_Sensor buf = %@",data);
    return data;
    //    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_ADV_CHARATERISTIC_KEY withRespon:YES protocolcmd:buf[0]];
    
}

-(NSData*)api2_Send_Nordic_intoOTA{
    Byte buf[20] = {'\0'};
    buf[0] = HJT_CMD_PHONE2DEVICE_NORDIC_INTO_OTA;
    buf[1] = 0x00;
    buf[2] = 0x00;
    
    //
    //    buf[0] = HJT_CMD_PHONE2DEVICE_NORDIC_INTO_OTA2;
    //    buf[1] = 0xFF;
    //    buf[2] = 0xFF;
    //    buf[3] = 0xFF;
    //    buf[4] = 0xFF;
    //    buf[5] = 0xFF;
    //    buf[6] = 0xFF;
    //    buf[7] = 0xFF;
    //    buf[8] = 0xFF;
    //    buf[9] = 0xFF;
    //    buf[10] = 0xFF;
    
    
    //    buf[1] = 0x0;
    //    buf[2] = 0x0;
    NSData * data = [NSData dataWithBytes:buf length:3];
    NSLog(@"send api2_Send_Nordic_intoOTA buf = %@",data);
    return data;
    //    [self.blecontrol submit_writeData:data forPeripheralKey:BLECONNECTED_DEVICE_BONG_KEY forCharacteristicKey:BLECONNECTED_DEVICE_BONG_WRITE_ADV_CHARATERISTIC_KEY withRespon:YES protocolcmd:buf[0]];
    
}
-(NSData*)api2_alarm_name{
    Byte buf[34] = {'\0'};
    buf[0]       = HJT_CMD_ALARM_NAME;
    Alarm* alarminfo = nil;
    NSString* macid = nil;
    NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bi == nil) {
        macid = nil;
    }else{
        macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
    }
//    if (self.setAlarmNameIndex) {
        alarminfo = [self.datacenter getAlarmDataByType:ALARM_TYPE_TIMER byIndex:(int)self.setAlarmNameIndex byMacid:macid byUid:self.commondata.uid];
//    }else{
//        alarminfo = [self.datacenter getAlarmDataByType:ALARM_TYPE_TIMER byIndex:0 byMacid:macid byUid:self.commondata.uid];
//    }
    
    if (alarminfo) {
        buf[2] = self.setAlarmNameIndex+1;
        NSString* name = alarminfo.name;
        char *chname = (char*)[name UTF8String];
        for (int i=0; i<strlen(chname); i++) {
            buf[3+i] = chname[i];
        }
        int len = (int)strlen(chname)+1;
        buf[1] = len;
        int8_t checksum = buf[2];
        for (int i = 3; i<2+len; i++) {
            checksum = checksum^buf[i];
        }
        buf[2+len] = checksum;

        NSData * data = [NSData dataWithBytes:buf length:len+3];
        NSLog(@"send api2_alarm_name buf = %@",data);
        return data;
    }else{
        return nil;
    }
}
-(NSData*)api2_send_sensordata:(int)sensortype{
    Byte buf[34] = {'\0'};
    buf[0]       = HJT_CMD_PHONE2DEVICE_SENSORDATA;
    buf[1]  = 0x11;
    
    NSUInteger lasttime = 0;
    NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bi != nil) {
        NSNumber* lastsensortime = [bi objectForKey:BONGINFO_KEY_LASTSENSORDATATIME];
        if (lastsensortime) {
            lasttime = lastsensortime.unsignedIntegerValue;
        }
    }
    buf[2] = (lasttime>>24)&0xFF;
    buf[3] = (lasttime>>16)&0xFF;
    buf[4] = (lasttime>>8)&0xFF;
    buf[5] = (lasttime)&0xFF;
    buf[6] = sensortype;
    
    int8_t checksum = buf[2];
    for (int i = 3; i<19; i++) {
        checksum = checksum^buf[i];
    }
    buf[19] = checksum;
    NSData * data = [NSData dataWithBytes:buf length:20];
    NSLog(@"send api2_send_sensordata buf = %@",data);
    return data;
    
}

-(void)nextCommand{
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_next_command object:nil];
}

-(void)reinitEnv{
    NSLog(@"------reinitEnv-------");
    self.current_command = @"";
    self.current_state = STATE_CONNECT_IDLE;
    self.sub_state = SUB_STATE_IDLE;
    [self.commandlist removeAllObjects];
    self.expect_response_count = 0;
    self.current_response_count = 0;
    if (self.cmdResendtimer) {
        [self.cmdResendtimer invalidate];
        self.cmdResendtimer = nil;
    }
    
    
}
-(void)onSendNextCommand:(NSNotification*)notify{
    if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
        self.current_response_count = 0;
        return;
    }
    if (self.sub_state != SUB_STATE_IDLE) {
        self.current_response_count = 0;
        return;
    }
    if ([self.commandlist count]) {
        NSString* cmdname = [self.commandlist objectAtIndex:0];
        [self.commandlist removeObjectAtIndex:0];
//        self.expect_response_count = [self getExpectResponseCount:cmdname];
        self.current_response_count = 0;
//        self.current_command = cmdname;
        [self send_command:cmdname];

    }else{
//        if (self.current_state==STATE_CONNECT_INIT) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_band_has_kickoff object:nil userInfo:nil ];
//        }
        //如果是第一次连接则关闭自动连接开关
        NSLog(@"No command need to send");
        //        if (self.current_state==STATE_PROC_EXIST_CONNECTING)
        [self reinitEnv];
        
    }
}

-(int)getExpectResponseCount:(int)msglen{
    if (self.sub_state == SUB_STATE_WAIT_A2_RSP){
        return 1;
    }else{
        int msgtmplen = msglen +3;
        if (msgtmplen % 20 == 0){
            return msgtmplen/20;
        }else{
            return msgtmplen/20 +1;
        }
    }

}


-(void)procAntiLostRsp:(NSData*)recvdata{
    NSLog(@"procAntiLostRsp %@",recvdata);
    

}

-(double)refreshLastReadtime:(double)lasttime{
    NSDate* currentdate = [NSDate date];
    double currentdatetime = [currentdate timeIntervalSince1970];
    double delta = currentdatetime-lasttime;

    if (delta<60*60){
        NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents* comp = [[NSDateComponents alloc] init];
        comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:currentdate];
        int offset = comp.minute%10;

        comp.minute = comp.minute-offset;
        comp.second = 0;
        NSDate* tempdate = [calendar dateFromComponents:comp];
        NSLog(@"refreshLastReadtime = %@",tempdate);
        return [tempdate timeIntervalSince1970];
    }else{
        NSLog(@"refreshLastReadtime = %f",lasttime+60*60);
        return lasttime+60*60;
    }
}

-(void)procA2Rsp:(NSData*)recvdata{
    
    NSLog(@"procA2Rsp:%@",recvdata);
    
    Byte *data = (Byte *)[recvdata bytes];
    
    int offset = 0;
    Byte cmdname = data[offset];
    offset += 1;
    
    //跳过长度
    offset += 1;
    
    if(cmdname != HJT_CMD_PHONE2DEVICE_READ_SPORT_DATA_BY_DAY)
    {
        //如果错误返回，再发一次
        [self sendCmd:CMD_A2];
    }
    else
    {
        //运动类型
        Byte type = data[offset];
        offset += 1;
        //年
        Byte year = data[offset];
        offset += 1;
        //月
        Byte month = data[offset];
        offset += 1;
        //日
        Byte day = data[offset];
        offset += 1;
        
        
        //转成date
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setYear:year+2000];
        [comps setMonth:month];
        [comps setDay:day];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        
        //NSDate *date = [comps date];
        NSDate *date = [gregorian dateFromComponents:comps];
//        double dateTime = [date timeIntervalSince1970];
        //进行时间校验
        //...
        
        //运动时长
        int sportTimes = (data[offset] << 8 & 0xFF00) | data[offset + 1];
        
//        int test2 = THREE_BYTE(0x01, 0x01, 0x02);

        offset += 2;
        //步数
        int steps = THREE_BYTE(data[offset], data[offset + 1], data[offset + 2]);
        offset += 3;
        
        //卡路里
        int cals = TWO_BYTE(data[offset], data[offset + 1]);
        offset += 2;
        
//        Byte checksum = data[offset];
        //进行checksum校验
        
        
        NSMutableDictionary* bonginfo =[self.commondata getBongInformation:self.commondata.lastBongUUID];
        
        NSString* macid = [bonginfo objectForKey:BONGINFO_KEY_BLEADDR];
        
        //数据入库
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Sport_data_history" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adddate = %@ and type = %d and uid IN{%@,%@,%@} and macid IN{%@,%@,%@}",date,type, nil, @"", self.commondata.uid, @"", nil, macid];
        
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects != nil && [fetchedObjects count] != 0)
        {
            for(Sport_data_history *obj in fetchedObjects)
            {
                obj.step = [NSNumber numberWithInt:steps];
                obj.cal = [NSNumber numberWithInt:cals];
                obj.timeLength = [NSNumber numberWithInt:sportTimes];
//                NSLog(@"record = %@",obj);
            }
            
            NSError * error;
            [self.managedObjectContext save:&error];
         }
        else
        {
            //如果为空则insert
            Sport_data_history* record = [NSEntityDescription insertNewObjectForEntityForName:@"Sport_data_history" inManagedObjectContext:self.managedObjectContext];
            record.uid = self.commondata.uid;
            record.macid = macid;
            record.step = [NSNumber numberWithInt:steps];
            record.cal = [NSNumber numberWithInt:cals];
            record.timeLength = [NSNumber numberWithInt:sportTimes];
            record.adddate = date;
            record.type = [NSNumber numberWithInt:type];
//            NSLog(@"record = %@",record);
            
            NSError * error;
            [self.managedObjectContext save:&error];

        }
        
//        NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0];
//        NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
//        [format1 setDateFormat:@"yyyy-MM-dd 00:00:00"];
//        NSString *todayStr = [format1 stringFromDate:today];
//        NSDate *todayDate = [format1 dateFromString:todayStr];
//        double todayTime = [todayDate timeIntervalSince1970];
        
        //如果>=今天的时间就不再发
//        if(dateTime >= todayTime)
//        {
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_read_sport_data_finish object:nil];
//        }
//        else
//        {
//            [self sendCmd:CMD_A2];
//        }
        [self sendCmd:CMD_A2];
    }
}

- (BOOL)isSaveSleepData:(int)res_hour min:(int)res_min
{
    
    NSDate *startTime;
    NSDate *endTime;
    NSInteger maxHour = 0;
    NSInteger minHour = 0;
    NSInteger maxMin = 0;
    NSInteger minMin = 0;
    
    NSMutableDictionary* bonginfo =[self.commondata getBongInformation:self.commondata.lastBongUUID];
    
    //从bonginfo获取开始时间,结束时间
    if ([bonginfo.allKeys containsObject:BONGINFO_KEY_SLEEPSTARTTIME])
    {
        startTime = [bonginfo objectForKey:BONGINFO_KEY_SLEEPSTARTTIME];
    }
    if ([bonginfo.allKeys containsObject:BONGINFO_KEY_SLEEPENDTIME])
    {
        endTime = [bonginfo objectForKey:BONGINFO_KEY_SLEEPENDTIME];
    }
    
    
    if(startTime)
    {

        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps = [calendar components:unitFlags fromDate:startTime];
        
        minMin = [comps minute];
        minHour = [comps hour];
        
    }
    else
    {
        minHour = 22;
    }
    
    if(endTime)
    {

        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps = [calendar components:unitFlags fromDate:endTime];
        
    
        maxHour = [comps hour];
        maxMin = [comps minute];
    }
    else
    {
        maxHour = 8;
    }

    
    if(maxHour >= minHour)
    {
        if(res_hour > minHour && res_hour < maxHour)
        {
            return YES;
        }
        else if(res_hour == minHour && res_min >= minMin)//临界值单独讨论
        {
            return YES;
        }
        else if(res_hour == maxHour && res_min <= maxMin)//临界值单独讨论
        {
            return YES;
        }

        return NO;
    }
    else
    {
        if(res_hour > minHour && (res_hour < 24))
        {
            return YES;
        }
        else if(res_hour == minHour && res_min >= minMin)//临界值单独讨论
        {
            return YES;
        }

        
        if(res_hour >= 0 && res_hour < maxHour)
        {
            return YES;
        }
        else if(res_hour == maxHour && res_min <= maxMin)//临界值单独讨论
        {
            return YES;
        }
        
        return NO;
        
    }


}

-(void)procC4Rsp:(NSData*)recvdata{
    NSLog(@"procC4Rsp :: %@ ,current_response_count=%d",recvdata,self.current_response_count);
    if (self.current_response_count < self.expect_response_count) {
        [self.cachedata appendData:recvdata];
        return;
    }
    if (self.current_response_count >= self.expect_response_count) {
        [self.cachedata appendData:recvdata];
        
        //6字节   RECV:<24281004 1c090000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000100 000000>
        //6字节   RECV:<24281004 1c0f0014 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00001300 000000>
        //2字节   RECV:<24101004 1d090056 00000000 00000000 00005600>
        NSLog(@"RECV:%@",self.cachedata);
        
        //根据报文长度判断是新协议还是旧协议
        //步数+卡路里+距离：新协议2字节，旧协议6字节
        Byte* bytearray = (Byte*)[self.cachedata bytes];
        Byte cmdname = bytearray[0];
        Byte cmdparamlen = bytearray[1];
        
        if(cmdparamlen < 0x28)
        {
            //新协议
            if (cmdname == HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_WEEK_OK) {
                //NSLog(@"buf = %@",recvdata);
                NSMutableDictionary* bonginfo =[self.commondata getBongInformation:self.commondata.lastBongUUID];
                double lastReadDataTime = [[bonginfo objectForKey:BONGINFO_KEY_LASTSYNCTIME] doubleValue];
                NSString* macid = [bonginfo objectForKey:BONGINFO_KEY_BLEADDR];
                if (macid == nil) {
                    macid = @"";
                }
                if(![self CheckData:recvdata]){
                    NSLog(@"RecvData Error!");
                    //            [self.commandlist addObject:CMD_C4];
                    lastReadDataTime =[self refreshLastReadtime:lastReadDataTime];
                    [bonginfo setObject:[NSNumber numberWithDouble:lastReadDataTime] forKey:BONGINFO_KEY_LASTSYNCTIME];
                    [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_recv_device_sync_data object:nil];
                    [self sendCmd:CMD_C4];
                    
                    return;
                }
                
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                NSInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour;
                //先校验日期是否正确
                NSDate* cdate = [NSDate dateWithTimeIntervalSince1970:lastReadDataTime];
                NSDate* currentdate = [NSDate date];
//                double currentdatetime = [currentdate timeIntervalSince1970];
                //            NSTimeInterval  timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
                //            cdate = [cdate dateByAddingTimeInterval:timeZoneOffset];
                comps = [calendar components:unitFlags fromDate:cdate];
                NSInteger year = [comps year];
                NSInteger month = [comps month];
                NSInteger day = [comps day];
                NSInteger hour = [comps hour];
                int res_year = bytearray[2]+2000;
                int res_month = bytearray[3];
                int res_day = bytearray[4];
                int res_hour = bytearray[5];
                NSLog(@"Currentdate = %ld-%ld-%ld %ld",year,month,day,hour);
                NSLog(@"responesdate = %d-%d-%d %d",res_year,res_month,res_day,res_hour);
                if (year!= res_year || month != res_month || res_day!= day || res_hour != hour) {
                    NSLog(@"INVALID HISTORY DATA");
                    lastReadDataTime =[self refreshLastReadtime:lastReadDataTime];
                    [bonginfo setObject:[NSNumber numberWithDouble:lastReadDataTime] forKey:BONGINFO_KEY_LASTSYNCTIME];
                    [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_recv_device_sync_data object:nil];
                    //            [self.commandlist addObject:CMD_C4];
                    [self sendCmd:CMD_C4];
                    
                    return;
                }
                
                
                
                NSDate* t1 = [NSDate date];
                NSError * error;
                int readoffset = 6;
                int readtimes = 6;
                int currentreadtimes = 0;
                int readbytes = 0;
                NSDateFormatter* format = [[NSDateFormatter alloc] init];
                [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                [format setTimeZone:[NSTimeZone systemTimeZone]];
                format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                
//                int deltaStep = 0;
//                int deltaDeep = 0;
//                int deltaLight = 0;
//                int deltaAwake = 0;
//                int deltaExLight =0;
                //            NSString* datacenter_hourkey = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d",res_year,res_month,res_day, res_hour];
                //            NSString* datacenter_daykey = [NSString stringWithFormat:@"%d-%.2d-%.2d",res_year,res_month,res_day];
                //            NSString* datacenter_monthkey = [NSString stringWithFormat:@"%d-%.2d",res_year,res_month];
//                NSString* monthdatestr = [NSString stringWithFormat:@"%d-%.2d-01 00:00:00",(int)year, (int)month];
//                NSString* daydatestr = [NSString stringWithFormat:@"%d-%.2d-%.2d 00:00:00",(int)year, (int)month, (int)day];
//                NSString* hourdatestr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:00:00",(int)year,(int)month, (int)day, (int)hour];
//                NSDate* monthdate = [format dateFromString:monthdatestr];
//                NSDate* daydate = [format dateFromString:daydatestr];
//                NSDate* hourdate = [format dateFromString:hourdatestr];
                
                NSString* startstr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:00:00",res_year,res_month,res_day, res_hour];
                NSDate* startdate = [format dateFromString:startstr];
                NSString* endstr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:59:59",res_year,res_month,res_day, res_hour];
                NSDate* enddate = [format dateFromString:endstr];
                
                //先找当前已存在的记录 用年-月-日 时：分的结构作为KEY存在字典中
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
                [fetchRequest setEntity:entity];
                // Specify criteria for filtering which objects to fetch
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid IN {%@,%@,%@} and macid in {%@,%@,%@}", startdate, enddate, nil, @"", self.commondata.uid, nil, @"", macid];
                
                [fetchRequest setPredicate:predicate];
                // Specify how the fetched objects should be sorted
                NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                NSMutableDictionary* existRecordDict = [[NSMutableDictionary alloc] init];
                if (fetchedObjects) {
                    [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        StepHistory* record = (StepHistory*)obj;
                        NSDateFormatter* format = [[NSDateFormatter alloc] init];
                        format.dateFormat = @"yyyy-MM-dd HH:mm";
                        NSString* key = [format stringFromDate:record.datetime];
                        [existRecordDict setObject:record forKey:key];
                    }];
                }
                //读取数据
                
                //所有这个小时内的步数差额，用于计算统计表的值
                while(currentreadtimes < readtimes){
                    NSString* datestr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:%.2d:00",res_year,res_month,res_day, res_hour, currentreadtimes*10];
                    NSLog(@"current datestr = %@",datestr);
                    NSString* checkkey = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:%.2d",res_year,res_month,res_day, res_hour, currentreadtimes*10];
                    
                    NSDate* cdate = [format dateFromString:datestr];
                    if([currentdate timeIntervalSinceDate:cdate]<10*60){
                        NSLog(@"最近的10分钟，不记录");
                        break;
                    }
                    
                    //0014
                    uint8_t tmp[2];
                    tmp[0] = bytearray[readoffset];
                    tmp[1] = bytearray[readoffset+1];
                    unsigned int mode = tmp[0] >> 6;
                    if(mode == 3){
                        NSLog(@"c4 mode = 3, ignore current data");
                        readoffset += 2;
                        readbytes += 2;
                        currentreadtimes += 1;
                        continue;
                    }
                    uint8_t t = tmp[0] << 2;
                    tmp[0] = t >> 2;
                    //                uint16_t steps = CFSwapInt16BigToHost(*(int16_t*)tmp);
                    uint16_t steps = tmp[0]*0x100+tmp[1];
                    if (steps >= 0x3FFF) {
                        steps = 0;
                    }
                    
                    //固定为0
                    uint16_t cal = 0;
                    
                    uint16_t dis = 0;
                    
                    NSLog(@"steps = %d, cal=%d, dis=%d",steps, cal,dis);
                    
                    if ([existRecordDict.allKeys containsObject:checkkey]) {
                        StepHistory* record = [existRecordDict objectForKey:checkkey];
//                        if (mode != HJT_STEP_MODE_SLEEP) {
//                            deltaStep += steps - record.steps.unsignedShortValue;
//                        }else{
//                            int newAwake = 0;
//                            int newExlight = 0;
//                            int newLight = 0;
//                            int newDeep = 0;
//                            int oldAwake = 0;
//                            int oldExlight = 0;
//                            int oldLight = 0;
//                            int oldDeep = 0;
//                            if (record.steps.intValue > HJT_SLEEP_MODE_AWAKE) {
//                                oldAwake += 10*60;
//                            }
//                            else if(record.steps.intValue > HJT_SLEEP_MODE_EXLIGHT){
//                                oldExlight += 10*60;
//                            }
//                            else if(record.steps.intValue > HJT_SLEEP_MODE_LIGHT){
//                                oldLight += 10*60;
//                            }else{
//                                oldDeep += 10*60;
//                            }
//                            
//                            if (steps > HJT_SLEEP_MODE_AWAKE) {
//                                newAwake += 10*60;
//                            }
//                            else if(steps > HJT_SLEEP_MODE_EXLIGHT){
//                                newExlight += 10*60;
//                            }
//                            else if(steps > HJT_SLEEP_MODE_LIGHT){
//                                newLight += 10*60;
//                            }else{
//                                newDeep += 10*60;
//                            }
//                            deltaAwake += newAwake-oldAwake;
//                            deltaExLight += newExlight-oldExlight;
//                            deltaLight += newLight-oldLight;
//                            deltaDeep += newDeep-oldDeep;
//                            
//                        }
                        
                        record.steps = [NSNumber numberWithInt:steps];
                        record.cal = [NSNumber numberWithUnsignedInteger:cal];
                        record.distance = [NSNumber numberWithUnsignedInteger:dis];
                        record.mode = [NSNumber numberWithUnsignedInt:mode];
                        record.macid = macid;
                        record.uid = self.commondata.uid;
                        NSLog(@"update exist record = %@",record);
                    }else{
                        StepHistory* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
                        record.cal = [NSNumber numberWithUnsignedInteger:cal];
                        record.distance = [NSNumber numberWithUnsignedInteger:dis];
                        record.mode = [NSNumber numberWithUnsignedInt:mode];
                        record.uid = self.commondata.uid;
                        record.macid = macid;
                        record.memberid = self.commondata.memberid;
//                        if (mode != HJT_STEP_MODE_SLEEP) {
//                            deltaStep += steps;
//                        }else{
//                            if (steps > HJT_SLEEP_MODE_AWAKE) {
//                                deltaAwake += 10*60;
//                            }
//                            else if(steps > HJT_SLEEP_MODE_EXLIGHT){
//                                deltaExLight += 10*60;
//                            }
//                            else if(steps > HJT_SLEEP_MODE_LIGHT){
//                                deltaLight += 10*60;
//                            }else{
//                                deltaDeep += 10*60;
//                            }
//                            
//                        }
                        record.steps = [NSNumber numberWithUnsignedInt:steps];
                        record.datetime = cdate;
                        record.type = [NSNumber numberWithInt:0];
                        record.issync = [NSNumber numberWithInt:NO];
                        //////////for healthkit/////////////
                        record.issynchealthkit = [NSNumber numberWithBool:NO];
                        
//                        NSLog(@"record = %@",record);
                    }
                    
                    readoffset += 2;
                    readbytes += 2;
                    currentreadtimes += 1;
                }
//                NSLog(@"deltaStep=%d,detlaAwake=%d,deltaExlight=%d,deltaLight=%d,deltaDeep=%d",deltaStep,deltaAwake,deltaExLight,deltaLight,deltaDeep);
//                
//                if (deltaStep != 0) {
//                    //有增量 小时
//                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//                    [fetchRequest setEntity:entity];
//                    // Specify criteria for filtering which objects to fetch
//                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", hourdate,self.commondata.uid, macid];
//                    
//                    [fetchRequest setPredicate:predicate];
//                    // Specify how the fetched objects should be sorted
//                    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                    if (fetchedObjects.count) {
//                        StepHistory_Hour* record = [fetchedObjects objectAtIndex:0];
//                        record.steps = [NSNumber numberWithInt:record.steps.intValue+deltaStep];
//                    }else{
//                        StepHistory_Hour* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//                        record.steps = [NSNumber numberWithInt:deltaStep];
//                        record.cal = @0;
//                        record.distance = @0;
//                        record.macid = macid;
//                        record.uid = self.commondata.uid;
//                        record.datetime = hourdate;
//                    }
//                    //天
//                    entity = [NSEntityDescription entityForName:@"StepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//                    [fetchRequest setEntity:entity];
//                    // Specify criteria for filtering which objects to fetch
//                    predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", daydate,self.commondata.uid, macid];
//                    
//                    [fetchRequest setPredicate:predicate];
//                    // Specify how the fetched objects should be sorted
//                    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                    if (fetchedObjects.count) {
//                        StepHistory_Day* record = [fetchedObjects objectAtIndex:0];
//                        record.steps = [NSNumber numberWithInt:record.steps.intValue+deltaStep];
//                    }else{
//                        StepHistory_Day* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//                        record.steps = [NSNumber numberWithInt:deltaStep];
//                        record.cal = @0;
//                        record.distance = @0;
//                        record.macid = macid;
//                        record.uid = self.commondata.uid;
//                        record.datetime = daydate;
//                    }
//                    //天
//                    entity = [NSEntityDescription entityForName:@"StepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//                    [fetchRequest setEntity:entity];
//                    // Specify criteria for filtering which objects to fetch
//                    predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", monthdate,self.commondata.uid, macid];
//                    
//                    [fetchRequest setPredicate:predicate];
//                    // Specify how the fetched objects should be sorted
//                    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                    if (fetchedObjects.count) {
//                        StepHistory_Month* record = [fetchedObjects objectAtIndex:0];
//                        record.steps = [NSNumber numberWithInt:record.steps.intValue+deltaStep];
//                    }else{
//                        StepHistory_Month* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//                        record.steps = [NSNumber numberWithInt:deltaStep];
//                        record.cal = @0;
//                        record.distance = @0;
//                        record.macid = macid;
//                        record.uid = self.commondata.uid;
//                        record.datetime = monthdate;
//                    }
//                    
//                    
//                }
//                
//                if (deltaAwake != 0 ||
//                    deltaExLight != 0 ||
//                    deltaLight != 0 ||
//                    deltaDeep != 0 ) {
//                    //有睡眠增量
//                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SleepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//                    [fetchRequest setEntity:entity];
//                    // Specify criteria for filtering which objects to fetch
//                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", hourdate,self.commondata.uid, macid];
//                    
//                    [fetchRequest setPredicate:predicate];
//                    // Specify how the fetched objects should be sorted
//                    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                    if (fetchedObjects.count) {
//                        SleepHistory_Hour* record = [fetchedObjects objectAtIndex:0];
//                        record.awake = [NSNumber numberWithFloat:record.awake.doubleValue+deltaAwake];
//                        record.exlight = [NSNumber numberWithFloat:record.exlight.doubleValue+deltaExLight];
//                        record.light = [NSNumber numberWithFloat:record.light.doubleValue+deltaLight];
//                        record.deep = [NSNumber numberWithFloat:record.deep.doubleValue+deltaDeep];
//                    }else{
//                        SleepHistory_Hour* record = [NSEntityDescription insertNewObjectForEntityForName:@"SleepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//                        record.deep = [NSNumber numberWithDouble:deltaDeep];
//                        record.exlight = [NSNumber numberWithDouble:deltaExLight];
//                        record.light = [NSNumber numberWithDouble:deltaLight];
//                        record.awake = [NSNumber numberWithDouble:deltaAwake];
//                        record.macid = macid;
//                        record.uid = self.commondata.uid;
//                        record.datetime = hourdate;
//                    }
//                    //天
//                    entity = [NSEntityDescription entityForName:@"SleepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//                    [fetchRequest setEntity:entity];
//                    // Specify criteria for filtering which objects to fetch
//                    predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", daydate,self.commondata.uid, macid];
//                    
//                    [fetchRequest setPredicate:predicate];
//                    // Specify how the fetched objects should be sorted
//                    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                    if (fetchedObjects.count) {
//                        SleepHistory_Day* record = [fetchedObjects objectAtIndex:0];
//                        record.awake = [NSNumber numberWithFloat:record.awake.doubleValue+deltaAwake];
//                        record.exlight = [NSNumber numberWithFloat:record.exlight.doubleValue+deltaExLight];
//                        record.light = [NSNumber numberWithFloat:record.light.doubleValue+deltaLight];
//                        record.deep = [NSNumber numberWithFloat:record.deep.doubleValue+deltaDeep];
//                    }else{
//                        SleepHistory_Day* record = [NSEntityDescription insertNewObjectForEntityForName:@"SleepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//                        record.deep = [NSNumber numberWithDouble:deltaDeep];
//                        record.exlight = [NSNumber numberWithDouble:deltaExLight];
//                        record.light = [NSNumber numberWithDouble:deltaLight];
//                        record.awake = [NSNumber numberWithDouble:deltaAwake];
//                        record.macid = macid;
//                        record.uid = self.commondata.uid;
//                        record.datetime = daydate;
//                    }
//                    //天
//                    entity = [NSEntityDescription entityForName:@"SleepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//                    [fetchRequest setEntity:entity];
//                    // Specify criteria for filtering which objects to fetch
//                    predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", monthdate,self.commondata.uid, macid];
//                    
//                    [fetchRequest setPredicate:predicate];
//                    // Specify how the fetched objects should be sorted
//                    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                    if (fetchedObjects.count) {
//                        SleepHistory_Month* record = [fetchedObjects objectAtIndex:0];
//                        record.awake = [NSNumber numberWithFloat:record.awake.doubleValue+deltaAwake];
//                        record.exlight = [NSNumber numberWithFloat:record.exlight.doubleValue+deltaExLight];
//                        record.light = [NSNumber numberWithFloat:record.light.doubleValue+deltaLight];
//                        record.deep = [NSNumber numberWithFloat:record.deep.doubleValue+deltaDeep];
//                    }else{
//                        SleepHistory_Month* record = [NSEntityDescription insertNewObjectForEntityForName:@"SleepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//                        record.deep = [NSNumber numberWithDouble:deltaDeep];
//                        record.exlight = [NSNumber numberWithDouble:deltaExLight];
//                        record.light = [NSNumber numberWithDouble:deltaLight];
//                        record.awake = [NSNumber numberWithDouble:deltaAwake];
//                        record.macid = macid;
//                        record.uid = self.commondata.uid;
//                        record.datetime = monthdate;
//                    }
//                    
//                    
//                }
//                
                //[self.managedObjectContext save:&error];
                [self saveDB];
                
                NSLog(@"proc data time = %f", [[NSDate date] timeIntervalSinceDate:t1]);
                lastReadDataTime =[self refreshLastReadtime:lastReadDataTime];
                [bonginfo setObject:[NSNumber numberWithDouble:lastReadDataTime] forKey:BONGINFO_KEY_LASTSYNCTIME];
                [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_recv_device_sync_data object:nil];
                [self sendCmd:CMD_C4];
                
                //        [self.commandlist addObject:CMD_C4];
            }else{
                [self sendCmd:CMD_C4];
                //        [self.commandlist addObject:CMD_C4];
            }
            
        }
        else
        {
            //旧协议
            if (cmdname == HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_WEEK_OK) {
                //NSLog(@"buf = %@",recvdata);
                NSMutableDictionary* bonginfo =[self.commondata getBongInformation:self.commondata.lastBongUUID];
                double lastReadDataTime = [[bonginfo objectForKey:BONGINFO_KEY_LASTSYNCTIME] doubleValue];
                NSString* macid = [bonginfo objectForKey:BONGINFO_KEY_BLEADDR];
                if (macid == nil) {
                    macid = @"";
                }
                if(![self CheckData:recvdata]){
                    NSLog(@"RecvData Error!");
                    //            [self.commandlist addObject:CMD_C4];
                    lastReadDataTime =[self refreshLastReadtime:lastReadDataTime];
                    [bonginfo setObject:[NSNumber numberWithDouble:lastReadDataTime] forKey:BONGINFO_KEY_LASTSYNCTIME];
                    [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_recv_device_sync_data object:nil];
                    [self sendCmd:CMD_C4];
                    
                    return;
                }
                
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                NSInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour;
                //先校验日期是否正确
                NSDate* cdate = [NSDate dateWithTimeIntervalSince1970:lastReadDataTime];
                NSDate* currentdate = [NSDate date];
//                double currentdatetime = [currentdate timeIntervalSince1970];
                //            NSTimeInterval  timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
                //            cdate = [cdate dateByAddingTimeInterval:timeZoneOffset];
                comps = [calendar components:unitFlags fromDate:cdate];
                NSInteger year = [comps year];
                NSInteger month = [comps month];
                NSInteger day = [comps day];
                NSInteger hour = [comps hour];
                int res_year = bytearray[2]+2000;
                int res_month = bytearray[3];
                int res_day = bytearray[4];
                int res_hour = bytearray[5];
                NSLog(@"Currentdate = %d-%d-%d %d",(int)year,(int)month,(int)day,(int)hour);
                NSLog(@"responesdate = %d-%d-%d %d",res_year,res_month,res_day,res_hour);
                if (year!= res_year || month != res_month || res_day!= day || res_hour != hour) {
                    NSLog(@"INVALID HISTORY DATA");
                    lastReadDataTime =[self refreshLastReadtime:lastReadDataTime];
                    [bonginfo setObject:[NSNumber numberWithDouble:lastReadDataTime] forKey:BONGINFO_KEY_LASTSYNCTIME];
                    [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_recv_device_sync_data object:nil];
                    //            [self.commandlist addObject:CMD_C4];
                    [self sendCmd:CMD_C4];
                    
                    return;
                }
                
                
                
                NSDate* t1 = [NSDate date];
                NSError * error;
                int readoffset = 6;
                int readtimes = 6;
                int currentreadtimes = 0;
                int readbytes = 0;
                NSDateFormatter* format = [[NSDateFormatter alloc] init];
                [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                [format setTimeZone:[NSTimeZone systemTimeZone]];
                format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                
//                int deltaStep = 0;
//                int deltaDeep = 0;
//                int deltaLight = 0;
//                int deltaAwake = 0;
//                int deltaExLight =0;
                //            NSString* datacenter_hourkey = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d",res_year,res_month,res_day, res_hour];
                //            NSString* datacenter_daykey = [NSString stringWithFormat:@"%d-%.2d-%.2d",res_year,res_month,res_day];
                //            NSString* datacenter_monthkey = [NSString stringWithFormat:@"%d-%.2d",res_year,res_month];
//                NSString* monthdatestr = [NSString stringWithFormat:@"%d-%.2d-01 00:00:00",(int)year, (int)month];
//                NSString* daydatestr = [NSString stringWithFormat:@"%d-%.2d-%.2d 00:00:00",(int)year, (int)month, (int)day];
//                NSString* hourdatestr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:00:00",(int)year,(int)month, (int)day, (int)hour];
//                NSDate* monthdate = [format dateFromString:monthdatestr];
//                NSDate* daydate = [format dateFromString:daydatestr];
//                NSDate* hourdate = [format dateFromString:hourdatestr];
                
                NSString* startstr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:00:00",res_year,res_month,res_day, res_hour];
                NSDate* startdate = [format dateFromString:startstr];
                NSString* endstr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:59:59",res_year,res_month,res_day, res_hour];
                NSDate* enddate = [format dateFromString:endstr];
                
                //先找当前已存在的记录 用年-月-日 时：分的结构作为KEY存在字典中
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
                [fetchRequest setEntity:entity];
                // Specify criteria for filtering which objects to fetch
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid IN {%@,%@,%@} and macid in {%@,%@,%@}", startdate, enddate, nil, @"", self.commondata.uid, nil, @"", macid];
                
                [fetchRequest setPredicate:predicate];
                // Specify how the fetched objects should be sorted
                NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                NSMutableDictionary* existRecordDict = [[NSMutableDictionary alloc] init];
                if (fetchedObjects) {
                    [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        StepHistory* record = (StepHistory*)obj;
                        NSDateFormatter* format = [[NSDateFormatter alloc] init];
                        format.dateFormat = @"yyyy-MM-dd HH:mm";
                        NSString* key = [format stringFromDate:record.datetime];
                        [existRecordDict setObject:record forKey:key];
                    }];
                }
                //读取数据
                
                //所有这个小时内的步数差额，用于计算统计表的值
                while(currentreadtimes < readtimes){
                    NSString* datestr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:%.2d:00",res_year,res_month,res_day, res_hour, currentreadtimes*10];
                    NSLog(@"current datestr = %@",datestr);
                    NSString* checkkey = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:%.2d",res_year,res_month,res_day, res_hour, currentreadtimes*10];
                    
                    NSDate* cdate = [format dateFromString:datestr];
                    if([currentdate timeIntervalSinceDate:cdate]<10*60){
                        NSLog(@"最近的10分钟，不记录");
                        break;
                    }
                    
                    //0014
                    uint8_t tmp[2];
                    tmp[0] = bytearray[readoffset];
                    tmp[1] = bytearray[readoffset+1];
                    unsigned int mode = tmp[0] >> 6;
                    uint8_t t = tmp[0] << 2;
                    tmp[0] = t >> 2;
                    //                uint16_t steps = CFSwapInt16BigToHost(*(int16_t*)tmp);
                    uint16_t steps = tmp[0]*0x100+tmp[1];
                    if (steps >= 0x3FFF) {
                        steps = 0;
                    }
                    
                    if(mode == 3){
                        NSLog(@"c4 mode = 3, ignore current data");
                        readoffset += 6;
                        readbytes += 6;
                        currentreadtimes += 1;
                        continue;
                    }

                    tmp[0] = bytearray[readoffset+2];
                    tmp[1] = bytearray[readoffset+3];
                    uint16_t cal = CFSwapInt16BigToHost(*(int16_t*)tmp);
                    
                    tmp[0] = bytearray[readoffset+4];
                    tmp[1] = bytearray[readoffset+5];
                    uint16_t dis = CFSwapInt16BigToHost(*(int16_t*)tmp);
                    
                    NSLog(@"steps = %d, cal=%d, dis=%d",steps, cal,dis);
                    
                    if ([existRecordDict.allKeys containsObject:checkkey]) {
                        StepHistory* record = [existRecordDict objectForKey:checkkey];
//                        if (mode != HJT_STEP_MODE_SLEEP) {
//                            deltaStep += steps - record.steps.unsignedShortValue;
//                        }else{
//                            int newAwake = 0;
//                            int newExlight = 0;
//                            int newLight = 0;
//                            int newDeep = 0;
//                            int oldAwake = 0;
//                            int oldExlight = 0;
//                            int oldLight = 0;
//                            int oldDeep = 0;
//                            if (record.steps.intValue > HJT_SLEEP_MODE_AWAKE) {
//                                oldAwake += 10*60;
//                            }
//                            else if(record.steps.intValue > HJT_SLEEP_MODE_EXLIGHT){
//                                oldExlight += 10*60;
//                            }
//                            else if(record.steps.intValue > HJT_SLEEP_MODE_LIGHT){
//                                oldLight += 10*60;
//                            }else{
//                                oldDeep += 10*60;
//                            }
//                            
//                            if (steps > HJT_SLEEP_MODE_AWAKE) {
//                                newAwake += 10*60;
//                            }
//                            else if(steps > HJT_SLEEP_MODE_EXLIGHT){
//                                newExlight += 10*60;
//                            }
//                            else if(steps > HJT_SLEEP_MODE_LIGHT){
//                                newLight += 10*60;
//                            }else{
//                                newDeep += 10*60;
//                            }
//                            deltaAwake += newAwake-oldAwake;
//                            deltaExLight += newExlight-oldExlight;
//                            deltaLight += newLight-oldLight;
//                            deltaDeep += newDeep-oldDeep;
//                            
//                        }
                        
                        record.steps = [NSNumber numberWithInt:steps];
                        record.cal = [NSNumber numberWithUnsignedInteger:cal];
                        record.distance = [NSNumber numberWithUnsignedInteger:dis];
                        record.mode = [NSNumber numberWithUnsignedInt:mode];
                        record.macid = macid;
                        record.uid = self.commondata.uid;
                        NSLog(@"update exist record = %@",record);
                    }else{
                        StepHistory* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
                        record.cal = [NSNumber numberWithUnsignedInteger:cal];
                        record.distance = [NSNumber numberWithUnsignedInteger:dis];
                        record.mode = [NSNumber numberWithUnsignedInt:mode];
                        record.uid = self.commondata.uid;
                        record.macid = macid;
                        record.memberid = self.commondata.memberid;
//                        if (mode != HJT_STEP_MODE_SLEEP) {
//                            deltaStep += steps;
//                        }else{
//                            if (steps > HJT_SLEEP_MODE_AWAKE) {
//                                deltaAwake += 10*60;
//                            }
//                            else if(steps > HJT_SLEEP_MODE_EXLIGHT){
//                                deltaExLight += 10*60;
//                            }
//                            else if(steps > HJT_SLEEP_MODE_LIGHT){
//                                deltaLight += 10*60;
//                            }else{
//                                deltaDeep += 10*60;
//                            }
//                            
//                        }
                        record.steps = [NSNumber numberWithUnsignedInt:steps];
                        record.datetime = cdate;
                        record.type = [NSNumber numberWithInt:0];
                        record.issync = [NSNumber numberWithBool:NO];
                        //////////for healthkit/////////////
                        record.issynchealthkit = [NSNumber numberWithBool:NO];
//                        NSLog(@"record = %@",record);
                    }
                    
                    readoffset += 6;
                    readbytes += 6;
                    currentreadtimes += 1;
                }
//                NSLog(@"deltaStep=%d,detlaAwake=%d,deltaExlight=%d,deltaLight=%d,deltaDeep=%d",deltaStep,deltaAwake,deltaExLight,deltaLight,deltaDeep);
//                
//                if (deltaStep != 0) {
//                    //有增量 小时
//                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//                    [fetchRequest setEntity:entity];
//                    // Specify criteria for filtering which objects to fetch
//                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", hourdate,self.commondata.uid, macid];
//                    
//                    [fetchRequest setPredicate:predicate];
//                    // Specify how the fetched objects should be sorted
//                    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                    if (fetchedObjects.count) {
//                        StepHistory_Hour* record = [fetchedObjects objectAtIndex:0];
//                        record.steps = [NSNumber numberWithInt:record.steps.intValue+deltaStep];
//                    }else{
//                        StepHistory_Hour* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//                        record.steps = [NSNumber numberWithInt:deltaStep];
//                        record.cal = @0;
//                        record.distance = @0;
//                        record.macid = macid;
//                        record.uid = self.commondata.uid;
//                        record.datetime = hourdate;
//                    }
//                    //天
//                    entity = [NSEntityDescription entityForName:@"StepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//                    [fetchRequest setEntity:entity];
//                    // Specify criteria for filtering which objects to fetch
//                    predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", daydate,self.commondata.uid, macid];
//                    
//                    [fetchRequest setPredicate:predicate];
//                    // Specify how the fetched objects should be sorted
//                    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                    if (fetchedObjects.count) {
//                        StepHistory_Day* record = [fetchedObjects objectAtIndex:0];
//                        record.steps = [NSNumber numberWithInt:record.steps.intValue+deltaStep];
//                    }else{
//                        StepHistory_Day* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//                        record.steps = [NSNumber numberWithInt:deltaStep];
//                        record.cal = @0;
//                        record.distance = @0;
//                        record.macid = macid;
//                        record.uid = self.commondata.uid;
//                        record.datetime = daydate;
//                    }
//                    //天
//                    entity = [NSEntityDescription entityForName:@"StepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//                    [fetchRequest setEntity:entity];
//                    // Specify criteria for filtering which objects to fetch
//                    predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", monthdate,self.commondata.uid, macid];
//                    
//                    [fetchRequest setPredicate:predicate];
//                    // Specify how the fetched objects should be sorted
//                    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                    if (fetchedObjects.count) {
//                        StepHistory_Month* record = [fetchedObjects objectAtIndex:0];
//                        record.steps = [NSNumber numberWithInt:record.steps.intValue+deltaStep];
//                    }else{
//                        StepHistory_Month* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//                        record.steps = [NSNumber numberWithInt:deltaStep];
//                        record.cal = @0;
//                        record.distance = @0;
//                        record.macid = macid;
//                        record.uid = self.commondata.uid;
//                        record.datetime = monthdate;
//                    }
//                    
//                    
//                }
//                
//                if (deltaAwake != 0 ||
//                    deltaExLight != 0 ||
//                    deltaLight != 0 ||
//                    deltaDeep != 0 ) {
//                    //有睡眠增量
//                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SleepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//                    [fetchRequest setEntity:entity];
//                    // Specify criteria for filtering which objects to fetch
//                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", hourdate,self.commondata.uid, macid];
//                    
//                    [fetchRequest setPredicate:predicate];
//                    // Specify how the fetched objects should be sorted
//                    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                    if (fetchedObjects.count) {
//                        SleepHistory_Hour* record = [fetchedObjects objectAtIndex:0];
//                        record.awake = [NSNumber numberWithFloat:record.awake.doubleValue+deltaAwake];
//                        record.exlight = [NSNumber numberWithFloat:record.exlight.doubleValue+deltaExLight];
//                        record.light = [NSNumber numberWithFloat:record.light.doubleValue+deltaLight];
//                        record.deep = [NSNumber numberWithFloat:record.deep.doubleValue+deltaDeep];
//                    }else{
//                        SleepHistory_Hour* record = [NSEntityDescription insertNewObjectForEntityForName:@"SleepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//                        record.deep = [NSNumber numberWithDouble:deltaDeep];
//                        record.exlight = [NSNumber numberWithDouble:deltaExLight];
//                        record.light = [NSNumber numberWithDouble:deltaLight];
//                        record.awake = [NSNumber numberWithDouble:deltaAwake];
//                        record.macid = macid;
//                        record.uid = self.commondata.uid;
//                        record.datetime = hourdate;
//                    }
//                    //天
//                    entity = [NSEntityDescription entityForName:@"SleepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//                    [fetchRequest setEntity:entity];
//                    // Specify criteria for filtering which objects to fetch
//                    predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", daydate,self.commondata.uid, macid];
//                    
//                    [fetchRequest setPredicate:predicate];
//                    // Specify how the fetched objects should be sorted
//                    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                    if (fetchedObjects.count) {
//                        SleepHistory_Day* record = [fetchedObjects objectAtIndex:0];
//                        record.awake = [NSNumber numberWithFloat:record.awake.doubleValue+deltaAwake];
//                        record.exlight = [NSNumber numberWithFloat:record.exlight.doubleValue+deltaExLight];
//                        record.light = [NSNumber numberWithFloat:record.light.doubleValue+deltaLight];
//                        record.deep = [NSNumber numberWithFloat:record.deep.doubleValue+deltaDeep];
//                    }else{
//                        SleepHistory_Day* record = [NSEntityDescription insertNewObjectForEntityForName:@"SleepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//                        record.deep = [NSNumber numberWithDouble:deltaDeep];
//                        record.exlight = [NSNumber numberWithDouble:deltaExLight];
//                        record.light = [NSNumber numberWithDouble:deltaLight];
//                        record.awake = [NSNumber numberWithDouble:deltaAwake];
//                        record.macid = macid;
//                        record.uid = self.commondata.uid;
//                        record.datetime = daydate;
//                    }
//                    //天
//                    entity = [NSEntityDescription entityForName:@"SleepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//                    [fetchRequest setEntity:entity];
//                    // Specify criteria for filtering which objects to fetch
//                    predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", monthdate,self.commondata.uid, macid];
//                    
//                    [fetchRequest setPredicate:predicate];
//                    // Specify how the fetched objects should be sorted
//                    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                    if (fetchedObjects.count) {
//                        SleepHistory_Month* record = [fetchedObjects objectAtIndex:0];
//                        record.awake = [NSNumber numberWithFloat:record.awake.doubleValue+deltaAwake];
//                        record.exlight = [NSNumber numberWithFloat:record.exlight.doubleValue+deltaExLight];
//                        record.light = [NSNumber numberWithFloat:record.light.doubleValue+deltaLight];
//                        record.deep = [NSNumber numberWithFloat:record.deep.doubleValue+deltaDeep];
//                    }else{
//                        SleepHistory_Month* record = [NSEntityDescription insertNewObjectForEntityForName:@"SleepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//                        record.deep = [NSNumber numberWithDouble:deltaDeep];
//                        record.exlight = [NSNumber numberWithDouble:deltaExLight];
//                        record.light = [NSNumber numberWithDouble:deltaLight];
//                        record.awake = [NSNumber numberWithDouble:deltaAwake];
//                        record.macid = macid;
//                        record.uid = self.commondata.uid;
//                        record.datetime = monthdate;
//                    }
//                    
//                    
//                }
//                
                //[self.managedObjectContext save:&error];
                [self saveDB];
                
                NSLog(@"proc data time = %f", [[NSDate date] timeIntervalSinceDate:t1]);
                lastReadDataTime =[self refreshLastReadtime:lastReadDataTime];
                [bonginfo setObject:[NSNumber numberWithDouble:lastReadDataTime] forKey:BONGINFO_KEY_LASTSYNCTIME];
                [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_recv_device_sync_data object:nil];
                [self sendCmd:CMD_C4];
                
                //        [self.commandlist addObject:CMD_C4];
            }else{
                [self sendCmd:CMD_C4];
                //        [self.commandlist addObject:CMD_C4];
            }
            
        }
        
    }
    
}

-(void)saveDB{
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error;
        if (![self.managedObjectContext save:&error])
        {
            // handle error
            NSLog(@"Datacenter::stepContext save error:%@",error);
        }
        
        // save parent to disk asynchronously
        [self.managedObjectContext.parentContext performBlockAndWait:^{
            NSError *error;
            if (![self.managedObjectContext.parentContext save:&error])
            {
                // handle error
                NSLog(@"Datacenter::managedObjectContext save error:%@",error);
            }
        }];
    }];
    
}

//-(void)procC4Rsp:(NSData*)recvdata{
//    NSLog(@"procC4Rsp :: %@ ,current_response_count=%d",recvdata,self.current_response_count);
//    if (self.current_response_count < self.expect_response_count) {
//        [self.cachedata appendData:recvdata];
//        return;
//    }
//    if (self.current_response_count >= self.expect_response_count) {
//        [self.cachedata appendData:recvdata];
//        Byte* bytearray = (Byte*)[self.cachedata bytes];
//        Byte cmdname = bytearray[0];
//        Byte cmdparamlen = bytearray[1];
//        if (cmdname == HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_WEEK_OK) {
//            NSLog(@"buf = %@",recvdata);
//            NSMutableDictionary* bonginfo =[self.commondata getBongInformation:self.commondata.lastBongUUID];
//            double lastReadDataTime = [[bonginfo objectForKey:BONGINFO_KEY_LASTSYNCTIME] doubleValue];
//            NSString* macid = [bonginfo objectForKey:BONGINFO_KEY_BLEADDR];
//            if (macid == nil) {
//                macid = @"";
//            }
//            if(![self CheckData:recvdata]){
//                NSLog(@"RecvData Error!");
//                //            [self.commandlist addObject:CMD_C4];
//                lastReadDataTime =[self refreshLastReadtime:lastReadDataTime];
//                [bonginfo setObject:[NSNumber numberWithDouble:lastReadDataTime] forKey:BONGINFO_KEY_LASTSYNCTIME];
//                [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_recv_device_sync_data object:nil];
//                [self sendCmd:CMD_C4];
//                
//                return;
//            }
//            
//            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//            NSDateComponents *comps = [[NSDateComponents alloc] init];
//            NSInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute;
//            //先校验日期是否正确
//            NSDate* cdate = [NSDate dateWithTimeIntervalSince1970:lastReadDataTime];
//            NSDate* currentdate = [NSDate date];
//            double currentdatetime = [currentdate timeIntervalSince1970];
//            //            NSTimeInterval  timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
//            //            cdate = [cdate dateByAddingTimeInterval:timeZoneOffset];
//            comps = [calendar components:unitFlags fromDate:cdate];
//            NSInteger year = [comps year];
//            NSInteger month = [comps month];
//            NSInteger day = [comps day];
//            NSInteger hour = [comps hour];
//
//#ifdef CUSTOM_CZJK_COMMON
//            //暂时不校验
//            int res_year = year;
//            int res_month = month;
//            int res_day = day;
//            int res_hour = hour;
//            int res_min = -10;
//#else
//            int res_year = bytearray[2]+2000;
//            int res_month = bytearray[3];
//            int res_day = bytearray[4];
//            int res_hour = bytearray[5];
//            NSLog(@"Currentdate = %ld-%ld-%ld %ld",year,month,day,hour);
//            NSLog(@"responesdate = %d-%d-%d %d",res_year,res_month,res_day,res_hour);
//            if (year!= res_year || month != res_month || res_day!= day || res_hour != hour) {
//                NSLog(@"INVALID HISTORY DATA");
//                lastReadDataTime =[self refreshLastReadtime:lastReadDataTime];
//                [bonginfo setObject:[NSNumber numberWithDouble:lastReadDataTime] forKey:BONGINFO_KEY_LASTSYNCTIME];
//                [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
//                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_recv_device_sync_data object:nil];
//                //            [self.commandlist addObject:CMD_C4];
//                [self sendCmd:CMD_C4];
//                
//                return;
//            }
//#endif
//            
//            
//            
//            NSDate* t1 = [NSDate date];
//            NSError * error;
//            int readoffset = 6;
//            int readtimes = 6;
//            int currentreadtimes = 0;
//            int readbytes = 0;
//            NSDateFormatter* format = [[NSDateFormatter alloc] init];
//            [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//            [format setTimeZone:[NSTimeZone systemTimeZone]];
//            format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//            
//            int deltaStep = 0;
//            int deltaDeep = 0;
//            int deltaLight = 0;
//            int deltaAwake = 0;
//            int deltaExLight =0;
////            NSString* datacenter_hourkey = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d",res_year,res_month,res_day, res_hour];
////            NSString* datacenter_daykey = [NSString stringWithFormat:@"%d-%.2d-%.2d",res_year,res_month,res_day];
////            NSString* datacenter_monthkey = [NSString stringWithFormat:@"%d-%.2d",res_year,res_month];
//            NSString* monthdatestr = [NSString stringWithFormat:@"%d-%.2d-01 00:00:00",(int)year, (int)month];
//            NSString* daydatestr = [NSString stringWithFormat:@"%d-%.2d-%.2d 00:00:00",(int)year, (int)month, (int)day];
//            NSString* hourdatestr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:00:00",(int)year,(int)month, (int)day, (int)hour];
//            NSDate* monthdate = [format dateFromString:monthdatestr];
//            NSDate* daydate = [format dateFromString:daydatestr];
//            NSDate* hourdate = [format dateFromString:hourdatestr];
//            
//            NSString* startstr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:00:00",res_year,res_month,res_day, res_hour];
//            NSDate* startdate = [format dateFromString:startstr];
//            NSString* endstr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:59:59",res_year,res_month,res_day, res_hour];
//            NSDate* enddate = [format dateFromString:endstr];
//            
//            //先找当前已存在的记录 用年-月-日 时：分的结构作为KEY存在字典中
//            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
//            [fetchRequest setEntity:entity];
//            // Specify criteria for filtering which objects to fetch
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid IN {%@,%@,%@} and macid in {%@,%@,%@}", startdate, enddate, nil, @"", self.commondata.uid, nil, @"", macid];
//            
//            [fetchRequest setPredicate:predicate];
//            // Specify how the fetched objects should be sorted
//            NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//            NSMutableDictionary* existRecordDict = [[NSMutableDictionary alloc] init];
//            if (fetchedObjects) {
//                [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    StepHistory* record = (StepHistory*)obj;
//                    NSDateFormatter* format = [[NSDateFormatter alloc] init];
//                    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//                    [format setTimeZone:[NSTimeZone systemTimeZone]];
//                    format.dateFormat = @"yyyy-MM-dd HH:mm";
//                    NSString* key = [format stringFromDate:record.datetime];
//                    [existRecordDict setObject:record forKey:key];
//                }];
//            }
//            //读取数据
//            
//            //所有这个小时内的步数差额，用于计算统计表的值
//            while(currentreadtimes < readtimes){
//                NSString* datestr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:%.2d:00",res_year,res_month,res_day, res_hour, currentreadtimes*10];
//                NSLog(@"current datestr = %@",datestr);
//                NSString* checkkey = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:%.2d",res_year,res_month,res_day, res_hour, currentreadtimes*10];
//                
//                NSDate* cdate = [format dateFromString:datestr];
//                if([currentdate timeIntervalSinceDate:cdate]<10*60){
//                    NSLog(@"最近的10分钟，不记录");
//                    break;
//                }
//                
//                //modify:防止date为nil造成app闪退
//                if(cdate == nil)
//                {
//                    readoffset += 6;
//                    readbytes += 6;
//                    currentreadtimes += 1;
//                    continue;
//                }
//                
//                uint8_t tmp[2];
//                tmp[0] = bytearray[readoffset];
//                tmp[1] = bytearray[readoffset+1];
//                unsigned int mode = tmp[0] >> 6;
//                uint8_t t = tmp[0] << 2;
//                tmp[0] = t >> 2;
////                uint16_t steps = CFSwapInt16BigToHost(*(int16_t*)tmp);
//                uint16_t steps = tmp[0]*0x100+tmp[1];
//                if (steps >= 0x3FFF) {
//                    steps = 0;
//                }
//                
//                
//                tmp[0] = bytearray[readoffset+2];
//                tmp[1] = bytearray[readoffset+3];
//                uint16_t cal = CFSwapInt16BigToHost(*(int16_t*)tmp);
//                
//                tmp[0] = bytearray[readoffset+4];
//                tmp[1] = bytearray[readoffset+5];
//                uint16_t dis = CFSwapInt16BigToHost(*(int16_t*)tmp);
//                
//                NSLog(@"steps = %d, cal=%d, dis=%d",steps, cal,dis);
//                
//                if ([existRecordDict.allKeys containsObject:checkkey]) {
//                    StepHistory* record = [existRecordDict objectForKey:checkkey];
//                    if (mode != HJT_STEP_MODE_SLEEP) {
//                        deltaStep += steps - record.steps.unsignedShortValue;
//                    }else{
//                        int newAwake = 0;
//                        int newExlight = 0;
//                        int newLight = 0;
//                        int newDeep = 0;
//                        int oldAwake = 0;
//                        int oldExlight = 0;
//                        int oldLight = 0;
//                        int oldDeep = 0;
////#ifdef CUSTOM_FITRIST
//#if CUSTOM_FITRIST || CUSTOM_PUZZLE || CUSTOM_GOBAND|| CUSTOM_ZZB || CUSTOM_NOMI || CUSTOM_HIMOVE
//                        //FITRIST强行不检测每天早上8点至晚上21点间的睡眠数据，为手环垃圾firmware擦屁股
//                        
//                        res_min += 10;
//                        if(![self isSaveSleepData:res_hour min:res_min])
//                        {
//                            readoffset += 6;
//                            readbytes += 6;
//                            currentreadtimes += 1;
//                            continue;
//                        }
//                        
//                        
//  
//
//#endif
//                        if (record.steps.intValue > HJT_SLEEP_MODE_AWAKE) {
//                            oldAwake += 10*60;
//                        }
//                        else if(record.steps.intValue > HJT_SLEEP_MODE_EXLIGHT){
//                            oldExlight += 10*60;
//                        }
//                        else if(record.steps.intValue > HJT_SLEEP_MODE_LIGHT){
//                            oldLight += 10*60;
//                        }else{
//                            oldDeep += 10*60;
//                        }
//                        
//                        if (steps > HJT_SLEEP_MODE_AWAKE) {
//                            newAwake += 10*60;
//                        }
//                        else if(steps > HJT_SLEEP_MODE_EXLIGHT){
//                            newExlight += 10*60;
//                        }
//                        else if(steps > HJT_SLEEP_MODE_LIGHT){
//                            newLight += 10*60;
//                        }else{
//                            newDeep += 10*60;
//                        }
//                        deltaAwake += newAwake-oldAwake;
//                        deltaExLight += newExlight-oldExlight;
//                        deltaLight += newLight-oldLight;
//                        deltaDeep += newDeep-oldDeep;
//                        
//                    }
//                    
//                    record.steps = [NSNumber numberWithInt:steps];
//                    record.cal = [NSNumber numberWithUnsignedInteger:cal];
//                    record.distance = [NSNumber numberWithUnsignedInteger:dis];
//                    record.mode = [NSNumber numberWithUnsignedInt:mode];
//                    record.macid = macid;
//                    record.uid = self.commondata.uid;
//                    NSLog(@"update exist record = %@",record);
//                }else{
////#ifdef CUSTOM_FITRIST
//#if CUSTOM_FITRIST || CUSTOM_PUZZLE || CUSTOM_GOBAND|| CUSTOM_ZZB || CUSTOM_NOMI || CUSTOM_HIMOVE
//                    //同上
////                    if (mode == HJT_STEP_MODE_SLEEP && res_hour<=21 && res_hour>=8) {
////                        readoffset += 6;
////                        readbytes += 6;
////                        currentreadtimes += 1;
////                        continue;
////                    }
//                    if(mode == HJT_STEP_MODE_SLEEP)
//                    {
//                        res_min += 10;
//                        if(![self isSaveSleepData:res_hour min:res_min])
//                        {
//                            readoffset += 6;
//                            readbytes += 6;
//                            currentreadtimes += 1;
//                            continue;
//                        }
//                        
//                    }
//
//#endif
//                    StepHistory* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
//                    record.cal = [NSNumber numberWithUnsignedInteger:cal];
//                    record.distance = [NSNumber numberWithUnsignedInteger:dis];
//                    record.mode = [NSNumber numberWithUnsignedInt:mode];
//                    record.uid = self.commondata.uid;
//                    record.macid = macid;
//                    if (mode != HJT_STEP_MODE_SLEEP) {
//                        deltaStep += steps;
//                    }else{
//                        if (steps > HJT_SLEEP_MODE_AWAKE) {
//                            deltaAwake += 10*60;
//                        }
//                        else if(steps > HJT_SLEEP_MODE_EXLIGHT){
//                            deltaExLight += 10*60;
//                        }
//                        else if(steps > HJT_SLEEP_MODE_LIGHT){
//                            deltaLight += 10*60;
//                        }else{
//                            deltaDeep += 10*60;
//                        }
//                        
//                    }
//                    record.steps = [NSNumber numberWithUnsignedInt:steps];
//                    record.datetime = cdate;
//                    record.type = [NSNumber numberWithInt:0];
//                    NSLog(@"record = %@",record);
//                }
//                
//                readoffset += 6;
//                readbytes += 6;
//                currentreadtimes += 1;
//            }
//            NSLog(@"deltaStep=%d,detlaAwake=%d,deltaExlight=%d,deltaLight=%d,deltaDeep=%d",deltaStep,deltaAwake,deltaExLight,deltaLight,deltaDeep);
//            
//            if (deltaStep != 0) {
//                //有增量 小时
//                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//                NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//                [fetchRequest setEntity:entity];
//                // Specify criteria for filtering which objects to fetch
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", hourdate,self.commondata.uid, macid];
//                
//                [fetchRequest setPredicate:predicate];
//                // Specify how the fetched objects should be sorted
//                NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                if (fetchedObjects.count) {
//                    StepHistory_Hour* record = [fetchedObjects objectAtIndex:0];
//                    record.steps = [NSNumber numberWithInt:record.steps.intValue+deltaStep];
//                }else{
//                    StepHistory_Hour* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//                    record.steps = [NSNumber numberWithInt:deltaStep];
//                    record.cal = @0;
//                    record.distance = @0;
//                    record.macid = macid;
//                    record.uid = self.commondata.uid;
//                    record.datetime = hourdate;
//                }
//                //天
//                entity = [NSEntityDescription entityForName:@"StepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//                [fetchRequest setEntity:entity];
//                // Specify criteria for filtering which objects to fetch
//                predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", daydate,self.commondata.uid, macid];
//                
//                [fetchRequest setPredicate:predicate];
//                // Specify how the fetched objects should be sorted
//                fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                if (fetchedObjects.count) {
//                    StepHistory_Day* record = [fetchedObjects objectAtIndex:0];
//                    record.steps = [NSNumber numberWithInt:record.steps.intValue+deltaStep];
//                }else{
//                    StepHistory_Day* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//                    record.steps = [NSNumber numberWithInt:deltaStep];
//                    record.cal = @0;
//                    record.distance = @0;
//                    record.macid = macid;
//                    record.uid = self.commondata.uid;
//                    record.datetime = daydate;
//                }
//                //天
//                entity = [NSEntityDescription entityForName:@"StepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//                [fetchRequest setEntity:entity];
//                // Specify criteria for filtering which objects to fetch
//                predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", monthdate,self.commondata.uid, macid];
//                
//                [fetchRequest setPredicate:predicate];
//                // Specify how the fetched objects should be sorted
//                fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                if (fetchedObjects.count) {
//                    StepHistory_Month* record = [fetchedObjects objectAtIndex:0];
//                    record.steps = [NSNumber numberWithInt:record.steps.intValue+deltaStep];
//                }else{
//                    StepHistory_Month* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//                    record.steps = [NSNumber numberWithInt:deltaStep];
//                    record.cal = @0;
//                    record.distance = @0;
//                    record.macid = macid;
//                    record.uid = self.commondata.uid;
//                    record.datetime = monthdate;
//                }
//                
//                
//            }
//            
//            if (deltaAwake != 0 ||
//                deltaExLight != 0 ||
//                deltaLight != 0 ||
//                deltaDeep != 0 ) {
//                //有睡眠增量
//                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//                NSEntityDescription *entity = [NSEntityDescription entityForName:@"SleepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//                [fetchRequest setEntity:entity];
//                // Specify criteria for filtering which objects to fetch
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", hourdate,self.commondata.uid, macid];
//                
//                [fetchRequest setPredicate:predicate];
//                // Specify how the fetched objects should be sorted
//                NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                if (fetchedObjects.count) {
//                    SleepHistory_Hour* record = [fetchedObjects objectAtIndex:0];
//                    record.awake = [NSNumber numberWithFloat:record.awake.doubleValue+deltaAwake];
//                    record.exlight = [NSNumber numberWithFloat:record.exlight.doubleValue+deltaExLight];
//                    record.light = [NSNumber numberWithFloat:record.light.doubleValue+deltaLight];
//                    record.deep = [NSNumber numberWithFloat:record.deep.doubleValue+deltaDeep];
//                }else{
//                    SleepHistory_Hour* record = [NSEntityDescription insertNewObjectForEntityForName:@"SleepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
//                    record.deep = [NSNumber numberWithDouble:deltaDeep];
//                    record.exlight = [NSNumber numberWithDouble:deltaExLight];
//                    record.light = [NSNumber numberWithDouble:deltaLight];
//                    record.awake = [NSNumber numberWithDouble:deltaAwake];
//                    record.macid = macid;
//                    record.uid = self.commondata.uid;
//                    record.datetime = hourdate;
//                }
//                //天
//                entity = [NSEntityDescription entityForName:@"SleepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//                [fetchRequest setEntity:entity];
//                // Specify criteria for filtering which objects to fetch
//                predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", daydate,self.commondata.uid, macid];
//                
//                [fetchRequest setPredicate:predicate];
//                // Specify how the fetched objects should be sorted
//                fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                if (fetchedObjects.count) {
//                    SleepHistory_Day* record = [fetchedObjects objectAtIndex:0];
//                    record.awake = [NSNumber numberWithFloat:record.awake.doubleValue+deltaAwake];
//                    record.exlight = [NSNumber numberWithFloat:record.exlight.doubleValue+deltaExLight];
//                    record.light = [NSNumber numberWithFloat:record.light.doubleValue+deltaLight];
//                    record.deep = [NSNumber numberWithFloat:record.deep.doubleValue+deltaDeep];
//                }else{
//                    SleepHistory_Day* record = [NSEntityDescription insertNewObjectForEntityForName:@"SleepHistory_Day" inManagedObjectContext:self.managedObjectContext];
//                    record.deep = [NSNumber numberWithDouble:deltaDeep];
//                    record.exlight = [NSNumber numberWithDouble:deltaExLight];
//                    record.light = [NSNumber numberWithDouble:deltaLight];
//                    record.awake = [NSNumber numberWithDouble:deltaAwake];
//                    record.macid = macid;
//                    record.uid = self.commondata.uid;
//                    record.datetime = daydate;
//                }
//                //天
//                entity = [NSEntityDescription entityForName:@"SleepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//                [fetchRequest setEntity:entity];
//                // Specify criteria for filtering which objects to fetch
//                predicate = [NSPredicate predicateWithFormat:@"datetime = %@ and uid = %@ and macid = %@", monthdate,self.commondata.uid, macid];
//                
//                [fetchRequest setPredicate:predicate];
//                // Specify how the fetched objects should be sorted
//                fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//                if (fetchedObjects.count) {
//                    SleepHistory_Month* record = [fetchedObjects objectAtIndex:0];
//                    record.awake = [NSNumber numberWithFloat:record.awake.doubleValue+deltaAwake];
//                    record.exlight = [NSNumber numberWithFloat:record.exlight.doubleValue+deltaExLight];
//                    record.light = [NSNumber numberWithFloat:record.light.doubleValue+deltaLight];
//                    record.deep = [NSNumber numberWithFloat:record.deep.doubleValue+deltaDeep];
//                }else{
//                    SleepHistory_Month* record = [NSEntityDescription insertNewObjectForEntityForName:@"SleepHistory_Month" inManagedObjectContext:self.managedObjectContext];
//                    record.deep = [NSNumber numberWithDouble:deltaDeep];
//                    record.exlight = [NSNumber numberWithDouble:deltaExLight];
//                    record.light = [NSNumber numberWithDouble:deltaLight];
//                    record.awake = [NSNumber numberWithDouble:deltaAwake];
//                    record.macid = macid;
//                    record.uid = self.commondata.uid;
//                    record.datetime = monthdate;
//                }
//                
//                
//            }
//            
//            [self.managedObjectContext save:&error];
//            
//            NSLog(@"proc data time = %f", [[NSDate date] timeIntervalSinceDate:t1]);
//            lastReadDataTime =[self refreshLastReadtime:lastReadDataTime];
//            [bonginfo setObject:[NSNumber numberWithDouble:lastReadDataTime] forKey:BONGINFO_KEY_LASTSYNCTIME];
//            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_recv_device_sync_data object:nil];
//            [self sendCmd:CMD_C4];
//            
//            //        [self.commandlist addObject:CMD_C4];
//        }else{
//            [self sendCmd:CMD_C4];
//            //        [self.commandlist addObject:CMD_C4];
//        }
//
//    }
//
//}

-(void)procSyncSportData:(NSData*)recvdata{
    NSLog(@"procSyncSportData :: %@ ,current_response_count=%d",recvdata,self.current_response_count);
    if (self.current_response_count < self.expect_response_count) {
        [self.cachedata appendData:recvdata];
        return;
    }
    if (self.current_response_count >= self.expect_response_count) {
        [self.cachedata appendData:recvdata];
        Byte* bytearray = (Byte*)[self.cachedata bytes];
        Byte cmdname = bytearray[0];
        Byte cmdparamlen = bytearray[1];
        if (cmdname == HJT_CMD_DEVICE2PHONE_SYNC_SPORT_DATA_OK) {
            NSLog(@"buf = %@",recvdata);
            NSMutableDictionary* bonginfo =[self.commondata getBongInformation:self.commondata.lastBongUUID];
//            double lastReadDataTime = [[bonginfo objectForKey:BONGINFO_KEY_LASTSYNCTIME] doubleValue];
            NSString* macid = [bonginfo objectForKey:BONGINFO_KEY_BLEADDR];
            if (macid == nil) {
                macid = @"";
            }
            if(![self CheckData:recvdata]){
                NSLog(@"RecvData Error!");
                return;
            }
            int idx = 2;
            int offset = 0;
            while (offset<cmdparamlen) {
                int dbmode = SPORT_TYPE_BAND_BICYCLE;
                Byte mode = bytearray[idx];
                Byte year = bytearray[idx+1];
                Byte month = bytearray[idx+2];
                Byte day = bytearray[idx+3];
                uint8_t tmp[3];
                tmp[0] = bytearray[idx+4];
                tmp[1] = bytearray[idx+5];
                int duration = tmp[0]*0x100+tmp[1];
                
                tmp[0] = bytearray[idx+6];
                tmp[1] = bytearray[idx+7];
                tmp[2] = bytearray[idx+8];
                int steps = tmp[0]*0x10000+tmp[1]*0x100+tmp[2];
                
                tmp[0] = bytearray[idx+9];
                tmp[1] = bytearray[idx+10];
                int cal = tmp[0]*0x100+tmp[1];
                
                tmp[0] = bytearray[idx+11];
                tmp[1] = bytearray[idx+12];
                tmp[2] = bytearray[idx+13];
                int distance = tmp[0]*0x10000+tmp[1]*0x100+tmp[2];
                
                idx += 14;
                offset += 14;
                if (mode == 3) {
                    dbmode = SPORT_TYPE_BAND_BICYCLE;
                }
                NSLog(@"year=%d,month=%d,day=%d,mode=%d,duration=%d,step=%d,cal=%d,dis=%d",year,month,day,mode,duration,steps,cal,distance);
                NSString* strdate = [NSString stringWithFormat:@"20%.2d-%.2d-%.2d 00:00:00",year,month,day];
                NSDateFormatter* format = [[NSDateFormatter alloc] init];
                [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                [format setTimeZone:[NSTimeZone systemTimeZone]];
                
                format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSDate *addDate = [format dateFromString:strdate];
                if (addDate == nil) {
                    continue;
                }
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunRecord" inManagedObjectContext:self.managedObjectContext];
                [fetchRequest setEntity:entity];
                // Specify criteria for filtering which objects to fetch
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adddate = %@ and uid = %@ and macid = %@ and type = %@", addDate, self.commondata.uid, macid,[NSNumber numberWithInt:dbmode]];
                
                [fetchRequest setPredicate:predicate];
                // Specify how the fetched objects should be sorted
                NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
                if ([fetchedObjects count]) {
                    NSLog(@"RunRecord already exist");
                    RunRecord* record = [fetchedObjects objectAtIndex:0];
                    record.totaltime = [NSNumber numberWithDouble:duration*60];
                    record.totalstep = [NSNumber numberWithInt:steps];
                    record.totalcalories = [NSNumber numberWithInt:cal];
                    record.totaldistance = [NSNumber numberWithInt:distance];
                }else{
                    RunRecord* record = [NSEntityDescription insertNewObjectForEntityForName:@"RunRecord" inManagedObjectContext:self.managedObjectContext];
                    NSString* current_runid = [NSString stringWithFormat:@"%@%@",self.commondata.uid,strdate];
                    record.uid = self.commondata.uid;
                    record.macid = macid;
                    record.closed = @1;
                    record.adddate = addDate;
                    record.pace = @0;
                    record.type = [NSNumber numberWithInt:dbmode];
                    record.totaltime = [NSNumber numberWithDouble:duration*60];
                    record.totalstep = [NSNumber numberWithInt:steps];
                    record.totalcalories = [NSNumber numberWithInt:cal];
                    record.totaldistance = [NSNumber numberWithInt:distance];
                    record.starttime = addDate;
                    record.starttimestamp = [NSNumber numberWithDouble:[addDate timeIntervalSince1970]];
                    record.closed = [NSNumber numberWithInt:0];
                    record.pace = [NSNumber numberWithFloat:0];
                    record.issync = [NSNumber numberWithBool:NO];
                    record.running_id = current_runid;
                    record.memberid = self.commondata.memberid;
                    //////////for healthkit/////////////
                    record.issynchealthkit = [NSNumber numberWithBool:NO];


                }
                [self.managedObjectContext save:nil];
            }
             [[TaskManager SharedInstance] AddUpLoadTaskBySyncKey:SYNCKEY_RUNRECORD];
        }
    }
}


-(void)procC6Rsp:(NSData*)recvdata{
    NSLog(@"procC6Rsp :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    Byte cmdname = bytearray[0];
    Byte cmdparamlen = bytearray[1];
    if (cmdname == HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_OK) {
        if(cmdparamlen == 9){
            Byte buf[4];
            buf[0] = 0;
            buf[1] = bytearray[2];
            buf[2] = bytearray[3];
            buf[3] = bytearray[4];
            
            int steps = CFSwapInt32BigToHost(*(int*)buf);
            buf[0] = 0;
            buf[1] = bytearray[5];
            buf[2] = bytearray[6];
            buf[3] = bytearray[7];
            int cal = CFSwapInt32BigToHost(*(int*)buf);
            buf[0] = 0;
            buf[1] = bytearray[8];
            buf[2] = bytearray[9];
            buf[3] = bytearray[10];
            int distance = CFSwapInt32BigToHost(*(int*)buf);
            
            NSDictionary *userinfo = @{@"steps":[NSNumber numberWithInt:steps],@"cal":[NSNumber numberWithInt:cal],@"distance":[NSNumber numberWithInt:distance]};
//            self.commondata.current_steps = steps;
//            self.commondata.current_cal = cal;
//            self.commondata.current_distance = distance;
//            [self.commondata saveconfig];
//            
//            self.commondata.last_c6date = [NSDate date];
//            self.commondata.last_c6steps = steps;
//            
//            [self.commondata saveC6];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_current_steps object:nil userInfo:userinfo];
            NSLog(@"steps = %d, cal = %d, distance = %d",steps, cal, distance);
        }
        
    }else{
        
    }
//#ifdef CUSTOM_FITRIST
#if CUSTOM_FITRIST || CUSTOM_PUZZLE || CUSTOM_NOMI || CUSTOM_HIMOVE
    NSMutableDictionary* bonginfo = (NSMutableDictionary*)[self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bonginfo == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_start_sync_history object:nil];
    }else{
        NSNumber* nlasttime = [bonginfo objectForKey:BONGINFO_KEY_LASTSYNCTIME];
        if (nlasttime == nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_start_sync_history object:nil];
        }else{
            //#ifdef CUSTOM_JJT_COMMON
            NSDate* lastdate = [NSDate dateWithTimeIntervalSince1970:nlasttime.doubleValue];
            if (![self.commondata isDateInToday:lastdate]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_start_sync_history object:nil];
            }
        }
    }
#endif

}

-(void)procFARsp:(NSData*)recvdata{
    NSLog(@"procFARsp :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];

    uint8_t tmp[8] = {'\0'};
    uint8_t len = bytearray[1];
    int begin = 8-len;
    if (len) {
        tmp[begin+0] = bytearray[2];
        tmp[begin+1] = bytearray[3];
        tmp[begin+2] = bytearray[4];
        tmp[begin+3] = bytearray[5];
        tmp[begin+4] = bytearray[6];
        tmp[begin+5] = bytearray[7];
    }
    uint64_t macid = CFSwapInt64BigToHost(*(uint64_t*)tmp);
    NSString* macidstr = [[NSString stringWithFormat:@"%qx",macid] uppercaseString];
    NSLog(@"macid = %lld macidstr = %@",macid,macidstr);
    self.commondata.current_macid = [macidstr copy];
    NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bi == nil) {
        bi = [[NSMutableDictionary alloc] init];
    }
    [bi setObject:macidstr forKey:BONGINFO_KEY_BLEADDR];
    [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bi];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_mac_id object:nil];
    self.getmactimeout = 0;
}

-(void)procFBRsp:(NSData*)recvdata{
    NSLog(@"procFBRsp :: %@",recvdata);
    self.getfwtimeout = 0;
    Byte* bytearray = (Byte*)[recvdata bytes];
    
    char tmp[20] = {'\0'};
    uint8_t len = bytearray[1];
    for (int i =0; i<len; i++) {
        tmp[i] = bytearray[2+i];
    }
    NSString* firmware = [NSString stringWithCString:tmp encoding:NSASCIIStringEncoding];
    NSString* projectcode = @"";
    NSString* productcode = @"";
    NSString* versioncode = @"";
    if (firmware != nil && firmware.length>=12) {
        projectcode = [firmware substringWithRange:NSMakeRange(0, 4)];
        productcode = [firmware substringWithRange:NSMakeRange(4, 4)];
        versioncode = [firmware substringWithRange:NSMakeRange(9, 3)];

        NSLog(@"firmware = %@, projectcode = %@, productcode= %@, versioncode=%@",firmware, projectcode, productcode,versioncode);
        
    }else{
        
        projectcode = PROJECTCODE_WDB;
        //        versioncode = @"000";
        productcode = PRODUCTCODE_W4S;
        
        //        projectcode = [firmware substringWithRange:NSMakeRange(0, 4)];
        //        productcode = [firmware substringWithRange:NSMakeRange(4, 4)];
        versioncode = @"000";
    }
    
    NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bi == nil) {
        bi = [[NSMutableDictionary alloc] init];
    }
    [bi setObject:firmware forKey:BONGINFO_KEY_FIRMWARE];
    [bi setObject:projectcode forKey:BONGINFO_KEY_PROJECTCODE];
//    [bi setObject:PRODUCTCODE_CZJKMT_N forKey:BONGINFO_KEY_PRODUCTCODE];
    [bi setObject:productcode forKey:BONGINFO_KEY_PRODUCTCODE];
    [bi setObject:versioncode forKey:BONGINFO_KEY_VERSIONCODE];

    
    [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bi];
    //增加配对
    //MGCOOL 不处理配对消息，无需发送
    [self sendCmd:CMD_PAIR];
//    if ([productcode isEqualToString:PRODUCTCODE_CZJKMCHN]) {
//        //强制OTA
//        [self getLatestFirwareVersionFromServer];
//    }
}

-(void)getLatestFirwareVersionFromServer{
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSString* productcode = [self.commondata getValueFromBonginfoByKey:BONGINFO_KEY_PRODUCTCODE];
//    NSString* version = [self.commondata getValueFromBonginfoByKey:BONGINFO_KEY_VERSIONCODE];
    NSString* urlstr = [NSString stringWithFormat:@"http://download.keeprapid.com/apps/smartband/mgcool/fwupdater/en/%@/update.json",productcode];
    NSLog(@"urlstr=%@",urlstr);
    NSURL  *url = [NSURL URLWithString:urlstr];
    NSLog(@"url = %@",url);
    
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if ( urlData ){
        NSError* error = nil;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&error];
        if (error) {return;}
        NSLog(@"%@",responseDict);
        NSDictionary* updatInfo = [responseDict objectForKey:FIRMINFO_DICT_UPDATEINFO];
        if (updatInfo) {
//            NSString* fwDesc = [updatInfo objectForKey:FIRMINFO_DICT_FWDESC];
//            NSString* fwName = [updatInfo objectForKey:FIRMINFO_DICT_FWNAME];
//            NSString* fwUrl = [updatInfo objectForKey:FIRMINFO_DICT_FWURL];
//            NSString* filename = [[NSURL URLWithString:fwUrl] lastPathComponent];
            NSString* versionCode = [updatInfo objectForKey:FIRMINFO_DICT_VERSIONCODE];
            NSString* versionName = [updatInfo objectForKey:FIRMINFO_DICT_VERSIONNAME];
            NSString* currentfw;
            
            NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
            if (bonginfo) {
                NSString* fwinfo = [bonginfo objectForKey:BONGINFO_KEY_FIRMWARE];
                currentfw = fwinfo;
            }else{
                currentfw = @"";
            }
            
            NSString* currentCode = [self getVersionCode:currentfw];
            NSString* returnCode = [self getVersionCode:versionCode];
            NSComparisonResult result = [currentCode caseInsensitiveCompare:returnCode];
            
            if (result == NSOrderedAscending) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString* notifystr = [NSString stringWithFormat:@"%@\n\n%@%@(%@)",NSLocalizedString(@"OTA_FirmwareServer_Found_Latest", nil),
                                           NSLocalizedString(@"OTA_FirmwareServer_Newfirm", nil),
                                           versionCode,
                                           versionName];
                    
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:notifystr delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OTA_Confirm", nil),nil];
                    alert.tag = 100;
                    [alert show];
                    
                });
                return;
            }else{return;}
        }else{return;}
    }else{return;}
    //});
}

-(NSString*)getVersionCode:(NSString*)firmware{
    
    return [firmware substringWithRange:NSMakeRange([firmware length]-3, 3)];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CZJKOTAViewController *otaview = [[CZJKOTAViewController alloc] init];
                otaview.isJump=YES;
                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:otaview];
                AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [delegate.window.rootViewController presentViewController:navi animated:YES completion:nil];
            });
        }
    }
}


-(void)procReadTimeRsp:(NSData*)recvdata{
    NSLog(@"procReadTimeRsp :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    Byte cmdname = bytearray[0];
//    Byte cmdparamlen = bytearray[1];
    if (cmdname == HJT_CMD_DEVICE2PHONE_READ_DEVICE_TIME_OK) {
        uint8_t year = bytearray[2];
        uint8_t month = bytearray[3];
        uint8_t day = bytearray[4];
        uint8_t hour = bytearray[5];
        uint8_t minute = bytearray[6];
        uint8_t second = bytearray[7];
//        uint8_t week = bytearray[8];
        
        if(day == 0 && month == 0){
            day = 1;
            month = 1;
        }
        
        NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
        NSRange containsA = [formatStringForHours rangeOfString:@"a"];
        BOOL hasAMPM = containsA.location != NSNotFound;
        
        NSDateFormatter * format = [[NSDateFormatter alloc] init];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [format setTimeZone:[NSTimeZone systemTimeZone]];
        
        if(hasAMPM){
            //                [format setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            //                [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            //                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        }
        format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate* currentdate = [NSDate date];
        NSString* timestr = [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:%.2d:%.2d",year+2000,month,day,hour,minute,second];
        NSLog(@"timestr = %@",timestr);
        //            [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
        NSDate* devicedate = [format dateFromString:timestr];
        
        NSLog(@"devicedate = %@",devicedate);
        NSLog(@"currentdate = %@",currentdate);
        
        
        NSTimeInterval offset = abs((int)[currentdate timeIntervalSinceDate:devicedate]);
        NSLog(@"offset = %f",offset);
        if (offset >= TIME_NEED_TO_RESET_DEVICE) {
            [self.commandlist insertObject:CMD_CLEAR atIndex:0];
            [self.commandlist insertObject:CMD_SETTIME atIndex:0];
            
        }
        else if(offset >= TIME_NEED_TO_SYNC_DEVICE_TIME){
            [self.commandlist insertObject:CMD_SETTIME atIndex:0];
        }else{
//            if ([self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_E02PLUS] ||
//                [self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_E06PLUS] ||
//                [self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_ZTE] ||
//                [self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_E07] ||
//                [self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_TB01]) {
//                
//            }else{

                if (self.current_state == STATE_CONNECT_INIT) {
                    self.current_state = STATE_CONNECT_IDLE;
                    [self kickoff];
                }
//            }
//                self.current_state = CURRENT_STATE_READY;
//                [self kickoff];
        }

    }else{
        
    }

}

-(void)procSetTimeRsp:(NSData*)recvdata{
    NSLog(@"procSetTimeRsp :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    Byte cmdname = bytearray[0];
    if (cmdname == HJT_CMD_DEVICE2PHONE_SET_DEVICE_TIME_OK) {
//        if ([self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_E02PLUS] ||
//            [self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_E06PLUS] ||
//            [self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_ZTE] ||
//            [self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_E07] ||
//            [self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_TB01]) {
//            
//        }else{
            if (self.current_state == STATE_CONNECT_INIT) {
                self.current_state = STATE_CONNECT_IDLE;
                [self kickoff];
            }

//        }
    }else{
        
    }

}

-(void)procPersonInfoRsp:(NSData*)recvdata{
    NSLog(@"procPersonInfoRsp :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    Byte cmdname = bytearray[0];
//    Byte cmdparamlen = bytearray[1];
    if (cmdname == HJT_CMD_DEVICE2PHONE_SET_PERSONINFO_OK) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd_err object:nil];
    }

}

- (void)procLongSitRsp:(NSData *)recvdata
{
    NSLog(@"procLongsitRsp :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    Byte cmdname = bytearray[0];
    //    Byte cmdparamlen = bytearray[1];
    if (cmdname == HJT_CMD_DEVICE2PHONE_LONGSIT_OK) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd_err object:nil];
    }
}
-(void)procSensorDataRsp:(NSData*)recvdata{
    NSLog(@"procSensorDataRsp :: %@ ,current_response_count=%d",recvdata,self.current_response_count);
    if (self.current_response_count < self.expect_response_count) {
        [self.cachedata appendData:recvdata];
        return;
    }
    if (self.current_response_count >= self.expect_response_count) {
        [self.cachedata appendData:recvdata];
        NSLog(@"RECV:%@",self.cachedata);
        Byte* bytearray = (Byte*)[self.cachedata bytes];
        Byte cmdname = bytearray[0];
        int cmdparamlen = bytearray[1]*0x100+bytearray[2];
        
        NSUInteger lasttime = 0;
        NSString* macid = @"";
        NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
        if (bi != nil) {
            NSNumber* lastsensortime = [bi objectForKey:BONGINFO_KEY_LASTSENSORDATATIME];
            if (lastsensortime) {
                lasttime = lastsensortime.unsignedIntegerValue;
            }
            macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
            if (macid == nil) {
                macid = @"";
            }

        }

        if (cmdname == HJT_CMD_DEVICE2PHONE_SENSORDATA_OK) {
            int idx = 3;
            int offset = 0;
            while (offset<cmdparamlen) {
                int type = bytearray[idx];
                
                unsigned char t1 = bytearray[idx+1];
                unsigned char t2 = bytearray[idx+2];
                unsigned char t3 = bytearray[idx+3];
                unsigned char t4 = bytearray[idx+4];
                NSTimeInterval timestamp = t1*0x1000000+t2*0x10000+t3*0x100+t4;
                NSTimeInterval tmptimestamp = timestamp-[[NSTimeZone systemTimeZone] secondsFromGMT];
                NSDate * dates = [NSDate dateWithTimeIntervalSince1970:tmptimestamp];
                if(tmptimestamp>lasttime){
                    lasttime = tmptimestamp;
                }
                
                int value=0;
                int value2=0;
                float temperature = 0;
                int servertype = 0;
                if (type==1) {//心率
                    value=bytearray[idx+5];
                    servertype = SENSOR_TYPE_SERVER_HEARTRATE;
                    idx += 6;
                    offset += 6;
                }else if(type==2){//血压
                    servertype = SENSOR_TYPE_SERVER_BLOODPRESS;
                    value=bytearray[idx+5];//高压
                    value2=bytearray[idx+6];//低压
                    idx += 7;
                    offset += 7;
                }else if(type==3){//血氧
                    //暂时没有
                    idx += 5;
                    offset += 5;

                }else{
                    servertype = SENSOR_TYPE_SERVER_TEMPERATURE;
                    temperature=(bytearray[idx+5]*0x100 + bytearray[idx+6])/10.0;
                    idx += 7;
                    offset += 7;
                }
                
                
                NSLog(@"type=%d,dates=%@,value=%d,value2=%d,temperature = %f",type,dates,value,value2,temperature);
                
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Health_data_history" inManagedObjectContext:self.managedObjectContext];
                [fetchRequest setEntity:entity];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adddate = %@ and memberid = %@ and macid = %@ and type = %@", dates, self.commondata.memberid, macid,[NSNumber numberWithInt:servertype]];
                [fetchRequest setPredicate:predicate];
                NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
                if ([fetchedObjects count]) {
                    NSLog(@"Health_data_history already exist");
                }else{
                    Health_data_history* record = [NSEntityDescription insertNewObjectForEntityForName:@"Health_data_history" inManagedObjectContext:self.managedObjectContext];
                    record.adddate = dates;
                    record.issync = [NSNumber numberWithBool:NO];
                    //////////for healthkit/////////////
                    record.issynchealthkit = [NSNumber numberWithBool:NO];
                    record.macid = macid;
                    record.memberid = self.commondata.memberid;
                    record.type = [NSNumber numberWithInt:servertype];
                    record.uid = self.commondata.uid;
                    if (servertype == SENSOR_TYPE_SERVER_TEMPERATURE) {
                        record.value = [NSNumber numberWithFloat:temperature];
                    }else{
                        record.value = [NSNumber numberWithInt:value];
                    }
                    record.value2 = [NSNumber numberWithFloat:(float)value2];
                }
                [self saveDB];
            }
            [bi setObject:[NSNumber numberWithDouble:lasttime] forKey:BONGINFO_KEY_LASTSENSORDATATIME];
            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bi];
            
            [[TaskManager SharedInstance] AddUpLoadTaskBySyncKey:SYNCKEY_BODYFUNCTION];
            //////////for healthkit/////////////
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_syncdata_to_healthkit object:nil userInfo:@{@"tablename":@"Health_data_history"}];

        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd_err object:nil];
        }

    }
  
}

- (void)procHydrationRsp:(NSData *)recvdata{
    NSLog(@"procPersonInfoRsp :: %@",recvdata);
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd object:nil];
}

-(void)procSetSleepRsp:(NSData*)recvdata{
    NSLog(@"procSetSleepRsp :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    Byte cmdname = bytearray[0];
//    Byte cmdparamlen = bytearray[1];
    if (cmdname == HJT_CMD_DEVICE2PHONE_SET_SLEEP_TIME_OK) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd_err object:nil];
    }

}

-(void)procSetParamRsp:(NSData*)recvdata{
    NSLog(@"procSetParamRsp :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    Byte cmdname = bytearray[0];
//    Byte cmdparamlen = bytearray[1];
    if (cmdname == HJT_CMD_DEVICE2PHONE_SET_BANDPRAM_OK) {
        if (self.current_state == STATE_CONNECT_INIT) {
            self.current_state = STATE_CONNECT_IDLE;
            [self kickoff];
        }
    }else{
        
    }

}

-(void)procSetScreenRsp:(NSData*)recvdata{
    NSLog(@"procSetScreenRsp :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    Byte cmdname = bytearray[0];
//    Byte cmdparamlen = bytearray[1];
//    if (cmdname == HJT_CMD_DEVICE2PHONE_SET_BANDPRAM_OK) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd object:nil userInfo:nil];
//    }else{
//        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_send_cmd_err object:nil userInfo:nil];
//    }

}



-(void)procMonitorRsp:(NSData*)recvdata{
    NSLog(@"procMonitorRsp :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    Byte cmdname = bytearray[0];
//    Byte cmdparamlen = bytearray[1];
    if (cmdname == HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_MONITOR_OK) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_monitor_change object:nil userInfo:@{@"state":[NSNumber numberWithBool:YES]}];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_monitor_change object:nil userInfo:@{@"state":[NSNumber numberWithBool:NO]}];
        UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"activity_monitor_error_title", nil) message:NSLocalizedString(@"activity_monitor_error", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alerview show];
    }

}

-(void)procMonitorDataRsp:(NSData*)recvdata{
    NSLog(@"procMonitorDataRsp :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
//    Byte cmdname = bytearray[0];
//    Byte cmdparamlen = bytearray[1];
    uint8_t tmp[4] = {'\0'};
    uint8_t len = bytearray[1];
    NSInteger activity_type = bytearray[2];
    
    if (len) {
        tmp[3] = bytearray[7];
        tmp[2] = bytearray[8];
        tmp[1] = bytearray[9];
        tmp[0] = bytearray[10];
    }
    NSUInteger activity_value = (*(NSUInteger*)tmp);
    unsigned int tempvalue = (int)activity_value;
    
    NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:activity_type],@"activity_type",[NSNumber numberWithUnsignedInteger:tempvalue],@"activity_value", nil];
    NSLog(@"activity_type = %ld activity_value = %lu tempvalue = %d",(long)activity_type,(unsigned long)activity_value,tempvalue);
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_activity_report object:nil userInfo:userinfo];
    

}

-(void)procWeatherRsp:(NSData*)recvdata{
    NSLog(@"procWeatherRsp :: %@",recvdata);
}

-(void)procCameraRequest:(NSData*)recvdata{
    NSLog(@"procCameraRequest :: %@",recvdata);
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_take_photo object:nil userInfo:nil];

}



-(void)procAlarmRequest:(NSData*)recvdata{
    NSLog(@"procAlarmRequest :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
//    Byte cmdname = bytearray[0];
    Byte cmdparamlen = bytearray[1];
    if (cmdparamlen == 0) {
        return;
    }
    if (self.commondata.is_enable_devicecall) {
        

        Byte cmd = bytearray[2];
        if(cmd == HJT_ANTILOST_CMD_CALL_PHONE) {

            UILocalNotification *notification=[[UILocalNotification alloc] init];
            if (notification!=nil) {
//                NSDate *now=[NSDate new];
                notification.fireDate=[NSDate date];//10秒后通知
                notification.repeatInterval=0;//循环次数，kCFCalendarUnitWeekday一周一次
                notification.timeZone=[NSTimeZone defaultTimeZone];
                notification.applicationIconBadgeNumber=0; //应用的红色数字
                notification.soundName= @"alarm.caf";
                //去掉下面2行就不会弹出提示框
//                notification.alertBody=@"";//提示信息 弹出提示框
//                notification.alertAction = NSLocalizedString(@"Notify", nil);  //提示框按钮
//                notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
//                
//                 NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
//                notification.userInfo = infoDict; //添加额外的信息
                
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }

        }else if (cmd == HJT_ANTILOST_CMD_CALL_PHONE_END){
            [self stop_call_phone];
        }
    }

}


-(void)procMusicRequest:(NSData*)recvdata{
    NSLog(@"procMusicRequest :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
//    Byte cmdname = bytearray[0];
//    Byte cmdparamlen = bytearray[1];
    if (self.commondata.is_enable_bongcontrolmusic) {
        Byte cmd = bytearray[2];
//#ifdef CUSTOM_FITRIST
//#if CUSTOM_FITGO
//        if (cmd == HJT_MUSIC_CMD_PLAY) {
//            [self music_play];
//        }else if (cmd == HJT_MUSIC_CMD_NEXT){
//            [self music_next];
//        }else if(cmd == HJT_MUSIC_CMD_BACK){
//            [self music_back];
//        }
//#elif CUSTOM_FITRIST || CUSTOM_PUZZLE || CUSTOM_NOMI || CUSTOM_HIMOVE
        //FITRIST手环界面上的上一首下一首是反的
        if (cmd == HJT_MUSIC_CMD_PLAY) {
            [self music_play];
        }else if (cmd == HJT_MUSIC_CMD_NEXT){
            [self music_back];
        }else if(cmd == HJT_MUSIC_CMD_BACK){
            [self music_next];
        }
//#else
//        if (cmd == HJT_MUSIC_CMD_PLAY) {
//            [self music_play];
//        }else if (cmd == HJT_MUSIC_CMD_NEXT){
//            [self music_next];
//        }else if(cmd == HJT_MUSIC_CMD_BACK){
//            [self music_back];
//        }
//#endif
        
    }

}



-(void)procResetRsp:(NSData*)recvdata{
    NSLog(@"procResetRsp :: %@",recvdata);

}

-(void)procPair:(NSData*)recvdata{
    NSLog(@"procPair :: %@",recvdata);
    
}

-(void)procSensorChange:(NSData*)recvdata{
    NSLog(@"procSensorChange :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    
    NSInteger activity_type = bytearray[2];
    
    //心率类型
    if(activity_type != 0x80)
    {
        return;
    }
    
    uint8_t tmp[2] = {'\0'};

    tmp[0] = bytearray[6];
    tmp[1] = bytearray[7];
    

    NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:tmp[0]],SENSOR_REPORT_ONOFF, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_change_sensor_status object:nil userInfo:userinfo];
    
    
//    NSDictionary* userinfo1 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:activity_type],SENSOR_REPORT_INFO_KEY_TYPE,[NSNumber numberWithUnsignedInteger:arc4random()%100],SENSOR_REPORT_INFO_KEY_VALUE, [NSNumber numberWithUnsignedInteger:0],SENSOR_REPORT_INFO_KEY_VALUE2,nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_sensor_report object:nil userInfo:userinfo1];

}

-(void)procSensorDataReport:(NSData*)recvdata{
    NSLog(@"procSensorDataReport :: %@",recvdata);
    Byte* bytearray = (Byte*)[recvdata bytes];
    //    Byte cmdname = bytearray[0];
    //    Byte cmdparamlen = bytearray[1];
    uint8_t tmp[4] = {'\0'};
    uint8_t len = bytearray[1];
    NSInteger activity_type = bytearray[2];
    
    if (len) {
        tmp[3] = bytearray[6];
        tmp[2] = bytearray[8];
        tmp[1] = bytearray[9];
        tmp[0] = bytearray[10];
    }
    if(activity_type == SENSOR_HEARTRATE){
        unsigned int tempvalue = 0;
        unsigned int tempvalue2 = 0;
        NSUInteger activity_value = bytearray[6]*10+bytearray[7];
        tempvalue = (int)activity_value;
        NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:activity_type],SENSOR_REPORT_INFO_KEY_TYPE,[NSNumber numberWithUnsignedInteger:tempvalue],SENSOR_REPORT_INFO_KEY_VALUE, [NSNumber numberWithUnsignedInteger:tempvalue2],SENSOR_REPORT_INFO_KEY_VALUE2,nil];
        NSLog(@"sensor_type = %ld value1 = %d",(long)activity_type,tempvalue);
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_sensor_report object:nil userInfo:userinfo];

    }else if (activity_type == SENSOR_TEMPERATURE){
        CGFloat tempvalue = 0;
        CGFloat tempvalue2 = 0;
       
        int temptype = bytearray[6];
        int degree = bytearray[7];
        int v = bytearray[8]*0x100+bytearray[9];
        if (degree == 1) {
            tempvalue = v/(10.0);
        }else if (degree == 2){
            tempvalue = v/(100.0);
        }
        
        if (temptype == 2) {
            tempvalue = 0 - tempvalue;
        }
//        NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:activity_type],SENSOR_REPORT_INFO_KEY_TYPE,[NSNumber numberWithFloat:(arc4random()%400)/10.0],SENSOR_REPORT_INFO_KEY_VALUE, [NSNumber numberWithFloat:tempvalue2],SENSOR_REPORT_INFO_KEY_VALUE2,nil];
//        NSLog(@"sensor_type = %ld , value1 = %f",(long)activity_type,tempvalue);
//        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_sensor_report object:nil userInfo:userinfo];
//
        if (temptype != 0) {
            //有效值才发送
            NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:activity_type],SENSOR_REPORT_INFO_KEY_TYPE,[NSNumber numberWithFloat:tempvalue],SENSOR_REPORT_INFO_KEY_VALUE, [NSNumber numberWithFloat:tempvalue2],SENSOR_REPORT_INFO_KEY_VALUE2,nil];
            NSLog(@"sensor_type = %ld , value1 = %f",(long)activity_type,tempvalue);
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_sensor_report object:nil userInfo:userinfo];

        }

    }else if (activity_type == SENSOR_BLOODPRESS){
        int high = bytearray[6];
        int low = bytearray[7];
        NSDictionary* userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:activity_type],SENSOR_REPORT_INFO_KEY_TYPE,[NSNumber numberWithInt:high],SENSOR_REPORT_INFO_KEY_VALUE, [NSNumber numberWithInt:low],SENSOR_REPORT_INFO_KEY_VALUE2,nil];
        NSLog(@"sensor_type = %ld , value1 = %d, value2 = %d",(long)activity_type,high, low);
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_sensor_report object:nil userInfo:userinfo];
 
    }
    
    
    
}

-(void)start_init_device{
//    [self reinitEnv];
    
    NSString* sendkey = [NSString stringWithFormat:@"%@:0",CMD_NOTIFICATION];
    if ([self.commandlist containsObject:sendkey]) {
        [self.commandlist removeObject:sendkey];
    }
    [self.commandlist insertObject:sendkey atIndex:0];
    
    if ([self.commandlist containsObject:CMD_SETPARAM]) {
        [self.commandlist removeObject:CMD_SETPARAM];
    }
    [self.commandlist insertObject:CMD_SETPARAM atIndex:0];
    
    if ([self.commandlist containsObject:CMD_READTIME]) {
        [self.commandlist removeObject:CMD_READTIME];
    }
    [self.commandlist insertObject:CMD_READTIME atIndex:0];

    if ([self.commandlist containsObject:CMD_GETFW]) {
        [self.commandlist removeObject:CMD_GETFW];
    }
    
    [self.commandlist insertObject:CMD_GETFW atIndex:0];
    

    if ([self.commandlist containsObject:CMD_GETMAC]) {
        [self.commandlist removeObject:CMD_GETMAC];
    }
    [self.commandlist insertObject:CMD_GETMAC atIndex:0];
    
    [self nextCommand];

}





-(void)CheckBandInfo{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BandInfo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@ and uuid = %@", self.commondata.uid, self.commondata.lastBongUUID];
    
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (fetchedObjects==nil || fetchedObjects.count == 0) {

        NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
        if (bi) {
            BandInfo* record = [NSEntityDescription insertNewObjectForEntityForName:@"BandInfo" inManagedObjectContext:self.managedObjectContext];
            record.uid = self.commondata.uid;
            record.uuid = self.commondata.lastBongUUID;
            record.macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
            record.name = [bi objectForKey:BONGINFO_KEY_BLENAME];
            record.datetime = [NSDate date];
            record.subgeartype = [bi objectForKey:BONGINFO_KEY_SUBGEARTYPE];
            [self.managedObjectContext save:nil];
        }
    }

}

-(void)sendCmd:(NSString*)cmd{
    if (self.commandlist.count) {
        if ([self.commandlist containsObject:cmd]) {
            return;
        }else{
            if ([cmd isEqualToString:CMD_C4])
            {
                [self.commandlist insertObject:cmd atIndex:0];
            }
            else if([cmd isEqualToString:CMD_A2])
            {
                [self.commandlist insertObject:cmd atIndex:0];
            }
            else
            {
                [self.commandlist addObject:cmd];
            }
        }
    }else{
        [self.commandlist addObject:cmd];
        if(self.sub_state == SUB_STATE_IDLE){
            [self nextCommand];
        }
    }
}

-(void)onCmdTimeout:(NSNotification*)notify{
    NSLog(@"onCmdTimeout %@",notify.userInfo);
    NSString* cmd = [notify.userInfo objectForKey:@"cmdname"];
    if ([cmd hasPrefix:CMD_SENDALARM]) {
        self.sub_state = SUB_STATE_IDLE;
        [self nextCommand];
    }else if([cmd isEqualToString:CMD_GETMAC]){
//        NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
//        [bi setObject:@"123456" forKey:BONGINFO_KEY_BLEADDR];
//        [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bi];
//        self.sub_state = SUB_STATE_IDLE;
//        [self nextCommand];
 
        self.getmactimeout += 1;
        if (self.getmactimeout >= 3) {
            self.sub_state = SUB_STATE_IDLE;
            [self nextCommand];
        }else{
            [self sendCmd:cmd];
            self.sub_state = SUB_STATE_IDLE;
            [self nextCommand];
        }

    }
    else if ([cmd isEqualToString:CMD_GETFW]){
//#ifdef CUSTOM_FITRIST
//#if CUSTOM_FITRIST || CUSTOM_PUZZLE || CUSTOM_NOMI || CUSTOM_HIMOVE
        NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
        [bi setObject:@"000" forKey:BONGINFO_KEY_VERSIONCODE];
        [bi setObject:@"FR_T" forKey:BONGINFO_KEY_PRODUCTCODE];
        [bi setObject:@"CZJK" forKey:BONGINFO_KEY_PROJECTCODE];
        [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bi];
//#endif
        self.getfwtimeout += 1;
        if (self.getfwtimeout >= 3) {
            self.sub_state = SUB_STATE_IDLE;
            [self nextCommand];
        }else{
            [self sendCmd:cmd];
            self.sub_state = SUB_STATE_IDLE;
            [self nextCommand];
        }
        

    }else if ([cmd isEqualToString:CMD_SETSCREEN]){
        self.sub_state = SUB_STATE_IDLE;
        [self nextCommand];
    }else if ([cmd isEqualToString:CMD_PAIR]){
        self.sub_state = SUB_STATE_IDLE;
        [self nextCommand];
    }
    else if ([cmd hasPrefix:CMD_WEATHER]){
        self.sub_state = SUB_STATE_IDLE;
        [self nextCommand];
    }
    else if ([cmd hasPrefix:CMD_SENDALARM]){
        self.sub_state = SUB_STATE_IDLE;
        [self nextCommand];
    }
    else{
//        [self sendCmd:cmd];
        self.sub_state = SUB_STATE_IDLE;
        [self nextCommand];
    }
}
//#endif
//在一些不需要响应的命令，发送过后，blecontrol会调用此代理方法，让mainloop的状态机继续往下走
-(void)doNext{
//#ifdef CUSTOM_API2
    if (self.sub_state == SUB_STATE_WAIT_NODIC_INTO_OTA_RSP) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_send_nodic_ota0 object:nil];
        [self reinitEnv];
        [self.blecontrol disconnectDevice2];

    }
//#endif
}

-(void)startNodicOTA{
//#ifdef CUSTOM_API2
    [self reinitEnv];
    [self sendCmd:CMD_NORDIC_INTO_OTA];
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(doNext) userInfo:nil repeats:NO];
     
     //#endif
}


-(void)StartAutoSync{
    /*
    if (self.autoC4timer) {
        [self.autoC4timer invalidate];
        self.autoC4timer= nil;
    }
    self.autoC4timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(SyncHsitoryData) userInfo:nil repeats:YES];
    */
    //    if (self.autoC6timer) {
    //        [self.autoC6timer invalidate];
    //        self.autoC6timer = nil;
    //    }
    //    self.autoC6timer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(SyncCurrentData) userInfo:nil repeats:YES];
    
}
-(void)StopAutoSync{
    /*
    if (self.autoC4timer) {
        [self.autoC4timer invalidate];
        self.autoC4timer= nil;
    }
    */
    //    if (self.autoC6timer) {
    //        [self.autoC6timer invalidate];
    //        self.autoC6timer = nil;
    //    }
    
}

-(void)onTakePhoto:(NSNotification*)notify{
    NSLog(@"TakePhoto::");
    if(self.commondata.is_enable_takephoto)
        [self takePhoto];
}

-(void)takePhoto{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        if ([[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController isKindOfClass:[SXRPhoto2ViewController class]] == NO){
            [self performSelectorOnMainThread:@selector(openCamera) withObject:nil waitUntilDone:YES];
            
        }else{
            
        }
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                
                if ([[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController isKindOfClass:[SXRPhoto2ViewController class]] == NO){
                    
                    [self performSelectorOnMainThread:@selector(openCamera) withObject:nil waitUntilDone:YES];
                }
                
            } else {
                NSLog(@"Not granted access");
            }
        }];
    }else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Camera_Denied", nil) message:NSLocalizedString(@"Camera_Denied_Tip", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL",nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alert.tag = 100;
        [alert show];
    }
}
-(void)openCamera{
    SXRPhoto2ViewController* vc = [[SXRPhoto2ViewController alloc] init];
    AppDelegate *appdelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    //    appdelegate.window.rootViewController=vc;
    [appdelegate.window.rootViewController presentViewController:vc animated:YES completion:nil];
}


@end
