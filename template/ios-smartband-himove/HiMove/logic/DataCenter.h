//
//  DataCenter.h
//  SXRBand
//
//  Created by qf on 14-8-14.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "StepHistory+CoreDataClass.h"
#import "StepHistory_Day.h"
#import "StepHistory_Hour.h"
#import "StepHistory_Month.h"
#import "SleepHistory_Day.h"
#import "SleepHistory_Month.h"
#import "Alarm.h"

@interface DataCenter : NSObject<NSFetchedResultsControllerDelegate>

+(DataCenter *)SharedInstance;
@property (nonatomic, strong) IRKCommonData* commondata;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic,strong) dispatch_queue_t dataqueue;

@property NSDate* maxDate;
@property NSDate* maxDateMonth;
@property int maxYear;
@property int minYear;


@property NSDate* minDate;
@property NSDate* minDateMonth;
@property NSMutableDictionary * Hourdict;
@property NSMutableDictionary * Daydict;
@property NSMutableDictionary * Monthdict;

-(void)reloadData;
-(NSDate*)getPrevDate:(NSDate*)date;
-(NSDate*)getNextDate:(NSDate*)date;
-(NSDate*)getPrevMonth:(NSDate*)date;
-(NSDate*)getNextMonth:(NSDate*)date;
-(NSDate*)getPrevYear:(NSDate*)date;
-(NSDate*)getNextYear:(NSDate*)date;

-(NSInteger)getStepbyDate:(NSDate*)date;
-(NSMutableDictionary*)getDataByDate:(NSDate*)date;
-(NSMutableDictionary*)getMonthDataByDate:(NSDate*)date;
-(NSMutableDictionary*)getSleepDataByDate:(NSDate*)date;
-(Alarm*)getAlarmDataByType:(int)alarmtype byIndex:(int)index byMacid:(NSString*)macid byUid:(NSString*)uid;

-(NSString*)getMonthKeyfromDate:(NSDate*)date;
-(NSString*)getDayKeyfromDate:(NSDate*)date;
-(NSString*)getHourKeyfromDate:(NSDate*)date;

-(NSString*)get10MinuteKeyfromDate:(NSDate*)date;
@end
