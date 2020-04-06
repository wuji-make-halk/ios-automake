//
//  SXRSedentaryViewController.m
//  HiMove
//
//  Created by qf on 2017/6/22.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "SXRSedentaryViewController.h"
#import "WKProgressHUD.h"
#import "BleControl.h"
#import "MainLoop.h"
#import "IRKCommonData.h"
#import "CommonDefine.h"

typedef NS_ENUM(NSInteger, SettingCellTag) {
    AlarmSettingEnable,
    AlarmSettingStartHour,
    AlarmSettingEndHour,
    AlarmSettingRepeat,
    AlarmSettingWeekly
};


@interface SXRSedentaryViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate,ActionSheetCustomPickerDelegate>
@property(nonatomic,strong)NSManagedObjectContext* context;
@property(nonatomic,strong)ServerLogic* serverlogic;
@property (strong, nonatomic)UIActivityIndicatorView* indicator;
@property(nonatomic,strong)BleControl* blecontrol;
@property (nonatomic, strong)IRKCommonData* commondata;
@property (nonatomic, strong)MainLoop* mainloop;
@property(nonatomic,strong)NSArray* fetchArrar;
@property (nonatomic, strong)UITableView* tableview;
@property(strong,nonatomic)NSMutableArray* itemlist;

@end

@implementation SXRSedentaryViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
    [self reloadData];
    [self reloadCell];
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.serverlogic = [ServerLogic SharedInstance];
    self.blecontrol = [BleControl SharedInstance];
    self.mainloop = [MainLoop SharedInstance];
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.context = appdelegate.managedObjectContext;
    self.itemlist = [[NSMutableArray alloc] init];
    [self initNav];
    [self initcontrol];
}

-(void)reloadCell{
    [self.itemlist removeAllObjects];
    
    [self.itemlist addObject:@[
                               @{@"name":NSLocalizedString(@"LongSit_State", nil),
                                 @"image":@"",
                                 @"type":@"switch",
                                 @"celltag":[NSNumber numberWithInt:AlarmSettingEnable],
                                 @"switchon":[NSNumber numberWithBool:self.alarminfo.enable.boolValue]
                                 }]];
    [self.itemlist addObject:@[
                               @{@"name":NSLocalizedString(@"LongSit_Interval", nil),
                                 @"image":@"",
                                 @"type":@"label",
                                 @"celltag":[NSNumber numberWithInt:AlarmSettingRepeat],
                                 @"textvalue":[NSString stringWithFormat:@"%d %@",self.alarminfo.snooze.intValue, NSLocalizedString(@"UNIT_MIN", nil)]},
                               @{@"name":NSLocalizedString(@"LongSit_Start", nil),
                                 @"image":@"",
                                 @"type":@"label",
                                 @"celltag":[NSNumber numberWithInt:AlarmSettingStartHour],
                                 @"textvalue": [self format_time:self.alarminfo.starthour.intValue minute:self.alarminfo.startminute.intValue]},
                               @{@"name":NSLocalizedString(@"LongSit_End", nil),
                                 @"image":@"",
                                 @"type":@"label",
                                 @"celltag":[NSNumber numberWithInt:AlarmSettingEndHour],
                                 @"textvalue":[self format_time:self.alarminfo.endhour.intValue minute:self.alarminfo.endminute.intValue]}]];
    [self.itemlist addObject:@[
                               @{@"name":@"",
                                 @"image":@"",
                                 @"type":@"peroid",
                                 @"celltag":[NSNumber numberWithInt:AlarmSettingWeekly]
                                 }]];
    
    [self.tableview reloadData];
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
    label.text=NSLocalizedString(@"Config_Cell_Longsit", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}

-(void)onClickBack:(UIButton*)sender{
    [self.context save:nil];
    if (self.commondata.is_login){
        [self.serverlogic update_alarm:[self.serverlogic MakeAlarmActionBody:self.alarminfo]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)initcontrol{
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-65) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    [self.view addSubview:self.tableview];
    self.tableview.tableFooterView =({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 80)];
        view.backgroundColor = [UIColor clearColor];
        UIButton* reset = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.1, 20, CGRectGetWidth(self.view.frame)*0.8, 60)];
        reset.backgroundColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1];
        [reset setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [reset setTitle:NSLocalizedString(@"Set_to_Band", nil) forState:UIControlStateNormal];
        [reset addTarget:self action:@selector(onClickSync) forControlEvents:UIControlEventTouchUpInside];
        reset.layer.cornerRadius = 5;
        [view addSubview:reset];
        if (self.indicator) {
            self.indicator = nil;
        }
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [reset addSubview:self.indicator];
        self.indicator.center = CGPointMake(180, 20);
        self.indicator.hidden = YES;
        view;
    });
}

-(void)showIndicator{
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
}
-(void)hideIndicator{
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
}
-(void)onClickSync{
    //[self onPopWindow];
    [self.context save:nil];
    if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        return;
    }
    [self showIndicator];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinish:) name:notify_key_did_finish_send_cmd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailed:) name:notify_key_did_finish_send_cmd_err object:nil];
    
    [self.mainloop sendCmd:CMD_LONGSIT];
    
}
-(void)didFailed:(NSNotification*)notify{
    //    self.commondata.is_enable_clock = [[NSUserDefaults standardUserDefaults] boolForKey:CONFIG_KEY_ENABLE_CLOCK];
    [self hideIndicator];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error",nil) message:NSLocalizedString(@"Alarm_Fail", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)didFinish:(NSNotification*)notify{
    [self hideIndicator];
    [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alarm_sedentary_finish", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --------TableView Method--------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.alarminfo == nil) return 0;
    else return self.itemlist.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray* rowlist = [self.itemlist objectAtIndex:section];
    return [rowlist count];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
        //        cell.textLabel.textColor=[UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
        //        cell.detailTextLabel.textColor=[UIColor whiteColor];
    }
    cell.textLabel.text = [iteminfo objectForKey:@"name"];
    cell.tag = [[iteminfo objectForKey:@"celltag"] integerValue];
    NSString* imagename =[iteminfo objectForKey:@"image"];
    if (imagename != nil && ![imagename isEqualToString:@""]){
        cell.imageView.image = [UIImage imageNamed:imagename];
    }
    if ([iteminfo.allKeys containsObject:@"backgroundcolor"]) {
        cell.backgroundColor = [iteminfo objectForKey:@"backgroundcolor"];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
    UIColor* contentcolor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
    if ([celltype isEqualToString:@"switch"]) {
        UISwitch* switchview = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        [switchview setOnTintColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];
        [switchview addTarget:self action:@selector(switchTouchUp:) forControlEvents:UIControlEventValueChanged];
        NSNumber* switchon = [iteminfo objectForKey:@"switchon"];
        [switchview setOn:switchon.boolValue animated:NO];
        switchview.tag = [[iteminfo objectForKey:@"celltag"] integerValue];
        cell.accessoryView = switchview;
        
    }else if([celltype isEqualToString:@"label"]){
        //        UIView* content = [[UIView alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.view.frame)*0.5,20)];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.view.frame)*0.5,20)];
        label.textAlignment = NSTextAlignmentRight;
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        if ([iteminfo.allKeys containsObject:@"textcolor"]) {
            label.textColor = [iteminfo objectForKey:@"textcolor"];
        }else{
            label.textColor = contentcolor;
        }
        label.font = [UIFont systemFontOfSize:14];
        if ([iteminfo.allKeys containsObject:@"attributetextvalue"]) {
            label.attributedText = [iteminfo objectForKey:@"attributetextvalue"];
        }else if ([iteminfo.allKeys containsObject:@"textvalue"]){
            label.text = [iteminfo objectForKey:@"textvalue"];
        }
        label.tag = [[iteminfo objectForKey:@"celltag"] integerValue];
        cell.accessoryView = label;
        
    }else if([celltype isEqualToString:@"peroid"]){
        UIColor* selectcolor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1];
        UIView* btnview = [cell viewWithTag:1024];
        if (btnview) {
            [btnview removeFromSuperview];
            btnview = nil;
        }
        CGFloat cellheight =[self.tableview rectForRowAtIndexPath:indexPath].size.height;
        btnview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), cellheight)];
        btnview.backgroundColor = [UIColor clearColor];
        
        CGFloat btn_size = cellheight*0.6;
        CGFloat sep = (CGRectGetWidth(btnview.frame)-7*btn_size)/8.0;
        CGFloat yoffset = (cellheight-btn_size)/2.0;
        CGFloat fontsize = btn_size*0.3;
        UIButton* btn1 = [[UIButton alloc] initWithFrame:CGRectMake(sep, yoffset, btn_size, btn_size)];
        btn1.layer.cornerRadius = btn_size/2.0;
        btn1.titleLabel.font = [self.commondata getFontbySize:fontsize isBold:NO];
        btn1.clipsToBounds = YES;
        btn1.userInteractionEnabled = YES;
        btn1.tag = 1;
        [btn1 addTarget:self action:@selector(onClickWeekly:) forControlEvents:UIControlEventTouchUpInside];
        [btn1 setTitle:NSLocalizedString(@"Sunday", nil) forState:UIControlStateNormal];
        if ((self.alarminfo.weekly.intValue & PERIOD_1) == 1) {
            [btn1 setSelected:YES];
            [btn1 setBackgroundColor:selectcolor];
        }else{
            [btn1 setSelected:NO];
            [btn1 setBackgroundColor:[UIColor clearColor]];
        }
        [btnview addSubview:btn1];
        
        UIButton* btn2 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn1.frame)+sep, yoffset, btn_size, btn_size)];
        btn2.layer.cornerRadius = btn_size/2.0;
        btn2.titleLabel.font = [self.commondata getFontbySize:fontsize isBold:NO];
        btn2.clipsToBounds = YES;
        btn2.userInteractionEnabled = YES;
        btn2.tag = 2;
        [btn2 addTarget:self action:@selector(onClickWeekly:) forControlEvents:UIControlEventTouchUpInside];
        [btn2 setTitle:NSLocalizedString(@"Monday", nil) forState:UIControlStateNormal];
        if (((self.alarminfo.weekly.intValue & PERIOD_2)>>1) == 1) {
            [btn2 setSelected:YES];
            [btn2 setBackgroundColor:selectcolor];
        }else{
            [btn2 setSelected:NO];
            [btn2 setBackgroundColor:[UIColor clearColor]];
        }
        [btnview addSubview:btn2];
        
        UIButton* btn3 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn2.frame)+sep, yoffset, btn_size, btn_size)];
        btn3.layer.cornerRadius = btn_size/2.0;
        btn3.titleLabel.font = [self.commondata getFontbySize:fontsize isBold:NO];
        btn3.clipsToBounds = YES;
        btn3.userInteractionEnabled = YES;
        btn3.tag = 3;
        [btn3 addTarget:self action:@selector(onClickWeekly:) forControlEvents:UIControlEventTouchUpInside];
        [btn3 setTitle:NSLocalizedString(@"Tuesday", nil) forState:UIControlStateNormal];
        if (((self.alarminfo.weekly.intValue & PERIOD_3)>>2) == 1) {
            [btn3 setSelected:YES];
            [btn3 setBackgroundColor:selectcolor];
        }else{
            [btn3 setSelected:NO];
            [btn3 setBackgroundColor:[UIColor clearColor]];
        }
        [btnview addSubview:btn3];
        
        UIButton* btn4 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn3.frame)+sep, yoffset, btn_size, btn_size)];
        btn4.layer.cornerRadius = btn_size/2.0;
        btn4.titleLabel.font = [self.commondata getFontbySize:fontsize isBold:NO];
        btn4.clipsToBounds = YES;
        btn4.userInteractionEnabled = YES;
        btn4.tag = 4;
        [btn4 addTarget:self action:@selector(onClickWeekly:) forControlEvents:UIControlEventTouchUpInside];
        [btn4 setTitle:NSLocalizedString(@"Wednesday", nil) forState:UIControlStateNormal];
        if (((self.alarminfo.weekly.intValue & PERIOD_4)>>3) == 1) {
            [btn4 setSelected:YES];
            [btn4 setBackgroundColor:selectcolor];
        }else{
            [btn4 setSelected:NO];
            [btn4 setBackgroundColor:[UIColor clearColor]];
        }
        [btnview addSubview:btn4];
        
        UIButton* btn5 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn4.frame)+sep, yoffset, btn_size, btn_size)];
        btn5.layer.cornerRadius = btn_size/2.0;
        btn5.titleLabel.font = [self.commondata getFontbySize:fontsize isBold:NO];
        btn5.clipsToBounds = YES;
        btn5.userInteractionEnabled = YES;
        btn5.tag = 5;
        [btn5 addTarget:self action:@selector(onClickWeekly:) forControlEvents:UIControlEventTouchUpInside];
        [btn5 setTitle:NSLocalizedString(@"Thursday", nil) forState:UIControlStateNormal];
        if (((self.alarminfo.weekly.intValue & PERIOD_5)>>4) == 1) {
            [btn5 setSelected:YES];
            [btn5 setBackgroundColor:selectcolor];
        }else{
            [btn5 setSelected:NO];
            [btn5 setBackgroundColor:[UIColor clearColor]];
        }
        [btnview addSubview:btn5];
        
        UIButton* btn6 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn5.frame)+sep, yoffset, btn_size, btn_size)];
        btn6.layer.cornerRadius = btn_size/2.0;
        btn6.titleLabel.font = [self.commondata getFontbySize:fontsize isBold:NO];
        btn6.clipsToBounds = YES;
        btn6.userInteractionEnabled = YES;
        btn6.tag = 6;
        [btn6 addTarget:self action:@selector(onClickWeekly:) forControlEvents:UIControlEventTouchUpInside];
        [btn6 setTitle:NSLocalizedString(@"Friday", nil) forState:UIControlStateNormal];
        if (((self.alarminfo.weekly.intValue & PERIOD_6)>>5) == 1) {
            [btn6 setSelected:YES];
            [btn6 setBackgroundColor:selectcolor];
        }else{
            [btn6 setSelected:NO];
            [btn6 setBackgroundColor:[UIColor clearColor]];
        }
        [btnview addSubview:btn6];
        
        UIButton* btn7 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn6.frame)+sep, yoffset, btn_size, btn_size)];
        btn7.layer.cornerRadius = btn_size/2.0;
        btn7.titleLabel.font = [self.commondata getFontbySize:fontsize isBold:NO];
        btn7.clipsToBounds = YES;
        btn7.userInteractionEnabled = YES;
        btn7.tag = 7;
        [btn7 addTarget:self action:@selector(onClickWeekly:) forControlEvents:UIControlEventTouchUpInside];
        [btn7 setTitle:NSLocalizedString(@"Saturday", nil) forState:UIControlStateNormal];
        if (((self.alarminfo.weekly.intValue & PERIOD_7)>>6) == 1) {
            [btn7 setSelected:YES];
            [btn7 setBackgroundColor:selectcolor];
        }else{
            [btn7 setSelected:NO];
            [btn7 setBackgroundColor:[UIColor clearColor]];
        }
        [btnview addSubview:btn7];
        btn1.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn1.titleLabel.minimumScaleFactor = 0.5;
        btn2.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn2.titleLabel.minimumScaleFactor = 0.5;
        btn3.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn3.titleLabel.minimumScaleFactor = 0.5;
        btn4.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn4.titleLabel.minimumScaleFactor = 0.5;
        btn5.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn5.titleLabel.minimumScaleFactor = 0.5;
        btn6.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn6.titleLabel.minimumScaleFactor = 0.5;
        btn7.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn7.titleLabel.minimumScaleFactor = 0.5;
        
        [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn4 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn5 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn6 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn6 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn7 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn7 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        
        btnview.tag = 1024;
        [cell addSubview:btnview];
    }
    return cell;

    
//    NSUInteger section = [indexPath section];
//    //    NSUInteger row = [indexPath row];
//    static NSString* checkbox = @"CheckBoxCell";
//    static NSString* cellid = @"SimpleCell";
//    //    static NSString* nameid = @"nameid";
//    if(section == 0){
//        switch (indexPath.row) {
//            case 0:{
//                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:checkbox];
//                if (cell == nil) {
//                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:checkbox];
//                }
//                cell.tag = 0;
//                //        DCRoundSwitch *switchview = [[DCRoundSwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
//                //        [switchview setOffTintColor:[UIColor colorWithRed:0/255.0 green:2/255.0 blue:60/255.0 alpha:1.0f]];
//                //        [switchview setOnKnobColor:[UIColor colorWithRed:0x7e/255.0 green:0x2e/255.0 blue:0x80/255.0 alpha:1.0]];
//                //        [switchview setOffKnobColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0f]];
//                UISwitch* switchview = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
//                [switchview setOnTintColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];
//                [switchview addTarget:self action:@selector(switchTouchUp:) forControlEvents:UIControlEventValueChanged];
//                
//                cell.backgroundColor = [UIColor whiteColor];
//                cell.selectionStyle=UITableViewCellSelectionStyleNone;
//                cell.textLabel.text = NSLocalizedString(@"Clock_Drink_State", nil);
//                cell.textLabel.textColor=[UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
//                //        [switchview addTarget:self action:@selector(switchTouchUp:) forControlEvents:UIControlEventValueChanged];
//                [switchview setOn:self.alarminfo.enable.boolValue animated:YES];
//                switchview.tag = 1;
//                cell.accessoryView = switchview;
//                return cell;
//                
//            }
//                break;
//                
//            default:
//                return nil;
//                break;
//        }
//    }else if(section == 1){
//        switch (indexPath.row) {
//            case 0:{
//                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
//                if (cell == nil) {
//                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
//                }
//                cell.tag = 2;
//                cell.backgroundColor = [UIColor whiteColor];
//                cell.selectionStyle=UITableViewCellSelectionStyleNone;
//                cell.textLabel.text = NSLocalizedString(@"Clock_Drink_Time", nil);
//                cell.textLabel.textColor=[UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
//                UIView* content = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,20)];
//                UILabel* label = [[UILabel alloc] initWithFrame:content.bounds];
//                label.textAlignment = NSTextAlignmentRight;
//                label.font = [UIFont systemFontOfSize:14];
//                label.text = [self format_time:self.alarminfo.hour.intValue minute:self.alarminfo.minute.intValue];
//                label.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
//                [content addSubview:label];
//                cell.accessoryView = content;
//                return cell;
//                
//            }
//                break;
//            case 1:{
//                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
//                if (cell == nil) {
//                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
//                }
//                cell.backgroundColor = [UIColor whiteColor];
//                cell.selectionStyle=UITableViewCellSelectionStyleNone;
//                cell.textLabel.textColor=[UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
//                cell.textLabel.text = NSLocalizedString(@"Alarm_Repeat_Minute", nil);
//                cell.textLabel.textAlignment = NSTextAlignmentLeft;
//                UITextField* text_value = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 60)];
//                text_value.textAlignment = NSTextAlignmentRight;
//                text_value.delegate = self;
//                [text_value addTarget:self action:@selector(onTextChange:) forControlEvents:UIControlEventEditingChanged];
//                text_value.text = [NSString stringWithFormat:@"%d >",self.alarminfo.repeat_hour.intValue];
//                text_value.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
//                text_value.tag = 2003;
//                cell.accessoryView = text_value;
//                return cell;
//                
//            }
//                break;
//                
//            case 2:{
//                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
//                if (cell == nil) {
//                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
//                }
//                cell.backgroundColor = [UIColor whiteColor];
//                cell.selectionStyle=UITableViewCellSelectionStyleNone;
//                cell.textLabel.textColor=[UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
//                cell.textLabel.text = NSLocalizedString(@"Alarm_Repeat_Times", nil);
//                cell.textLabel.textAlignment = NSTextAlignmentLeft;
//                UITextField* text_value = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 60)];
//                text_value.textAlignment = NSTextAlignmentRight;
//                text_value.delegate = self;
//                [text_value addTarget:self action:@selector(onTextChange:) forControlEvents:UIControlEventEditingChanged];
//                text_value.text = [NSString stringWithFormat:@"%d >",self.alarminfo.repeat_times.intValue];
//                text_value.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
//                text_value.tag = 2012;
//                cell.accessoryView = text_value;
//                return cell;
//                
//            }
//                break;
//            default:
//                return nil;
//                break;
//        }
//    }else
//        return nil;
}
-(void)onClickWeekly:(UIButton*)sender{
    switch (sender.tag) {
        case 1:
            if (!sender.isSelected) {
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue|PERIOD_1];
            }else{
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue&(~PERIOD_1)];
            }
            break;
        case 2:
            if (!sender.isSelected) {
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue|PERIOD_2];
            }else{
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue&(~PERIOD_2)];
            }
            break;
        case 3:
            if (!sender.isSelected) {
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue|PERIOD_3];
            }else{
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue&(~PERIOD_3)];
            }
            break;
        case 4:
            if (!sender.isSelected) {
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue|PERIOD_4];
            }else{
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue&(~PERIOD_4)];
            }
            break;
        case 5:
            if (!sender.isSelected) {
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue|PERIOD_5];
            }else{
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue&(~PERIOD_5)];
            }
            break;
        case 6:
            if (!sender.isSelected) {
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue|PERIOD_6];
            }else{
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue&(~PERIOD_6)];
            }
            break;
        case 7:
            if (!sender.isSelected) {
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue|PERIOD_7];
            }else{
                self.alarminfo.weekly = [NSNumber numberWithInt:self.alarminfo.weekly.intValue&(~PERIOD_7)];
            }
            break;
            
        default:
            break;
    }
    [self reloadCell];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //该方法响应列表中行的点击事件
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case AlarmSettingRepeat:{
            ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"LongSit_Interval", nil) delegate:self showCancelButton:YES origin:self.view];
            ap.tag = AlarmSettingRepeat;
            [ap showActionSheetPicker];

        }
            break;
        case AlarmSettingStartHour:{
            NSCalendar* ca = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents* comp = [ca components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
            [comp setHour:self.alarminfo.starthour.intValue];
            [comp setMinute:self.alarminfo.startminute.intValue];
            NSDate* d = [ca dateFromComponents:comp];
            ActionSheetDatePicker* ap = [[ActionSheetDatePicker alloc] initWithTitle:NSLocalizedString(@"LongSit_Start", nil) datePickerMode:UIDatePickerModeTime selectedDate:d doneBlock:^(ActionSheetDatePicker *picker, NSDate *selectedDate, id origin) {
                NSCalendar* ca = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents* comp = [ca components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:selectedDate];
                
                NSInteger hours = comp.hour;
                if (hours > self.alarminfo.endhour.intValue) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"StartLittleThanEnd_Title", nil) message:NSLocalizedString(@"StartLittleThanEnd_Tip", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                    [alert show];
                }else{
                    self.alarminfo.starthour = [NSNumber numberWithInt: (int)comp.hour];
                    self.alarminfo.startminute = [NSNumber numberWithInt: (int)comp.minute];
                }
                
                [self reloadCell];
                
            } cancelBlock:nil origin:self.view];
            ap.minuteInterval = 1;
            [ap showActionSheetPicker];

        } break;
        case AlarmSettingEndHour:
        {
            NSCalendar* ca = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents* comp = [ca components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
            [comp setHour:self.alarminfo.endhour.intValue];
            [comp setMinute:self.alarminfo.endminute.intValue];
            NSDate* d = [ca dateFromComponents:comp];
            ActionSheetDatePicker* ap = [[ActionSheetDatePicker alloc] initWithTitle:NSLocalizedString(@"LongSit_End", nil) datePickerMode:UIDatePickerModeTime selectedDate:d doneBlock:^(ActionSheetDatePicker *picker, NSDate *selectedDate, id origin) {
                NSCalendar* ca = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents* comp = [ca components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:selectedDate];
                NSInteger hours = comp.hour;
                if (hours < self.alarminfo.starthour.intValue) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EndBiggerThanStart_Title", nil) message:NSLocalizedString(@"EndBiggerThanStart_Tip", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                    [alert show];
                }else{
                    self.alarminfo.endhour = [NSNumber numberWithInt:(int)comp.hour];
                    self.alarminfo.endminute = [NSNumber numberWithInt:(int)comp.minute];
                    
                }
                
                [self reloadCell];
                
            } cancelBlock:nil origin:self.view];
            ap.minuteInterval = 1;
            [ap showActionSheetPicker];
            /*
             ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"GoalSet_Sleeptime_piker_title", nil) delegate:self showCancelButton:YES origin:self.view];
             ap.tag = 14;
             [ap showActionSheetPicker];
             */
            
        }
            break;
        default: break;
    }
}


-(void) switchTouchUp:(id)sender{
    UISwitch * switchview = (UISwitch*)sender;
    switch (switchview.tag) {
        case AlarmSettingEnable:
            self.alarminfo.enable =[NSNumber numberWithBool:switchview.on];
            break;
        default: break;
    }
}

//ActionsheetCustomDelegate
-(void)reloadData{
    if (self.commondata.lastBongUUID == nil || [self.commondata.lastBongUUID isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Alarm_No_Macid", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
        return;
    }
    NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    NSString* macid = [bonginfo objectForKey:BONGINFO_KEY_BLEADDR];
    
    
    if (macid == nil || [macid isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Alarm_No_Macid", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
        return;
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
//    int maxalarmcount = 1;
//    if ([self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_E06]) {
//        maxalarmcount = 1;
//    }else{
//        maxalarmcount = 1;
//    }
    
    if ([self.fetchArrar count] > 0) {
        self.alarminfo = [self.fetchArrar firstObject];
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
        record.snooze = [NSNumber numberWithInt:60];
        record.repeat_hour = [NSNumber numberWithInt:0];
        record.vib_number = [NSNumber numberWithInt:3];
        record.vib_repeat = [NSNumber numberWithInt:3];
        record.name =[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"Config_Cell_Longsit", nil),0];
        [self.serverlogic update_alarm:[self.serverlogic MakeAlarmActionBody:record]];
        [self.context save:nil];
        self.alarminfo = record;
//        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
//        return;
    }
//    
//    self.alarminfo = [self.fetchArrar objectAtIndex:0];
//    
//    [self.tableview reloadData];
    
}
/////////////////////////////////////////////////////////////////////


-(NSString*)format_time:(int)hour minute:(int)min{
    NSDate* date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday |NSCalendarUnitHour;
    
    comps = [calendar components:unitFlags fromDate:date];
    comps.hour = hour;
    comps.minute = min;
    NSDate* d = [calendar dateFromComponents:comps];
    
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"hh:mm a";
    
    NSString* str = [format stringFromDate:d];
    return str;
    
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if ([segue.identifier isEqualToString:@"PeriodSegue"]) {
//        //LWClockPeriodViewController* vc = segue.destinationViewController;
//        //vc.alarminfo = self.alarminfo;
//    }
//}
//
//-(void)onChange:(UITextField*)sender{
//    if (sender.tag == 100) {
//        self.alarminfo.name = sender.text;
//    }
//}

//-(void)textFieldDidEndEditing:(UITextField *)textField{
//    [textField resignFirstResponder];
//}
//-(void)onEndEdit:(UITextField*)sender{
//    [sender resignFirstResponder];
//}


- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin{
    switch (actionSheetPicker.tag) {
        case AlarmSettingRepeat:
        {
            UIPickerView * picker = (UIPickerView *)actionSheetPicker.pickerView;
            self.alarminfo.snooze =[NSNumber numberWithInteger:[picker selectedRowInComponent:0]+10];
            [self reloadCell];
            break;
        }
        default:
            break;
    }
    
}


- (void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView{
    switch (actionSheetPicker.tag) {
        case AlarmSettingRepeat:
            pickerView.tag = AlarmSettingRepeat;
            [pickerView selectRow:self.alarminfo.snooze.intValue - 10 inComponent:0 animated:YES];
            break;
        default:
            break;
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (pickerView.tag) {
        case AlarmSettingRepeat:
            return 230;
            break;
            
        default:
            break;
    }
    return 0;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (pickerView.tag) {
        case AlarmSettingRepeat:
            return [NSString stringWithFormat:@"%d",(int)row+10];
            break;
            
        default:
            break;
    }
    return @"";
}

//-(void)onTextChange:(UITextField*)sender{
//    if (sender.tag == 100) {
//        self.alarminfo.name = sender.text;
//    }
//}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
