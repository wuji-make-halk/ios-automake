//
//  RunRecord+CoreDataProperties.h
//  HiMove
//
//  Created by qf on 2017/9/5.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "RunRecord+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RunRecord (CoreDataProperties)

+ (NSFetchRequest<RunRecord *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *adddate;
@property (nullable, nonatomic, copy) NSNumber *closed;
@property (nullable, nonatomic, copy) NSNumber *issync;
@property (nullable, nonatomic, copy) NSString *macid;
@property (nullable, nonatomic, copy) NSString *memberid;
@property (nullable, nonatomic, copy) NSNumber *pace;
@property (nullable, nonatomic, copy) NSString *running_id;
@property (nullable, nonatomic, copy) NSString *sectionIdentifier;
@property (nullable, nonatomic, copy) NSDate *starttime;
@property (nullable, nonatomic, copy) NSNumber *starttimestamp;
@property (nullable, nonatomic, copy) NSNumber *totalcalories;
@property (nullable, nonatomic, copy) NSNumber *totaldistance;
@property (nullable, nonatomic, copy) NSNumber *totalstep;
@property (nullable, nonatomic, copy) NSNumber *totaltime;
@property (nullable, nonatomic, copy) NSNumber *type;
@property (nullable, nonatomic, copy) NSString *uid;
@property (nullable, nonatomic, copy) NSNumber *issynchealthkit;

@end

NS_ASSUME_NONNULL_END
