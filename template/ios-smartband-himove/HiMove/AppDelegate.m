//
//  AppDelegate.m
//  SXRBand
//
//  Created by qf on 14-7-16.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "AppDelegate.h"
#import "KLCPopup.h"
#import "YFTLoginViewController.h"
#import "HMTabBarController.h"
#import "LocationLoop.h"
#import "IRKCommonData.h"
#import "CommonDefine.h"
#import <Bugly/Bugly.h>
#import <HealthKit/HealthKit.h>
#import "HealthKitManager.h"

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
@interface AppDelegate() <JPUSHRegisterDelegate>

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSMutableDictionary *configdata = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString* buglyid = [configdata objectForKey:@"bugly_id"];
    if (buglyid!=nil) {
        [Bugly startWithAppId:buglyid];
    }
    
    
    IRKCommonData* data = [IRKCommonData SharedInstance];
    [data loadconfig];
    [BleControl SharedInstance];
    [MainLoop SharedInstance];
    [ServerLogic SharedInstance];
    [LocationLoop SharedInstance];
    [HealthKitManager SharedInstance];
    [self initPlatforms];
    [self initJpush:launchOptions];
#ifdef RELEASE_LOG
    NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [allPaths objectAtIndex:0];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appname = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *filename = [[NSString stringWithFormat:@"app%@_%@_%@%@.log",appname,[data getPhoneId],[data getPhoneOS],[data getPhoneType]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *pathForLog = [documentsDirectory stringByAppendingPathComponent:filename];
    freopen([pathForLog cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
#endif

    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version >= 8.0){
        UIUserNotificationType types = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *mySettings =
        [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (data.is_first_run /*|| data.is_login == NO*/) {
        UINavigationController *n1=[[UINavigationController alloc]initWithRootViewController:[YFTLoginViewController new]];
        self.window.rootViewController = n1;
    }else{
        HMTabBarController *tb=[HMTabBarController new];
        self.window.rootViewController = tb;
    }
    [self.window makeKeyAndVisible];
    if(data.is_login==YES){
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_has_Login object:nil];
    }
    //清除badge
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    /*
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier taskID;
    taskID = [app beginBackgroundTaskWithExpirationHandler:^{
        //如果系统觉得我们还是运行了太久，将执行这个程序块，并停止运行应用程序
        NSLog(@"--------end now-------------");
        [app endBackgroundTask:taskID];
    }];
    if (taskID == UIBackgroundTaskInvalid) {
        NSLog(@"Failed to start background task!");
        return;
    }
    NSLog(@"Starting background task with %f seconds remaining", app.backgroundTimeRemaining);
    while (1) {
        [NSThread sleepForTimeInterval:1];
        NSLog(@"Finishing background task with %f seconds remaining",app.backgroundTimeRemaining);

    }
    //告诉系统我们完成了
    [app endBackgroundTask:taskID];
     */
    /*
    MainLoop* mainloop = [MainLoop SharedInstance];
    mainloop.runmode = RUNMODE_BACKGROUD;
    NSLog(@"mainloop.runmode = %d",mainloop.runmode);
    self.myTimer =
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(timerMethod:) userInfo:nil
                                    repeats:YES];
    self.backgroundIdentifier = [application beginBackgroundTaskWithExpirationHandler:^(void) {
        [self endBackgroundTask];
    }];
     */
}
/*
- (void)timerMethod:(NSTimer *)paramSender{
    //获取后台任务可执行时间，单位秒，若应用未能在此时间内完成任务，则应用将被终止
    NSTimeInterval backgroundTimeRemaining = [[UIApplication sharedApplication] backgroundTimeRemaining];
    static int is_send_heartbeat = 0;
    //应用处于前台时，backgroundTimeRemaining值weiDBL_MAX
    if (backgroundTimeRemaining == DBL_MAX) {
        NSLog(@"Background time remaining = Undetermined");
        is_send_heartbeat = 0;
        
    } else {
        NSLog(@"Background time remaining = %.02f seconds", backgroundTimeRemaining);
        if (is_send_heartbeat == 0 && backgroundTimeRemaining <30) {
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_heartbeat object:nil];
            is_send_heartbeat = 1;
        }
    }
}
- (void) endBackgroundTask{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    __weak AppDelegate *weakSelf = self;
    dispatch_async(mainQueue, ^(void) {
        AppDelegate *strongSelf = weakSelf;
        if (strongSelf != nil){
            [strongSelf.myTimer invalidate];
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundIdentifier];
            strongSelf.backgroundIdentifier = UIBackgroundTaskInvalid;
        }
    });
}
 */
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

- (void)applicationWillEnterForeground:(UIApplication *)application{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    MainLoop* mainloop = [MainLoop SharedInstance];
    mainloop.runmode = RUNMODE_ACTIVE;
    NSLog(@"mainloop.runmode = %d",mainloop.runmode);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

/*
 
    NSString* expirestr = @"2014-11-01 00:00:00";
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate* expireday = [format dateFromString:expirestr];
    NSDate* today = [NSDate date];
    NSComparisonResult r = [today compare:expireday];
    
    if (r != NSOrderedAscending) {
        UIView* syncview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
        syncview.backgroundColor = [UIColor grayColor];
        syncview.layer.cornerRadius = 20;
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectInset(syncview.bounds, 20, 20)];
        label.textColor = [UIColor whiteColor];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        label.text = NSLocalizedString(@"APP_Expire", nil);
        [syncview addSubview:label];
        KLCPopup* popup = [KLCPopup popupWithContentView:syncview showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeSlideOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
        [popup show];
    }
*/
}

- (void)applicationWillTerminate:(UIApplication *)application{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (void)saveContext{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SXRBand" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SXRBand.sqlite"];
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                       NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES],
                                       NSInferMappingModelAutomaticallyOption, nil];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if([notification.soundName isEqualToString:@"alarm.caf"])
    {
        [[IRKCommonData SharedInstance] playSoundWithName:notification.soundName];
    }
}


- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration{
//    NSLog(@"newStatusBarOrientation = %d",newStatusBarOrientation);
    
}


/*
 
 */
- (void)initPlatforms{
//    [ShareSDK registerApp:@"18e4f03162966" activePlatforms:@[@(SSDKPlatformTypeWechat),
//                                                             @(SSDKPlatformTypeQQ),
//                                                             @(SSDKPlatformTypeLinkedIn),
//                                                             @(SSDKPlatformTypeFacebook),
//                                                             @(SSDKPlatformTypeTwitter),
//                                                             @(SSDKPlatformTypeWhatsApp)]
//                 onImport:^(SSDKPlatformType platformType)
//     {
//         switch (platformType){
//             case SSDKPlatformTypeWechat:
//                 [ShareSDKConnector connectWeChat:[WXApi class]]; break;
//             case SSDKPlatformTypeQQ:
//                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]]; break;
//             default: break;
//         }
//     }
//          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
//     {
//         switch (platformType)
//         {
//             case SSDKPlatformTypeWechat:
//                 [appInfo SSDKSetupWeChatByAppId:@"wx91c1603b82efe080" appSecret:@"cc0cf08458f89f2235e55d85c86b320e"]; break;
//             case SSDKPlatformTypeQQ:
//                 [appInfo SSDKSetupQQByAppId:@"1106081159"
//                                      appKey:@"A4Gs0fpVcFKtrXZL"
//                                    authType:SSDKAuthTypeBoth]; break;
//             case SSDKPlatformTypeLinkedIn:
//                 [appInfo SSDKSetupLinkedInByApiKey:@"8169zyccwz38ez" secretKey:@"WbEKSQ5HJ1Vgsr2M" redirectUrl:@"http://www.keeprapid.com"]; break;
//             case SSDKPlatformTypeFacebook:
//                 [appInfo SSDKSetupFacebookByApiKey:@"1631899927108281" appSecret:@"f1d688d3f0eca380aa26e110a14a6509" authType:SSDKAuthTypeBoth]; break;
//             case SSDKPlatformTypeTwitter:
//                 [appInfo SSDKSetupTwitterByConsumerKey:@"0Alwzrhcs8ACd11IbfMBrHgYy" consumerSecret:@"poB0ZPggSy6B6j5Lq8kWcCKkx5nmzxrYLl7cB0QYtTHUXXveXD" redirectUri:@"http://www.keeprapid.com"]; break;
//             default: break;
//         }
//     }];
    
    
    NSMutableArray *arrayActive = [[NSMutableArray alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSMutableDictionary *configdata = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString* sharesdkkey = [configdata objectForKey:@"shareKey"];
    NSDictionary *weibo = [configdata objectForKey:@"weibo"];
    NSDictionary *mail = [configdata objectForKey:@"mail"];
    NSDictionary *qq = [configdata objectForKey:@"qq"];
    NSDictionary *wechat = [configdata objectForKey:@"wechat"];
    NSDictionary *facebook = [configdata objectForKey:@"facebook"];
    NSDictionary *twitter = [configdata objectForKey:@"twitter"];
    NSDictionary *linkedin = [configdata objectForKey:@"linkedin"];
    
    NSNumber *weiboEnabled = [weibo objectForKey:@"enabled"];
    NSNumber *mailEnabled = [mail objectForKey:@"enabled"];
    NSNumber *wechatEnabled = [wechat objectForKey:@"enabled"];
    NSNumber *qqEnabled = [qq objectForKey:@"enabled"];
    NSNumber *fbEnabled = [facebook objectForKey:@"enabled"];
    NSNumber *twitterEnabled = [twitter objectForKey:@"enabled"];
    NSNumber *linkedinEnabled = [linkedin objectForKey:@"enabled"];
    
    if(weiboEnabled.boolValue)
    {
        [arrayActive addObject:@(SSDKPlatformTypeSinaWeibo)];
    }
    
    if(mailEnabled.boolValue)
    {
        [arrayActive addObject:@(SSDKPlatformTypeMail)];
    }
    
    if(wechatEnabled.boolValue)
    {
        [arrayActive addObject:@(SSDKPlatformTypeWechat)];
    }
    
    if(qqEnabled.boolValue)
    {
        [arrayActive addObject:@(SSDKPlatformTypeQQ)];
    }
    
    if(fbEnabled.boolValue)
    {
        [arrayActive addObject:@(SSDKPlatformTypeFacebook)];
    }
    
    if(twitterEnabled.boolValue)
    {
        [arrayActive addObject:@(SSDKPlatformTypeTwitter)];
    }
    if(linkedinEnabled.boolValue)
    {
        [arrayActive addObject:@(SSDKPlatformTypeLinkedIn)];
    }
    
    [ShareSDK registerApp:sharesdkkey activePlatforms:arrayActive onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
             {
                 NSString *appId = [weibo objectForKey:@"appId"];
                 NSString *appKey = [weibo objectForKey:@"appKey"];
                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:appId
                                           appSecret:appKey
                                         redirectUri:@"http://www.keeprapid.com"
                                            authType:SSDKAuthTypeBoth];
             }
                 break;
             case SSDKPlatformTypeWechat:
             {
                 NSString *appId = [wechat objectForKey:@"appId"];
                 NSString *appKey = [wechat objectForKey:@"appKey"];
                 [appInfo SSDKSetupWeChatByAppId:appId
                                       appSecret:appKey];
             }
                 break;
             case SSDKPlatformTypeQQ:
             {
                 NSString *appId = [qq objectForKey:@"appId"];
                 NSString *appKey = [qq objectForKey:@"appKey"];
                 [appInfo SSDKSetupQQByAppId:appId
                                      appKey:appKey
                                    authType:SSDKAuthTypeBoth];
             }
                 break;
             case SSDKPlatformTypeTwitter:
             {
                 NSString *appId = [twitter objectForKey:@"appId"];
                 NSString *appKey = [twitter objectForKey:@"appKey"];
                 [appInfo SSDKSetupTwitterByConsumerKey:appId consumerSecret:appKey redirectUri:@"http://www.keeprapid.com"];
             }
                 break;
                 
             case SSDKPlatformTypeFacebook:
             {
                 NSString *appId = [facebook objectForKey:@"appId"];
                 NSString *appKey = [facebook objectForKey:@"appKey"];
                 [appInfo SSDKSetupFacebookByApiKey:appId appSecret:appKey authType:SSDKAuthTypeBoth];
             }
                 break;
                 
             case SSDKPlatformTypeLinkedIn:
             {
                 NSString *appId = [linkedin objectForKey:@"appId"];
                 NSString *appKey = [linkedin objectForKey:@"appKey"];
                 [appInfo SSDKSetupLinkedInByApiKey:appId secretKey:appKey redirectUrl:@"http://www.keeprapid.com"];
             }
                 break;

                 
             default:
                 break;
         }
     }];
    
}

//- (BOOL)application:(UIApplication *)application
//      handleOpenURL:(NSURL *)url
//{
//    return [ShareSDK handleOpenURL:url
//                        wxDelegate:self];
//}
//
//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation
//{
//    return [ShareSDK handleOpenURL:url
//                 sourceApplication:sourceApplication
//                        annotation:annotation
//                        wxDelegate:self];
//}
-(void)initJpush:(NSDictionary *)launchOptions{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSMutableDictionary *configdata = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString* jpushid = [configdata objectForKey:@"jpush_appkey"];
    if (jpushid == nil || [jpushid isEqualToString:@""]) {
        return;
    }
#ifdef APNS_PRODUCTION
    BOOL isproduction = YES;
#else
    BOOL isproduction = NO;
#endif
    
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
//    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:jpushid
                          channel:@"Appstore"
                 apsForProduction:isproduction
            advertisingIdentifier:nil];
    
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}



@end
