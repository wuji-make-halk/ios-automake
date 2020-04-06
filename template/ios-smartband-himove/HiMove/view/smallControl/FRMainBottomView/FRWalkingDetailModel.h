//
//  FRWalkingDetailModel.h
//  CZJKBand
//
//  Created by 刘增述 on 16/9/9.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRWalkingDetailModel : NSObject

@property (nonatomic,copy) NSString *totalDistance;

@property (nonatomic,copy) NSString *calBurned;

@property (nonatomic,copy) NSString *totalTime;

@property (nonatomic,copy) NSString *runCalBurned;

@property (nonatomic,copy) NSString *deep;

@property (nonatomic,copy) NSString *extremly;

@property (nonatomic,copy) NSString *light;

@property (nonatomic,copy) NSString *awake;

@property (nonatomic,copy) NSString *BPM;

@property (nonatomic,copy) NSString *BPM_time;

/**
 *  不同页数赋不同的值
 */
@property (nonatomic,assign) NSInteger index;


@end
