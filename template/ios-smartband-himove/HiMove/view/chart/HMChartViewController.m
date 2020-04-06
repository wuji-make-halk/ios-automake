//
//  HMChartViewController.m
//  CZJKBand
//
//  Created by 周凯伦 on 17/3/15.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "HMChartViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "SXRChart2View.h"
#import "IRKCommonData.h"
#import "StepHistory_Hour.h"
#import "AppDelegate.h"
#import "DataCenter.h"
#import "CommonDefine.h"
#import "Health_data_history+CoreDataClass.h"


@interface HMChartViewController ()<SXRChart2ViewDelegate>
@property (strong, nonatomic) UISegmentedControl *ActivitySeg;
@property (strong, nonatomic) UIScrollView* scrollview;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;

@property (strong, nonatomic) NSMutableArray* chartarray;//用于刷新图表
@property (assign, nonatomic) NSInteger currentSeg;//记录当前分段选择器的序号
@property (assign, nonatomic) NSInteger datacount;//数据个数,即横坐标的个数
@property (strong, nonatomic) NSDate* beginDate;//查询数据库时的起始时间

@property (assign, nonatomic) NSInteger maxSteps;//步数最大值

@property (assign, nonatomic) NSInteger totalHearts;//心率总值
@property (assign, nonatomic) NSInteger dbHeartDataCount;//心率数据量
@property (nonatomic, assign) NSInteger totalTemperature;//体温总值
@property (nonatomic, assign) NSInteger dbTemperature;//体温数据量
@property (nonatomic, assign) double totalRides;//骑行总值
@property (nonatomic, assign) NSInteger dbRideDataCount;//骑行数据量
@property (assign, nonatomic) NSInteger totalSteps;//步数总值
@property (assign, nonatomic) NSInteger dbDataCount;//步数数据量
@property (assign, nonatomic) double tSleepTime;//睡眠总值
@property (assign, nonatomic) NSInteger dbSleepDataCount;//睡眠数据量
@property (assign, nonatomic) double tDeepSleepTime;//深睡总值
@property (assign, nonatomic) NSInteger dbDeepSleepDataCount;//深睡数据量
@property (strong, nonatomic) NSDate* lastHeartDate;//最后一次心率测试时间
@property (strong, nonatomic) NSDate* lastTempDate;//最后一次温度测试时间
@property (assign, nonatomic) CGFloat lastHeart;//最后一次心率
@property (assign, nonatomic) CGFloat lastTemp;//最后一次温度


//数据数组
@property(nonatomic,strong) NSMutableArray *heartarray;
@property(nonatomic,strong) NSMutableArray *temperaturearray;
//@property(nonatomic,strong) NSMutableArray *ridearray;
@property(nonatomic,strong) NSMutableArray *steparray;
@property(nonatomic,strong) NSMutableArray *totalarray;//睡眠
@property(nonatomic,strong) NSMutableArray *deeparray;//睡眠


@property(nonatomic,strong) IRKCommonData *commondata;
@property(nonatomic,strong) DataCenter *datacenter;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end

@implementation HMChartViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = appdelegate.managedObjectContext;
    self.commondata=[IRKCommonData SharedInstance];
    self.datacenter = [DataCenter SharedInstance];
    
    
    self.steparray = [[NSMutableArray  alloc] init];
    self.heartarray = [[NSMutableArray alloc] init];
    self.temperaturearray = [[NSMutableArray  alloc] init];
    //self.ridearray = [[NSMutableArray  alloc] init];
    self.steparray = [[NSMutableArray  alloc] init];
    self.totalarray = [[NSMutableArray alloc]init];
    self.deeparray = [[NSMutableArray alloc]init];
    self.chartarray = [[NSMutableArray alloc] init];
    self.currentSeg = 0;
    self.datacount = 24;
    self.beginDate = [NSDate date];
    
    self.maxSteps = 0;
    [self initNav];
    [self initControl];
}

-(void)initNav{
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
    
    UIButton* btn_share = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    btn_share.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btn_share setImage:[UIImage imageNamed:@"shareBtn"] forState:UIControlStateNormal];
    [btn_share addTarget:self action:@selector(onClickShare:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_share];
    
}

-(void)initControl{
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    
    self.ActivitySeg = [[UISegmentedControl alloc] initWithFrame:CGRectMake(-2, 0, CGRectGetWidth(self.view.frame)+4, 40)];
    [self.ActivitySeg insertSegmentWithTitle:NSLocalizedString(@"Chart_Time_perday", nil) atIndex:0 animated:NO];
    [self.ActivitySeg insertSegmentWithTitle:NSLocalizedString(@"Chart_Time_perweek", nil) atIndex:1 animated:NO];
    [self.ActivitySeg insertSegmentWithTitle:NSLocalizedString(@"Chart_Time_permonth", nil) atIndex:2 animated:NO];
    [self.ActivitySeg insertSegmentWithTitle:NSLocalizedString(@"Chart_Time_peryear", nil) atIndex:3 animated:NO];
    [self.ActivitySeg setTintColor:[UIColor colorWithRed:0x55/255.0 green:0xa7/255.0 blue:0xe9/255.0 alpha:1]];
    [self.ActivitySeg addTarget:self action:@selector(onSegChange:) forControlEvents:UIControlEventValueChanged];
    [self.ActivitySeg setSelectedSegmentIndex:0];
    [self.ActivitySeg setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.ActivitySeg];
    
    int chartcount = 7;//图表个数
    CGFloat chartheight = 200;//图表高度
    CGFloat sep = 5;//图表上下左右间隔
    self.scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.ActivitySeg.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-65-49-CGRectGetHeight(self.ActivitySeg.frame))];
    self.scrollview.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), chartheight*chartcount+sep*(chartcount+2));
    for (int i = 0; i<chartcount; i++) {
        SXRChart2View* chartstep = [[SXRChart2View alloc] initWithFrame:CGRectMake(sep, sep*(i+1)+i*chartheight, CGRectGetWidth(self.view.frame)-sep*2, chartheight)];
        chartstep.tag = i+1;
        chartstep.delegate = self;
        chartstep.layer.cornerRadius = 5;
        chartstep.currentMode = 0;
        chartstep.beginDate = [NSDate date];
        if(i==0){
            chartstep.barType = BarTypeHeartLine;
//            chartstep.barType = BarTypeTwoPointBar;
        }
        else if(i==1)
            chartstep.barType = BarTypeHeartLine;
        else
            chartstep.barType = BarTypeLine;
        
        [self.scrollview addSubview:chartstep];
        [self.chartarray addObject:chartstep];
    }
    self.scrollview.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollview];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.activityIndicator.layer.cornerRadius = 10;
    self.activityIndicator.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    self.activityIndicator.color = [UIColor whiteColor];
    self.activityIndicator.center = CGPointMake(CGRectGetWidth(self.view.frame)/2.0, CGRectGetHeight(self.view.frame)/2.0);
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    [self.view addSubview:self.activityIndicator];
}

//分段选择器切换方法
-(void)onSegChange:(UISegmentedControl*)sender{
    self.currentSeg = sender.selectedSegmentIndex;
    switch (self.currentSeg) {
        case 0:{
            self.datacount = 24;
            self.beginDate = [NSDate date];
            SXRChart2View* chart = [self.scrollview viewWithTag:1];
            chart.barType = BarTypeHeartLine;
            chart = [self.scrollview viewWithTag:2];
            chart.barType = BarTypeHeartLine;
        } break;
        case 1:{
            self.datacount = 7;
            self.beginDate = [[NSDate date] dateByAddingTimeInterval:-6*24*60*60];
            SXRChart2View* chart = [self.scrollview viewWithTag:1];
            chart.barType = BarTypeTwoPointBar;
            chart = [self.scrollview viewWithTag:2];
            chart.barType = BarTypeTwoPointBar;
        } break;
        case 2:{
            self.datacount = 31;
            self.beginDate = [[NSDate date] dateByAddingTimeInterval:-30*24*60*60];
            SXRChart2View* chart = [self.scrollview viewWithTag:1];
            chart.barType = BarTypeTwoPointBar;
            chart = [self.scrollview viewWithTag:2];
            chart.barType = BarTypeTwoPointBar;
        } break;
        case 3:{
            self.datacount = 12;
            self.beginDate = [self lastYearDay:[NSDate date]];
            SXRChart2View* chart = [self.scrollview viewWithTag:1];
            chart.barType = BarTypeTwoPointBar;
            chart = [self.scrollview viewWithTag:2];
            chart.barType = BarTypeTwoPointBar;
        } break;
        default: break;
    }
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    self.ActivitySeg.enabled = NO;
    [self loadData];
}

#pragma mark --------Load Data Method
-(void)loadData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.heartarray removeAllObjects];
        [self.temperaturearray removeAllObjects];
        //[self.ridearray removeAllObjects];
        [self.steparray removeAllObjects];
        [self.totalarray removeAllObjects];
        [self.deeparray removeAllObjects];
        self.maxSteps = 0;
        
        self.totalHearts=0;
        self.dbHeartDataCount=0;
        self.totalTemperature=0;
        self.dbTemperature=0;
        self.totalRides=0;
        self.dbRideDataCount=0;
        self.totalSteps=0;
        self.dbDataCount=0;
        self.tSleepTime=0;
        self.dbSleepDataCount=0;
        self.tDeepSleepTime=0;
        self.dbDeepSleepDataCount=0;
        [self loadLastData];
        switch (self.currentSeg) {
            case 0:[self loadDayData]; break;
            case 1: [self loadWeekData]; break;
            case 2: [self loadMonthData]; break;
            case 3: [self loadYearData]; break;
            default: break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            self.ActivitySeg.enabled = YES;
            [self refresh];
        });
    });
}
-(void)loadLastData{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Health_data_history" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@ and uid = %@",[NSNumber numberWithInt:SENSOR_TYPE_SERVER_HEARTRATE], self.commondata.uid];
    [fetchRequest setPredicate:predicate];
    //按时间降序查询
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"adddate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSort]];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil && [fetchedObjects count] != 0){
        Health_data_history *obj = [fetchedObjects objectAtIndex:0];
        self.lastHeart = obj.value.floatValue;
        self.lastHeartDate = [obj.adddate copy];
    }else{
        self.lastHeart = 0;
        self.lastHeartDate = nil;
    }
    //取最后一条温度
    predicate = [NSPredicate predicateWithFormat:@"type = %@ and uid = %@",[NSNumber numberWithInt:SENSOR_TYPE_SERVER_TEMPERATURE], self.commondata.uid];
    [fetchRequest setPredicate:predicate];
    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil && [fetchedObjects count] != 0){
        Health_data_history *obj = [fetchedObjects objectAtIndex:0];
        self.lastTemp = obj.value.floatValue;
        self.lastTempDate = [obj.adddate copy];
    }else{
        self.lastTemp = 0;
        self.lastTempDate = nil;
    }
    

}

-(void)loadDayData{
    NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    NSString* macid = @"";
    if (bi) {
        if ([bi.allKeys containsObject:BONGINFO_KEY_BLEADDR]){
            macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
        }
    }
    for (int i=0; i<self.datacount; i++) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:[NSString stringWithFormat:@"yyyy-MM-dd %.2d:00:00",i]];
        NSString * datebeginstr = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * datebegin = [dateFormatter dateFromString:datebeginstr];
        NSDate * dateend = [datebegin dateByAddingTimeInterval:3599];
//        NSLog(@"datebegin = %@, dateend = %@",datebegin, dateend);
        {
            //读取步数统计
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode in {%@,%@}",datebegin,dateend,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_DAILY],[NSNumber numberWithInt:HJT_STEP_MODE_SPORT]];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
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
            
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                [self.steparray addObject:@0];
            }else{
                NSDictionary* fetchdict = [fetchedObjects firstObject];
                NSNumber* sumsteps = [fetchdict objectForKey:@"sumsteps"];
                if (sumsteps != nil) {
                    [self.steparray addObject:sumsteps];
                }else{
                    [self.steparray addObject:@0];
                }
                
                if (sumsteps.intValue > self.maxSteps) {
                    self.maxSteps = sumsteps.intValue;
                }
                self.totalSteps += sumsteps.intValue;
                if (sumsteps.intValue>0) {
                    self.dbDataCount += 1;
                }
            }
        }

        {
            //读取睡眠统计
            NSDate* sleepbegindate = [datebegin dateByAddingTimeInterval:-12*60*60];
            NSDate* sleependdate = [sleepbegindate dateByAddingTimeInterval:3599];
//            NSLog(@"sleepbegindate = %@, sleependdate = %@",sleepbegindate, sleependdate);
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode = %@ and steps<=%@",sleepbegindate,sleependdate,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_SLEEP],[NSNumber numberWithInt:HJT_SLEEP_MODE_AWAKE]];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime"ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            fetchRequest.returnsDistinctResults = YES;
            
            fetchRequest.resultType = NSDictionaryResultType;

            NSMutableArray* expresslist = [[NSMutableArray alloc] init];
            NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
            expression.name = @"count";
            NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"mode"];
            expression.expression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:keyPathExpression]];
            //        expression.expression = [NSExpression expressionWithFormat:@"count:"];
            expression.expressionResultType = NSInteger32AttributeType;
            [expresslist addObject:expression];
            
            fetchRequest.propertiesToFetch = expresslist;
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//            NSLog(@"%@",fetchedObjects);
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                //NSLog(@"No data");
                [self.totalarray addObject:@0];
            }else{
                NSDictionary* fechdict = [fetchedObjects firstObject];
                NSNumber* count = [fechdict objectForKey:@"count"];
                NSNumber *tTime = [NSNumber numberWithDouble:count.intValue*10*60];
                [self.totalarray addObject:tTime];
                self.tSleepTime += tTime.doubleValue;
                if (count.intValue>0) {
                    self.dbSleepDataCount += 1;
                }

            }
            
        }
        {
            //读取深睡统计
            NSDate* sleepbegindate = [datebegin dateByAddingTimeInterval:-12*60*60];
            NSDate* sleependdate = [sleepbegindate dateByAddingTimeInterval:3599];
            //            NSLog(@"sleepbegindate = %@, sleependdate = %@",sleepbegindate, sleependdate);
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode = %@ and steps<=%@",sleepbegindate,sleependdate,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_SLEEP],[NSNumber numberWithInt:HJT_SLEEP_MODE_LIGHT]];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime"ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            fetchRequest.returnsDistinctResults = YES;
            
            fetchRequest.resultType = NSDictionaryResultType;
            
            NSMutableArray* expresslist = [[NSMutableArray alloc] init];
            NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
            expression.name = @"count";
            NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"mode"];
            expression.expression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:keyPathExpression]];
            //        expression.expression = [NSExpression expressionWithFormat:@"count:"];
            expression.expressionResultType = NSInteger32AttributeType;
            [expresslist addObject:expression];
            
            fetchRequest.propertiesToFetch = expresslist;
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            //            NSLog(@"%@",fetchedObjects);
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                //NSLog(@"No data");
                [self.deeparray addObject:@0];
            }else{
                NSDictionary* fechdict = [fetchedObjects firstObject];
                NSNumber* count = [fechdict objectForKey:@"count"];
                NSNumber *tTime = [NSNumber numberWithDouble:count.intValue*10*60];
                [self.deeparray addObject:tTime];
                self.tDeepSleepTime += tTime.doubleValue;
                if (count.intValue>0) {
                    self.dbDeepSleepDataCount += 1;
                }
                
            }
            
        }
//        {
//            //读取体温数据
//            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Health_data_history" inManagedObjectContext:self.managedObjectContext];
//            [fetchRequest setEntity:entity];
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adddate between {%@,%@} and memberid = %@",datebegin,dateend,self.commondata.memberid];
//            [fetchRequest setPredicate:predicate];
//            NSError *error = nil;
//            
//            fetchRequest.resultType = NSDictionaryResultType;
//            fetchRequest.propertiesToGroupBy = [NSArray arrayWithObject:@"type"];
//            
//            NSMutableArray* expresslist = [[NSMutableArray alloc] init];
//            
//            [expresslist addObject:@"type"];
//            
//            NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
//            expression.name = @"maxvalue";
//            NSExpression *keyExpression = [NSExpression expressionForKeyPath:@"value"];
//            NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyExpression]];
//            expression.expression = maxExpression;
//            expression.expressionResultType = NSFloatAttributeType;
//            [expresslist addObject:expression];
//
//            NSExpressionDescription* expression1 = [[NSExpressionDescription alloc] init];
//            expression1.name = @"minvalue";
//            NSExpression *minExpression = [NSExpression expressionForFunction:@"min:" arguments:[NSArray arrayWithObject:keyExpression]];
//            expression1.expression = minExpression;
//            expression1.expressionResultType = NSFloatAttributeType;
//            [expresslist addObject:expression1];
//
//            fetchRequest.propertiesToFetch = expresslist;
//            
//            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
////            NSLog(@"%@",fetchedObjects);
//            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
//                [self.heartarray addObject:@{@"max":@0,@"min":@0}];
//                [self.temperaturearray addObject:@{@"max":@0,@"min":@0}];
//            }else{
//                __block BOOL findheart = NO;
//                __block BOOL findtemp = NO;
//                [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    NSDictionary* dictobj = (NSDictionary*)obj;
//                    NSNumber* type = [dictobj objectForKey:@"type"];
//                    NSNumber* max = [dictobj objectForKey:@"maxvalue"];
//                    if (max == nil) {
//                        max = @0;
//                    }
//                    NSNumber* min = [dictobj objectForKey:@"minvalue"];
//                    if (min == nil) {
//                        min = @0;
//                    }
//                    if (type.intValue == SENSOR_TYPE_SERVER_HEARTRATE) {
//                        findheart = YES;
//                        [self.heartarray addObject:@{@"max":max,@"min":min}];
//                    }else if (type.intValue == SENSOR_TYPE_SERVER_TEMPERATURE){
//                        findtemp = YES;
//                        [self.temperaturearray addObject:@{@"max":max,@"min":min}];
//                    }
//                }];
//                if (findheart == NO) {
//                    [self.heartarray addObject:@{@"max":@0,@"min":@0}];
//                }
//                if (findtemp == NO) {
//                    [self.temperaturearray addObject:@{@"max":@0,@"min":@0}];
//                }
//            }
//        }



    }
    //单独读取心率数据
    {
        //读取体温数据
        [self.heartarray removeAllObjects];
        [self.temperaturearray removeAllObjects];
        for (int i=0; i<1440; i++) {
            [self.heartarray addObject:@0];
//            [self.heartarray addObject:[NSNumber numberWithInt:arc4random()%100+40]];
//            [self.temperaturearray addObject:[NSNumber numberWithInt:arc4random()%10+30]];
            [self.temperaturearray addObject:@0];
        }

        NSCalendar* calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
        NSDateComponents* comp = [[NSDateComponents alloc] init];
        comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate date]];
        comp.hour = 0;
        comp.minute = 0;
        comp.second = 0;
        __block NSDate * datebegin = [calendar dateFromComponents:comp];
        comp.hour = 23;
        comp.minute = 59;
        comp.second = 59;
        NSDate * dateend = [calendar dateFromComponents:comp];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Health_data_history" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adddate between {%@,%@} and memberid = %@",datebegin,dateend,self.commondata.memberid];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        
//        fetchRequest.resultType = NSDictionaryResultType;
//        fetchRequest.propertiesToGroupBy = [NSArray arrayWithObject:@"type"];
//        
//        NSMutableArray* expresslist = [[NSMutableArray alloc] init];
//        
//        [expresslist addObject:@"type"];
//        
//        NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
//        expression.name = @"maxvalue";
//        NSExpression *keyExpression = [NSExpression expressionForKeyPath:@"value"];
//        NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyExpression]];
//        expression.expression = maxExpression;
//        expression.expressionResultType = NSFloatAttributeType;
//        [expresslist addObject:expression];
//        
//        NSExpressionDescription* expression1 = [[NSExpressionDescription alloc] init];
//        expression1.name = @"minvalue";
//        NSExpression *minExpression = [NSExpression expressionForFunction:@"min:" arguments:[NSArray arrayWithObject:keyExpression]];
//        expression1.expression = minExpression;
//        expression1.expressionResultType = NSFloatAttributeType;
//        [expresslist addObject:expression1];
//        
//        fetchRequest.propertiesToFetch = expresslist;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"adddate" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        //            NSLog(@"%@",fetchedObjects);
        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
            NSLog(@"no record");
        }else{
            [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                Health_data_history* record = (Health_data_history*)obj;
                NSTimeInterval t = [record.adddate timeIntervalSinceDate:datebegin];
                int index = t/60;
                if(index > 1440 || index < 0){
                    NSLog(@"index error");
                }else{
                    if (record.type.intValue == SENSOR_TYPE_SERVER_HEARTRATE) {
                        [self.heartarray replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:record.value.intValue]];
                    }else if (record.type.intValue == SENSOR_TYPE_SERVER_TEMPERATURE){
                        [self.temperaturearray replaceObjectAtIndex:index withObject:[NSNumber numberWithFloat:record.value.floatValue]];
                    }
                }
             }];
        }
    }

    
}

-(void)loadWeekData{
    NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    NSString* macid = @"";
    if (bi) {
        if ([bi.allKeys containsObject:BONGINFO_KEY_BLEADDR]){
            macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
        }
    }
    for (int i=0; i<self.datacount; i++) {
        NSDate* currentdate = [self.beginDate dateByAddingTimeInterval:i*24*60*60];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
        NSString * datebeginstr = [dateFormatter stringFromDate:currentdate];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd 23:59:59"];
//        NSString * dateendstr = [dateFormatter stringFromDate:currentdate];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * datebegin = [dateFormatter dateFromString:datebeginstr];
        NSDate * dateend = [datebegin dateByAddingTimeInterval:86399];
        //        NSLog(@"datebegin = %@, dateend = %@",datebegin, dateend);
        {
            //读取步数统计
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode in {%@,%@}",datebegin,dateend,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_DAILY],[NSNumber numberWithInt:HJT_STEP_MODE_SPORT]];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
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
            
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                [self.steparray addObject:@0];
            }else{
                NSDictionary* fetchdict = [fetchedObjects firstObject];
                NSNumber* sumsteps = [fetchdict objectForKey:@"sumsteps"];
                [self.steparray addObject:sumsteps];
                if (sumsteps.intValue > self.maxSteps) {
                    self.maxSteps = sumsteps.intValue;
                }
                self.totalSteps += sumsteps.intValue;
                if (sumsteps.intValue>0) {
                    self.dbDataCount += 1;
                }
            }
        }
        
        {
            //读取睡眠统计
//            NSDate* sleepbegindate = [datebegin dateByAddingTimeInterval:-12*60*60];
//            NSDate* sleependdate = [sleepbegindate dateByAddingTimeInterval:3599];
            //            NSLog(@"sleepbegindate = %@, sleependdate = %@",sleepbegindate, sleependdate);
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode = %@ and steps <= %@",datebegin,dateend,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_SLEEP],[NSNumber numberWithInt:HJT_SLEEP_MODE_AWAKE]];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime"ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            fetchRequest.returnsDistinctResults = YES;
            
            fetchRequest.resultType = NSDictionaryResultType;
            
            NSMutableArray* expresslist = [[NSMutableArray alloc] init];
            NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
            expression.name = @"count";
            NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"mode"];
            expression.expression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:keyPathExpression]];
            //        expression.expression = [NSExpression expressionWithFormat:@"count:"];
            expression.expressionResultType = NSInteger32AttributeType;
            [expresslist addObject:expression];
            
            fetchRequest.propertiesToFetch = expresslist;
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            //            NSLog(@"%@",fetchedObjects);
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                //NSLog(@"No data");
                [self.totalarray addObject:@0];
            }else{
                NSDictionary* fechdict = [fetchedObjects firstObject];
                NSNumber* count = [fechdict objectForKey:@"count"];
                NSNumber *tTime = [NSNumber numberWithDouble:count.intValue*10*60];
                [self.totalarray addObject:tTime];
                self.tSleepTime += tTime.doubleValue;
                if (count.intValue>0) {
                    self.dbSleepDataCount += 1;
                }
                
            }
            
        }
        {
            //读取深睡统计
//            NSDate* sleepbegindate = [datebegin dateByAddingTimeInterval:-12*60*60];
//            NSDate* sleependdate = [sleepbegindate dateByAddingTimeInterval:3599];
            //            NSLog(@"sleepbegindate = %@, sleependdate = %@",sleepbegindate, sleependdate);
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode = %@ and steps<=%@",datebegin,dateend,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_SLEEP],[NSNumber numberWithInt:HJT_SLEEP_MODE_LIGHT]];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime"ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            fetchRequest.returnsDistinctResults = YES;
            
            fetchRequest.resultType = NSDictionaryResultType;
            
            NSMutableArray* expresslist = [[NSMutableArray alloc] init];
            NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
            expression.name = @"count";
            NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"mode"];
            expression.expression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:keyPathExpression]];
            //        expression.expression = [NSExpression expressionWithFormat:@"count:"];
            expression.expressionResultType = NSInteger32AttributeType;
            [expresslist addObject:expression];
            
            fetchRequest.propertiesToFetch = expresslist;
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            //            NSLog(@"%@",fetchedObjects);
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                //NSLog(@"No data");
                [self.deeparray addObject:@0];
            }else{
                NSDictionary* fechdict = [fetchedObjects firstObject];
                NSNumber* count = [fechdict objectForKey:@"count"];
                NSNumber *tTime = [NSNumber numberWithDouble:count.intValue*10*60];
                [self.deeparray addObject:tTime];
                self.tDeepSleepTime += tTime.doubleValue;
                if (count.intValue>0) {
                    self.dbDeepSleepDataCount += 1;
                }
                
            }
            
        }
        {
            //读取心率 体温数据
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Health_data_history" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adddate between {%@,%@} and memberid = %@",datebegin,dateend,self.commondata.memberid];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
            fetchRequest.resultType = NSDictionaryResultType;
            fetchRequest.propertiesToGroupBy = [NSArray arrayWithObject:@"type"];
            
            NSMutableArray* expresslist = [[NSMutableArray alloc] init];
            
            [expresslist addObject:@"type"];
            
            NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
            expression.name = @"maxvalue";
            NSExpression *keyExpression = [NSExpression expressionForKeyPath:@"value"];
            NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyExpression]];
            expression.expression = maxExpression;
            expression.expressionResultType = NSFloatAttributeType;
            [expresslist addObject:expression];
            
            NSExpressionDescription* expression1 = [[NSExpressionDescription alloc] init];
            expression1.name = @"minvalue";
            NSExpression *minExpression = [NSExpression expressionForFunction:@"min:" arguments:[NSArray arrayWithObject:keyExpression]];
            expression1.expression = minExpression;
            expression1.expressionResultType = NSFloatAttributeType;
            [expresslist addObject:expression1];
            
            fetchRequest.propertiesToFetch = expresslist;
            
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            //            NSLog(@"%@",fetchedObjects);
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                [self.heartarray addObject:@{@"max":@0,@"min":@0}];
                [self.temperaturearray addObject:@{@"max":@0,@"min":@0}];
            }else{
                __block BOOL findheart = NO;
                __block BOOL findtemp = NO;
                [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDictionary* dictobj = (NSDictionary*)obj;
                    NSNumber* type = [dictobj objectForKey:@"type"];
                    NSNumber* max = [dictobj objectForKey:@"maxvalue"];
                    NSNumber* min = [dictobj objectForKey:@"minvalue"];
                    if (type.intValue == SENSOR_TYPE_SERVER_HEARTRATE) {
                        findheart = YES;
                        [self.heartarray addObject:@{@"max":max,@"min":min}];
                    }else if (type.intValue == SENSOR_TYPE_SERVER_TEMPERATURE){
                        findtemp = YES;
                        [self.temperaturearray addObject:@{@"max":max,@"min":min}];
                    }
                }];
                if (findheart == NO) {
                    [self.heartarray addObject:@{@"max":@0,@"min":@0}];
                }
                if (findtemp == NO) {
                    [self.temperaturearray addObject:@{@"max":@0,@"min":@0}];
                }
            }
        }

    }
}

-(void)loadMonthData{
    NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    NSString* macid = @"";
    if (bi) {
        if ([bi.allKeys containsObject:BONGINFO_KEY_BLEADDR]){
            macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
        }
    }
    for (int i=0; i<self.datacount; i++) {
        NSDate* currentdate = [self.beginDate dateByAddingTimeInterval:i*24*60*60];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
        NSString * datebeginstr = [dateFormatter stringFromDate:currentdate];
        //        [dateFormatter setDateFormat:@"yyyy-MM-dd 23:59:59"];
        //        NSString * dateendstr = [dateFormatter stringFromDate:currentdate];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * datebegin = [dateFormatter dateFromString:datebeginstr];
        NSDate * dateend = [datebegin dateByAddingTimeInterval:86399];
        //        NSLog(@"datebegin = %@, dateend = %@",datebegin, dateend);
        {
            //读取步数统计
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode in {%@,%@}",datebegin,dateend,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_DAILY],[NSNumber numberWithInt:HJT_STEP_MODE_SPORT]];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
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
            
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                [self.steparray addObject:@0];
            }else{
                NSDictionary* fetchdict = [fetchedObjects firstObject];
                NSNumber* sumsteps = [fetchdict objectForKey:@"sumsteps"];
                [self.steparray addObject:sumsteps];
                if (sumsteps.intValue > self.maxSteps) {
                    self.maxSteps = sumsteps.intValue;
                }
                self.totalSteps += sumsteps.intValue;
                if (sumsteps.intValue>0) {
                    self.dbDataCount += 1;
                }
            }
        }
        
        {
            //读取睡眠统计
//            NSDate* sleepbegindate = [datebegin dateByAddingTimeInterval:-12*60*60];
//            NSDate* sleependdate = [sleepbegindate dateByAddingTimeInterval:3599];
            //            NSLog(@"sleepbegindate = %@, sleependdate = %@",sleepbegindate, sleependdate);
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode = %@ and steps <= %@",datebegin,dateend,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_SLEEP],[NSNumber numberWithInt:HJT_SLEEP_MODE_AWAKE]];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime"ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            fetchRequest.returnsDistinctResults = YES;
            
            fetchRequest.resultType = NSDictionaryResultType;
            
            NSMutableArray* expresslist = [[NSMutableArray alloc] init];
            NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
            expression.name = @"count";
            NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"mode"];
            expression.expression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:keyPathExpression]];
            //        expression.expression = [NSExpression expressionWithFormat:@"count:"];
            expression.expressionResultType = NSInteger32AttributeType;
            [expresslist addObject:expression];
            
            fetchRequest.propertiesToFetch = expresslist;
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            //            NSLog(@"%@",fetchedObjects);
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                //NSLog(@"No data");
                [self.totalarray addObject:@0];
            }else{
                NSDictionary* fechdict = [fetchedObjects firstObject];
                NSNumber* count = [fechdict objectForKey:@"count"];
                NSNumber *tTime = [NSNumber numberWithDouble:count.intValue*10*60];
                [self.totalarray addObject:tTime];
                self.tSleepTime += tTime.doubleValue;
                if (count.intValue>0) {
                    self.dbSleepDataCount += 1;
                }
                
            }
            
        }
        {
            //读取深睡统计
//            NSDate* sleepbegindate = [datebegin dateByAddingTimeInterval:-12*60*60];
//            NSDate* sleependdate = [sleepbegindate dateByAddingTimeInterval:3599];
            //            NSLog(@"sleepbegindate = %@, sleependdate = %@",sleepbegindate, sleependdate);
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode = %@ and steps<=%@",datebegin,dateend,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_SLEEP],[NSNumber numberWithInt:HJT_SLEEP_MODE_LIGHT]];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime"ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            fetchRequest.returnsDistinctResults = YES;
            
            fetchRequest.resultType = NSDictionaryResultType;
            
            NSMutableArray* expresslist = [[NSMutableArray alloc] init];
            NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
            expression.name = @"count";
            NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"mode"];
            expression.expression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:keyPathExpression]];
            //        expression.expression = [NSExpression expressionWithFormat:@"count:"];
            expression.expressionResultType = NSInteger32AttributeType;
            [expresslist addObject:expression];
            
            fetchRequest.propertiesToFetch = expresslist;
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            //            NSLog(@"%@",fetchedObjects);
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                //NSLog(@"No data");
                [self.deeparray addObject:@0];
            }else{
                NSDictionary* fechdict = [fetchedObjects firstObject];
                NSNumber* count = [fechdict objectForKey:@"count"];
                NSNumber *tTime = [NSNumber numberWithDouble:count.intValue*10*60];
                [self.deeparray addObject:tTime];
                self.tDeepSleepTime += tTime.doubleValue;
                if (count.intValue>0) {
                    self.dbDeepSleepDataCount += 1;
                }
                
            }
            
        }
        {
            //读取心率 体温数据
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Health_data_history" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adddate between {%@,%@} and memberid = %@",datebegin,dateend,self.commondata.memberid];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
            fetchRequest.resultType = NSDictionaryResultType;
            fetchRequest.propertiesToGroupBy = [NSArray arrayWithObject:@"type"];
            
            NSMutableArray* expresslist = [[NSMutableArray alloc] init];
            
            [expresslist addObject:@"type"];
            
            NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
            expression.name = @"maxvalue";
            NSExpression *keyExpression = [NSExpression expressionForKeyPath:@"value"];
            NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyExpression]];
            expression.expression = maxExpression;
            expression.expressionResultType = NSFloatAttributeType;
            [expresslist addObject:expression];
            
            NSExpressionDescription* expression1 = [[NSExpressionDescription alloc] init];
            expression1.name = @"minvalue";
            NSExpression *minExpression = [NSExpression expressionForFunction:@"min:" arguments:[NSArray arrayWithObject:keyExpression]];
            expression1.expression = minExpression;
            expression1.expressionResultType = NSFloatAttributeType;
            [expresslist addObject:expression1];
            
            fetchRequest.propertiesToFetch = expresslist;
            
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            //            NSLog(@"%@",fetchedObjects);
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                [self.heartarray addObject:@{@"max":@0,@"min":@0}];
                [self.temperaturearray addObject:@{@"max":@0,@"min":@0}];
            }else{
                __block BOOL findheart = NO;
                __block BOOL findtemp = NO;
                [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDictionary* dictobj = (NSDictionary*)obj;
                    NSNumber* type = [dictobj objectForKey:@"type"];
                    NSNumber* max = [dictobj objectForKey:@"maxvalue"];
                    NSNumber* min = [dictobj objectForKey:@"minvalue"];
                    if (type.intValue == SENSOR_TYPE_SERVER_HEARTRATE) {
                        findheart = YES;
                        [self.heartarray addObject:@{@"max":max,@"min":min}];
                    }else if (type.intValue == SENSOR_TYPE_SERVER_TEMPERATURE){
                        findtemp = YES;
                        [self.temperaturearray addObject:@{@"max":max,@"min":min}];
                    }
                }];
                if (findheart == NO) {
                    [self.heartarray addObject:@{@"max":@0,@"min":@0}];
                }
                if (findtemp == NO) {
                    [self.temperaturearray addObject:@{@"max":@0,@"min":@0}];
                }
            }
        }

    }
//    for (int i = 0; i<self.datacount; i++) {
//        NSDate* date = [self.beginDate dateByAddingTimeInterval:i*24*60*60];
//        NSString* key = [self.datacenter getDayKeyfromDate:date];
//        if ([[self.datacenter.Daydict allKeys] containsObject:key]) {
//            NSDictionary* daydict = [self.datacenter.Daydict objectForKey:key];
//            if ([[daydict allKeys] containsObject:@"steps"]) {
//                NSNumber* steps = [daydict objectForKey:@"steps"];
//                self.totalSteps += steps.integerValue;
//                self.dbDataCount+= 1;
//                [self.steparray addObject:[NSNumber numberWithInteger:steps.integerValue]];
//            }else{
//                [self.steparray addObject:@0];
//            }
//            double total = 0;
//            if ([[daydict allKeys] containsObject:@"deep"]) {
//                NSNumber* number = [daydict objectForKey:@"deep"];
//                total+=number.doubleValue;
//            }
//            if ([[daydict allKeys] containsObject:@"light"]) {
//                NSNumber* number = [daydict objectForKey:@"light"];
//                total+=number.doubleValue;
//            }
//            if ([[daydict allKeys] containsObject:@"exlight"]) {
//                NSNumber* number = [daydict objectForKey:@"exlight"];
//                total+=number.doubleValue;
//            }
//            if (total>0) {
//                self.tSleepTime += total;
//                self.dbSleepDataCount += 1;
//                [self.totalarray addObject:[NSNumber numberWithDouble:total]];
//            }else{
//                [self.totalarray addObject:@0];
//            }
//        }else{
//            [self.steparray addObject:@0];
//            [self.totalarray addObject:@0];
//        }
//    }
}

-(void)loadYearData{
    NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    NSString* macid = @"";
    if (bi) {
        if ([bi.allKeys containsObject:BONGINFO_KEY_BLEADDR]){
            macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
        }
    }
    for (int i=0; i<self.datacount; i++) {
        NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents* comp = [[NSDateComponents alloc] init];
        comp = [calendar components:NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:self.beginDate];
        comp.month+= i+1;
        comp.day = 1;
        comp.hour= 0;
        comp.minute = 0;
        comp.second = 0;
        NSDate* datebegin = [calendar dateFromComponents:comp];

        NSDateComponents* comp1 = [[NSDateComponents alloc] init];
        comp1 = [calendar components:NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:self.beginDate];
        comp1.month+= (i+2);
        comp1.day = 1;
        comp1.hour= 0;
        comp1.minute = 0;
        comp1.second = 0;
        NSDate* nextmonthdate = [calendar dateFromComponents:comp1];
        NSDate* dateend = [nextmonthdate dateByAddingTimeInterval:-1];

        NSLog(@"%@-%@",datebegin,dateend);
        {
            //读取步数统计
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode in {%@,%@}",datebegin,dateend,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_DAILY],[NSNumber numberWithInt:HJT_STEP_MODE_SPORT]];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
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
            
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                [self.steparray addObject:@0];
            }else{
                NSDictionary* fetchdict = [fetchedObjects firstObject];
                NSNumber* sumsteps = [fetchdict objectForKey:@"sumsteps"];
                [self.steparray addObject:sumsteps];
                if (sumsteps.intValue > self.maxSteps) {
                    self.maxSteps = sumsteps.intValue;
                }
                self.totalSteps += sumsteps.intValue;
                if (sumsteps.intValue>0) {
                    self.dbDataCount += 1;
                }
            }
        }
        
        {
            //读取睡眠统计
//            NSDate* sleepbegindate = [datebegin dateByAddingTimeInterval:-12*60*60];
//            NSDate* sleependdate = [sleepbegindate dateByAddingTimeInterval:3599];
            //            NSLog(@"sleepbegindate = %@, sleependdate = %@",sleepbegindate, sleependdate);
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode = %@ and steps <=%@",datebegin,dateend,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_SLEEP],[NSNumber numberWithInt:HJT_SLEEP_MODE_AWAKE]];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime"ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            fetchRequest.returnsDistinctResults = YES;
            
            fetchRequest.resultType = NSDictionaryResultType;
            
            NSMutableArray* expresslist = [[NSMutableArray alloc] init];
            NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
            expression.name = @"count";
            NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"mode"];
            expression.expression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:keyPathExpression]];
            //        expression.expression = [NSExpression expressionWithFormat:@"count:"];
            expression.expressionResultType = NSInteger32AttributeType;
            [expresslist addObject:expression];
            
            fetchRequest.propertiesToFetch = expresslist;
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            //            NSLog(@"%@",fetchedObjects);
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                //NSLog(@"No data");
                [self.totalarray addObject:@0];
            }else{
                NSDictionary* fechdict = [fetchedObjects firstObject];
                NSNumber* count = [fechdict objectForKey:@"count"];
                NSNumber *tTime = [NSNumber numberWithDouble:count.intValue*10*60];
                [self.totalarray addObject:tTime];
                self.tSleepTime += tTime.doubleValue;
                if (count.intValue>0) {
                    self.dbSleepDataCount += 1;
                }
                
            }
            
        }
        {
            //读取深睡统计
//            NSDate* sleepbegindate = [datebegin dateByAddingTimeInterval:-12*60*60];
//            NSDate* sleependdate = [sleepbegindate dateByAddingTimeInterval:3599];
            //            NSLog(@"sleepbegindate = %@, sleependdate = %@",sleepbegindate, sleependdate);
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@ and macid =%@ and mode = %@ and steps<=%@",datebegin,dateend,self.commondata.uid, macid, [NSNumber numberWithInt:HJT_STEP_MODE_SLEEP],[NSNumber numberWithInt:HJT_SLEEP_MODE_LIGHT]];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime"ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            fetchRequest.returnsDistinctResults = YES;
            
            fetchRequest.resultType = NSDictionaryResultType;
            
            NSMutableArray* expresslist = [[NSMutableArray alloc] init];
            NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
            expression.name = @"count";
            NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"mode"];
            expression.expression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:keyPathExpression]];
            //        expression.expression = [NSExpression expressionWithFormat:@"count:"];
            expression.expressionResultType = NSInteger32AttributeType;
            [expresslist addObject:expression];
            
            fetchRequest.propertiesToFetch = expresslist;
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            //            NSLog(@"%@",fetchedObjects);
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                //NSLog(@"No data");
                [self.deeparray addObject:@0];
            }else{
                NSDictionary* fechdict = [fetchedObjects firstObject];
                NSNumber* count = [fechdict objectForKey:@"count"];
                NSNumber *tTime = [NSNumber numberWithDouble:count.intValue*10*60];
                [self.deeparray addObject:tTime];
                self.tDeepSleepTime += tTime.doubleValue;
                if (count.intValue>0) {
                    self.dbDeepSleepDataCount += 1;
                }
                
            }
            
        }
        {
            //读取心率 体温数据
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Health_data_history" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adddate between {%@,%@} and memberid = %@",datebegin,dateend,self.commondata.memberid];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            
            fetchRequest.resultType = NSDictionaryResultType;
            fetchRequest.propertiesToGroupBy = [NSArray arrayWithObject:@"type"];
            
            NSMutableArray* expresslist = [[NSMutableArray alloc] init];
            
            [expresslist addObject:@"type"];
            
            NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
            expression.name = @"maxvalue";
            NSExpression *keyExpression = [NSExpression expressionForKeyPath:@"value"];
            NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyExpression]];
            expression.expression = maxExpression;
            expression.expressionResultType = NSFloatAttributeType;
            [expresslist addObject:expression];
            
            NSExpressionDescription* expression1 = [[NSExpressionDescription alloc] init];
            expression1.name = @"minvalue";
            NSExpression *minExpression = [NSExpression expressionForFunction:@"min:" arguments:[NSArray arrayWithObject:keyExpression]];
            expression1.expression = minExpression;
            expression1.expressionResultType = NSFloatAttributeType;
            [expresslist addObject:expression1];
            
            fetchRequest.propertiesToFetch = expresslist;
            
            NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            //            NSLog(@"%@",fetchedObjects);
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                [self.heartarray addObject:@{@"max":@0,@"min":@0}];
                [self.temperaturearray addObject:@{@"max":@0,@"min":@0}];
            }else{
                __block BOOL findheart = NO;
                __block BOOL findtemp = NO;
                [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDictionary* dictobj = (NSDictionary*)obj;
                    NSNumber* type = [dictobj objectForKey:@"type"];
                    NSNumber* max = [dictobj objectForKey:@"maxvalue"];
                    NSNumber* min = [dictobj objectForKey:@"minvalue"];
                    if (type.intValue == SENSOR_TYPE_SERVER_HEARTRATE) {
                        findheart = YES;
                        [self.heartarray addObject:@{@"max":max,@"min":min}];
                    }else if (type.intValue == SENSOR_TYPE_SERVER_TEMPERATURE){
                        findtemp = YES;
                        [self.temperaturearray addObject:@{@"max":max,@"min":min}];
                    }
                }];
                if (findheart == NO) {
                    [self.heartarray addObject:@{@"max":@0,@"min":@0}];
                }
                if (findtemp == NO) {
                    [self.temperaturearray addObject:@{@"max":@0,@"min":@0}];
                }
            }
        }

    }
//    for (int i = 1; i<=self.datacount; i++) {
//        NSCalendar* calendar =[[NSCalendar alloc ] initWithCalendarIdentifier:NSGregorianCalendar];
//        NSDateComponents* comp = [[NSDateComponents alloc] init];
//        comp = [calendar components:NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self.beginDate];
//        comp.month+= i;
//        comp.day = 1;
//        NSDate* date = [calendar dateFromComponents:comp];
//        NSString* key = [self.datacenter getMonthKeyfromDate:date];
//        //NSLog(@"loadYearData key = %@",key);
//        if ([[self.datacenter.Monthdict allKeys] containsObject:key]) {
//            NSDictionary* daydict = [self.datacenter.Monthdict objectForKey:key];
//            if ([[daydict allKeys] containsObject:@"steps"]) {
//                NSNumber* steps = [daydict objectForKey:@"steps"];
//                self.totalSteps += steps.integerValue;
//                self.dbDataCount+= 1;
//                [self.steparray addObject:[NSNumber numberWithInteger:steps.integerValue]];
//            }else{
//                [self.steparray addObject:@0];
//            }
//            double total = 0;
//            if ([[daydict allKeys] containsObject:@"deep"]) {
//                NSNumber* number = [daydict objectForKey:@"deep"];
//                total+=number.doubleValue;
//            }
//            if ([[daydict allKeys] containsObject:@"light"]) {
//                NSNumber* number = [daydict objectForKey:@"light"];
//                total+=number.doubleValue;
//            }
//            if ([[daydict allKeys] containsObject:@"exlight"]) {
//                NSNumber* number = [daydict objectForKey:@"exlight"];
//                total+=number.doubleValue;
//            }
//            if (total>0) {
//                self.tSleepTime += total;
//                self.dbSleepDataCount += 1;
//                [self.totalarray addObject:[NSNumber numberWithDouble:total]];
//            }else{
//                [self.totalarray addObject:@0];
//            }
////            if ([[daydict allKeys] containsObject:@"sleepday"]) {
//            //准确天数
////                NSNumber* number = [daydict objectForKey:@"sleepday"];
////                self.dbSleepDataCount += number.integerValue;
////            }
//        }else{
//            [self.steparray addObject:@0];
//            [self.totalarray addObject:@0];
//        }
//    }
}
#pragma mark --------SXRChart2ViewDelegate Method--------
-(NSDate*)SXRChart2ViewBeginDate:(SXRChart2View*)view{
    switch (view.tag) {
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:{
            if (self.currentSeg == 0) {
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                //    timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
                //设定时间格式,这里可以设置成自己需要的格式
                [dateFormatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
                NSString* datebeginstr = [dateFormatter stringFromDate:[NSDate date]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate* datebegin = [dateFormatter dateFromString:datebeginstr];
                return datebegin;
            }else{
                return self.beginDate;
            }
        } break;
        case 6:
        case 7:{
            if (self.currentSeg == 0) {
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                //    timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
                //设定时间格式,这里可以设置成自己需要的格式
                [dateFormatter setDateFormat:@"yyyy-MM-dd 12:00:00"];
                NSString* datebeginstr = [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:-24*60*60]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate* datebegin = [dateFormatter dateFromString:datebeginstr];
                //NSLog(@"datebegin = %@",datebegin);
                return datebegin;
            }else{
                return self.beginDate;
            }
        } break;
        default: break;
    }
    return self.beginDate;
}
//数据列表
-(NSArray*)SXRChart2ViewDataValueArray:(SXRChart2View*)view{
    NSMutableArray* arr = [[NSMutableArray alloc] init];
//    for (int i=0; i<self.datacount; i++) {
        switch (view.tag) {
            case 1:return [self.heartarray mutableCopy]; break;//心率
            case 2:return [self.temperaturearray mutableCopy]; break;//体温
            //case 3:return [self.ridearray mutableCopy]; break;//骑行
            case 3:return [self.steparray mutableCopy]; break;//步数
            case 4:{//卡路里
                __block NSMutableArray* dictarray = [[NSMutableArray alloc] init];
                for (int i=0; i<self.steparray.count; i++) {
                    [dictarray addObject:[NSNumber numberWithFloat:[self.commondata getCal:[[self.steparray objectAtIndex:i] integerValue]]]];
                }
                return dictarray;
            } break;
            case 5:{//距离
                __block NSMutableArray* dictarray = [[NSMutableArray alloc] init];
                for (int i=0; i<self.steparray.count; i++) {
                    [dictarray addObject:[NSNumber numberWithFloat:[self.commondata getDistance:[[self.steparray objectAtIndex:i] integerValue]]]];
                }
                return dictarray;
            } break;
            case 6:return [self.totalarray mutableCopy]; break;//睡眠
            case 7:return [self.deeparray mutableCopy]; break;//深睡
            default: break;
        }
//    }
    return arr;
}

//y轴坐标最大值，用于计算
-(CGFloat)SXRChart2ViewYLabelMaxValue:(SXRChart2View*)view{
    switch (view.tag) {
        case 1:return 220; break;//心率
        case 2:return 50; break;//体温
//        case 3:{//骑行
//            switch (self.currentSeg){
//                case 0:return 1000; break;
//                case 1:
//                case 2:return 10000; break;
//                case 3:return 300000; break;
//                default: break;
//            }
//        } break;
        case 3:{//步数
            switch (self.currentSeg){
                case 0:return ((self.maxSteps/1000)+1)*1000; break;
                case 1:
                case 2:return self.commondata.target_steps; break;
                case 3:return self.commondata.target_steps*30; break;
                default: break;
            }
        }break;
        case 4:{//卡路里
            switch (self.currentSeg){
                case 0:return ceil([self.commondata getCal:((self.maxSteps/1000)+1)*1000]); break;
                case 1:
                case 2:return self.commondata.target_calorie; break;
                case 3:return self.commondata.target_calorie*30; break;
                default: break;
            }
        } break;
        case 5:{//距离
            switch (self.currentSeg) {
                case 0:return ceil([self.commondata getDistance:((self.maxSteps/1000)+1)*1000]); break;
                case 1:
                case 2:
                    return self.commondata.target_distance;
                    break;
//                    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) return self.commondata.target_distance;
//                    else return self.commondata.target_distance*KM2MILE; break;
                case 3:
                    return self.commondata.target_distance*30;
                    break;
//                    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) return self.commondata.target_distance*30;
//                    else return self.commondata.target_distance*KM2MILE*30; break;
                default: break;
            }
        } break;
        case 6:
        case 7:{//睡眠
            switch (self.currentSeg) {
                case 0: return 60*60; break;
                case 1:
                case 2:return self.commondata.target_sleeptime; break;
                case 3:return 30*self.commondata.target_sleeptime; break;
                default: break;
            }
        } break;
        default: break;
    }
    return 0;
}
//y轴最大值，用于界面显示
-(NSString*)SXRChart2ViewMaxValueTip:(SXRChart2View*)view{
    switch (view.tag) {
        case 1:return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:220] numberStyle:NSNumberFormatterDecimalStyle]; break;//心率
        case 2:return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:50] numberStyle:NSNumberFormatterDecimalStyle]; break;//体温
//        case 3:{//骑行
//            switch (self.currentSeg) {
//                case 0:{
//                    int value = 1000;
//                    return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInt:value] numberStyle:NSNumberFormatterDecimalStyle];
//                } break;
//                case 1:
//                case 2:return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:10000] numberStyle:NSNumberFormatterDecimalStyle]; break;
//                case 3:return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:300000] numberStyle:NSNumberFormatterDecimalStyle]; break;
//                default: break;
//            }
//        } break;
        case 3:{//步数
            switch (self.currentSeg) {
                case 0:{
                    int value = (int)(((self.maxSteps/1000)+1)*1000);
                    return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInt:value] numberStyle:NSNumberFormatterDecimalStyle];
                } break;
                case 1:
                case 2:return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:self.commondata.target_steps] numberStyle:NSNumberFormatterDecimalStyle]; break;
                case 3:return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:self.commondata.target_steps*30] numberStyle:NSNumberFormatterDecimalStyle]; break;
                default: break;
            }
        } break;
        case 4:{//卡路里
            switch (self.currentSeg) {
                case 0:{
                    int value = ceil([self.commondata getCal:((self.maxSteps/1000)+1)*1000]);
                    return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInt:value] numberStyle:NSNumberFormatterDecimalStyle];
                } break;
                case 1:
                case 2:return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:self.commondata.target_calorie] numberStyle:NSNumberFormatterDecimalStyle]; break;
                case 3:return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:self.commondata.target_calorie*30] numberStyle:NSNumberFormatterDecimalStyle]; break;
                default: break;
            }
        } break;
        case 5:{//距离
            switch (self.currentSeg) {
                case 0:{
                    int value = ceil([self.commondata getDistance:((self.maxSteps/1000)+1)*1000]);
                    return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInt:value] numberStyle:NSNumberFormatterDecimalStyle];
                } break;
                case 1:
                case 2:{
                    return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:self.commondata.target_distance] numberStyle:NSNumberFormatterDecimalStyle];
//                    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:self.commondata.target_distance] numberStyle:NSNumberFormatterDecimalStyle];
//                    else return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:self.commondata.target_distance*KM2MILE] numberStyle:NSNumberFormatterDecimalStyle];
                } break;
                case 3:{
                    return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:self.commondata.target_distance*30] numberStyle:NSNumberFormatterDecimalStyle];
//                    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:self.commondata.target_distance*30] numberStyle:NSNumberFormatterDecimalStyle];
//                    else return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:self.commondata.target_distance*KM2MILE*30] numberStyle:NSNumberFormatterDecimalStyle];
                } break;
                default: break;
            }
        } break;
        case 6:
        case 7:{//睡眠
            switch (self.currentSeg) {
                case 0:return @"01:00"; break;
                case 1:
                case 2:return [NSString stringWithFormat:@"%.2d:%.2d",(int)self.commondata.target_sleeptime/3600,((int)self.commondata.target_sleeptime%3600)/60]; break;
                case 3:return [NSString stringWithFormat:@"%.2d:%.2d",(int)self.commondata.target_sleeptime*30/3600,((int)self.commondata.target_sleeptime*30%3600)/60]; break;
                default: break;
            }
        } break;
        default: break;
    }
    return @"";
}
//y轴最小值
-(NSString*)SXRChart2ViewMinValueTip:(SXRChart2View*)view{
    return @"0";
}
//左上方显示内容
-(NSAttributedString*)SXRChart2ViewTopLeftTip:(SXRChart2View*)view{
    CGFloat largesize = view.topTipHeight*0.66*0.6;
    CGFloat smallsize = view.topTipHeight*0.33*0.5;
    UIColor* textcolor = [UIColor whiteColor];
    NSMutableAttributedString* str;
    switch (view.tag) {
        case 1:{//心率
           str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Chart_Btn_Title_Heart", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            NSInteger avg_heart = 0;
            if (self.dbHeartDataCount == 0) avg_heart = 0;
            else avg_heart = self.totalHearts/self.dbHeartDataCount;
//            switch (self.currentSeg) {
//                case 1:
//                case 2:{
//                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"daily_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:avg_heart] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"BPM", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
//                } break;
//                case 3:{
//                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"monthly_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:avg_heart] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"BPM", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
//                } break;
//                default: break;
//            }
        } break;
        case 2:{//体温
            str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Chart_Btn_Title_Temperature", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            NSInteger avg_temperature = 0;
            if (self.dbTemperature == 0) avg_temperature = 0;
            else avg_temperature = self.totalTemperature/self.dbTemperature;
//            switch (self.currentSeg) {
//                case 1:
//                case 2:{
//                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"daily_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:avg_temperature] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
//                } break;
//                case 3:{
//                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"monthly_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:avg_temperature] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
//                } break;
//                default: break;
//            }
        } break;
//        case 3:{//骑行
//            str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Chart_Btn_Title_Bike", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
//            NSInteger avg_ride = 0;
//            if (self.dbRideDataCount == 0) avg_ride = 0;
//            else avg_ride = self.totalRides/self.dbRideDataCount;
//            switch (self.currentSeg) {
//                case 1:
//                case 2:{
//                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"daily_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:avg_ride] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
//                } break;
//                case 3:{
//                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"monthly_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:avg_ride] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
//                } break;
//                default: break;
//            }
//        } break;
        case 3:{//步数
            str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Chart_Btn_Title_Step", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            NSInteger avg_step = 0;
            if (self.dbDataCount == 0) avg_step = 0;
            else avg_step = self.totalSteps/self.dbDataCount;
            switch (self.currentSeg) {
                case 1:
                case 2:{
                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"daily_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:avg_step] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"UNIT_STEP", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
                } break;
                case 3:{
                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"monthly_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:avg_step] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"UNIT_STEP", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
                } break;
                default: break;
            }
        } break;
        case 4:{//卡路里
            str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Chart_Btn_Title_Calories", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            NSInteger avg_step = 0;
            if (self.dbDataCount == 0) avg_step = 0;
            else avg_step = self.totalSteps/self.dbDataCount;
            CGFloat avg_cal = [self.commondata getCal:avg_step];
            switch (self.currentSeg) {
                case 1:
                case 2:{
                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"daily_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:avg_cal] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"UNIT_CAL", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
                } break;
                case 3:{
                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"monthly_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:avg_cal] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"UNIT_CAL", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
                } break;
                default: break;
            }
        } break;
        case 5:{//距离
            str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Chart_Btn_Title_Distance", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            NSInteger avg_step = 0;
            if (self.dbDataCount == 0) avg_step = 0;
            else avg_step = self.totalSteps/self.dbDataCount;
            CGFloat avg_dist = [self.commondata getDistance:avg_step];
            switch (self.currentSeg) {
                case 1:
                case 2:{
                    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"daily_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:avg_dist] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"UNIT_KM", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
                    else [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"daily_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:avg_dist] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"UNIT_MILE", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
                } break;
                case 3:{
                    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"monthly_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:avg_dist] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"UNIT_KM", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
                    else [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %@ %@",NSLocalizedString(@"monthly_average", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:avg_dist] numberStyle:NSNumberFormatterDecimalStyle], NSLocalizedString(@"UNIT_MILE", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
                } break;
                default: break;
            }
        } break;
        case 6:{//睡眠
            str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Chart_Btn_Title_Sleep", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            double avg_sleep = 0;
            if (self.dbSleepDataCount == 0) avg_sleep = 0;
            else avg_sleep = (int)self.tSleepTime/self.dbSleepDataCount;
            switch (self.currentSeg) {
                case 1:
                case 2:{
                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %d%@%.2d%@",NSLocalizedString(@"daily_average", nil), (int)avg_sleep/3600, NSLocalizedString(@"UNIT_H", nil),((int)avg_sleep%3600)/60,NSLocalizedString(@"UNIT_M", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
                } break;
                case 3:{
                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %d%@%.2d%@",NSLocalizedString(@"monthly_average", nil), (int)avg_sleep/3600, NSLocalizedString(@"UNIT_H", nil),((int)avg_sleep%3600)/60,NSLocalizedString(@"UNIT_M", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
                } break;
                default: break;
            }
        } break;
        case 7:{//深睡
            str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"sleep_deep", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            double avg_sleep = 0;
            if (self.dbDeepSleepDataCount == 0) avg_sleep = 0;
            else avg_sleep = (int)self.tDeepSleepTime/self.dbDeepSleepDataCount;
            switch (self.currentSeg) {
                case 1:
                case 2:{
                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %d%@%.2d%@",NSLocalizedString(@"daily_average", nil), (int)avg_sleep/3600, NSLocalizedString(@"UNIT_H", nil),((int)avg_sleep%3600)/60,NSLocalizedString(@"UNIT_M", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
                } break;
                case 3:{
                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@ %d%@%.2d%@",NSLocalizedString(@"monthly_average", nil), (int)avg_sleep/3600, NSLocalizedString(@"UNIT_H", nil),((int)avg_sleep%3600)/60,NSLocalizedString(@"UNIT_M", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
                } break;
                default: break;
            }
        } break;
        default: break;
    }
    return str;
}
//右上方显示内容
-(NSAttributedString*)SXRChart2ViewTopRightTip:(SXRChart2View*)view{
    CGFloat largesize = view.topTipHeight*0.66*0.6;
    CGFloat smallsize = view.topTipHeight*0.33*0.5;
    UIColor* textcolor = [UIColor whiteColor];
    NSDate* lastsyncdate = nil;
    NSMutableDictionary* bonginfo = (NSMutableDictionary*)[self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bonginfo != nil) {
        NSNumber* nlasttime = [bonginfo objectForKey:BONGINFO_KEY_LASTSYNCTIME];
        if (nlasttime != nil) {
            lastsyncdate = [NSDate dateWithTimeIntervalSince1970:nlasttime.doubleValue];
        }
    }
    NSMutableAttributedString* str;
    switch (view.tag) {
        case 1:{
            str = [[NSMutableAttributedString alloc] initWithString:[NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:self.lastHeart] numberStyle:NSNumberFormatterDecimalStyle] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"BMP\n" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            if(self.lastHeartDate != nil){
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:self.lastHeartDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterMediumStyle] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }else{
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"---" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }
            
        }
            break;
//            str=[[NSMutableAttributedString alloc]initWithString:@""]; break;
        case 2:{
            str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.1f",self.lastTemp] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"°C\n" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            if(self.lastTempDate != nil){
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:self.lastTempDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterMediumStyle] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }else{
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"---" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }
            
        }
            break;
//            str=[[NSMutableAttributedString alloc]initWithString:@""]; break;
        //case 3:str=[[NSMutableAttributedString alloc]initWithString:@""]; break;
        case 3:{//步数
            str = [[NSMutableAttributedString alloc] initWithString:[NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:self.totalSteps] numberStyle:NSNumberFormatterDecimalStyle] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",NSLocalizedString(@"UNIT_STEP", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            if(lastsyncdate != nil){
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:lastsyncdate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterMediumStyle] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }else{
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"---" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }

        } break;
        case 4:{//卡路里
            NSNumber* numbers =[NSNumber numberWithFloat:[self.commondata getCal:self.totalSteps]];
            str = [[NSMutableAttributedString alloc] initWithString:[NSNumberFormatter localizedStringFromNumber:numbers numberStyle:NSNumberFormatterDecimalStyle] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",NSLocalizedString(@"UNIT_KCAL", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            if(lastsyncdate != nil){
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:lastsyncdate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterMediumStyle] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }else{
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"---" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }

        } break;
        case 5:{//距离
            NSNumber* numbers =[NSNumber numberWithFloat:[self.commondata getDistance:self.totalSteps]];
            str = [[NSMutableAttributedString alloc] initWithString:[NSNumberFormatter localizedStringFromNumber:numbers numberStyle:NSNumberFormatterDecimalStyle] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",NSLocalizedString(@"UNIT_KM", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            else [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",NSLocalizedString(@"UNIT_MILE", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            if(lastsyncdate != nil){
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:lastsyncdate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterMediumStyle] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }else{
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"---" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }

        } break;
        case 6:{//睡眠
            str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d%@%.2d%@\n",(int)self.tSleepTime/3600, NSLocalizedString(@"UNIT_H", nil),((int)self.tSleepTime%3600)/60,NSLocalizedString(@"UNIT_M", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            if(lastsyncdate != nil){
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:lastsyncdate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterMediumStyle] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }else{
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"---" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }

        } break;
        case 7:{//深睡
            str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d%@%.2d%@\n",(int)self.tDeepSleepTime/3600, NSLocalizedString(@"UNIT_H", nil),((int)self.tDeepSleepTime%3600)/60,NSLocalizedString(@"UNIT_M", nil)] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largesize],NSForegroundColorAttributeName:textcolor}];
            if(lastsyncdate != nil){
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:lastsyncdate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterMediumStyle] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }else{
                [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"---" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:smallsize],NSForegroundColorAttributeName:textcolor}]];
            }

        } break;
        default: break;
    }
    return str;
}

//当前分段选择器序号
-(NSInteger)SXRChart2ViewCurrentMode:(SXRChart2View*)view{
    return self.currentSeg;
}
//x坐标点个数
-(NSInteger)SXRChart2ViewBarCount:(SXRChart2View*)view{
    if ((view.tag == 1 || view.tag == 2)&& self.currentSeg == 0) {
        return 1440;
    }
    return self.datacount;
}
//背景色
-(UIColor*)SXRChart2ViewBackgroundColor:(SXRChart2View*)view{
    switch (view.tag) {
        case 1:return [[UIColor colorWithRed:0xfc/255.0 green:0x3c/255.0 blue:0x51/255.0 alpha:1.0] colorWithAlphaComponent:1]; break;
        case 2:return [[UIColor colorWithRed:0x7d/255.0 green:0x94/255.0 blue:0x9a/255.0 alpha:1.0] colorWithAlphaComponent:1]; break;
        //case 3:return [[UIColor colorWithRed:0x92/255.0 green:0xd0/255.0 blue:0x7a/255.0 alpha:1.0] colorWithAlphaComponent:1]; break;
        case 3:return [[UIColor colorWithRed:0xef/255.0 green:0xca/255.0 blue:0x9e/255.0 alpha:1.0] colorWithAlphaComponent:1]; break;
        case 4:return [[UIColor colorWithRed:0xff/255.0 green:0x7a/255.0 blue:0x67/255.0 alpha:1.0] colorWithAlphaComponent:1]; break;
        case 5:return [[UIColor colorWithRed:0x6d/255.0 green:0xdb/255.0 blue:0xd8/255.0 alpha:1.0] colorWithAlphaComponent:1]; break;
        case 6:return [[UIColor colorWithRed:0x5b/255.0 green:0x70/255.0 blue:0xd9/255.0 alpha:1.0] colorWithAlphaComponent:1]; break;
        case 7:return [[UIColor colorWithRed:0x69/255.0 green:0xAD/255.0 blue:0xFF/255.0 alpha:1.0] colorWithAlphaComponent:1]; break;
        default:return [UIColor clearColor]; break;
    }
}
//文字颜色
-(UIColor*)SXRChart2ViewTextColor:(SXRChart2View*)view{
    return [UIColor whiteColor];
}
//分割线的颜色
-(UIColor*)SXRChart2ViewSepLineColor:(SXRChart2View*)view{
    return [UIColor whiteColor];
}
//图表线条或者柱状图的颜色
-(UIColor*)SXRChart2ViewBarColor:(SXRChart2View*)view{
    return [UIColor whiteColor];
}
//x轴显示坐标内容
-(NSArray*)SXRChart2ViewXLabelArray:(SXRChart2View*)view{
    return @[@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
}
//x轴显示的内容过滤值，每隔几个显示一个坐标
-(NSInteger)SXRChart2ViewXLabelFilter:(SXRChart2View*)view{
    return 3;
}
-(CGFloat)SXRChart2ViewMiddleLabel1Value:(SXRChart2View *)view{
    if (self.currentSeg == 0) {
        if (view.tag == 1) {
            return 60;
        }else if (view.tag == 2){
            return 37;
        }else{
            return 0;
        }
    }else{
        return 0;
    }
}
-(CGFloat)SXRChart2ViewMiddleLabel2Value:(SXRChart2View *)view{
    if (self.currentSeg == 0) {
        if (view.tag == 1) {
            return 120;
        }else if (view.tag == 2){
            return 0;
        }else{
            return 0;
        }
    }else{
        return 0;
    }
}
-(void)SXRChart2ViewBeginOnTouched:(SXRChart2View *)view{
    for(int i = 0; i< 7 ;i++){
        if (i!=(view.tag - 1)) {
            SXRChart2View* chart = [self.scrollview viewWithTag:i+1];
            [chart hiddenTips];
        }
    }
}
-(BOOL)SXRChart2ViewNeedTips:(SXRChart2View *)view{
    if (self.currentSeg == 0) {
        if (view.tag == 1) {
            return YES;
        }else if (view.tag == 2){
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
 
}

#pragma mark ---------Auxiliary Method--------
-(void)refresh{
    [self.chartarray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SXRChart2View* chart = (SXRChart2View*)obj;
        [chart reload];
    }];
}
-(NSDate*)lastMonthDay:(NSDate*)currentdate{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comp = [[NSDateComponents alloc] init];
    comp = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:currentdate];
    comp.month -= 1;
    //comp.day += 1;
    NSDate* reterndate = [calendar dateFromComponents:comp];
    //NSLog(@"lastMonthDay = %@",reterndate);
    return reterndate;
}

-(NSDate*)lastYearDay:(NSDate*)currentdate{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comp = [[NSDateComponents alloc] init];
    comp = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:currentdate];
    comp.year -= 1;
    if (comp.day == 29 && comp.month == 2) {
        comp.day -= 1;
    }
    NSDate* reterndate = [calendar dateFromComponents:comp];
    //NSLog(@"lastYearDay = %@",reterndate);
    return reterndate;
}

#pragma mark --------Share Method--------
-(void)onClickShare:(UIButton*)sender{
    NSArray* imageArray = @[[self screenshot2]];
    UIImage *image=[self screenshot2];
    //    （注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
    if (imageArray) {
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
//        NSURL* url = [NSURL URLWithString:@"http://www.keeprapid.com"];
        [shareParams SSDKSetupShareParamsByText:NSLocalizedString(@"ShareText", nil) images:image url:nil title:NSLocalizedString(@"ShareText", nil) type:SSDKContentTypeAuto];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:nil items:nil shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
            switch (state) {
                case SSDKResponseStateSuccess:{
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    //[alertView show];
                } break;
                case SSDKResponseStateFail:{
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败" message:[NSString stringWithFormat:@"%@",error.userInfo[@"error_message"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    //[alert show];
                } break;
                case SSDKResponseStateCancel:{
//                    UIAlertView *alertViews = [[UIAlertView alloc] initWithTitle:@"分享已取消" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    //[alertViews show];
                } break;
                default: break;
            }
        }];
    }
}

-(UIImage*)screenshot2{
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) UIGraphicsBeginImageContextWithOptions(appdelegate.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else UIGraphicsBeginImageContext(appdelegate.window.bounds.size);
    //[[[[UIApplication sharedApplication] windows] objectAtIndex:0] drawViewHierarchyInRect:appdelegate.window.bounds afterScreenUpdates:YES]; // Set To YES
    [appdelegate.window.layer renderInContext:UIGraphicsGetCurrentContext() ];
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
