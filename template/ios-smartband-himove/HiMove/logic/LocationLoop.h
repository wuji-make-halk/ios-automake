//
//  LocationLoop.h
//  SXRBand
//
//  Created by qf on 14-7-31.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
//#import <AdSupport/AdSupport.h>

@interface LocationLoop : NSObject<CLLocationManagerDelegate>
+(LocationLoop *)SharedInstance;
@property (strong, nonatomic) CLLocationManager* locationmanager;
@property (strong, nonatomic) IRKCommonData* commondata;
@property (strong, nonatomic) NSTimer* locationtimer;
@property (strong, nonatomic) NSMutableArray* coord_list;

-(void)startLocation;
-(void)stopLocation;

@end
