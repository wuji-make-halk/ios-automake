//
//  TaskInfo+CoreDataProperties.m
//  HiMove
//
//  Created by qf on 2017/5/23.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "TaskInfo+CoreDataProperties.h"

@implementation TaskInfo (CoreDataProperties)

+ (NSFetchRequest<TaskInfo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"TaskInfo"];
}

@dynamic createdate;
@dynamic currentkey;
@dynamic datatype;
@dynamic filename;
@dynamic memberid;
@dynamic startkey;
@dynamic state;
@dynamic synckey;
@dynamic targetkey;
@dynamic taskid;
@dynamic tasktype;
@dynamic uid;

@end
