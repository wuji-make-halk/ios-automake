//
//  ServerLogic.m
//  SXRBand
//
//  Created by qf on 14-9-1.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "ServerLogic.h"
#import "Alarm.h"
#import "TaskInfo+CoreDataClass.h"
#import "TaskManager.h"
#import "JPUSHService.h"


@implementation ServerLogic
+(ServerLogic *)SharedInstance
{
    static ServerLogic *s = nil;
    if (s == nil) {
        s = [[ServerLogic alloc] init];
    }
    return s;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.commondata = [IRKCommonData SharedInstance];
        self.mainloop = [MainLoop SharedInstance];
        self.blecontrol = [BleControl SharedInstance];
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        //self.managedObjectContext = appdelegate.managedObjectContext;
        self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.managedObjectContext.parentContext = appdelegate.managedObjectContext;
        
        self.dispatchqueue = dispatch_queue_create("com.keeprapid.serverlogic", DISPATCH_QUEUE_SERIAL);
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMemberInfo) name:notify_key_has_Login object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMemberInfo) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMemberInfo) name:notify_key_synckey_changed_memberinfo object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSyncKey) name:notify_key_has_Login object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSyncKey) name:UIApplicationWillEnterForegroundNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAuthInfo) name:notify_key_did_get_mac_id object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearData) name:notify_key_clear_all_data object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkOTA) name:notify_key_check_ota object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startOTA) name:notify_key_start_OTA object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkOTA) name:notify_key_did_finish_device_sync object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkOTAAfterSync) name:notify_key_did_finish_device_sync object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginJpush:) name:kJPFNetworkDidLoginNotification object:nil];

    }
    return self;
}
-(NSString*)getVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *label = [NSString stringWithFormat:@"%@ v%@ (build %@)", name, version, build];
    return label;
}
-(NSString*)getPhoneType{
    return [[UIDevice currentDevice] model];
}
-(NSString*)getPhoneOS{
    return [NSString stringWithFormat:@"%@:%@",[[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
}
-(NSString*)getPhoneName{
    return [[UIDevice currentDevice] name];
}
-(NSString*)getSeqid{
    return [NSString stringWithFormat:@"%d", arc4random()/100000];
}
-(NSString*)getPhoneId{
//    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return  [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}
-(NSString*)getDeviceName{
    CBPeripheral* currentperipheral = [self.blecontrol.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
    if (currentperipheral) {
        return [currentperipheral.name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }else{
        return NSLocalizedString(@"Gear_Unknown", nil);
    }
}
-(NSString*)gen_uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}

//-(void)sendPhoneInfo{
//    //return;
//    NSLog(@"ServerLogic::sendPhoneInfo");
//    if (self.commondata.is_login) {
//        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"update_phone_info",@"action_cmd",[self getSeqid],@"seq_id",self.commondata.token,@"running_passport", @{@"phone_type":[self getPhoneType] ,@"phone_os_version":[self getPhoneOS], @"phone_app_version":[self getVersion],@"phone_type":[self.commondata getPhoneType]},@"action_body", nil];
//        NSError* error = nil;
//        NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//        
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,IPSVR_URL]];
//        NSLog(@"url = %@",url);
//        //第二步，创建请求
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
//        [request setURL:url];
//        [request setHTTPBody:data];
//        [request setHTTPMethod:@"POST"];
//        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//        //设置http-header:Content-Length
//        NSString *postLength = [NSString stringWithFormat:@"%d",[data length]];
//        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//        [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
//        [request setTimeoutInterval:60];
//        //第三步，连接服务器
//        NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
//        [connection start];
//        NSLog(@"sendPhoneInfo ok");
//
//    }
//}
//
//
/////////////////////////////////////////////////
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
//    NSLog(@"didReceiveResponse%@",[res allHeaderFields]);
//    self.recvdata = [NSMutableData data];
//    
//    
//    
//}
//-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    [self.recvdata appendData:data];
//}
////数据传完之后调用此方法
//-(void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    NSString *receiveStr = [[NSString alloc]initWithData:self.recvdata encoding:NSUTF8StringEncoding];
//    NSLog(@"connectionDidFinishLoading :%@",receiveStr);
//    NSError* error = nil;
//    if (self.recvdata != nil) {
//        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:self.recvdata options:NSJSONReadingMutableLeaves error:&error];
//        NSLog(@"%@",result);
//        [self procData:result];
//
//    }
//    
//}
//
//
//-(void)connection:(NSURLConnection *)connection
// didFailWithError:(NSError *)error
//{
//    NSLog(@"didFailWithError%@",[error localizedDescription]);
//    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(sendPhoneInfo) userInfo:nil repeats:NO];
//}
//
//-(void)procData:(NSDictionary*)result{
//    NSString* error = [result objectForKey:@"error"];
//    if (error) {
//        if ([error isEqualToString:@"OK"]) {
//            NSLog(@"update phone info OK");
//        }else{
//            [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(sendPhoneInfo) userInfo:nil repeats:NO];
//        }
//      
//    }
//}

-(void)getAuthInfo{
    NSLog(@"getAuthInfo");
    if (self.commondata.current_macid == nil || [self.commondata.current_macid isEqual:@""]) {
        NSLog(@"NO current_mac");
        return;
    }
    NSDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bonginfo == nil || ![bonginfo.allKeys containsObject:BONGINFO_KEY_BLEADDR]) {
        return ;
    }
    
    if ([bonginfo.allKeys containsObject:BONGINFO_KEY_AUTHEXPIRE]) {
        NSDate* date = [bonginfo objectForKey:BONGINFO_KEY_AUTHEXPIRE];
        if ([date timeIntervalSinceNow]>0) {
            NSLog(@" auth not expired");
            return;
        }
    }

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              PROTOCOL_VERSION,ACTION_KEY_VERSION,
                              ACTION_CMD_GEARAUTH,ACTION_KEY_CMDNAME,
                              [self getSeqid],ACTION_KEY_SEQID,
                              @{
                                ACTION_KEY_TID:self.commondata.token,
                                ACTION_KEY_VID:self.commondata.vid,
                                ACTION_KEY_APPLANG:NSLocalizedString(@"GetBackPasswordLang", nil),
                                ACTION_KEY_SYSLANG:[IRKCommonData getSysLanguage],
                                ACTION_KEY_NATION:[IRKCommonData getCountryCode],
                                ACTION_KEY_NATIONCODE:[IRKCommonData getCountryNum],
                                ACTION_KEY_MACID:self.commondata.current_macid,
                                ACTION_KEY_PHONEID:[self getPhoneId],
                                ACTION_KEY_PHONEOS:[self getPhoneOS],
                                ACTION_KEY_PHONENAME:[self getPhoneName],
                                ACTION_KEY_DEVICENAME:[self getDeviceName],
                                ACTION_KEY_PHONETYPE:[self.commondata getPhoneType]},ACTION_KEY_BODY, nil];
        
        NSString* url =[NSString stringWithFormat:@"%@%@",SERVER_URL,GEARCENTER_URL];
        NSLog(@"url = %@",url);
        NSLog(@"postdata = %@",dict);
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"getAuthInfo JSON: %@", responseObject);
            NSDictionary* respjson = (NSDictionary*)responseObject;
            NSDictionary* body = [respjson objectForKey:RESPONE_KEY_BODY];
            NSString* errocode = [respjson objectForKey:RESPONE_KEY_ERRORCODE];
            if (body == nil) {
                NSLog(@"getAuthInfo error: no body");
                return;
            }
            NSInteger auth_flag = -1;
            if ([body.allKeys containsObject:RESPONE_KEY_AUTHFLAG]) {
                NSNumber* number = [body objectForKey:RESPONE_KEY_AUTHFLAG];
                auth_flag = number.integerValue;
            }
            if (auth_flag != 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //通知用户需要登陆
                    [self procAuth:auth_flag errorcode:errocode];
                });
            }else{
                self.commondata.forbbiden_flag = 0;
                [self.commondata saveconfig];
                
                NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
                [bonginfo setObject:[[NSDate date] dateByAddingTimeInterval:7*24*60*60]  forKey:BONGINFO_KEY_AUTHEXPIRE];
                [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
                
            }

            
            if([errocode isEqualToString:ERROR_CODE_TOKENOOS]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //通知用户需要登陆
                    [self notifyOOS];
                    
                });
                
                
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"getAuthInfo error= %@",error);
        }];


        //nation_code
        //app_lang
        //sys_lang
//        NSError* error = nil;
//        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"gear_auth",@"action_cmd",[self getSeqid],@"seq_id",@{@"tid":self.commondata.token,@"vid":self.commondata.vid,@"app_lang":NSLocalizedString(@"GetBackPasswordLang", nil),@"sys_lang":[IRKCommonData getSysLanguage],@"nation":[IRKCommonData getCountryCode],@"nation_code":[IRKCommonData getCountryNum],@"mac_id":self.commondata.current_macid,@"phone_id":[self getPhoneId],@"phone_os":[self getPhoneOS],@"phone_name":[self getPhoneName],@"device_name":[self getDeviceName],@"phone_type":[self.commondata getPhoneType]},@"body", nil];
//        NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//        
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,GEARCENTER_URL]];
//        NSLog(@"url = %@",url);
//        NSLog(@"postdata = %@",dict);
//        //第二步，创建请求
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
//        [request setURL:url];
//        [request setHTTPBody:data];
//        [request setHTTPMethod:@"POST"];
//        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//        NSString *postLength = [NSString stringWithFormat:@"%d",[data length]];
//        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//        //设置http-header:Content-Length
//        NSHTTPURLResponse* urlResponse = nil;
//        //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
//        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
//        if (error) {
//            NSLog(@"network error!! try again later");
//            //            [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getMemberInfo) userInfo:nil repeats:NO];
//            return;
//        }
//        NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"gear_auth result:%@",result);
//        if (result == nil) {
//            NSLog(@"result is nil");
//            return;
//        }
//        if(responseData == nil){
//            NSLog(@"responseData is nil");
//            return;
//        }
//        NSDictionary* respjson = [NSJSONSerialization
//                                  JSONObjectWithData:responseData //1
//                                  options:NSJSONReadingAllowFragments
//                                  error:&error];
//        if (error) {
//            NSLog(@"gear_auth info decode json ERROR!!");
//            return;
//            
//        }
//        NSString* errocode = [respjson objectForKey:@"error_code"];
//        if (errocode == nil) {
//            NSLog(@"gear_auth has no Errorcode!!");
//            return;
//        }
//        
//        
//        NSDictionary* body = [respjson objectForKey:@"body"];
//        NSArray* keys = [body allKeys];
//        NSInteger auth_flag = -1;
//        if ([keys containsObject:@"auth_flag"]) {
//            NSNumber* number = [body objectForKey:@"auth_flag"];
//            auth_flag = number.integerValue;
//        }
//        
//        NSString* owenrname = nil;
//        if ([keys containsObject:@"bind_username"]) {
//            owenrname = [body objectForKey:@"bind_username"];
//        }
//        if (auth_flag != 0) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //通知用户需要登陆
//                [self procAuth:auth_flag errorcode:errocode];
//            });
//        }else{
//            self.commondata.forbbiden_flag = 0;
//            [self.commondata saveconfig];
//            
//            NSMutableDictionary* bonginfo1 = [self.commondata getBongInformation:self.commondata.lastBongUUID];
//            [bonginfo1 setObject:[[NSDate date] dateByAddingTimeInterval:24*60*60]  forKey:BONGINFO_KEY_AUTHEXPIRE];
//            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo1];
//
//        }
//        
//            //        [self onClickGoback:nil];
//        if([errocode isEqualToString:ERROR_CODE_TOKENOOS]){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //通知用户需要登陆
//                [self notifyOOS];
//                
//            });
//        }
    });
    

}
-(void)getSyncKey{
    if (self.commondata.is_login == NO) {
        NSLog(@"getsync key need login state.");
        return;
    }
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString* url = [NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL];
    NSDictionary* paramlist = @{ACTION_KEY_CMDNAME:ACTION_CMD_QUERYSYNC,
                                ACTION_KEY_VERSION:PROTOCOL_VERSION,
                                ACTION_KEY_SEQID:[self getSeqid],
                                ACTION_KEY_BODY:@{
                                        ACTION_KEY_VID:self.commondata.vid,
                                        ACTION_KEY_TID:self.commondata.token}
                                };
    [manager POST:url parameters:paramlist progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"getSyncKey JSON: %@", responseObject);
        NSDictionary* retdict = (NSDictionary*)responseObject;
        NSString* errcode = [retdict objectForKey:RESPONE_KEY_ERRORCODE];
        if (errcode){
            if([errcode isEqualToString:ERROR_CODE_OK]) {
                NSDictionary* body = [retdict objectForKey:RESPONE_KEY_BODY];
                if (body) {
                    [[TaskManager SharedInstance] CheckSyncKey:[body mutableCopy]];
                }
            }else if ([errcode isEqualToString:ERROR_CODE_TOKENOOS]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //通知用户需要登陆
                    [self notifyOOS];
                    
                });
                
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getSyncKey Error: %@", error);
    }];
    

}

-(void)getMemberInfo{
    NSLog(@"getMemberInfo");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if(self.commondata.is_login){
            
            NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  PROTOCOL_VERSION,ACTION_KEY_VERSION,
                                  ACTION_CMD_MEMBER_INFO,ACTION_KEY_CMDNAME,
                                  [self getSeqid],ACTION_KEY_SEQID,
                                  @{ACTION_KEY_TID:self.commondata.token,
                                    ACTION_KEY_VID:self.commondata.vid},ACTION_KEY_BODY, nil];
            //            NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
            NSString* url =[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL];
            NSLog(@"url = %@",url);
            NSLog(@"postdata = %@",dict);
            AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
            //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"getMemberInfo2 JSON: %@", responseObject);
                NSDictionary* respjson = (NSDictionary*)responseObject;
                NSString* errocode = [respjson objectForKey:RESPONE_KEY_ERRORCODE];
                
                if ([errocode isEqualToString:ERROR_CODE_OK]) {
                    NSDictionary* body = [respjson objectForKey:RESPONE_KEY_BODY];
                    if (body){
                        
                        [[TaskManager SharedInstance] CheckSyncKey:[body mutableCopy]];
                        [self updateUserInfotoCommonData:[body mutableCopy]];
 
                    }
                    
                }else if([errocode isEqualToString:ERROR_CODE_TOKENOOS]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //通知用户需要登陆
                        [self notifyOOS];
                        
                    });
                    
                    
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"getMemberInfo error= %@",error);
            }];

            
            
//            NSError* error = nil;
//            NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"member_info",@"action_cmd",[self getSeqid],@"seq_id",@{@"tid":self.commondata.token,@"vid":self.commondata.vid},@"body", nil];
//            NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//            
//            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL]];
//            NSLog(@"url = %@",url);
//            NSLog(@"postdata = %@",dict);
//            //第二步，创建请求
//            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
//            [request setURL:url];
//            [request setHTTPBody:data];
//            [request setHTTPMethod:@"POST"];
//            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//            NSString *postLength = [NSString stringWithFormat:@"%d",[data length]];
//            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//            //设置http-header:Content-Length
//            NSHTTPURLResponse* urlResponse = nil;
//            //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
//            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
//            if (error) {
//                NSLog(@"network error!! try again later");
//    //            [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getMemberInfo) userInfo:nil repeats:NO];
//                return;
//            }
//            NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//            NSLog(@"member_info result:%@",result);
//            if (result == nil) {
//                NSLog(@"result is nil");
//                return;
//            }
//            if(responseData == nil){
//                NSLog(@"responseData is nil");
//                return;
//            }
//            NSDictionary* respjson = [NSJSONSerialization
//                                      JSONObjectWithData:responseData //1
//                                      options:NSJSONReadingAllowFragments
//                                      error:&error];
//            if (error) {
//                NSLog(@"member info decode json ERROR!!");
//                return;
//                
//            }
//            NSString* errocode = [respjson objectForKey:@"error_code"];
//            if (errocode == nil) {
//                NSLog(@"member info has no Errorcode!!");
//                return;
//            }
//            if ([errocode isEqualToString:ERROR_CODE_OK]) {
//                
//                NSDictionary* body = [respjson objectForKey:@"body"];
//                NSArray* users = (NSArray*)[body objectForKey:@"userinfo"];
//                //删除所有本地数据
//                [self removeAllUser:self.commondata.lastLoginUsername];
//                
//                if ([users count] == 0) {
//                    //如果是0用户，则自己创建一个新账号
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//                        [self addNewUser];
//                        
//                    });
//                }else{
//                    //取当前self.commondata.uid的用户或者是第一个user用户
//                    BOOL addflag = NO;
//                    for (int i = 0; i<[users count]; i++){
//                        
//                        NSMutableDictionary* userinfo = [[NSMutableDictionary alloc] initWithDictionary: users[i]];
//                        NSArray* keys = [userinfo allKeys];
//                        if ([keys containsObject:@"name"]) {
//                            
//                            NSString* name = [userinfo objectForKey:@"name"];
//                            self.commondata.nickname = name;
//                            [self.commondata saveconfig];
//                            
//                            NSString* namedecode = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)name, CFSTR(""), kCFStringEncodingUTF8);
//                            [userinfo setObject:namedecode forKey:@"name"];
//                        }
////                        [self updateUserInfotoDB:userinfo];
//                        NSString* tempuid = [userinfo objectForKey:@"uid"];
//                        if ([self.commondata.uid isEqualToString:tempuid]) {
//                            [self updateUserInfotoCommonData:userinfo];
//                            addflag = YES;
//                        }
//                        
//                        
//                        
//                    }
//                    if (addflag == NO){
////                        NSMutableDictionary* userinfo = [users objectAtIndex:0];
//                        NSMutableDictionary* userinfo = [[NSMutableDictionary alloc] initWithDictionary: users[0]];
//                        NSArray* keys = [userinfo allKeys];
//                        if ([keys containsObject:@"name"]) {
//                            NSString* name = [userinfo objectForKey:@"name"];
//                            NSString* namedecode = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)name, CFSTR(""), kCFStringEncodingUTF8);
//                            [userinfo setObject:namedecode forKey:@"name"];
//                        }
//                        [self updateUserInfotoCommonData:userinfo];
//                    }
//                    
//                }
//                
//                
//                //        [self onClickGoback:nil];
//            }else if([errocode isEqualToString:ERROR_CODE_TOKENOOS]){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    //通知用户需要登陆
//                    [self notifyOOS];
//
//                });
//            }else{
//                NSLog(@"error = %@ ",NSLocalizedString(errocode, nil));
//            }

            
        }
    });
    
}

/////////////////////////////////////////
-(void)notifyOOS{
    self.commondata.is_login = NO;
    self.commondata.uid = @"";
    self.commondata.has_custom_headimage = NO;
    self.commondata.token = @"";
    self.commondata.is_memberinfo_change = NO;
    [self.commondata saveconfig];

//    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login_Error", nil) message:NSLocalizedString(ERROR_CODE_TOKENOOS, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
//#if CUSTOM_PUZZLE || CUSTOM_NOMI || CUSTOM_HIMOVE
//#else
//    [alertview show];
//#endif
}

//-(void)addNewUser{
//    NSString* uuid = [self gen_uuid];
//    NSError* error = nil;
//    NSString* username = [self.commondata.lastLoginUsername stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"user_add",@"action_cmd",[self getSeqid],@"seq_id",@{@"tid":self.commondata.token,@"vid":self.commondata.vid,@"uid":uuid,@"name":username,@"gender":@"1",@"height":[NSNumber numberWithFloat:DEFAULT_HEIGHT],@"weight":[NSNumber numberWithFloat:DEFAULT_WEIGHT],@"stride":[NSNumber numberWithFloat:DEFAULT_STRIDE],@"bloodtype":DEFAULT_BLOODTYPE,@"birth":DEFAULT_BIRTH,@"gear_type":GEAR_TYPE},@"body", nil];
//    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL]];
//    NSLog(@"url = %@",url);
//    NSLog(@"postdata = %@",dict);
//    //第二步，创建请求
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
//    [request setURL:url];
//    [request setHTTPBody:data];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    NSString *postLength = [NSString stringWithFormat:@"%d",[data length]];
//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    //设置http-header:Content-Length
//    NSHTTPURLResponse* urlResponse = nil;
//    //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
//    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
//    if (error) {
//        NSLog(@"network error!! try again later");
//        return;
//    }
//    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"user_add result:%@",result);
//    if (result == nil) {
//        NSLog(@"result is nil");
//        return;
//    }
//    if(responseData == nil){
//        NSLog(@"responseData is nil");
//        return;
//    }
//    NSDictionary* respjson = [NSJSONSerialization
//                              JSONObjectWithData:responseData //1
//                              options:NSJSONReadingAllowFragments
//                              error:&error];
//    if (error) {
//        NSLog(@"user_add decode json ERROR!!");
//        return;
//        
//    }
//    NSString* errocode = [respjson objectForKey:@"error_code"];
//    if (errocode == nil) {
//        NSLog(@"user_add has no Errorcode!!");
//        //使用默认数据
//        [self setDefaultUser];
//        return;
//    }
//    if ([errocode isEqualToString:ERROR_CODE_OK]) {
//        NSMutableDictionary* userinfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:uuid,@"uid",self.commondata.lastLoginUsername,@"name",@"1",@"gender",[NSNumber numberWithFloat:DEFAULT_HEIGHT],@"height",[NSNumber numberWithFloat:DEFAULT_WEIGHT],@"weight",[NSNumber numberWithFloat:DEFAULT_STRIDE],@"stride",DEFAULT_BLOODTYPE,@"bloodtype",DEFAULT_BIRTH,@"birth",GEAR_TYPE,@"gear_type",nil];
//        
////        [self updateUserInfotoDB:userinfo];
//        [self updateUserInfotoCommonData:userinfo];
//        
//    }else if([errocode isEqualToString:ERROR_CODE_TOKENOOS]){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self notifyOOS];
//            [self setDefaultUser];
//        });
//    }else{
//        NSLog(@"error = %@ ",NSLocalizedString(errocode, nil));
//        [self setDefaultUser];
//
//    }
//
//
//}
//
//-(void)setDefaultUser{
//    self.commondata.male = 1;
//    self.commondata.weight = DEFAULT_WEIGHT;
//    self.commondata.height = DEFAULT_HEIGHT;
//    self.commondata.stride = DEFAULT_STRIDE;
//    self.commondata.birthyear = DEFAULT_BIRTH;
//    self.commondata.bloodtype = DEFAULT_BLOODTYPE;
//    self.commondata.nickname = NSLocalizedString(@"Default_Nickname", nil);
//    
//    [self.commondata saveconfig];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_member_info object:nil];
//    });
//    
//}
//
//-(void)updateUserInfotoDB:(NSMutableDictionary*)userinfo{
//    NSLog(@"updateUserInfotoDB::%@",userinfo);
//    NSError* error = nil;
//    NSArray* keys = [userinfo allKeys];
//    NSString* uid;
//    NSString* headimg_url;
//    NSString* user_name;
//    
//    if ([keys containsObject:@"uid"]) {
//        uid = (NSString*)[userinfo objectForKey:@"uid"];
//    }else{
//        NSLog(@"updateUserInfotoDB No UID error" );
//        return;
//    }
//    
//    if ([keys containsObject:@"name"]) {
//        user_name = [userinfo objectForKey:@"name"];
//    }else{
//        user_name = self.commondata.lastLoginUsername;
//    }
//    
//    if ([keys containsObject:@"img_url"]) {
//        headimg_url = [userinfo objectForKey:@"img_url"];
//    }else{
//        headimg_url = @"";
//    }
//    NSData* data = [NSJSONSerialization dataWithJSONObject:userinfo options:NSJSONWritingPrettyPrinted error:&error];
//    NSString* userprofile = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MemberInfo" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    // Specify criteria for filtering which objects to fetch
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"member_name = %@ and user_id = %@", self.commondata.lastLoginUsername, uid];
//    
//    [fetchRequest setPredicate:predicate];
//    // Specify how the fetched objects should be sorted
//    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
//        MemberInfo* record = [NSEntityDescription insertNewObjectForEntityForName:@"MemberInfo" inManagedObjectContext:self.managedObjectContext];
//        record.member_name = [self.commondata.lastLoginUsername copy];
//        record.user_name = [user_name copy];
//        record.headimgurl = [headimg_url copy];
//        record.user_profile = [userprofile copy];
//        record.user_id = uid;
//        NSLog(@"new record = %@",record);
//    }
//    else{
//        MemberInfo* record = [fetchedObjects objectAtIndex:0];
//        NSLog(@"old record = %@",record);
//        record.user_name = [user_name copy];
//        record.headimgurl = [headimg_url copy];
//        record.user_profile = [userprofile copy];
//        NSLog(@"update record = %@",record);
//    }
//    //[self.managedObjectContext save:&error];
//    [self saveDB];
//}

-(void)updateUserInfotoCommonData:(NSMutableDictionary*)userinfo{
//    NSLog(@"updateUserInfotoCommonData::%@",userinfo);

    NSArray* keys = [userinfo allKeys];
    NSNumber* weight;
    NSNumber* height;
    NSNumber* stride;
    NSString* gender;

    if ([keys containsObject:@"uid"]) {
        self.commondata.uid = (NSString*)[userinfo objectForKey:@"uid"];
        
//        [self.commondata updateHeadNameWithUid:self.commondata.uid];
    }else{
        self.commondata.uid = @"";
    }
    if ([keys containsObject:@"memberid"]) {
        self.commondata.memberid = (NSString*)[userinfo objectForKey:@"memberid"];
        
    }else{
        self.commondata.memberid = @"";
    }
    
    if ([keys containsObject:@"height"]) {
        height = (NSNumber*)[userinfo objectForKey:@"height"];
        self.commondata.height = height.floatValue;
    }else{
        self.commondata.height = DEFAULT_HEIGHT;
    }

    if ([keys containsObject:@"gender"]) {
        gender = [userinfo objectForKey:@"gender"];
        if ([gender isEqual:@"1"]) {
            self.commondata.male = 1;
        }else{
            self.commondata.male = 2;
        }
    }else{
        self.commondata.male = 1;
    }

    if ([keys containsObject:@"weight"]) {
        weight = (NSNumber*)[userinfo objectForKey:@"weight"];
        self.commondata.weight = weight.floatValue;
    }else{
        self.commondata.weight = DEFAULT_WEIGHT;
    }
    
    if ([keys containsObject:@"stride"]) {
        stride = (NSNumber*)[userinfo objectForKey:@"stride"];
        self.commondata.stride = stride.floatValue;
    }else{
        self.commondata.stride = DEFAULT_STRIDE;
    }

    if ([keys containsObject:@"bloodtype"]) {
        self.commondata.bloodtype = (NSString*)[userinfo objectForKey:@"bloodtype"];
    }else{
        self.commondata.bloodtype = DEFAULT_BLOODTYPE;
    }

    if ([keys containsObject:@"birth"]) {
        self.commondata.birthyear = (NSString*)[userinfo objectForKey:@"birth"];
    }else{
        self.commondata.birthyear = DEFAULT_BIRTH;
    }
    
    if ([keys containsObject:@"name"]) {
        NSString* name = (NSString*)[userinfo objectForKey:@"name"];
        NSString* namedecode = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)name, CFSTR(""), kCFStringEncodingUTF8);
        self.commondata.nickname = namedecode;
    }else{
        self.commondata.nickname = @"";
    }
    
    if ([keys containsObject:@"headimg"]) {
        NSString* img_url = (NSString*)[userinfo objectForKey:@"headimg"];
        if (![img_url isEqualToString:@""]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:img_url]];
                NSString *filename = [NSString stringWithFormat:@"%@.jpg",self.commondata.uid];                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
                
                [data writeToFile:filePath atomically:YES];
                self.commondata.has_custom_headimage = YES;
                self.commondata.headimg_url = [filename copy];
                [self.commondata saveconfig];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_headimage object:nil];
                });
            });
        }
    }
    
    if ([keys containsObject:RESPONE_KEY_ALARMLIST]) {
        NSArray* alarmlist = [userinfo objectForKey:RESPONE_KEY_ALARMLIST];
        for (NSDictionary* alarminfo in alarmlist) {
            NSString* macid = [alarminfo objectForKey:RESPONE_KEY_MACID];
            NSInteger type = [[alarminfo objectForKey:RESPONE_KEY_TYPE] integerValue];
            NSInteger alarmid = [[alarminfo objectForKey:RESPONE_KEY_ALARMID] integerValue];
            NSInteger enable = [[alarminfo objectForKey:RESPONE_KEY_ENABLE] integerValue];
            NSString* uid = [alarminfo objectForKey:RESPONE_KEY_UID];
//            NSString* vid = [alarminfo objectForKey:RESPONE_KEY_VID];
            NSArray* alarmkeys = [alarminfo allKeys];
            NSDate* createtime;
            if ([alarmkeys containsObject: RESPONE_KEY_CREATETIME]  ) {
                NSDateFormatter* format = [[NSDateFormatter alloc] init];
                [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                [format setTimeZone:[NSTimeZone systemTimeZone]];
                
                format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSString* datestr = [alarminfo objectForKey:RESPONE_KEY_CREATETIME];
                createtime = [format dateFromString:datestr];
            }else{
                createtime = [NSDate date];
            }
            NSInteger hour;
            if ([alarmkeys containsObject: RESPONE_KEY_HOUR]  ) {
                hour = [[alarminfo objectForKey:RESPONE_KEY_HOUR] integerValue];
            }else{
                hour = 0;
            }
            
            NSInteger minute;
            if ([alarmkeys containsObject: RESPONE_KEY_MINUTE]  ) {
                minute = [[alarminfo objectForKey:RESPONE_KEY_MINUTE] integerValue];
            }else{
                minute = 0;
            }
            
            NSDate* firedate;
            if ([alarmkeys containsObject: RESPONE_KEY_FIREDATE]  ) {
                id object =[alarminfo objectForKey:RESPONE_KEY_FIREDATE];
                if ([object isKindOfClass:[NSString class]]) {
                    NSDateFormatter* format = [[NSDateFormatter alloc] init];
                    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                    [format setTimeZone:[NSTimeZone systemTimeZone]];
                    
                    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                    NSString* firdatestr = [alarminfo objectForKey:RESPONE_KEY_FIREDATE] ;
                    
                    firedate = [format dateFromString:firdatestr];
                }else{
                    NSNumber* firedatetimeval = [alarminfo objectForKey:RESPONE_KEY_FIREDATE] ;
                    
                    firedate = [NSDate dateWithTimeIntervalSince1970:firedatetimeval.doubleValue];

                }
                
            }else{
                firedate = [NSDate date];
            }
            
            NSInteger weekly;
            if ([alarmkeys containsObject: RESPONE_KEY_WEEKLY]  ) {
                weekly = [[alarminfo objectForKey:RESPONE_KEY_WEEKLY] integerValue];
            }else{
                weekly = 0;
            }
            
            NSInteger snooze;
            if ([alarmkeys containsObject: RESPONE_KEY_SNOOZE]  ) {
                snooze = [[alarminfo objectForKey:RESPONE_KEY_SNOOZE] integerValue];
            }else{
                snooze = 0;
            }
            
            NSInteger snooze_repeat;
            if ([alarmkeys containsObject: RESPONE_KEY_SNOOZE_REPEAT]  ) {
                snooze_repeat = [[alarminfo objectForKey:RESPONE_KEY_SNOOZE_REPEAT] integerValue];
            }else{
                snooze_repeat = 0;
            }
            
            NSString* name = @"";
            if ([alarmkeys containsObject: RESPONE_KEY_NAME]  ) {
                name = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)[alarminfo objectForKey:RESPONE_KEY_NAME], CFSTR(""), kCFStringEncodingUTF8);
            }
            
            NSInteger day;
            if ([alarmkeys containsObject: RESPONE_KEY_DAY]  ) {
                day = [[alarminfo objectForKey:RESPONE_KEY_DAY] integerValue];
            }else{
                day = 1;
            }
            
            NSInteger repeat_hour;
            if ([alarmkeys containsObject: RESPONE_KEY_REPEATHOUR]  ) {
                repeat_hour = [[alarminfo objectForKey:RESPONE_KEY_REPEATHOUR] integerValue];
            }else{
                repeat_hour = 0;
            }
            
            NSInteger repeat_times;
            if ([alarmkeys containsObject: RESPONE_KEY_REPEATTIMES]  ) {
                repeat_times = [[alarminfo objectForKey:RESPONE_KEY_REPEATTIMES] integerValue];
            }else{
                repeat_times = 0;
            }
            
            NSInteger vib_number;
            if ([alarmkeys containsObject: RESPONE_KEY_VIBNUMBER]  ) {
                vib_number = [[alarminfo objectForKey:RESPONE_KEY_VIBNUMBER] integerValue];
            }else{
                vib_number = 0;
            }
            NSInteger vib_repeat;
            if ([alarmkeys containsObject: RESPONE_KEY_VIBREPEAT]  ) {
                vib_repeat = [[alarminfo objectForKey:RESPONE_KEY_VIBREPEAT] integerValue];
            }else{
                vib_repeat = 0;
            }
            
            NSInteger year;
            if ([alarmkeys containsObject: RESPONE_KEY_YEAR]  ) {
                year = [[alarminfo objectForKey:RESPONE_KEY_YEAR] integerValue];
            }else{
                year = 2015;
            }
            NSInteger month;
            if ([alarmkeys containsObject: RESPONE_KEY_MONTH]  ) {
                month = [[alarminfo objectForKey:RESPONE_KEY_MONTH] integerValue];
            }else{
                month = 1;
            }
            NSInteger repeat_schedule;
            if ([alarmkeys containsObject: RESPONE_KEY_REPEATSCEDUAL]  ) {
                repeat_schedule = [[alarminfo objectForKey:RESPONE_KEY_REPEATSCEDUAL] integerValue];
            }else{
                repeat_schedule = ALARM_REPEAT_SCHEDULE_NO_REPEAT;
            }
            
            NSInteger starthour;
            if ([alarmkeys containsObject: RESPONE_KEY_STARTHOUR]  ) {
                starthour = [[alarminfo objectForKey:RESPONE_KEY_STARTHOUR] integerValue];
            }else{
                starthour = 0;
            }
            
            NSInteger startminute;
            if ([alarmkeys containsObject: RESPONE_KEY_STARTMINUTE]  ) {
                startminute = [[alarminfo objectForKey:RESPONE_KEY_STARTMINUTE] integerValue];
            }else{
                startminute = 0;
            }
            
            NSInteger endhour;
            if ([alarmkeys containsObject: RESPONE_KEY_ENDHOUR]  ) {
                endhour = [[alarminfo objectForKey:RESPONE_KEY_ENDHOUR] integerValue];
            }else{
                endhour = 0;
            }
            
            NSInteger endminute;
            if ([alarmkeys containsObject: RESPONE_KEY_ENDMINUTE]  ) {
                endminute = [[alarminfo objectForKey:RESPONE_KEY_ENDMINUTE] integerValue];
            }else{
                endminute = 0;
            }
            
            
            NSError* error = nil;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            // Specify criteria for filtering which objects to fetch
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@ and type = %d and alarm_id = %d and macid = %@", uid, type, alarmid, macid];
            
            [fetchRequest setPredicate:predicate];
            // Specify how the fetched objects should be sorted
            NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil || [fetchedObjects count] == 0) {
                NSLog(@"no record add it ");
                Alarm* record = (Alarm*)[NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:self.managedObjectContext];
                record.uid = uid;
                record.macid = macid;
                record.type = [NSNumber numberWithInteger:type];
                record.name = name;
                record.createtime = createtime;
                record.alarm_id = [NSNumber numberWithInteger:alarmid];
                record.firedate = firedate;
                record.hour = [NSNumber numberWithInteger:hour];
                record.minute = [NSNumber numberWithInteger:minute];
                record.enable = [NSNumber numberWithInteger:enable];
                record.weekly = [NSNumber numberWithInteger:weekly];
                record.snooze = [NSNumber numberWithInteger:snooze];
                record.snooze_repeat = [NSNumber numberWithInteger:snooze_repeat];
                record.day = [NSNumber numberWithInteger:day];
                record.repeat_hour = [NSNumber numberWithInteger:repeat_hour];
                record.repeat_times = [NSNumber numberWithInteger:repeat_times];
                record.vib_number = [NSNumber numberWithInteger:vib_number];
                record.vib_repeat = [NSNumber numberWithInteger:vib_repeat];
                record.year = [NSNumber numberWithInteger:year];
                record.month = [NSNumber numberWithInteger:month];
                record.repeat_schedule = [NSNumber numberWithInteger:repeat_schedule];
                record.starthour = [NSNumber numberWithInteger:starthour];
                record.endhour = [NSNumber numberWithInteger:endhour];
                record.startminute = [NSNumber numberWithInteger:startminute];
                record.endminute = [NSNumber numberWithInteger:endminute];
                
            }
            else{
                NSLog(@"find obj" );
                Alarm* record = (Alarm*)[fetchedObjects objectAtIndex:0];
                record.uid = uid;
                record.macid = macid;
                record.type = [NSNumber numberWithInteger:type];
                record.name = name;
                record.createtime = createtime;
                record.alarm_id = [NSNumber numberWithInteger:alarmid];
                record.firedate = firedate;
                record.hour = [NSNumber numberWithInteger:hour];
                record.minute = [NSNumber numberWithInteger:minute];
                record.enable = [NSNumber numberWithInteger:enable];
                record.weekly = [NSNumber numberWithInteger:weekly];
                record.snooze = [NSNumber numberWithInteger:snooze];
                record.snooze_repeat = [NSNumber numberWithInteger:snooze_repeat];
                record.day = [NSNumber numberWithInteger:day];
                record.repeat_hour = [NSNumber numberWithInteger:repeat_hour];
                record.repeat_times = [NSNumber numberWithInteger:repeat_times];
                record.vib_number = [NSNumber numberWithInteger:vib_number];
                record.vib_repeat = [NSNumber numberWithInteger:vib_repeat];
                record.year = [NSNumber numberWithInteger:year];
                record.month = [NSNumber numberWithInteger:month];
                record.repeat_schedule = [NSNumber numberWithInteger:repeat_schedule];
                record.starthour = [NSNumber numberWithInteger:starthour];
                record.endhour = [NSNumber numberWithInteger:endhour];
                record.startminute = [NSNumber numberWithInteger:startminute];
                record.endminute = [NSNumber numberWithInteger:endminute];
            }
            //[self.managedObjectContext save:&error];
            [self saveDB];
        }
    }
    
    [self.commondata saveconfig];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_member_info object:nil];
    });
    
}

-(void)saveDB{
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error;
        if (![self.managedObjectContext save:&error])
        {
            // handle error
            NSLog(@"Datacenter::stepContext save error:%@",error);
        }
        
        // save parent to disk asynchronously
        [self.managedObjectContext.parentContext performBlockAndWait:^{
            NSError *error;
            if (![self.managedObjectContext.parentContext save:&error])
            {
                // handle error
                NSLog(@"Datacenter::managedObjectContext save error:%@",error);
            }
        }];
    }];
    
}

//-(void)removeAllUser:(NSString*)member_name{
//    NSError* error = nil;
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MemberInfo" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    // Specify criteria for filtering which objects to fetch
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"member_name = %@", member_name];
//    
//    [fetchRequest setPredicate:predicate];
//    // Specify how the fetched objects should be sorted
//    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
//        NSLog(@"no record need to delete");
//    }
//    else{
//        NSLog(@"need to delete obj = %@", fetchedObjects );
//        for (NSManagedObject* obj in fetchedObjects) {
//            [self.managedObjectContext deleteObject:obj];
//        }
//    }
//    //[self.managedObjectContext save:&error];
//    [self saveDB];
//
//}

-(void)procAuth:(NSInteger)auth_flag errorcode:(NSString*)ec{
    switch (auth_flag) {
        case 1:{
            [self.blecontrol disconnectDevice:0];
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AUTH_ERROR", nil) message:NSLocalizedString(@"AUTH_ERROR_FLAG_1", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            alertview.tag = 100;
            [alertview show];
            return;
        }
        case 2:
            [self.blecontrol disconnectDevice:0];
            break;
        case 3:
            self.commondata.forbbiden_flag = 1;
            [self.commondata saveconfig];
            break;
            
        default:
            break;
    }
    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AUTH_ERROR", nil) message:NSLocalizedString(ec, nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertview show];
}
//////////////////////////
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        exit(0); 
    }else if(alertView.tag == 101){
        if (buttonIndex == alertView.cancelButtonIndex) {
            NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
            [bonginfo setObject:[NSDate date] forKey:BONGINFO_KEY_LASTCANCELUPDATE_DATE];
            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
            return;
        }
//        else if (buttonIndex == alertView.firstOtherButtonIndex){
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_start_sync_history object:nil];
//        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_start_OTA object:nil];

        }
    }
}
/*
-(void)logout{
    if (self.commondata.is_login = NO) {
        return;
    }
    NSLog(@"logout now");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.commondata.is_login = NO;
        self.commondata.token = @"";
        self.commondata.uid = @"";
        self.commondata.headimg_url = @"";
        self.commondata.has_custom_headimage = NO;
        self.commondata.is_memberinfo_change = NO;
        self.commondata.weight = DEFAULT_WEIGHT;
        self.commondata.height = DEFAULT_HEIGHT;
        self.commondata.stride = DEFAULT_STRIDE;
        self.commondata.birthyear = DEFAULT_BIRTH;
        self.commondata.bloodtype = DEFAULT_BLOODTYPE;
        self.commondata.nickname = NSLocalizedString(@"Default_Nickname", nil);
        [self.commondata saveconfig];
        
        NSError* error = nil;
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"logout",@"action_cmd",[self getSeqid],@"seq_id",@{@"tid":self.commondata.token,@"vid":VID},@"body", nil];
        NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL]];
        NSLog(@"url = %@",url);
        NSLog(@"postdata = %@",dict);
        //第二步，创建请求
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
        [request setURL:url];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSString *postLength = [NSString stringWithFormat:@"%d",[data length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        //设置http-header:Content-Length
        NSHTTPURLResponse* urlResponse = nil;
        //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        if (error) {
            NSLog(@"network error!! try again later");
            
        }
        
        return;
        
    });
}
*/
-(void)clearData{
    //[self logout];
}




-(void)update_userinfo{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSString* name = [self.commondata.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString* gender;
        if (self.commondata.male == 1) {
            gender = @"1";
        }else{
            gender = @"2";
        }
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,ACTION_KEY_VERSION,
                              ACTION_CMD_MEMBER_UPDATE,ACTION_KEY_CMDNAME,
                              [self getSeqid],ACTION_KEY_SEQID,
                              @{ACTION_KEY_TID:self.commondata.token,
                                ACTION_KEY_VID:self.commondata.vid,
                                ACTION_KEY_UID:self.commondata.uid,
                                ACTION_KEY_NAME:name,
                                ACTION_KEY_GENDER:gender,
                                ACTION_KEY_HEIGHT:[NSString stringWithFormat:@"%.1f",self.commondata.height],
                                ACTION_KEY_WEIGHT:[NSString stringWithFormat:@"%.1f",self.commondata.weight],
                                ACTION_KEY_STRIDE:[NSString stringWithFormat:@"%.1f",self.commondata.stride ],
                                ACTION_KEY_BLOODTYPE:self.commondata.bloodtype,
                                ACTION_KEY_BIRTHDAY:self.commondata.birthyear},ACTION_KEY_BODY, nil];

        NSString* url =[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL];
        NSLog(@"url = %@",url);
        NSLog(@"postdata = %@",dict);
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"update_userinfo JSON: %@", responseObject);
            NSDictionary* respjson = (NSDictionary*)responseObject;
            NSString* errocode = [respjson objectForKey:RESPONE_KEY_ERRORCODE];
            
            if ([errocode isEqualToString:ERROR_CODE_OK]) {
                NSDictionary* body = [respjson objectForKey:RESPONE_KEY_BODY];
                if (body){
                    NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
                    if (synckey) {
                        NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
                        NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
                        NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
                        NSMutableDictionary* memberinfo = [self.commondata getMemberInfo:self.commondata.memberid];
                        [memberinfo setObject:syncvalue forKey:synckeystr];
                        [self.commondata setMemberInfo:self.commondata.memberid Information:memberinfo];
                        
                    }
                }
                
            }else if([errocode isEqualToString:ERROR_CODE_TOKENOOS]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //通知用户需要登陆
                    [self notifyOOS];
                    
                });
                
                
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"update_userinfo error= %@",error);
        }];
        

        
//        NSError* error = nil;
//        NSString* name = [self.commondata.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSString* gender;
//        if (self.commondata.male == 1) {
//            gender = @"1";
//        }else{
//            gender = @"2";
//        }
//        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,ACTION_KEY_VERSION,
//                              ACTION_CMD_UPDATE_USER,ACTION_KEY_CMDNAME,
//                              [self getSeqid],ACTION_KEY_SEQID,
//                              @{ACTION_KEY_TID:self.commondata.token,
//                                ACTION_KEY_VID:self.commondata.vid,
//                                ACTION_KEY_UID:self.commondata.uid,
//                                ACTION_KEY_NAME:name,
//                                ACTION_KEY_GENDER:gender,
//                                ACTION_KEY_HEIGHT:[NSString stringWithFormat:@"%.1f",self.commondata.height],
//                                ACTION_KEY_WEIGHT:[NSString stringWithFormat:@"%.1f",self.commondata.weight],
//                                ACTION_KEY_STRIDE:[NSString stringWithFormat:@"%.1f",self.commondata.stride ],
//                                ACTION_KEY_BLOODTYPE:self.commondata.bloodtype,
//                                ACTION_KEY_BIRTHDAY:self.commondata.birthyear},ACTION_KEY_BODY, nil];
//        
//        
//        NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//        
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL]];
//        NSLog(@"url = %@",url);
//        NSLog(@"postdata = %@",dict);
//        //第二步，创建请求
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
//        [request setURL:url];
//        [request setHTTPBody:data];
//        [request setHTTPMethod:@"POST"];
//        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//        NSString *postLength = [NSString stringWithFormat:@"%d",[data length]];
//        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//        //设置http-header:Content-Length
//        NSHTTPURLResponse* urlResponse = nil;
//        //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
//        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
//        if (error) {
//            NSLog(@"network error!! try again later");
//            return;
//        }
//        NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"user_add result:%@",result);
//        if (result == nil) {
//            NSLog(@"result is nil");
//            return;
//        }
//        if(responseData == nil){
//            NSLog(@"responseData is nil");
//            return;
//        }
//        NSDictionary* respjson = [NSJSONSerialization
//                                  JSONObjectWithData:responseData //1
//                                  options:NSJSONReadingAllowFragments
//                                  error:&error];
//        if (error) {
//            NSLog(@"user_add decode json ERROR!!");
//            return;
//            
//        }
//        NSString* errocode = [respjson objectForKey:@"error_code"];
//        if (errocode == nil) {
//            NSLog(@"user_add has no Errorcode!!");
//            //使用默认数据
//            return;
//        }
//        if ([errocode isEqualToString:ERROR_CODE_OK]) {
//            
//        }else{
//            NSLog(@"error = %@ ",NSLocalizedString(errocode, nil));
//            
//        }
//        
        
    });
}


-(void)update_usergoal{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,ACTION_KEY_VERSION,
                              ACTION_CMD_MEMBER_UPDATE,ACTION_KEY_CMDNAME,
                              [self getSeqid],ACTION_KEY_SEQID,
                              @{ACTION_KEY_TID:self.commondata.token,
                                ACTION_KEY_UID:self.commondata.uid,
                                ACTION_KEY_VID:self.commondata.vid,
                                ACTION_KEY_GOALCAL:[NSNumber numberWithFloat:self.commondata.target_calorie],
                                ACTION_KEY_GOALDISTANCE:[NSNumber numberWithFloat:self.commondata.target_distance],
                                ACTION_KEY_GOALSLEEP:[NSNumber numberWithDouble:self.commondata.target_sleeptime],
                                ACTION_KEY_GOALSTEPS:[NSNumber numberWithInteger:self.commondata.target_steps]},ACTION_KEY_BODY, nil];
        
        NSString* url =[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL];
        NSLog(@"url = %@",url);
        NSLog(@"postdata = %@",dict);
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"update_usergoal JSON: %@", responseObject);
            NSDictionary* respjson = (NSDictionary*)responseObject;
            NSString* errocode = [respjson objectForKey:RESPONE_KEY_ERRORCODE];
            
            if ([errocode isEqualToString:ERROR_CODE_OK]) {
                NSDictionary* body = [respjson objectForKey:RESPONE_KEY_BODY];
                if (body){
                    NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
                    if (synckey) {
                        NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
                        NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
                        NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
                        NSMutableDictionary* memberinfo = [self.commondata getMemberInfo:self.commondata.memberid];
                        [memberinfo setObject:syncvalue forKey:synckeystr];
                        [self.commondata setMemberInfo:self.commondata.memberid Information:memberinfo];
                        
                    }
                }
                
            }else if([errocode isEqualToString:ERROR_CODE_TOKENOOS]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //通知用户需要登陆
                    [self notifyOOS];
                    
                });
                
                
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"update_usergoal error= %@",error);
        }];
        

//        NSError* error = nil;
//        
//        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,ACTION_KEY_VERSION,
//                              ACTION_CMD_UPDATE_USER,ACTION_KEY_CMDNAME,
//                              [self getSeqid],ACTION_KEY_SEQID,
//                              @{ACTION_KEY_TID:self.commondata.token,
//                                ACTION_KEY_UID:self.commondata.uid,
//                                ACTION_KEY_VID:self.commondata.vid,
//                                ACTION_KEY_GOALCAL:[NSNumber numberWithFloat:self.commondata.target_calorie],
//                                ACTION_KEY_GOALDISTANCE:[NSNumber numberWithFloat:self.commondata.target_distance],
//                                ACTION_KEY_GOALSLEEP:[NSNumber numberWithDouble:self.commondata.target_sleeptime],
//                                ACTION_KEY_GOALSTEPS:[NSNumber numberWithInteger:self.commondata.target_steps]},ACTION_KEY_BODY, nil];
//        
//        NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//        
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL]];
//        NSLog(@"url = %@",url);
//        NSLog(@"postdata = %@",dict);
//        //第二步，创建请求
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
//        [request setURL:url];
//        [request setHTTPBody:data];
//        [request setHTTPMethod:@"POST"];
//        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//        NSString *postLength = [NSString stringWithFormat:@"%d",[data length]];
//        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//        //设置http-header:Content-Length
//        NSHTTPURLResponse* urlResponse = nil;
//        //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
//        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
//        if (error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Login_Error_No_network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
//                [alertview show];
//                
//            });
//            return;
//        }
//        NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"user_add result:%@",result);
//        if (result == nil) {
//            NSLog(@"result is nil");
//            return;
//        }
//        if(responseData == nil){
//            NSLog(@"responseData is nil");
//            return;
//        }
//        NSDictionary* respjson = [NSJSONSerialization
//                                  JSONObjectWithData:responseData //1
//                                  options:NSJSONReadingAllowFragments
//                                  error:&error];
//        if (error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", nil) message:NSLocalizedString(@"Login_Error_No_network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
//                [alertview show];
//                
//            });
//            return;
//            
//        }
//        NSString* errocode = [respjson objectForKey:@"error_code"];
//        if (errocode == nil) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Login_Error_No_network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
//                [alertview show];
//                
//            });
//            return;
//        }
//        if ([errocode isEqualToString:ERROR_CODE_OK]) {
//            
//        }else{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Login_Error_No_network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
//                [alertview show];
//                
//            });
//            return;
//            
//        }
//        
        
    });
    
}


-(void)logout{
    if (self.commondata.is_login == NO) {
        return;
    }
    NSLog(@"logout now");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.commondata.is_login = NO;
        self.commondata.token = @"";
        self.commondata.uid = @"";
        self.commondata.headimg_url = @"";
        self.commondata.has_custom_headimage = NO;
        self.commondata.is_memberinfo_change = NO;
        self.commondata.weight = DEFAULT_WEIGHT;
        self.commondata.height = DEFAULT_HEIGHT;
        self.commondata.stride = DEFAULT_STRIDE;
        self.commondata.birthyear = DEFAULT_BIRTH;
        self.commondata.bloodtype = DEFAULT_BLOODTYPE;
        self.commondata.nickname = NSLocalizedString(@"Default_Nickname", nil);
        self.commondata.lastBongUUID = nil;
        
        //把密码清空
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"" forKey:self.commondata.lastLoginUsername];
        [ud synchronize];
        
        [self.commondata saveconfig];
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              PROTOCOL_VERSION,ACTION_KEY_VERSION,
                              ACTION_CMD_LOGOUT,ACTION_KEY_CMDNAME,
                              [self getSeqid],ACTION_KEY_SEQID,
                              @{
                                ACTION_KEY_TID:self.commondata.token,
                                ACTION_KEY_VID:self.commondata.vid},ACTION_KEY_BODY, nil];
        
        NSString* url =[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL];
        NSLog(@"url = %@",url);
        NSLog(@"postdata = %@",dict);
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"logout JSON: %@", responseObject);
//            NSDictionary* respjson = (NSDictionary*)responseObject;
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"logout error= %@",error);
        }];
        
        
//        NSError* error = nil;
//        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"logout",@"action_cmd",[self getSeqid],@"seq_id",@{@"tid":self.commondata.token,@"vid":self.commondata.vid},@"body", nil];
//        NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//        
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL]];
//        NSLog(@"url = %@",url);
//        NSLog(@"postdata = %@",dict);
//        //第二步，创建请求
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
//        [request setURL:url];
//        [request setHTTPBody:data];
//        [request setHTTPMethod:@"POST"];
//        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//        NSString *postLength = [NSString stringWithFormat:@"%d",[data length]];
//        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//        //设置http-header:Content-Length
//        NSHTTPURLResponse* urlResponse = nil;
//        //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
//        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
//        if (error) {
//            NSLog(@"network error!! try again later");
//            
//        }
//        
//        return;
        
    });
}

-(NSMutableDictionary*)MakeAlarmActionBody:(Alarm*)alarminfo{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    if (alarminfo == nil) {
        return dict;
    }
    if (alarminfo.name != nil) {
        [dict setObject:alarminfo.name forKey:ACTION_KEY_NAME];
    }
    if (alarminfo.macid != nil) {
        [dict setObject:alarminfo.macid forKey:ACTION_KEY_MACID];
    }
    if (alarminfo.uid != nil) {
        [dict setObject:alarminfo.uid forKey:ACTION_KEY_UID];
    }
    if (alarminfo.type != nil) {
        [dict setObject:alarminfo.type forKey:ACTION_KEY_TYPE];
    }
    if (alarminfo.createtime != nil) {
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [format setTimeZone:[NSTimeZone systemTimeZone]];
        
        format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        [dict setObject:[format stringFromDate:alarminfo.createtime] forKey:ACTION_KEY_CREATETIME];
    }
    if (alarminfo.hour != nil) {
        [dict setObject:alarminfo.hour forKey:ACTION_KEY_HOUR];
    }
    if (alarminfo.minute != nil) {
        [dict setObject:alarminfo.minute forKey:ACTION_KEY_MINUTE];
    }
    if (alarminfo.firedate != nil) {
        //        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        //        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        //        [format setTimeZone:[NSTimeZone systemTimeZone]];
        //        format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        //
        //        [dict setObject:[format stringFromDate:alarminfo.firedate] forKey:ACTION_KEY_FIREDATE];
        [dict setObject:[NSNumber numberWithDouble:[alarminfo.firedate timeIntervalSince1970]] forKey:ACTION_KEY_FIREDATE];
    }
    if (alarminfo.enable != nil) {
        [dict setObject:alarminfo.enable forKey:ACTION_KEY_ENABLE];
    }
    if (alarminfo.weekly != nil) {
        [dict setObject:alarminfo.weekly forKey:ACTION_KEY_WEEKLY];
    }
    if (alarminfo.snooze != nil) {
        [dict setObject:alarminfo.snooze forKey:ACTION_KEY_SNOOZE];
    }
    if (alarminfo.snooze_repeat != nil) {
        [dict setObject:alarminfo.snooze_repeat forKey:ACTION_KEY_SNOOZE_REPEAT];
    }
    if (alarminfo.repeat_hour != nil) {
        [dict setObject:alarminfo.repeat_hour forKey:ACTION_KEY_REPEATHOUR];
    }
    if (alarminfo.repeat_times != nil) {
        [dict setObject:alarminfo.repeat_times forKey:ACTION_KEY_REPEATTIMES];
    }
    if (alarminfo.vib_number != nil) {
        [dict setObject:alarminfo.vib_number forKey:ACTION_KEY_VIBNUMBER];
    }
    if (alarminfo.vib_repeat != nil) {
        [dict setObject:alarminfo.vib_repeat forKey:ACTION_KEY_VIBREPEAT];
    }
    if (alarminfo.year != nil) {
        [dict setObject:alarminfo.year forKey:ACTION_KEY_YEAR];
    }
    if (alarminfo.month != nil) {
        [dict setObject:alarminfo.month forKey:ACTION_KEY_MONTH];
    }
    if (alarminfo.repeat_schedule != nil) {
        [dict setObject:alarminfo.repeat_schedule forKey:ACTION_KEY_REPEATSCEDUAL];
    }
    if (alarminfo.starthour != nil) {
        [dict setObject:alarminfo.starthour forKey:ACTION_KEY_STARTHOUR];
    }
    if (alarminfo.endhour != nil) {
        [dict setObject:alarminfo.endhour forKey:ACTION_KEY_ENDHOUR];
    }
    if (alarminfo.startminute != nil) {
        [dict setObject:alarminfo.startminute forKey:ACTION_KEY_STARTMINUTE];
    }
    if (alarminfo.endminute != nil) {
        [dict setObject:alarminfo.endminute forKey:ACTION_KEY_ENDMINUTE];
    }
    if (alarminfo.alarm_id != nil) {
        [dict setObject:alarminfo.alarm_id forKey:ACTION_KEY_ALARMID];
    }
    NSLog(@" actionbody = %@", dict);
    return dict;
    
}


-(void)update_alarm:(NSDictionary*)alarminfo{
    dispatch_async(self.dispatchqueue, ^{
        if (self.commondata.is_login == NO) {
            return ;
        }
        NSMutableDictionary* actionbody = [alarminfo mutableCopy];
        if ([actionbody.allKeys containsObject: ACTION_KEY_NAME]) {
            NSString* name = [actionbody objectForKey:ACTION_KEY_NAME];
            [actionbody setObject:[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:ACTION_KEY_NAME];
        }
        
        [actionbody setObject:self.commondata.token forKey:ACTION_KEY_TID];
        [actionbody setObject:self.commondata.vid forKey:ACTION_KEY_VID];
        
        
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              PROTOCOL_VERSION,ACTION_KEY_VERSION,
                              ACTION_CMD_UPDATE_ALARM,ACTION_KEY_CMDNAME,
                              [self getSeqid],ACTION_KEY_SEQID,
                              actionbody,ACTION_KEY_BODY, nil];
        
        NSString* url =[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL];
        NSLog(@"url = %@",url);
        NSLog(@"postdata = %@",dict);
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"update_usergoal JSON: %@", responseObject);
            NSDictionary* respjson = (NSDictionary*)responseObject;
            NSString* errocode = [respjson objectForKey:RESPONE_KEY_ERRORCODE];
            
            if ([errocode isEqualToString:ERROR_CODE_OK]) {
                NSDictionary* body = [respjson objectForKey:RESPONE_KEY_BODY];
                if (body){
                    NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
                    if (synckey) {
                        NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
                        NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
                        NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
                        NSMutableDictionary* memberinfo = [self.commondata getMemberInfo:self.commondata.memberid];
                        [memberinfo setObject:syncvalue forKey:synckeystr];
                        [self.commondata setMemberInfo:self.commondata.memberid Information:memberinfo];
                        
                    }
                }
                
            }else if([errocode isEqualToString:ERROR_CODE_TOKENOOS]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //通知用户需要登陆
                    [self notifyOOS];
                    
                });
                
                
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"update_usergoal error= %@",error);
        }];
        

//        NSError* error = nil;
//        NSMutableDictionary* actionbody = [alarminfo mutableCopy];
//        if ([actionbody.allKeys containsObject: ACTION_KEY_NAME]) {
//            NSString* name = [actionbody objectForKey:ACTION_KEY_NAME];
//            [actionbody setObject:[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:ACTION_KEY_NAME];
//        }
//        
//        [actionbody setObject:self.commondata.token forKey:ACTION_KEY_TID];
//        [actionbody setObject:self.commondata.vid forKey:ACTION_KEY_VID];
//        
//        
//        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,ACTION_KEY_VERSION,
//                              ACTION_CMD_UPDATE_ALARM,ACTION_KEY_CMDNAME,
//                              [self getSeqid],ACTION_KEY_SEQID,
//                              actionbody,ACTION_KEY_BODY, nil];
//        
//        NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//        
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL]];
//        NSLog(@"url = %@",url);
//        NSLog(@"postdata = %@",dict);
//        //第二步，创建请求
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
//        [request setURL:url];
//        [request setHTTPBody:data];
//        [request setHTTPMethod:@"POST"];
//        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//        NSString *postLength = [NSString stringWithFormat:@"%d",[data length]];
//        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//        //设置http-header:Content-Length
//        NSHTTPURLResponse* urlResponse = nil;
//        //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
//        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
//        if (error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Login_Error_No_network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
//                [alertview show];
//                
//            });
//            return;
//        }
//        NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"user_add result:%@",result);
//        if (result == nil) {
//            NSLog(@"result is nil");
//            return;
//        }
//        if(responseData == nil){
//            NSLog(@"responseData is nil");
//            return;
//        }
//        NSDictionary* respjson = [NSJSONSerialization
//                                  JSONObjectWithData:responseData //1
//                                  options:NSJSONReadingAllowFragments
//                                  error:&error];
//        if (error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", nil) message:NSLocalizedString(@"Login_Error_No_network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
//                [alertview show];
//                
//            });
//            return;
//            
//        }
//        NSString* errocode = [respjson objectForKey:@"error_code"];
//        if (errocode == nil) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Login_Error_No_network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
//                [alertview show];
//                
//            });
//            return;
//        }
//        if ([errocode isEqualToString:ERROR_CODE_OK]) {
//            
//        }else{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Login_Error_No_network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
//                [alertview show];
//                
//            });
//            return;
//            
//        }
//        
        
    });
    
}
-(void)compareVersion{
    NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    NSDictionary* updatInfo = [bonginfo objectForKey:BONGINFO_KEY_UPDATEINFO];
    NSString* currentfw = [bonginfo objectForKey:BONGINFO_KEY_FIRMWARE];
    NSString* versionCode = [bonginfo objectForKey:BONGINFO_KEY_UPDATEVERSIONCODE];
    if (versionCode == nil) {
        return;
    }
    
    NSString* currentCode = [self getVersionCode:currentfw];
    NSString* returnCode = [self getVersionCode:versionCode];
    NSComparisonResult result = [currentCode caseInsensitiveCompare:returnCode];
    
    
    if (result == NSOrderedAscending) {
        NSString* tips;
        NSDictionary* tipdict = [updatInfo objectForKey:FIRMINFO_DICT_UPDATETIPS];
        NSString* language = NSLocalizedString(@"OTA_FirmwareServer_laguage", nil);
        if ([[tipdict allKeys] containsObject:language]) {
            tips = [tipdict objectForKey:language];
        }else{
            tips = [tipdict objectForKey:@"default"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* notifystr = [NSString stringWithFormat:@"%@",tips];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:notifystr delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"Confirm_OTA", nil),nil];
            alert.tag = 101;
            [alert show];
            
        });
        
        return;
        
    }else{
        return;
        
    }
    
}
-(void)checkOTA{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString* projectcode ;
        NSString* currentfw;
        
//        NSDictionary* fwinfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
        NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
        if (bonginfo) {
            projectcode = [bonginfo objectForKey:BONGINFO_KEY_PRODUCTCODE];
            if (projectcode == nil) {
                return;
            }
            currentfw = [bonginfo objectForKey:BONGINFO_KEY_FIRMWARE];
            if (currentfw == nil) {
                return;
            }
            NSString* currentCode = [self getVersionCode:currentfw];
            NSString* otabasecode = @"V060";
            NSComparisonResult result = [currentCode caseInsensitiveCompare:otabasecode];
            
            
            if (result == NSOrderedDescending) {
                return;
            }
            
            NSDate* lastcanceldate = [bonginfo objectForKey:BONGINFO_KEY_LASTCANCELUPDATE_DATE];
            if(lastcanceldate != nil){
                NSDateFormatter* format = [[NSDateFormatter alloc] init];
                [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                [format setTimeZone:[NSTimeZone systemTimeZone]];
                
                format.dateFormat = @"yyyy-MM-dd";
                NSString* checkdatestr = [format stringFromDate:lastcanceldate];
                NSString* now = [format stringFromDate:[NSDate date]];
                if ([checkdatestr isEqualToString:now]) {
                    NSLog(@"check cancel time not expired!");
                    return;
                }
            }

            NSDate* lastcheckdate = [bonginfo objectForKey:BONGINFO_KEY_LASTCHECKOTA_DATE];
            if(lastcheckdate != nil){
                NSDateFormatter* format = [[NSDateFormatter alloc] init];
                [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                [format setTimeZone:[NSTimeZone systemTimeZone]];
                
                format.dateFormat = @"yyyy-MM-dd";
                NSString* checkdatestr = [format stringFromDate:lastcheckdate];
                NSString* now = [format stringFromDate:[NSDate date]];
                if ([checkdatestr isEqualToString:now]) {
                    NSLog(@"check updateinfo time not expired!");
                    [self compareVersion];
                    return;
                }
            }
            

        }else{
            return;
        }
        

        NSString* urlstr = [NSString stringWithFormat:FIRMWARE_VERSION_SERVER_URL,@"en",projectcode];
        NSURL  *url = [NSURL URLWithString:urlstr];
        NSLog(@"url = %@",url);
        
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData )
        {
            //        NSLog(@"%@",[NSString stringWithCharacters:[urlData bytes] length:urlData.length ]);
            NSError* error = nil;
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&error];
            if (error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                
//                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"OTA_FirmwareServer_ResponeError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//                    [alert show];
//                    
//                });
                NSLog(@"autoOTA:::get update.json error");
                return;
                
            }
            NSLog(@"%@",responseDict);
            NSDictionary* updatInfo = [responseDict objectForKey:FIRMINFO_DICT_UPDATEINFO];
            if (updatInfo) {
                
//                NSString* fwDesc = [updatInfo objectForKey:FIRMINFO_DICT_FWDESC];
//                NSString* fwName = [updatInfo objectForKey:FIRMINFO_DICT_FWNAME];
                self.fwUrl = [updatInfo objectForKey:FIRMINFO_DICT_FWURL];
                self.filename = [[NSURL URLWithString:self.fwUrl] lastPathComponent];
                NSString* versionCode = [updatInfo objectForKey:FIRMINFO_DICT_VERSIONCODE];
//                NSString* versionName = [updatInfo objectForKey:FIRMINFO_DICT_VERSIONNAME];
//                NSDictionary* updatetipdict = [updatInfo objectForKey:FIRMINFO_DICT_UPDATETIPS];
                self.md5file = [updatInfo objectForKey:FIRMINFO_DICT_MD5];
//                NSString* updatetips = nil;
//                if (updatetipdict) {
//                    if ([[updatetipdict allKeys] containsObject:NSLocalizedString(@"OTA_FirmwareServer_laguage",nil)]) {
//                        updatetips = [updatetipdict objectForKey:NSLocalizedString(@"OTA_FirmwareServer_laguage",nil)];
//                    }else{
//                        updatetips = [updatetipdict objectForKey:@"default"];
//                    }
//                }
                //                NSArray* fwlist = [self.currentfw componentsSeparatedByString:@"_"];
                //                if ([fwlist count]>1) {
                //                    currentfw = [fwlist objectAtIndex:0];
                //               }
                [bonginfo setObject:[NSDate date] forKey:BONGINFO_KEY_LASTCHECKOTA_DATE];
                [bonginfo setObject:[updatInfo mutableCopy] forKey:BONGINFO_KEY_UPDATEINFO];
                [bonginfo setObject:versionCode forKey:BONGINFO_KEY_UPDATEVERSIONCODE];
                [bonginfo setObject:self.fwUrl forKey:BONGINFO_KEY_UPDATEFILEURL];
                [bonginfo setObject:self.md5file forKey:BONGINFO_KEY_UPDATEFILEMD5];
                [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
                [self compareVersion];
                

            }else{
                 return;
                
            }
            
        }else{
            return;
            
        }
        
    });
}
-(NSString*)getVersionCode:(NSString*)firmware{
    
    return [firmware substringWithRange:NSMakeRange([firmware length]-3, 3)];
}

-(void)startOTA{
}

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    if ([[window subviews] count]) {
        UIView *frontView = [[window subviews] objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
            result = nextResponder;
        else
            result = window.rootViewController;

    }else{
        result = window.rootViewController;
    }
    
    return result;
}
/////For JPush////////
-(void)didLoginJpush:(NSNotification*)notify{
    NSLog(@"didLoginJpush :%@",notify);
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,ACTION_KEY_VERSION,
                              ACTION_CMD_JPUSH_UPDATE,ACTION_KEY_CMDNAME,
                              [self getSeqid],ACTION_KEY_SEQID,
                              @{ACTION_KEY_TID:self.commondata.token,
                                ACTION_KEY_VID:self.commondata.vid,
                                ACTION_KEY_JPUSHID:[JPUSHService registrationID],
                                ACTION_KEY_PHONEID:[self.commondata getPhoneId],
                                },ACTION_KEY_BODY, nil];
        
        NSString* url =[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL];
        NSLog(@"url = %@",url);
        NSLog(@"postdata = %@",dict);
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"didLoginJpush JSON: %@", responseObject);
            NSDictionary* respjson = (NSDictionary*)responseObject;
            NSString* errocode = [respjson objectForKey:RESPONE_KEY_ERRORCODE];
            
            if([errocode isEqualToString:ERROR_CODE_TOKENOOS]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //通知用户需要登陆
                    [self notifyOOS];
                    
                });
                
                
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"didLoginJpush error= %@",error);
        }];
    });
}
@end
