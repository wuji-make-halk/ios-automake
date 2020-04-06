//
//  FRTipsViewController.h
//  CZJKBand
//
//  Created by 张志鹏 on 16/7/4.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TipViewDelegate <NSObject>

- (void)DidClickedTipButton:(NSInteger) btnIndex;

@end

@interface FRTipsViewController : UIViewController

@property (nonatomic, assign) NSInteger tipIndex;

@property (nonatomic, weak) id<TipViewDelegate> delegate;

@end
