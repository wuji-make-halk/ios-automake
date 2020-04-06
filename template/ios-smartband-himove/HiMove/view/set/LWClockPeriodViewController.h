//
//  LWClockPeriodViewController.h
//  Lovewell
//
//  Created by qf on 14-8-28.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"

@interface LWClockPeriodViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)IRKCommonData* commondata;
@property (nonatomic, strong)UITableView* tableview;
@property int period;
@property (nonatomic, strong)Alarm* alarminfo;
@end
