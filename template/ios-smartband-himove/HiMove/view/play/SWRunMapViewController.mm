//
//  SWRunMapViewController.m
//  SXRBand
//
//  Created by qf on 15/11/17.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import "SWRunMapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "mkMoveAnnotation.h"
#import "mkMoveAnnotationView.h"
#import <CoreLocation/CoreLocation.h>
#import "SWTextAttachment.h"
#import "RunHistory+CoreDataClass.h"
#import "RunRecord+CoreDataClass.h"
#import "HBLockSliderView.h"
#import "AppDelegate.h"
#import "MainLoop.h"
#import "CommonDefine.h"
#import "IRKCommonData.h"
#import "TaskManager.h"

@interface SWRunMapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,HBLockSliderDelegate>
@property (nonatomic, strong) IRKCommonData* commondata;
@property (nonatomic, strong) MKMapView* mapview;
@property (nonatomic, strong) CLLocationManager* locationmanager;
@property (nonatomic, strong) CLLocationManager* locationmanager_longterm;
@property (nonatomic, strong) mkMoveAnnotation* currentanno;
@property (nonatomic, strong) CLLocation* lastlocation;
@property (nonatomic, strong) NSManagedObjectContext* context;
//@property (nonatomic, strong) NSManagedObjectContext* parentcontext;
@property(nonatomic,strong) dispatch_queue_t dataqueue;
@property(nonatomic,strong) NSString* current_runid;
@property(nonatomic,strong) NSMutableArray* arrayLoc;
@property(nonatomic,strong) NSMutableArray* arrayCoordinate;
@property(nonatomic,strong) NSMutableArray* overlayArray;
@property(nonatomic,strong) UILabel* labeldistance;
@property(nonatomic,strong) UILabel* labelgps;
@property(nonatomic,strong) UILabel* labeltime;
@property(nonatomic,strong) UILabel* labelspeed;
@property(nonatomic,strong) UILabel* labelcal;
@property(nonatomic,strong) UIButton* btn_start;
@property(nonatomic,strong) UIButton* btn_finish;
@property(nonatomic,strong) UIButton* btn_continue;
@property(nonatomic,assign) int runstate;  //0-stop 1-start 2-pause
@property(nonatomic, assign)double seconds;
@property(nonatomic, strong)NSTimer* timer;
@property(nonatomic, assign)double currentdistance;
@property(nonatomic, assign)CGFloat currentcal;
@property(nonatomic, assign)NSInteger currentstep;
@property(nonatomic, assign)double currentpace;
@property(nonatomic, strong)RunRecord* runrecord;
@property(nonatomic, strong)NSDate* intobackdate;
@property(nonatomic, assign)double intobackseconds;
@property (nonatomic,strong)UIView *startView;
@property (nonatomic,strong)UIButton *runBtn;
@property (nonatomic,strong)UIButton *walkBtn;
@property (nonatomic,strong)UIButton *bicycleBtn;
@property (nonatomic,strong)UIView *playView;
@property (nonatomic,strong)HBLockSliderView *suspend;
@property (nonatomic,strong)UIView *bottomView;
@property (nonatomic,strong)UILabel *recordDistance;
@property (nonatomic,strong)UILabel *recordTimes;
//@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong)UIButton *btn;
@property(nonatomic,strong) MainLoop *mainloop;
@end

@implementation SWRunMapViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    
    
    if (!self.locationmanager) {
        self.locationmanager =[[CLLocationManager alloc] init];
        self.locationmanager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationmanager.delegate = self;
        self.locationmanager.distanceFilter =5;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            self.locationmanager.allowsBackgroundLocationUpdates = YES;
        }
    }
    if (!self.locationmanager_longterm) {
        self.locationmanager_longterm =[[CLLocationManager alloc] init];
        self.locationmanager_longterm.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationmanager_longterm.delegate = self;
        self.locationmanager_longterm.distanceFilter =5;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            self.locationmanager_longterm.allowsBackgroundLocationUpdates = YES;
        }
    }
    self.mapview.delegate=self;
    [self.locationmanager startUpdatingLocation];
    [self.locationmanager_longterm startMonitoringSignificantLocationChanges];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResigActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [self performSelector:@selector(startBtnClick:) withObject:nil afterDelay:0.5];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.locationmanager stopUpdatingLocation];
    [self.locationmanager_longterm stopMonitoringSignificantLocationChanges];
    self.locationmanager.delegate =nil;
    self.locationmanager = nil;
    
    self.locationmanager_longterm.delegate = nil;
    self.locationmanager_longterm = nil;
    self.mapview=nil;
    //[self.mapview removeFromSuperview];
    self.mapview.delegate=nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[TaskManager SharedInstance] AddUpLoadTaskBySyncKey:SYNCKEY_RUNRECORD];
    [[TaskManager SharedInstance] AddUpLoadTaskBySyncKey:SYNCKEY_RUNHISTORY];
    //////////for healthkit/////////////
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_syncdata_to_healthkit object:nil userInfo:@{@"tablename":@"RunRecord"}];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.mainloop=[MainLoop SharedInstance];
    
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    self.managedObjectContext = appdelegate.managedObjectContext;
    
//    self.parentcontext = appdelegate.managedObjectContext;
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.context.parentContext = appdelegate.managedObjectContext;
    
    
    self.arrayLoc = [[NSMutableArray alloc] init];
    self.arrayCoordinate = [[NSMutableArray alloc] init];
    self.overlayArray = [[NSMutableArray alloc] init];
    self.currentcal = 0;
    self.currentdistance = 0;
    self.currentpace = 0;
    self.currentstep = 0;
    
    self.mapview = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [self.view addSubview:self.mapview];
   
    [self initControl];
    [self initcontrol];
    
    _btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 50, 30)];
    [_btn setImage:[UIImage imageNamed:@"icon_back_hsk_green"] forState:UIControlStateNormal];
    _btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_btn addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn];
}

-(void)initControl{
    _startView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) ];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _startView.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor blackColor] colorWithAlphaComponent:0.9].CGColor,
                       (id)[[UIColor whiteColor]colorWithAlphaComponent:0.0].CGColor,nil];
    [_startView.layer insertSublayer:gradient atIndex:0];
    _startView.userInteractionEnabled = YES;
    [self.view addSubview:_startView];
    
    UIButton *startBtn=[[UIButton alloc]initWithFrame:CGRectMake(30, CGRectGetHeight(self.view.frame)-150, CGRectGetWidth(self.view.frame)-60, 50)];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"startBtn_backgroundImage"] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [startBtn setTitle:NSLocalizedString(@"running_start", nil) forState:UIControlStateNormal];
    startBtn.titleLabel.textColor=[UIColor whiteColor];
    [_startView addSubview:startBtn];
    [_startView setHidden:YES];
}

-(void)initcontrol{
    _playView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)*5/8, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*3/8) ];
    _playView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    _playView.userInteractionEnabled = YES;
    [self.view addSubview:_playView];
    
    self.labeldistance = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetHeight(_playView.frame)/6-20, CGRectGetWidth(self.view.frame)-15, CGRectGetHeight(_playView.frame)/6)];
    NSMutableAttributedString* str_distance = [[NSMutableAttributedString alloc] initWithString:@"0.00" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:50]}];
    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
        [str_distance appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_KM", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}]];
    }else{
        [str_distance appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_MILE", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}]];
    }
    self.labeldistance.attributedText = str_distance;
    self.labeldistance.textColor = [UIColor whiteColor];
    [_playView addSubview:self.labeldistance];
    
    UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(self.labeldistance.frame)+5, CGRectGetWidth(self.view.frame)-30, 1.5)];
    sepView.backgroundColor=[UIColor whiteColor];
    [_playView addSubview:sepView];
    
    self.labelgps = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2.0, CGRectGetHeight(_playView.frame)/6-20, CGRectGetWidth(self.view.frame)/2.0-15, CGRectGetHeight(_playView.frame)/6)];
    self.labelgps.textAlignment = NSTextAlignmentRight;
    self.labelgps.textColor = [UIColor whiteColor];
    SWTextAttachment* attach = [[SWTextAttachment alloc] init];
    attach.image = [UIImage imageNamed:@"icon_gps_white.png"];
    NSAttributedString* attatchstring = [NSAttributedString attributedStringWithAttachment:attach];
    NSMutableAttributedString* strgps  = [[NSMutableAttributedString alloc] initWithAttributedString:attatchstring ];
    [strgps appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@ %@",NSLocalizedString(@"GPS", nil),NSLocalizedString(@"None", nil)] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}]];
    self.labelgps.attributedText = strgps;
    [_playView addSubview:self.labelgps];
    
    
    CGFloat labelwidth = CGRectGetWidth(sepView.frame)/3.0;
    NSArray *textArray=@[NSLocalizedString(@"Speed", nil),NSLocalizedString(@"Heat", nil),NSLocalizedString(@"Duration", nil)];
    NSMutableArray *labelArray=[NSMutableArray array];
    for (int i=0; i<3; i++) {
        UIImageView* imageView= [[UIImageView alloc] initWithFrame:CGRectMake(i*labelwidth+15, CGRectGetMaxY(sepView.frame)+5, 20, 20)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"play_icon_%d",i]];
        [_playView addSubview:imageView];
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame), imageView.frame.origin.y, labelwidth-20, 20)];
        label.textColor=[UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11];
        label.text=textArray[i];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        [_playView addSubview:label];
        
        UILabel *egLabel=[[UILabel alloc]initWithFrame:CGRectMake(i*labelwidth+15, CGRectGetMaxY(imageView.frame)+5, labelwidth-10, 35)];
        egLabel.textColor = [UIColor whiteColor];
        egLabel.textAlignment=NSTextAlignmentLeft;
        egLabel.font=[UIFont systemFontOfSize:11];
        [labelArray addObject:egLabel];
    }
    self.labelspeed=(UILabel*)labelArray[0];
    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
        self.labelspeed.text=[NSString stringWithFormat:@"00'00''%@/%@",NSLocalizedString(@"UNIT_MIN", nil),NSLocalizedString(@"UNIT_KM", nil)];
    }else{
        self.labelspeed.text=[NSString stringWithFormat:@"00'00''%@/%@",NSLocalizedString(@"UNIT_MIN", nil),NSLocalizedString(@"UNIT_MILE", nil)];
    }
    [_playView addSubview:self.labelspeed];
    
    self.labelcal=(UILabel*)labelArray[1];
    self.labelcal.text=[NSString stringWithFormat:@"0.0%@",NSLocalizedString(@"UNIT_KCAL", nil)];
    [_playView addSubview:self.labelcal];
    
    self.labeltime=(UILabel*)labelArray[2];
    self.labeltime.text=@"00:00:00";
    [_playView addSubview:self.labeltime];
    
    CGFloat suspend_y=(_playView.frame.size.height-CGRectGetMaxY(self.labelspeed.frame)-50)/2+CGRectGetMaxY(self.labelspeed.frame);
    _suspend = [[HBLockSliderView alloc] initWithFrame:CGRectMake(30, suspend_y, CGRectGetWidth(self.view.frame)-60, 50)];
    _suspend.text = NSLocalizedString(@"Skip_stop", nil);
    [_suspend setColorForBackgroud:[UIColor colorWithRed:64/255.0 green:195/255.0 blue:175/255.0 alpha:1] foreground:[UIColor colorWithRed:0 green:182/255.0 blue:198/255.0 alpha:1] thumb:[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1] border:[UIColor blackColor] textColor:[UIColor whiteColor]];
    _suspend.thumbImage=[UIImage imageNamed:@"slide_cycle"];
    _suspend.finishImage=[UIImage imageNamed:@"slide_cycle_blue"];
    _suspend.delegate=self;
    [_playView addSubview:_suspend];
    
    self.btn_continue = [[UIButton alloc] initWithFrame:CGRectMake(30,suspend_y, 100, 40)];
    self.btn_continue.backgroundColor = [UIColor clearColor];
    self.btn_continue.layer.cornerRadius = 20;
    self.btn_continue.layer.borderWidth=2;
    self.btn_continue.layer.borderColor=[UIColor whiteColor].CGColor;
    [self.btn_continue setTitle:NSLocalizedString(@"Continue", nil) forState:UIControlStateNormal];
    self.btn_continue.titleLabel.textColor=[UIColor whiteColor];
    [self.btn_continue addTarget:self action:@selector(onTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    self.btn_continue.tag = 1;
    self.btn_continue.alpha = 0;
    [_playView addSubview:self.btn_continue];
    
    self.btn_finish = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-130,suspend_y, 100, 40)];
    self.btn_finish.backgroundColor = [UIColor clearColor];
    self.btn_finish.layer.cornerRadius = 20;
    self.btn_finish.layer.borderWidth=2;
    self.btn_finish.layer.borderColor=[UIColor whiteColor].CGColor;
    [self.btn_finish setTitle:NSLocalizedString(@"Finish", nil) forState:UIControlStateNormal];
    self.btn_finish.titleLabel.textColor=[UIColor whiteColor];
    [self.btn_finish addTarget:self action:@selector(onTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    self.btn_finish.tag = 2;
    self.btn_finish.alpha = 0;
    [_playView addSubview:self.btn_finish];
    
    [_playView setHidden:NO];
}




#pragma mark --------HBLockSliderDelegate Method--------
- (void)sliderEndValueChanged:(HBLockSliderView *)slider{
    if (self.runstate) {
        self.runstate = 2;
        [self stoptimer];
        [UIView animateWithDuration:0.5 animations:^{
            self.suspend.alpha = 0;
            self.btn_finish.alpha = 1;
            self.btn_continue.alpha = 1;
        }];
    }
}


#pragma mark --------Location Method--------
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSMutableParagraphStyle* p = [[NSMutableParagraphStyle alloc] init];
    p.alignment = NSTextAlignmentCenter;
    //    self.textlog.attributedText = strlog;
    NSLog(@"%@",locations);
    if ([locations count]) {
        CLLocation* loc = [locations lastObject];
        if (self.mainloop.runmode == RUNMODE_ACTIVE) {
            NSString* signal;
            if(loc.horizontalAccuracy < GPS_ACCURACY_VALID){
                signal = NSLocalizedString(@"None", nil);
            }else if (loc.horizontalAccuracy>GPS_ACCURACY_WEAK){
                signal = NSLocalizedString(@"Weak", nil);
            }else if (loc.horizontalAccuracy>0 && loc.horizontalAccuracy <GPS_ACCURACY_STRONG){
                signal = NSLocalizedString(@"Strong", nil);
            }else{
                signal = NSLocalizedString(@"Medium", nil);
            }
            SWTextAttachment* attach = [[SWTextAttachment alloc] init];
            attach.image = [UIImage imageNamed:@"icon_gps_white.png"];
            NSAttributedString* attatchstring = [NSAttributedString attributedStringWithAttachment:attach];
            NSMutableAttributedString* str  = [[NSMutableAttributedString alloc] initWithAttributedString:attatchstring ];
            [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@ %@",NSLocalizedString(@"GPS", nil),signal] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:p}]];
            self.labelgps.attributedText = str;
        }else{
//                        UILocalNotification *notification=[[UILocalNotification alloc]init];
//                        //设置调用时间
//                        notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:0.5];//通知触发的时间，10s以后
//                        //设置通知属性
//                        notification.alertBody=loc.description; //通知主体
//                        notification.alertAction=@"打开应用"; //待机界面的滑动动作提示
//                        notification.alertLaunchImage=@"Default";//通过点击通知打开应用时的启动图片,这里使用程序启动图片
//                        notification.soundName=UILocalNotificationDefaultSoundName;//通知声音（需要真机才能听到声音）
//                        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
        
        
        if (self.runstate == 1) {
            if ([self.arrayLoc count] == 0 && loc.horizontalAccuracy > START_RUN_ACCURACY) {
                return;
            }
            //过滤掉无用的点
            if (loc.horizontalAccuracy>GPS_ACCURACY_UNTRUST || loc.course <0||loc.speed<0) {
                return;
            }
            
            if (self.lastlocation) {
                double distance = [loc distanceFromLocation:self.lastlocation];
                self.currentdistance+=distance;
            }
            self.lastlocation = loc;
            CLLocationCoordinate2D pt = [self.commondata convert_wgs2gcj:loc.coordinate];
            NSLog(@"map=======>%@",loc);
            if (self.currentanno == nil) {
                //           imageAnnotation* ano = [[imageAnnotation alloc] init];
                mkMoveAnnotation* ano = [[mkMoveAnnotation alloc] init];
                ano.coordinate = pt;
                self.currentanno=ano;
                
                MKMapPoint mappoint = MKMapPointForCoordinate(pt);
                [(mkMoveAnnotation*)self.currentanno SetMapPoint:mappoint];
                //           ano.title = @"iam here";
                [self.mapview addAnnotation:ano];
                [self zoom_forSee];
                //            [self performSelector:@selector(zoom_forSee) withObject:nil afterDelay:0.3];
            }else{
                MKMapPoint mappoint = MKMapPointForCoordinate(pt);
                [(mkMoveAnnotation*)self.currentanno SetMapPoint:mappoint];
                //                [self center_forSee];
                [self performSelector:@selector(center_forSee) withObject:nil afterDelay:0.3];
                
            }
            
            
            [self.arrayLoc addObject:loc];
            [self.arrayCoordinate addObject:@{@"lng":[NSNumber numberWithDouble:pt.longitude],@"lat":[NSNumber numberWithDouble:pt.latitude]}];
            
            [self addLine];
            [self refreshText];
            
            RunHistory* record = [NSEntityDescription insertNewObjectForEntityForName:@"RunHistory" inManagedObjectContext:self.context];
            record.uid = self.commondata.uid;
            record.running_id = self.current_runid;
            record.latitude = [NSNumber numberWithDouble:loc.coordinate.latitude];
            record.longitude = [NSNumber numberWithDouble:loc.coordinate.longitude];
            record.altitude = [NSNumber numberWithDouble:loc.altitude];
            record.direction = [NSNumber numberWithDouble:loc.course];
            record.locType = @1;
            record.macid = @"";
            //record.issync = [NSNumber numberWithBool:NO];
            record.radius = [NSNumber numberWithDouble:loc.horizontalAccuracy];
            record.satellite_number = @2;
            record.speed = [NSNumber numberWithDouble:loc.speed];
            record.adddate = [loc.timestamp copy];
            record.addtimestamp = [NSNumber numberWithDouble:[loc.timestamp timeIntervalSince1970]];
            record.issync = [NSNumber numberWithBool:NO];
            record.memberid = self.commondata.memberid;
            
            self.runrecord.pace = [NSNumber numberWithFloat:0];
            self.runrecord.adddate = [loc.timestamp copy];
            
            self.runrecord.totalcalories = [NSNumber numberWithFloat:self.currentcal];
            self.runrecord.totaldistance = [NSNumber numberWithDouble:self.currentdistance];
            self.runrecord.totalstep = [NSNumber numberWithInteger:self.currentstep];
            self.runrecord.pace = [NSNumber numberWithDouble:self.currentpace];
            self.runrecord.totaltime = [NSNumber numberWithDouble:self.seconds];
            
            [self save2DB];
            
        }else{
            
            if (!(loc.horizontalAccuracy>GPS_ACCURACY_UNTRUST || loc.course <0||loc.speed<0)) {
                self.lastlocation = loc;
            }
            
            CLLocationCoordinate2D pt = [self.commondata convert_wgs2gcj:loc.coordinate];
            NSLog(@"map=======>%@",loc);
            if (self.currentanno == nil) {
                //           imageAnnotation* ano = [[imageAnnotation alloc] init];
                mkMoveAnnotation* ano = [[mkMoveAnnotation alloc] init];
                ano.coordinate = pt;
                self.currentanno=ano;
                
                MKMapPoint mappoint = MKMapPointForCoordinate(pt);
                [(mkMoveAnnotation*)self.currentanno SetMapPoint:mappoint];
                [self.mapview addAnnotation:ano];
                [self zoom_forSee:pt];
            }else{
                MKMapPoint mappoint = MKMapPointForCoordinate(pt);
                [(mkMoveAnnotation*)self.currentanno SetMapPoint:mappoint];
                [self center_forSee:pt];
            }
            
        }
        
    }
}
#pragma mark --------MapView Method--------
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer* polylineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        polylineView.fillColor = [UIColor colorWithRed:0x2e/255.0 green:0xb8/255.0 blue:0x32/255.0 alpha:1.0];//self.commondata.colorMapLine;
        //       polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.strokeColor = [UIColor colorWithRed:0x2e/255.0 green:0xb8/255.0 blue:0x32/255.0 alpha:1.0];//self.commondata.colorMapLine;
        polylineView.lineWidth = 4.0;
        //        polylineView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        //        polylineView.layer.shadowOpacity = 0.8;
        //        polylineView.layer.shadowRadius = 2;
        //        polylineView.layer.shadowOffset = CGSizeMake(1, 1);
        return polylineView;
    }
    return nil;
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView* polylineView = [[MKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [UIColor colorWithRed:0x2e/255.0 green:0xb8/255.0 blue:0x32/255.0 alpha:1.0];//self.commondata.colorMapLine;
        //       polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.strokeColor = [UIColor colorWithRed:0x2e/255.0 green:0xb8/255.0 blue:0x32/255.0 alpha:1.0];//self.commondata.colorMapLine;
        polylineView.lineWidth = 4.0;
        polylineView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        polylineView.layer.shadowOpacity = 0.8;
        polylineView.layer.shadowRadius = 2;
        polylineView.layer.shadowOffset = CGSizeMake(1, 1);
        return polylineView;
    }
    return nil;
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    static NSString* annotationId = @"mkcustomanotation";
    static NSString* moveanoid = @"mkmoveano";
    
    if([annotation isKindOfClass:[mkMoveAnnotation class]]){
        mkMoveAnnotationView *annotationView = (mkMoveAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:moveanoid];
        if (!annotationView) {
            annotationView = [[mkMoveAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:moveanoid];
        }else{
            annotationView.annotation = annotation;
        }
        //configure the annotation view
        annotationView.imageview.image = [UIImage imageNamed:@"icon_anno_start.png"];
        
        annotationView.imageview.contentMode = UIViewContentModeScaleAspectFit;
        //        annotationView.imageview.contentMode = UIViewContentModeScaleAspectFit;
        //        annotationView.frame = CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y, 46, 52);
        //        annotationView.frame = CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y, 30, 30);
        //        annotationView.imageview.frame = CGRectMake(3, 3, 40, 40);
        //        annotationView.imageview.layer.cornerRadius = 3;
        annotationView.mapView = self.mapview;
        annotationView.showView = self.view;
        return annotationView;
    }
    else{
        MKAnnotationView* annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
        annotationView.backgroundColor = [UIColor colorWithRed:0x14/255.0 green:0x73/255.0 blue:0xd5/255.0 alpha:1.0];//self.commondata.colorNav;
        annotationView.frame = CGRectMake(0, 0, 14, 14);
        annotationView.layer.cornerRadius = 7;
        annotationView.layer.borderColor = [UIColor whiteColor].CGColor;
        annotationView.layer.borderWidth = 2;
        annotationView.layer.shadowColor = [UIColor grayColor].CGColor;
        annotationView.layer.shadowOffset = CGSizeMake(2, 2);
        annotationView.layer.shadowOpacity = 0.8;
        annotationView.clipsToBounds = YES;
        return annotationView;
    }
    return nil;
}

-(void)zoom_forSee:(CLLocationCoordinate2D)pt{
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pt, 500, 500);
    [self.mapview setRegion:region animated:NO];
    
}
-(void)zoom_forSee{
    if ([self.arrayCoordinate count]) {
        NSDictionary* obj = [self.arrayCoordinate lastObject];
        NSNumber* lat = [obj objectForKey:@"lat"];
        NSNumber* lng = [obj objectForKey:@"lng"];
        CLLocationCoordinate2D pt =  CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pt, 500, 500);
        [self.mapview setRegion:region animated:NO];
        //        [self.mapview setCenterCoordinate:pt animated:YES];
        
    }
    
}
-(void)center_forSee:(CLLocationCoordinate2D)pt{
    
    [self.mapview setCenterCoordinate:pt animated:YES];
    
}
-(void)center_forSee{
    if ([self.arrayCoordinate count]) {
        NSDictionary* obj = [self.arrayCoordinate lastObject];
        NSNumber* lat = [obj objectForKey:@"lat"];
        NSNumber* lng = [obj objectForKey:@"lng"];
        CLLocationCoordinate2D pt =  CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
        [self.mapview setCenterCoordinate:pt animated:YES];
        
    }
    
}
#pragma mark --------Click Method--------
-(void)startBtnClick:(UIButton*)sender{
    self.runstate = 1;//开始运动
    [_startView setHidden:YES];
    [_playView setHidden:NO];
    
    [self startrunning];
    [self.locationmanager startUpdatingLocation];
}

-(void)onClickBack:(UIButton*)sender{
    if (self.runrecord /*&& self.runrecord.closed.intValue == 0*/) {
        
        self.runrecord.closed = @1;
        self.runrecord.adddate = [NSDate date];
        self.runrecord.totalcalories = [NSNumber numberWithFloat:self.currentcal];
        self.runrecord.totaldistance = [NSNumber numberWithFloat:self.currentdistance];
        self.runrecord.totalstep = [NSNumber numberWithInteger:self.currentstep];
        self.runrecord.totaltime = [NSNumber numberWithDouble:self.seconds];
        self.runrecord.pace = [NSNumber numberWithDouble:self.currentpace];
        [self save2DB];
    }
    if (self.runstate != 0) {
        [[[UIAlertView alloc] initWithTitle:nil/*NSLocalizedString(@"Tip_ERROR", nil)*/ message:NSLocalizedString(@"Running_not_exit", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil] show];
        return;
    }
    //[self.locationmanager stopUpdatingLocation];
    //self.locationmanager = nil;
    //self.mapview=nil;
    
    /**删除地图上的线和数组内容**/
    if (self.overlayArray.count>0) {
        [self.mapview removeOverlays:self.overlayArray];
        [self.overlayArray removeAllObjects];
    }
    if (self.arrayLoc.count) {
        [self.arrayLoc removeAllObjects];
    }
    if (self.arrayCoordinate.count) {
        [self.arrayCoordinate removeAllObjects];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    //self.navigationController pop
}

-(void)onTouchUp:(UIButton*)sender{
    switch (sender.tag) {
        case 1:{
            self.runstate = 1;
            self.suspend.alpha = 1;
            self.btn_finish.alpha = 0;
            self.btn_continue.alpha = 0;
            [self resumetimer];
            [self.locationmanager startUpdatingLocation];
        }
            break;
        case 2:{
            self.runstate = 0;
            self.btn_finish.alpha = 0;
            self.btn_continue.alpha = 0;
            if (self.runrecord) {
//                self.runrecord.closed = [NSNumber numberWithInt:1];
                self.runrecord.adddate = [NSDate date];
                self.runrecord.totalcalories = [NSNumber numberWithFloat:self.currentcal];
                self.runrecord.totaldistance = [NSNumber numberWithFloat:self.currentdistance];
                self.runrecord.totalstep = [NSNumber numberWithInteger:self.currentstep];
                self.runrecord.totaltime = [NSNumber numberWithDouble:self.seconds];
                self.runrecord.pace = [NSNumber numberWithDouble:self.currentpace];
                
//                [self save2DB];
                
                [self onClickBack:nil];
            }
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark --------Notification Method--------
-(void)onActive{
    NSLog(@"::::>>>onActive");
    if (self.runstate == 1) {
        self.seconds = self.intobackseconds + [[NSDate date] timeIntervalSinceDate:self.intobackdate];
        [self resumetimer];
        
    }
    [self.locationmanager_longterm stopMonitoringSignificantLocationChanges];
    [self addLine];
    [self refreshText];
    //    [self.locationmanager stopMonitoringSignificantLocationChanges];
    //    [self.locationmanager startUpdatingLocation];
    
}

-(void)willResigActive{
    NSLog(@"::::>>>willResigActive");
    self.intobackdate = [NSDate date];
    self.intobackseconds = self.seconds;
    [self stoptimer];
    //    [self.locationmanager stopUpdatingLocation];
    //    [self.locationmanager startMonitoringSignificantLocationChanges];
    [self.locationmanager_longterm startMonitoringSignificantLocationChanges];
}

#pragma mark --------Auxiliary Method--------
-(void)startrunning{
    
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"YYYYMMddHHmmss";
    
    self.current_runid = [NSString stringWithFormat:@"%@%@",self.commondata.uid,[format stringFromDate:[NSDate date]]];
    self.runrecord = [NSEntityDescription insertNewObjectForEntityForName:@"RunRecord" inManagedObjectContext:self.context];
    self.runrecord.uid = self.commondata.uid;
    self.runrecord.type = [NSNumber numberWithInteger:self.runmode];
    self.runrecord.starttime = [NSDate date];
//    format.dateFormat=@"yyyy-MM";
//    self.runrecord.sectionIdentifier=[format stringFromDate:[NSDate date]];
    self.runrecord.starttimestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    self.runrecord.closed = [NSNumber numberWithInt:0];
    self.runrecord.pace = [NSNumber numberWithFloat:0];
    self.runrecord.adddate = [NSDate date];
    //self.runrecord.issync = [NSNumber numberWithBool:NO];
    self.runrecord.running_id = self.current_runid;
    self.runrecord.totalcalories = @0;
    self.runrecord.totaldistance = @0;
    self.runrecord.totalstep = @0;
    self.runrecord.totaltime = @0;
    self.runrecord.macid = @"";
    //NSLog(@"record = %@",self.runrecord);
    self.runrecord.issync = [NSNumber numberWithBool:NO];
    self.runrecord.memberid = self.commondata.memberid;
    //////////for healthkit/////////////
    self.runrecord.issynchealthkit = [NSNumber numberWithBool:NO];
    
    self.currentpace = 0;
    self.currentdistance = 0;
    self.currentstep = 0;
    self.currentcal = 0;
    [self starttimer];
    [self save2DB];
    
}

-(void)save2DB{
    [self.context performBlockAndWait:^{
        NSError *error;
        if (![self.context save:&error])
        {
            // handle error
            NSLog(@"context save error:%@",error);
        }
        
        // save parent to disk asynchronously
        [self.context.parentContext performBlockAndWait:^{
            NSError *error;
            if (![self.context.parentContext save:&error])
            {
                // handle error
                NSLog(@"self.parentcontext save error:%@",error);
            }
        }];
    }];
}

-(void)refreshText{
    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
        NSMutableAttributedString* str_distance = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",self.currentdistance/1000.0] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:50]}];
        [str_distance appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_KM", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}]];
        self.labeldistance.attributedText = str_distance;
        
        if (self.currentdistance == 0) {
            self.currentpace = 0;
        }else{
            //self.currentpace = (1/((self.currentdistance/1000.0)/(self.seconds/3600.0)))*3600;
            //self.currentpace = (self.currentdistance/1000.0)/(self.seconds/3600.0);
            self.currentpace = (self.seconds)/(self.currentdistance/1000.0);
        }
        //self.labelspeed.text = [NSString stringWithFormat:@"%.2d'%.2d''",((int)self.currentpace)/60,((int)self.currentpace)%60];
        self.labelspeed.text=[NSString stringWithFormat:@"%d'%d''%@/%@",(int)self.currentpace/60,(int)self.currentpace%60,NSLocalizedString(@"UNIT_MIN", nil),NSLocalizedString(@"UNIT_KM", nil)];
        
        self.currentcal = (self.currentdistance / 1000.0) * self.commondata.weight * RUNNINGCALORIEQUOTE;
        self.labelcal.text = [NSString stringWithFormat:@"%.2f%@",self.currentcal,NSLocalizedString(@"UNIT_KCAL", nil)];
        
    }else{
        NSMutableAttributedString* str_distance = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",(self.currentdistance/1000.0)*KM2MILE] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:50]}];
        [str_distance appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_MILE", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}]];
        self.labeldistance.attributedText = str_distance;
        CGFloat showpace = 0;
        if (self.currentdistance == 0) {
            self.currentpace = 0;
            showpace = 0;
        }else{
            //            self.currentpace = (1/((self.currentdistance/1000.0)/(self.seconds/3600.0)))*3600;
            //            showpace = (1/(((self.currentdistance/1000.0)*KM2MILE)/(self.seconds/3600.0)))*3600;
            self.currentpace = (self.seconds/60.0)/(self.currentdistance/1000.0);
            showpace =(self.seconds/60.0)/((self.currentdistance/1000.0)*KM2MILE);
        }
        self.labelspeed.text=[NSString stringWithFormat:@"%d'%d''%@/%@",(int)showpace/60,(int)showpace%60,NSLocalizedString(@"UNIT_MIN", nil),NSLocalizedString(@"UNIT_MILE", nil)];
        
        self.currentcal = (self.currentdistance / 1000.0) * (self.commondata.weight/KG2LB) * RUNNINGCALORIEQUOTE;
        self.labelcal.text = [NSString stringWithFormat:@"%.2f%@",self.currentcal,NSLocalizedString(@"UNIT_KCAL", nil)];
    }
}

-(void)addLine{
    if ([self.arrayCoordinate count]<2) {
        return;
    }
    [self.mapview removeOverlays:self.overlayArray];
    [self.overlayArray removeAllObjects];
    
    __block CLLocationCoordinate2D* coordArray = new CLLocationCoordinate2D[[self.arrayCoordinate count]];
    [self.arrayCoordinate enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary* locinfo = (NSDictionary*)obj;
        NSNumber* lat = [locinfo objectForKey:@"lat"];
        NSNumber* lng = [locinfo objectForKey:@"lng"];
        coordArray[idx].latitude = lat.doubleValue;
        coordArray[idx].longitude = lng.doubleValue;
        
    }];
    MKPolyline* polygon = [MKPolyline polylineWithCoordinates:coordArray count:[self.arrayLoc count]];
    [self.mapview addOverlay:polygon];
    [self.overlayArray addObject:polygon];
    delete []coordArray;
}
#pragma mark ----Timer Method----
-(void)starttimer{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.seconds = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

-(void)resumetimer{
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

-(void)stoptimer{
    if (self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)onTimer:(NSNotification*)notify{
    self.seconds+=1;
    self.labeltime.text=[NSString stringWithFormat:@"%d:%.2d:%.2d\n", (int)(self.seconds)/3600,((int)(self.seconds)/60)%60,(int)(self.seconds)%60];
}
#pragma mark ----UI Method----
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
//    [self.mapview removeFromSuperview];
//    [self.view addSubview:self.mapview];
//    [self.view addSubview:_startView];
//    [self.view addSubview:_playView];
//    [self.view addSubview:_btn];
//    
//}

//- (void)dealloc
//{
//    NSLog(@"comeon");
////#if DEBUG
//    // Xcode8/iOS10 MKMapView bug workaround
//    static NSMutableArray* unusedObjects;
//    if (!unusedObjects)
//        unusedObjects = [NSMutableArray new];
//    [unusedObjects addObject:_mapview];
////#endif
//}


@end
