//
//  LWClockViewController.h
//  Lovewell
//
//  Created by qf on 14-8-28.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SXRNotifyView.h"
#import "KLCPopup.h"
#import "MainLoop.h"
#import "ActionSheetCustomPicker.h"
#import "ActionSheetDatePicker.h"
#import "Alarm.h"

@interface LWClockViewController : UIViewController
@property (nonatomic, strong)Alarm* alarminfo;
/**
 当前闹钟序号
 */
@property (nonatomic, assign) NSUInteger currentIndex;

@end
