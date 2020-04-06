//
//  SXRSleepSetViewController.m
//  SXRBand
//
//  Created by qf on 15/8/28.
//  Copyright (c) 2015年 SXR. All rights reserved.
//

#import "SXRSleepSetViewController.h"
#import "ActionSheetDatePicker.h"
#import "ActionSheetDatePicker.h"

@interface SXRSleepSetViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)IRKCommonData* commondata;
@property(nonatomic,strong)DataCenter* datacenter;
@property(nonatomic,strong)BleControl* blecontrol;
@property(nonatomic,strong)MainLoop* mainloop;
@property(nonatomic,strong)UITableView* tableview;
@property (strong, nonatomic)UIActivityIndicatorView* indicator;

@property(nonatomic, strong)NSDate* startTime;
@property(nonatomic, assign)NSInteger startHour;
@property(nonatomic, assign)NSInteger startMin;
@property(nonatomic, strong)NSDate* endTime;
@property(nonatomic, assign)NSInteger endHour;
@property(nonatomic, assign)NSInteger endMin;

@end

@implementation SXRSleepSetViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.tableview reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinish:) name:notify_key_did_finish_send_cmd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailed:) name:notify_key_did_finish_send_cmd_err object:nil];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.blecontrol = [BleControl SharedInstance];
    self.mainloop = [MainLoop SharedInstance];
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
    label.text=NSLocalizedString(@"Config_Cell_Sleep", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}

-(void)onClickBack:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initcontrol{
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-65) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor=[UIColor clearColor];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    [self.view addSubview:self.tableview];
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
    if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        return;
    }
    [self showIndicator];
    
    [self.mainloop StartSetSleepset];
}


-(void)didFailed:(NSNotification*)notify{
    //    self.commondata.is_enable_clock = [[NSUserDefaults standardUserDefaults] boolForKey:CONFIG_KEY_ENABLE_CLOCK];
    [self hideIndicator];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error",nil) message:NSLocalizedString(@"ModeSet_Fail", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}
-(void)didFinish:(NSNotification*)notify{
    [self hideIndicator];
    [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ModeSet_Finish", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSUInteger section = [indexPath section];
    static NSString* checkbox = @"CheckBoxCell";
    NSMutableDictionary* bonginfo = (NSMutableDictionary*)[self.commondata getBongInformation:self.commondata.lastBongUUID];
    //[bonginfo1 setObject:[[NSDate date] dateByAddingTimeInterval:24*60*60]  forKey:BONGINFO_KEY_AUTHEXPIRE];
    //[bi setObject:name forKey:BONGINFO_KEY_SLEEPSTARTTIME];
    //[bi setObject:name forKey:BONGINFO_KEY_SLEEPENDTIME];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:checkbox];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:checkbox];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
    if(indexPath.row == 0){
        cell.tag = 0;
        cell.textLabel.text = NSLocalizedString(@"Clock_Begin_Time", nil);
        cell.textLabel.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
        UIView* content = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,20)];
        UILabel* label = [[UILabel alloc] initWithFrame:content.bounds];
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:14];
        //从bonginfo获取开始时间
        if ([bonginfo.allKeys containsObject:BONGINFO_KEY_SLEEPSTARTTIME]){
            _startTime = [bonginfo objectForKey:BONGINFO_KEY_SLEEPSTARTTIME];
        }
        //获取开始时间年月日
        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];

        if(_startTime == nil){
            _startHour = 22;
            _startMin = 0;
            label.text = [self format_time:22 minute:0];
        }else{
            comps = [calendar components:unitFlags fromDate:_startTime];
            _startHour = [comps hour];
            _startMin = [comps minute];

            label.text = [self format_time:(int)_startHour minute:(int)_startMin];
        }
        label.textColor =  [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
        [content addSubview:label];
        cell.accessoryView = content;
        return cell;
    }else if(indexPath.row == 1){
        cell.tag = 1;
        cell.textLabel.text = NSLocalizedString(@"Clock_End_Time", nil);
        cell.textLabel.textColor =  [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
        UIView* content = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,20)];
        UILabel* label = [[UILabel alloc] initWithFrame:content.bounds];
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:14];
        //从bonginfo获取结束时间
        if ([bonginfo.allKeys containsObject:BONGINFO_KEY_SLEEPENDTIME]){
            _endTime = [bonginfo objectForKey:BONGINFO_KEY_SLEEPENDTIME];
        }
        //获取开始时间年月日
        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        if(_endTime == nil){
            _endHour = 8;
            _endMin = 0;
            label.text = [self format_time:8 minute:0];
        }
        else{
            comps = [calendar components:unitFlags fromDate:_endTime];
            _endHour = [comps hour];
            _endMin = [comps minute];
            label.text = [self format_time:(int)_endHour minute:(int)_endMin];
        }
        label.textColor =  [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
        [content addSubview:label];
        cell.accessoryView = content;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //该方法响应列表中行的点击事件
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSMutableDictionary* bonginfo = (NSMutableDictionary*)[self.commondata getBongInformation:self.commondata.lastBongUUID];
    switch (cell.tag) {
        case 0:{
            NSCalendar* ca = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents* comp = [ca components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
            
            if(_startTime == nil){
                [comp setHour:22];
                [comp setMinute:0];
            }else{
                [comp setHour:_startHour];
                [comp setMinute:_startMin];
            }

            NSDate* d = [ca dateFromComponents:comp];
            ActionSheetDatePicker* ap = [[ActionSheetDatePicker alloc] initWithTitle:NSLocalizedString(@"Clock_Interval", nil) datePickerMode:UIDatePickerModeTime selectedDate:d doneBlock:^(ActionSheetDatePicker *picker, NSDate *selectedDate, id origin) {
//                NSCalendar* ca = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//                NSDateComponents* comp = [ca components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:selectedDate];
                [bonginfo setObject:selectedDate  forKey:BONGINFO_KEY_SLEEPSTARTTIME];
                [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
                
                [self.tableview reloadData];
             
            } cancelBlock:nil origin:self.view];
            
            //设置可选的时间范围(18:00~23:59)
            NSDate *date = [NSDate date];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
            [gregorian setTimeZone:gmt];
            NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
            [components setHour: 15];
            [components setMinute:59];
            [components setSecond:0];
//            NSDate *maxDate = [gregorian dateFromComponents: components];
            
            
            NSDateComponents *components1 = [gregorian components: NSUIntegerMax fromDate: date];
            [components1 setHour: 10];
            [components1 setMinute:0];
            [components1 setSecond:0];
//            NSDate *minDate = [gregorian dateFromComponents: components1];
            
//            ap.maximumDate = maxDate;
//            ap.minimumDate = minDate;
            ap.minuteInterval = 1;
            [ap showActionSheetPicker];
        } break;
        case 1:{
            NSCalendar* ca = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents* comp = [ca components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
            
            if(_endTime == nil)
            {
                [comp setHour:8];
                [comp setMinute:0];
            }
            else
            {
                [comp setHour:_endHour];
                [comp setMinute:_endMin];
            }
            NSDate* d = [ca dateFromComponents:comp];
            ActionSheetDatePicker* ap = [[ActionSheetDatePicker alloc] initWithTitle:NSLocalizedString(@"Clock_Interval", nil) datePickerMode:UIDatePickerModeTime selectedDate:d doneBlock:^(ActionSheetDatePicker *picker, NSDate *selectedDate, id origin) {
//                NSCalendar* ca = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//                NSDateComponents* comp = [ca components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:selectedDate];
                [bonginfo setObject:selectedDate  forKey:BONGINFO_KEY_SLEEPENDTIME];
                [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
                
                [self.tableview reloadData];
                
            } cancelBlock:nil origin:self.view];
            
            
            //设置可选的时间范围(06:00~11:59)
            NSDate *date = [NSDate date];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
            [gregorian setTimeZone:gmt];
            NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
            [components setHour: 3];
            [components setMinute:59];
            [components setSecond:0];
//            NSDate *maxDate = [gregorian dateFromComponents: components];
            
            
            NSDateComponents *components1 = [gregorian components: NSUIntegerMax fromDate: date];
            [components1 setHour: -2];
            [components1 setMinute:0];
            [components1 setSecond:0];
//            NSDate *minDate = [gregorian dateFromComponents: components1];
            
//            ap.maximumDate = maxDate;
//            ap.minimumDate = minDate;
            
            ap.minuteInterval = 1;
            [ap showActionSheetPicker];
        } break;
        default: break;
    }
}


-(void) switchTouchUp:(id)sender{
    UISwitch * switchview = (UISwitch*)sender;
    switch (switchview.tag) {
        case 0:{
            NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
            if (bonginfo == nil) {
                bonginfo = [[NSMutableDictionary alloc] init];
            }
            if (switchview.on){
                [bonginfo setObject:DEF_ENABLE forKey:BONGINFO_KEY_SLEEP1_ENABLE];
            }else{
                [bonginfo setObject:DEF_DISABLE forKey:BONGINFO_KEY_SLEEP1_ENABLE];

            }
            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
        }
            break;
        case 3:
        {
            NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
            if (bonginfo == nil) {
                bonginfo = [[NSMutableDictionary alloc] init];
            }
            if (switchview.on){
                [bonginfo setObject:DEF_ENABLE forKey:BONGINFO_KEY_SLEEP2_ENABLE];
            }else{
                [bonginfo setObject:DEF_DISABLE forKey:BONGINFO_KEY_SLEEP2_ENABLE];
                
            }
            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
        }
            break;
        case 6:
        {
            NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
            if (bonginfo == nil) {
                bonginfo = [[NSMutableDictionary alloc] init];
            }
            if (switchview.on){
                [bonginfo setObject:DEF_ENABLE forKey:BONGINFO_KEY_SLEEP3_ENABLE];
            }else{
                [bonginfo setObject:DEF_DISABLE forKey:BONGINFO_KEY_SLEEP3_ENABLE];
                
            }
            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
        }
            break;
        default:
            break;
    }
    [self.tableview reloadData];
}

/////////////////////////////////////////////////////////////////////
//ActionsheetCustomDelegate


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

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

-(void)onEndEdit:(UITextField*)sender{
    [sender resignFirstResponder];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
