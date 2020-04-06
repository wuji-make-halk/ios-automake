//
//  FRAboutViewController.h
//  SXRBand
//
//  Created by qf on 16/4/19.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface FRAboutViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) IRKCommonData* commondata;
@property (nonatomic, strong) UITableView* tableview;


@end
