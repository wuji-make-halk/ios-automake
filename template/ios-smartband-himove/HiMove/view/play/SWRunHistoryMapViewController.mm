//
//  SWRunHistoryMapViewController.m
//  SXRBand
//
//  Created by qf on 15/11/17.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import "SWRunHistoryMapViewController.h"
#import <MapKit/MapKit.h>
#import "mkMoveAnnotation.h"
#import "mkMoveAnnotationView.h"
#import "mkcustomPointAnnotation.h"
#import "mkimageAnnotation.h"
#import "mkcustomCalloutAnnotationView.h"
#import <CoreLocation/CoreLocation.h>
#import "SWTextAttachment.h"
#import "RunHistory+CoreDataClass.h"
#import "RunRecord+CoreDataClass.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface SWRunHistoryMapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>
    @property (nonatomic, strong) IRKCommonData* commondata;
    @property (nonatomic, strong) MKMapView* mapview;
    @property (nonatomic, strong) mkMoveAnnotation* currentanno;
    @property (nonatomic, strong) NSManagedObjectContext* context;
    @property (nonatomic, strong) NSManagedObjectContext* parentcontext;
    @property(nonatomic,strong) dispatch_queue_t dataqueue;
    @property(nonatomic,strong) NSMutableArray* arrayCoordinate;
    @property(nonatomic,strong) NSMutableArray* overlayArray;
    @property(nonatomic,strong) UILabel* labeldistance;
    @property(nonatomic,strong) UILabel* labeltime;
    @property(nonatomic,strong) UILabel* labelspeed;
    @property(nonatomic,strong) UILabel* labelcal;
    @property (nonatomic,strong)UIView *playView;
    @property (nonatomic,strong)UIView *bottomView;
    @property (nonatomic,strong)UIButton *btn;
    @end

@implementation SWRunHistoryMapViewController
    
-(void)viewWillAppear:(BOOL)animated{
    //    self.navigationController.navigationBar.barTintColor = self.commondata.colorHSKNav;
    [self.navigationController.navigationBar setTranslucent:NO];
    //[self.navigationController.navigationBar setHidden:YES];
    [self loadData];
    
    
}
    
-(void)viewWillDisappear:(BOOL)animated{
    //[self.mapview removeFromSuperview];
    self.mapview.delegate=nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    UIImageView * backimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 7, 22, 15)];
    backimg.image = [UIImage imageNamed:@"icon_back"];
    backimg.contentMode = UIViewContentModeScaleAspectFit;
    [btn addSubview:backimg];
    [btn addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton* btn_share = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    btn_share.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    btn_share.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btn_share setImage:[UIImage imageNamed:@"shareBtn"] forState:UIControlStateNormal];
    [btn_share addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_share];
    
    NSMutableParagraphStyle* p = [NSMutableParagraphStyle new];
    p.alignment = NSTextAlignmentCenter;
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"History", nil) attributes:@{NSFontAttributeName: [UIFont fontWithName:@"STHeitiSC-Medium" size:14], NSParagraphStyleAttributeName: p}];
    UILabel* titleview = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, str.size.width, str.size.height)];
    titleview.attributedText = str;
    titleview.textColor = [UIColor blackColor];
    self.navigationItem.titleView = titleview;
    
    self.commondata = [IRKCommonData SharedInstance];
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    self.dataqueue = dispatch_queue_create("com.walknote.datacenter", DISPATCH_QUEUE_SERIAL);
    self.context = appdelegate.managedObjectContext;
    self.arrayCoordinate = [[NSMutableArray alloc] init];
    self.overlayArray = [[NSMutableArray alloc] init];
    
    self.mapview = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), (CGRectGetHeight(self.view.frame)-65-49)*0.7)];
    self.mapview.delegate = self;
    [self.view addSubview:self.mapview];
    
    
    _playView = [[UIView alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(self.view.frame)-65-49)*0.7, CGRectGetWidth(self.view.frame), (CGRectGetHeight(self.view.frame)-65-49)*0.3) ];
    _playView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    _playView.userInteractionEnabled = YES;
    [self.view addSubview:_playView];
    
    self.labeldistance = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.view.frame)-15, CGRectGetHeight(_playView.frame)/3.0)];
    self.labeldistance.textColor = [UIColor whiteColor];
    [_playView addSubview:self.labeldistance];
    
    UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(self.labeldistance.frame)+5, CGRectGetWidth(self.view.frame)-30, 1.5)];
    sepView.backgroundColor=[UIColor whiteColor];
    [_playView addSubview:sepView];
    
    CGFloat labelwidth = CGRectGetWidth(sepView.frame)/3.0;
    NSArray *textArray;
    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
        textArray=@[[NSString stringWithFormat:@"%@",NSLocalizedString(@"Speed", nil)] ,[NSString stringWithFormat:@"%@",NSLocalizedString(@"Heat", nil)] ,NSLocalizedString(@"Duration", nil)];
    }else{
        textArray=@[[NSString stringWithFormat:@"%@",NSLocalizedString(@"Speed", nil)],[NSString stringWithFormat:@"%@",NSLocalizedString(@"Heat", nil)],NSLocalizedString(@"Duration", nil)];
    }
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
        egLabel.textAlignment=NSTextAlignmentCenter;
        egLabel.font=[UIFont systemFontOfSize:11];
        [labelArray addObject:egLabel];
    }
    self.labelspeed=(UILabel*)labelArray[0];
    [_playView addSubview:self.labelspeed];
    
    self.labelcal=(UILabel*)labelArray[1];
    [_playView addSubview:self.labelcal];
    
    self.labeltime=(UILabel*)labelArray[2];
    [_playView addSubview:self.labeltime];
    
    if (self.record) {
        if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
            NSMutableAttributedString* str_distance = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",self.record.totaldistance.doubleValue/1000.0] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:50]}];
            [str_distance appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_KM", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}]];
            self.labeldistance.attributedText = str_distance;
            
            self.labelspeed.text=[NSString stringWithFormat:@"%d'%d''%@/%@",(int)self.record.pace.doubleValue/60,(int)self.record.pace.doubleValue%60,NSLocalizedString(@"UNIT_MIN", nil),NSLocalizedString(@"UNIT_KM", nil)];
            self.labelcal.text =[NSString stringWithFormat:@"%.2f%@",self.record.totalcalories.doubleValue,NSLocalizedString(@"UNIT_KCAL", nil)];
            self.labeltime.text =[NSString stringWithFormat:@"%.2d:%.2d:%.2d",(int)(self.record.totaltime.doubleValue)/3600,((int)(self.record.totaltime.doubleValue)/60)%60,(int)(self.record.totaltime.doubleValue)%60];
        }else{
            NSMutableAttributedString* str_distance = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",(self.record.totaldistance.doubleValue/1000.0)*KM2MILE] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:50]}];
            [str_distance appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_MILE", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}]];
            self.labeldistance.attributedText = str_distance;
            self.labelspeed.text=[NSString stringWithFormat:@"%d'%d''%@/%@",(int)(self.record.pace.doubleValue/KM2MILE)/60,(int)(self.record.pace.doubleValue/KM2MILE)%60,NSLocalizedString(@"UNIT_MIN", nil),NSLocalizedString(@"UNIT_MILE", nil)];
            self.labelcal.text =[NSString stringWithFormat:@"%.2f%@",self.record.totalcalories.doubleValue,NSLocalizedString(@"UNIT_KCAL", nil)];
            self.labeltime.text =[NSString stringWithFormat:@"%.2d:%.2d:%.2d",(int)(self.record.totaltime.doubleValue)/3600,((int)(self.record.totaltime.doubleValue)/60)%60,(int)(self.record.totaltime.doubleValue)%60];
        }
    }
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
-(void)onClickBack:(UIButton*)sender{
    //[self.mapview removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}
    
-(void)loadData{
    self.arrayCoordinate = [[NSMutableArray alloc] init];
    if (self.record == nil) {
        return;
    }
    
    [self.mapview removeOverlays:self.overlayArray];
    [self.overlayArray removeAllObjects];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunHistory" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid IN {%@,%@} and running_id = %@", self.commondata.uid,@"",self.record.running_id];
    [fetchRequest setPredicate:predicate];
    // Set the batch size to a suitable number.
    //    [fetchRequest setFetchBatchSize:20];
    
    // Sort using the timeStamp property.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"adddate" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor ]];
    
    NSArray* result = [self.context executeFetchRequest:fetchRequest error:nil];
    if ([result count]<2) {
        return;
    }
    
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RunHistory* record = (RunHistory*)obj;
        NSLog(@"%f,%f,a=%f,c=%f",record.latitude.doubleValue,record.longitude.doubleValue,record.radius.doubleValue,record.direction.doubleValue);
        CLLocationCoordinate2D ptorigin = CLLocationCoordinate2DMake(record.latitude.doubleValue, record.longitude.doubleValue);
        CLLocationCoordinate2D pt = [self.commondata convert_wgs2gcj:ptorigin];
        [self.arrayCoordinate addObject:@{@"lat":[NSNumber numberWithDouble:pt.latitude],@"lng":[NSNumber numberWithDouble:pt.longitude]}];
    }];
    [self addLine];
    
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
    CLLocationCoordinate2D center;
    CGFloat maxdistance;
    if ([self.arrayCoordinate count]==1) {
        NSDictionary* coordinfo = [self.arrayCoordinate objectAtIndex:0];
        NSNumber* latitude = [coordinfo objectForKey:@"lat"];
        NSNumber* longitude = [coordinfo objectForKey:@"lng"];
        center = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
        maxdistance = 1000;
    }else{
        center = [self calc2DPolygonCentroid:coordArray count:(int)[self.arrayCoordinate count]];
        maxdistance = [self calcMaxDistance:coordArray count:(int)[self.arrayCoordinate count] center:center];
    }
    
    //           imageAnnotation* ano = [[imageAnnotation alloc] init];
    mkimageAnnotation* ano = [[mkimageAnnotation alloc] init];
    ano.coordinate = coordArray[0];;
    ano.title = @"iam here";
    [self.mapview addAnnotation:ano];
    
    mkimageAnnotation* anoe = [[mkimageAnnotation alloc] init];
    anoe.coordinate = coordArray[[self.arrayCoordinate count]-1];
    anoe.title = @"iam here";
    [self.mapview addAnnotation:anoe];
    
    
    MKPolyline* polygon = [MKPolyline polylineWithCoordinates:coordArray count:[self.arrayCoordinate count]];
    [self.mapview addOverlay:polygon];
    [self.overlayArray addObject:polygon];
    delete []coordArray;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, maxdistance*2, maxdistance*2);
    if (isnan(region.center.latitude)||isnan(region.center.longitude)) {
        NSLog(@"invalid region");
    }else{
        [self.mapview setRegion:region animated:YES];
    }
    
}
    
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
        polylineView.layer.shadowRadius = 1;
        polylineView.layer.shadowOffset = CGSizeMake(0, 0);
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
        
    }else if ([annotation isKindOfClass:[mkimageAnnotation class]]){
        mkcustomCalloutAnnotationView* annotationView = [[mkcustomCalloutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
        
        
        annotationView.imageview.image = [UIImage imageNamed:@"icon_anno_start.png"];
        
        annotationView.imageview.contentMode = UIViewContentModeScaleAspectFit;
        annotationView.frame = CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y, 40, 40);
        annotationView.imageview.frame = CGRectMake(3, 3, 40, 40);
        annotationView.imageview.layer.cornerRadius = 3;
        annotationView.imageview.clipsToBounds = YES;
        
        //       NSLog(@"%@",NSStringFromCGRect(annotationView.frame));
        //        annotationView.image = [UIImage imageNamed:@"icon_pin_red.png"];
        [annotationView setSelected:YES];
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
    
-(CGFloat)calcMaxDistance:(CLLocationCoordinate2D*)points count:(int)pointCount center:(CLLocationCoordinate2D)centerPoint{
    CGFloat maxdistance = 0;
    for(int i = 0; i< pointCount; i++){
        //        CLLocationCoordinate2D pt = CLLocationCoordinate2DMake(points, <#CLLocationDegrees longitude#>)
        MKMapPoint point1 = MKMapPointForCoordinate(points[i]);
        MKMapPoint point2 = MKMapPointForCoordinate(centerPoint);
        CLLocationDistance distance = MKMetersBetweenMapPoints(point1,point2);
        if (distance>maxdistance) {
            maxdistance = distance;
        }
        
    }
    
    
    return maxdistance;
}
    
-(CLLocationCoordinate2D)calc2DPolygonCentroid:(CLLocationCoordinate2D*)vertices count:(int)vertexCount{
    CLLocationCoordinate2D centroid = {0, 0};
    double signedArea = 0.0;
    double x0 = 0.0; // Current vertex X
    double y0 = 0.0; // Current vertex Y
    double x1 = 0.0; // Next vertex X
    double y1 = 0.0; // Next vertex Y
    double a = 0.0;  // Partial signed area
    
    // For all vertices except last
    int i=0;
    for (i=0; i<vertexCount-1; ++i)
    {
        x0 = vertices[i].latitude;
        y0 = vertices[i].longitude;
        x1 = vertices[i+1].latitude;
        y1 = vertices[i+1].longitude;
        a = x0*y1 - x1*y0;
        signedArea += a;
        centroid.latitude += (x0 + x1)*a;
        centroid.longitude += (y0 + y1)*a;
    }
    
    // Do last vertex
    x0 = vertices[i].latitude;
    y0 = vertices[i].longitude;
    x1 = vertices[0].latitude;
    y1 = vertices[0].longitude;
    a = x0*y1 - x1*y0;
    signedArea += a;
    centroid.latitude += (x0 + x1)*a;
    centroid.longitude += (y0 + y1)*a;
    
    signedArea *= 0.5;
    centroid.latitude /= (6.0*signedArea);
    centroid.longitude /= (6.0*signedArea);
    
    return centroid;
}
    

-(void)bottomBtnClick:(UIButton*)sender{
        NSArray* imageArray = @[[self screenshot2]];
        UIImage *image=[self screenshot2];
        //    （注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
        if (imageArray) {
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
            NSURL* url = [NSURL URLWithString:@"http://www.keeprapid.com"];
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
//                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
//                                                                                       message:nil
//                                                                                      delegate:nil
//                                                                             cancelButtonTitle:@"确定"
//                                                                             otherButtonTitles:nil];
//                                   [alertView show];
                                   break;
                               }
                               case SSDKResponseStateFail:
                               {
                                   
//                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
//                                                                                   message:[NSString stringWithFormat:@"%@",error.userInfo[@"error_message"]]
//                                                                                  delegate:nil
//                                                                         cancelButtonTitle:@"OK"
//                                                                         otherButtonTitles:nil, nil];
//                                   
//                                   [alert show];
                                   break;
                               }
                               case SSDKResponseStateCancel:
                               {
//                                   UIAlertView *alertViews = [[UIAlertView alloc] initWithTitle:@"分享已取消"
//                                                                                        message:nil
//                                                                                       delegate:nil
//                                                                              cancelButtonTitle:@"确定"
//                                                                              otherButtonTitles:nil];
//                                   [alertViews show];
                                   break;
                               }
                               default:
                               break;
                           }
                           
                       }];
            
        }
}

-(UIImage*)screenshot2{
    AppDelegate* appdelegate = [UIApplication sharedApplication].delegate;
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
//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
//    [self.mapview removeFromSuperview];
//    [self.view addSubview:self.mapview];
//    [self.view addSubview:_playView];
//    [self.view addSubview:_btn];
//}

- (void)dealloc{
    NSLog(@"comeon");
    //#if DEBUG
    // Xcode8/iOS10 MKMapView bug workaround
    static NSMutableArray* unusedObjects;
    if (!unusedObjects)
        unusedObjects = [NSMutableArray new];
    [unusedObjects addObject:_mapview];
    //#endif

}

@end
