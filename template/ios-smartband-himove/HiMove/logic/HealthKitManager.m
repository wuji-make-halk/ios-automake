//
//  HealthKitManager.m
//  HiMove
//
//  Created by qf on 2017/9/6.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "HealthKitManager.h"
#import "StepHistory+CoreDataClass.h"
#import "RunRecord+CoreDataClass.h"
#import "Health_data_history+CoreDataClass.h"
#import <HealthKit/HealthKit.h>

@interface HealthKitManager()
@property (strong, nonatomic) IRKCommonData* commondata;
@property(nonatomic,strong) NSManagedObjectContext* stepContext;
@property(nonatomic,strong) dispatch_queue_t dispatchqueue;
@end

@implementation HealthKitManager
+(HealthKitManager *)SharedInstance
{
    static HealthKitManager *s = nil;
    if (s == nil) {
        s = [[HealthKitManager alloc] init];
    }
    return s;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.commondata = [IRKCommonData SharedInstance];
        //        self.mainloop = [MainLoop SharedInstance];
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        self.stepContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.stepContext.parentContext = appdelegate.managedObjectContext;
        self.dispatchqueue = dispatch_queue_create("com.wedobe.healthkitmanager", DISPATCH_QUEUE_SERIAL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proc_synctask:) name:notify_key_syncdata_to_healthkit object:nil];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proc_task:) name:notify_key_download_synckey_changed object:nil];
    }
    return self;
}

-(void)proc_synctask:(NSNotification*)notify{
    if (notify.userInfo == nil || [HKHealthStore isHealthDataAvailable] == NO) {
        return;
    }
    __block NSString* tablename = [notify.userInfo objectForKey:@"tablename"];
    
    dispatch_async(self.dispatchqueue, ^{
        NSLog(@"proc_synchealthkit->[%@]",tablename);
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:tablename inManagedObjectContext:self.stepContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issynchealthkit = %@ and memberid = %@", [NSNumber numberWithBool:NO], self.commondata.memberid];
        
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSError *error = nil;
        NSArray *fetchedObjects = [self.stepContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
            NSLog(@"proc_synchealthkit no data");
        }else{
            __block int count = 0;
            @try {
                [fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    count++;
                        //                    id record = NSClassFromString(tablename);
                        ////                    StepHistory* record = (StepHistory*)obj;
    //                    [obj setValue:[NSNumber numberWithBool:YES] forKey:@"issynchealthkit"];
                        //                    record.issync = [NSNumber numberWithBool:YES];
                        if ([tablename isEqualToString:@"StepHistory"]) {
                            StepHistory* record = (StepHistory*)obj;
                            //保存运动数据
                            HKHealthStore* healthStore = [[HKHealthStore alloc] init];

                            if (record.mode.intValue != HJT_STEP_MODE_SLEEP) {
                                if (record.steps.intValue == 0) {
                                    NSLog(@"[HealthKitManager] step == 0, return");
                                    return;
                                }
                                //保存步数
                                HKQuantityType *countUnitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                                if ([healthStore authorizationStatusForType:countUnitType] == HKAuthorizationStatusSharingAuthorized) {
                                    HKUnit *countUnit = [HKUnit countUnit];
                                    HKQuantity *countUnitQuantity = [HKQuantity quantityWithUnit:countUnit doubleValue:record.steps.doubleValue];
                                    HKQuantitySample *stepCountSample = [HKQuantitySample quantitySampleWithType:countUnitType quantity:countUnitQuantity startDate:record.datetime endDate:[record.datetime dateByAddingTimeInterval:10*60-1]];
                                    [healthStore saveObject:stepCountSample withCompletion:^(BOOL success, NSError *error) {
                                        if (!success) {
                                            NSLog(@"StepCount sample %@ error was: %@.", stepCountSample, error);
                                        }
                                    }];
                                    
                                }
                                //保存距离
                                HKQuantityType *distanceUnitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
                                if ([healthStore authorizationStatusForType:distanceUnitType] == HKAuthorizationStatusSharingAuthorized) {
                                    HKUnit *countUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo];
                                    //计算距离，Himove存的步距都是CM，所以这里只会产生m的数据
                                    double distance = record.steps.intValue * self.commondata.stride / 100000.0;
                                    HKQuantity *countUnitQuantity = [HKQuantity quantityWithUnit:countUnit doubleValue:distance];
                                    HKQuantitySample *stepCountSample = [HKQuantitySample quantitySampleWithType:distanceUnitType quantity:countUnitQuantity startDate:record.datetime endDate:[record.datetime dateByAddingTimeInterval:10*60-1]];
                                    [healthStore saveObject:stepCountSample withCompletion:^(BOOL success, NSError *error) {
                                        if (!success) {
                                            NSLog(@"DistanceWalkingRunning sample %@ error was: %@.", stepCountSample, error);
                                        }
                                    }];
                                    
                                }
                                //保存卡路里
                                HKQuantityType *calUnitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
                                if ([healthStore authorizationStatusForType:calUnitType] == HKAuthorizationStatusSharingAuthorized) {
                                    HKUnit *countUnit = [HKUnit unitFromEnergyFormatterUnit:NSEnergyFormatterUnitKilocalorie];
                                    //计算距离，Himove存的步距都是CM，所以这里只会产生m的数据
                                    double cal = [self.commondata getCal:record.steps.intValue];
                                    HKQuantity *countUnitQuantity = [HKQuantity quantityWithUnit:countUnit doubleValue:cal];
                                    HKQuantitySample *stepCountSample = [HKQuantitySample quantitySampleWithType:calUnitType quantity:countUnitQuantity startDate:record.datetime endDate:[record.datetime dateByAddingTimeInterval:10*60-1]];
                                    [healthStore saveObject:stepCountSample withCompletion:^(BOOL success, NSError *error) {
                                        if (!success) {
                                            NSLog(@"ActiveEnergyBurned sample %@ error was: %@.", stepCountSample, error);
                                        }
                                    }];
                                    
                                }
                            }else{
                                //保存睡眠数据
                                HKCategoryType *UnitType = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
                                if ([healthStore authorizationStatusForType:UnitType] == HKAuthorizationStatusSharingAuthorized) {

//                                    int sleepvalue = HKCategoryValueSleepAnalysisInBed;
                                    if (record.steps.intValue > HJT_SLEEP_MODE_AWAKE) {
                                        //超过awake的话就添加awak数据
                                        HKCategorySample* Sample = [HKCategorySample categorySampleWithType:UnitType value:HKCategoryValueSleepAnalysisAwake startDate:record.datetime endDate:[record.datetime dateByAddingTimeInterval:10*60-1]];
                                        [healthStore saveObject:Sample withCompletion:^(BOOL success, NSError *error) {
                                            if (!success) {
                                                NSLog(@"Sleep Analysis sample %@ error was: %@.", Sample, error);
                                            }
                                        }];

                                    }else{
                                        //否则添加成inbed数据
                                        HKCategorySample* Sample = [HKCategorySample categorySampleWithType:UnitType value:HKCategoryValueSleepAnalysisInBed startDate:record.datetime endDate:[record.datetime dateByAddingTimeInterval:10*60-1]];
                                        [healthStore saveObject:Sample withCompletion:^(BOOL success, NSError *error) {
                                            if (!success) {
                                                NSLog(@"Sleep Analysis sample %@ error was: %@.", Sample, error);
                                            }
                                        }];
                                        if (record.steps.intValue<HJT_SLEEP_MODE_LIGHT) {
                                            //深睡数据额外添加一层
                                            HKCategorySample* Sample = [HKCategorySample categorySampleWithType:UnitType value:HKCategoryValueSleepAnalysisAsleep startDate:record.datetime endDate:[record.datetime dateByAddingTimeInterval:10*60-1]];
                                            [healthStore saveObject:Sample withCompletion:^(BOOL success, NSError *error) {
                                                if (!success) {
                                                    NSLog(@"Sleep Analysis sample %@ error was: %@.", Sample, error);
                                                }
                                            }];

                                        }
                                    }
                                    
                                }

                            }


                        }else if([tablename isEqualToString:@"RunRecord"]){
                            RunRecord* record = (RunRecord*)obj;
                            if (record.totaltime.intValue == 0 || record.closed.intValue != 1) {
                                NSLog(@"[HealthKitManager]type = %d totaltime == 0 or closed != 1, return",record.type.intValue);
                                return;
                            }
                            NSLog(@"[HealthKitManager]RunRecord type = %d",record.type.intValue);
                            // Save the user's step count into HealthKit.
                            HKHealthStore* healthStore = [[HKHealthStore alloc] init];
                            if (record.type.intValue == SPORT_TYPE_RUNNING) {
                                if (record.totaldistance.floatValue > 0) {
                                    //保存运动距离
                                    HKQuantityType *countUnitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
                                    if ([healthStore authorizationStatusForType:countUnitType] == HKAuthorizationStatusSharingAuthorized) {
                                        HKUnit *countUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo];
                                        double distance = record.totaldistance.floatValue /1000.0;
                                        
                                        HKQuantity *countUnitQuantity = [HKQuantity quantityWithUnit:countUnit doubleValue:distance];
                                        HKQuantitySample *Sample = [HKQuantitySample quantitySampleWithType:countUnitType quantity:countUnitQuantity startDate:record.starttime endDate:[record.starttime dateByAddingTimeInterval:record.totaltime.doubleValue]];
                                        [healthStore saveObject:Sample withCompletion:^(BOOL success, NSError *error) {
                                            if (!success) {
                                                NSLog(@"RunDistance sample %@ error was: %@.", Sample, error);
                                            }
                                        }];
                                        
                                    }
                                    //保存卡路里
                                    HKQuantityType *calUnitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
                                    if ([healthStore authorizationStatusForType:calUnitType] == HKAuthorizationStatusSharingAuthorized) {
                                        HKUnit *countUnit = [HKUnit unitFromEnergyFormatterUnit:NSEnergyFormatterUnitKilocalorie];
                                        HKQuantity *countUnitQuantity = [HKQuantity quantityWithUnit:countUnit doubleValue:record.totalcalories.doubleValue];
                                        HKQuantitySample *stepCountSample = [HKQuantitySample quantitySampleWithType:calUnitType quantity:countUnitQuantity startDate:record.starttime endDate:[record.starttime dateByAddingTimeInterval:record.totaltime.doubleValue]];
                                        [healthStore saveObject:stepCountSample withCompletion:^(BOOL success, NSError *error) {
                                            if (!success) {
                                                NSLog(@"ActiveEnergyBurned sample %@ error was: %@.", stepCountSample, error);
                                            }
                                        }];
                                        
                                    }

                                    //增加训练计划
                                    HKWorkoutType *workoutType = [HKQuantityType workoutType];
                                    HKQuantity* totalcal = [HKQuantity quantityWithUnit:[HKUnit unitFromEnergyFormatterUnit:NSEnergyFormatterUnitKilocalorie] doubleValue:record.totalcalories.doubleValue];
                                    HKQuantity* totaldistance = [HKQuantity quantityWithUnit:[HKUnit unitFromLengthFormatterUnit:NSLengthFormatterUnitKilometer] doubleValue:record.totaldistance.doubleValue/1000.0];
                                    
                                                            
                                    if ([healthStore authorizationStatusForType:workoutType] == HKAuthorizationStatusSharingAuthorized) {
                                        HKWorkout* workout = [HKWorkout workoutWithActivityType:HKWorkoutActivityTypeRunning
                                                                                      startDate:record.starttime
                                                                                        endDate:[record.starttime dateByAddingTimeInterval:record.totaltime.doubleValue]
                                                                                       duration:record.totaltime.doubleValue
                                                                              totalEnergyBurned:totalcal
                                                                                  totalDistance:totaldistance
                                                                                       metadata:nil];

                                        [healthStore saveObject:workout withCompletion:^(BOOL success, NSError *error) {
                                            if (!success) {
                                                NSLog(@"Workout sample %@ error was: %@.", workout, error);
                                            }
                                        }];
                                        
                                    }

                                }
 
                            }else if(record.type.intValue == SPORT_TYPE_BICYCLE){
                                if (record.totaldistance.floatValue > 0) {
                                    HKQuantityType *countUnitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
                                    if ([healthStore authorizationStatusForType:countUnitType] == HKAuthorizationStatusSharingAuthorized) {
                                        HKUnit *countUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo];
                                        double distance = record.totaldistance.floatValue /1000.0;
                                        
                                        HKQuantity *countUnitQuantity = [HKQuantity quantityWithUnit:countUnit doubleValue:distance];
                                        HKQuantitySample *Sample = [HKQuantitySample quantitySampleWithType:countUnitType quantity:countUnitQuantity startDate:record.starttime endDate:[record.starttime dateByAddingTimeInterval:record.totaltime.doubleValue]];
                                        [healthStore saveObject:Sample withCompletion:^(BOOL success, NSError *error) {
                                            if (!success) {
                                                NSLog(@"RunDistance sample %@ error was: %@.", Sample, error);
                                            }
                                        }];
                                        
                                    }
                                    //保存卡路里
                                    HKQuantityType *calUnitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
                                    if ([healthStore authorizationStatusForType:calUnitType] == HKAuthorizationStatusSharingAuthorized) {
                                        HKUnit *countUnit = [HKUnit unitFromEnergyFormatterUnit:NSEnergyFormatterUnitKilocalorie];
                                        HKQuantity *countUnitQuantity = [HKQuantity quantityWithUnit:countUnit doubleValue:record.totalcalories.doubleValue];
                                        HKQuantitySample *stepCountSample = [HKQuantitySample quantitySampleWithType:calUnitType quantity:countUnitQuantity startDate:record.starttime endDate:[record.starttime dateByAddingTimeInterval:record.totaltime.doubleValue]];
                                        [healthStore saveObject:stepCountSample withCompletion:^(BOOL success, NSError *error) {
                                            if (!success) {
                                                NSLog(@"ActiveEnergyBurned sample %@ error was: %@.", stepCountSample, error);
                                            }
                                        }];
                                        
                                    }
                                    
                                   //增加训练计划
                                    HKWorkoutType *workoutType = [HKQuantityType workoutType];
                                    HKQuantity* totalcal = [HKQuantity quantityWithUnit:[HKUnit unitFromEnergyFormatterUnit:NSEnergyFormatterUnitKilocalorie] doubleValue:record.totalcalories.doubleValue];
                                    HKQuantity* totaldistance = [HKQuantity quantityWithUnit:[HKUnit unitFromLengthFormatterUnit:NSLengthFormatterUnitKilometer] doubleValue:record.totaldistance.doubleValue/1000.0];
                                    
                                    
                                    if ([healthStore authorizationStatusForType:workoutType] == HKAuthorizationStatusSharingAuthorized) {
                                        HKWorkout* workout = [HKWorkout workoutWithActivityType:HKWorkoutActivityTypeCycling
                                                                                      startDate:record.starttime
                                                                                        endDate:[record.starttime dateByAddingTimeInterval:record.totaltime.doubleValue]
                                                                                       duration:record.totaltime.doubleValue
                                                                              totalEnergyBurned:totalcal
                                                                                  totalDistance:totaldistance
                                                                                       metadata:nil];
                                        
                                        [healthStore saveObject:workout withCompletion:^(BOOL success, NSError *error) {
                                            if (!success) {
                                                NSLog(@"Workout sample %@ error was: %@.", workout, error);
                                            }
                                        }];
                                        
                                    }
                                    
                                }

                                
                            }else if(record.type.intValue == SPORT_TYPE_GPS_CLIMB){
                                if (record.totaldistance.floatValue > 0) {
                                    HKQuantityType *countUnitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
                                    if ([healthStore authorizationStatusForType:countUnitType] == HKAuthorizationStatusSharingAuthorized) {
                                        HKUnit *countUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo];
                                        double distance = record.totaldistance.floatValue /1000.0;
                                        
                                        HKQuantity *countUnitQuantity = [HKQuantity quantityWithUnit:countUnit doubleValue:distance];
                                        HKQuantitySample *Sample = [HKQuantitySample quantitySampleWithType:countUnitType quantity:countUnitQuantity startDate:record.starttime endDate:[record.starttime dateByAddingTimeInterval:record.totaltime.doubleValue]];
                                        [healthStore saveObject:Sample withCompletion:^(BOOL success, NSError *error) {
                                            if (!success) {
                                                NSLog(@"RunDistance sample %@ error was: %@.", Sample, error);
                                            }
                                        }];
                                        
                                    }
                                    //保存卡路里
                                    HKQuantityType *calUnitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
                                    if ([healthStore authorizationStatusForType:calUnitType] == HKAuthorizationStatusSharingAuthorized) {
                                        HKUnit *countUnit = [HKUnit unitFromEnergyFormatterUnit:NSEnergyFormatterUnitKilocalorie];
                                        HKQuantity *countUnitQuantity = [HKQuantity quantityWithUnit:countUnit doubleValue:record.totalcalories.doubleValue];
                                        HKQuantitySample *stepCountSample = [HKQuantitySample quantitySampleWithType:calUnitType quantity:countUnitQuantity startDate:record.starttime endDate:[record.starttime dateByAddingTimeInterval:record.totaltime.doubleValue]];
                                        [healthStore saveObject:stepCountSample withCompletion:^(BOOL success, NSError *error) {
                                            if (!success) {
                                                NSLog(@"ActiveEnergyBurned sample %@ error was: %@.", stepCountSample, error);
                                            }
                                        }];
                                        
                                    }
                                    
                                   //增加训练计划
                                    HKWorkoutType *workoutType = [HKQuantityType workoutType];
                                    HKQuantity* totalcal = [HKQuantity quantityWithUnit:[HKUnit unitFromEnergyFormatterUnit:NSEnergyFormatterUnitKilocalorie] doubleValue:record.totalcalories.doubleValue];
                                    HKQuantity* totaldistance = [HKQuantity quantityWithUnit:[HKUnit unitFromLengthFormatterUnit:NSLengthFormatterUnitKilometer] doubleValue:record.totaldistance.doubleValue/1000.0];
                                    
                                    
                                    if ([healthStore authorizationStatusForType:workoutType] == HKAuthorizationStatusSharingAuthorized) {
                                        HKWorkout* workout = [HKWorkout workoutWithActivityType:HKWorkoutActivityTypeClimbing
                                                                                      startDate:record.starttime
                                                                                        endDate:[record.starttime dateByAddingTimeInterval:record.totaltime.doubleValue]
                                                                                       duration:record.totaltime.doubleValue
                                                                              totalEnergyBurned:totalcal
                                                                                  totalDistance:totaldistance
                                                                                       metadata:nil];
                                        
                                        [healthStore saveObject:workout withCompletion:^(BOOL success, NSError *error) {
                                            if (!success) {
                                                NSLog(@"Workout sample %@ error was: %@.", workout, error);
                                            }
                                        }];
                                        
                                    }
                                    
                                }

                            }


                        }else if([tablename isEqualToString:@"Health_data_history"]){
                            Health_data_history* record = (Health_data_history*)obj;
                            if (record.value.intValue == 0 ) {
                                NSLog(@"[HealthKitManager] value == 0 return");
                                return;
                            }
                            HKHealthStore* healthStore = [[HKHealthStore alloc] init];
                            if (record.type.intValue == SENSOR_TYPE_SERVER_HEARTRATE) {
                                HKQuantityType *countUnitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
                                if ([healthStore authorizationStatusForType:countUnitType] == HKAuthorizationStatusSharingAuthorized) {
                                    HKUnit *countUnit = [HKUnit unitFromString:@"count/min"];
                                    HKQuantity *countUnitQuantity = [HKQuantity quantityWithUnit:countUnit doubleValue:record.value.doubleValue];
                                    HKQuantitySample *Sample = [HKQuantitySample quantitySampleWithType:countUnitType quantity:countUnitQuantity startDate:record.adddate endDate:[record.adddate dateByAddingTimeInterval:59]];
                                    [healthStore saveObject:Sample withCompletion:^(BOOL success, NSError *error) {
                                        if (!success) {
                                            NSLog(@"Heartrate sample %@ error was: %@.", Sample, error);
                                        }
                                    }];
                                    
                                }
                                
                            }else if(record.type.intValue == SENSOR_TYPE_SERVER_TEMPERATURE){
                                HKQuantityType *countUnitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
                                if ([healthStore authorizationStatusForType:countUnitType] == HKAuthorizationStatusSharingAuthorized) {
                                    HKUnit *countUnit = [HKUnit degreeCelsiusUnit];
                                    HKQuantity *countUnitQuantity = [HKQuantity quantityWithUnit:countUnit doubleValue:record.value.doubleValue];
                                    HKQuantitySample *Sample = [HKQuantitySample quantitySampleWithType:countUnitType quantity:countUnitQuantity startDate:record.adddate endDate:[record.adddate dateByAddingTimeInterval:59]];
                                    [healthStore saveObject:Sample withCompletion:^(BOOL success, NSError *error) {
                                        if (!success) {
                                            NSLog(@"Temperature sample %@ error was: %@.", Sample, error);
                                        }
                                    }];
                                    
                                }
              
                            }
                            // Save the user's step count into HealthKit.

                            
                        }
                    
                }];
                //通知DATACENTER修改已同步的标志位
                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_syncdata_to_healthkit_ok object:nil userInfo:@{@"tablename":tablename}];
            }
            @catch (NSException *exception) {
                NSLog(@"error  = %@",exception);
            }
           
        }
        
    });

}

@end
