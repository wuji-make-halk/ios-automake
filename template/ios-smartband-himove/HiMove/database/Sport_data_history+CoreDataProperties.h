//
//  Sport_data_history+CoreDataProperties.h
//  CZJKBand
//
//  Created by 张志鹏 on 16/6/23.
//  Copyright © 2016年 SXR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Sport_data_history.h"

NS_ASSUME_NONNULL_BEGIN

@interface Sport_data_history (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *adddate;
@property (nullable, nonatomic, retain) NSNumber *cal;
@property (nullable, nonatomic, retain) NSString *macid;
@property (nullable, nonatomic, retain) NSNumber *step;
@property (nullable, nonatomic, retain) NSNumber *timeLength;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSString *uid;

@end

NS_ASSUME_NONNULL_END
