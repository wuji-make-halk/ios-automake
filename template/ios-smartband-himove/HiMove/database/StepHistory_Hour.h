//
//  StepHistory_Hour.h
//  SXRBand
//
//  Created by qf on 15/8/27.
//  Copyright (c) 2015年 SXR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StepHistory_Hour : NSManagedObject

@property (nonatomic, retain) NSNumber * cal;
@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * sport;
@property (nonatomic, retain) NSNumber * steps;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * macid;

@end
