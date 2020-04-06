//
//  HMPlayViewController.m
//  CZJKBand
//
//  Created by 周凯伦 on 17/3/15.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "HMPlayViewController.h"
#import "RunRecord+CoreDataClass.h"
#import "AppDelegate.h"
#import "CommonDefine.h"
#import "SWRunMapViewController.h"
#import "SWRunHistoryViewController.h"
#import "SWTextAttachment.h"


@interface HMPlayViewController ()<CLLocationManagerDelegate>
@property(nonatomic,strong) IRKCommonData* commondata;
@property(nonatomic,strong)CLLocationManager* runmanager;
@property(nonatomic,strong) UILabel *recordDistance;
@property(nonatomic,strong) UIButton *recordTimes;
@property(nonatomic,strong) NSManagedObjectContext *managedObjectContext;
//@property(nonatomic,strong) UIImageView *typeImg;
@property(nonatomic,strong) UILabel *typeLabel;
@property(nonatomic,assign) int currentType;
@property(nonatomic,strong) UIView *backview;
@property(nonatomic,strong) UILabel* tiplabel;
@end

@implementation HMPlayViewController

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.backview removeFromSuperview];
    [self refreshType];
    [self refreshRecord];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commondata=[IRKCommonData SharedInstance];
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = appdelegate.managedObjectContext;
    self.currentType=0;
    [self initNavBar];
    [self initcontrol];
    if ([self respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self performSelector:@selector(requestAlwaysAuthorization)];
    }
    self.runmanager =[[CLLocationManager alloc] init];
    self.runmanager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.runmanager.delegate = self;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version>=8){
        
        [self.runmanager requestAlwaysAuthorization];
    }

}
-(void)initNavBar{
    UIView* logoview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    UIImageView* imgview = [[UIImageView alloc]init];
    imgview.frame=CGRectMake(0, 5, 40 , 40);
    imgview.image = [UIImage imageNamed:@"icon_bs_logo.png"];
    imgview.contentMode = UIViewContentModeScaleAspectFit;
    [logoview addSubview:imgview];
    UILabel *logoLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgview.frame)+5, 5, 200, 40)];
    logoLabel.text=@"Hi Move";
    logoLabel.textColor=[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1];
    [logoview addSubview:logoLabel];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoview];
    
}

-(void)refreshType{
//    if (self.currentType==0) {
//        self.typeImg.image=[UIImage imageNamed:@"play_run"];
//        self.typeLabel.text=NSLocalizedString(@"Play_run", nil);
//    }else {
//        self.typeImg.image=[UIImage imageNamed:@"play_bike"];
//        self.typeLabel.text=NSLocalizedString(@"Play_bike", nil);
//    }
    switch (self.currentType) {
        case 0:{
//            self.typeImg.image=[UIImage imageNamed:@"play_run"];
            SWTextAttachment* imageattach = [[SWTextAttachment alloc] init];
            imageattach.image = [UIImage imageNamed:@"play_run"];
            
            NSAttributedString* str = [NSAttributedString attributedStringWithAttachment:imageattach];
            
            NSMutableAttributedString* strtitle = [[NSMutableAttributedString alloc] initWithAttributedString:str];
            [strtitle appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            [strtitle appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"running_type_running", nil) attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0x1f/255.0 green:0x96/255.0 blue:0xf2/255.0 alpha:1]}]];

            self.typeLabel.attributedText = strtitle;
            
            if (self.commondata.measureunit == MEASURE_UNIT_US) {
                self.tiplabel.text = [NSString stringWithFormat:@"%@%@(%@)",NSLocalizedString(@"running_type_running", nil),NSLocalizedString(@"sport_sum_distance", nil),NSLocalizedString(@"UNIT_MILE", nil)];
            }else{
                self.tiplabel.text = [NSString stringWithFormat:@"%@%@(%@)",NSLocalizedString(@"running_type_running", nil),NSLocalizedString(@"sport_sum_distance", nil),NSLocalizedString(@"UNIT_KM", nil)];
            }
//            self.tiplabel.text = NSLocalizedString(@"sport_running_sum_distance", nil);
        }
            break;
        case 1:{
//            self.typeImg.image=[UIImage imageNamed:@"play_bike"];
//            self.typeLabel.text=NSLocalizedString(@"running_type_bycicle", nil);
            SWTextAttachment* imageattach = [[SWTextAttachment alloc] init];
            imageattach.image = [UIImage imageNamed:@"play_bike"];
            
            NSAttributedString* str = [NSAttributedString attributedStringWithAttachment:imageattach];
            
            NSMutableAttributedString* strtitle = [[NSMutableAttributedString alloc] initWithAttributedString:str];
            [strtitle appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            [strtitle appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"running_type_bycicle", nil) attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0x1f/255.0 green:0x96/255.0 blue:0xf2/255.0 alpha:1]}]];
            
            self.typeLabel.attributedText = strtitle;

//            self.tiplabel.text = NSLocalizedString(@"sport_bycicle_sum_distance", nil);
            if (self.commondata.measureunit == MEASURE_UNIT_US) {
                self.tiplabel.text = [NSString stringWithFormat:@"%@%@(%@)",NSLocalizedString(@"running_type_bycicle", nil),NSLocalizedString(@"sport_sum_distance", nil),NSLocalizedString(@"UNIT_MILE", nil)];
            }else{
                self.tiplabel.text = [NSString stringWithFormat:@"%@%@(%@)",NSLocalizedString(@"running_type_bycicle", nil),NSLocalizedString(@"sport_sum_distance", nil),NSLocalizedString(@"UNIT_KM", nil)];
            }

        }
            break;
        case 2:{
//            self.typeImg.image=[UIImage imageNamed:@"play_climb"];
//            self.typeLabel.text=NSLocalizedString(@"running_type_climbing", nil);
            SWTextAttachment* imageattach = [[SWTextAttachment alloc] init];
            imageattach.image = [UIImage imageNamed:@"play_climb"];
            
            NSAttributedString* str = [NSAttributedString attributedStringWithAttachment:imageattach];
            
            NSMutableAttributedString* strtitle = [[NSMutableAttributedString alloc] initWithAttributedString:str];
            [strtitle appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            [strtitle appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"running_type_climbing", nil) attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0x1f/255.0 green:0x96/255.0 blue:0xf2/255.0 alpha:1]}]];
            
            self.typeLabel.attributedText = strtitle;

//            self.tiplabel.text = NSLocalizedString(@"sport_climbing_sum_distance", nil);
            if (self.commondata.measureunit == MEASURE_UNIT_US) {
                self.tiplabel.text = [NSString stringWithFormat:@"%@%@(%@)",NSLocalizedString(@"running_type_climbing", nil),NSLocalizedString(@"sport_sum_distance", nil),NSLocalizedString(@"UNIT_MILE", nil)];
            }else{
                self.tiplabel.text = [NSString stringWithFormat:@"%@%@(%@)",NSLocalizedString(@"running_type_climbing", nil),NSLocalizedString(@"sport_sum_distance", nil),NSLocalizedString(@"UNIT_KM", nil)];
            }

        }
            break;
            
        default:
            break;
    }
}

-(void)initcontrol{
    //选择运动类型
    self.view.backgroundColor = [UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    CGFloat buttonsize = CGRectGetHeight(self.view.frame)*0.2;
    CGFloat labelsize = CGRectGetHeight(self.view.frame)*0.05;
    CGFloat sep = (CGRectGetHeight(self.view.frame)-buttonsize-labelsize*6-49-65)/8.0;
    
    self.tiplabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), labelsize)];
    self.tiplabel.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
    self.tiplabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.tiplabel];
//    [self.tiplabel 
    [self.tiplabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.frame), labelsize));
        make.top.mas_equalTo(@0).with.offset(sep*2.0);
        make.left.mas_equalTo(@0);
        
    }];

    _recordDistance=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), labelsize*2.0)];
    NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",0.00] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:labelsize*1.5],NSForegroundColorAttributeName:[UIColor colorWithRed:0x55/255.0 green:0xa7/255.0 blue:0xe9/255.0 alpha:1]}];
//    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//        [str appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_KM", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1]}]];
//    }else{
//        [str appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_MILE", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1]}]];
//    }
    _recordDistance.attributedText = str;
    _recordDistance.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:_recordDistance];
    [self.recordDistance mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake( CGRectGetWidth(self.view.frame), labelsize*2.0));
        make.top.mas_equalTo(self.tiplabel.mas_bottom).with.offset(sep);
        make.left.mas_equalTo(@0);
    }];

    //历史记录
//    UIButton *recordButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
////    [recordButton addTarget:self action:@selector(recordBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:recordButton];
    
    
    
    _recordTimes=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), labelsize)];
    [_recordTimes addTarget:self action:@selector(recordBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_recordTimes setTitle:[NSString stringWithFormat:NSLocalizedString(@"running_total_sport", nil),0] forState:UIControlStateNormal];
    [_recordTimes setTitleColor:[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1] forState:UIControlStateNormal];
//    _recordTimes.textColor=[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1];
//    _recordTimes.textAlignment=NSTextAlignmentCenter;
//    _recordTimes.font=[UIFont systemFontOfSize:22];
    [self.view addSubview:_recordTimes];
    [self.recordTimes mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.frame), labelsize));
        make.top.mas_equalTo(self.recordDistance.mas_bottom).with.offset(sep);
        make.left.mas_equalTo(@0);
    }];
 
    
    self.typeLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.view.frame),labelsize)];
//    self.typeLabel.textColor=[UIColor colorWithRed:0x55/255.0 green:0xa7/255.0 blue:0xe9/255.0 alpha:1];
    self.typeLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:self.typeLabel];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.frame), labelsize));
        make.top.mas_equalTo(self.recordTimes.mas_bottom).with.offset(sep);
        make.left.mas_equalTo(@0);
    }];
   
    UIButton *typeButton=[[UIButton alloc]initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.view.frame)*0.4, labelsize)];
    [typeButton addTarget:self action:@selector(selectTypeBtn:) forControlEvents:UIControlEventTouchUpInside];
    [typeButton setTitle:NSLocalizedString(@"running_type_select", nil) forState:UIControlStateNormal];
    [typeButton setTitleColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0] forState:UIControlStateNormal];
    typeButton.layer.cornerRadius = labelsize/2.0;
    typeButton.layer.borderColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0].CGColor;
    typeButton.layer.borderWidth = 1;
    typeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    typeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    typeButton.titleLabel.minimumScaleFactor = 0.5;
    [self.view addSubview:typeButton];
    [typeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.frame)*0.4, labelsize));
        make.top.mas_equalTo(self.typeLabel.mas_bottom).with.offset(sep);
        make.left.mas_equalTo(@0).with.offset(CGRectGetWidth(self.view.frame)*0.3);
    }];
  
    
    
//    self.typeImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
//    [typeButton addSubview:self.typeImg];
 
    [self refreshType];
    
//    UIImageView *arrowImg=[[UIImageView alloc]initWithFrame:CGRectMake(95, 5, 15, 10)];
//    arrowImg.image=[UIImage imageNamed:@"play_type_arrow"];
//    [typeButton addSubview:arrowImg];
//    
    

    
    UIButton *startBtn=[[UIButton alloc]initWithFrame:CGRectMake(0,0,buttonsize,buttonsize)];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"play_start_btn"] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [startBtn setTitle:NSLocalizedString(@"running_start", nil) forState:UIControlStateNormal];
    startBtn.titleLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:startBtn];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonsize,buttonsize));
        make.top.mas_equalTo(typeButton.mas_bottom).with.offset(sep);
        make.left.mas_equalTo(@0).with.offset((CGRectGetWidth(self.view.frame)-buttonsize)/2.0);
    }];

}

-(void)selectTypeBtn:(UIButton*)sender{
    self.backview=[[UIView alloc]initWithFrame:self.view.bounds];
    self.backview.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:self.backview];
    
    CGFloat sep=(CGRectGetWidth(self.view.frame)-100-180)/3;
    CGFloat sepy = 15;
    CGFloat buttonsize = 90;
    CGFloat labelsize = 20;
    CGFloat viewheight = labelsize*2+buttonsize*2+sepy*6 + 30;
    UIView *whiteView=[[UIView alloc]initWithFrame:CGRectMake(0,0,0,0)];
    whiteView.backgroundColor=[UIColor whiteColor];
    whiteView.layer.cornerRadius=10;
    [whiteView setClipsToBounds:YES];
    [self.backview addSubview:whiteView];
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.frame)-100, viewheight));
        make.top.mas_equalTo(@0).with.offset((CGRectGetHeight(self.backview.frame)-viewheight)/2.0);
        make.left.mas_equalTo(@0).with.offset(50);
    }];
    
    
    UILabel *label_title=[[UILabel alloc]initWithFrame:CGRectMake(0, 0,0,0)];
    label_title.text=NSLocalizedString(@"running_type_select", nil);
    label_title.textAlignment=NSTextAlignmentCenter;
    [whiteView addSubview:label_title];
    [label_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.frame)-100,30));
        make.top.mas_equalTo(whiteView.mas_top).with.offset(sepy);
        make.left.mas_equalTo(whiteView.mas_left);
    }];
    
    UIButton *btn_bike=[[UIButton alloc]initWithFrame:CGRectMake(0,0,0,0)];
    btn_bike.tag=501;
    [btn_bike addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.backview addSubview:btn_bike];
    [btn_bike mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonsize,buttonsize));
        make.top.mas_equalTo(label_title.mas_bottom).with.offset(sepy);
        make.left.mas_equalTo(whiteView.mas_left).with.offset(sep);
    }];
    
    UILabel *label_bike=[[UILabel alloc]initWithFrame:CGRectMake(0,0,0,0)];
    label_bike.tag=601;
    label_bike.textAlignment=NSTextAlignmentCenter;
    label_bike.font=[UIFont systemFontOfSize:13];
    label_bike.text=NSLocalizedString(@"running_type_bycicle", nil);
    [self.backview addSubview:label_bike];
    [label_bike mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonsize,labelsize));
        make.top.mas_equalTo(btn_bike.mas_bottom).with.offset(sepy);
        make.left.mas_equalTo(whiteView.mas_left).with.offset(sep);
    }];
 
    UIButton *btn_run=[[UIButton alloc]initWithFrame:CGRectMake(0,0,0,0)];
    btn_run.tag=500;
    [btn_run addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.backview addSubview:btn_run];
    [btn_run mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonsize,buttonsize));
        make.top.mas_equalTo(label_title.mas_bottom).with.offset(sepy);
        make.left.mas_equalTo(btn_bike.mas_right).with.offset(sep);
    }];
  
    
    UILabel *label_run=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label_bike.frame)+sep, CGRectGetMaxY(btn_run.frame)+15, 90, 20)];
    label_run.tag=600;
    label_run.textAlignment=NSTextAlignmentCenter;
    label_run.font=[UIFont systemFontOfSize:13];
    label_run.text=NSLocalizedString(@"running_type_running", nil);
    [self.backview addSubview:label_run];
    [label_run mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonsize,labelsize));
        make.top.mas_equalTo(btn_run.mas_bottom).with.offset(sepy);
        make.left.mas_equalTo(btn_bike.mas_right).with.offset(sep);
    }];

    UIButton *btn_hike =[[UIButton alloc]initWithFrame:CGRectMake(0,0,0,0)];
    btn_hike.tag=502;
    [btn_hike addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.backview addSubview:btn_hike];
    [btn_hike mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonsize,buttonsize));
        make.top.mas_equalTo(label_bike.mas_bottom).with.offset(sepy);
        make.left.mas_equalTo(whiteView.mas_left).with.offset(sep);
    }];
    
    
    UILabel *label_hike=[[UILabel alloc]initWithFrame:CGRectMake(0,0,0,0)];
    label_hike.tag=602;
    label_hike.textAlignment=NSTextAlignmentCenter;
    label_hike.font=[UIFont systemFontOfSize:13];
    label_hike.text=NSLocalizedString(@"running_type_climbing", nil);
    [self.backview addSubview:label_hike];
    [label_hike mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonsize,labelsize));
        make.top.mas_equalTo(btn_hike.mas_bottom).with.offset(sepy);
        make.left.mas_equalTo(whiteView.mas_left).with.offset(sep);
    }];
   
    
    
    if (self.currentType==0) {
        [btn_run setImage:[UIImage imageNamed:@"play_type_0_1"] forState:UIControlStateNormal];
        [btn_bike setImage:[UIImage imageNamed:@"play_type_1_0"] forState:UIControlStateNormal];
        [btn_hike setImage:[UIImage imageNamed:@"play_type_2_0"] forState:UIControlStateNormal];
        label_run.textColor=[UIColor colorWithRed:0x55/255.0 green:0xa7/255.0 blue:0xe9/255.0 alpha:1];
        label_bike.textColor=[UIColor lightGrayColor];
        label_hike.textColor=[UIColor lightGrayColor];
    }else if (self.currentType == 1){
        [btn_run setImage:[UIImage imageNamed:@"play_type_0_0"] forState:UIControlStateNormal];
        [btn_bike setImage:[UIImage imageNamed:@"play_type_1_1"] forState:UIControlStateNormal];
        [btn_hike setImage:[UIImage imageNamed:@"play_type_2_0"] forState:UIControlStateNormal];
        label_run.textColor=[UIColor lightGrayColor];
        label_bike.textColor=[UIColor colorWithRed:0x55/255.0 green:0xa7/255.0 blue:0xe9/255.0 alpha:1];
        label_hike.textColor=[UIColor lightGrayColor];
        
    }else{
        [btn_run setImage:[UIImage imageNamed:@"play_type_0_0"] forState:UIControlStateNormal];
        [btn_bike setImage:[UIImage imageNamed:@"play_type_1_0"] forState:UIControlStateNormal];
        [btn_hike setImage:[UIImage imageNamed:@"play_type_2_1"] forState:UIControlStateNormal];
        label_run.textColor=[UIColor lightGrayColor];
        label_bike.textColor=[UIColor lightGrayColor];
        label_hike.textColor=[UIColor colorWithRed:0x55/255.0 green:0xa7/255.0 blue:0xe9/255.0 alpha:1];

    }
    
}

-(void)typeClick:(UIButton*)sender{
    if (sender.tag==500) {
        UIButton *btn_current=(UIButton*)[self.backview viewWithTag:500];
        [btn_current setImage:[UIImage imageNamed:@"play_type_0_1"] forState:UIControlStateNormal];
        UIButton *btn_other=(UIButton*)[self.backview viewWithTag:501];
        [btn_other setImage:[UIImage imageNamed:@"play_type_1_0"] forState:UIControlStateNormal];
        UIButton *btn_hike=(UIButton*)[self.backview viewWithTag:502];
        [btn_hike setImage:[UIImage imageNamed:@"play_type_2_0"] forState:UIControlStateNormal];
        UILabel *label_current=(UILabel*)[self.backview viewWithTag:600];
        label_current.textColor=[UIColor colorWithRed:0x55/255.0 green:0xa7/255.0 blue:0xe9/255.0 alpha:1];
        
        UILabel *label_other=(UILabel*)[self.backview viewWithTag:601];
        label_other.textColor=[UIColor lightGrayColor];
        UILabel *label_hike=(UILabel*)[self.backview viewWithTag:602];
        label_hike.textColor=[UIColor lightGrayColor];
        
    }else if(sender.tag == 501){
        UIButton *btn_current=(UIButton*)[self.backview viewWithTag:501];
        [btn_current setImage:[UIImage imageNamed:@"play_type_1_1"] forState:UIControlStateNormal];
        UIButton *btn_other=(UIButton*)[self.backview viewWithTag:500];
        [btn_other setImage:[UIImage imageNamed:@"play_type_0_0"] forState:UIControlStateNormal];
        UIButton *btn_hike=(UIButton*)[self.backview viewWithTag:502];
        [btn_hike setImage:[UIImage imageNamed:@"play_type_2_0"] forState:UIControlStateNormal];
        
        UILabel *label_current=(UILabel*)[self.backview viewWithTag:601];
        label_current.textColor=[UIColor colorWithRed:0x55/255.0 green:0xa7/255.0 blue:0xe9/255.0 alpha:1];
        
        UILabel *label_other=(UILabel*)[self.backview viewWithTag:600];
        label_other.textColor=[UIColor lightGrayColor];
        UILabel *label_hike=(UILabel*)[self.backview viewWithTag:602];
        label_hike.textColor=[UIColor lightGrayColor];
    }else{
        UIButton *btn_current=(UIButton*)[self.backview viewWithTag:501];
        [btn_current setImage:[UIImage imageNamed:@"play_type_1_0"] forState:UIControlStateNormal];
        UIButton *btn_other=(UIButton*)[self.backview viewWithTag:500];
        [btn_other setImage:[UIImage imageNamed:@"play_type_0_0"] forState:UIControlStateNormal];
        UIButton *btn_hike=(UIButton*)[self.backview viewWithTag:502];
        [btn_hike setImage:[UIImage imageNamed:@"play_type_2_1"] forState:UIControlStateNormal];
        
        UILabel *label_current=(UILabel*)[self.backview viewWithTag:601];
        label_current.textColor=[UIColor lightGrayColor];
        UILabel *label_other=(UILabel*)[self.backview viewWithTag:600];
        label_other.textColor=[UIColor lightGrayColor];
        UILabel *label_hike=(UILabel*)[self.backview viewWithTag:602];
        label_hike.textColor=[UIColor colorWithRed:0x55/255.0 green:0xa7/255.0 blue:0xe9/255.0 alpha:1];

    }
    self.currentType=(int)(sender.tag-500);
    [self refreshType];
    
    [self.backview removeFromSuperview];
}



-(void)recordBtnClick:(UIButton*)sender{
    SWRunHistoryViewController *vc=[SWRunHistoryViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)startBtnClick:(UIButton*)sender{
    [self openMap];
}

-(void)refreshRecord{
    __block double totaldistance = 0;
    NSArray* recordarray =[self getRundata];
    long totaltime = recordarray.count;
    if (totaltime) {
        [recordarray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RunRecord* record = (RunRecord*)obj;
            
            totaldistance += record.totaldistance.doubleValue;
        }];
    }
    
    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
        NSMutableAttributedString* str_recordDistance = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",totaldistance/1000.0] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:50],NSForegroundColorAttributeName:[UIColor colorWithRed:0x55/255.0 green:0xa7/255.0 blue:0xe9/255.0 alpha:1]}];
        [str_recordDistance appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_KM", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1]}]];
        self.recordDistance.attributedText = str_recordDistance;
        
    }else{
        NSMutableAttributedString* str_recordDistance = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",(totaldistance/1000.0)*KM2MILE] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:50],NSForegroundColorAttributeName:[UIColor colorWithRed:0x55/255.0 green:0xa7/255.0 blue:0xe9/255.0 alpha:1]}];
        [str_recordDistance appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_MILE", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1]}]];
        self.recordDistance.attributedText = str_recordDistance;
    }
    
    [self.recordTimes setTitle:[NSString stringWithFormat:NSLocalizedString(@"running_total_sport", nil),totaltime] forState:UIControlStateNormal];
}

-(NSArray *)getRundata{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunRecord" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid=%@ and type IN {%@,%@,%@}", self.commondata.uid,[NSNumber numberWithInt:SPORT_TYPE_RUNNING],[NSNumber numberWithInt:SPORT_TYPE_BICYCLE],[NSNumber numberWithInt:SPORT_TYPE_GPS_CLIMB]];
    [fetchRequest setPredicate:predicate];
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"starttime" ascending:NO];
    //    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSError *error = nil;
    NSArray* fetchobjs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return fetchobjs ;
}

- (void)openMap{
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"GPS_notauth", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"GPS_Setting", nil), nil];
        alertview.tag = 101;
        [alertview show];
        return;
    }
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version >= 8.0){
        if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways){
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"GPS_notauth", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"GPS_Setting", nil), nil];
            alertview.tag = 101;
            [alertview show];
            return;
        }
    }else{
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"GPS_notauth", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"GPS_Setting", nil), nil];
            alertview.tag = 101;
            [alertview show];
            return;
        }
    }
    
    SWRunMapViewController* mapvc = [[SWRunMapViewController alloc] init];
    if (self.currentType==0) {
        mapvc.runmode = SPORT_TYPE_RUNNING;
    }else if(self.currentType == 1){
        mapvc.runmode = SPORT_TYPE_BICYCLE;
    }else{
        mapvc.runmode = SPORT_TYPE_GPS_CLIMB;
    }
    [self.navigationController presentViewController:mapvc animated:YES completion:nil];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 101)
    {
        if (buttonIndex != alertView.cancelButtonIndex) {
            if([[UIDevice currentDevice].systemVersion doubleValue] <10.0){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
            }else{
                //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:nil completionHandler:nil];
                NSURL *url=[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
