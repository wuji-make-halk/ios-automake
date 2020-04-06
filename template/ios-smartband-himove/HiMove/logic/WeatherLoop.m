//
//  WeatherLoop.m
//  SXRBand
//
//  Created by qf on 14-7-31.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "WeatherLoop.h"

@implementation WeatherLoop
+(WeatherLoop *)SharedInstance
{
    static WeatherLoop *weatherloop = nil;
    if (weatherloop == nil) {
        weatherloop = [[WeatherLoop alloc] init];
    }
    return weatherloop;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.commondata = [IRKCommonData SharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocationUpdate:) name:notify_key_location_update object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBandkickoff:) name:notify_band_has_kickoff object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocationUVUpdate:) name:@"notify_key_UV_update" object:nil];
        
    }
    return self;
}

-(void)onBandkickoff:(NSNotification* )notify{
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_weather_update object:nil userInfo:nil];
}

-(void)onLocationUpdate:(NSNotification*)notify{
    //获取天气
    //第一步，创建url
    double timenow = [[NSDate date] timeIntervalSince1970];
    if ((timenow - self.commondata.lastWeatherTime) < READ_WEATHER_TIMEOUT) {
        NSLog(@"no need to update weather");
        return;
    }
    NSString* mesunit;
    if (self.commondata.measureunit == MEASURE_UNIT_US) {
        mesunit = @"imperial";
    }
    else{
        mesunit = @"metric";
    }
    
    //http://api.openweathermap.org/data/2.5/weather?lat=22.2700000&lon=113.4600000&APPID=7e1da2b76ad3ee8a75bf2568c6739738&units=metric
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:WEATHER_API_URL,self.commondata.lastLat, self.commondata.lastLong, WeatherAPIKey, mesunit]];
    NSLog(@"url = %@",url);
    //第二步，创建请求
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    //第三步，连接服务器
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
    NSLog(@"location ok");

}

-(void)onLocationUVUpdate:(NSNotification*)notify{
    
//    NSLog(@"进来没");
    
//    
//    //获取天气
//    //第一步，创建url
//    double timenow = [[NSDate date] timeIntervalSince1970];
//    if ((timenow - self.commondata.lastWeatherTime) < 1*60*60) {
//        NSLog(@"no need to update weather");
//        return;
//    }
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:WEATHER_UV_API_URL,self.commondata.lastLat, self.commondata.lastLong, WeatherAPIKey]];
//    NSLog(@"url = %@",url);
//    //第二步，创建请求
//    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
////    //第三步，连接服务器
////    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
////    [connection start];
////    NSLog(@"location ok");
//    
//    //获取单例对象NSURLSession
//    NSURLSession *session = [NSURLSession sharedSession];
//    //创建数据任务对象，发送请求
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        //获取状态码
//        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
//        NSLog(@"statusCode==%d",statusCode);
//        if (statusCode == 200) {
//            //解析 (NSData -> NSDictionary)
//            NSDictionary *UVDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            NSLog(@"UVDic==%@",UVDic);
//            
//            
//            
//            //回到主线程
////            dispatch_async(dispatch_get_main_queue(), ^{
////                //刷新tableView
////               
////                //解析头部视图需要的value;并更新头部视图
////                
////            });
//        }
//    }];
//    //执行任务
//    [task resume];
//    
    
    
    
}


-(void)procWeather:(NSDictionary*)result{
    if (self.weatherApiType == WEATHER_API_TYPE_OPENWEATHERORG) {
        NSDictionary* main = [result objectForKey:@"main"];
        if (main) {
            NSString* temp = [main objectForKey:@"temp"];
            if(temp){
                self.commondata.temp = temp.floatValue;
            }
            NSString* tempmax = [main objectForKey:@"temp_max"];
            if (tempmax){
                self.commondata.tempmax = tempmax.floatValue;
            }
            NSString* tempmin = [main objectForKey:@"temp_min"];
            if(tempmin){
                self.commondata.tempmin = tempmin.floatValue;
            }
        }
        NSArray* weathers = [result objectForKey:@"weather"];
        for (NSDictionary* weather in weathers){
            NSDictionary* weather = [weathers objectAtIndex:0];
            NSString* idstr = [weather objectForKey:@"id"];
            NSInteger weatherid = idstr.integerValue;
            switch (weatherid) {
                case 200:
                case 201:
                case 202:
                case 230:
                case 231:
                case 232:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_THUNDERRAIN]];
                    break;
                case 210:
                case 211:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_THONDERSTORM]];
                    break;
                case 212:
                case 221:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_HEAVYTHONDERSTORM]];
                    break;
                case 300:
                case 301:
                case 302:
                case 310:
                case 311:
                case 312:
                case 313:
                case 314:
                case 321:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_DRIZZLE]];
                    break;
                case 500:
                case 501:
                case 511:
                case 520:
                case 521:
                case 522:
                case 531:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_RAIN]];
                    break;
                    
                case 502:
                case 503:
                case 504:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_HEAVYRAIN]];
                    break;
                case 600:
                case 601:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_SNOW]];
                    break;
                case 602:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_HEAVYSNOW]];
                    break;
                case 611:
                case 612:
                case 615:
                case 616:
                case 620:
                case 621:
                case 622:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_SNOWRAIN]];
                    break;
                case 701:
                case 711:
                case 721:
                case 741:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_FLOG]];
                    break;
                case 731:
                case 751:
                case 761:
                case 762:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_SAND]];
                    break;
                case 771:
                case 781:
                case 900:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_TORNADO]];
                    break;
                case 800:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_CLEAR]];
                    break;
                case 801:
                case 802:
                case 803:
                case 804:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_CLOUDY]];
                    break;
                case 901:
                case 902:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_STORM]];
                    break;
                case 906:
                case 958:
                case 959:
                    [self.commondata.weathertype addObject:[NSNumber numberWithInt:WEATHER_TYPE_HAIL]];
                    break;
                default:
                    break;
            }
            
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_weather_update object:nil userInfo:result];
    
}

//////////////////////////////////////////////
//NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    //NSLog(@"didReceiveResponse%@",[res allHeaderFields]);
    self.recvdata = [NSMutableData data];
    
    
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.recvdata appendData:data];
    NSLog(@"");
}
//数据传完之后调用此方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *receiveStr = [[NSString alloc]initWithData:self.recvdata encoding:NSUTF8StringEncoding];
    NSLog(@"connectionDidFinishLoading :%@",receiveStr);
    NSError* error = nil;
    NSDictionary* result = [NSJSONSerialization JSONObjectWithData:self.recvdata options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"result==%@",result);
    [self procWeather:result];
    self.commondata.lastWeatherTime = [[NSDate date] timeIntervalSince1970];
    
    
}


-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError%@",[error localizedDescription]);
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(onLocationUpdate:) userInfo:nil repeats:NO];
}

/*
 {
 "dt": 1384279857,
 "id": 5391959,
 "main": {
 "humidity": 69,
 "pressure": 1025,
 "temp": 62.29,
 "temp_max": 69.01,
 "temp_min": 57.2
 },
 "name": "San Francisco",
 "weather": [
 {
 "description": "haze",
 "icon": "50d",
 "id": 721,
 "main": "Haze"
 }
 ]
 }
 */

@end
