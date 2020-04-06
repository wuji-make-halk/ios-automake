//
//  LocationLoop.m
//  SXRBand
//
//  Created by qf on 14-7-31.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "LocationLoop.h"
@interface LocationLoop()
@property(nonatomic,assign) BOOL forRunning;
@property(nonatomic,strong) NSManagedObjectContext* context;
@property(nonatomic,strong) dispatch_queue_t dataqueue;
@property(nonatomic,strong) NSString* current_runid;
@property (strong, nonatomic) CLLocationManager* runmanager;
@end
@implementation LocationLoop
+(LocationLoop *)SharedInstance
{
    static LocationLoop *locationloop = nil;
    if (locationloop == nil) {
        locationloop = [[LocationLoop alloc] init];
    }
    return locationloop;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.commondata = [IRKCommonData SharedInstance];
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.dataqueue = dispatch_queue_create("com.czjk.datacenter", DISPATCH_QUEUE_SERIAL);
        
        self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.context.parentContext = appdelegate.managedObjectContext;

        self.forRunning = NO;
        self.locationmanager = [[CLLocationManager alloc] init];
        self.locationmanager.delegate = self;
        self.locationmanager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationmanager.distanceFilter = 1000.0f;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLocation) name:notify_key_start_location object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRunRequest) name:notify_key_start_running_request object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRunLocation) name:notify_key_start_running_location object:nil];
//#if CUSTOM_GOBAND ||CUSTOM_HIMOVE
        if ([self respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self performSelector:@selector(requestAlwaysAuthorization)];
        }
        double version = [[UIDevice currentDevice].systemVersion doubleValue];
        if (version>=8){
            
            [self.locationmanager requestAlwaysAuthorization];
        }
//#else
//        if ([self respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//            [self performSelector:@selector(requestAlwaysAuthorization)];
//        }
//        double version = [[UIDevice currentDevice].systemVersion doubleValue];
//        if (version>=8){
//            
//            [self.locationmanager requestAlwaysAuthorization];
//        }
//#endif
        [self startLocation];
    }
    return self;
}
-(void)startRunRequest{
    if (self.runmanager) {
        [self.runmanager stopUpdatingLocation];
        self.runmanager = nil;
    }
    self.runmanager =[[CLLocationManager alloc] init];
    self.runmanager.desiredAccuracy = kCLLocationAccuracyBest;
    self.runmanager.delegate = self;
//#if CUSTOM_GOBAND || CUSTOM_HIMOVE
    if ([self respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self performSelector:@selector(requestWhenInUseAuthorization)];
    }
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version>=8){
        
        [self.locationmanager requestWhenInUseAuthorization];
    }
//#else
//    
//    if ([self respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        [self performSelector:@selector(requestAlwaysAuthorization)];
//    }
//    double version = [[UIDevice currentDevice].systemVersion doubleValue];
//    if (version>=8){
//        
//        [self.locationmanager requestAlwaysAuthorization];
//    }
//#endif
    
    
}

-(void)startRunLocation{
    if ([CLLocationManager locationServicesEnabled]) {
        self.forRunning = YES;
        self.locationmanager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        [self.locationmanager startUpdatingLocation];
        
    }
}

-(void)startLocation{
    [self.locationmanager startUpdatingLocation];
    if (self.locationtimer) {
        [self.locationtimer invalidate];
        self.locationtimer = nil;
    }
    self.locationtimer=[NSTimer scheduledTimerWithTimeInterval:GET_LOCATION_TIME target:self selector:@selector(startLocation) userInfo:nil repeats:NO];
}

-(void)stopLocation{
    [self.locationmanager stopUpdatingLocation];
    if (self.locationtimer) {
        [self.locationtimer invalidate];
        self.locationtimer = nil;
    }
    
}
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"newlocation = %f,%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    NSLog(@"oldLocation = %f,%f",oldLocation.coordinate.latitude,oldLocation.coordinate.longitude);
    
    if (self.forRunning) {
        NSLog(@"%@",newLocation.description);
        NSLog(@"%@",oldLocation.description);
        
    }else{
        self.commondata.lastLat = newLocation.coordinate.latitude;
        self.commondata.lastLong = newLocation.coordinate.longitude;
        [self.commondata saveconfig];
        [manager stopUpdatingLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_location_update object:nil];
        //在地图上找位置
        CLGeocoder * geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if(error == nil){
                for (CLPlacemark* place in placemarks) {
                    NSLog(@"%@",place.country);
                    NSLog(@"%@",place.locality);
                    NSLog(@"%@",place.name);
                    self.commondata.lastCity = [place.locality copy];
                    self.commondata.lastLocationDetail = place.name;
                    [self.commondata saveconfig];
                    [[NSNotificationCenter defaultCenter]postNotificationName:notify_key_location_geacoder_update object:nil userInfo:nil];
                    
                }
            }
        }];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self upload_gps];
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;{
    NSLog(@"didFailWithError error = %@",error);
    
}
//////////////////////////////////////////
-(NSString*)getVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *label = [NSString stringWithFormat:@"%@ v%@ (build %@)", name, version, build];
    return [label stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
-(NSString*)getPhoneType{
    return [[UIDevice currentDevice] model];
}
-(NSString*)getPhoneOS{
    return [NSString stringWithFormat:@"%@:%@",[[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
}
-(NSString*)getSeqid{
    return [NSString stringWithFormat:@"%d", arc4random()/100000];
}
-(NSString*)getPhoneId{
//    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return  [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

-(void)upload_gps{
    NSDictionary* dict = nil;
    if (self.commondata.is_login) {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"gps_upload",@"action_cmd",[self getSeqid],@"seq_id",@{@"tid":self.commondata.token,@"vid":self.commondata.vid,@"long":[NSNumber numberWithFloat:self.commondata.lastLong],@"lat":[NSNumber numberWithFloat:self.commondata.lastLat],@"phone_id":[self getPhoneId],@"phone_os":[self getPhoneOS],@"phone_name":[self getPhoneOS],@"app_version":[self getVersion],@"phone_type":[self.commondata getPhoneType]},@"body", nil];
    }else{
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"gps_upload",@"action_cmd",[self getSeqid],@"seq_id",@{@"vid":self.commondata.vid,@"long":[NSNumber numberWithFloat:self.commondata.lastLong],@"lat":[NSNumber numberWithFloat:self.commondata.lastLat],@"phone_id":[self getPhoneId],@"phone_os":[self getPhoneOS],@"phone_name":[self getPhoneOS],@"app_version":[self getVersion],@"phone_type":[self.commondata getPhoneType]},@"body", nil];
    }
    NSError* error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,DATACENTER_URL]];

    NSLog(@"url = %@",url);
    NSLog(@"postdata = %@",dict);
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:url];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *postLength = [NSString stringWithFormat:@"%d",(int)[data length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //设置http-header:Content-Length
    NSHTTPURLResponse* urlResponse = nil;
    //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
    [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (error) {
        NSLog(@"network error!! try again later");
        return;
    }

}


@end
