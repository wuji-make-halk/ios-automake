//
//  IRKCommonData.h
//  IntelligentRingKing
//
//  Created by qf on 14-5-30.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ZCChinaLocation.h"
#import "sys/utsname.h"
#import <AVFoundation/AVFoundation.h>
#import "CommonDefine.h"


@interface IRKCommonData : NSObject
+(IRKCommonData*)SharedInstance;

@property (nonatomic, assign) BOOL is_enable_incomingcall;
@property (nonatomic, assign) BOOL is_enable_smsnotify;
@property (nonatomic, assign) BOOL is_enable_qqnotify;
@property (nonatomic, assign) BOOL is_enable_wechatnotify;
@property (nonatomic, assign) BOOL is_enable_whatsappnotify;

@property (nonatomic, assign) BOOL is_enable_facebooknotify;
@property (nonatomic, assign) BOOL is_enable_twitternotify;
@property (nonatomic, assign) BOOL is_enable_skypenotify;
@property (nonatomic, assign) BOOL is_enable_linenotify;


@property(nonatomic,assign) BOOL is_in_factory;

@property(nonatomic,assign) BOOL is_enable_autoheart;
@property (nonatomic, assign) BOOL is_enable_bringScreen;       //翻腕亮屏
@property (nonatomic, assign) BOOL is_enable_righthand;         //右手佩戴
@property (nonatomic, assign) BOOL is_enable_nodistrub;         //勿扰模式

@property (nonatomic, assign) BOOL is_first_run;
@property (nonatomic, assign) BOOL is_first_add;
@property (nonatomic, assign) BOOL is_enable_antilost;
@property (nonatomic, assign) BOOL is_enable_takephoto;
@property (nonatomic, assign) BOOL is_enable_mailnotify;

@property (nonatomic, assign) BOOL is_enable_devicecall;
@property (nonatomic, assign) BOOL is_enable_bongcontrolmusic;
@property (nonatomic, assign) BOOL is_enable_projectalert;
@property (nonatomic, assign) BOOL is_enable_remindernotify;




@property (nonatomic, assign) BOOL is_enable_longsitalarm;
@property (nonatomic, assign) BOOL is_enable_lowbatteryalarm; //在fitrist 中用作是否震动，其余此项作废

@property (nonatomic, assign) BOOL is_need_sycn_persondata;
@property (nonatomic, assign) BOOL is_sleepmode;
@property (nonatomic, assign) BOOL is_enable_shock;
@property (nonatomic, assign) NSInteger target_steps;
@property (nonatomic, assign) NSInteger target_runsteps;
@property (nonatomic, assign) float target_distance;
@property (nonatomic, assign) int target_activity;
@property (nonatomic, assign) float stride;
@property (nonatomic, assign) float target_calorie;
@property (nonatomic, assign) double target_sleeptime;
@property (nonatomic, assign) BOOL is_access_to_reminder;
@property (nonatomic, assign) NSInteger measureunit;
@property (nonatomic, assign) NSInteger current_steps;
@property (nonatomic, assign) NSInteger current_heartRate;
@property (nonatomic, assign) CGFloat current_cal;
@property (nonatomic, assign) NSInteger current_distance;
@property (nonatomic, assign) float lastLat;
@property (nonatomic, assign) float lastLong;
@property (nonatomic, copy) NSString* lastCity;
@property (nonatomic, copy) NSString* lastLocationDetail;
@property (nonatomic, assign) float tempmax;
@property (nonatomic, assign) float tempmin;
@property (nonatomic, assign) float temp;
@property (nonatomic, strong) NSMutableArray* weathertype;
@property (nonatomic, assign)BOOL is_login;
@property (nonatomic, copy) NSString* lastLoginUsername;
@property(nonatomic,assign)CGFloat batterylevel;
@property (nonatomic,copy)NSString* memberid;


@property (nonatomic, assign) double lastReadDataTime;
@property (nonatomic, assign) double lastReadSportDataTime;

@property (nonatomic, copy) NSString* nickname;
@property (nonatomic, assign) NSInteger   male;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) float weight;
@property (nonatomic, copy) NSString* bloodtype;
@property (nonatomic, copy) NSString* birthyear;
@property (nonatomic, copy) NSString* lastBongUUID;
@property (nonatomic, copy) NSString* BongServiceUUID;
@property (nonatomic, copy) NSString* BongNotifyCharacterUUID;
@property (nonatomic, copy) NSString* BongWriteCharacterUUID;
@property (nonatomic, copy) NSString* BongBatteryCharacterUUID;
@property (nonatomic, copy) NSString* BongAdvNotifyCharacterUUID;
@property (nonatomic, copy) NSString* BongAdvWriteCharacterUUID;
@property (nonatomic, copy) NSString* BongOtaSericeUUID;
@property (nonatomic, copy) NSString* BongOtaDataCharaterUUID;
@property (nonatomic, copy) NSString* BongOtaCMDCharaterUUID;


@property (nonatomic, strong) UIColor* colorActivity;
@property (nonatomic, strong) UIColor* colorSteps;
@property (nonatomic, strong) UIColor* colorDistance;
@property (nonatomic, strong) UIColor* colorCal;
@property (nonatomic, strong) UIColor* colorSleep;
@property (nonatomic, strong) UIColor* colorGold;
@property (nonatomic, strong) UIColor* colorSilver;
@property (nonatomic, strong) UIColor* colorLack;
@property (nonatomic, strong) UIColor* colorSleeptime;
@property (nonatomic, strong) UIColor* colorLight;
@property (nonatomic, strong) UIColor* colorDeep;
@property (nonatomic, strong) UIColor* colorAwake;
@property (nonatomic, strong) UIColor* colorMenuBackground;
@property (nonatomic, strong) UIColor* colorNav;
@property (nonatomic, strong) UIColor* colorSync;
@property (nonatomic, strong) UIColor* colorLogin;
@property (nonatomic, strong) UIColor* colorSingalText;
@property (nonatomic, strong) UIColor* colorExlight;
@property (nonatomic, strong) UIColor* colorTabBackground;
@property (nonatomic, strong) UIColor* colorTabTextNormal;
@property (nonatomic, strong) UIColor* colorTabTexHighlight;
@property (nonatomic, strong) UIColor* colorPersonText;
@property (nonatomic, strong) UIColor* colorTextColor;
@property (nonatomic, strong) UIColor* colorMapLine;
@property (nonatomic, strong) UIColor* colorSleepDeep;
@property (nonatomic, strong) UIColor* colorSleepLight;
@property (nonatomic, strong) UIColor* colorSleepExlight;
@property (nonatomic, strong) UIColor* colorLoginText;
@property (nonatomic, strong) UIColor* colorMainText;


/*
@property BOOL is_incoming_call;
@property BOOL is_incoming_email;
@property BOOL is_incoming_sms;
@property BOOL is_calendar_event;
@property BOOL is_phone_low_power;
*/
//@property int current_steps;
//@property float current_cal;
//@property float current_distance;
@property (nonatomic, copy) NSString* account;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, assign) double lastLoginTime;
@property (nonatomic, copy) NSString* token;
@property (nonatomic, copy) NSString* uid;
@property (nonatomic, copy) NSString* headimg_url;
@property (nonatomic, assign) BOOL has_custom_headimage;



@property (nonatomic, assign) NSInteger longsit_time;
@property (nonatomic, assign) NSInteger longsit_starthour;
@property (nonatomic, assign) NSInteger longsit_endhour;
@property (nonatomic, assign) NSInteger longsit_period;
@property (nonatomic, assign) BOOL is_enable_clock;
@property (nonatomic, assign) NSInteger clock_hour;
@property (nonatomic, assign) NSInteger clock_minute;
@property (nonatomic, assign) NSUInteger clock_period;
@property (nonatomic, assign) NSInteger clock_smart;
@property (nonatomic, assign) double lastWeatherTime;
@property (nonatomic, assign) BOOL is_memberinfo_change;
@property (nonatomic, copy) NSString* current_macid;
@property (nonatomic, copy) NSString* current_firmware;
@property (nonatomic, assign) NSInteger forbbiden_flag;
@property (nonatomic, assign) NSInteger screentime;
@property (nonatomic, assign) NSInteger last_c6steps;
@property (nonatomic, strong) NSDate* last_c6date;

@property (nonatomic, assign)IRKPhone2DeviceAlarms* alarmEvent;

@property (nonatomic, copy) NSString* gear_subtype;
@property (nonatomic, copy) NSString* sub_geartype;

@property (nonatomic, assign) BOOL auto_sync;
@property (nonatomic, strong) UIColor* colorWeeks;
@property (nonatomic, strong) UIColor* colorWeeksBackground;

@property (nonatomic, strong) NSURL *alarmUrl;

@property (nonatomic, strong)AVAudioPlayer *player;


@property (nonatomic, copy)NSString *vid;
@property (nonatomic, copy)NSString *bleName;
@property (nonatomic, copy)NSString *shareKey;
@property (nonatomic, strong)NSDictionary *shareDict;
@property (nonatomic, strong)NSDictionary *qqDict;
@property (nonatomic, strong)NSDictionary *wechatDict;
@property (nonatomic, strong)NSDictionary *weiboDict;
@property (nonatomic, strong)NSDictionary *twitterDict;
@property (nonatomic, strong)NSDictionary *facebookDict;
@property (nonatomic, strong)NSDictionary *mailDict;
@property (nonatomic, strong)NSMutableArray* healthkitArr;


-(void)saveconfig;
-(void)loadconfig;

-(void)saveconfig:(id)obj forkey:(NSString*)key;
-(void)saveC6;
- (void)refreshNickName;
@property (nonatomic,strong)dispatch_queue_t savequeue;

-(BOOL)isDateInToday:(NSDate*)currentdate;
-(CGSize)getStringSize:(NSString*)str byFont:(UIFont*)font;
-(UIFont*)getFontbySize:(CGFloat)size isBold:(BOOL)bold;
-(UIImage*)getHeadimage;

-(NSMutableDictionary*)getBongInformation:(NSString*)uuid;
-(void)setBongInformation:(NSString*)uuid Information:(NSMutableDictionary*)info;
-(NSMutableDictionary*)getMemberInfo:(NSString*)username;
-(void)setMemberInfo:(NSString*)username Information:(NSMutableDictionary*)info;
-(NSMutableDictionary*)getUserInfo:(NSString *)uid;
-(void)setUserInfo:(NSString *)uid Information:(NSMutableDictionary *)info;


-(NSString*)gen_uuid;
-(NSString*)getSeqid;
-(NSString*)getVersion;
-(NSString*)getPhoneType;
-(NSString*)getPhoneOS;
-(NSString*)getPhoneName;
-(NSString*)getPhoneId;
-(BOOL)is24time;
-(CGFloat)getDistance:(NSInteger)steps;
-(CGFloat)getCal:(NSInteger)steps;
-(NSString*)formatterInt:(int)value;

- (void)playSound;
- (void)playSoundWithName:(NSString *)soundName;

- (int)intervalTimeForDays:(NSDate *)beginTime endTime:(NSDate *)endTime;

//
+ (NSString *)getCountryNum;

//获取国家码
+ (NSString *)getCountryCode;

//获取语言
+ (NSString *)getSysLanguage;

-(BOOL)validateEmail:(NSString *)email;

////////location
-(CLLocationCoordinate2D)convert_wgs2gcj:(CLLocationCoordinate2D)orgin;
-(CLLocationCoordinate2D)convert_gcj2wgs:(CLLocationCoordinate2D)orgin;
@property(nonatomic,strong)ZCChinaLocation* zcchina;
-(UIFont*)getFontbySize2:(CGFloat)size isBold:(BOOL)bold;
-(id)getValueFromBonginfoByKey:(NSString*)key;
-(NSString*)getdid;
@end

