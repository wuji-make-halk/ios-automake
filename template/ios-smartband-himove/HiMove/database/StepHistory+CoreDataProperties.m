//
//  StepHistory+CoreDataProperties.m
//  HiMove
//
//  Created by qf on 2017/9/5.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "StepHistory+CoreDataProperties.h"

@implementation StepHistory (CoreDataProperties)

+ (NSFetchRequest<StepHistory *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"StepHistory"];
}

@dynamic cal;
@dynamic datetime;
@dynamic distance;
@dynamic heartrate;
@dynamic issync;
@dynamic macid;
@dynamic memberid;
@dynamic mode;
@dynamic steps;
@dynamic type;
@dynamic uid;
@dynamic issynchealthkit;

@end
