//
//  SXRPersonalinfoViewController.h
//  SXRBand
//
//  Created by qf on 14-7-23.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "KLCPopup.h"
#import "SXRNotifyView.h"
#import "MainLoop.h"
#import "ActionSheetCustomPicker.h"
#import "ActionSheetDatePicker.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SXRHeadImageMakerViewController.h"


@interface SXRPersonalinfoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate,SXRNotifyViewDelegate,ActionSheetCustomPickerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,SXRHeadImageMakerDelegate>

@property (nonatomic, strong) IRKCommonData* commondata;
@property (nonatomic, strong) UITableView* tableview;
@property (nonatomic, strong) MainLoop* mainloop;
@property (nonatomic, strong) BleControl* blecontrol;


@end
