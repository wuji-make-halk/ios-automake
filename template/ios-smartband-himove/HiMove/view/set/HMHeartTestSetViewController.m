//
//  HMHeartTestSetViewController.m
//  HiMove
//
//  Created by 周凯伦 on 2017/5/11.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "HMHeartTestSetViewController.h"
#import "IRKCommonData.h"
#import "MainLoop.h"

@interface HMHeartTestSetViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView* tableview;
@property(nonatomic,strong)IRKCommonData* commondata;
@property(nonatomic,strong) MainLoop *mainloop;
@property(nonatomic,assign) BOOL lastset;
@end

@implementation HMHeartTestSetViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.mainloop = [MainLoop SharedInstance];
    self.lastset=self.commondata.is_enable_autoheart;
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
    label.text=NSLocalizedString(@"heart_test_mode", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}

-(void)onClickBack:(id)sender{
    if (self.commondata.is_enable_autoheart!=self.lastset) {
        [self.mainloop setConfigParam];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initControl{
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor=[UIColor clearColor];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* cellid = @"heartset";
    UITableViewCell* cell = [self.tableview dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (indexPath.row==0) {
        cell.textLabel.text=NSLocalizedString(@"heart_test_automatic", nil);
        if (self.commondata.is_enable_autoheart) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else if (indexPath.row==1){
        cell.textLabel.text=NSLocalizedString(@"heart_test_manual", nil);
        if (self.commondata.is_enable_autoheart) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        self.commondata.is_enable_autoheart=YES;
        [self.commondata saveconfig];
    }else if(indexPath.row==1){
        self.commondata.is_enable_autoheart=NO;
        [self.commondata saveconfig];
    }
    [self.tableview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
