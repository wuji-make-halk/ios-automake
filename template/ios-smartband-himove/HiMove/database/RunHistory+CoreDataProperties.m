//
//  RunHistory+CoreDataProperties.m
//  HiMove
//
//  Created by qf on 2017/5/23.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "RunHistory+CoreDataProperties.h"

@implementation RunHistory (CoreDataProperties)

+ (NSFetchRequest<RunHistory *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"RunHistory"];
}

@dynamic adddate;
@dynamic addtimestamp;
@dynamic altitude;
@dynamic direction;
@dynamic issync;
@dynamic latitude;
@dynamic locType;
@dynamic longitude;
@dynamic macid;
@dynamic radius;
@dynamic running_id;
@dynamic satellite_number;
@dynamic speed;
@dynamic uid;
@dynamic memberid;

@end
