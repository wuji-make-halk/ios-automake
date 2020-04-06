//
//  RunHistory+CoreDataProperties.h
//  HiMove
//
//  Created by qf on 2017/5/23.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "RunHistory+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RunHistory (CoreDataProperties)

+ (NSFetchRequest<RunHistory *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *adddate;
@property (nullable, nonatomic, copy) NSNumber *addtimestamp;
@property (nullable, nonatomic, copy) NSNumber *altitude;
@property (nullable, nonatomic, copy) NSNumber *direction;
@property (nullable, nonatomic, copy) NSNumber *issync;
@property (nullable, nonatomic, copy) NSNumber *latitude;
@property (nullable, nonatomic, copy) NSNumber *locType;
@property (nullable, nonatomic, copy) NSNumber *longitude;
@property (nullable, nonatomic, copy) NSString *macid;
@property (nullable, nonatomic, copy) NSNumber *radius;
@property (nullable, nonatomic, copy) NSString *running_id;
@property (nullable, nonatomic, copy) NSNumber *satellite_number;
@property (nullable, nonatomic, copy) NSNumber *speed;
@property (nullable, nonatomic, copy) NSString *uid;
@property (nullable, nonatomic, copy) NSString *memberid;

@end

NS_ASSUME_NONNULL_END
