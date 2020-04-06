//
//  HMHomeViewController.m
//  CZJKBand
//
//  Created by 周凯伦 on 17/3/15.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "HMHomeViewController.h"
#import "AppDelegate.h"
#import "BattelLabel.h"
#import "IRKSportProgress.h"
#import "IRKSleepProgress.h"
#import "IRKHeartProgress.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "StepHistory+CoreDataClass.h"
#import "IRKCommonData.h"
#import "MainLoop.h"
#import "CommonDefine.h"
#import "KLCPopup.h"
#import "LWSyncView.h"
#import "Health_data_history+CoreDataClass.h"
//#import "LWBleDeviceViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "TaskManager.h"
#import "MainViewButton.h"



@interface HMHomeViewController ()<IRKSportProgressDataSource,IRKSportProgressDelegate,IRKSleepProgressDataSource,IRKSleepProgressDelegate,IRKHeartProgressDelegate,LWSyncViewDelegate>
@property (strong, nonatomic) IRKSportProgress* sportprogress;
@property (strong, nonatomic) IRKSleepProgress* sleepprogress;
@property (nonatomic, strong) IRKHeartProgress* heartprogress;
@property (nonatomic,strong) UIButton* btn_heart;
@property(nonatomic,strong) UIButton *btn_temperature;
@property (strong, nonatomic)NSTimer* timerReadC6;
@property (strong, nonatomic)KLCPopup* popup;
@property (strong, nonatomic)LWSyncView* notifyView;

@property (strong, nonatomic)UIView* sleeptipview;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray* fetchedObjects;
@property (strong, nonatomic)NSMutableDictionary* sleepdict;

@property (assign, nonatomic)NSTimeInterval starttimeinterval;
@property (strong, nonatomic)NSDate * currentDate;

@property (assign, nonatomic)int deepsleepcount;
@property(nonatomic,assign)NSInteger lightsleepcount;
@property(nonatomic,assign)NSInteger extrmelysleepcount;
@property(nonatomic,assign)NSInteger awakeCount;
@property (assign, nonatomic)int sleepcount;

@property (nonatomic,assign) NSUInteger currentsteps;
@property (nonatomic,assign) NSUInteger currenthearts;
@property(nonatomic,assign) CGFloat currenttemperature;
@property(nonatomic,assign) CGFloat temperatureValue;


@property (nonatomic,assign)NSInteger heartStatus;
@property (nonatomic,assign)NSInteger heartValue;

@property (strong, nonatomic) IRKCommonData* commondata;
@property (strong, nonatomic) MainLoop* mainloop;
@property(nonatomic,strong)BleControl* blecontrol;
@property (strong, nonatomic)UIButton* btn_sync;

@property(nonatomic,assign) int is_select_num;
@property(nonatomic,strong) NSDictionary* upperattri;
@property(nonatomic,strong) NSDictionary* lowerattri;

@end

@implementation HMHomeViewController


-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    /*监听蓝牙连接状态的改变*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ConnectStateChanged:) name:notify_key_connect_state_changed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ConnectStateChanged:) name:notify_key_ble_power_off object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ConnectStateChanged:) name:notify_band_has_kickoff object:nil];
    
    /*获取当前步数*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetCurrentSteps:) name:notify_key_did_get_current_steps object:nil];
    /*获取心率数据*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetHeartData:) name:notify_key_did_get_sensor_report object:nil];
    /*改变测试状态*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangeHeartStatus:) name:notify_key_did_change_sensor_status object:nil];
    /*读取运动数据*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReadSportData:) name:notify_key_read_sport_data_finish object:nil];
    /*完成数据同步*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFinish) name:notify_key_did_finish_device_sync object:nil];
    
    self.currentDate = [NSDate date];
    [self reload];
    
    [self.mainloop SyncCurrentData];//与[self.mainloop HomeGetCurrentData]一样
    
    
//    [self.sportprogress reload];                  // 运动进展 刷新
//    [self.sportprogress setNeedsDisplay];         // 运动进展 设置需要显示
//    
//    [self.sleepprogress reload];                  // 睡眠的进展 刷新
//    [self.sleepprogress setNeedsDisplay];         // 睡眠的进展 设置需要显示
    
//    [self.heartprogress setHeartValue:0];
//    [self.heartprogress reload];
    
    if (self.timerReadC6) {
        [self.timerReadC6 invalidate];
        self.timerReadC6 = nil;
    }
    self.timerReadC6 = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(ReadCurrentSteps:) userInfo:nil repeats:YES];
    [self loadHeartData];
    [self refreshValueLabel];
}

-(void)viewDidDisappear:(BOOL)animated{
    if (self.timerReadC6) {
        [self.timerReadC6 invalidate];
        self.timerReadC6 = nil;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.currentDate = [NSDate date];
    
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = appdelegate.managedObjectContext;
    self.commondata = [IRKCommonData SharedInstance];
    self.mainloop = [MainLoop SharedInstance];
    self.blecontrol = [BleControl SharedInstance];
    self.currentsteps=0;
    _heartValue = 0;
    _heartStatus = 0;
    self.temperatureValue = 0;

    self.is_select_num=1;
    [self initNav];
    [self initcontrols];
}

-(void)initNav{
    UIView* logoview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 50)];
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
    
    UIView *rightView=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 20, self.view.frame.size.width/2, 44)];

    UIButton *shareBtn=[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(rightView.frame)-40, 0, 35, 35)];
    shareBtn.imageView.contentMode=UIViewContentModeScaleAspectFit;
    [shareBtn setImage:[UIImage imageNamed:@"shareBtn"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(onClickShare:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:shareBtn];
    
    self.btn_sync = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(rightView.frame)-90, 0, 40, 40)];
    self.btn_sync.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.btn_sync setImage:[UIImage imageNamed:@"syncBtn"] forState:UIControlStateNormal];
    [self.btn_sync setImage:[UIImage imageNamed:@"syncBtn_disable.png"] forState:UIControlStateDisabled];
    [self.btn_sync addTarget:self action:@selector(onClickSync:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:self.btn_sync];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
}

-(void)initcontrols{
    self.view.backgroundColor = [UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    
    //同步框
    self.notifyView = [[LWSyncView alloc] initWithFrame:self.view.bounds];
    self.notifyView.delegate = self;
    self.notifyView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    CGFloat progress_xoffset = self.view.frame.size.width/6.0;
    CGFloat progress_yoffset = self.view.frame.size.width/8.0;
    CGFloat progress_width = self.view.frame.size.width*2/3.0;
    
    self.sportprogress = [[IRKSportProgress alloc] initWithFrame:CGRectMake(progress_xoffset, progress_yoffset, progress_width, progress_width)];
    self.sportprogress.delegate = self;
    self.sportprogress.datasource = self;
    [self.view addSubview:self.sportprogress];
    
    self.sleepprogress = [[IRKSleepProgress alloc] initWithFrame:CGRectMake(progress_xoffset, progress_xoffset, progress_width, progress_width)];
    self.sleepprogress.delegate = self;
    self.sleepprogress.datasource = self;
    [self.view addSubview:self.sleepprogress];
    
    self.heartprogress = [[IRKHeartProgress alloc] initWithFrame:CGRectMake(progress_xoffset, progress_xoffset, progress_width, progress_width)];
    self.heartprogress.delegate = self;
    [self.view addSubview:self.heartprogress];
    
    
    CGFloat heart_height =30;//self.heartprogress.frame.size.height/7.0;
    CGFloat heart_xoffset = self.view.frame.size.width/2-50;
    CGFloat heart_yoffset = CGRectGetMaxY(self.heartprogress.frame)-self.heartprogress.frame.size.height/3.0;
    self.btn_heart = [[UIButton alloc] initWithFrame:CGRectMake(heart_xoffset, heart_yoffset, 100, heart_height)];
    self.btn_heart.tag=10001;
    [self.btn_heart setTitle:NSLocalizedString(@"Heart_start", nil) forState:UIControlStateNormal];
    [self.btn_heart setTitle:NSLocalizedString(@"Heart_stop", nil) forState:UIControlStateSelected];
    self.btn_heart.backgroundColor =[UIColor colorWithRed:0xfc/255.0 green:0x3c/255.0 blue:0x51/255.0 alpha:1];
    [self.btn_heart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btn_heart.layer.cornerRadius=15;
    self.btn_heart.titleLabel.font = [UIFont systemFontOfSize:heart_height/2.0];
    self.btn_heart.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.btn_heart.titleLabel.minimumScaleFactor = 0.5;
    [self.btn_heart addTarget:self action:@selector(onClickHeart:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_heart];
    
    self.btn_temperature = [[UIButton alloc] initWithFrame:CGRectMake(heart_xoffset, heart_yoffset, 100, heart_height)];
    self.btn_temperature.tag=10001;
    [self.btn_temperature setTitle:NSLocalizedString(@"Heart_start", nil) forState:UIControlStateNormal];
    [self.btn_temperature setTitle:NSLocalizedString(@"Heart_stop", nil) forState:UIControlStateSelected];
    self.btn_temperature.backgroundColor =[UIColor colorWithRed:0x7d/255.0 green:0x94/255.0 blue:0x9a/255.0 alpha:1];
    [self.btn_temperature setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btn_temperature.layer.cornerRadius=15;
    self.btn_temperature.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.btn_temperature.titleLabel.minimumScaleFactor = 0.5;
    [self.btn_temperature addTarget:self action:@selector(onClickTemperature:) forControlEvents:UIControlEventTouchUpInside];
    self.btn_temperature.titleLabel.font = [UIFont systemFontOfSize:heart_height/2.0];
    [self.view addSubview:self.btn_temperature];
    
    
    CGFloat offset_y=(CGRectGetHeight(self.view.frame)-65-49-(progress_yoffset*2+progress_width))/3.0;
    CGFloat buttonHeight=offset_y*0.9;
    CGFloat buttonWeight = CGRectGetWidth(self.view.frame)*0.45;
    CGFloat buttonSep = CGRectGetWidth(self.view.frame)*0.05;
    CGFloat textheight = (buttonHeight/2.0)*0.5;
    self.upperattri =  @{NSFontAttributeName:[UIFont systemFontOfSize:textheight],NSForegroundColorAttributeName:[UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1]};
    self.lowerattri =  @{NSFontAttributeName:[UIFont systemFontOfSize:textheight*0.8],NSForegroundColorAttributeName:[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1]};
    
    UIView *sepview=[[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2.0-1, progress_yoffset*2+progress_width, 2, offset_y*3.0-15)];
    sepview.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:sepview];
    
    MainViewButton* btn1 = [[MainViewButton alloc] initWithFrame:CGRectZero];
    btn1.tag=1;
    [btn1 addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn1.backgroundColor=[UIColor clearColor];
    [btn1 setImage:[UIImage imageNamed:@"home_1_0.png"] forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"home_1_1.png"] forState:UIControlStateSelected];
    btn1.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn1.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn1.titleLabel.numberOfLines = 0;
    [self.view addSubview:btn1];
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWeight, offset_y));
        make.left.mas_equalTo([NSNumber numberWithFloat:buttonSep]);
        make.top.mas_equalTo([NSNumber numberWithFloat:progress_yoffset*2.0+progress_width]);
    }];
    
    MainViewButton* btn2 = [[MainViewButton alloc] initWithFrame:CGRectZero];
    btn2.tag=2;
    [btn2 addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn2.backgroundColor=[UIColor clearColor];
    [btn2 setImage:[UIImage imageNamed:@"home_2_0.png"] forState:UIControlStateNormal];
    [btn2 setImage:[UIImage imageNamed:@"home_2_1.png"] forState:UIControlStateSelected];
    btn2.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn2.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn2.titleLabel.numberOfLines = 0;
    [self.view addSubview:btn2];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWeight, offset_y));
        make.left.mas_equalTo([NSNumber numberWithFloat:buttonSep]);
        make.top.mas_equalTo(btn1.mas_bottom);
    }];
    
    MainViewButton* btn3 = [[MainViewButton alloc] initWithFrame:CGRectZero];
    btn3.tag=3;
    [btn3 addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn3.backgroundColor=[UIColor clearColor];
    [btn3 setImage:[UIImage imageNamed:@"home_3_0.png"] forState:UIControlStateNormal];
    [btn3 setImage:[UIImage imageNamed:@"home_3_1.png"] forState:UIControlStateSelected];
    btn3.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn3.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn3.titleLabel.numberOfLines = 0;
    [self.view addSubview:btn3];
    [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWeight, offset_y));
        make.left.mas_equalTo([NSNumber numberWithFloat:buttonSep]);
        make.top.mas_equalTo(btn2.mas_bottom);
    }];
    
    MainViewButton* btn4 = [[MainViewButton alloc] initWithFrame:CGRectZero];
    btn4.tag=4;
    [btn4 addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn4.backgroundColor=[UIColor clearColor];
    [btn4 setImage:[UIImage imageNamed:@"home_4_0.png"] forState:UIControlStateNormal];
    [btn4 setImage:[UIImage imageNamed:@"home_4_1.png"] forState:UIControlStateSelected];
    btn4.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn4.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn4.titleLabel.numberOfLines = 0;
    [self.view addSubview:btn4];
    [btn4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWeight, offset_y));
        make.left.mas_equalTo([NSNumber numberWithFloat:CGRectGetWidth(self.view.frame)/2.0+buttonSep]);
        make.top.mas_equalTo(btn1.mas_top);
    }];
    
    MainViewButton* btn5 = [[MainViewButton alloc] initWithFrame:CGRectZero];
    btn5.tag=5;
    [btn5 addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn5.backgroundColor=[UIColor clearColor];
    [btn5 setImage:[UIImage imageNamed:@"home_5_0.png"] forState:UIControlStateNormal];
    [btn5 setImage:[UIImage imageNamed:@"home_5_1.png"] forState:UIControlStateSelected];
    btn5.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn5.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn5.titleLabel.numberOfLines = 0;
    [self.view addSubview:btn5];
    [btn5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWeight, offset_y));
        make.left.mas_equalTo([NSNumber numberWithFloat:CGRectGetWidth(self.view.frame)/2.0+buttonSep]);
        make.top.mas_equalTo(btn4.mas_bottom);
    }];
    
    MainViewButton* btn6 = [[MainViewButton alloc] initWithFrame:CGRectZero];
    btn6.tag=6;
    [btn6 addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn6.backgroundColor=[UIColor clearColor];
    [btn6 setImage:[UIImage imageNamed:@"home_6_0.png"] forState:UIControlStateNormal];
    [btn6 setImage:[UIImage imageNamed:@"home_6_1.png"] forState:UIControlStateSelected];
    btn6.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn6.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn6.titleLabel.numberOfLines = 0;
    [self.view addSubview:btn6];
    [btn6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWeight, offset_y));
        make.left.mas_equalTo([NSNumber numberWithFloat:CGRectGetWidth(self.view.frame)/2.0+buttonSep]);
        make.top.mas_equalTo(btn5.mas_bottom);
    }];


//    for (int i=0; i<2; i++) {
//        for (int j=0; j<3; j++) {
//            UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/12.0+8+i*CGRectGetWidth(self.view.frame)/2.0, progress_yoffset*2+progress_width+8+j*offset_y, buttonHeight-16, buttonHeight-16)];
//            imageview.image=[UIImage imageNamed:[NSString stringWithFormat:@"home_%d_0",i*3+j+1]];
//            imageview.tag=i*3+j+1+100;
//            imageview.contentMode = UIViewContentModeScaleAspectFit;
//            [self.view addSubview:imageview];
//            
//            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/12.0+10+buttonHeight+i*CGRectGetWidth(self.view.frame)/2.0, progress_yoffset*2+progress_width+j*offset_y, CGRectGetWidth(self.view.frame)/3.0-buttonHeight+2+10, buttonHeight/2)];
//            NSString *textstr=[NSString stringWithFormat:@"Home_text%d",i*3+j+1];
//            label.text=NSLocalizedString(textstr, nil);
//            label.font=[UIFont systemFontOfSize:textheight];
//            label.textColor=[UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1];
//            [self.view addSubview:label];
//            
//            UILabel *valueLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/12.0+10+buttonHeight+i*CGRectGetWidth(self.view.frame)/2.0, progress_yoffset*2+progress_width+buttonHeight/2+j*offset_y, CGRectGetWidth(self.view.frame)/3.0-buttonHeight-10, buttonHeight/2)];
//            valueLabel.font=[UIFont systemFontOfSize:textheight*0.8];
//            valueLabel.textColor=[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1];
//            valueLabel.tag=i*3+j+1+200;
//            [self.view addSubview:valueLabel];
//            
//            UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/12.0+i*CGRectGetWidth(self.view.frame)/2.0, progress_yoffset*2+progress_width+j*offset_y, CGRectGetWidth(self.view.frame)/3.0, buttonHeight)];
//            button.tag=i*3+j+1;
//            [button addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//            [self.view addSubview:button];
//            button.backgroundColor=[UIColor clearColor];
//        }
//    }
//    UIImageView *selectimageview=(UIImageView*)[self.view viewWithTag:(self.is_select_num+100)];
//    selectimageview.image=[UIImage imageNamed:[NSString stringWithFormat:@"home_%d_1",self.is_select_num]];
    
    [btn1 setSelected:YES];
    [self refreshValueLabel];
    
    CGFloat sleeptipheight = 12;
    CGFloat sleepsep = sleeptipheight/2.0;
    CGFloat sleeptipwidth = CGRectGetWidth(self.view.frame)*0.22;
    
    self.sleeptipview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//    self.sleeptipview.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.sleeptipview];
    [self.sleeptipview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(sleeptipwidth, 3*sleeptipheight+2*sleepsep));
        make.left.mas_equalTo(@10);
        make.bottom.mas_equalTo(btn1.mas_top).with.offset(-20);
    }];
    
    UIView* awakeimg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sleeptipwidth*0.3, sleeptipheight)];
    awakeimg.layer.cornerRadius = sleeptipheight/2.0;
    awakeimg.backgroundColor = [UIColor whiteColor];
    [self.sleeptipview addSubview:awakeimg];
    [awakeimg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(sleeptipwidth*0.3, sleeptipheight));
        make.left.mas_equalTo(@0);
        make.top.mas_equalTo(@0);
    }];
    UILabel* awakelabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, sleeptipwidth*0.7, sleeptipheight)];
    awakelabel.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
    awakelabel.textAlignment = NSTextAlignmentCenter;
    awakelabel.adjustsFontSizeToFitWidth = YES;
    awakelabel.minimumScaleFactor = 0.5;
    awakelabel.text = NSLocalizedString(@"Chart_Awake",nil);
    awakelabel.font = [UIFont systemFontOfSize:sleeptipheight*0.8];
    [self.sleeptipview addSubview:awakelabel];
    [awakelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(sleeptipwidth*0.7, sleeptipheight));
        make.left.mas_equalTo(awakeimg.mas_right);
        make.top.mas_equalTo(@0);
    }];
   
    UIView* lightimg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sleeptipwidth*0.3, sleeptipheight)];
    lightimg.layer.cornerRadius = sleeptipheight/2.0;
    lightimg.backgroundColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0xff/255.0 alpha:1.0];
    [self.sleeptipview addSubview:lightimg];
    [lightimg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(sleeptipwidth*0.3, sleeptipheight));
        make.left.mas_equalTo(@0);
        make.top.mas_equalTo(awakeimg.mas_bottom).with.offset(sleepsep);
    }];
    UILabel* lightlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, sleeptipwidth*0.7, sleeptipheight)];
    lightlabel.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
    lightlabel.textAlignment = NSTextAlignmentCenter;
    lightlabel.adjustsFontSizeToFitWidth = YES;
    lightlabel.minimumScaleFactor = 0.5;
    lightlabel.text = NSLocalizedString(@"Chart_Light",nil);
    lightlabel.font = [UIFont systemFontOfSize:sleeptipheight*0.8];
    [self.sleeptipview addSubview:lightlabel];
    [lightlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(sleeptipwidth*0.7, sleeptipheight));
        make.left.mas_equalTo(lightimg.mas_right);
        make.top.mas_equalTo(awakeimg.mas_bottom).with.offset(sleepsep);
    }];

    UIView* deepimg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sleeptipwidth*0.3, sleeptipheight)];
    deepimg.layer.cornerRadius = sleeptipheight/2.0;
    deepimg.backgroundColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0xcd/255.0 alpha:1.0];
    [self.sleeptipview addSubview:deepimg];
    [deepimg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(sleeptipwidth*0.3, sleeptipheight));
        make.left.mas_equalTo(@0);
        make.top.mas_equalTo(lightimg.mas_bottom).with.offset(sleepsep);
    }];
    UILabel* deeplabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, sleeptipwidth*0.7, sleeptipheight)];
    deeplabel.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
    deeplabel.textAlignment = NSTextAlignmentCenter;
    deeplabel.adjustsFontSizeToFitWidth = YES;
    deeplabel.minimumScaleFactor = 0.5;
    deeplabel.text = NSLocalizedString(@"Chart_Deep",nil);
    deeplabel.font = [UIFont systemFontOfSize:sleeptipheight*0.8];
    [self.sleeptipview addSubview:deeplabel];
    [deeplabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(sleeptipwidth*0.7, sleeptipheight));
        make.left.mas_equalTo(deepimg.mas_right);
        make.top.mas_equalTo(lightimg.mas_bottom).with.offset(sleepsep);
    }];

    
    
    self.sleepprogress.hidden=YES;
    self.heartprogress.hidden=YES;
    self.btn_heart.hidden=YES;
    self.btn_temperature.hidden=YES;
    self.sleeptipview.hidden = YES;
    self.sportprogress.hidden=NO;
}

//点击选择方法
-(void)onBtnClick:(UIButton*)sender{
//    NSDictionary *userinfo = @{@"steps":[NSNumber numberWithInt:0],@"cal":[NSNumber numberWithInt:0],@"distance":[NSNumber numberWithInt:0]};
//    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_current_steps object:nil userInfo:userinfo];
    if (self.is_select_num!=(int)sender.tag) {
//        UIImageView *imageview=(UIImageView*)[self.view viewWithTag:(self.is_select_num+100)];
//        imageview.image=[UIImage imageNamed:[NSString stringWithFormat:@"home_%d_0",self.is_select_num]];
//        UIImageView *selectimageview=(UIImageView*)[self.view viewWithTag:(sender.tag+100)];
//        selectimageview.image=[UIImage imageNamed:[NSString stringWithFormat:@"home_%d_1",(int)sender.tag]];

        UIButton* lastbtn = [self.view viewWithTag:self.is_select_num];
        [lastbtn setSelected:NO];
        self.is_select_num=(int)sender.tag;
        [sender setSelected:YES];
        if (sender.tag>0&&sender.tag<4) {
            self.sleepprogress.hidden=YES;
            self.sleeptipview.hidden = YES;
            self.heartprogress.hidden=YES;
            self.btn_heart.hidden=YES;
            self.btn_temperature.hidden=YES;
            self.sportprogress.hidden=NO;
            [self.sportprogress reload];
            
        }else if (sender.tag==4) {
            self.sportprogress.hidden=YES;
            self.sleepprogress.hidden=YES;
            self.sleeptipview.hidden = YES;
            self.heartprogress.hidden=NO;
            self.btn_heart.hidden=NO;
            self.btn_temperature.hidden=YES;
            self.heartprogress.isShowFloat = NO;
            [self.heartprogress reload];
            [self.heartprogress setHeartValue:self.currenthearts];
        }else if(sender.tag==6){
            self.sportprogress.hidden=YES;
            self.sleepprogress.hidden=YES;
            self.sleeptipview.hidden = YES;
            self.heartprogress.hidden=NO;
            self.btn_heart.hidden=YES;
            self.btn_temperature.hidden=NO;
            self.heartprogress.isShowFloat = YES;
            [self.heartprogress reload];
            [self.heartprogress setTempValue:self.currenttemperature];
//            [self.heartprogress reload];
        }else if (sender.tag==5) {
            self.sportprogress.hidden=YES;
            self.heartprogress.hidden=YES;
            self.btn_heart.hidden=YES;
            self.btn_temperature.hidden=YES;
            self.sleepprogress.hidden=NO;
            self.sleeptipview.hidden = NO;
            [self.sleepprogress reload];
        }
        if (self.btn_temperature.selected == YES) {
            [self stopTemperatureRate:YES];
            
        }
        if (self.btn_heart.selected == YES) {
            [self stopHeartRate:YES];
            
        }
    }
}
//刷新标签显示
-(void)refreshValueLabel{
    UIButton* btn1 = [self.view viewWithTag:1];
    NSAttributedString* title1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",NSLocalizedString(@"Home_text1", nil)] attributes:self.upperattri];
    NSAttributedString* content1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d%@",(int)self.currentsteps,NSLocalizedString(@"UNIT_STEP", nil)] attributes:self.lowerattri];
    NSMutableAttributedString* attr1 = [[NSMutableAttributedString alloc] initWithAttributedString:title1];
    [attr1 appendAttributedString:content1];
    [btn1 setAttributedTitle:attr1 forState:UIControlStateNormal];
    
    UIButton* btn2 = [self.view viewWithTag:2];
    
    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
        NSAttributedString* title2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",NSLocalizedString(@"Home_text2", nil)] attributes:self.upperattri];
        NSAttributedString* content2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.3f%@",[self getDistance],NSLocalizedString(@"UNIT_KM", nil)] attributes:self.lowerattri];
        NSMutableAttributedString* attr2 = [[NSMutableAttributedString alloc] initWithAttributedString:title2];
        [attr2 appendAttributedString:content2];
        [btn2 setAttributedTitle:attr2 forState:UIControlStateNormal];
    }else{
        NSAttributedString* title2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",NSLocalizedString(@"Home_text2", nil)] attributes:self.upperattri];
        NSAttributedString* content2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.3f%@",[self getDistance],NSLocalizedString(@"UNIT_MILE", nil)] attributes:self.lowerattri];
        NSMutableAttributedString* attr2 = [[NSMutableAttributedString alloc] initWithAttributedString:title2];
        [attr2 appendAttributedString:content2];
        [btn2 setAttributedTitle:attr2 forState:UIControlStateNormal];
    }


    UIButton* btn3 = [self.view viewWithTag:3];
    NSAttributedString* title3 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",NSLocalizedString(@"Home_text3", nil)] attributes:self.upperattri];
    NSAttributedString* content3 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.0f%@",[self getCals],NSLocalizedString(@"UNIT_KCAL", nil)] attributes:self.lowerattri];
    NSMutableAttributedString* attr3 = [[NSMutableAttributedString alloc] initWithAttributedString:title3];
    [attr3 appendAttributedString:content3];
    [btn3 setAttributedTitle:attr3 forState:UIControlStateNormal];

    UIButton* btn4 = [self.view viewWithTag:4];
    NSAttributedString* title4 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",NSLocalizedString(@"Home_text4", nil)] attributes:self.upperattri];
    NSAttributedString* content4 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d %@",(int)self.currenthearts,NSLocalizedString(@"BPM", nil)] attributes:self.lowerattri];
    NSMutableAttributedString* attr4 = [[NSMutableAttributedString alloc] initWithAttributedString:title4];
    [attr4 appendAttributedString:content4];
    [btn4 setAttributedTitle:attr4 forState:UIControlStateNormal];

    UIButton* btn5 = [self.view viewWithTag:5];
    NSAttributedString* title5 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",NSLocalizedString(@"Home_text5", nil)] attributes:self.upperattri];
    NSAttributedString* content5 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d%@%d%@",(int)[self getCurrentSleepTimes]/3600,NSLocalizedString(@"UNIT_H", nil),(int)(((int)[self getCurrentSleepTimes]%3600)/60),NSLocalizedString(@"UNIT_M", nil)] attributes:self.lowerattri];
    NSMutableAttributedString* attr5 = [[NSMutableAttributedString alloc] initWithAttributedString:title5];
    [attr5 appendAttributedString:content5];
    [btn5 setAttributedTitle:attr5 forState:UIControlStateNormal];

    UIButton* btn6 = [self.view viewWithTag:6];
    NSAttributedString* title6 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",NSLocalizedString(@"Home_text6", nil)] attributes:self.upperattri];
    NSAttributedString* content6 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.1f%@",self.currenttemperature,@"°C"] attributes:self.lowerattri];
    NSMutableAttributedString* attr6 = [[NSMutableAttributedString alloc] initWithAttributedString:title6];
    [attr6 appendAttributedString:content6];
    [btn6 setAttributedTitle:attr6 forState:UIControlStateNormal];

//    UILabel *label1=(UILabel*)[self.view viewWithTag:201];
//    label1.text=[NSString stringWithFormat:@"%d%@",(int)self.currentsteps,NSLocalizedString(@"UNIT_STEP", nil)];
//    UILabel *label2=(UILabel*)[self.view viewWithTag:202];
//    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//        label2.text=[NSString stringWithFormat:@"%.2f%@",[self getDistance],NSLocalizedString(@"UNIT_KM", nil)];
//    }else{
//        label2.text=[NSString stringWithFormat:@"%.2f%@",[self getDistance],NSLocalizedString(@"UNIT_MILE", nil)];
//    }
//    UILabel *label3=(UILabel*)[self.view viewWithTag:203];
//    label3.text=[NSString stringWithFormat:@"%.0f%@",[self getCals],NSLocalizedString(@"UNIT_KCAL", nil)];
//    
//    UILabel *label4=(UILabel*)[self.view viewWithTag:204];
//    label4.text=[NSString stringWithFormat:@"%d %@",(int)self.currenthearts,NSLocalizedString(@"BPM", nil)];
//    
//    UILabel *label5=(UILabel*)[self.view viewWithTag:205];
//    label5.text=[NSString stringWithFormat:@"%d:%d%@",(int)[self getCurrentSleepTimes]/3600,(int)(((int)[self getCurrentSleepTimes]%3600)/60),@"H"];
//    
//    UILabel *label6=(UILabel*)[self.view viewWithTag:206];
//    label6.text=[NSString stringWithFormat:@"%.1f%@",self.currenttemperature,@"°C"];
}



#pragma mark --------SportProgress Delegate--------Start
-(UIColor*)getSportProgressColor{
    return [UIColor colorWithRed:0x55/255.0 green:0xa7/255.0 blue:0xe9/255.0 alpha:1];
}
-(UIColor*)IRKSportProgressBoardColor:(IRKSportProgress*)view{
    return [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
}

-(CGFloat)getSportProgress{
//    return (arc4random()%100)/100.0;
    CGFloat progress = 0;
    if (self.is_select_num == 1) {
        progress =  self.currentsteps / (self.commondata.target_steps*1.0);
    }else if (self.is_select_num == 2){
        progress =  [self getDistance] / self.commondata.target_distance;
    }else{
        progress =  [self getCals] / self.commondata.target_calorie;
    }
    if (progress>1) {
        progress = 1.0;
    }
    return progress;
}

-(CGFloat)getSportTextSize:(int)index{
    if (index == 1 || index == 3) {
        if (DEVICE_IS_IPHONE5)
            return 20;
        else
            return 18;
    }
    else{
        if (DEVICE_IS_IPHONE5)
            return 40;
        else
            return 36;
    }
}
-(NSString*)getSportText:(int)index{
    if (index == 3) {
        if (self.is_select_num == 1) {
            return [NSString stringWithFormat:@"%@:%ld",NSLocalizedString(@"Goal", nil), (long)self.commondata.target_steps];
        }else if(self.is_select_num == 2){
//            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//                
//                return [NSString stringWithFormat:@"%@:%.2f",NSLocalizedString(@"Goal", nil), self.commondata.target_distance];
//            }else{
//                return [NSString stringWithFormat:@"%@:%.2f",NSLocalizedString(@"Goal", nil), self.commondata.target_distance*KM2MILE];
//            }
            return [NSString stringWithFormat:@"%@:%.2f",NSLocalizedString(@"Goal", nil), self.commondata.target_distance];
        }else{
            return [NSString stringWithFormat:@"%@:%.1f",NSLocalizedString(@"Goal", nil), self.commondata.target_calorie];
            return @"";
        }
    }else if(index == 1){
        if (self.is_select_num == 1) {
            return NSLocalizedString(@"Home_text1", nil);
        }else if (self.is_select_num == 2){
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                return [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"Home_text2", nil),NSLocalizedString(@"UNIT_KM", nil)];
            }else{
                return [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"Home_text2", nil),NSLocalizedString(@"UNIT_MILE", nil)];
            }
//            return NSLocalizedString(@"Home_text2", nil);
        }else{
            return [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"Home_text3", nil),NSLocalizedString(@"UNIT_KCAL", nil)];
//            return NSLocalizedString(@"Home_text3", nil);
        }
    }else{
        return @"";
    }
}
-(CGFloat)IRKSportProgressCurrentSteps:(IRKSportProgress*)view{
    if (self.is_select_num == 1) {
        return self.currentsteps;
    }else if(self.is_select_num == 2){
        CGFloat dis = [self getDistance];//做过公英制处理
        if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
            return dis;
        }else{
            return dis;
        }
    }else{
        return [self getCals];
    }
}

-(NSInteger)IRKSportProgressCurrentSelectedBalance:(IRKSportProgress*)view{
    return self.is_select_num;
}
#pragma mark --------SportProgress Delegate--------End

#pragma mark --------SleepProgress Delegate--------Start
-(UIColor*)IRKSleepProgressTitleColor:(IRKSleepProgress*)view{
    return [UIColor colorWithRed:0x5b/255.0 green:0x70/255.0 blue:0xd9/255.0 alpha:1];
}

-(UIColor*)IRKSleepProgressBoardColor:(IRKSleepProgress*)view{
    return [UIColor whiteColor];
//    return [UIColor colorWithRed:0xdb/255.0 green:0xdb/255.0 blue:0xdb/255.0 alpha:1];
}

-(NSUInteger)getDataSegCount{
    return 144;
}

-(IRKSleepType)getSleepTypeByIndex:(NSUInteger)index{
    NSNumber* data = (NSNumber*)[self.sleepdict objectForKey:[NSString stringWithFormat:@"%d",(int)index]];
    if (data == nil){
        return IRKSleepTypeUnSleep;
    }
    int move = data.intValue;
    
//    int move = arc4random()%40;
    
    if (move > HJT_SLEEP_MODE_AWAKE) {
        return IRKSleepTypeAwake;
//    }else if(move > HJT_SLEEP_MODE_EXLIGHT){
//        return IRKSleepTypeExLightSleep;
    }else if(move > HJT_SLEEP_MODE_LIGHT){
        return IRKSleepTypeLightSleep;;
    }else{
        return IRKSleepTypeDeepSleep;
    }
}
-(UIColor*)getColorByType:(IRKSleepType)type{
    if (type == IRKSleepTypeDeepSleep) {
        return [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0xcd/255.0 alpha:1];
        //return self.commondata.colorDeep;
    }else if (type == IRKSleepTypeLightSleep){
        return [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0xff/255.0 alpha:1];
        //return self.commondata.colorLight;
    }else if (type == IRKSleepTypeExLightSleep){
        return [UIColor colorWithRed:0x5b/255.0 green:0x70/255.0 blue:0xd9/255.0 alpha:1];
        //return self.commondata.colorExlight;
    }else if (type == IRKSleepTypeAwake){
        return [UIColor whiteColor];
    }else{
        return [UIColor clearColor];
    }
}

-(NSString*)getText:(int)index{
    NSTimeInterval deepsleeptimes = [self getCurrentDeepSleepTimes];
    if (index == 1) {
        if (self.is_select_num==5) {
            return NSLocalizedString(@"sleep_time", nil);
        }else{
            return NSLocalizedString(@"Home_text6", nil);
        }
    }else if(index == 3){//不需要显示深睡了
        return [NSString stringWithFormat:@"%@:%d%@%d%@",NSLocalizedString(@"Home_Label_DeepTime", nil),(int)deepsleeptimes/3600,NSLocalizedString(@"UNIT_H", nil),(int)(((int)deepsleeptimes%3600)/60),NSLocalizedString(@"UNIT_M", nil)];
//        return @"";
    }else{
        return @"";
    }
}

-(CGFloat)IRKSleepProgressCurrentSleep:(IRKSleepProgress*)view{
    if (self.is_select_num==5) {
        return [self getCurrentSleepTimes];
    }else{
        return [self getCurrentSleepTimes];
    }
}

#pragma mark --------SleepProgress Delegate--------End

#pragma mark --------HeartProgress Delegate--------Start
-(UIColor*)IRKHeartProgressBackgroundColor:(IRKHeartProgress*)view{
    return [UIColor clearColor];
}

-(UIColor*)IRKHeartProgressTextColor:(IRKHeartProgress*)view{
    
    return [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1];
}

-(UIColor*)IRKHeartProgressTrackerColor:(IRKHeartProgress*)view{
    return [UIColor colorWithRed:0xdb/255.0 green:0xdb/255.0 blue:0xdb/255.0 alpha:1];
}

-(UIColor*)IRKHeartProgressCircleBarColor:(IRKHeartProgress*)view{
    if (self.is_select_num==4) {
        return [UIColor colorWithRed:0xfc/255.0 green:0x3c/255.0 blue:0x51/255.0 alpha:1];
    }else if (self.is_select_num==6){
        return [UIColor colorWithRed:0x7d/255.0 green:0x94/255.0 blue:0x9a/255.0 alpha:1];
    }else{
        return [UIColor colorWithRed:0xff/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1];
    }

}

-(CGFloat)IRKHeartProgressTrackerWidth:(IRKHeartProgress*)view{
    return 3;
}

-(UIImage*)IRKHeartProgressHeartImage:(IRKHeartProgress*)view{
    return [UIImage imageNamed:@"icon_heart_bmp"];
}

-(NSString*)IRKHeartProgressText:(IRKHeartProgress*)view{
    return NSLocalizedString(@"Home_text4", nil);
    
}

-(CGFloat)IRKHeartProgressCircleBarWidth:(IRKHeartProgress*)view{
    return 10;
}

-(NSInteger)IRKHeartProgressCurrentSelectedBalance:(IRKHeartProgress *)view{
    return self.is_select_num;
}
#pragma mark --------HeartProgress Delegate--------End
#pragma mark --------LWSyncViewDelegate Method--------
-(void)LWSyncViewClickClose:(LWSyncView *)view{
    [self.popup dismissPresentingPopup];
    self.popup = nil;
    self.notifyView = nil;
}


#pragma mark--------心率检测--------
-(void)onClickHeart:(UIButton*)sender{
//    if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
//        UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
//        [alerview show];
//        return;
//    }
    if (self.btn_temperature.selected) {
        return;
    }
    
    if (!sender.selected) {
        [self.heartprogress setHeartValue:0];
        [self openHeartRate:YES];
//        [self loadHeartData];
    }else{
        [self stopHeartRate:YES];
        //停止以后刷新测量数据；
    }
    
    
}

-(void)onClickTemperature:(UIButton*)sender{
    if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
        UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Device_unavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alerview show];
        return;
    }
    if (self.btn_heart.selected) {
        return;
    }
    
    //            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"此功能暂未开放" delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
    //            [alert show];
    
    if (!sender.selected) {
        [self.heartprogress setTempValue:0];
        [self openTemperatureRate:YES];
//        [self loadHeartData];
    }else{
        [self stopTemperatureRate:YES];
        //停止以后刷新测量数据；
    }
}

- (void)openHeartRate:(BOOL) isSendCmd{
    //心率状态标志位
    _heartStatus = 1;
    //重置心率值
    [self resetHeartValue];
    [self.heartprogress startAnimation];
    [self.btn_heart setSelected:YES];
    if(isSendCmd){
        NSString* cmd = [[NSString alloc] initWithFormat:@"%@:128:1:1",CMD_SENSOR_CHANGE];
        [self.mainloop sendCmd:cmd];
    }
}

- (void)openTemperatureRate:(BOOL) isSendCmd{
    //心率状态标志位
    _heartStatus = 1;
    //重置心率值
    [self resetHeartValue];
    [self.heartprogress startAnimation];
    [self.btn_temperature setSelected:YES];
    if(isSendCmd){
        NSString* cmd = [[NSString alloc] initWithFormat:@"%@:16:1:1",CMD_SENSOR_CHANGE];
        [self.mainloop sendCmd:cmd];
    }
}

- (void)resetHeartValue{
    _heartValue = 0;
    self.temperatureValue = 0;
//    _currenttemperature = 0;
}

- (void)stopHeartRate:(BOOL) isSendCmd{
    //心率状态标志位
    _heartStatus = 0;
    [self.heartprogress stopAnimation];
    [self.btn_heart setSelected:NO];
    if(isSendCmd){
        //收到心率数据后发送停止命令
        NSString* cmd = [[NSString alloc] initWithFormat:@"%@:128:0:0",CMD_SENSOR_CHANGE];
        [self.mainloop sendCmd:cmd];
    }
    if(_heartValue > 0){
        //停止的时候保存心率数据
        [self saveHeartValue:_heartValue];
    }
}

- (void)stopTemperatureRate:(BOOL) isSendCmd{
    //心率状态标志位
    _heartStatus = 0;
    [self.heartprogress stopAnimation];
    [self.btn_temperature setSelected:NO];
    if(isSendCmd){
        //收到心率数据后发送停止命令
        NSString* cmd = [[NSString alloc] initWithFormat:@"%@:16:0:0",CMD_SENSOR_CHANGE];
        [self.mainloop sendCmd:cmd];
    }
    if(self.temperatureValue > 0){
        //停止的时候保存心率数据
        //[self saveHeartValue:_heartValue];
//        self.currenttemperature=_heartValue;
        [self saveTempValue:self.currenttemperature];
//        [self refreshValueLabel];
    }
}

- (void)saveHeartValue:(NSInteger)value{
    
    //    if(activityvalue.intValue != self.rateControl)
    //    {
    //        self.rateControl = activityvalue.intValue;
    
    __typeof (&*self) __weak weakSelf = self;
    //将得到的心率数据写数据库
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AppDelegate* appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        Context.parentContext = appdelegate.managedObjectContext;
        NSMutableDictionary* bonginfo =[self.commondata getBongInformation:self.commondata.lastBongUUID];
        
        NSString* macid = [bonginfo objectForKey:BONGINFO_KEY_BLEADDR];

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Health_data_history" inManagedObjectContext:Context];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        NSCalendar* calender = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
        NSDateComponents* comp = [[NSDateComponents alloc] init];
        comp = [calender components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate date]];
        comp.second = 0;
        NSDate* adddate = [calender dateFromComponents:comp];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adddate = %@ and macid = %@ and memberid = %@ and type = %@", adddate, macid, weakSelf.commondata.memberid, [NSNumber numberWithInt:SENSOR_TYPE_SERVER_HEARTRATE]];
        
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSError* error = nil;
        NSArray *fetchedObjects = [Context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || fetchedObjects.count == 0) {
            NSLog(@"new record");
            Health_data_history* record = [NSEntityDescription insertNewObjectForEntityForName:@"Health_data_history" inManagedObjectContext:Context];
            record.uid = weakSelf.commondata.uid;
            record.macid = macid;
            record.issync = [NSNumber numberWithBool:NO];
            record.value = [NSNumber numberWithInteger:value];
            record.adddate = adddate;
            record.type = [NSNumber numberWithInt:SENSOR_TYPE_SERVER_HEARTRATE];
            record.memberid = weakSelf.commondata.memberid;
            //////////for healthkit/////////////
            record.issynchealthkit = [NSNumber numberWithBool:NO];
            record.value2 = @0;
        }else{
            Health_data_history* record = (Health_data_history*)[fetchedObjects objectAtIndex:0];
            NSLog(@"exists record %@",record);
            record.value = [NSNumber numberWithInteger:value];
        }
        
        //            NSLog(@"record = %@",record);
        
//        NSError * error;
//        [weakSelf.managedObjectContext save:&error];
        [Context performBlockAndWait:^{
            NSError *error;
            if (![Context save:&error])
            {
                // handle error
                NSLog(@"save heartvalue error:%@",error);
            }
            
            // save parent to disk asynchronously
            [Context.parentContext performBlockAndWait:^{
                NSError *error;
                if (![Context.parentContext save:&error])
                {
                    // handle error
                    NSLog(@"save heartvalue error:%@",error);
                }
            }];
        }];

        [[TaskManager SharedInstance] AddUpLoadTaskBySyncKey:SYNCKEY_BODYFUNCTION];
        //////////for healthkit/////////////
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_syncdata_to_healthkit object:nil userInfo:@{@"tablename":@"Health_data_history"}];
        
        [weakSelf resetHeartValue];
        //NSLog(@"%@",error);
    });
    //    }
//    [self loadHeartData];
}

- (void)saveTempValue:(CGFloat)value{
    __typeof (&*self) __weak weakSelf = self;
    //将得到的心率数据写数据库
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary* bonginfo =[self.commondata getBongInformation:self.commondata.lastBongUUID];
        
        NSString* macid = [bonginfo objectForKey:BONGINFO_KEY_BLEADDR];
        AppDelegate* appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        Context.parentContext = appdelegate.managedObjectContext;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Health_data_history" inManagedObjectContext:Context];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        NSCalendar* calender = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
        NSDateComponents* comp = [[NSDateComponents alloc] init];
        comp = [calender components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate date]];
        comp.second = 0;
        NSDate* adddate = [calender dateFromComponents:comp];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adddate = %@ and macid = %@ and memberid = %@ and type = %@", adddate, macid, weakSelf.commondata.memberid, [NSNumber numberWithInt:SENSOR_TYPE_SERVER_TEMPERATURE]];
        
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSError* error = nil;
        NSArray *fetchedObjects = [Context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || fetchedObjects.count == 0) {
            NSLog(@"new record");
            Health_data_history* record = [NSEntityDescription insertNewObjectForEntityForName:@"Health_data_history" inManagedObjectContext:weakSelf.managedObjectContext];
            record.uid = weakSelf.commondata.uid;
            record.macid = macid;
            record.issync = [NSNumber numberWithBool:NO];
            record.value = [NSNumber numberWithFloat:value];
            record.adddate = adddate;
            record.type = [NSNumber numberWithInt:SENSOR_TYPE_SERVER_TEMPERATURE];
            record.memberid = self.commondata.memberid;
            //////////for healthkit/////////////
            record.issynchealthkit = [NSNumber numberWithBool:NO];
            record.value2 = @0;
        }else{
            Health_data_history* record = (Health_data_history*)[fetchedObjects objectAtIndex:0];
            NSLog(@"exists record %@",record);
            record.value = [NSNumber numberWithInteger:value];

        }
        //            NSLog(@"record = %@",record);
        
//        NSError * error;
//        [weakSelf.managedObjectContext save:&error];
        [Context performBlockAndWait:^{
            NSError *error;
            if (![Context save:&error])
            {
                // handle error
                NSLog(@"save heartvalue error:%@",error);
            }
            
            // save parent to disk asynchronously
            [Context.parentContext performBlockAndWait:^{
                NSError *error;
                if (![Context.parentContext save:&error])
                {
                    // handle error
                    NSLog(@"save heartvalue error:%@",error);
                }
            }];
        }];

        [[TaskManager SharedInstance] AddUpLoadTaskBySyncKey:SYNCKEY_BODYFUNCTION];
        //////////for healthkit/////////////
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_syncdata_to_healthkit object:nil userInfo:@{@"tablename":@"Health_data_history"}];
        [weakSelf resetHeartValue];
        //NSLog(@"%@",error);
    });
    //    }
//    [self loadHeartData];
}

- (void)loadHeartData{
    __typeof (&*self) __weak weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSMutableDictionary* bonginfo =[self.commondata getBongInformation:self.commondata.lastBongUUID];
//        NSString* macid = [bonginfo objectForKey:BONGINFO_KEY_BLEADDR];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Health_data_history" inManagedObjectContext:weakSelf.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@ and uid = %@",[NSNumber numberWithInt:SENSOR_TYPE_SERVER_HEARTRATE], weakSelf.commondata.uid];
        [fetchRequest setPredicate:predicate];
        //按时间降序查询
        NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"adddate" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSort]];
        NSError *error = nil;
        NSArray *fetchedObjects = [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects != nil && [fetchedObjects count] != 0){
            Health_data_history *obj = [fetchedObjects objectAtIndex:0];
            weakSelf.currenthearts=obj.value.intValue;
            NSLog(@"%@",obj.adddate);
        }else{
            weakSelf.currenthearts=0;
        }
        //取最后一条温度
        predicate = [NSPredicate predicateWithFormat:@"type = %@ and uid = %@",[NSNumber numberWithInt:SENSOR_TYPE_SERVER_TEMPERATURE], weakSelf.commondata.uid];
        [fetchRequest setPredicate:predicate];
        fetchedObjects = [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects != nil && [fetchedObjects count] != 0){
            Health_data_history *obj = [fetchedObjects objectAtIndex:0];
            weakSelf.currenttemperature=obj.value.floatValue;
        }else{
            weakSelf.currenttemperature=0;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.heartSumView.walkingModel = heartModel;
            [weakSelf.heartprogress reload];
            [weakSelf refreshHeartTempProgress];
//            if (weakSelf.is_select_num == 4) {
//                [weakSelf.heartprogress setHeartValue:weakSelf.currenthearts];
//            }else if (weakSelf.is_select_num == 6){
//                [weakSelf.heartprogress setTempValue:weakSelf.currenttemperature];
//            }
            [weakSelf refreshValueLabel];
        });
    });
}

-(void)refreshHeartTempProgress{
    if (self.is_select_num == 4) {
        [self.heartprogress setHeartValue:self.currenthearts];
    }else if(self.is_select_num == 6){
        [self.heartprogress setTempValue:self.currenttemperature];
    }
}
#pragma mark --------Auxiliary Method--------
//获取步数
-(CGFloat)getCurrentStep{
    return self.currentsteps;
//    if (self.pagecontrol.currentPage == 0){
//        if (![self isDateInToday:self.currentDate]) {
//            return self.currentsteps;
//        }
//        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//        NSDate* lastc6date = [ud objectForKey:CONFIG_KEY_LAST_C6_TIME];
//        
//        if (lastc6date == nil || ![self isDateInToday:lastc6date]){
//            return self.currentsteps;
//        }
//        if ([self isDateInToday:[lastc6date copy]] && [self isDateInToday:self.currentDate]) {
//            return self.commondata.last_c6steps;
//        }else{
//            return self.currentsteps;
//        }
//    }else{
//        return 0;
//    }
}
//获取距离
-(CGFloat)getDistance{//已做过公英制处理
    return [self.commondata getDistance:[self getCurrentStep]];
}
//获取卡路里
-(CGFloat)getCals{
    return [self.commondata getCal:[self getCurrentStep]];
}
//获取睡眠时长
-(NSTimeInterval)getCurrentSleepTimes{
    return self.sleepcount*10*60;
}
//获取深睡时长
-(NSTimeInterval)getCurrentDeepSleepTimes{
    return self.deepsleepcount*10*60;
}

-(void)procSleepData{
    if (self.sleepdict) {
        [self.sleepdict removeAllObjects];
        self.sleepdict = nil;
    }
    
    self.sleepcount = 0;
    self.deepsleepcount = 0;
    self.sleepdict = [[NSMutableDictionary alloc] init];
    for (StepHistory* steps in self.fetchedObjects) {
//        NSLog(@"sleep cout = %d,%@",steps.steps.intValue,steps.datetime);
        NSDate* date = steps.datetime;
       
        NSTimeInterval t1 = [date timeIntervalSince1970] - self.starttimeinterval;
        NSString* indexkey =[NSString stringWithFormat:@"%d", (int)t1/(10*60)];
        [self.sleepdict setObject:[NSNumber numberWithInt:steps.steps.intValue] forKey:indexkey];
        if (steps.steps.intValue <= HJT_SLEEP_MODE_AWAKE)
            self.sleepcount += 1;
        
        if (steps.steps.intValue <= HJT_SLEEP_MODE_LIGHT) {
            self.deepsleepcount += 1;
        }
        if (steps.steps.intValue > HJT_SLEEP_MODE_LIGHT && steps.steps.intValue <HJT_SLEEP_MODE_EXLIGHT) {
            self.lightsleepcount += 1;
        }
        if (steps.steps.intValue > HJT_SLEEP_MODE_EXLIGHT && steps.steps.intValue < HJT_SLEEP_MODE_AWAKE) {
            self.extrmelysleepcount += 1;
        }
        if (steps.steps.intValue > HJT_SLEEP_MODE_AWAKE){
            self.awakeCount += 1;
        }
    }
    [self.sleepprogress reload];

}

-(void)getHistoryData{
    [self getSportHistoryData];
    [self getSleepHistoryData];
    [self procSleepData];
}
-(void)reloadUI{
    if (self.blecontrol.is_connected == IRKConnectionStateConnected) {
        //[self.mainloop ReadBongBatteryLevel];
        [self.btn_sync setEnabled:YES];
    }else{
        [self.btn_sync setEnabled:NO];
    }

    [self.sportprogress reload];
    [self.sleepprogress reload];
}

-(void)reload{
    [self getHistoryData];
    [self reloadUI];
}

-(BOOL)isDateInToday:(NSDate*)currentdate{
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    format.dateFormat = @"yyyy-MM-dd";
    NSDate* today = [NSDate date];
    NSString* todaystr = [format stringFromDate:today];
    NSString* currentstr = [format stringFromDate:currentdate];
    if ([todaystr isEqualToString:currentstr]) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark--------Get Core Data--------
-(void)getSportHistoryData{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //   NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
//    NSTimeInterval timeZoneOffset = 0;
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSString * datebeginstr = [dateFormatter stringFromDate:self.currentDate];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 23:59:59"];
    NSString * dateendstr = [dateFormatter stringFromDate:self.currentDate];
   
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate * datebegin = [[dateFormatter dateFromString:datebeginstr] dateByAddingTimeInterval:timeZoneOffset];
    NSDate* datebegin = [dateFormatter dateFromString:datebeginstr];
    NSDate* dateend = [dateFormatter dateFromString:dateendstr];
    NSLog(@"datebegin = %@, dateend=%@",datebegin,dateend);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    NSString* macid = @"";
    if (bi) {
        if ([bi.allKeys containsObject:BONGINFO_KEY_BLEADDR]){
            macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
        }
    }
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid =%@ and macid = %@ and mode <> %@",datebegin, dateend, self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_SLEEP]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode in {%@,%@}",datebegin,dateend,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_DAILY],[NSNumber numberWithInt:HJT_STEP_MODE_SPORT]];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime"ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    fetchRequest.returnsDistinctResults = YES;
    
    fetchRequest.resultType = NSDictionaryResultType;
//    fetchRequest.propertiesToGroupBy = [NSArray arrayWithObjects:@"dateStr",@"type", nil];
    
    NSMutableArray* expresslist = [[NSMutableArray alloc] init];
    
    NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
    expression.name = @"sumsteps";
    expression.expression = [NSExpression expressionWithFormat:@"@sum.steps"];
    expression.expressionResultType = NSInteger32AttributeType;
    [expresslist addObject:expression];
    
    fetchRequest.propertiesToFetch = expresslist;

    
    NSError *error = nil;
    
    NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"%@",fetchedObjects);
    if ([fetchedObjects count]) {
        NSDictionary* fetchdict = [fetchedObjects firstObject];
        if ([fetchdict.allKeys containsObject:@"sumsteps"]) {
            NSInteger currentstep = [[fetchdict objectForKey:@"sumsteps"] integerValue];
            if (currentstep == 0 && self.currentsteps != 0) {
                NSLog(@"no need change step to 0");
            }else{
                self.currentsteps = currentstep;
            }
            
        }
    }
//
//    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
//        NSLog(@"error");
//        self.currentsteps = 0;
//    }else{
//        StepHistory_Day* stepday = (StepHistory_Day*)[fetchedObjects objectAtIndex:0];
//        self.currentsteps = stepday.steps.intValue;
//        NSLog(@"macid = %@, uid = %@, steps = %d",stepday.macid, stepday.uid, stepday.steps.intValue);
//    }
}

-(void)getSleepHistoryData{
    NSDate * prevday = [self.currentDate dateByAddingTimeInterval:-24*60*60];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    NSTimeInterval timeZoneOffset = 0;
    //    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd 18:00:00"];
    NSString * datebeginstr = [dateFormatter stringFromDate:prevday];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * datebegin = [dateFormatter dateFromString:datebeginstr];
    NSLog(@"datebegin = %@",datebegin);
    self.starttimeinterval = [datebegin timeIntervalSince1970];

    [dateFormatter setDateFormat:@"yyyy-MM-dd 17:59:59"];
    NSString * dateendstr = [dateFormatter stringFromDate:self.currentDate];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * dateend = [dateFormatter dateFromString:dateendstr];
    NSLog(@"dateend = %@",dateend);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    NSString* macid = @"";
    if (bi) {
        if ([bi.allKeys containsObject:BONGINFO_KEY_BLEADDR]){
            macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
        }
    }
    //总睡眠时间不要清醒
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and mode = %@ and uid =%@ and macid =%@ ",datebegin,dateend,[NSNumber numberWithInt:HJT_STEP_MODE_SLEEP], self.commondata.uid, macid];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime"ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSError *error = nil;
    if (self.fetchedObjects){
        self.fetchedObjects = nil;
    }
    self.fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (self.fetchedObjects == nil) {
        NSLog(@"error");
    }
}

#pragma mark --------Notification Method--------
//定时器定期同步
-(void)ReadCurrentSteps:(NSNotification*)nofify{
    if (self.mainloop.runmode == RUNMODE_BACKGROUD) {
        return;
    }
    [self.mainloop HomeGetCurrentData];
}

-(void)ConnectStateChanged:(NSNotification*)notify{
    if (self.blecontrol.is_connected == IRKConnectionStateConnected) {
        //[self.mainloop ReadBongBatteryLevel];
        [self.btn_sync setEnabled:YES];
    }else{
        [self.btn_sync setEnabled:NO];
        if (self.btn_heart.isSelected) {
            [self stopHeartRate:YES];
        }else if (self.btn_temperature.isSelected){
            [self stopTemperatureRate:YES];
        }
    }
}

-(void)GetCurrentSteps:(NSNotification*)notify{
    NSNumber *steps = (NSNumber*)[[notify userInfo] objectForKey:@"steps"];
    self.currentsteps = [steps integerValue];
    [self.sportprogress reload];
    [self refreshValueLabel];
}

-(void)onGetHeartData:(NSNotification*)notify{
    if (self.btn_heart.selected == YES || self.btn_temperature.selected == YES) {
        NSNumber* sensortype = [notify.userInfo objectForKey:SENSOR_REPORT_INFO_KEY_TYPE];
        
        if (sensortype.integerValue == SENSOR_HEARTRATE) {
            NSNumber * activityvalue = [notify.userInfo objectForKey:SENSOR_REPORT_INFO_KEY_VALUE];
//            [self.heartprogress setHeartValue:activityvalue.integerValue];
            self.currenthearts = activityvalue.intValue;
            self.heartValue = activityvalue.intValue;
        }else if (sensortype.integerValue == SENSOR_TEMPERATURE){
            NSNumber * activityvalue = [notify.userInfo objectForKey:SENSOR_REPORT_INFO_KEY_VALUE];
//            [self.heartprogress setTempValue:activityvalue.floatValue];
            self.currenttemperature = activityvalue.floatValue;
            self.temperatureValue = activityvalue.floatValue;
        }
        [self refreshHeartTempProgress];
        [self refreshValueLabel];

    }
}

- (void)onChangeHeartStatus:(NSNotification *)notify{
    NSString *status = [notify.userInfo objectForKey:SENSOR_REPORT_ONOFF];
    if(status.intValue == 0){
        if(_heartStatus){
            if (self.is_select_num == 4) {
                [self stopHeartRate:NO];
            }else{
                [self stopTemperatureRate:NO];
            }
        }else{
            if(_heartValue > 0 &&_heartStatus == NO&&self.is_select_num!=4){
                //进不来，因为_heartValue>0的时候不会进入这个else
                [self saveHeartValue:_heartValue];
            }
        }//这个时候是手环停止测量的，可能不在心率测量界面，但数据仍需要保存
    }else{
        //当前心率是关闭状态且在心率页面才开启
        if(!_heartStatus && self.is_select_num == 4)
            [self openHeartRate:NO];
        else if(!_heartStatus && self.is_select_num == 6)
            [self openTemperatureRate:NO];
    }
}

- (void)onReadSportData:(NSNotification *)notify{
    [self reload];
}

-(void)onFinish{
    NSLog(@"onFinish::::::::::::::::>>>>>>>>");
    [self getHistoryData];
    [self.popup dismissPresentingPopup];
    self.popup = nil;
    self.notifyView = nil;
}

#pragma mark--------Sync Method--------
-(void)onClickSync:(UIButton*)sender{
    if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
        UIAlertController* ac = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Sync_connect_first", nil) preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:ac animated:YES completion:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_start_sync_history object:nil];
    }
}
#pragma mark --------Share Method--------
-(void)onClickShare:(id)sender{
    //[self ScreenShot];
    
    NSArray* imageArray = @[[self screenshot2]];
    UIImage *image=[self screenshot2];
    //    （注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
    if (imageArray) {
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
//        NSURL* url = [NSURL URLWithString:@"http://www.keeprapid.com"];
        [shareParams SSDKSetupShareParamsByText:NSLocalizedString(@"ShareText", nil)
                                         images:image
                                            url:nil
                                          title:NSLocalizedString(@"ShareText", nil)
                                           type:SSDKContentTypeAuto];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
//                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
//                                                                                   message:nil
//                                                                                  delegate:nil
//                                                                         cancelButtonTitle:@"确定"
//                                                                         otherButtonTitles:nil];
//                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
//                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
//                                                                               message:[NSString stringWithFormat:@"%@",error.userInfo[@"error_message"]]
//                                                                              delegate:nil
//                                                                     cancelButtonTitle:@"OK"
//                                                                     otherButtonTitles:nil, nil];
//                               
//                               [alert show];
                               break;
                           }
                           case SSDKResponseStateCancel:
                           {
//                               UIAlertView *alertViews = [[UIAlertView alloc] initWithTitle:@"分享已取消"
//                                                                                    message:nil
//                                                                                   delegate:nil
//                                                                          cancelButtonTitle:@"确定"
//                                                                          otherButtonTitles:nil];
//                               [alertViews show];
                               break;
                           }
                           default:
                               break;
                       }
                       
                   }];
        
    }
}

-(UIImage*)screenshot2{
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    NSLog(@"appdelegate.window.bounds.==%@",appdelegate.window.bounds);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(appdelegate.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(appdelegate.window.bounds.size);
    
    //[[[[UIApplication sharedApplication] windows] objectAtIndex:0] drawViewHierarchyInRect:appdelegate.window.bounds afterScreenUpdates:YES]; // Set To YES
    
    [appdelegate.window.layer renderInContext:UIGraphicsGetCurrentContext() ];
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
