//
//  TaskInfo+CoreDataProperties.h
//  HiMove
//
//  Created by qf on 2017/5/23.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "TaskInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TaskInfo (CoreDataProperties)

+ (NSFetchRequest<TaskInfo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *createdate;
@property (nullable, nonatomic, copy) NSNumber *currentkey;
@property (nullable, nonatomic, copy) NSString *datatype;
@property (nullable, nonatomic, copy) NSString *filename;
@property (nullable, nonatomic, copy) NSString *memberid;
@property (nullable, nonatomic, copy) NSNumber *startkey;
@property (nullable, nonatomic, copy) NSNumber *state;
@property (nullable, nonatomic, copy) NSString *synckey;
@property (nullable, nonatomic, copy) NSNumber *targetkey;
@property (nullable, nonatomic, copy) NSString *taskid;
@property (nullable, nonatomic, copy) NSString *tasktype;
@property (nullable, nonatomic, copy) NSString *uid;

@end

NS_ASSUME_NONNULL_END
