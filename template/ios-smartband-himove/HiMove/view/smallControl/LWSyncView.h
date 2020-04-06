//
//  LWSyncView.h
//  Lovewell
//
//  Created by qf on 14-8-6.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRKProgressBar.h"
#import "KLCPopup.h"

@class LWSyncView;
@protocol LWSyncViewDelegate <NSObject>

@optional
-(void)LWSyncViewDisOk:(LWSyncView*)view;
-(void)LWSyncViewClickClose:(LWSyncView *)view;
@end

@interface LWSyncView : UIView<IRKProgressBarDelegate>
@property (assign, nonatomic) id<LWSyncViewDelegate> delegate;
@property (strong, nonatomic) IRKCommonData* commondata;
@property (strong, nonatomic) IRKProgressBar * progressbar;
@property (strong, nonatomic) UILabel* tip;
@property (strong, nonatomic) UILabel* timelabel;
@property (strong, nonatomic) UILabel* label_rate;
@property (strong, nonatomic) UIButton* button;
@property(nonatomic, strong)UIButton* btn_back;
@property double totaltime;
@property double lasttime;

@property CGFloat fontsize;

@end
