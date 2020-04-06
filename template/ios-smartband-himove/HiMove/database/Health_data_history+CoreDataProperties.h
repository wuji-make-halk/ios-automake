//
//  Health_data_history+CoreDataProperties.h
//  HiMove
//
//  Created by qf on 2017/9/5.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "Health_data_history+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Health_data_history (CoreDataProperties)

+ (NSFetchRequest<Health_data_history *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *adddate;
@property (nullable, nonatomic, copy) NSNumber *issync;
@property (nullable, nonatomic, copy) NSString *macid;
@property (nullable, nonatomic, copy) NSString *memberid;
@property (nullable, nonatomic, copy) NSNumber *type;
@property (nullable, nonatomic, copy) NSString *uid;
@property (nullable, nonatomic, copy) NSNumber *value;
@property (nullable, nonatomic, copy) NSNumber *value2;
@property (nullable, nonatomic, copy) NSNumber *issynchealthkit;

@end

NS_ASSUME_NONNULL_END
