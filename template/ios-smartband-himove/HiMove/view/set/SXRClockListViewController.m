//
//  SXRClockListViewController.m
//  SXRBand
//
//  Created by qf on 15/8/28.
//  Copyright (c) 2015年 SXR. All rights reserved.
//

#import "SXRClockListViewController.h"
#import "LWClockViewController.h"
#import "IRKCommonData.h"

@interface SXRClockListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView* tableview;
@property(nonatomic,strong)NSManagedObjectContext* context;
@property(nonatomic,strong)NSArray* fetchArrar;
@property(nonatomic,strong)IRKCommonData* commondata;
@property(nonatomic,strong)ServerLogic* serverlogic;
@property(nonatomic,strong)NSMutableArray* showArrar;
@property(nonatomic,strong)NSMutableArray* hiddenArrar;

@end

@implementation SXRClockListViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor =[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.serverlogic = [ServerLogic SharedInstance];
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.context = delegate.managedObjectContext;
    
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
    label.text=NSLocalizedString(@"Clock_Title", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
    
    UIButton * btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImageView * backimg2 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
    backimg2.image = [UIImage imageNamed:@"icon_add.png"];
    backimg2.contentMode = UIViewContentModeScaleAspectFit;
    [btn2 addSubview:backimg2];
    [btn2 addTarget:self action:@selector(onClickAdd:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn2];

}
-(void)onClickBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)initControl{
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor=[UIColor clearColor];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];
}

-(void)onClickAdd:(UIButton*)sender{
    if ([self.hiddenArrar count] == 0) {
        UIAlertController* al = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"add_alarm_max", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
        [al addAction:okAction];
        [self presentViewController:al animated:YES completion:nil];
        return;
    }
    Alarm* record = [self.hiddenArrar firstObject];
    record.ishidden = [NSNumber numberWithBool:NO];
    [self.context save:nil];
    LWClockViewController* vc = [LWClockViewController new];
    vc.alarminfo = record;
//    vc.currentIndex = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.showArrar count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* cellid = @"simple";
    UITableViewCell* cell = [self.tableview dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
    }
    UISwitch* switchview = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [switchview setOnTintColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];
    [switchview addTarget:self action:@selector(onClickSwitch:) forControlEvents:UIControlEventValueChanged];

    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];;
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    Alarm* record = (Alarm*)[self.showArrar objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [self format_time:record.hour.intValue minute:record.minute.intValue];
    cell.detailTextLabel.text = [self format_period:record.weekly.intValue];
    [switchview setOn:record.enable.boolValue];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryView = switchview;
    switchview.tag = indexPath.row;
    return cell;
}
-(void)onClickSwitch:(UISwitch*)sender{
    Alarm* record = (Alarm*)[self.showArrar objectAtIndex:sender.tag];
    record.enable = [NSNumber numberWithBool:sender.on];
    [self.context save:nil];
    [[MainLoop SharedInstance] StartSetPersonInfo];

}

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

-(NSString*)format_period:(int)period{
    if (period == WORKDAY) {
        return NSLocalizedString(@"WorkDay", nil);
    }else if(period == ALLDAY){
        return NSLocalizedString(@"AllDay", nil);
    }else{
        NSString* str = @"";
        if ((period & PERIOD_1) == 1) {
            str = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Sunday", nil)];
        }
        if (((period & PERIOD_2)>>1) == 1) {
            if ([str length]) {
                str = [NSString stringWithFormat:@"%@,%@",str,NSLocalizedString(@"Monday", nil)];
            }else{
                str = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Monday", nil)];
            }
        }
        if (((period & PERIOD_3)>>2) == 1) {
            if ([str length]) {
                str = [NSString stringWithFormat:@"%@,%@",str,NSLocalizedString(@"Tuesday", nil)];
            }else{
                str = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Tuesday", nil)];
            }
        }
        if (((period & PERIOD_4)>>3) == 1) {
            if ([str length]) {
                str = [NSString stringWithFormat:@"%@,%@",str,NSLocalizedString(@"Wednesday", nil)];
            }else{
                str = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Wednesday", nil)];
            }
        }
        if (((period & PERIOD_5)>>4) == 1) {
            if ([str length]) {
                str = [NSString stringWithFormat:@"%@,%@",str,NSLocalizedString(@"Thursday", nil)];
            }else{
                str = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Thursday", nil)];
            }
        }
        if (((period & PERIOD_6)>>5) == 1) {
            if ([str length]) {
                str = [NSString stringWithFormat:@"%@,%@",str,NSLocalizedString(@"Friday", nil)];
            }else{
                str = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Friday", nil)];
            }
        }
        if (((period & PERIOD_7)>>6) == 1) {
            if ([str length]) {
                str = [NSString stringWithFormat:@"%@,%@",str,NSLocalizedString(@"Saturday", nil)];
            }else{
                str = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Saturday", nil)];
            }
        }
        if ([str length]==0) {
            return NSLocalizedString(@"NoDay", nil);
        }else{
            return str;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LWClockViewController* vc = [LWClockViewController new];
    Alarm* alarminfo = [self.showArrar objectAtIndex:indexPath.row];
    vc.alarminfo = alarminfo;
    vc.currentIndex = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

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
    self.showArrar = [[NSMutableArray alloc] init];
    self.hiddenArrar = [[NSMutableArray alloc] init];
    NSError* error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"macid=%@ and uid = %@ and type = %@", macid, self.commondata.uid,[NSNumber numberWithInt:ALARM_TYPE_TIMER]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"alarm_id" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    
    self.fetchArrar = [self.context executeFetchRequest:fetchRequest error:&error];
    int maxalarmcount;
    
//    NSString* version = [self.commondata getValueFromBonginfoByKey:BONGINFO_KEY_VERSIONCODE];
//    if ([self.commondata.gear_subtype isEqualToString:GEAR_SUBTYPE_E06])
//    {
//        maxalarmcount = 1;
//    }else{
        maxalarmcount = ALARM_MAX_COUNT_TIMER;
//    }
    if ([self.fetchArrar count] < maxalarmcount) {
        for (int i = 0; i< [self.fetchArrar count]; i++) {
            Alarm* record = (Alarm*)[self.fetchArrar objectAtIndex:i];
            record.alarm_id = [NSNumber numberWithInt:i];
            [self.serverlogic update_alarm:[self.serverlogic MakeAlarmActionBody:record]];
            if (record.ishidden.boolValue == NO) {
                [self.showArrar addObject:record];
            }else{
                [self.hiddenArrar addObject: record];
            }
        }
        for (long int j=[self.fetchArrar count]; j<maxalarmcount; j++) {
            Alarm* record = (Alarm*)[NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:self.context];
            record.alarm_id = [NSNumber numberWithLong:j];
            record.type = [NSNumber numberWithInt:ALARM_TYPE_TIMER];
            record.uid = self.commondata.uid;
            record.macid = macid;
            record.createtime = [NSDate date];
            record.hour = [NSNumber numberWithInt:7];
            record.minute = [NSNumber numberWithInt:0];
            record.weekly = [NSNumber numberWithInt:62];
            record.enable = [NSNumber numberWithInt:0];
            record.snooze = [NSNumber numberWithInt:0];
            record.snooze_repeat = [NSNumber numberWithInt:0];
            record.vib_number = [NSNumber numberWithInt:3];
            record.vib_repeat = [NSNumber numberWithInt:3];
            record.ishidden = [NSNumber numberWithBool:YES];
            record.name =[NSString stringWithFormat:@"%@ %ld",NSLocalizedString(@"TIMER_NAME", nil),j+1];

            [self.serverlogic update_alarm:[self.serverlogic MakeAlarmActionBody:record]];
            [self.hiddenArrar addObject:record];
        }
        [self.context save:nil];
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
        return;
    }else{
        for(Alarm* record in self.fetchArrar){
            if (record.ishidden.boolValue == NO) {
                [self.showArrar addObject:record];
            }else{
                [self.hiddenArrar addObject:record];
            }
        }
    }
    
    
    [self.tableview reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
