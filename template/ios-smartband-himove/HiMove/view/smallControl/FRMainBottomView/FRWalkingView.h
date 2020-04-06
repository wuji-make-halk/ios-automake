//
//  FRWalkingView.h
//  CZJKBand
//
//  Created by 刘增述 on 16/9/9.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRWalkingDetailModel.h"


@class FRWalkingView;

@protocol walkingBottomDelegate <NSObject>

@optional
-(void)SyncButtonInWalkingView:(FRWalkingView *)walkingView;
@end



@interface FRWalkingView : UIView

@property (nonatomic,strong)FRWalkingDetailModel *walkingModel;

@property (nonatomic,weak) id<walkingBottomDelegate>syncDelegate;

@property (nonatomic,assign) BOOL isHiddenSyncBtn;

+ (instancetype)WalkingView;


@end
