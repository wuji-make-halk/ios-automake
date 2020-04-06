//
//  SXRNotifyView.h
//  SXRBand
//
//  Created by qf on 14-8-14.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLCPopup.h"
@class SXRNotifyView;


@protocol SXRNotifyViewDelegate <NSObject>
@required
-(NSString*)SXRNotifyView:(SXRNotifyView*)view stringByAction:(NSString*)action;
@optional
-(void)SXRNotifyViewDisOk:(SXRNotifyView*)view;

@end

@interface SXRNotifyView : UIView
@property (assign, nonatomic) id<SXRNotifyViewDelegate> delegate;
@property (strong, nonatomic) IRKCommonData* commondata;
@property (strong, nonatomic) UILabel* tip;
@property (strong, nonatomic) UIButton* button;

@property CGFloat fontsize;
@end
