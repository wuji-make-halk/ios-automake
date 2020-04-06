//
//  ServerLogic.h
//  SXRBand
//
//  Created by qf on 14-9-1.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "MemberInfo.h"
//#import <AdSupport/AdSupport.h>
#import "MainLoop.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Alarm.h"
#import <AFNetworking/AFNetworking.h>

@class MainLoop;


@interface ServerLogic : NSObject<NSFetchedResultsControllerDelegate,UIAlertViewDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) IRKCommonData* commondata;
@property (strong, nonatomic) MainLoop* mainloop;
@property (strong, nonatomic) BleControl* blecontrol;
@property (strong, nonatomic)NSString* fwUrl;
@property (strong, nonatomic)NSString* filename;
@property (strong, nonatomic)NSString* md5file;

+(ServerLogic *)SharedInstance;
@property (strong,nonatomic)NSMutableData* recvdata;

-(void)logout;
-(void)update_usergoal;
-(void)update_userinfo;
-(NSMutableDictionary*)MakeAlarmActionBody:(Alarm*)alarminfo;
-(void)update_alarm:(NSDictionary*)alarminfo;
@property(nonatomic,strong) dispatch_queue_t dispatchqueue;
-(void)updateUserInfotoCommonData:(NSMutableDictionary*)userinfo;

@end
