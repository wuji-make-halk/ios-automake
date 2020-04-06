//
//  WeatherLoop.h
//  SXRBand
//
//  Created by qf on 14-7-31.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherLoop : NSObject<NSURLConnectionDelegate>
+(WeatherLoop *)SharedInstance;
@property (nonatomic, assign) NSInteger weatherApiType;

@property (strong, nonatomic)IRKCommonData* commondata;
@property (strong,nonatomic)NSMutableData* recvdata;

@end
