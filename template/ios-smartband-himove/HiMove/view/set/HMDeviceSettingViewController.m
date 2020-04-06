//
//  HMDeviceSettingViewController.m
//  HiMove
//
//  Created by qf on 2017/6/1.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "HMDeviceSettingViewController.h"
#import "ConfigTableViewCell.h"
#import "CZJKOTAViewController.h"
#import "SXRSleepSetViewController.h"
#import "HMHeartTestSetViewController.h"



typedef NS_ENUM(NSInteger, DeviceSettingTag) {
    DeviceSettingAntilost,
    DeviceSettingTurnon,
    DeviceSettingPhoto,
    DeviceSettingMusic,
    DeviceSettingSleepSet,
    DeviceSettingClear,
    DeviceSettingReset,
    DeviceSettingHeart,
    DeviceSettingOTA,
    DeviceSettingAutoHeartrate,
    DeviceSettingAutoTemperature
};

@interface HMDeviceSettingViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic)UITableView* tableview;
@property(nonatomic,strong)BleControl* blecontrol;
@property(nonatomic,strong)MainLoop* mainloop;
@property (strong, nonatomic)IRKCommonData* commondata;
@property(strong,nonatomic)KLCPopup* popup;
@property(strong,nonatomic)NSMutableArray* itemlist;
@end

@implementation HMDeviceSettingViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClearOK:) name:notify_key_clear_ok object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClearErr:) name:notify_key_clear_err object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClearTimeout:) name:notify_key_clear_timeout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTipFactoryOK:) name:@"notify_key_tip_factory_ok" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTipFactoryErr:) name:@"notify_key_tip_factory_err" object:nil];
    [self.tableview reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.mainloop = [MainLoop SharedInstance];
    self.blecontrol = [BleControl SharedInstance];
    self.itemlist = [[NSMutableArray alloc] init];
//    [self.itemlist addObject:@[
//                               @{@"name":NSLocalizedString(@"Config_Cell_Antilost", nil),
//                                 @"image":@"",
//                                 @"type":@"switch",
//                                 @"celltag":[NSNumber numberWithInt:DeviceSettingAntilost],
//                                 @"switchon":[NSNumber numberWithBool:self.commondata.is_enable_antilost]
//                                 }]];
    BOOL autoheart = NO;
    BOOL autotemp = NO;
    NSDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bonginfo) {
        NSNumber* a = [bonginfo objectForKey:BONGINFO_KEY_AUTOHEART];
        if (a && a.intValue>0) {
            autoheart = YES;
        }
        NSNumber* b = [bonginfo objectForKey:BONGINFO_KEY_AUTOTEMP];
        if (b && b.intValue>0) {
            autotemp = YES;
        }
    }
    [self.itemlist addObject:@[
                               @{@"name":NSLocalizedString(@"Config_Cell_Bright_Screen", nil),
                                 @"image":@"",
                                 @"type":@"switch",
                                 @"celltag":[NSNumber numberWithInt:DeviceSettingTurnon],
                                 @"switchon":[NSNumber numberWithBool:self.commondata.is_enable_bringScreen]
                                 }]];
    
    [self.itemlist addObject:@[
                               @{@"name":NSLocalizedString(@"Config_Cell_Auto_Heartrate", nil),
                                 @"image":@"",
                                 @"type":@"switch",
                                 @"celltag":[NSNumber numberWithInt:DeviceSettingAutoHeartrate],
                                 @"switchon":[NSNumber numberWithBool:autoheart]
                                 },
                               @{@"name":NSLocalizedString(@"Config_Cell_Auto_Temprature", nil),
                                 @"image":@"",
                                 @"type":@"switch",
                                 @"celltag":[NSNumber numberWithInt:DeviceSettingAutoTemperature],
                                 @"switchon":[NSNumber numberWithBool:autotemp]
                                 }
                               ]];
   
    [self.itemlist addObject:@[
                               @{@"name":NSLocalizedString(@"Config_Cell_TakePhoto", nil),
                                 @"image":@"",
                                 @"type":@"switch",
                                 @"celltag":[NSNumber numberWithInt:DeviceSettingPhoto],
                                 @"switchon":[NSNumber numberWithBool:self.commondata.is_enable_takephoto]
                                 },
                               @{@"name":NSLocalizedString(@"Config_Cell_Music", nil),
                                 @"image":@"",
                                 @"type":@"switch",
                                 @"celltag":[NSNumber numberWithInt:DeviceSettingMusic],
                                 @"switchon":[NSNumber numberWithBool:self.commondata.is_enable_bongcontrolmusic]}]];
    [self.itemlist addObject:@[
                               @{@"name":NSLocalizedString(@"Config_Cell_Sleep", nil),
                                 @"image":@"",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:DeviceSettingSleepSet]
                                 }]];
//    [self.itemlist addObject:@[
//                               @{@"name":NSLocalizedString(@"heart_test_mode", nil),
//                                 @"image":@"",
//                                 @"type":@"indicate",
//                                 @"celltag":[NSNumber numberWithInt:DeviceSettingHeart]
//                                 }]];
    [self.itemlist addObject:@[
//                               @{@"name":NSLocalizedString(@"Config_Cell_Clear", nil),
//                                 @"image":@"",
//                                 @"type":@"button",
//                                 @"celltag":[NSNumber numberWithInt:DeviceSettingClear],
//                                 @"buttontext":NSLocalizedString(@"setdevice_cleardata", nil)
//                                 },
                               @{@"name":NSLocalizedString(@"Factory_title", nil),
                                 @"image":@"",
                                 @"type":@"button",
                                 @"celltag":[NSNumber numberWithInt:DeviceSettingReset],
                                 @"buttontext":NSLocalizedString(@"setdevice_restore", nil)},
                               @{@"name":NSLocalizedString(@"Config_Cell_OTA", nil),
                                 @"image":@"",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:DeviceSettingOTA]}]];

    [self initNav];
    [self initControl];
}
-(void)initNav{
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    UIImageView * backimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 22, 18)];
    backimg.image = [UIImage imageNamed:@"icon_back_white.png"];
    backimg.contentMode = UIViewContentModeScaleAspectFit;
    [btn addSubview:backimg];
    [btn addTarget:self action:@selector(onClickGoback:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectZero];
    label.textColor=[UIColor whiteColor];
    label.text=NSLocalizedString(@"LeftMenu_Setting", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}
- (void)onClickGoback:(id)sender{
    //    [self.mainloop setConfigParam];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)initControl{
    
    self.view.backgroundColor=[UIColor colorWithRed:0xEE/255.0 green:0xEE/255.0 blue:0xEE/255.0 alpha:1];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-65) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.tableview];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.itemlist count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //    if(section==0) return 4;//个人信息，目标，拍照，蓝牙
    //    else if(section == 1) return 5;//五个开关
    //    else if(section == 2) return 6;
    //    else return 5;//关于
    NSArray* items = [self.itemlist objectAtIndex:section];
    return [items count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray* sectioninfo = [self.itemlist objectAtIndex:indexPath.section];
    NSDictionary* iteminfo = [sectioninfo objectAtIndex:indexPath.row];
    if (iteminfo == nil) {
        return nil;
    }
    NSString* celltype = [iteminfo objectForKey:@"type"];
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:celltype];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celltype];
        if ([celltype isEqualToString:@"indicate"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
        }
        cell.textLabel.textColor=[UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
        //        cell.detailTextLabel.textColor=[UIColor whiteColor];
    }
    cell.textLabel.text = [iteminfo objectForKey:@"name"];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
    cell.tag = [[iteminfo objectForKey:@"celltag"] integerValue];
//    cell.imageView.image = [UIImage imageNamed:[iteminfo objectForKey:@"image"]];
    if ([celltype isEqualToString:@"switch"]) {
        UISwitch* switchview = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        [switchview setOnTintColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];
        [switchview addTarget:self action:@selector(switchTouchUp:) forControlEvents:UIControlEventValueChanged];
        NSNumber* switchon = [iteminfo objectForKey:@"switchon"];
        [switchview setOn:switchon.boolValue animated:NO];
        switchview.tag = [[iteminfo objectForKey:@"celltag"] integerValue];
        cell.accessoryView = switchview;

    }else if([celltype isEqualToString:@"button"]){
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        [btn setBackgroundColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];
        [btn addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:[iteminfo objectForKey:@"buttontext"] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5;
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.titleLabel.minimumScaleFactor = 0.5;
        btn.tag = [[iteminfo objectForKey:@"celltag"] integerValue];
        cell.accessoryView = btn;

    }
    return cell;

}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [self.tableview cellForRowAtIndexPath:indexPath];
    if (cell.tag == DeviceSettingSleepSet || cell.tag == DeviceSettingOTA || cell.tag == DeviceSettingHeart) {
        return YES;
    }
    return NO;
}
-(void)switchTouchUp:(UISwitch*)sender{
    switch (sender.tag) {
        case DeviceSettingAntilost:
            self.commondata.is_enable_antilost = sender.on;
            [self.commondata saveconfig];
            break;
        case DeviceSettingTurnon:
            self.commondata.is_enable_bringScreen = sender.on;
            [self.commondata saveconfig];
            [self.mainloop setConfigParam];
            break;
        case DeviceSettingPhoto:
            self.commondata.is_enable_takephoto = sender.on;
            [self.commondata saveconfig];
            break;
        case DeviceSettingMusic:
            self.commondata.is_enable_bongcontrolmusic = sender.on;
            [self.commondata saveconfig];
            break;
        case DeviceSettingAutoTemperature:{
            NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
            if (bonginfo) {
                if (sender.on) {
                    [bonginfo setObject:[NSNumber numberWithInt:30] forKey:BONGINFO_KEY_AUTOTEMP];
                }else{
                    [bonginfo setObject:[NSNumber numberWithInt:0] forKey:BONGINFO_KEY_AUTOTEMP];
                    
                }
            }
            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
            [self.mainloop sendCmd:[NSString stringWithFormat:@"%@:0",CMD_NOTIFICATION]];
        }
            break;
        case DeviceSettingAutoHeartrate:{
            NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
            if (bonginfo) {
                if (sender.on) {
                    [bonginfo setObject:[NSNumber numberWithInt:30] forKey:BONGINFO_KEY_AUTOHEART];
                }else{
                    [bonginfo setObject:[NSNumber numberWithInt:0] forKey:BONGINFO_KEY_AUTOHEART];
                    
                }
            }
            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
            [self.mainloop sendCmd:[NSString stringWithFormat:@"%@:0",CMD_NOTIFICATION]];

        }
            break;
        default:
            break;
    }

}

-(void)onClickBtn:(UIButton*)sender{
    switch (sender.tag) {
        case DeviceSettingClear:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected){
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
            }else{
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Clear_Confirm_hm", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"Delete", nil), nil];
                alerview.tag = 500;
                [alerview show];
            }

        }
            
            break;
        case DeviceSettingReset:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected){
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
            }else{
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Factory_title", nil) message:NSLocalizedString(@"Factory_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL",nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                alert.tag = 1001;
                [alert show];
            }

        }
            break;
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [self.tableview cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case DeviceSettingOTA:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];

            }else{
                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[CZJKOTAViewController new]];
                [self presentViewController:navi animated:YES completion:nil];
            }
        }
            break;
        case DeviceSettingSleepSet:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
            }else{
                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SXRSleepSetViewController new]];
                [self presentViewController:navi animated:YES completion:nil];
            }
        }
            break;
        case DeviceSettingHeart:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
            }else{
                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[HMHeartTestSetViewController new]];
                [self presentViewController:navi animated:YES completion:nil];
            }
         
        }
         default:
            break;
    }
 }


#pragma mark --------TakePhoto Method--------

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100){
        if (buttonIndex != alertView.cancelButtonIndex) {
            BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
            if (canOpenSettings)
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }else if (alertView.tag == 500){
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self showPop:NSLocalizedString(@"Clear_ing", nil)];
            [self.mainloop Start_clear];
        }
    }
    else if (alertView.tag==1001) {
        if (buttonIndex!= alertView.cancelButtonIndex) {
            if (self.blecontrol.is_connected != IRKConnectionStateConnected){
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
                return;
            }
            self.commondata.is_in_factory=YES;
            [self.commondata saveconfig];
            [self.mainloop setNotification:CONTROL_DEVICE_OPTCODE_RESET];
            
        }
    }
}

-(void)showPop:(NSString*)str{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    if(self.popup){
        [KLCPopup dismissAllPopups];
        self.popup = nil;
    }
    self.popup = [KLCPopup popupWithContentView:label showType:KLCPopupShowTypeNone dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeClear dismissOnBackgroundTouch:NO dismissOnContentTouch:YES];
    label.text = str;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    KLCPopupLayout lay= KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutBottom);
    [self.popup showWithLayout:lay];
}


-(void)onClearOK:(NSNotification*)notify{
    [KLCPopup dismissAllPopups];
    //    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Clear_OK", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    //    [alertview show];
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_clear_all_data object:nil];
}

-(void)onClearErr:(NSNotification*)notify{
    [KLCPopup dismissAllPopups];
    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Clear_Failed", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertview show];
}

-(void)onClearTimeout:(NSNotification*)notify{
    NSLog(@"onClearTimeout");
    [KLCPopup dismissAllPopups];
    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Clear_Failed", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertview show];
}

-(void)onTipFactoryOK:(NSNotification*)notify{
    UIAlertController* ac = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Factory_Succeed", nil) preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}
-(void)onTipFactoryErr:(NSNotification*)notify{
    UIAlertController* ac = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Factory_Fail", nil) preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
