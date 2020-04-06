//
//  LWClockViewController.m
//  Lovewell
//
//  Created by qf on 14-8-28.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "LWClockViewController.h"
#import "LWClockPeriodViewController.h"
#import "BleControl.h"
#import "DCRoundSwitch.h"

@interface LWClockViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate,ActionSheetCustomPickerDelegate,UIAlertViewDelegate,UITextFieldDelegate>
@property(nonatomic,strong)NSManagedObjectContext* contex;
@property(nonatomic,strong)ServerLogic* serverlogic;
@property (strong, nonatomic)UIActivityIndicatorView* indicator;
@property(nonatomic,strong)BleControl* blecontrol;
@property (nonatomic, strong)IRKCommonData* commondata;
@property (nonatomic, strong)MainLoop* mainloop;
@property (nonatomic, strong)UITableView* tableview;
@end

@implementation LWClockViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor =[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
    [self.tableview reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.serverlogic = [ServerLogic SharedInstance];
    self.blecontrol = [BleControl SharedInstance];
    self.mainloop = [MainLoop SharedInstance];
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.contex = appdelegate.managedObjectContext;
    [self initNav];
    [self initControl];
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
    label.text=NSLocalizedString(@"Clock_Title", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
    
    UIButton * btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImageView * backimg2 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
    backimg2.image = [UIImage imageNamed:@"icon_del.png"];
    backimg2.contentMode = UIViewContentModeScaleAspectFit;
    [btn2 addSubview:backimg2];
    [btn2 addTarget:self action:@selector(onClickDel:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn2];

}

-(void)onClickBack:(UIButton*)sender{
    [self.contex save:nil];
    if (self.commondata.is_login){
        [self.serverlogic update_alarm:[self.serverlogic MakeAlarmActionBody:self.alarminfo]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onClickDel:(UIButton*)sender{
    if (self.alarminfo) {
        self.alarminfo.ishidden = [NSNumber numberWithBool:YES];
        self.alarminfo.enable = [NSNumber numberWithBool:NO];
//        [self.contex save:nil];
    }
    [self.contex save:nil];
    [self.mainloop StartSetPersonInfo];
    if (self.commondata.is_login){
        [self.serverlogic update_alarm:[self.serverlogic MakeAlarmActionBody:self.alarminfo]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initControl{
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-65) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorStyle =UITableViewCellSeparatorStyleSingleLine;
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.tableview.tableFooterView = ({
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
    [self.view addSubview:self.tableview];
}

/////////////////////////////
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
    self.alarminfo.enable = [NSNumber numberWithInt:ALARM_ENABLE];
    [self.contex save:nil];
    if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinish:) name:notify_key_did_finish_send_cmd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailed:) name:notify_key_did_finish_send_cmd_err object:nil];

    [self showIndicator];
    [self.mainloop StartSetPersonInfo];
}
-(void)didFailed:(NSNotification*)notify{
    //    self.commondata.is_enable_clock = [[NSUserDefaults standardUserDefaults] boolForKey:CONFIG_KEY_ENABLE_CLOCK];
    [self hideIndicator];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error",nil) message:NSLocalizedString(@"Alarm_Fail", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}
-(void)didFinish:(NSNotification*)notify{
    [self hideIndicator];
    [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Alarm_Finish", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}

#pragma mark --------TableView Method--------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else{
        return 2;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.alarminfo == nil) return 0;
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = [indexPath section];
//    static NSString* checkbox = @"CheckBoxCell";
    static NSString* cellid = @"SimpleCell";
    static NSString* periodid = @"periodid";
//    if (section == 0){
//        switch (indexPath.row) {
//            case 0:{
//                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:checkbox];
//                if (cell == nil) {
//                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:checkbox];
//                }
//                cell.tag = 0;
//                UISwitch* switchview = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
//                [switchview setOnTintColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];
//                [switchview addTarget:self action:@selector(switchTouchUp:) forControlEvents:UIControlEventValueChanged];
//
//                cell.backgroundColor = [UIColor whiteColor];
//                cell.selectionStyle=UITableViewCellSelectionStyleNone;
////                [switchview addTarget:self action:@selector(switchTouchUp:) forControlEvents:UIControlEventValueChanged];
//                [switchview setOn:self.alarminfo.enable.boolValue animated:NO];
//                switchview.tag = 1;
//                cell.textLabel.text = NSLocalizedString(@"Clock_State", nil);
//                cell.textLabel.textColor=[UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
//                cell.accessoryView = switchview;
//                return cell;
//            }
//                break;
//                
//            default:
//                break;
//        }
//    }else
    if(section == 0){
        switch (indexPath.row) {
            case 0:{
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
                }
                cell.tag = 2;
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.textLabel.text = NSLocalizedString(@"Clock_Time", nil);
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.minimumScaleFactor = 0.5;
                cell.textLabel.textColor=[UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
                UIView* content = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,20)];
                UILabel* label = [[UILabel alloc] initWithFrame:content.bounds];
                label.textAlignment = NSTextAlignmentRight;
                label.textColor=[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
//                label.font = [UIFont systemFontOfSize:14];
                label.text = [self format_time:self.alarminfo.hour.intValue minute:self.alarminfo.minute.intValue];
                [content addSubview:label];
                cell.accessoryView = content;
                return cell;

            }
                break;
            case 1:{
                UIColor* selectcolor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1];
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:periodid];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:periodid];
                }
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
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
                cell.tag = 203;
                [cell addSubview:btnview];
                return cell;
                
            }
                break;

            default:
                break;
        }
 
    }else{
        return nil;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //该方法响应列表中行的点击事件
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case 2:{
            NSCalendar* ca = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents* comp = [ca components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
            [comp setHour:self.alarminfo.hour.intValue];
            [comp setMinute:self.alarminfo.minute.intValue];
            NSDate* d = [ca dateFromComponents:comp];
            ActionSheetDatePicker* ap = [[ActionSheetDatePicker alloc] initWithTitle:NSLocalizedString(@"Clock_Interval", nil) datePickerMode:UIDatePickerModeTime selectedDate:d doneBlock:^(ActionSheetDatePicker *picker, NSDate *selectedDate, id origin) {
                NSCalendar* ca = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents* comp = [ca components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:selectedDate];
                
                self.alarminfo.hour = [NSNumber numberWithInt:(int)comp.hour];
                self.alarminfo.minute = [NSNumber numberWithInt:(int)comp.minute];
                [self.tableview reloadData];
                
            } cancelBlock:nil origin:self.view];
            ap.minuteInterval = 1;
            [ap showActionSheetPicker];
            
        } break;
//        case 3:{
//            LWClockPeriodViewController *vc=[LWClockPeriodViewController new];
//            vc.alarminfo = self.alarminfo;
//            [self.navigationController pushViewController:vc animated:YES];
//            
//        } break;
//        case 5: [self onClickSync]; break;
        default: break;
    }
}


-(void) switchTouchUp:(id)sender{
    UISwitch * switchview = (UISwitch*)sender;
    switch (switchview.tag) {
        case 1:
            self.alarminfo.enable =[NSNumber numberWithBool:switchview.on];
            break;
        default:
            break;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (pickerView.tag) {
        case 112:
            return 30;
            break;
        case 118:
            return 10;
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d",(int)row];
}
/////////////////////////////////////////////////////////////////////
//ActionsheetCustomDelegate

- (void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView{
    switch (actionSheetPicker.tag) {
        case 12:
            pickerView.tag = 112;
            [pickerView selectRow:self.alarminfo.snooze.intValue inComponent:0 animated:YES];
            break;
            
        case 18:
            pickerView.tag = 118;
            [pickerView selectRow:self.alarminfo.snooze_repeat.intValue inComponent:0 animated:YES];
            break;
            
        default:
            break;
    }
}
- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin{
    switch (actionSheetPicker.tag) {
        case  12:{
            UIPickerView * picker = (UIPickerView *)actionSheetPicker.pickerView;
            self.alarminfo.snooze =[NSNumber numberWithInt:(int)[picker selectedRowInComponent:0]];
            [self.tableview reloadData];
            break;
        }
        case  18:{
            UIPickerView * picker = (UIPickerView *)actionSheetPicker.pickerView;
            self.alarminfo.snooze_repeat =[NSNumber numberWithInt:(int)[picker selectedRowInComponent:0]];
            [self.tableview reloadData];
            break;
        }
        default:
            break;
    }
    
}

/////////////////////////////////////////////////////////////////////


-(NSString*)format_time:(int)hour minute:(int)min{
    NSDate* date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit |NSHourCalendarUnit;
    
    comps = [calendar components:unitFlags fromDate:date];
    comps.hour = hour;
    comps.minute = min;
    NSDate* d = [calendar dateFromComponents:comps];
    
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"hh:mm a";
    
    NSString* str = [format stringFromDate:d];
    return str;
    
}

-(void)onChange:(UITextField*)sender{
    if (sender.tag == 100) {
        self.alarminfo.name = sender.text;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}
-(void)onEndEdit:(UITextField*)sender{
    [sender resignFirstResponder];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//#ifdef CUSTOM_ZZB
//    [self.mainloop set_alarm_name_index:self.currentIndex];
//#endif
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
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
    [self.tableview reloadData];
}

@end
