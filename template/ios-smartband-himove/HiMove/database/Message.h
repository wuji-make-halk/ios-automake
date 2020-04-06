//
//  Message.h
//  SXRBand
//
//  Created by qf on 14-7-25.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * type;

@end
