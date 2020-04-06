//
//  SXRConfigViewController.h
//  SXRBand
//
//  Created by qf on 14-7-23.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "RESideMenu.h"

typedef enum {
    ConfigCellEventAntiLost,
    ConfigCellEventIncomingCall,
    ConfigCellEventWhatsApp,
//    ConfigCellEventMail,
//#ifndef CUSTOM_FITBAND
    ConfigCellEventMusicControl,
//#endif
//    ConfigCellEventIncomingCall,
//    ConfigCellEventReminderAlarm,
//    ConfigCellEventSms,
    ConfigCellEventCallPhone,
    ConfigCellEventOTA,
    ConfigCellEventVibration,
    ConfigCellEventTakePhoto,

    ConfigCellClockSet,
    ConfigCellDrinkSet,
    
    ConfigCellLongSit,
    ContigCellSleepSet,
    ConfigCellBellSet,
    ConfigCellClearData,
    ConfigCellScreenTime,

    ConfigCellEventUserManual,
    ConfigCellEventOTANodic,
    ConfigCellEventBrightScreen,
    ConfigCellEventNotify,
    ConfigCellEventGoalSeting
    
}ConfigCellEvent;
@interface SXRConfigViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic)UITableView* tableview;

@end
