//
//  YFTDeviceViewController.m
//  SXRBand
//
//  Created by qf on 16/1/11.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "YFTDeviceViewController.h"
#import "BleControl.h"
#import "MainLoop.h"
#import "SXRGearCell2.h"
#import "KLCPopup.h"
#import "LWSyncView.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import "FRTipsViewController.h"
#import "ConnectedDeviceTableViewCell.h"

@interface YFTDeviceViewController ()<UIAlertViewDelegate,SXRGearCell2Delegate,LWSyncViewDelegate,TipViewDelegate,ConnectedDeviceDelegate>

@property (nonatomic, strong) IRKCommonData* commondata;
@property (nonatomic, strong) UIImageView* searchview;
@property (nonatomic, strong) BleControl* blecontrol;
@property (nonatomic, strong) MainLoop* mainloop;
@property (strong, nonatomic)KLCPopup* popup;
@property (strong, nonatomic)LWSyncView* notifyView;
@property (nonatomic, strong)UIImageView *backView;
@property (nonatomic, strong)UIImageView *tipView;

@property (nonatomic, strong)UIButton *btnSetANCS;

@end

@implementation YFTDeviceViewController

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didScanDevice:) name:notify_key_did_scan_device object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectDevice:) name:notify_key_did_connect_device object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectDeviceError:) name:notify_key_did_connect_device_err object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnetDevice:) name:notify_key_did_disconnect_device object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectDevice:) name:notify_band_has_kickoff object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFinish) name:notify_key_did_finish_device_sync object:nil];
    [self beginRefresh];
    [self.tableView reloadData];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.blecontrol stopScanDevice];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.blecontrol = [BleControl SharedInstance];
    self.mainloop = [MainLoop SharedInstance];
    self.commondata = [IRKCommonData SharedInstance];
    [self initNav];
    [self initcontrol];
}

-(void)initNav{
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    UIImageView * backimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 22, 18)];
    backimg.image = [UIImage imageNamed:@"icon_back_white.png"];
    backimg.contentMode = UIViewContentModeScaleAspectFit;
    [btn addSubview:backimg];
    [btn addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectZero];
    label.textColor=[UIColor whiteColor];
    label.text=NSLocalizedString(@"Gear_Title", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}

-(void)onClickBack:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)initcontrol{
    self.refreshControl = [[UIRefreshControl alloc] init];
    NSString *Str=NSLocalizedString(@"MyDevice_Pull_Refresh", nil);
    NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc]initWithString:Str];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0] range:NSMakeRange(0, Str.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, Str.length)];
    self.refreshControl.attributedTitle =attributedString;
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
    self.tableView.frame = self.view.bounds;
}
-(void)beginRefresh{
    
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
    [self pullToRefresh];
    
}
-(void)pullToRefresh{
    NSLog(@"pullToRefresh");
    if(self.blecontrol){
        [self.blecontrol stopScanDevice];
        self.blecontrol.is_autoconnect = YES;
        [self.blecontrol scanDevice:nil withOption:nil withNotifyName:notify_key_did_scan_device];
    }
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(searchTimeout) userInfo:nil repeats:NO];
    
    
}

- (void)showTip:(NSInteger) index{
//    FRTipsViewController *tipView = [[FRTipsViewController alloc] init];
//    tipView.delegate = self;
//    tipView.tipIndex = index;
//    [self.navigationController pushViewController:tipView animated:YES];
    
}

-(void)searchTimeout{
    //    [self.searchview stopAnimating];
    [self.refreshControl endRefreshing];
    if(self.blecontrol)
        [self.blecontrol stopScanDevice];
}
-(void)didScanDevice:(NSNotification*) aNotification{
    //找到设备了，刷新tabview，停止animation
    NSLog(@"didScanDevice");
    [self.tableView reloadData];
}
-(void)didConnectDevice:(NSNotification*) aNotification{
    NSLog(@"didConnectDevice");
    [self.tableView reloadData];
}
-(void)didConnectDeviceError:(NSNotification*) aNotification{
    //找到设备了，刷新tabview，停止animation
    NSLog(@"didConnectDeviceError");
    [self.tableView reloadData];
}
-(void)didDisconnetDevice:(NSNotification*) aNotification{
    //找到设备了，刷新tabview，停止animation
    NSLog(@"didDisconnetDevice");
    [self.tableView reloadData];
}

-(NSString*)getStringfromUUID:(CBUUID* )uuid{
    NSString* aStr;
    if ([uuid respondsToSelector:@selector(UUIDString)]) {
        return [uuid.UUIDString uppercaseString];
    }
    else{
        if ([uuid.data length] == 2) {
            const unsigned char *tokenBytes = [uuid.data bytes];
            aStr = [NSString stringWithFormat:@"%02x%02x", tokenBytes[0], tokenBytes[1]];
        }
        else{
            NSUUID* tmpuuid = [[NSUUID alloc] initWithUUIDBytes:[uuid.data bytes]];
            aStr = tmpuuid.UUIDString;
        }
        //        aStr = [[NSString alloc] initWithData:ch.UUID.data encoding:NSUTF8StringEncoding];
        aStr = [aStr uppercaseString];
        NSLog(@"astr = %@",aStr);
        return aStr;
    }
}


///////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count;
    if(section == 0){
        //找已连接的设备
        count = [self.blecontrol.connectedDevicelist count];
        return count;
    }
    else{
        count = [self.blecontrol.scanDevicelist count];
        return count;
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return NSLocalizedString(@"Gear_Connected_Title", nil);
    }
    else{
        return NSLocalizedString(@"Gear_Scan_Title", nil);
        
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableView.sectionHeaderHeight)];
    label.backgroundColor=[UIColor whiteColor];
    
    if (section==0) {
        label.text=NSLocalizedString(@"Gear_Connected_Title", nil);
        label.textColor=[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
    }
    else {
        label.text=NSLocalizedString(@"Gear_Scan_Title", nil);
        label.textColor=[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
    }
    return label;
}
//新建某一行并返回

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *GealId = @"GealCell";
    NSString *ConnectedId = @"ConnectedCell";
    
    if (indexPath.section == 0){
        if (indexPath.row == 0) {
            ConnectedDeviceTableViewCell *cell = (ConnectedDeviceTableViewCell*)[tableView dequeueReusableCellWithIdentifier:ConnectedId];
            if (cell == nil) {
                cell = [[ConnectedDeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ConnectedId];
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.delegate = self;
            cell.tag = 100+indexPath.row;
            [cell reload];
            return cell;
        }
    }else{
        SXRGearCell2 *cell = (SXRGearCell2*)[tableView dequeueReusableCellWithIdentifier:GealId];
        if (cell == nil) {
            cell = [[SXRGearCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GealId];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
        cell.tag = 200+indexPath.row;
        [cell reload];
        return cell;
        
    }
    return nil;
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SXRGearCell2* cell = (SXRGearCell2*)[self.tableView cellForRowAtIndexPath:indexPath];
    if(cell.tag < 200){
        //        [self.blecontrol disconnectDevice:(cell.tag-100)];
        
    }else{
        //modify:连接新设备前先判断当前是否有连接蓝牙
        if (self.blecontrol.is_connected == IRKConnectionStateConnected)
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Doconnect_tip", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil,nil];
                alert.tag = 100;
            [alert show];
            return NO;
        }
        
        //
//        [self showTip:1];
        if([self.blecontrol.scanDevicelist count] > 0){
            [self.blecontrol stopScanDevice];
            [self.blecontrol connectDevice:(cell.tag-200)];
        }
        
    }
    [self.tableView reloadData];
    
    
    return NO;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)getDeviceName:(SXRGearCell2*)cell{
    if (cell.tag < 200) {
        CBPeripheral * peripheral =(CBPeripheral*)[self.blecontrol.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
        if(peripheral){
            return peripheral.name;
            
        }
        else{
            
            return NSLocalizedString(@"Gear_Unknown", nil);
        }
    }else{
        NSUInteger index = cell.tag - 200;
        //        NSLog(@"%@",self.blecontrol.scanDevicelist);
        
        if (index >[self.blecontrol.scanDevicelist count] || (index == 0 && [self.blecontrol.scanDevicelist count]==0))
            return NSLocalizedString(@"Gear_Unknown", nil);
        NSDictionary* d = (NSDictionary*)[self.blecontrol.scanDevicelist objectAtIndex:index];
        CBPeripheral * peripheral =(CBPeripheral*)[d objectForKey:@"peripheral"];
        //       CBPeripheral * peripheral =(CBPeripheral*)[self.blecontrol.scanDevicelist objectAtIndex:index];
        if (peripheral) {
            return peripheral.name;
        }else{
            return NSLocalizedString(@"Gear_Unknown", nil);
        }
        
        
    }
}
-(NSString*)getDeviceId:(SXRGearCell2*)cell{
    if (cell.tag < 200) {
        CBPeripheral * peripheral =(CBPeripheral*)[self.blecontrol.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
        if(peripheral){
            return peripheral.identifier.UUIDString;
            
        }
        else{
            
            return NSLocalizedString(@"Gear_Unknown", nil);
        }
    }else{
        NSUInteger index = cell.tag - 200;
        //        NSLog(@"%@",self.blecontrol.scanDevicelist);
        if (index >[self.blecontrol.scanDevicelist count]|| (index == 0 && [self.blecontrol.scanDevicelist count]==0))
            return NSLocalizedString(@"Gear_Unknown", nil);
        
        //        CBPeripheral * peripheral =(CBPeripheral*)[self.blecontrol.scanDevicelist objectAtIndex:index];
        NSDictionary* d = (NSDictionary*)[self.blecontrol.scanDevicelist objectAtIndex:index];
        CBPeripheral * peripheral =(CBPeripheral*)[d objectForKey:@"peripheral"];
        if (peripheral) {
            return peripheral.identifier.UUIDString;
        }else{
            return NSLocalizedString(@"Gear_Unknown", nil);
        }
        
        
    }
}
-(int)getRssi:(SXRGearCell2*)cell{
    if (cell.tag < 200) {
        CBPeripheral * peripheral =(CBPeripheral*)[self.blecontrol.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
        if(peripheral){
            return peripheral.RSSI.intValue;
            
        }
        else{
            
            return -80;
        }
    }else{
        NSUInteger index = cell.tag - 200;
        //        NSLog(@"%@",self.blecontrol.scanDevicelist);
        if (index >[self.blecontrol.scanDevicelist count]|| (index == 0 && [self.blecontrol.scanDevicelist count]==0))
            return -120;
        
        //        CBPeripheral * peripheral =(CBPeripheral*)[self.blecontrol.scanDevicelist objectAtIndex:index];
        NSDictionary* d = (NSDictionary*)[self.blecontrol.scanDevicelist objectAtIndex:index];
        NSNumber* n = (NSNumber*)[d objectForKey:@"RSSI"];
        if (n) {
            return n.intValue;
        }else{
            return -120;
        }
        
        
    }
    
}
-(void)didStartCall:(SXRGearCell2*)cell{
    [self.mainloop api_send_antilost:HJT_ANTILOST_TYPE_PHONE_CALL_DEVICE];
}
-(void)didStopCall:(SXRGearCell2*)cell{
    [self.mainloop api_send_antilost:HJT_ANTILOST_TYPE_PHONE_CALL_DEVICE_END];
    
}
-(void)didStartSync:(SXRGearCell2 *)cell{
    //    if(self.notifyView == nil){
    //        self.notifyView = [[LWSyncView alloc] initWithFrame:self.view.bounds];
    //        self.notifyView.delegate = self;
    //        self.notifyView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    //    }
    //    self.popup = [KLCPopup popupWithContentView:self.notifyView showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    //    [self.popup show];
    //[[NSNotificationCenter defaultCenter] postNotificationName:notify_key_start_sync_history object:nil];
    
}

-(void)didClickConnectImage:(SXRGearCell2*)cell{
    if(cell.tag < 200){
        [self.blecontrol disconnectDevice:(cell.tag-100)];
//        [self showTip:2];
    }else{
        if([self.blecontrol.scanDevicelist count] > 0){
            //modify:连接新设备前先判断当前是否有连接蓝牙
            if (self.blecontrol.is_connected == IRKConnectionStateConnected){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Doconnect_tip", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil,nil];
                alert.tag = 100;
                [alert show];
                return;
            }
            
            //提醒蓝牙配对连接
//            [self showTip:1];
            [self.blecontrol stopScanDevice];
            [self.refreshControl endRefreshing];
            [self.blecontrol connectDevice:(cell.tag-200)];
        }
        
    }
    [self.tableView reloadData];
    
}
-(int)getSelfType:(SXRGearCell2*)cell{
    if (cell.tag >= 100 && cell.tag < 200) {
        return 1;
    }else{
        return 2;
    }
}

-(BOOL)getCallBtnEnable:(SXRGearCell2 *)cell{
//#ifdef CUSTOM_API2
    if (self.mainloop.current_state == STATE_CONNECT_IDLE)
//#else
//        if (self.mainloop.current_state == CURRENT_STATE_READY)
//#endif
        {
            return YES;
        }else{
            return NO;
        }
}

-(void)LWSyncViewClickClose:(LWSyncView *)view{
    [self.popup dismissPresentingPopup];
    //    [KLCPopup dismissAllPopups];
    self.popup = nil;
    self.notifyView = nil;
    //    self.notifyView = nil;
}

-(void)onFinish{
    NSLog(@"onFinish::::::::::::::::>>>>>>>>");
    [self.popup dismissPresentingPopup];
    //    [KLCPopup dismissAllPopups];
    
    self.popup = nil;
    self.notifyView = nil;
    
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1024) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        }else{
            [self.blecontrol disconnectDevice:0];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
        }
    }
}

- (void)DidClickedTipButton:(NSInteger)btnIndex
{
    if(btnIndex == 1 )
    {
        //断开蓝牙
        [self.blecontrol disconnectDevice:0];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////
-(NSString*)ConnectedDeviceTableViewCellGetDeviceName:(ConnectedDeviceTableViewCell*)cell{
    CBPeripheral * peripheral =(CBPeripheral*)[self.blecontrol.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
    if(peripheral){
        return peripheral.name;
        
    }
    else{
        
        return NSLocalizedString(@"Gear_Unknown", nil);
    }

}
-(NSString*)ConnectedDeviceTableViewCellGetDeviceId:(ConnectedDeviceTableViewCell*)cell{
    CBPeripheral * peripheral =(CBPeripheral*)[self.blecontrol.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
    if(peripheral){
        return peripheral.identifier.UUIDString;
        
    }
    else{
        
        return NSLocalizedString(@"Gear_Unknown", nil);
    }

}
-(void)ConnectedDeviceTableViewCellDidStartCall:(ConnectedDeviceTableViewCell*)cell{
    [self.mainloop api_send_antilost:HJT_ANTILOST_TYPE_PHONE_CALL_DEVICE];
}
-(void)ConnectedDeviceTableViewCellDidStopCall:(ConnectedDeviceTableViewCell*)cell{
    [self.mainloop api_send_antilost:HJT_ANTILOST_TYPE_PHONE_CALL_DEVICE_END];
}
-(void)ConnectedDeviceTableViewCellDisconnect:(ConnectedDeviceTableViewCell*)cell{
    [self.blecontrol disconnectDevice:(cell.tag-100)];
//    [self showTip:2];

}
-(BOOL)ConnectedDeviceTableViewCellGetCallBtnEnable:(ConnectedDeviceTableViewCell*)cell{
    if (self.mainloop.current_state == STATE_CONNECT_IDLE)
    {
        return YES;
    }else{
        return NO;
    }

}

@end
