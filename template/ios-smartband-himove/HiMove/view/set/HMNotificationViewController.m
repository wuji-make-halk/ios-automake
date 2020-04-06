//
//  HMNotificationViewController.m
//  HiMove
//
//  Created by 周凯伦 on 2017/5/11.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "HMNotificationViewController.h"
#import "IRKCommonData.h"
#import "MainLoop.h"
//#import "DCRoundSwitch.h"
#import "ConfigTableViewCell.h"


@interface HMNotificationViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView* tableview;
@property(nonatomic,strong)IRKCommonData* commondata;
@property(nonatomic,strong) MainLoop *mainloop;
@end

@implementation HMNotificationViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor =[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.mainloop = [MainLoop SharedInstance];
    [self initNavBar];
    [self initControl];
}
-(void)initNavBar{
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    UIImageView * backimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 22, 18)];
    backimg.image = [UIImage imageNamed:@"icon_back_white.png"];
    backimg.contentMode = UIViewContentModeScaleAspectFit;
    [btn addSubview:backimg];
    [btn addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectZero];
    label.textColor=[UIColor whiteColor];
    label.text=NSLocalizedString(@"Config_Cell_Notification", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}

-(void)onClickBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initControl{
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor=[UIColor clearColor];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.tableview];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* infocellstr = @"notificationCell";
    ConfigTableViewCell *cell = (ConfigTableViewCell*)[tableView dequeueReusableCellWithIdentifier:infocellstr];
    if (cell == nil) {
        cell = [[ConfigTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infocellstr];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor=[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
    }
    
//    DCRoundSwitch *switchview = [[DCRoundSwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
//    switchview.delegate = self;
//    [switchview setOffTintColor:[UIColor whiteColor]];
//    [switchview setOnTintColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];
//    [switchview setOnKnobColor:[UIColor whiteColor]];
//    [switchview setOffKnobColor:[UIColor whiteColor]];
//    
    
    
    UISwitch* switchview = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [switchview setOnTintColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];
    [switchview addTarget:self action:@selector(onClickSwitch:) forControlEvents:UIControlEventValueChanged];
    
    switch (indexPath.row) {
        case 0:{
            cell.textLabel.text = NSLocalizedString(@"Notification_Cell_Incomingcall", nil);
            cell.imageView.image = [UIImage imageNamed:@"icon_notify_phone.png"];
            [switchview setOn:self.commondata.is_enable_incomingcall animated:YES];
            switchview.tag = 1;
        } break;
        case 1:{
            cell.textLabel.text = NSLocalizedString(@"Notification_Cell_SMS", nil);
            cell.imageView.image = [UIImage imageNamed:@"icon_notify_sms.png"];
            [switchview setOn:self.commondata.is_enable_smsnotify animated:YES];
            switchview.tag = 2;
        } break;
        case 2:{
            cell.textLabel.text = NSLocalizedString(@"Notification_Cell_QQ", nil);
            cell.imageView.image = [UIImage imageNamed:@"icon_notify_qq.png"];
            [switchview setOn:self.commondata.is_enable_qqnotify animated:YES];
            switchview.tag=3;
        } break;
        case 3:{
            cell.textLabel.text = NSLocalizedString(@"Notification_Cell_Wechat", nil);
            cell.imageView.image = [UIImage imageNamed:@"icon_notify_wechat.png"];
            [switchview setOn:self.commondata.is_enable_wechatnotify animated:YES];
            switchview.tag=4;
        } break;
        case 4:{
            cell.textLabel.text = NSLocalizedString(@"Notification_Cell_Facebook", nil);
            cell.imageView.image = [UIImage imageNamed:@"icon_notify_facebook.png"];
            [switchview setOn:self.commondata.is_enable_facebooknotify animated:YES];
            switchview.tag=5;
        } break;
        case 5:{
            cell.textLabel.text = NSLocalizedString(@"Notification_Cell_Twitter", nil);
            cell.imageView.image = [UIImage imageNamed:@"icon_notify_twitter.png"];
            [switchview setOn:self.commondata.is_enable_twitternotify animated:YES];
            switchview.tag=6;
        } break;
        case 6:{
            cell.textLabel.text = NSLocalizedString(@"Notification_Cell_Skype", nil);
            cell.imageView.image = [UIImage imageNamed:@"icon_notify_skype.png"];
            [switchview setOn:self.commondata.is_enable_skypenotify animated:YES];
            switchview.tag=7;
        } break;
//        case 7:{
//            cell.textLabel.text = NSLocalizedString(@"Notification_Cell_Line", nil);
//            cell.imageView.image = [UIImage imageNamed:@"icon_notify_line.png"];
//            [switchview setOn:self.commondata.is_enable_linenotify animated:YES];
//            switchview.tag=8;
//        } break;
        case 7:{
            cell.textLabel.text = NSLocalizedString(@"Notification_Cell_Whatsapp", nil);
            cell.imageView.image = [UIImage imageNamed:@"icon_notify_whatsapp.png"];
            [switchview setOn:self.commondata.is_enable_whatsappnotify animated:YES];
            switchview.tag=9;
        } break;
        default: break;
    }
    cell.accessoryView = switchview;
    return cell;
}
- (void)onClickSwitch:(UISwitch*)sender{
    switch (sender.tag) {
        case 1:{
            self.commondata.is_enable_incomingcall = sender.on;
            [self.commondata saveconfig];
            [self.mainloop setNotification:CONTROL_DEVICE_OPTCODE_NONE];
        } break;
        case 2:{
            self.commondata.is_enable_smsnotify = sender.on;
            [self.commondata saveconfig];
            [self.mainloop setNotification:CONTROL_DEVICE_OPTCODE_NONE];
        } break;
        case 3:{
            self.commondata.is_enable_qqnotify = sender.on;
            [self.commondata saveconfig];
            [self.mainloop setNotification:CONTROL_DEVICE_OPTCODE_NONE];
        } break;
        case 4:{
            self.commondata.is_enable_wechatnotify = sender.on;
            [self.commondata saveconfig];
            [self.mainloop setNotification:CONTROL_DEVICE_OPTCODE_NONE];
        } break;
        case 5:{
            self.commondata.is_enable_facebooknotify = sender.on;
            [self.commondata saveconfig];
            [self.mainloop setNotification:CONTROL_DEVICE_OPTCODE_NONE];
        } break;
        case 6:{
            self.commondata.is_enable_twitternotify = sender.on;
            [self.commondata saveconfig];
            [self.mainloop setNotification:CONTROL_DEVICE_OPTCODE_NONE];
        } break;
        case 7:{
            self.commondata.is_enable_skypenotify = sender.on;
            [self.commondata saveconfig];
            [self.mainloop setNotification:CONTROL_DEVICE_OPTCODE_NONE];
        } break;
//        case 8:{
//            self.commondata.is_enable_linenotify = sender.on;
//            [self.commondata saveconfig];
//            [self.mainloop setNotification:CONTROL_DEVICE_OPTCODE_NONE];
//        } break;
        case 9:{
            self.commondata.is_enable_whatsappnotify = sender.on;
            [self.commondata saveconfig];
            [self.mainloop setNotification:CONTROL_DEVICE_OPTCODE_NONE];
        } break;
        default:
        break;
    }
}

//- (void)didSwitchTouchUp:(BOOL)status tagIndex:(NSInteger)tag{
//    switch (tag) {
//        case 1:{
//            self.commondata.is_enable_incomingcall = status;
//            [self.commondata saveconfig];
//            [self.mainloop setNotification];
//        } break;
//        case 2:{
//            self.commondata.is_enable_smsnotify = status;
//            [self.commondata saveconfig];
//            [self.mainloop setNotification];
//        } break;
//        case 3:{
//            self.commondata.is_enable_qqnotify = status;
//            [self.commondata saveconfig];
//            [self.mainloop setNotification];
//        } break;
//        case 4:{
//            self.commondata.is_enable_wechatnotify = status;
//            [self.commondata saveconfig];
//            [self.mainloop setNotification];
//        } break;
//        case 5:{
//            self.commondata.is_enable_facebooknotify = status;
//            [self.commondata saveconfig];
//            [self.mainloop setNotification];
//        } break;
//        case 6:{
//            self.commondata.is_enable_twitternotify = status;
//            [self.commondata saveconfig];
//            [self.mainloop setNotification];
//        } break;
//        case 7:{
//            self.commondata.is_enable_skypenotify = status;
//            [self.commondata saveconfig];
//            [self.mainloop setNotification];
//        } break;
//        case 8:{
//            self.commondata.is_enable_linenotify = status;
//            [self.commondata saveconfig];
//            [self.mainloop setNotification];
//        } break;
//        case 9:{
//            self.commondata.is_enable_whatsappnotify = status;
//            [self.commondata saveconfig];
//            [self.mainloop setNotification];
//        } break;
//        default:
//            break;
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
