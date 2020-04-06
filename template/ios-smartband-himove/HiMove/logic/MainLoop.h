//
//  MainLoop.h
//  IntelligentRingKing
//
//  Created by qf on 14-5-30.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
//#import <CoreTelephony/CTCall.h>
//#import <CoreTelephony/CTCallCenter.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BleControl.h"
#import "StepHistory+CoreDataClass.h"
#import "StepHistory_Day.h"
#import "StepHistory_Hour.h"
#import "StepHistory_Month.h"
#import "SleepHistory_Day.h"
#import "SleepHistory_Month.h"
#import "SleepHistory_Hour.h"
#import "AppDelegate.h"
#import <EventKit/EventKit.h>
#import "DataCenter.h"
#import "SyncNotifyView.h"
#import "KLCPopup.h"
#import "Sport_data_history.h"

#define STABLE_TIMER 1

#define CURRENT_STATE_UNCONNECTED  0
#define CURRENT_STATE_WAIT_FOR_STABLE 1
#define CURRENT_STATE_WAIT_FOR_DEVICE_TIME 2
#define CURRENT_STATE_WAIT_FOR_SET_DEVICE_TIME 3
#define CURRENT_STATE_WAIT_CLEAR 4
#define CURRENT_STATE_READY 5
#define CURRENT_STATE_OTA 6
#define CURRENT_STATE_WAIT_MANUAL_CLEAR 7
#define CURRENT_STATE_WAIT_SLEEP_SET 8



#define TIME_NEED_TO_RESET_DEVICE 30*60
#define TIME_NEED_TO_SYNC_DEVICE_TIME 2

#define PLAYMUSICTYPE_STOP 1
#define PLAYMUSICTYPE_PLAY 2

#define OPERATOR_SYNC_NIL 0
#define OPERATOR_SYNC_HISTORY 1
#define OPERATOR_SYNC_CURRENT 2
#define OPERATOR_SYNC_ALARM 3
#define OPERATOR_SYNC_LONGSIT 4
#define OPERATOR_SYNC_CLOCK 5
#define OPERATOR_SYNC_PERSONINFO 6
#define OPERATOR_SYNC_WEATHER 7
#define OPERATOR_SYNC_OTA 8
#define OPERATOR_CLEAR 9
#define OPERATOR_SYNC_SLEEPTIME 10
#define OPERATOR_SYNC_SWITCHACTIVITY 11
#define OPERATOR_SYNC_SCREENTIME 12



@interface MainLoop : NSObject<BleControlDelegate,AVAudioPlayerDelegate>

//@property (nonatomic, strong)CTCallCenter * center;


@property (nonatomic, assign) BOOL is_thread_run;

@property NSMutableArray * commandArray;

+(MainLoop*)SharedInstance;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) MPMusicPlayerController * musicplayer;

@property (nonatomic, retain) AVAudioPlayer *player_call;


//-(void)ReadBongBatteryLevel;
- (void)setHydration;
//-(void)setPersonInfo;
//-(void)api_send_alarm:(IRKPhone2DeviceAlarms)evt;
-(void)api_send_weather:(IRKPhone2DeviceWeather)evt;
-(void)api_send_antilost:(int)type;
//-(void)api_get_DeviceTime;
//-(void)api_set_DeviceTime:(Byte)year M:(Byte)month D:(Byte)day H:(Byte)hour MM:(Byte)minute S:(Byte)second W:(Byte)week;
//-(void)api_set_Clear;
//-(void)api_set_Personal_data;
//-(void)api_set_SleepMode:(BOOL)sleepmode ShackMode:(BOOL)shackmode;
//-(void)api_set_sleeptime;
//-(void)api_send_activity_monitor:(NSInteger)activetype report:(BOOL)reportflag;
//-(void)api_set_screentime;
-(void)set_alarm_name_index:(NSInteger)index;
@property NSMutableArray * rssilist;
@property BOOL is_send_alarm;

@property (strong, nonatomic) EKEventStore* ekstore;

@property NSTimer* waitStableTmr;
@property NSTimer* C4Timer;
@property NSTimer* C6Timer;
@property (strong, nonatomic)NSTimer* backgroundtimer;

@property int current_state;
@property int errortimes;
@property int playmusicType;
@property int sync_type;
@property (nonatomic, strong) NSTimer* reconnect;
@property (nonatomic, strong) NSTimer* connecttimeout;
-(void)SyncHsitoryData;
-(void)SyncCurrentData;
@property int runmode;

@property NSTimer* cmdResendtimer;
-(void)StartSetLongsit;
-(void)StartSetClock;
//-(void)StartNotify;
//-(void)closeConnect;
-(void)connectDefaultDevice:(NSNotification*)notify;
-(void)StartSetPersonInfo;
-(void)StartSetSleepset;
-(void)StartSetScreenTime;
-(void)StartOTA:(NSString*)filepath;
@property (assign, nonatomic)NSInteger current_ota_block;
@property (assign, nonatomic)NSInteger current_ota_piece;
@property (assign, nonatomic)NSInteger max_ota_block;
@property (assign, nonatomic)NSInteger max_ota_piece;

-(void)start_call_phone;
@property UIBackgroundTaskIdentifier backgroundIdentifier;
-(void)HomeGetCurrentData;

@property (strong, nonatomic)NSTimer* antilost_relay_timer;

-(void)Start_clear;
-(void)StartSwitchActivity:(NSInteger)activetype report:(BOOL)reportflag;
-(void)sendCmd:(NSString*)cmd;
-(void)startNodicOTA;

-(void)StartAutoSync;
-(void)StopAutoSync;


- (void)setConfigParam;
- (void)setNotification:(int)optcode;
@end
