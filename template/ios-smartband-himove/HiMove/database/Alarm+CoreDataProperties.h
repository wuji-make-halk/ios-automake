//
//  Alarm+CoreDataProperties.h
//  CZJKBand
//
//  Created by 张志鹏 on 16/6/15.
//  Copyright © 2016年 SXR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Alarm.h"

NS_ASSUME_NONNULL_BEGIN

@interface Alarm (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *alarm_id;
@property (nullable, nonatomic, retain) NSDate *createtime;
@property (nullable, nonatomic, retain) NSNumber *day;
@property (nullable, nonatomic, retain) NSNumber *enable;
@property (nullable, nonatomic, retain) NSNumber *endhour;
@property (nullable, nonatomic, retain) NSNumber *endminute;
@property (nullable, nonatomic, retain) NSDate *firedate;
@property (nullable, nonatomic, retain) NSNumber *hour;
@property (nullable, nonatomic, retain) NSString *macid;
@property (nullable, nonatomic, retain) NSNumber *minute;
@property (nullable, nonatomic, retain) NSNumber *month;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *repeat_hour;
@property (nullable, nonatomic, retain) NSNumber *repeat_schedule;
@property (nullable, nonatomic, retain) NSNumber *repeat_times;
@property (nullable, nonatomic, retain) NSNumber *snooze;
@property (nullable, nonatomic, retain) NSNumber *snooze_repeat;
@property (nullable, nonatomic, retain) NSNumber *starthour;
@property (nullable, nonatomic, retain) NSNumber *startminute;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSNumber *vib_number;
@property (nullable, nonatomic, retain) NSNumber *vib_repeat;
@property (nullable, nonatomic, retain) NSNumber *weekly;
@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) NSNumber *ishidden;

@end

NS_ASSUME_NONNULL_END
