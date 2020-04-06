//
//  SleepHistory_Month.h
//  SXRBand
//
//  Created by qf on 15/8/27.
//  Copyright (c) 2015年 SXR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SleepHistory_Month : NSManagedObject

@property (nonatomic, retain) NSNumber * awake;
@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) NSNumber * deep;
@property (nonatomic, retain) NSNumber * exlight;
@property (nonatomic, retain) NSNumber * light;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * macid;

@end
