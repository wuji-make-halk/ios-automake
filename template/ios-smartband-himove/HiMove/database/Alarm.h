//
//  Alarm.h
//  SXRBand
//
//  Created by qf on 15/8/28.
//  Copyright (c) 2015年 SXR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Alarm : NSManagedObject

@property (nonatomic, retain) NSNumber * alarm_id;
@property (nonatomic, retain) NSDate * createtime;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * enable;
@property (nonatomic, retain) NSNumber * endhour;
@property (nonatomic, retain) NSNumber * endminute;
@property (nonatomic, retain) NSDate * firedate;
@property (nonatomic, retain) NSNumber * hour;
@property (nonatomic, retain) NSString * macid;
@property (nonatomic, retain) NSNumber * minute;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * repeat_hour;
@property (nonatomic, retain) NSNumber * repeat_schedule;
@property (nonatomic, retain) NSNumber * repeat_times;
@property (nonatomic, retain) NSNumber * snooze;
@property (nonatomic, retain) NSNumber * snooze_repeat;
@property (nonatomic, retain) NSNumber * starthour;
@property (nonatomic, retain) NSNumber * startminute;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * vib_number;
@property (nonatomic, retain) NSNumber * vib_repeat;
@property (nonatomic, retain) NSNumber * weekly;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * ishidden;

@end
