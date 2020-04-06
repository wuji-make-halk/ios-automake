//
//  SyncNotifyView.h
//  Walknote
//
//  Created by qf on 15/4/21.
//  Copyright (c) 2015年 SXR. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SyncNotifyView;
@protocol SyncNotifyViewDelegate <NSObject>

-(void)SyncNotifyViewClickBackBtn:(SyncNotifyView*)view;

@end

@interface SyncNotifyView : UIView
@property(nonatomic,weak) id<SyncNotifyViewDelegate>delegate;
-(void)refreshSyncProgress:(CGFloat)progress;
@end
