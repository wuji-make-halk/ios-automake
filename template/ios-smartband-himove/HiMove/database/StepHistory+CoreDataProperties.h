//
//  StepHistory+CoreDataProperties.h
//  HiMove
//
//  Created by qf on 2017/9/5.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "StepHistory+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface StepHistory (CoreDataProperties)

+ (NSFetchRequest<StepHistory *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *cal;
@property (nullable, nonatomic, copy) NSDate *datetime;
@property (nullable, nonatomic, copy) NSNumber *distance;
@property (nullable, nonatomic, copy) NSNumber *heartrate;
@property (nullable, nonatomic, copy) NSNumber *issync;
@property (nullable, nonatomic, copy) NSString *macid;
@property (nullable, nonatomic, copy) NSString *memberid;
@property (nullable, nonatomic, copy) NSNumber *mode;
@property (nullable, nonatomic, copy) NSNumber *steps;
@property (nullable, nonatomic, copy) NSNumber *type;
@property (nullable, nonatomic, copy) NSString *uid;
@property (nullable, nonatomic, copy) NSNumber *issynchealthkit;

@end

NS_ASSUME_NONNULL_END
