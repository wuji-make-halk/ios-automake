//
//  Health_data_history+CoreDataProperties.m
//  HiMove
//
//  Created by qf on 2017/9/5.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "Health_data_history+CoreDataProperties.h"

@implementation Health_data_history (CoreDataProperties)

+ (NSFetchRequest<Health_data_history *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Health_data_history"];
}

@dynamic adddate;
@dynamic issync;
@dynamic macid;
@dynamic memberid;
@dynamic type;
@dynamic uid;
@dynamic value;
@dynamic value2;
@dynamic issynchealthkit;

@end
