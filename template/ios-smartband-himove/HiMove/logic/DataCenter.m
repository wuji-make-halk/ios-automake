//
//  DataCenter.m
//  SXRBand
//
//  Created by qf on 14-8-14.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "DataCenter.h"

@implementation DataCenter
+(DataCenter *)SharedInstance
{
    static DataCenter *datacenter = nil;
    if (datacenter == nil) {
        datacenter = [[DataCenter alloc] init];
    }
    return datacenter;
}

-(id)init
{
    self = [super init];
    if (self) {
//        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//        self.managedObjectContext = appdelegate.managedObjectContext;
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        //self.managedObjectContext = appdelegate.managedObjectContext;
        self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.managedObjectContext.parentContext = appdelegate.managedObjectContext;
        self.commondata = [IRKCommonData SharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:notify_key_sycn_finish_need_reloaddata object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearData) name:notify_key_clear_all_data object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncnetworkok2:) name:notify_key_syncdata_to_network_ok object:nil];
        //////////for healthkit/////////////
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncHealthKitok2:) name:notify_key_syncdata_to_healthkit_ok object:nil];
        /////////end////////////////////////
        
        self.Daydict = [[NSMutableDictionary alloc] init];
        self.Monthdict = [[NSMutableDictionary alloc] init];
        self.Hourdict = [[NSMutableDictionary alloc] init];
        self.dataqueue = dispatch_queue_create("com.keeprapid.datacenter", DISPATCH_QUEUE_SERIAL);

        [self reloadData];
    }
    return self;
}
-(int)getYearfromDate:(NSDate*)date{
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM";
    NSString* year = [format stringFromDate:date];
    return year.intValue;
    
}
-(NSString*)getMonthKeyfromDate:(NSDate*)date{
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM";
    return [format stringFromDate:date];
}

-(NSString*)getDayKeyfromDate:(NSDate*)date{
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    format.dateFormat = @"yyyy-MM-dd";
    return [format stringFromDate:date];
}

-(NSString*)getHourKeyfromDate:(NSDate*)date{
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    format.dateFormat = @"yyyy-MM-dd HH";
    return [format stringFromDate:date];
}


-(void)reloadData{
    [self reloadStepData];
    [self procStepData];
    [self reloadSleepData];
    [self procSleepData];
    NSLog(@"daydict = %@",self.Daydict);
    NSLog(@"monthdict = %@",self.Monthdict);

}

-(void)reloadStepData{
    NSLog(@"getSportHistoryData");
    //设定时间格式,这里可以设置成自己需要的格式
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory_Day" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
//#ifdef CUSTOM_API2
    NSDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    NSString* macid = @"";
    if (bi) {
        if ([bi.allKeys containsObject:BONGINFO_KEY_BLEADDR]) {
            macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
        }
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"uid IN {%@,%@,%@} and macid IN {%@,%@,%@}", nil, @"", [IRKCommonData SharedInstance].uid, nil, @"", macid];
    [fetchRequest setPredicate:predicate];
//#endif
    // Specify how the fetched objects should be sorted
    NSError *error = nil;
    NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (self.Daydict) {
        [self.Daydict removeAllObjects];
    }
    if (self.Monthdict) {
        [self.Monthdict removeAllObjects];
    }
    self.maxYear = 0;
    self.maxDate = nil;
    self.maxDateMonth = nil;
    self.minDateMonth = nil;
    
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        NSLog(@"No data");
    }else{
        for (StepHistory_Day* stepday in fetchedObjects) {
            NSString* key = [self getDayKeyfromDate:stepday.datetime];
            
            //modify:防止date为nil造成app闪退
            if(key == nil)
                continue;
            // @{@"steps":[NSNumber numberWithInt:stepday.steps.intValue],@"sport":[NSNumber numberWithInt:stepday.sport.intValue],@"cal":[NSNumber numberWithFloat:stepday.cal.floatValue],@"distance":[NSNumber numberWithFloat:stepday.distance.floatValue],@"deep":[NSNumber numberWithFloat:0],@"light":[NSNumber numberWithFloat:0],@"awake":[NSNumber numberWithFloat:0]}
//#ifdef CUSTOM_API2
            if ([self.Daydict.allKeys containsObject:key]) {
                NSMutableDictionary* dict = [self.Daydict objectForKey:key];
                [dict setObject:[NSNumber numberWithInt:stepday.sport.intValue+[[dict objectForKey:@"steps"] intValue]] forKey:@"steps"];
                [self.Daydict setObject:dict forKey:key];
            }else{
                [self.Daydict setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:stepday.steps.intValue],@"steps",[NSNumber numberWithInt:stepday.sport.intValue],@"sport",[NSNumber numberWithFloat:0],@"cal",[NSNumber numberWithFloat:0],@"distance",[NSNumber numberWithFloat:0],@"deep",[NSNumber numberWithFloat:0],@"light",[NSNumber numberWithFloat:0],@"awake", nil] forKey:key];
            }
//#else
//            [self.Daydict setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:stepday.steps.intValue],@"steps",[NSNumber numberWithInt:stepday.sport.intValue],@"sport",[NSNumber numberWithFloat:0],@"cal",[NSNumber numberWithFloat:0],@"distance",[NSNumber numberWithFloat:0],@"deep",[NSNumber numberWithFloat:0],@"light",[NSNumber numberWithFloat:0],@"awake", nil] forKey:key];
//#endif
            int year = [self getYearfromDate:stepday.datetime];
            if (self.maxYear<year || self.maxYear == 0)
                self.maxYear = year;
            if(self.minYear > year || self.minYear == 0)
                self.minYear = year;
            
//            NSDate* tmpdate = [stepday.datetime dateByAddingTimeInterval:-[NSTimeZone systemTimeZone].secondsFromGMT];
            NSDate* tmpdate = [stepday.datetime copy];
            if (self.maxDate == nil) {
                self.maxDate = [tmpdate copy];
                self.minDate = [tmpdate copy];
            }
            else{
                NSComparisonResult c = [self.maxDate compare:tmpdate];
                if (c == NSOrderedAscending){
                    self.maxDate = [tmpdate copy];
                }else{
                    NSComparisonResult d = [self.minDate compare:tmpdate];
                    if (d == NSOrderedDescending) {
                        self.minDate = [tmpdate copy];
                    }
                }
            }
            
            
        }
    }
    
    
    entity = [NSEntityDescription entityForName:@"StepHistory_Month" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    
//#ifdef CUSTOM_API2
    predicate = [NSPredicate predicateWithFormat:@"uid IN {%@,%@,%@} and macid IN {%@,%@,%@}", nil, @"", [IRKCommonData SharedInstance].uid, nil, @"", macid];
    [fetchRequest setPredicate:predicate];
//#endif
    // Specify how the fetched objects should be sorted
    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        NSLog(@"No data");
    }else{
        for (StepHistory_Month* stepmonth in fetchedObjects) {
            NSString* key = [self getMonthKeyfromDate:stepmonth.datetime];
            
            //modify:防止date为nil造成app闪退
            if(key == nil)
                continue;
//#ifdef CUSTOM_API2
            if ([self.Monthdict.allKeys containsObject:key]) {
                NSMutableDictionary* dict = [self.Monthdict objectForKey:key];
                [dict setObject:[NSNumber numberWithInt:stepmonth.sport.intValue+[[dict objectForKey:@"steps"] intValue]] forKey:@"steps"];
                [self.Monthdict setObject:dict forKey:key];
            }else{
                [self.Monthdict setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:stepmonth.steps.intValue],@"steps",[NSNumber numberWithInt:stepmonth.sport.intValue],@"sport",[NSNumber numberWithFloat:stepmonth.cal.floatValue],@"cal",[NSNumber numberWithFloat:stepmonth.distance.floatValue],@"distance",[NSNumber numberWithFloat:0],@"deep",[NSNumber numberWithFloat:0],@"light",[NSNumber numberWithFloat:0],@"awake", nil] forKey:key];
            }
//#else
//
//            [self.Monthdict setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:stepmonth.steps.intValue],@"steps",[NSNumber numberWithInt:stepmonth.sport.intValue],@"sport",[NSNumber numberWithFloat:stepmonth.cal.floatValue],@"cal",[NSNumber numberWithFloat:stepmonth.distance.floatValue],@"distance",[NSNumber numberWithFloat:0],@"deep",[NSNumber numberWithFloat:0],@"light",[NSNumber numberWithFloat:0],@"awake", nil] forKey:key];
//#endif
//            NSDate* tmpdate = [stepmonth.datetime dateByAddingTimeInterval:-[NSTimeZone systemTimeZone].secondsFromGMT];
            NSDate* tmpdate = [stepmonth.datetime copy];
            if (self.maxDateMonth == nil) {
                self.maxDateMonth = [tmpdate copy];
                self.minDateMonth = [tmpdate copy];
            }
            else{
                NSComparisonResult c = [self.maxDateMonth compare:tmpdate];
                if (c == NSOrderedAscending){
                    self.maxDateMonth = [tmpdate copy];
                }else{
                    NSComparisonResult d = [self.minDateMonth compare:tmpdate];
                    if (d == NSOrderedDescending) {
                        self.minDateMonth = [tmpdate copy];
                    }
                }
            }
            
            
        }
    }
    
}
-(void)procStepData{
    
}
-(void)reloadSleepData{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SleepHistory_Day" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    
//#ifdef CUSTOM_API2
    NSDictionary* bi = [[IRKCommonData SharedInstance] getBongInformation:[IRKCommonData SharedInstance].lastBongUUID];
    NSString* macid = @"";
    if (bi) {
        if ([bi.allKeys containsObject:BONGINFO_KEY_BLEADDR]) {
            macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
        }
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"uid IN {%@,%@,%@} and macid IN {%@,%@,%@}", nil, @"", [IRKCommonData SharedInstance].uid, nil, @"", macid];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//#else
//    [fetchRequest setPredicate:nil];
//#endif
    // Specify how the fetched objects should be sorted
    NSError *error = nil;
    NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        NSLog(@"No data");
    }else{
        NSString* lastkey = @"";
        for (SleepHistory_Day* sleepday in fetchedObjects) {
            NSString* key = [self getDayKeyfromDate:sleepday.datetime];
            
            //modify:防止date为nil造成app闪退
            if(key == nil)
                continue;
            NSMutableDictionary* obj = (NSMutableDictionary*)[self.Daydict objectForKey:key];
            if (obj){
//#ifdef CUSTOM_API2
                [obj setValue:[NSNumber numberWithFloat:sleepday.deep.floatValue+[[obj objectForKey:@"deep"] floatValue]] forKey:@"deep"];
                [obj setValue:[NSNumber numberWithFloat:sleepday.light.floatValue+[[obj objectForKey:@"light"] floatValue]] forKey:@"light"];
                [obj setValue:[NSNumber numberWithFloat:sleepday.awake.floatValue+[[obj objectForKey:@"awake"] floatValue]] forKey:@"awake"];
                [obj setValue:[NSNumber numberWithFloat:sleepday.exlight.floatValue+[[obj objectForKey:@"exlight"] floatValue]] forKey:@"exlight"];
//#else
//                [obj setValue:[NSNumber numberWithFloat:sleepday.deep.floatValue] forKey:@"deep"];
//                [obj setValue:[NSNumber numberWithFloat:sleepday.light.floatValue] forKey:@"light"];
//                [obj setValue:[NSNumber numberWithFloat:sleepday.awake.floatValue] forKey:@"awake"];
//                [obj setValue:[NSNumber numberWithFloat:sleepday.exlight.floatValue] forKey:@"exlight"];
//#endif
                
            }else{

                [self.Daydict setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:0],@"steps",[NSNumber numberWithInt:0],@"sport",[NSNumber numberWithInt:0],@"cal",[NSNumber numberWithInt:0],@"distance",[NSNumber numberWithFloat:sleepday.deep.floatValue],@"deep",[NSNumber numberWithFloat:sleepday.light.floatValue],@"light",[NSNumber numberWithFloat:sleepday.awake.floatValue],@"awake",[NSNumber numberWithFloat:sleepday.exlight.floatValue],@"exlight",nil] forKey:key];
                
                int year = [self getYearfromDate:sleepday.datetime];
                if (self.maxYear<year || self.maxYear == 0)
                    self.maxYear = year;
                if(self.minYear > year || self.minYear == 0)
                    self.minYear = year;
                
//                NSDate* tmpdate = [sleepday.datetime dateByAddingTimeInterval:-[NSTimeZone systemTimeZone].secondsFromGMT];
                NSDate* tmpdate = [sleepday.datetime copy];
                if (self.maxDate == nil) {
                    self.maxDate = [tmpdate copy];
                    self.minDate = [tmpdate copy];
                }
                else{
                    NSComparisonResult c = [self.maxDate compare:tmpdate];
                    if (c == NSOrderedAscending){
                        self.maxDate = [tmpdate copy];
                    }else{
                        NSComparisonResult d = [self.minDate compare:tmpdate];
                        if (d == NSOrderedDescending) {
                            self.minDate = [tmpdate copy];
                        }
                    }
                }
                
            }
//#ifdef CUSTOM_API2
            if (![lastkey isEqualToString:key]) {
                NSString* monthkey = [self getMonthKeyfromDate:sleepday.datetime];
                
                //modify:防止date为nil造成app闪退
                if(monthkey == nil)
                    continue;
                
                NSMutableDictionary* objmonth = (NSMutableDictionary*)[self.Monthdict objectForKey:monthkey];
                if (objmonth) {
                    NSNumber* sleepdays = [objmonth objectForKey:@"sleepday"];
                    if (sleepdays) {
                        int sleepday_u = sleepdays.intValue + 1;
                        [objmonth setValue:[NSNumber numberWithInt:sleepday_u] forKey:@"sleepday"];
                    }else{
                        [objmonth setValue:[NSNumber numberWithInt:1] forKey:@"sleepday"];
                    }
                }else{
                    [self.Monthdict setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:0],@"steps",[NSNumber numberWithInt:0],@"sport",[NSNumber numberWithInt:0],@"cal",[NSNumber numberWithInt:0],@"distance",[NSNumber numberWithFloat:0],@"deep",[NSNumber numberWithFloat:0],@"light",[NSNumber numberWithFloat:0],@"awake",[NSNumber numberWithFloat:0],@"exlight",[NSNumber numberWithFloat:1],@"sleepday", nil] forKey:key];
                }

            }
            lastkey = key;
//#else
//            NSString* monthkey = [self getMonthKeyfromDate:sleepday.datetime];
//            
//            //modify:防止date为nil造成app闪退
//            if(monthkey == nil)
//                continue;
//            
//            NSMutableDictionary* objmonth = (NSMutableDictionary*)[self.Monthdict objectForKey:monthkey];
//            if (objmonth) {
//                NSNumber* sleepdays = [objmonth objectForKey:@"sleepday"];
//                if (sleepdays) {
//                    int sleepday_u = sleepdays.intValue + 1;
//                    [objmonth setValue:[NSNumber numberWithInt:sleepday_u] forKey:@"sleepday"];
//                }else{
//                    [objmonth setValue:[NSNumber numberWithInt:1] forKey:@"sleepday"];
//                }
//            }else{
//                [self.Monthdict setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:0],@"steps",[NSNumber numberWithInt:0],@"sport",[NSNumber numberWithInt:0],@"cal",[NSNumber numberWithInt:0],@"distance",[NSNumber numberWithFloat:0],@"deep",[NSNumber numberWithFloat:0],@"light",[NSNumber numberWithFloat:0],@"awake",[NSNumber numberWithFloat:0],@"exlight",[NSNumber numberWithFloat:1],@"sleepday", nil] forKey:key];
//            }
//#endif
        }
        
    }
    entity = [NSEntityDescription entityForName:@"SleepHistory_Month" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    
//#ifdef CUSTOM_API2
    predicate = [NSPredicate predicateWithFormat:@"uid IN {%@,%@,%@} and macid IN {%@,%@,%@}", nil, @"", [IRKCommonData SharedInstance].uid, nil, @"", macid];
    [fetchRequest setPredicate:predicate];
//#else
//    [fetchRequest setPredicate:nil];
//#endif
    // Specify how the fetched objects should be sorted
    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        NSLog(@"No data");
    }else{
        for (SleepHistory_Month* sleepmonth in fetchedObjects) {
            NSString* key = [self getMonthKeyfromDate:sleepmonth.datetime];
            
            //modify:防止date为nil造成app闪退
            if(key == nil)
                continue;
            
            NSMutableDictionary* obj = (NSMutableDictionary*)[self.Monthdict objectForKey:key];
            if (obj){
//#ifdef CUSTOM_API2
                [obj setValue:[NSNumber numberWithFloat:sleepmonth.deep.floatValue+[[obj objectForKey:@"deep"] floatValue]] forKey:@"deep"];
                [obj setValue:[NSNumber numberWithFloat:sleepmonth.light.floatValue+[[obj objectForKey:@"light"] floatValue]] forKey:@"light"];
                [obj setValue:[NSNumber numberWithFloat:sleepmonth.awake.floatValue+[[obj objectForKey:@"awake"] floatValue]] forKey:@"awake"];
                [obj setValue:[NSNumber numberWithFloat:sleepmonth.exlight.floatValue+[[obj objectForKey:@"exlight"] floatValue]] forKey:@"exlight"];
//#else
//                [obj setValue:[NSNumber numberWithFloat:sleepmonth.deep.floatValue] forKey:@"deep"];
//                [obj setValue:[NSNumber numberWithFloat:sleepmonth.light.floatValue] forKey:@"light"];
//                [obj setValue:[NSNumber numberWithFloat:sleepmonth.awake.floatValue] forKey:@"awake"];
//                [obj setValue:[NSNumber numberWithFloat:sleepmonth.exlight.floatValue] forKey:@"exlight"];
//#endif
                
            }else{
                [self.Monthdict setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:0],@"steps",[NSNumber numberWithInt:0],@"sport",[NSNumber numberWithInt:0],@"cal",[NSNumber numberWithInt:0],@"distance",[NSNumber numberWithFloat:sleepmonth.deep.floatValue],@"deep",[NSNumber numberWithFloat:sleepmonth.light.floatValue],@"light",[NSNumber numberWithFloat:sleepmonth.awake.floatValue],@"awake",[NSNumber numberWithFloat:sleepmonth.exlight.floatValue],@"exlight", nil] forKey:key];
//                [self.Monthdict setObject:@{@"steps":[NSNumber numberWithInt:0],@"sport":[NSNumber numberWithInt:0],@"cal":[NSNumber numberWithFloat:0],@"distance":[NSNumber numberWithFloat:0],@"deep":[NSNumber numberWithFloat:sleepmonth.deep.floatValue],@"light":[NSNumber numberWithFloat:sleepmonth.light.floatValue],@"awake":[NSNumber numberWithFloat:sleepmonth.awake.floatValue]} forKey:key];
 //               NSDate* tmpdate = [sleepmonth.datetime dateByAddingTimeInterval:-[NSTimeZone systemTimeZone].secondsFromGMT];
                NSDate* tmpdate = [sleepmonth.datetime copy];
                if (self.maxDateMonth == nil) {
                    self.maxDateMonth = [tmpdate copy];
                    self.minDateMonth = [tmpdate copy];
                }
                else{
                    NSComparisonResult c = [self.maxDateMonth compare:tmpdate];
                    if (c == NSOrderedAscending){
                        self.maxDateMonth = [tmpdate copy];
                    }else{
                        NSComparisonResult d = [self.minDateMonth compare:tmpdate];
                        if (d == NSOrderedDescending) {
                            self.minDateMonth = [tmpdate copy];
                        }
                    }
                }
                
            }
        }
    }
    
    
}
-(void)procSleepData{
    
}
-(NSDate*)getPrevDate:(NSDate*)date{
    NSDate* currentdate = date;
    while (1) {
        currentdate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:currentdate];
        NSString* key = [self getDayKeyfromDate:currentdate];
        id obj = [self.Daydict objectForKey:key];
        if (obj){
            return currentdate;
        }
        NSComparisonResult c = [currentdate compare:self.minDate];
        if (c == NSOrderedAscending || c == NSOrderedSame) {
            return date;
        }
    }
}
-(NSDate*)getNextDate:(NSDate*)date{
    NSDate* currentdate = date;
    while (1) {
        currentdate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:currentdate];
        NSString* key = [self getDayKeyfromDate:currentdate];
        id obj = [self.Daydict objectForKey:key];
        if (obj){
            return currentdate;
        }
        NSComparisonResult c = [currentdate compare:self.maxDate];
        if (c == NSOrderedDescending || c == NSOrderedSame) {
            return [NSDate date];
        }
    }

}
-(NSDate*)getPrevMonth:(NSDate*)date{
    NSDate* currentdate = date;
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:currentdate];
    
    while (1) {
        comp.month -= 1;
        currentdate = [calendar dateFromComponents:comp];
        NSLog(@"%@",currentdate);
        
        NSString* key = [self getMonthKeyfromDate:currentdate];
        id obj = [self.Monthdict objectForKey:key];
        if (obj){
            return currentdate;
        }
        NSComparisonResult c = [currentdate compare:self.minDateMonth];
        if (c == NSOrderedAscending || c == NSOrderedSame) {
            return date;
        }
    }
}
-(NSDate*)getNextMonth:(NSDate*)date{
    NSDate* currentdate = date;
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:currentdate];
    
    while (1) {
        comp.month += 1;
        currentdate = [calendar dateFromComponents:comp];
        NSLog(@"%@",currentdate);
        
        NSString* key = [self getMonthKeyfromDate:currentdate];
        id obj = [self.Monthdict objectForKey:key];
        if (obj){
            return currentdate;
        }
        NSComparisonResult c = [currentdate compare:self.maxDateMonth];
        if (c == NSOrderedDescending || c == NSOrderedSame) {
            return [NSDate date];
        }
    }
    
}

-(NSDate*)getPrevYear:(NSDate*)date{
    NSDate* currentdate = date;
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:currentdate];
    
    int year = (int)comp.year - 1;
    if (year>= self.minYear){
        comp.year -= 1;
        currentdate = [calendar dateFromComponents:comp];
        return currentdate;
    }else{
        return date;
    }
}
-(NSDate*)getNextYear:(NSDate*)date{
    NSDate* currentdate = date;
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:currentdate];
    int year = (int)comp.year + 1;
    if (year<= self.maxYear){
        comp.year += 1;
        currentdate = [calendar dateFromComponents:comp];
        return currentdate;
    }else{
        return date;
    }
    
}




-(NSMutableDictionary*)getDataByDate:(NSDate*)date{
    NSString* key = [self getDayKeyfromDate:date];
    return [self.Daydict objectForKey:key];
}

-(NSMutableDictionary*)getMonthDataByDate:(NSDate*)date{
    NSString* key = [self getMonthKeyfromDate:date];
    return [self.Monthdict objectForKey:key];
}
-(NSMutableDictionary*)getSleepDataByDate:(NSDate*)date{
    //获取前一天晚上9点到今早9点的睡眠数据，供界面使用
    NSDate * prevday = [date dateByAddingTimeInterval:-24*60*60];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
    NSTimeInterval timeZoneOffset = 0;
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd 21:00:00"];
    NSString * datebeginstr = [dateFormatter stringFromDate:prevday];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * datebegin = [[dateFormatter dateFromString:datebeginstr] dateByAddingTimeInterval:timeZoneOffset];
    NSLog(@"datebegin = %@",datebegin);
    NSTimeInterval starttimeinterval = [datebegin timeIntervalSince1970];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd 09:00:00"];
    NSString * dateendstr = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * dateend = [[dateFormatter dateFromString:dateendstr] dateByAddingTimeInterval:timeZoneOffset];
    NSLog(@"dateend = %@",dateend);
    
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and mode = %d",datebegin,dateend,HJT_STEP_MODE_SLEEP];
    
    [fetchRequest setPredicate:predicate];
    NSError* error = nil;
    NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"error");
    }
    
    //    int totalsteps = [[self.fetchedObjects valueForKeyPath:@"@sum.steps"] intValue];
    //   NSLog(@"IRKMainSleepViewController::getHistoryData fetchedobjects = %@", self.fetchedObjects);
    

    int awakecount = 0;
    int deepcount = 0;
    int lightcount = 0;
    NSMutableDictionary* sleepdict = [[NSMutableDictionary alloc] init];
    for (StepHistory* steps in fetchedObjects) {
        NSDate* date = steps.datetime;
        NSTimeInterval t1 = [date timeIntervalSince1970] - starttimeinterval;
        NSString* indexkey =[NSString stringWithFormat:@"%d", (int)t1/(10*60)];
        [sleepdict setObject:[NSNumber numberWithInt:steps.steps.intValue] forKey:indexkey];
        if (steps.steps.intValue <= HJT_SLEEP_MODE_LIGHT)
            deepcount += 1;
        else if (steps.steps.intValue <= HJT_SLEEP_MODE_AWAKE)
            lightcount+= 1;
        else
            awakecount +=1;
        
    }
    [sleepdict setObject:[NSNumber numberWithInt:deepcount] forKey:@"deepcount"];
    [sleepdict setObject:[NSNumber numberWithInt:lightcount] forKey:@"lightcount"];
    [sleepdict setObject:[NSNumber numberWithInt:awakecount] forKey:@"awakecount"];
    
    return sleepdict;
}

-(void)clearData{
//#ifdef CUSTOM_API2
    NSError* error= nil;
//    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary* bi = [[IRKCommonData SharedInstance] getBongInformation:[IRKCommonData SharedInstance].lastBongUUID];
    NSString* macid = @"";
    if (bi) {
        if ([bi.allKeys containsObject:BONGINFO_KEY_BLEADDR]) {
            macid = [bi objectForKey:BONGINFO_KEY_BLEADDR];
        }
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"uid = %@ and macid = %@",[IRKCommonData SharedInstance].uid, macid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject* obj in fetchedObjects) {
        [self.managedObjectContext deleteObject:obj];
    }
    
    entity = [NSEntityDescription entityForName:@"StepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    
    predicate = [NSPredicate predicateWithFormat:@"uid = %@ and macid = %@",[IRKCommonData SharedInstance].uid, macid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject* obj in fetchedObjects) {
        [self.managedObjectContext deleteObject:obj];
    }
    entity = [NSEntityDescription entityForName:@"StepHistory_Day" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    
    predicate = [NSPredicate predicateWithFormat:@"uid = %@ and macid = %@",[IRKCommonData SharedInstance].uid, macid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject* obj in fetchedObjects) {
        [self.managedObjectContext deleteObject:obj];
    }
    entity = [NSEntityDescription entityForName:@"StepHistory_Month" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    
    predicate = [NSPredicate predicateWithFormat:@"uid = %@ and macid = %@",[IRKCommonData SharedInstance].uid, macid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject* obj in fetchedObjects) {
        [self.managedObjectContext deleteObject:obj];
    }
    
    entity = [NSEntityDescription entityForName:@"SleepHistory_Hour" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    
    predicate = [NSPredicate predicateWithFormat:@"uid = %@ and macid = %@",[IRKCommonData SharedInstance].uid, macid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject* obj in fetchedObjects) {
        [self.managedObjectContext deleteObject:obj];
    }
    entity = [NSEntityDescription entityForName:@"SleepHistory_Day" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    
    predicate = [NSPredicate predicateWithFormat:@"uid = %@ and macid = %@",[IRKCommonData SharedInstance].uid, macid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject* obj in fetchedObjects) {
        [self.managedObjectContext deleteObject:obj];
    }
    entity = [NSEntityDescription entityForName:@"SleepHistory_Month" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    
    predicate = [NSPredicate predicateWithFormat:@"uid = %@ and macid = %@",[IRKCommonData SharedInstance].uid, macid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject* obj in fetchedObjects) {
        [self.managedObjectContext deleteObject:obj];
    }

    [self.managedObjectContext save:nil];
    [self reloadData];

//#else
//    NSError* error= nil;
//    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//
//    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]URLByAppendingPathComponent:@"SXRBand.sqlite"];
//    NSPersistentStore* store = [appdelegate.persistentStoreCoordinator persistentStoreForURL:storeURL];
//    [appdelegate.persistentStoreCoordinator removePersistentStore:store error:&error];
//    if (error) {
//        NSLog(@"delete error!!!%@",error);
//        return;
//    }
//    NSFileManager* fm = [[NSFileManager alloc]init];
//    [fm removeItemAtURL:storeURL error:&error];
//    if (error) {
//        NSLog(@"delete error!!!%@",error);
//        return;
//
//    }
//    
//    
//    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
//                                       NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES],
//                                       NSInferMappingModelAutomaticallyOption, nil];
//
//    
//    
//    
//    
//    if (![appdelegate.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error]) {
//         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    [self reloadData];
//#endif
    
}

-(Alarm*)getAlarmDataByType:(int)alarmtype byIndex:(int)index byMacid:(NSString*)macid byUid:(NSString*)uid{
    if (macid == nil || [macid isEqualToString:@""] || uid==nil) {
        return nil;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"macid=%@ and uid = %@ and type = %@ and alarm_id = %@", macid, uid,[NSNumber numberWithInt:alarmtype],[NSNumber numberWithInt:index]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"alarm_id" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSError* error = nil;
    NSArray* fetchArrar = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchArrar count]) {
        return [fetchArrar objectAtIndex:0];
    }else{
        return nil;
    }

}

-(NSInteger)getStepbyDate:(NSDate*)date{
    NSString* key = [self getDayKeyfromDate:date];
    if ([self.Daydict.allKeys containsObject:key]) {
        NSDictionary* info = [self.Daydict objectForKey:key];
        NSNumber* step = [info objectForKey:@"steps"];
        if(step){
            return step.integerValue;
        }else{
            return 0;
        }
    }
    return 0;
}



-(NSString*)get10MinuteKeyfromDate:(NSDate*)date{
    NSCalendar* calender = [NSCalendar currentCalendar];
    [calender setFirstWeekday:1];
    NSDateComponents* comp = [[NSDateComponents alloc] init];
    NSInteger unitflag = NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSYearCalendarUnit;
    comp = [calender components:unitflag fromDate:date];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH";
    return [NSString stringWithFormat:@"%@:%d",[format stringFromDate:date],(int)comp.minute/10];
    
}


-(void)syncnetworkok2:(NSNotification*)notify{
    if (notify.userInfo == nil) {
        return;
    }
    __block NSString* tablename = [notify.userInfo objectForKey:@"tablename"];
    
    dispatch_async(self.dataqueue, ^{
        NSLog(@"syncnetworkok2->[%@]",tablename);
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:tablename inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issync = %@ and uid = %@", [NSNumber numberWithBool:NO], self.commondata.uid];
        
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
            NSLog(@"syncnetworkok no data");
        }else{
            __block int count = 0;
            [fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                count++;
                StepHistory* record = (StepHistory*)obj;
                @try {
                    record.issync = [NSNumber numberWithBool:YES];
                }
                @catch (NSException *exception) {
                    NSLog(@"error record  = %@",record);
                }
                
            }];
            
        }
        [self saveDB];
        
    });
    
}
//////////for healthkit/////////////
-(void)syncHealthKitok2:(NSNotification*)notify{
    if (notify.userInfo == nil) {
        return;
    }
    __block NSString* tablename = [notify.userInfo objectForKey:@"tablename"];
    
    dispatch_async(self.dataqueue, ^{
        NSLog(@"syncHealthKitok2->[%@]",tablename);
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:tablename inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issynchealthkit = %@ and memberid = %@", [NSNumber numberWithBool:NO], self.commondata.memberid];
        if ([tablename isEqualToString:@"RunRecord"]) {
            predicate = [NSPredicate predicateWithFormat:@"issynchealthkit = %@ and memberid = %@ and closed == %@", [NSNumber numberWithBool:NO], self.commondata.memberid, [NSNumber numberWithInt:1]];
        }
        
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
            NSLog(@"syncnetworkok no data");
        }else{
            __block int count = 0;
            [fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                count++;
                @try {
//                    id record = NSClassFromString(tablename);
////                    StepHistory* record = (StepHistory*)obj;
                    [obj setValue:[NSNumber numberWithBool:YES] forKey:@"issynchealthkit"];
//                    record.issync = [NSNumber numberWithBool:YES];
                }
                @catch (NSException *exception) {
                    NSLog(@"error  = %@",exception);
                }
                
            }];
            
        }
        [self saveDB];
        
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


@end
