//
//  SWDisturbViewController.m
//  smartwristband
//
//  Created by 张志鹏 on 16/9/20.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "SWDisturbViewController.h"
#import "YUDatePicker.h"
#import "MainLoop.h"
#import "BleControl.h"
#import "IRKCommonData.h"
#import "CommonDefine.h"
@interface SWDisturbViewController ()

@property(nonatomic, strong) IRKCommonData* commondata;
@property(nonatomic, strong) UITableView* tableview;
@property (nonatomic, strong) BleControl* blecontrol;
@property (nonatomic, strong) MainLoop* mainloop;
@property(nonatomic, strong)DataCenter* datacenter;

@property(nonatomic,strong)UILabel *titleLabel;

@property (nonatomic, strong)YUDatePicker *datePicker;

@property (nonatomic, assign)NSInteger selectedRow;

@property (nonatomic, assign)NSInteger pickerHeight;
@end

@implementation SWDisturbViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.hidesBackButton =YES;
    
    _selectedRow = 0;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.blecontrol = [BleControl SharedInstance];
    self.mainloop = [MainLoop SharedInstance];
    self.datacenter = [DataCenter SharedInstance];
    [self initNav];
    [self initcontrol];
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
    label.text=NSLocalizedString(@"Config_Cell_NoDisturb", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
    
    UIButton * btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
//    UIImageView * backimg2 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
//    backimg2.image = [UIImage imageNamed:@"icon_confirm.png"];
//    backimg2.contentMode = UIViewContentModeScaleAspectFit;
//    [btn2 addSubview:backimg2];
    [btn2 setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn2.titleLabel.adjustsFontSizeToFitWidth = YES;
    btn2.titleLabel.minimumScaleFactor = 0.5;
    [btn2 addTarget:self action:@selector(onClickConfirm:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn2];

}
-(void)initcontrol{
    self.view.backgroundColor = [UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStyleGrouped];
    self.tableview.delegate = (id)self;
    self.tableview.dataSource = (id)self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableview];
}


- (void)onClickGoback:(id)sender{
//    [self.mainloop setConfigParam];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onClickConfirm:(UIButton*)sender{
//    [self.mainloop setConfigParam];
    [self.mainloop sendCmd:CMD_SETPARAM];
    [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"action_save_aaronli_success", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 1) return 2;
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *GealId = @"GearCell";
    NSString* simple = @"simple";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:simple];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simple];
    }
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView* v = (UIView*)obj;
        [v removeFromSuperview];
        v = nil;
    }];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    cell.textLabel.text = @"";
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
   
    if(indexPath.section == 0){
        cell.textLabel.text = NSLocalizedString(@"Config_Cell_NoDisturb", nil);
        cell.textLabel.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
        UISwitch* sw = [[UISwitch alloc] init];
        //[sw setOnTintColor:self.commondata.colorNav];
        [sw setOnTintColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];

        [sw setOn:self.commondata.is_enable_nodistrub];
        [sw addTarget:self action:@selector(onSwitchChange:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;
    }else if(indexPath.section == 1){
        NSString *beginDate = nil;
        NSString *endDate = nil;
        NSMutableDictionary* bonginfo = (NSMutableDictionary*)[self.commondata getBongInformation:self.commondata.lastBongUUID];
        if (bonginfo){
            beginDate = [bonginfo objectForKey:BONGINFO_KEY_DISTURB_STARTTIME];
            endDate = [bonginfo objectForKey:BONGINFO_KEY_DISTURB_ENDTIME];
        }
        if(!beginDate){
            beginDate = @"23:00";
            [bonginfo setObject:beginDate forKey:BONGINFO_KEY_DISTURB_STARTTIME];
            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
        }
        if(!endDate){
            endDate = @"08:00";
            [bonginfo setObject:endDate forKey:BONGINFO_KEY_DISTURB_ENDTIME];
            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
        }
        
        cell.textLabel.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-120, 0, 100, 44)];
        timeLabel.font = [UIFont systemFontOfSize:16];
        timeLabel.textAlignment = NSTextAlignmentRight;
        
        if(_selectedRow == indexPath.row)
            timeLabel.textColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
        else
            timeLabel.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
        
        NSArray *arraybegin = [beginDate componentsSeparatedByString:@":"];
        int beginhour = [arraybegin[0] intValue];
        int beginmin = [arraybegin[1] intValue];
        NSArray *arrayend = [endDate componentsSeparatedByString:@":"];
        int endhour = [arrayend[0] intValue];
        int endmin = [arrayend[1] intValue];
        
        if(indexPath.row == 0){
            
            cell.textLabel.text = NSLocalizedString(@"nodistrub_start", nil);
            timeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"nodistrub_first", nil),beginDate];
        }else{
//            if(_selectedRow == 1) cell.backgroundColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
//            else cell.backgroundColor = [UIColor whiteColor];
            
            cell.textLabel.text = NSLocalizedString(@"nodistrub_end", nil);
            if (beginhour > endhour) {
                timeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"nodistrub_next", nil),endDate];

            }else if(beginhour < endhour){
                timeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"nodistrub_first", nil),endDate];

            }else{
                if (beginmin > endmin) {
                    timeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"nodistrub_next", nil),endDate];
                }else{
                    timeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"nodistrub_first", nil),endDate];
                  
                }
            }
        }
        timeLabel.tag = 1024;
        timeLabel.adjustsFontSizeToFitWidth = YES;
        timeLabel.minimumScaleFactor = 0.5;
        [cell.contentView addSubview:timeLabel];
    }else if(indexPath.section == 2){
        CGFloat yOffset = (_pickerHeight - 216) * 0.5;
        _datePicker = [ [ YUDatePicker alloc] initWithFrame:CGRectMake(0, yOffset, CGRectGetWidth(self.view.frame), 216)];
        _datePicker.datePickerMode = UIYUDatePickerModeClock;
        [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:_datePicker];
        
        NSString *beginDate = nil;
        NSString *endDate = nil;
        NSMutableDictionary* bonginfo = (NSMutableDictionary*)[self.commondata getBongInformation:self.commondata.lastBongUUID];
        if (bonginfo){
            beginDate = [bonginfo objectForKey:BONGINFO_KEY_DISTURB_STARTTIME];
            endDate = [bonginfo objectForKey:BONGINFO_KEY_DISTURB_ENDTIME];
        }
        
        if(_selectedRow == 0){
            if(!beginDate){
                [self.datePicker setHour:23 andMinute:0];
            }else{
                NSString *hour = nil;
                NSString *minute = nil;
                NSArray *array = [beginDate componentsSeparatedByString:@":"];
                if([array count] >= 2){
                    hour = [array objectAtIndex:0];
                    minute = [array objectAtIndex:1];
                }
                [self.datePicker setHour:hour.intValue andMinute:minute.intValue];
            }
        }else{
            if(!endDate){
                [self.datePicker setHour:8 andMinute:0];
            }else{
                NSString *hour = nil;
                NSString *minute = nil;
                NSArray *array = [endDate componentsSeparatedByString:@":"];
                if([array count] >= 2){
                    hour = [array objectAtIndex:0];
                    minute = [array objectAtIndex:1];
                }
                [self.datePicker setHour:hour.intValue andMinute:minute.intValue];
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 2){
        _pickerHeight = CGRectGetHeight(self.view.frame) * 0.4;
        if(_pickerHeight < 216)
            _pickerHeight = 216;
        return _pickerHeight;
    }
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 2) return 40;
    else return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 2){
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
        view.backgroundColor = [UIColor clearColor];
        
        UILabel* tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.view.frame), 40)];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.textColor = [UIColor blackColor];
        tipLabel.textAlignment = NSTextAlignmentLeft;
        tipLabel.font = [UIFont systemFontOfSize:14];
        tipLabel.text = NSLocalizedString(@"nodistrub_settime", nil);
        [view addSubview:tipLabel];
        return view;
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if(section == 1){
        
        if(row != _selectedRow){
            NSIndexPath *lastPath = [NSIndexPath indexPathForRow:_selectedRow inSection:1];
            UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:lastPath];
            UILabel* label = [lastCell viewWithTag:1024];
            label.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
//            lastCell.backgroundColor = [UIColor whiteColor];
            
            _selectedRow = row;
            
            UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            UILabel* label1 = [selectedCell viewWithTag:1024];
            label1.textColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
//            selectedCell.backgroundColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
            
            //刷新datePicker section
            NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:2];
            
            [self.tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    return NO;
}

- (void)onSwitchChange:(UISwitch *)sender{
    self.commondata.is_enable_nodistrub = sender.on;
    [self.commondata saveconfig];
}

-(void)dateChanged:(YUDatePicker*)sender{
    NSDateFormatter* format = [[NSDateFormatter alloc]init];
    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    format.dateFormat = [NSString stringWithFormat:@"HH:mm"];
    
    NSString *dateStr = [format stringFromDate:sender.date];
    
    NSMutableDictionary* bonginfo = (NSMutableDictionary*)[self.commondata getBongInformation:self.commondata.lastBongUUID];
    
    if (bonginfo != nil)
    {
        if(_selectedRow == 0)
        {
            [bonginfo setObject:dateStr forKey:BONGINFO_KEY_DISTURB_STARTTIME];
        }
        else
        {
            [bonginfo setObject:dateStr forKey:BONGINFO_KEY_DISTURB_ENDTIME];
        }
            
        [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
    }
    else
    {
        NSLog(@"bongingo is nil");
    }
    
    //对单个cell进行刷新
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectedRow inSection:1];
    NSArray <NSIndexPath *> *indexPathArray = @[[NSIndexPath indexPathForRow:0 inSection:1],[NSIndexPath indexPathForRow:1 inSection:1]];
    [self.tableview reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end




