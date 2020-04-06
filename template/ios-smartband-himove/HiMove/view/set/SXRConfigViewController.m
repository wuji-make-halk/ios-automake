//
//  SXRConfigViewController.m
//  SXRBand
//
//  Created by qf on 14-7-23.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "SXRConfigViewController.h"
#import "BleControl.h"
#import "MainLoop.h"
#import "KLCPopup.h"

#import "DCRoundSwitch.h"
#import "IRKCommonData.h"
#import "CommonDefine.h"

@interface SXRConfigViewController ()<UIAlertViewDelegate,DCRoundSwitchDelegate>
@property(nonatomic,strong)BleControl* blecontrol;
@property(nonatomic,strong)MainLoop* mainloop;
@property(strong,nonatomic)KLCPopup* popup;
@property(strong,nonatomic)NSTimer* popontime;
@property(nonatomic,strong)NSManagedObjectContext* context;
@property(nonatomic,strong)NSArray* fetchArrar;
@property(nonatomic,strong)ServerLogic* serverlogic;
@property(nonatomic,strong) IRKCommonData *commondata;
@property(nonatomic, assign)NSInteger valueChanged;
@end

@implementation SXRConfigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClearOK:) name:notify_key_clear_ok object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClearErr:) name:notify_key_clear_err object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClearTimeout:) name:notify_key_clear_timeout object:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.mainloop = [MainLoop SharedInstance];
    self.blecontrol = [BleControl SharedInstance];
    self.serverlogic = [ServerLogic SharedInstance];
    
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.context = delegate.managedObjectContext;
    [self initcontrol];
}



-(void)initcontrol{
    self.navigationController.navigationBar.barTintColor = self.commondata.colorNav;
    [self.navigationController.navigationBar setTranslucent:NO];
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn setImage:[UIImage imageNamed:@"icon_pz_menu.png"] forState:UIControlStateNormal];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btn setImageEdgeInsets:UIEdgeInsetsMake(2.5, 0, 2.5, 5)];
    [btn addTarget:self action:@selector(onClickMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    NSMutableParagraphStyle* p = [NSMutableParagraphStyle new];
    p.alignment = NSTextAlignmentCenter;
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Device_Config_Title", nil) attributes:@{NSFontAttributeName: [self.commondata getFontbySize:18 isBold:NO], NSParagraphStyleAttributeName: p}];
    
    UILabel* titleview = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, str.size.width, str.size.height)];
    titleview.attributedText = str;
    titleview.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleview;
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-65) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    UIImageView* backView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [backView setBackgroundColor:[UIColor clearColor]];
    backView.image = [UIImage imageNamed:@"icon_hm_about_background"];
    backView.contentMode = UIViewContentModeScaleToFill;
    self.tableview.backgroundView = backView;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableview];
}

-(void)onClickMenu:(id)sender{
    //[self.sideMenuViewController presentLeftMenuViewController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 6;
    }else if(section == 1){
        return 3;
    }else{
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    static NSString* checkbox = @"CheckBoxCell";
    static NSString* cellid = @"SimpleCell";
    if (section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:checkbox];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:checkbox];
            
        }
        DCRoundSwitch *switchview = [[DCRoundSwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        switchview.delegate = self;
        [switchview setOffTintColor:[UIColor colorWithRed:0/255.0 green:2/255.0 blue:60/255.0 alpha:1.0f]];
        [switchview setOnTintColor:[UIColor colorWithRed:0/255.0 green:2/255.0 blue:60/255.0 alpha:1.0f]];
        
        [switchview setOnKnobColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0]];
        [switchview setOffKnobColor:[UIColor colorWithRed:0/255.0 green:2/255.0 blue:60/255.0 alpha:1.0f]];
        cell.backgroundColor = [UIColor colorWithRed:102/255.0f green:153/255.0f blue:255/255.0f alpha:0.3f];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        switchview.userInteractionEnabled = YES;

        cell.layer.cornerRadius = 0;
        cell.textLabel.font = [self.commondata getFontbySize:16 isBold:NO];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.minimumScaleFactor = 0.5;
        cell.textLabel.numberOfLines = 0;
        
        switch (row) {
            case 0:{
                cell.textLabel.text = NSLocalizedString(@"Home_Tableview_Goals", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.layer.cornerRadius = 0;
                cell.textLabel.font = [self.commondata getFontbySize:16 isBold:NO];
                cell.tag = ConfigCellEventGoalSeting;
            }
                break;
                
            case 1:
                [switchview setOn:self.commondata.is_enable_antilost animated:YES];
                switchview.tag = ConfigCellEventAntiLost;
                cell.tag = ConfigCellEventAntiLost;
                cell.textLabel.text = NSLocalizedString(@"Config_Cell_Antilost", nil);
                break;
            case 2:
                [switchview setOn:self.commondata.is_enable_devicecall animated:YES];
                switchview.tag = ConfigCellEventCallPhone;
                
                cell.tag = ConfigCellEventCallPhone;
                cell.textLabel.text = NSLocalizedString(@"Config_Cell_DeviceCall", nil);
                break;
            case 3:
                [switchview setOn:self.commondata.is_enable_bongcontrolmusic animated:YES];
                switchview.tag = ConfigCellEventMusicControl;
                cell.tag = ConfigCellEventMusicControl;
                cell.textLabel.text = NSLocalizedString(@"Config_Cell_Music", nil);
                break;
                
            case 5:
                //震动
                [switchview setOn:self.commondata.is_enable_lowbatteryalarm animated:YES];
                switchview.tag = ConfigCellEventVibration;
                cell.tag = ConfigCellEventVibration;
                cell.textLabel.text = NSLocalizedString(@"Config_Cell_Viberation", nil);
                //                cell.hidden = YES;
                break;
            case 4:
                //拍照
                [switchview setOn:self.commondata.is_enable_takephoto animated:YES];
                switchview.tag = ConfigCellEventTakePhoto;
                cell.tag = ConfigCellEventTakePhoto;
                cell.textLabel.text = NSLocalizedString(@"Config_Cell_TakePhoto", nil);
                //                cell.hidden = YES;
                break;
        }
        //新增目标设置
        if (row!=0) {
            cell.accessoryView = switchview;
        }
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        return cell;
    }
    else if (section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:checkbox];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:checkbox];
        }
        cell.backgroundColor = [UIColor colorWithRed:102/255.0f green:153/255.0f blue:255/255.0f alpha:0.3f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.textLabel setTextColor: [UIColor whiteColor]];
        cell.layer.cornerRadius = 0;
        cell.textLabel.font = [self.commondata getFontbySize:16 isBold:NO];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        switch (row) {
            case 0:
                cell.tag = ConfigCellClockSet;
                cell.textLabel.text = NSLocalizedString(@"Config_Cell_Clock", nil);
                //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
                break;
            case 1:
                cell.tag = ConfigCellDrinkSet;
                cell.textLabel.text = NSLocalizedString(@"Config_Cell_Drink", nil);
                //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            case 2:
                cell.tag = ContigCellSleepSet;
                cell.textLabel.text = NSLocalizedString(@"Config_Cell_Sleep", nil);
                //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            case 3:
                cell.tag = ConfigCellBellSet;
                cell.textLabel.text = NSLocalizedString(@"Config_Cell_Bell", nil);
                //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
//            case 0:
//                cell.tag = ConfigCellEventNotify;
//                cell.textLabel.text = NSLocalizedString(@"Config_Cell_Notification", nil);
//                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            default:
                break;
         }
        


        return cell;
        
    }
    else if(section == 2){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
        }
        cell.textLabel.font = [self.commondata getFontbySize:16 isBold:NO];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:102/255.0f green:153/255.0f blue:255/255.0f alpha:0.3f];
        [cell.textLabel setTextColor: [UIColor whiteColor]];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        switch (row) {
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Config_Cell_UserManual", nil);
                cell.tag = ConfigCellEventUserManual;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 0:{
                cell.textLabel.text = NSLocalizedString(@"Config_Cell_OTA", nil);
                cell.tag = ConfigCellEventOTANodic;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 1:{
                cell.textLabel.text = NSLocalizedString(@"Config_Cell_CLEARDATA", nil);
                cell.tag = ConfigCellClearData;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
                
            default:
                break;
        }
        return cell;
        
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath");
    //该方法响应列表中行的点击事件
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case ConfigCellEventUserManual:{
            [self performSegueWithIdentifier:@"ConfigUsermanualSegue" sender:self];//SXRUsermanualViewController
            break;
        }
        case ConfigCellEventGoalSeting:
        {
            [self performSegueWithIdentifier:@"PZGoalSetting" sender:self];//FRTargetSetViewController
            break;
        }

 
        case ConfigCellEventOTA:
        {
            [self performSegueWithIdentifier:@"OTASegue" sender:self];
            break;
        }
        case ConfigCellClockSet:
        {
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
            
            }else{
                [self performSegueWithIdentifier:@"clockSegue" sender:self];//SXRClockListViewController
            }
            break;
        }
        case ConfigCellDrinkSet:
        {
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
                
            }else{
                [self performSegueWithIdentifier:@"drinkSegue" sender:self];//SXRDrinkViewController
            }
            break;
        }
        case ConfigCellBellSet:
        {
            [self performSegueWithIdentifier:@"bellSetSegue" sender:self];
            break;
        }
        case ConfigCellEventOTANodic:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
                
            }else{
                [self performSegueWithIdentifier:@"OTANodicSegue" sender:self];//CZJKOTAViewController
            }
            break;
         
        }
        case ConfigCellClearData:
        {
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];

            }else{
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Clear_Confirm_hm", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"Delete", nil), nil];
                alerview.tag = 100;
                [alerview show];
            }
            break;
        }
        case ConfigCellLongSit:
        {
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
                
            }else{
                
                [self performSegueWithIdentifier:@"longsitSegue" sender:self];
            }
            break;

        }
        case ConfigCellEventNotify:
        {
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
                
            }else{
                
                [self performSegueWithIdentifier:@"notificationSegue" sender:self];
            }
            break;
        }
        case ContigCellSleepSet:
        {
//            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                [alerview show];
//                
//            }else if([self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_E06]){
//                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_nofunction", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//                [alerview show];
//
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                            [alerview show];
            
            }else{
                [self performSegueWithIdentifier:@"sleepSegue" sender:self];//SXRSleepSetViewController
            }
            break;
        }
        case ConfigCellScreenTime:{
            if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
                UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alerview show];
                
            }else{
                [self performSegueWithIdentifier:@"screenSegue" sender:self];
            }
            break;
        }
            /*
        case ConfigCellEventVibration:
        {
            
            if (self.blecontrol.is_connected != IRKConnectionStateConnected){
                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"OTA_Error_No_Ble_connect", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                alertview.tag = 2000;
                [alertview show];
                
            }else{
                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Need_Sync_Band", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
                alertview.tag = 2002;
                [alertview show];
                
            }
            break;
        }
          */
   
        default:
            break;
    }
   
    //    [self.tableview setHidden:YES];
}

- (void)didSwitchTouchUp:(BOOL)status tagIndex:(NSInteger)tag
{
    NSLog(@"didSwitchTouchUp");
    switch (tag) {
        case ConfigCellEventAntiLost:
            self.commondata.is_enable_antilost = status;
            [self.commondata saveconfig];
            [self.mainloop setConfigParam];
            break;
        case ConfigCellEventMusicControl:
            self.commondata.is_enable_bongcontrolmusic = status;
            [self.commondata saveconfig];
            break;
        case ConfigCellEventIncomingCall:
            self.commondata.is_enable_incomingcall = status;
            [self.commondata saveconfig];
            if (status) {
                [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"incomingcall_tip", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil] show];
            }
        case ConfigCellEventBrightScreen:
            self.commondata.is_enable_bringScreen = status;
            [self.commondata saveconfig];
            [self.mainloop setConfigParam];
            break;
        case ConfigCellEventCallPhone:
            self.commondata.is_enable_devicecall = status;
            [self.commondata saveconfig];
            break;
        case ConfigCellEventWhatsApp:
            self.commondata.is_enable_whatsappnotify;
            [self.commondata saveconfig];
            break;
        case ConfigCellEventVibration:{
            
            if (self.blecontrol.is_connected != IRKConnectionStateConnected){
                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"OTA_Error_No_Ble_connect", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                alertview.tag = 2000;
                [alertview show];
                
            }else{
                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Need_Sync_Band", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
                alertview.tag = 2002;
//                self.commondata.is_enable_lowbatteryalarm = status;
//                [self.commondata saveconfig];
                [alertview show];
                
                
            }
            break;
        }
        case ConfigCellEventTakePhoto:
        {
            self.commondata.is_enable_takephoto = status;
            [self.commondata saveconfig];
            break;
        }
            
        default:
            break;
    }
}
    
-(void) switchTouchUp:(id)sender{
    UISwitch * switchview = (UISwitch*)sender;
    
    NSLog(@"switchTouchUp");
    switch (switchview.tag) {
        case ConfigCellEventAntiLost:
            self.commondata.is_enable_antilost = switchview.on;
            NSLog(@"%d",self.commondata.is_enable_antilost);
            [self.commondata saveconfig];
            [self.mainloop setConfigParam];
            break;
        case ConfigCellEventMusicControl:
            self.commondata.is_enable_bongcontrolmusic = switchview.on;
            [self.commondata saveconfig];
            break;
        case ConfigCellEventIncomingCall:
            self.commondata.is_enable_incomingcall = switchview.on;
            [self.commondata saveconfig];
            if (switchview.on) {
                [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"incomingcall_tip", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil] show];
            }

            break;
        case ConfigCellEventBrightScreen:
            self.commondata.is_enable_bringScreen = switchview.on;
            [self.commondata saveconfig];
            [self.mainloop setConfigParam];
            break;
/*
        case ConfigCellEventMail:
            self.commondata.is_enable_mailnotify = switchview.on;
            [self.commondata saveconfig];
            break;
        case ConfigCellEventReminderAlarm:
            self.commondata.is_enable_remindernotify = switchview.on;
            [self.commondata saveconfig];
            break;
        case ConfigCellEventSms:
            self.commondata.is_enable_smsnotify = switchview.on;
            [self.commondata saveconfig];
            break;
 */
        case ConfigCellEventCallPhone:
            self.commondata.is_enable_devicecall = switchview.on;
            [self.commondata saveconfig];
            break;
        case ConfigCellEventVibration:{
            
            if (self.blecontrol.is_connected != IRKConnectionStateConnected){
                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"OTA_Error_No_Ble_connect", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                alertview.tag = 2000;
                [alertview show];
                
            }else{
//                NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
//                if (bi != nil) {
//                    NSString* versioncode = [bi objectForKey:BONGINFO_KEY_VERSIONCODE];
//                    if (versioncode == nil || [versioncode isEqualToString:@"000"]) {
//                        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Not_Support", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//                        alertview.tag = 2001;
//                        [alertview show];
//                      
//                    }else{
//                        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Need_Sync_Band", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
//                        alertview.tag = 2002;
//                        [alertview show];
//
//                    }
//                }
                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Need_Sync_Band", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
                alertview.tag = 2002;
                [alertview show];


            }
        }
            
            
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==100) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self showPop:NSLocalizedString(@"Clear_ing", nil)];
            [self.mainloop Start_clear];
        }
    }else if (alertView.tag == 2000){
        [self.tableview reloadData];
    }else if (alertView.tag == 2001){
        [self.tableview reloadData];
    }else if (alertView.tag == 2002){
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self.tableview reloadData];
        }else{
            self.commondata.is_enable_lowbatteryalarm = !self.commondata.is_enable_lowbatteryalarm;
            [self.commondata saveconfig];
            [self.tableview reloadData];
            [self.mainloop StartSetScreenTime];
        }
    }
}

-(void)showPop:(NSString*)str{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    if(self.popup){
        [KLCPopup dismissAllPopups];
//        [self.popup dismissPresentingPopup];
        self.popup = nil;
        
    }
//    if (self.popontime) {
//        [self.popontime invalidate];
//        self.popontime = nil;
//    }
    self.popup = [KLCPopup popupWithContentView:label showType:KLCPopupShowTypeNone dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeClear dismissOnBackgroundTouch:NO dismissOnContentTouch:YES];
    label.text = str;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    KLCPopupLayout lay= KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutBottom);
    [self.popup showWithLayout:lay];
    
    //self.popontime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onPopTime:) userInfo:nil repeats:NO];
}

-(void)onPopTime:(id)sender{
    self.popontime = nil;
    [self.popup dismissPresentingPopup];
    self.popup = nil;
    
}

-(void)onClearOK:(NSNotification*)notify{
    NSLog(@"onClearOK");
    [KLCPopup dismissAllPopups];
//    [self.popup dismiss:YES];
    
    //[self showPop:NSLocalizedString(@"Clear_OK", nil)];
    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Clear_OK", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertview show];

    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_clear_all_data object:nil];

}

-(void)onClearErr:(NSNotification*)notify{
    NSLog(@"onClearErr");
//    [self showPop:NSLocalizedString(@"Clear_Failed", nil)];
    [KLCPopup dismissAllPopups];
    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Clear_Failed", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertview show];
    
}

-(void)onClearTimeout:(NSNotification*)notify{
    NSLog(@"onClearTimeout");
//    [self showPop:NSLocalizedString(@"Clear_Failed", nil)];
    [KLCPopup dismissAllPopups];
    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Clear_Failed", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertview show];
    
}

-(Alarm*)checkLongsit{
    NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    NSString* macid = [bonginfo objectForKey:BONGINFO_KEY_BLEADDR];
    if (macid == nil || [macid isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Alarm_No_Macid", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
        return nil;
    }
    NSError* error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"macid=%@ and uid = %@ and type = %@", macid, self.commondata.uid,[NSNumber numberWithInt:ALARM_TYPE_LONGSIT]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"alarm_id" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    
    self.fetchArrar = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if ([self.fetchArrar count]) {
        return [self.fetchArrar objectAtIndex:0];
    }else{
        Alarm* record = (Alarm*)[NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:self.context];
        record.alarm_id = [NSNumber numberWithInt:0];
        record.type = [NSNumber numberWithInt:ALARM_TYPE_LONGSIT];
        record.uid = self.commondata.uid;
        record.macid = macid;
        record.createtime = [NSDate date];
        record.firedate = [NSDate date];
        record.starthour = [NSNumber numberWithInt:9];
        record.startminute = [NSNumber numberWithInt:0];
        record.endhour = [NSNumber numberWithInt:18];
        record.endminute = [NSNumber numberWithInt:0];
        record.weekly = [NSNumber numberWithInt:62];
        record.enable = [NSNumber numberWithInt:0];
        record.snooze = [NSNumber numberWithInt:30];
        record.repeat_hour = [NSNumber numberWithInt:0];
        record.vib_number = [NSNumber numberWithInt:3];
        record.vib_repeat = [NSNumber numberWithInt:3];
        record.name =[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"LONGSIT_NAME", nil),0];
        [self.serverlogic update_alarm:[self.serverlogic MakeAlarmActionBody:record]];
        [self.context save:nil];
        return record;
    }

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
