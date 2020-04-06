//
//  SyncCmdNotifyView.h
//  SXRBand
//
//  Created by qf on 16/4/12.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SyncCmdNotifyView;
@protocol SyncCmdNotifyViewDelegate <NSObject>

-(void)SyncCmdNotifyViewClickBackBtn:(SyncCmdNotifyView*)view;

@end

@interface SyncCmdNotifyView : UIView
@property(nonatomic,weak) id<SyncCmdNotifyViewDelegate>delegate;
-(void)ShowString:(NSString*)str;

@end

