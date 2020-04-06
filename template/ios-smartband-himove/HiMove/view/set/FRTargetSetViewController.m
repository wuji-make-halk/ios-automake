//
//  FRTargetSetViewController.m
//  SXRBand
//
//  Created by qf on 16/3/22.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "FRTargetSetViewController.h"
#import "ImageLargeTableViewCell.h"
#import "ActionSheetDatePicker.h"
#import "ActionSheetCustomPicker.h"

@interface FRTargetSetViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate,ActionSheetCustomPickerDelegate,UITextFieldDelegate>
@property (nonatomic, strong) IRKCommonData* commondata;
@property (nonatomic, strong) UITableView* tableview;
@property BOOL nibsEditCellRegistered;


@end

@implementation FRTargetSetViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.nibsEditCellRegistered = NO;
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
    label.text=NSLocalizedString(@"LeftMenu_TargetSet", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}

-(void)initcontrol{
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-65) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableview];
    self.tableview.tableFooterView =({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 80)];
        view.backgroundColor = [UIColor clearColor];
        UIButton* reset = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.1, 20, CGRectGetWidth(self.view.frame)*0.8, 60)];
        reset.backgroundColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1];
        [reset setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [reset setTitle:NSLocalizedString(@"Reset", nil) forState:UIControlStateNormal];
        [reset addTarget:self action:@selector(onReset:) forControlEvents:UIControlEventTouchUpInside];
        reset.layer.cornerRadius = 5;
        [view addSubview:reset];
        view;
    });
}

-(void)onClickBack:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)onReset:(id)sender{
    self.commondata.target_steps = 10000;
    self.commondata.target_distance = 10;
    self.commondata.target_calorie = 500;
    self.commondata.target_sleeptime = 8*60*60;
    self.commondata.target_runsteps = 10000;
    [self.tableview reloadData];
}
///////////////////////////////////////////////////
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
//新建某一行并返回
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellstr = @"EditCell";
    ImageLargeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellstr];
    if (cell == nil) {
        cell = [[ImageLargeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellstr];
    }
    UIColor* titlecolor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
    UIColor* contentcolor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];

    cell.tag = indexPath.row;
    UILabel* textlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame)/2.0, 40)];
    cell.accessoryView = textlabel;
    textlabel.textColor = contentcolor;
    cell.textLabel.textColor = titlecolor;
    textlabel.textAlignment = NSTextAlignmentRight;
    textlabel.font = [UIFont systemFontOfSize:16];

    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.backgroundColor = [UIColor whiteColor];
    cell.tag = indexPath.row;
    switch (indexPath.row) {
        case 0:
            cell.imageView.image = [UIImage imageNamed:@"home_1_1.png"];
            cell.textLabel.text = NSLocalizedString(@"TargetSet_Steps", nil);
            textlabel.text =[NSString stringWithFormat:@"%d",(int)self.commondata.target_steps];
            break;
        case 1:{

            cell.imageView.image = [UIImage imageNamed:@"home_2_1.png"];
            cell.textLabel.text = NSLocalizedString(@"TargetSet_Distance", nil);
//            UITextField* text_value = [[UITextField alloc] initWithFrame:CGRectMake(0, 15, 100, 40)];
//            text_value.backgroundColor = [UIColor clearColor];
//            //_textField = text_value;
//            text_value.returnKeyType = UIReturnKeyDone;
//            text_value.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
//            text_value.textAlignment = NSTextAlignmentRight;
//            text_value.delegate = self;
//            text_value.textColor = contentcolor;
//            text_value.font = [UIFont systemFontOfSize:16];
            
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX){
                textlabel.text = [NSString stringWithFormat:@"%.1f %@",self.commondata.target_distance,NSLocalizedString(@"UNIT_KM", nil)];
            }else{
                textlabel.text = [NSString stringWithFormat:@"%.1f %@",self.commondata.target_distance,NSLocalizedString(@"UNIT_MILE", nil)];
            }
//            cell.accessoryView = text_value;
//            text_value.delegate = self;
//            cell.tag = 102;
//            text_value.tag = 1020;

        }
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"home_3_1.png"];
            cell.textLabel.text = NSLocalizedString(@"TargetSet_Cal", nil);
            textlabel.text = [NSString stringWithFormat:@"%.0f %@",self.commondata.target_calorie,NSLocalizedString(@"UNIT_KCAL", nil)];
            break;
//        case 1:
//            cell.imageView.image = [UIImage imageNamed:@"icon_pz_goal_running.png"];
//            cell.textLabel.text = NSLocalizedString(@"TargetSet_Running", nil);
//            textlabel.text =[NSString stringWithFormat:@"%ld",self.commondata.target_runsteps];
//            break;
        default:
            break;
    }
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
            ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"TargetSet_Steps", nil) delegate:self showCancelButton:YES origin:self.view];
            ap.tag = 100;
            [ap showActionSheetPicker];
        }
            break;
        case 1: {
            ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"TargetSet_Distance", nil) delegate:self showCancelButton:YES origin:self.view];
            ap.tag = 101;
            [ap showActionSheetPicker];
        }
            break;
        case 2:{
            ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"TargetSet_Cal", nil) delegate:self showCancelButton:YES origin:self.view];
            ap.tag = 102;
            [ap showActionSheetPicker];
        }
            break;
//        case 1:{
//            ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"TargetSet_Running", nil) delegate:self showCancelButton:YES origin:self.view];
//            ap.tag = 104;
//            [ap showActionSheetPicker];
//        }
//            break;
        case 4:
        {
            ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"TargetSet_Running", nil) delegate:self showCancelButton:YES origin:self.view];
            ap.tag = 104;
            [ap showActionSheetPicker];
        }
            break;
        default:
            break;
    }
    return NO;
}

//////////////////////////////////////////////////

-(float)getCal{
    return CALQUOTE*(self.commondata.stride/100.0)*self.commondata.target_steps*self.commondata.weight/1000.0;
}
-(float)getDistance{
    return self.commondata.stride*self.commondata.target_steps/100000.0;
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    return [self validateNumber:string];
//}

//- (BOOL)validateNumber:(NSString*)number {
//    BOOL res = YES;
//    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
//    int i = 0;
//    while (i < number.length) {
//        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
//        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
//        if (range.length == 0) {
//            res = NO;
//            break;
//        }
//        i++;
//    }
//    return res;
//}

///////////////////////////////////////////////////////////////////////
#pragma tabelview delegate
//-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    if(textField.tag == 1020){
//        if (self.commondata.measureunit == MEASURE_UNIT_METRIX){
//            textField.text = [NSString stringWithFormat:@"%.1f",self.commondata.target_distance];
//        }else{
//            textField.text = [NSString stringWithFormat:@"%.1f",self.commondata.target_distance*KM2MILE];
//        }
//    }
//    return YES;
//}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    if(textField.tag == 1020){
//        if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//            self.commondata.target_distance = textField.text.floatValue;
//            
//        }else{
//            self.commondata.target_distance = textField.text.floatValue / KM2MILE;
//            
//        }
//
//        [self.commondata saveconfig];
//        
//        //主线程更新UI
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableview reloadData];
//            
//        });
//        
//    }
//    return YES;
//}
//
//
////当用户按下return键或者按回车键，keyboard消失
//-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    [textField resignFirstResponder];
//    return YES;
//}
//

/////////////////////////////////////////////////////////////////////
//ActionsheetCustomDelegate

- (void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView{
    switch (actionSheetPicker.tag) {
        case 100:
            pickerView.tag = 100;
            long int idx = self.commondata.target_steps/1000;
            if (idx == 0) {
                idx = 1;
            }
            [pickerView selectRow:idx-1 inComponent:0 animated:YES];
            break;
            
        case 101:{
            pickerView.tag = 101;
//            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//                int cal = (int)self.commondata.target_distance -1;
//                if (cal < 0) {
//                    cal = 0;
//                }
//                [pickerView selectRow:cal inComponent:0 animated:YES];
//                
//            }else{
//                int cal = floor(self.commondata.target_distance);
//                [pickerView selectRow:cal inComponent:0 animated:YES];
//                
//            }
            int cal = (int)self.commondata.target_distance -1;
            if (cal < 0) {
                cal = 0;
            }
            [pickerView selectRow:cal inComponent:0 animated:YES];

            break;
        }
        case 102:{
            pickerView.tag = 102;
//            int cal = floor(self.commondata.target_calorie);
//            if (cal == 0){
//                cal = 1;
//            }
//            [pickerView selectRow:cal-1 inComponent:0 animated:YES];
            int cal = (int)self.commondata.target_calorie -50;
            if (cal < 0) {
                cal = 0;
            }
            [pickerView selectRow:cal inComponent:0 animated:YES];

            break;
        }
        case 104:
        {
            pickerView.tag = 104;
            int idx = (int)((int)self.commondata.target_steps/1000);
            if (idx == 0) {
                idx = 1;
            }
            [pickerView selectRow:idx-1 inComponent:0 animated:YES];
        }
            break;
        default:
            break;
    }
}
- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin{
    switch ((int)actionSheetPicker.tag) {
        case  100:{
            UIPickerView * picker = (UIPickerView *)actionSheetPicker.pickerView;
            int index = (int)[picker selectedRowInComponent:0];
            self.commondata.target_steps = (index+1)*1000;
            [self.commondata saveconfig];
        }
            break;
        case  101:{
            UIPickerView * picker = (UIPickerView *)actionSheetPicker.pickerView;
//            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//                int index = (int)[picker selectedRowInComponent:0];
//                self.commondata.target_distance = index+1;
//                
//            }else{
//                int index = (int)[picker selectedRowInComponent:0];
//                self.commondata.target_distance = (index/10.0);
            
//            }
            int index = (int)[picker selectedRowInComponent:0];
            self.commondata.target_distance = index+1;

            [self.commondata saveconfig];
        }
            break;
        case  102:{
            UIPickerView * picker = (UIPickerView *)actionSheetPicker.pickerView;
            self.commondata.target_calorie = [picker selectedRowInComponent:0]+50;
            [self.commondata saveconfig];
            break;
        }
        case 104:{
            UIPickerView * picker = (UIPickerView *)actionSheetPicker.pickerView;
            int index = (int)[picker selectedRowInComponent:0];
            self.commondata.target_runsteps = (index+1)*1000;
            [self.commondata saveconfig];
        }
            break;
        default:
            break;
    }
    [self.tableview reloadData];
    
}

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (pickerView.tag) {
        case 100:
            return 100;
            break;
        case 101:
            return 44;
            
        case 102:
            return 949;
            break;
        case 104:
            return 100;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (pickerView.tag) {
        case 100:
            return [NSString stringWithFormat:@"%ld",(row+1)*1000];
            break;
            
        case 101:
            return [NSString stringWithFormat:@"%d",row+1];
            break;
            
        case 102:
            return [NSString stringWithFormat:@"%ld",row+50];
            
            break;
        case 104:
            return [NSString stringWithFormat:@"%ld",(row+1)*1000];
            break;
        default:
            return @"";
            break;
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
