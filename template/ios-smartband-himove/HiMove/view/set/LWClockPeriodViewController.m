//
//  LWClockPeriodViewController.m
//  Lovewell
//
//  Created by qf on 14-8-28.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "LWClockPeriodViewController.h"
#import "DCRoundSwitch.h"

@interface LWClockPeriodViewController ()

@end

@implementation LWClockPeriodViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.tableview reloadData];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    [self initNav];
    [self initcontrol];
    
}
-(void)initNav{
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    UIImageView * backimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 22, 18)];
    backimg.image = [UIImage imageNamed:@"icon_back"];
    backimg.contentMode = UIViewContentModeScaleAspectFit;
    [btn addSubview:backimg];
    [btn addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectZero];
    label.textColor=[UIColor blackColor];
    label.text=NSLocalizedString(@"Period_Title", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}

-(void)onClickBack:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initcontrol{
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-65) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.dataSource = self;
    self.tableview.delegate =self;
    [self.view addSubview:self.tableview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];
    static NSString* checkbox = @"CheckBoxCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:checkbox];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:checkbox];
    }

    DCRoundSwitch *switchview = [[DCRoundSwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [switchview setOffTintColor:[UIColor colorWithRed:0/255.0 green:2/255.0 blue:60/255.0 alpha:1.0f]];
    [switchview setOnTintColor:[UIColor colorWithRed:0/255.0 green:2/255.0 blue:60/255.0 alpha:1.0f]];
    
    [switchview setOnKnobColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0]];
    [switchview setOffKnobColor:[UIColor colorWithRed:0/255.0 green:2/255.0 blue:60/255.0 alpha:1.0f]];
    
    cell.backgroundColor = [UIColor whiteColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [switchview addTarget:self action:@selector(switchTouchUp:) forControlEvents:UIControlEventValueChanged];
    int weekly = 0;
    if (self.alarminfo != nil) {
        weekly = self.alarminfo.weekly.intValue;
    }
    switch (row) {
        case 0:
            [switchview setOn:(weekly & PERIOD_1) == 1?YES:NO animated:YES];
            switchview.tag = 11;
            cell.tag = row;
            cell.textLabel.text = NSLocalizedString(@"Sunday", nil);
            break;
        case 1:
            [switchview setOn:((weekly & PERIOD_2)>>1) == 1?YES:NO animated:YES];
            switchview.tag = 12;
            cell.tag = row;
            cell.textLabel.text = NSLocalizedString(@"Monday", nil);
            break;
        case 2:
            [switchview setOn:((weekly & PERIOD_3)>>2) == 1?YES:NO animated:YES];
            switchview.tag = 13;
            cell.tag = row;
            cell.textLabel.text = NSLocalizedString(@"Tuesday", nil);
            break;
        case 3:
            [switchview setOn:((weekly & PERIOD_4)>>3) == 1?YES:NO animated:YES];
            switchview.tag = 14;
            cell.tag = row;
            cell.textLabel.text = NSLocalizedString(@"Wednesday", nil);
            break;
        case 4:
            [switchview setOn:((weekly & PERIOD_5)>>4) == 1?YES:NO animated:YES];
            switchview.tag = 15;
            cell.tag = row;
            cell.textLabel.text = NSLocalizedString(@"Thursday", nil);
            break;
        case 5:
            [switchview setOn:((weekly & PERIOD_6)>>5) == 1?YES:NO animated:YES];
            switchview.tag = 16;
            cell.tag = row;
            cell.textLabel.text = NSLocalizedString(@"Friday", nil);
            break;
        case 6:
            [switchview setOn:((weekly & PERIOD_7)>>6) == 1?YES:NO animated:YES];
            switchview.tag = 17;
            cell.tag = row;
            cell.textLabel.text = NSLocalizedString(@"Saturday", nil);
            break;
        default:
            break;
    }
    cell.accessoryView = switchview;

    return cell;
    
}

-(void) switchTouchUp:(id)sender{
    UISwitch * switchview = (UISwitch*)sender;
    int weekly = 0;
    if (self.alarminfo != nil) {
        weekly = self.alarminfo.weekly.intValue;
    }
    switch (switchview.tag) {
        case 11:
            if (switchview.on) {
                weekly = weekly|PERIOD_1;
            }else{
                weekly = weekly&(~PERIOD_1);
            }
            break;
        case 12:
            if (switchview.on) {
                weekly = weekly|PERIOD_2;
            }else{
                weekly = weekly&(~PERIOD_2);
            }
            break;
        case 13:
            if (switchview.on) {
                weekly = weekly|PERIOD_3;
            }else{
                weekly = weekly&(~PERIOD_3);
            }
            break;
        case 14:
            if (switchview.on) {
                weekly = weekly|PERIOD_4;
            }else{
                weekly = weekly&(~PERIOD_4);
            }
            break;
        case 15:
            if (switchview.on) {
                weekly = weekly|PERIOD_5;
            }else{
                weekly = weekly&(~PERIOD_5);
            }
            break;
        case 16:
            if (switchview.on) {
                weekly = weekly|PERIOD_6;
            }else{
                weekly = weekly&(~PERIOD_6);
            }
            break;
        case 17:
            if (switchview.on) {
                weekly = weekly|PERIOD_7;
            }else{
                weekly = weekly&(~PERIOD_7);
            }
            break;
            
        default:
            break;
    }
    self.alarminfo.weekly = [NSNumber numberWithInt:weekly];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
