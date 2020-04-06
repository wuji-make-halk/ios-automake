//
//  RunRecord+CoreDataProperties.m
//  HiMove
//
//  Created by qf on 2017/9/5.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "RunRecord+CoreDataProperties.h"

@implementation RunRecord (CoreDataProperties)

+ (NSFetchRequest<RunRecord *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"RunRecord"];
}

@dynamic adddate;
@dynamic closed;
@dynamic issync;
@dynamic macid;
@dynamic memberid;
@dynamic pace;
@dynamic running_id;
@dynamic sectionIdentifier;
@dynamic starttime;
@dynamic starttimestamp;
@dynamic totalcalories;
@dynamic totaldistance;
@dynamic totalstep;
@dynamic totaltime;
@dynamic type;
@dynamic uid;
@dynamic issynchealthkit;

@end
