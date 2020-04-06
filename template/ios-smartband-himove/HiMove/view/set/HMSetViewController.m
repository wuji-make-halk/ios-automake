//
//  HMSetViewController.m
//  CZJKBand
//
//  Created by 周凯伦 on 17/3/15.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "HMSetViewController.h"
#import "CommonDefine.h"
#import "IRKCommonData.h"
#import "BleControl.h"
#import "MainLoop.h"
#import "SXRPersonalinfoViewController.h"
#import "FRTargetSetViewController.h"
#import "SXRPhoto2ViewController.h"
#import "YFTDeviceViewController.h"
#import "SXRClockListViewController.h"
#import "SXRDrinkViewController.h"
#import "SXRSleepSetViewController.h"
#import "FRAboutViewController.h"
#import "CZJKOTAViewController.h"
#import "SXRUsermanualViewController.h"
#import "SWDisturbViewController.h"
#import "HMHeartTestSetViewController.h"
#import "HMNotificationViewController.h"
#import "HMDeviceSettingViewController.h"
#import "SXRSedentaryViewController.h"
#import "ConfigTableViewCell.h"
#import <HealthKit/HealthKit.h>
#import "HMHealthKitViewController.h"

#import "KLCPopup.h"
#import "DCRoundSwitch.h"
typedef NS_ENUM(NSInteger, SettingCellTag) {
    SettingPerson,
    SettingTarget,
    SettingMyDevice,
    SettingDevice,
    SettingAncs,
    SettingClock,
    SettingDrink,
    SettingSedentary,
    SettingDisturb,
    SettingManual,
    SettingHealthKit,
    SettingAbout
};


@interface HMSetViewController ()<UITableViewDataSource, UITableViewDelegate,DCRoundSwitchDelegate>
@property (strong, nonatomic)UITableView* tableview;
@property(nonatomic,strong)BleControl* blecontrol;
@property(nonatomic,strong)MainLoop* mainloop;
@property (strong, nonatomic)IRKCommonData* commondata;
@property(strong,nonatomic)KLCPopup* popup;
@property(strong,nonatomic)NSMutableArray* itemlist;
@end

@implementation HMSetViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTakePhoto:) name:notify_key_take_photo object:nil];//手环控制手机拍照
    
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
    [self.itemlist addObject:@[
                               @{@"name":NSLocalizedString(@"LeftMenu_Person", nil),
                                 @"image":@"icon_setting_person.png",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:SettingPerson]
                                   },
                               @{@"name":NSLocalizedString(@"LeftMenu_TargetSet", nil),
                                 @"image":@"icon_setting_target.png",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:SettingTarget]}]];
    [self.itemlist addObject:@[
                               @{@"name":NSLocalizedString(@"Menu_BleDevices", nil),
                                 @"image":@"icon_setting_ble.png",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:SettingMyDevice]
                                 },
                               @{@"name":NSLocalizedString(@"LeftMenu_Setting", nil),
                                 @"image":@"icon_setting_device.png",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:SettingDevice]}]];
    [self.itemlist addObject:@[
                               @{@"name":NSLocalizedString(@"Config_Cell_Notification", nil),
                                 @"image":@"icon_setting_ancs.png",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:SettingAncs]
                                 },
                               @{@"name":NSLocalizedString(@"Config_Cell_Clock", nil),
                                 @"image":@"icon_setting_clock.png",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:SettingClock]},
                               @{@"name":NSLocalizedString(@"Config_Cell_Drink", nil),
                                 @"image":@"icon_setting_drink.png",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:SettingDrink]},
                               @{@"name":NSLocalizedString(@"Config_Cell_Longsit", nil),
                                 @"image":@"icon_setting_sedentary.png",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:SettingSedentary]},
                               @{@"name":NSLocalizedString(@"Config_Cell_NoDisturb", nil),
                                 @"image":@"icon_setting_disturb.png",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:SettingDisturb]}]];
    //////////for healthkit/////////////
    [self.itemlist addObject:@[
                               @{@"name":NSLocalizedString(@"Config_Cell_HealthKit", nil),
                                 @"image":@"icon_setting_healthkit.png",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:SettingHealthKit]
                                 }]];
    [self.itemlist addObject:@[
                               @{@"name":NSLocalizedString(@"Config_Cell_UserManual", nil),
                                 @"image":@"icon_setting_help.png",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:SettingManual]
                                 },
                               @{@"name":NSLocalizedString(@"LeftMenu_About", nil),
                                 @"image":@"icon_setting_about.png",
                                 @"type":@"indicate",
                                 @"celltag":[NSNumber numberWithInt:SettingAbout]}]];
    
    [self initNav];
    [self initControl];
}
-(void)initNav{
    UIView* logoview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    UIImageView* imgview = [[UIImageView alloc]init];
    imgview.frame=CGRectMake(0, 5, 40 , 40);
    imgview.image = [UIImage imageNamed:@"icon_bs_logo.png"];
    imgview.contentMode = UIViewContentModeScaleAspectFit;
    [logoview addSubview:imgview];
    UILabel *logoLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgview.frame)+5, 5, 200, 40)];
    logoLabel.text=@"Hi Move";
    logoLabel.textColor=[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1];
    [logoview addSubview:logoLabel];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoview];
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
    NSString* infocellstr = @"configCell";
    ConfigTableViewCell *cell = (ConfigTableViewCell*)[tableView dequeueReusableCellWithIdentifier:infocellstr];
    if (cell == nil) {
        cell = [[ConfigTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infocellstr];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor=[UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
//        cell.detailTextLabel.textColor=[UIColor whiteColor];
    }
    cell.textLabel.text = [iteminfo objectForKey:@"name"];
    cell.tag = [[iteminfo objectForKey:@"celltag"] integerValue];
    cell.imageView.image = [UIImage imageNamed:[iteminfo objectForKey:@"image"]];
    return cell;
//    
//    if (indexPath.section==0) {
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        switch (indexPath.row) {
//            case 0:cell.textLabel.text = NSLocalizedString(@"LeftMenu_Person", nil); break;
//            case 1:cell.textLabel.text = NSLocalizedString(@"LeftMenu_TargetSet", nil); break;
//            case 2:cell.textLabel.text = NSLocalizedString(@"Menu_TakePhoto", nil); break;
//            case 3:cell.textLabel.text = NSLocalizedString(@"Menu_BleDevices", nil); break;
//            default: break;
//        }
//        return cell;
//    }else if (indexPath.section==1){
//        cell.accessoryType=UITableViewCellAccessoryNone;
//        DCRoundSwitch *switchview = [[DCRoundSwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
//        switchview.delegate = self;
//        [switchview setOffTintColor:[UIColor colorWithRed:0/255.0 green:2/255.0 blue:60/255.0 alpha:1.0f]];
//        [switchview setOnTintColor:[UIColor colorWithRed:0/255.0 green:2/255.0 blue:60/255.0 alpha:1.0f]];
//        [switchview setOnKnobColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0]];
//        [switchview setOffKnobColor:[UIColor colorWithRed:0/255.0 green:2/255.0 blue:60/255.0 alpha:1.0f]];
//        //UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
//        //[switchview setOnTintColor:[UIColor greenColor]];
//        //[switchview addTarget:self action:@selector(switchTouchUp:) forControlEvents:UIControlEventValueChanged];
//        switch (indexPath.row) {
//            case 0:{
//                cell.textLabel.text = NSLocalizedString(@"Config_Cell_Antilost", nil);
//                [switchview setOn:self.commondata.is_enable_antilost animated:YES];
//                switchview.tag = 1;
//            } break;
//            case 1:{
//                cell.textLabel.text = NSLocalizedString(@"Config_Cell_DeviceCall", nil);
//                [switchview setOn:self.commondata.is_enable_devicecall animated:YES];
//                switchview.tag = 2;
//            } break;
//            case 2:{
//                cell.textLabel.text = NSLocalizedString(@"Config_Cell_Music", nil);
//                [switchview setOn:self.commondata.is_enable_bongcontrolmusic animated:YES];
//                switchview.tag=3;
//            } break;
//            case 3:{
//                cell.textLabel.text = NSLocalizedString(@"Config_Cell_TakePhoto", nil);
//                [switchview setOn:self.commondata.is_enable_takephoto animated:YES];
//                switchview.tag=4;
//            } break;
//            case 4:{
//                cell.textLabel.text = NSLocalizedString(@"Config_Cell_Bright_Screen", nil);
//                [switchview setOn:self.commondata.is_enable_bringScreen animated:YES];
//                switchview.tag=5;
//            } break;
//            default: break;
//        }
//        cell.accessoryView = switchview;
//        return cell;
//    }else if (indexPath.section==2){
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        switch (indexPath.row) {
//            case 0:{
//                cell.textLabel.text = NSLocalizedString(@"Config_Cell_AutoHeart", nil);
//                if (self.commondata.is_enable_autoheart) cell.detailTextLabel.text=NSLocalizedString(@"AutoHeart_Auto", nil);
//                else cell.detailTextLabel.text=NSLocalizedString(@"AutoHeart_Manual", nil);
//            } break;
//            case 1:cell.textLabel.text = NSLocalizedString(@"Config_Cell_Notification", nil); break;
//            case 2:cell.textLabel.text = NSLocalizedString(@"Config_Cell_Clock", nil); break;
//            case 3:cell.textLabel.text = NSLocalizedString(@"Config_Cell_Drink", nil); break;
//            case 4:cell.textLabel.text = NSLocalizedString(@"Config_Cell_Sleep", nil); break;
//            case 5:cell.textLabel.text = NSLocalizedString(@"Config_Cell_NoDisturb", nil); break;
//            default: break;
//        }
//        return cell;
//    }else{
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        switch (indexPath.row) {
//            case 0:cell.textLabel.text = NSLocalizedString(@"LeftMenu_About", nil); break;
//            case 1:cell.textLabel.text = NSLocalizedString(@"Config_Cell_OTA", nil); break;
//            case 2:cell.textLabel.text = NSLocalizedString(@"Config_Cell_Clear", nil); break;
//            case 3:cell.textLabel.text = NSLocalizedString(@"Config_Cell_UserManual", nil); break;
//            case 4:cell.textLabel.text = NSLocalizedString(@"恢复出厂设置", nil); break;
//            default: break;
//        }
//        cell.accessoryView = nil;
//        return cell;
//    }
//    return cell;
}

//- (void)didSwitchTouchUp:(BOOL)status tagIndex:(NSInteger)tag{
//    switch (tag) {
//        case 1:{
//            self.commondata.is_enable_antilost = status;
//            [self.commondata saveconfig];
//            [self.mainloop setConfigParam];
//        } break;
//        case 2:{
//            self.commondata.is_enable_devicecall = status;
//            [self.commondata saveconfig];
//        } break;
//        case 3:{
//            self.commondata.is_enable_bongcontrolmusic = status;
//            [self.commondata saveconfig];
//        } break;
//        case 4:{
//            self.commondata.is_enable_takephoto = status;
//            [self.commondata saveconfig];
//        } break;
//        case 5:{
//            self.commondata.is_enable_bringScreen = status;
//            [self.commondata saveconfig];
//            [self.mainloop setConfigParam];
//        } break;
//        default:
//            break;
//    }
//}

//-(void) switchTouchUp:(id)sender{
//    UISwitch * switchview = (UISwitch*)sender;
//    switch (switchview.tag) {
//        case 1:{
//            self.commondata.is_enable_antilost = switchview.on;
//            [self.commondata saveconfig];
//            [self.mainloop setConfigParam];
//        } break;
//        case 2:{
//            self.commondata.is_enable_devicecall = switchview.on;
//            [self.commondata saveconfig];
//        } break;
//        case 3:{
//            self.commondata.is_enable_bongcontrolmusic = switchview.on;
//            [self.commondata saveconfig];
//        } break;
//        case 4:{
//            self.commondata.is_enable_takephoto = switchview.on;
//            [self.commondata saveconfig];
//        } break;
//        case 5:{
//            if (self.blecontrol.is_connected != IRKConnectionStateConnected){
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"OTA_Error_No_Ble_connect", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//                alertview.tag = 2000;
//                [alertview show];
//            }else{
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Need_Sync_Band", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
//                alertview.tag = 2002;
//                [alertview show];
//            }
//        } break;
//        default:
//            break;
//    }
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [self.tableview cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case SettingPerson:{//个人信息设置
            UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SXRPersonalinfoViewController new]];
            [self presentViewController:navi animated:YES completion:nil];
        }
            break;
        case SettingTarget:{
            UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[FRTargetSetViewController new]];
            [self presentViewController:navi animated:YES completion:nil];
        }
            break;
        case SettingMyDevice:{
            UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[YFTDeviceViewController new]];
            [self presentViewController:navi animated:YES completion:nil];
        }
            break;
        case SettingDevice:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
            }else{
                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[HMDeviceSettingViewController new]];
                [self presentViewController:navi animated:YES completion:nil];
            }
        }
            break;
        case SettingAncs:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
            }else{
                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[HMNotificationViewController new]];
                [self presentViewController:navi animated:YES completion:nil];
            }
        }
            break;
        case SettingClock:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
            }else{
                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SXRClockListViewController new]];
                [self presentViewController:navi animated:YES completion:nil];
            }
        }
            break;
        case SettingDrink:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
            }else{
                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SXRDrinkViewController new]];
                [self presentViewController:navi animated:YES completion:nil];
            }
        }
            break;
        case SettingSedentary:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
            }else{
                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SXRSedentaryViewController new]];
                [self presentViewController:navi animated:YES completion:nil];
            }
        }
            break;
        case SettingDisturb:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
            }else{
                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SWDisturbViewController new]];
                [self presentViewController:navi animated:YES completion:nil];
            }
        }
            break;
        case SettingManual:{
            UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SXRUsermanualViewController new]];
            [self presentViewController:navi animated:YES completion:nil];
        }
            break;
        case SettingAbout:{
            UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[FRAboutViewController new]];
            [self presentViewController:navi animated:YES completion:nil];
        }
            break;
            //////////for healthkit/////////////
        case SettingHealthKit:{
            if ([HKHealthStore isHealthDataAvailable]) {
                HKHealthStore *healthStore = [[HKHealthStore alloc] init];
                __block NSMutableSet *writeObjectTypes = [[NSMutableSet alloc] init];
//                NSLog(@"%@",HKWorkoutTypeIdentifier);
                [[IRKCommonData SharedInstance].healthkitArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString* name = (NSString*)obj;
                    if ([name hasPrefix:@"HKWorkout"]) {
                        HKObjectType* type = [HKObjectType workoutType];
                        if (type != nil) {
                            [writeObjectTypes addObject:type];
                        }
                    }else if ([name hasPrefix:@"HKCategory"]){
                        HKCategoryType* type = [HKCategoryType categoryTypeForIdentifier:name];
                        if (type != nil) {
                            [writeObjectTypes addObject:type];
                        }
                    }
                    else{
                        HKObjectType* type = [HKObjectType quantityTypeForIdentifier:name];
                        if (type != nil) {
                            [writeObjectTypes addObject:type];
                        }
                    }
                    
                }];
                
                if (writeObjectTypes.count) {
                    [healthStore requestAuthorizationToShareTypes:writeObjectTypes readTypes:nil completion:^(BOOL success, NSError *error) {
                        if (success == YES)  {
                            //授权成功
                        } else {
                            //授权失败
                        }
                    }];
                    
                }
            }
            UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[HMHealthKitViewController new]];
            [self presentViewController:navi animated:YES completion:nil];
           
        }
            break;
        default:
            break;
    }
//    if (indexPath.section==0) {
//        switch (indexPath.row) {
//            case 0:{//个人信息设置
//                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SXRPersonalinfoViewController new]];
//                [self presentViewController:navi animated:YES completion:nil];
//            } break;
//            case 1:{//目标设置
//                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[FRTargetSetViewController new]];
//                [self presentViewController:navi animated:YES completion:nil];
//            } break;
//            case 2:[self takePhoto]; break;//手机拍照
//            case 3:{//蓝牙设备
//                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[YFTDeviceViewController new]];
//                [self presentViewController:navi animated:YES completion:nil];
//            } break;
//            default: break;
//        }
//    }else if (indexPath.section==1){
//        
//    }else if (indexPath.section==2){
//        switch (indexPath.row) {
//            case 0:{//心率检测设置
//                if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//                    UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                    [alerview show];
//                }else{
//                    UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[HMHeartTestSetViewController new]];
//                    [self presentViewController:navi animated:YES completion:nil];
//                }
//            } break;
//            case 1:{//消息提醒设置
//                if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//                    UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                    [alerview show];
//                }else{
//                    UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[HMNotificationViewController new]];
//                    [self presentViewController:navi animated:YES completion:nil];
//                }
//            } break;
//            case 2:{//闹钟提醒
//                if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//                    UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                    [alerview show];
//                }else{
//                    UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SXRClockListViewController new]];
//                    [self presentViewController:navi animated:YES completion:nil];
//                }
//            } break;
//            case 3:{//饮水设置
//                if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//                    UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                    [alerview show];
//                }else{
//                    UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SXRDrinkViewController new]];
//                    [self presentViewController:navi animated:YES completion:nil];
//                }
//            } break;
//            case 4:{//睡眠偏好
//                if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//                    UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                    [alerview show];
//                }else{
//                    UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SXRSleepSetViewController new]];
//                    [self presentViewController:navi animated:YES completion:nil];
//                }
//            } break;
//            case 5:{//勿扰模式
//                if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//                    UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                    [alerview show];
//                }else{
//                    UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SWDisturbViewController new]];
//                    [self presentViewController:navi animated:YES completion:nil];
//                }
//            } break;
//            default: break;
//        }
//    }else{
//        switch (indexPath.row) {
//            case 0:{//关于
//                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[FRAboutViewController new]];
//                [self presentViewController:navi animated:YES completion:nil];
//            } break;
//            case 1:{//手环更新
//                if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//                    UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                    [alerview show];
//                    
//                }else{
//                    UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[CZJKOTAViewController new]];
//                    [self presentViewController:navi animated:YES completion:nil];
//                }
//            } break;
//            case 2:{//清除数据
//                if (self.blecontrol.is_connected != IRKConnectionStateConnected){
//                    UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                    [alerview show];
//                }else{
//                    UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Clear_Confirm_hm", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"Delete", nil), nil];
//                    alerview.tag = 500;
//                    [alerview show];
//                }
//            } break;
//            case 3:{//用户手册
//                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[SXRUsermanualViewController new]];
//                [self presentViewController:navi animated:YES completion:nil];
//            } break;
//            case 4:{
//                if (self.blecontrol.is_connected != IRKConnectionStateConnected){
//                    UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                    [alerview show];
//                }else{
//                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Factory_title", nil) message:NSLocalizedString(@"Factory_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL",nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                    alert.tag = 1001;
//                    [alert show];
//                }
//            } break;
//            default: break;
//        }
//    }
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([cell respondsToSelector:@selector(tintColor)]) {
//        CGFloat cornerRadius = 10.f;
//        cell.backgroundColor = UIColor.clearColor;
//        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
//        CGMutablePathRef pathRef = CGPathCreateMutable();
//        CGRect bounds = CGRectInset(cell.bounds, 10, 0);
//        BOOL addLine = NO;
//        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
//        } else if (indexPath.row == 0) {
//            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
//            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
//            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
//            addLine = YES;
//        } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
//            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
//            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
//        } else {
//            CGPathAddRect(pathRef, nil, bounds);
//            addLine = YES;
//        }
//        layer.path = pathRef;
//        CFRelease(pathRef);
//        //颜色修改
//        layer.fillColor = [UIColor colorWithRed:0x74/255.0 green:0xb7/255.0 blue:0xec/255.0 alpha:1].CGColor;//[UIColor colorWithWhite:1.f alpha:0.5f].CGColor;
//        layer.strokeColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1].CGColor;//[UIColor whiteColor].CGColor;
//        if (addLine == YES) {
//            CALayer *lineLayer = [[CALayer alloc] init];
//            CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
//            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height-lineHeight, bounds.size.width, lineHeight);
//            lineLayer.backgroundColor = [UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1].CGColor;//tableView.separatorColor.CGColor;
//            [layer addSublayer:lineLayer];
//        }
//        UIView *testView = [[UIView alloc] initWithFrame:bounds];
//        [testView.layer insertSublayer:layer atIndex:0];
//        testView.backgroundColor = UIColor.clearColor;
//        cell.backgroundView = testView;
//    }
//}

#pragma mark --------TakePhoto Method--------
//-(void)onTakePhoto:(NSNotification*)notify{
//    NSLog(@"TakePhoto::");
//    if(self.commondata.is_enable_takephoto)
//        [self takePhoto];
//}
//
//-(void)takePhoto{
//    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    if(authStatus == AVAuthorizationStatusAuthorized) {
//        if ([[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController isKindOfClass:[SXRPhoto2ViewController class]] == NO){
//            [self performSelectorOnMainThread:@selector(openCamera) withObject:nil waitUntilDone:YES];
//            
//        }else{
//            
//        }
//    }else if(authStatus == AVAuthorizationStatusNotDetermined){
//        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//            if(granted){
//                
//                if ([[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController isKindOfClass:[SXRPhoto2ViewController class]] == NO){
//                    
//                    [self performSelectorOnMainThread:@selector(openCamera) withObject:nil waitUntilDone:YES];
//                }
//                
//            } else {
//                NSLog(@"Not granted access");
//            }
//        }];
//    }else{
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Camera_Denied", nil) message:NSLocalizedString(@"Camera_Denied_Tip", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL",nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//        alert.tag = 100;
//        [alert show];
//    }
//}
//
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
//    if (alertView.tag == 100){
//        if (buttonIndex != alertView.cancelButtonIndex) {
//            BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
//            if (canOpenSettings)
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//        }
//    }else if (alertView.tag == 500){
//        if (buttonIndex != alertView.cancelButtonIndex) {
//            [self showPop:NSLocalizedString(@"Clear_ing", nil)];
//            [self.mainloop Start_clear];
//        }
//    }
//    else if (alertView.tag==1001) {
//        if (buttonIndex!= alertView.cancelButtonIndex) {
//            if (self.blecontrol.is_connected != IRKConnectionStateConnected){
//                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                [alerview show];
//                return;
//            }
//            self.commondata.is_in_factory=YES;
//            [self.commondata saveconfig];
//            [self.mainloop setNotification::CONTROL_DEVICE_OPTCODE_RESET];
//            
//        }
//    }
//}

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


//-(void)openCamera{
//    SXRPhoto2ViewController* vc = [[SXRPhoto2ViewController alloc] init];
//    AppDelegate *appdelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
////    appdelegate.window.rootViewController=vc;
//    [appdelegate.window.rootViewController presentViewController:vc animated:YES completion:nil];
//}

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
