//
//  FRSleepBottomView.h
//  CZJKBand
//
//  Created by 刘增述 on 16/9/9.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRWalkingDetailModel.h"

@class FRSleepBottomView;

@protocol sleepBottomViewDelegate <NSObject>

@optional
-(void)SyncButtonInSleepBottomView:(FRSleepBottomView *)sleepBottomView;
@end

@interface FRSleepBottomView : UIView

@property (nonatomic,strong)FRWalkingDetailModel *sleepModle;
@property (nonatomic,weak) id<sleepBottomViewDelegate> delegate;

+ (instancetype)sleepBottomView;


@end
