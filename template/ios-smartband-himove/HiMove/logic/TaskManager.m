//
//  TaskManager.m
//  Yoo Fitness
//
//  Created by qf on 16/12/27.
//  Copyright © 2016年 Keeprapid. All rights reserved.
//

#import "TaskManager.h"
#import "TaskInfo+CoreDataClass.h"
#import "StepHistory+CoreDataClass.h"
#import "RunRecord+CoreDataClass.h"
#import "RunHistory+CoreDataClass.h"
#import "Health_data_history+CoreDataClass.h"


#import <AFNetworking.h>

@interface TaskManager()
@property(nonatomic,strong) NSManagedObjectContext* stepContext;
@property(nonatomic,assign) int run_task_count;
@property(nonatomic,strong) NSMutableDictionary* networktaskdict;
@property(nonatomic,strong) dispatch_queue_t dispatchqueue;
@property(nonatomic,strong) dispatch_queue_t dispatchtaskqueue;
@end
@implementation TaskManager
+(TaskManager *)SharedInstance
{
    static TaskManager *s = nil;
    if (s == nil) {
        s = [[TaskManager alloc] init];
    }
    return s;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.commondata = [IRKCommonData SharedInstance];
//        self.mainloop = [MainLoop SharedInstance];
        self.blecontrol = [BleControl SharedInstance];
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = appdelegate.managedObjectContext;
        
        self.stepContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.stepContext.parentContext = appdelegate.managedObjectContext;
        self.run_task_count = 0;
        self.dispatchqueue = dispatch_queue_create("com.wedobe.downloadmanager", DISPATCH_QUEUE_SERIAL);
        self.dispatchtaskqueue = dispatch_queue_create("com.wedobe.taskmanager", DISPATCH_QUEUE_SERIAL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proc_task:) name:notify_key_download_synckey_changed object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proc_task:) name:notify_key_download_synckey_changed object:nil];
       self.networktaskdict = [[NSMutableDictionary alloc] init];
     }
    return self;
}
-(void)CheckSyncKey:(NSDictionary*)bodyinfo{
    if (bodyinfo == nil || [bodyinfo respondsToSelector:@selector(objectForKey:)] == NO) {
        return;
    }
    NSString* synckeys = [bodyinfo objectForKey:RESPONE_KEY_SYNCKEY];
    NSLog(@"CheckSyncKey:%@",synckeys);
    
    if (synckeys && ![synckeys isEqualToString:@""]) {
        NSMutableDictionary* memberinfo = [self.commondata getMemberInfo:self.commondata.memberid];
        if (memberinfo == nil) {
            memberinfo = [[NSMutableDictionary alloc] init];
        }
        NSArray* synckeylist = [synckeys componentsSeparatedByString:@"|"];
        for (NSString* str in synckeylist) {
            NSArray* keyvaluelist = [str componentsSeparatedByString:@"_"];
            NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,keyvaluelist[0]];
            NSNumber* synckeyvalue = [NSNumber numberWithInt:[keyvaluelist[1] intValue]];
            
            NSNumber* currentsyncvalue = [memberinfo objectForKey:synckeystr];
            //            NSLog(@"currentsyncvalue = %@, synckeyvalue=%@, synckeystr=%@",currentsyncvalue,synckeyvalue,synckeystr);
            [memberinfo setObject:synckeyvalue forKey:synckeystr];
            if ((currentsyncvalue == nil || currentsyncvalue.intValue < synckeyvalue.intValue)&&synckeyvalue.intValue>0) {
                if ([synckeystr isEqualToString:SYNCKEY_MEMBERINFO]) {
                    if (currentsyncvalue) {
                        NSLog(@"post::notify_key_synckey_changed_memberinfo");
                        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_synckey_changed_memberinfo object:nil];
                    }
                }else if([synckeystr isEqualToString:SYNCKEY_FITNESS]){
                    if (currentsyncvalue) {
                        NSLog(@"post::notify_key_synckey_changed_fitness");
                        [[TaskManager SharedInstance] AddDownLoadTaskBySyncKey:synckeystr From:currentsyncvalue.intValue To:synckeyvalue.intValue];
                    }else{
                        NSLog(@"post::notify_key_synckey_changed_fitness");
                        [[TaskManager SharedInstance] AddDownLoadTaskBySyncKey:synckeystr From:0 To:synckeyvalue.intValue];
                    }
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed object:nil userInfo:@{@"synckey":synckeystr}];
                }else if([synckeystr isEqualToString:SYNCKEY_SLEEP]){
                    if (currentsyncvalue) {
                        NSLog(@"post::notify_key_synckey_changed_sleep");
                        [[TaskManager SharedInstance] AddDownLoadTaskBySyncKey:synckeystr From:currentsyncvalue.intValue To:synckeyvalue.intValue];
                    }else{
                        NSLog(@"post::notify_key_synckey_changed_sleep");
                        [[TaskManager SharedInstance] AddDownLoadTaskBySyncKey:synckeystr From:0 To:synckeyvalue.intValue];
                    }
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed object:nil userInfo:@{@"synckey":synckeystr}];
                }else if([synckeystr isEqualToString:SYNCKEY_RUNRECORD]){
                    if (currentsyncvalue) {
                        NSLog(@"post::notify_key_synckey_changed_runrecord");
                        [[TaskManager SharedInstance] AddDownLoadTaskBySyncKey:synckeystr From:currentsyncvalue.intValue To:synckeyvalue.intValue];
                    }else{
                        NSLog(@"post::notify_key_synckey_changed_runrecord");
                        [[TaskManager SharedInstance] AddDownLoadTaskBySyncKey:synckeystr From:0 To:synckeyvalue.intValue];
                    }
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed object:nil userInfo:@{@"synckey":synckeystr}];
                }else if([synckeystr isEqualToString:SYNCKEY_RUNHISTORY]){
                    if (currentsyncvalue) {
                        NSLog(@"post::notify_key_synckey_changed_runhistory");
                        [[TaskManager SharedInstance] AddDownLoadTaskBySyncKey:synckeystr From:currentsyncvalue.intValue To:synckeyvalue.intValue];
                    }else{
                        NSLog(@"post::notify_key_synckey_changed_runhistory");
                        [[TaskManager SharedInstance] AddDownLoadTaskBySyncKey:synckeystr From:0 To:synckeyvalue.intValue];
                    }
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed object:nil userInfo:@{@"synckey":synckeystr}];
                }else if([synckeystr isEqualToString:SYNCKEY_BODYFUNCTION]){
                    if (currentsyncvalue) {
                        NSLog(@"post::notify_key_synckey_changed_bodyfunction");
                        [[TaskManager SharedInstance] AddDownLoadTaskBySyncKey:synckeystr From:currentsyncvalue.intValue To:synckeyvalue.intValue];
                    }else{
                        NSLog(@"post::notify_key_synckey_changed_bodyfunction");
                        [[TaskManager SharedInstance] AddDownLoadTaskBySyncKey:synckeystr From:0 To:synckeyvalue.intValue];
                    }
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed object:nil userInfo:@{@"synckey":synckeystr}];
                }
                
            }else{
//                if([synckeystr isEqualToString:SYNCKEY_MEMBERINFO]){
//                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_sync_memberinfo_finish object:nil];
//                }
            }
            
        }
        //        NSLog(@"CheckSyncKey done %@",memberinfo);
//        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed object:nil userInfo:nil];
        
        [self.commondata setMemberInfo:self.commondata.memberid Information:memberinfo];
    }
    
}
-(void)saveDB{
    [self.stepContext performBlockAndWait:^{
        NSError *error;
        if (![self.stepContext save:&error])
        {
            // handle error
            NSLog(@"Datacenter::stepContext save error:%@",error);
        }
        
        // save parent to disk asynchronously
        [self.managedObjectContext performBlockAndWait:^{
            NSError *error;
            if (![self.managedObjectContext save:&error])
            {
                // handle error
                NSLog(@"Datacenter::managedObjectContext save error:%@",error);
            }
        }];
    }];
    
}

-(void)saveDB:(NSManagedObjectContext*)context{
    [context performBlockAndWait:^{
        NSError *error;
        if (![context save:&error])
        {
            // handle error
            NSLog(@"context save error:%@",error);
        }
        
        // save parent to disk asynchronously
        [context.parentContext performBlockAndWait:^{
            NSError *error;
            if (![context.parentContext save:&error])
            {
                // handle error
                NSLog(@"context.parentContext save error:%@",error);
            }
        }];
    }];
    
}

-(void)AddDownLoadTaskBySyncKey:(NSString*)synckey From:(int)beginkey To:(int)endkey{
    dispatch_async(self.dispatchtaskqueue, ^{
        NSLog(@"AddDownLoadTaskBySyncKey[%@]%d->%d",synckey,beginkey,endkey);
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskInfo" inManagedObjectContext:self.stepContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@ and synckey = %@ and targetkey = %@ and tasktype = %@", self.commondata.uid, synckey, [NSNumber numberWithInt:endkey], TASKTYPE_DOWNLOAD];
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSError *error = nil;
        NSArray *fetchedObjects = [self.stepContext executeFetchRequest:fetchRequest error:&error];
        //    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
            NSLog(@"Add task ok");
            TaskInfo* record = [NSEntityDescription insertNewObjectForEntityForName:@"TaskInfo" inManagedObjectContext:self.stepContext];
            record.memberid = self.commondata.memberid;
            record.uid = self.commondata.uid;
            record.tasktype = TASKTYPE_DOWNLOAD;
            record.startkey = [NSNumber numberWithInt:beginkey];
            record.currentkey = [NSNumber numberWithInt:beginkey];
            record.targetkey = [NSNumber numberWithInt:endkey];
            record.taskid = [self.commondata gen_uuid];
            if ([synckey isEqualToString:SYNCKEY_FITNESS]) {
                record.datatype = DATATYPE_FITNESS;
            }else if ([synckey isEqualToString:SYNCKEY_BODYFUNCTION]){
                record.datatype = DATATYPE_BODYFUNCTION;
            }else if ([synckey isEqualToString:SYNCKEY_SLEEP]){
                record.datatype = DATATYPE_SLEEP;
            }else if ([synckey isEqualToString:SYNCKEY_RUNRECORD]){
                record.datatype = DATATYPE_RUNRECORD;
            }else if ([synckey isEqualToString:SYNCKEY_RUNHISTORY]){
                record.datatype = DATATYPE_RUNHISTORY;
            }
            record.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            record.filename = @"";
            record.synckey = synckey;
            record.createdate = [NSDate date];
            [self saveDB];
        }else{
            NSLog(@"Task already exist");
//            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed object:nil userInfo:nil];

    });
    
}
-(void)AddUpLoadTaskBySyncKey:(NSString*)synckey{
    dispatch_async(self.dispatchtaskqueue, ^{
        NSLog(@"AddUpLoadTaskBySyncKey[%@]",synckey);
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskInfo" inManagedObjectContext:self.stepContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@ and synckey = %@ and tasktype = %@ and state <> %@", self.commondata.uid, synckey, TASKTYPE_UPLOAD, [NSNumber numberWithInt:TASKSTATE_FINISH]];
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSError *error = nil;
        NSArray *fetchedObjects = [self.stepContext executeFetchRequest:fetchRequest error:&error];
        //    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
            NSLog(@"Add task ok");
            TaskInfo* record = [NSEntityDescription insertNewObjectForEntityForName:@"TaskInfo" inManagedObjectContext:self.stepContext];
            record.memberid = self.commondata.memberid;
            record.uid = self.commondata.uid;
            record.tasktype = TASKTYPE_UPLOAD;
            record.startkey = [NSNumber numberWithInt:0];
            record.currentkey = [NSNumber numberWithInt:0];
            record.targetkey = [NSNumber numberWithInt:0];
            record.taskid = [self.commondata gen_uuid];
            if ([synckey isEqualToString:SYNCKEY_FITNESS]) {
                record.datatype = DATATYPE_FITNESS;
            }else if ([synckey isEqualToString:SYNCKEY_BODYFUNCTION]){
                record.datatype = DATATYPE_BODYFUNCTION;
            }else if ([synckey isEqualToString:SYNCKEY_SLEEP]){
                record.datatype = DATATYPE_SLEEP;
            }else if ([synckey isEqualToString:SYNCKEY_RUNHISTORY]){
                record.datatype = DATATYPE_RUNHISTORY;
            }else if ([synckey isEqualToString:SYNCKEY_RUNRECORD]){
                record.datatype = DATATYPE_RUNRECORD;
            }
            record.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            record.filename = @"";
            record.synckey = synckey;
            record.createdate = [NSDate date];
            [self saveDB];
        }else{
            NSLog(@"Task already exist");
//            return;
        }
//        if (self.run_task_count < MAX_TASK_NUMBER) {
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed object:nil];
//            return;
//        }
    });
}


-(TaskInfo*)getTaskInfo{
//    NSLog(@"getTaskInfo [%@:%@]",synckey,taskType);
//    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    Context.parentContext = appdelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskInfo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@ and synckey=%@", self.commondata.uid,SYNCKEY_FITNESS];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@ and state = %@", self.commondata.uid, [NSNumber numberWithInt:TASKSTATE_WAITING]];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdate" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    // Specify how the fetched objects should be sorted
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    //    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        return nil;
    }else{
        for (TaskInfo* taskinfo in fetchedObjects) {
            NSLog(@"task[%@:%@],target=%d,current=%d,state=%d",taskinfo.tasktype,taskinfo.datatype,taskinfo.targetkey.intValue,taskinfo.currentkey.intValue,taskinfo.state.intValue);
        }
        return [fetchedObjects firstObject];
    }
}


-(TaskInfo*)getTaskInfoByNetworkTaskID:(NSUInteger)networktaskid ByPrefix:(NSString*)prefix ByContext:(NSManagedObjectContext*)context{
    NSString* taskid = [self.networktaskdict objectForKey:[NSString stringWithFormat:@"%@:%lu",prefix,(unsigned long)networktaskid]];
    if (taskid == nil || [taskid isEqualToString:@""]) {
        return nil;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskInfo" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskid=%@", taskid];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    //    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        return nil;
    }else{
        return [fetchedObjects firstObject];
    }
   
}

-(TaskInfo*)getTaskInfoByTaskID:(NSString*)taskid ByContex:(NSManagedObjectContext*)contex{
    if (taskid == nil || [taskid isEqualToString:@""] || contex == nil) {
        return nil;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskInfo" inManagedObjectContext:contex];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskid=%@", taskid];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [contex executeFetchRequest:fetchRequest error:&error];
    //    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        return nil;
    }else{
        return [fetchedObjects firstObject];
    }
    
}


-(void)proc_task:(NSNotification*)notify{
    if (self.run_task_count >= MAX_TASK_NUMBER) {
        NSLog(@"TaskManager::current task count > %d",MAX_TASK_NUMBER);
        return;
    }
    self.run_task_count +=1;
    TaskInfo* taskinfo = [self getTaskInfo];
    NSLog(@"taskinfo[%@]",taskinfo.tasktype);
    if (taskinfo == nil) {
        //任务执行完成，通知界面刷新
        self.run_task_count -=1;
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_sync_networkdata_finish object:nil];
        return;
    }
    if ([taskinfo.tasktype isEqualToString:TASKTYPE_DOWNLOAD]) {
        if ([taskinfo.synckey isEqualToString:SYNCKEY_FITNESS]) {
            [self download_fitness:taskinfo.taskid];
        }else if ([taskinfo.synckey isEqualToString:SYNCKEY_BODYFUNCTION]) {
            [self download_bodyfunction:taskinfo.taskid];
//        }else if ([taskinfo.synckey isEqualToString:SYNCKEY_SLEEP]) {
//            [self download_sleep:taskinfo.taskid];
        }else if ([taskinfo.synckey isEqualToString:SYNCKEY_RUNRECORD]) {
            [self download_runrecord:taskinfo.taskid];
        }else if ([taskinfo.synckey isEqualToString:SYNCKEY_RUNHISTORY]) {
            [self download_runhistory:taskinfo.taskid];
        }

    }else{
        if ([taskinfo.synckey isEqualToString:SYNCKEY_FITNESS]) {
            [self upload_fitness:taskinfo.taskid];
        }else if ([taskinfo.synckey isEqualToString:SYNCKEY_BODYFUNCTION]) {
            [self upload_bodyfunction:taskinfo.taskid];
//        }else if ([taskinfo.synckey isEqualToString:SYNCKEY_SLEEP]) {
//            [self upload_sleep:taskinfo.taskid];
        }else if ([taskinfo.synckey isEqualToString:SYNCKEY_RUNRECORD]) {
            [self upload_runrecord:taskinfo.taskid];
        }else if ([taskinfo.synckey isEqualToString:SYNCKEY_RUNHISTORY]) {
            [self upload_runhistory:taskinfo.taskid];
        }

    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_syncnetwork_data object:nil];
}

-(void)download_fitness:(id)taskobj{
    NSLog(@"download_fitness");
    dispatch_async(self.dispatchqueue, ^{
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        Context.parentContext = appdelegate.managedObjectContext;

        TaskInfo* taskinfo = (TaskInfo*)[self getTaskInfoByTaskID:taskobj ByContex:Context];
        if(taskinfo == nil){
            NSLog(@"download_fitness no taskinfo");
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];

            return;
        }
//        if (taskinfo.state.intValue == TASKSTATE_PROCEEDING) {
//            NSLog(@"download_fitness task in proceed");
//            return;
//            
//        }
//        taskinfo.state = [NSNumber numberWithInt:TASKSTATE_PROCEEDING];
//        [self saveDB];
//        self.run_task_count +=1;
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"ZZZZZ";
        
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString* url = [NSString stringWithFormat:@"%@%@",SERVER_URL,DATACENTER_URL];
        NSDictionary* paramlist = @{ACTION_KEY_CMDNAME:ACTION_CMD_DOWNLOADFITNESS,
                                    ACTION_KEY_VERSION:PROTOCOL_VERSION,
                                    ACTION_KEY_SEQID:[self.commondata getSeqid],
                                    ACTION_KEY_BODY:@{
                                            ACTION_KEY_VID:self.commondata.vid,
                                            ACTION_KEY_TID:self.commondata.token,
                                            ACTION_KEY_DID:[self.commondata getdid],
                                            ACTION_KEY_UID:self.commondata.uid,
                                            ACTION_KEY_DATATYPE:DATATYPE_FITNESS,
                                            ACTION_KEY_SYNCKEY:[NSNumber numberWithInt:taskinfo.currentkey.intValue],
                                            ACTION_KEY_TARGETKEY:[NSNumber numberWithInt:taskinfo.targetkey.intValue],
                                            ACTION_KEY_TIMEZONE:[format stringFromDate:[NSDate date]]
                                            }
                                    };
        //    NSLog(@"%@",paramlist);
        NSURLSessionDataTask* networktask = [manager POST:url parameters:paramlist progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"download_fitness JSON: %@", responseObject);
            
            NSDictionary* retdict = (NSDictionary*)responseObject;
            NSString* errcode = [retdict objectForKey:RESPONE_KEY_ERRORCODE];
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"fitness" ByContext:Context];
            BOOL isfinish = NO;
            if (errcode){
                if([errcode isEqualToString:ERROR_CODE_OK]) {
                    NSDictionary* body = [retdict objectForKey:RESPONE_KEY_BODY];
                    if (body) {
                        NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
                        if (synckey) {
                            NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
//                            NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
                            NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
                            taskinfo.currentkey = [NSNumber numberWithInt:syncvalue.intValue];
                            
                            if (syncvalue.intValue >= taskinfo.targetkey.intValue) {
                                //说明下载完成了
                                isfinish = YES;
                                
                            }else{
                                isfinish = NO;
                            }
//                            [self saveDB];
                        }
                        NSArray* datalist = [body objectForKey:RESPONE_KEY_DATALIST];
                        [self syncFitnessDBTask:datalist ByContext:Context];
                        
                    }
                    
                }
            }
            if (isfinish) {
                taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
            }else{
                taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            }
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
           
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"download_fitness Error: %@", error);
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"fitness" ByContext:Context];
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        }];
        if (networktask != nil) {
            [self.networktaskdict setObject:taskinfo.taskid forKey:[NSString stringWithFormat:@"fitness:%lu",(unsigned long)networktask.taskIdentifier]];

        }
        
    });
}

-(void)download_sleep:(id)taskobj{
    NSLog(@"download_sleep");
    dispatch_async(self.dispatchqueue, ^{
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        Context.parentContext = appdelegate.managedObjectContext;
        TaskInfo* taskinfo = (TaskInfo*)[self getTaskInfoByTaskID:taskobj ByContex:Context];
        if(taskinfo == nil){
            NSLog(@"download_sleep no taskinfo");
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];

            return;
        }
//        self.run_task_count +=1;
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"ZZZZZ";
        
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString* url = [NSString stringWithFormat:@"%@%@",SERVER_URL,DATACENTER_URL];
        NSDictionary* paramlist = @{ACTION_KEY_CMDNAME:ACTION_CMD_DOWNLOADSLEEP,
                                    ACTION_KEY_VERSION:PROTOCOL_VERSION,
                                    ACTION_KEY_SEQID:[self.commondata getSeqid],
                                    ACTION_KEY_BODY:@{
                                            ACTION_KEY_VID:self.commondata.vid,
                                            ACTION_KEY_TID:self.commondata.token,
                                            ACTION_KEY_DID:[self.commondata getdid],
                                            ACTION_KEY_UID:self.commondata.uid,
                                            ACTION_KEY_DATATYPE:DATATYPE_SLEEP,
                                            ACTION_KEY_SYNCKEY:[NSNumber numberWithInt:taskinfo.currentkey.intValue],
                                            ACTION_KEY_TARGETKEY:[NSNumber numberWithInt:taskinfo.targetkey.intValue],
                                            ACTION_KEY_TIMEZONE:[format stringFromDate:[NSDate date]]
                                            }
                                    };
        //    NSLog(@"%@",paramlist);
        NSURLSessionDataTask* networktask = [manager POST:url parameters:paramlist progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"download_sleep JSON: %@", responseObject);
            NSDictionary* retdict = (NSDictionary*)responseObject;
            NSString* errcode = [retdict objectForKey:RESPONE_KEY_ERRORCODE];
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"sleep" ByContext:Context];
            BOOL isfinish = NO;
            if (errcode){
                if([errcode isEqualToString:ERROR_CODE_OK]) {
                    NSDictionary* body = [retdict objectForKey:RESPONE_KEY_BODY];
                    if (body) {
                        NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
                        if (synckey) {
                            NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
                            //                            NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
                            NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
                            taskinfo.currentkey = [NSNumber numberWithInt:syncvalue.intValue];
                            
                            if (syncvalue.intValue >= taskinfo.targetkey.intValue) {
                                //说明下载完成了
                                isfinish = YES;
                                
                            }else{
                                isfinish = NO;
                            }
                            //                            [self saveDB];
                        }
                        NSArray* datalist = [body objectForKey:RESPONE_KEY_DATALIST];
                        [self syncSleepDBTask:datalist ByContext:Context];
                        
                    }
                    
                }
            }
            if (isfinish) {
                taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
            }else{
                taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            }
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"download_sleep Error: %@", error);
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"sleep" ByContext:Context];
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        }];
        if (networktask != nil) {
            [self.networktaskdict setObject:taskinfo.taskid forKey:[NSString stringWithFormat:@"sleep:%lu",(unsigned long)networktask.taskIdentifier]];
            
        }
        

    });
}
-(void)download_runrecord:(id)taskobj{
    NSLog(@"download_runrecord");
    dispatch_async(self.dispatchqueue, ^{
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        Context.parentContext = appdelegate.managedObjectContext;
        TaskInfo* taskinfo = (TaskInfo*)[self getTaskInfoByTaskID:taskobj ByContex:Context];
        if(taskinfo == nil){
            NSLog(@"download_runrecord no taskinfo");
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];

            return;
        }
//        self.run_task_count +=1;
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"ZZZZZ";
        
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString* url = [NSString stringWithFormat:@"%@%@",SERVER_URL,DATACENTER_URL];
        NSDictionary* paramlist = @{ACTION_KEY_CMDNAME:ACTION_CMD_DOWNLOAD_RUNRECORD,
                                    ACTION_KEY_VERSION:PROTOCOL_VERSION,
                                    ACTION_KEY_SEQID:[self.commondata getSeqid],
                                    ACTION_KEY_BODY:@{
                                            ACTION_KEY_VID:self.commondata.vid,
                                            ACTION_KEY_TID:self.commondata.token,
                                            ACTION_KEY_DID:[self.commondata getdid],
                                            ACTION_KEY_UID:self.commondata.uid,
                                            ACTION_KEY_DATATYPE:DATATYPE_RUNRECORD,
                                            ACTION_KEY_SYNCKEY:[NSNumber numberWithInt:taskinfo.currentkey.intValue],
                                            ACTION_KEY_TARGETKEY:[NSNumber numberWithInt:taskinfo.targetkey.intValue],
                                            ACTION_KEY_TIMEZONE:[format stringFromDate:[NSDate date]]
                                            }
                                    };
        //    NSLog(@"%@",paramlist);
        NSURLSessionDataTask* networktask = [manager POST:url parameters:paramlist progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"download_runrecord JSON: %@", responseObject);
            NSDictionary* retdict = (NSDictionary*)responseObject;
            NSString* errcode = [retdict objectForKey:RESPONE_KEY_ERRORCODE];
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"runrecord" ByContext:Context];
            BOOL isfinish = NO;
            if (errcode){
                if([errcode isEqualToString:ERROR_CODE_OK]) {
                    NSDictionary* body = [retdict objectForKey:RESPONE_KEY_BODY];
                    if (body) {
                        NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
                        if (synckey) {
                            NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
                            //                            NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
                            NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
                            taskinfo.currentkey = [NSNumber numberWithInt:syncvalue.intValue];
                            
                            if (syncvalue.intValue >= taskinfo.targetkey.intValue) {
                                //说明下载完成了
                                isfinish = YES;
                                
                            }else{
                                isfinish = NO;
                            }
                            //                            [self saveDB];
                        }
                        NSArray* datalist = [body objectForKey:RESPONE_KEY_DATALIST];
                        [self syncRunRecordDBTask:datalist ByContext:Context];
                        
                    }
                    
                }
            }
            if (isfinish) {
                taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
            }else{
                taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            }
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"download_runrecord Error: %@", error);
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"runrecord" ByContext:Context];
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        }];
        if (networktask != nil) {
            [self.networktaskdict setObject:taskinfo.taskid forKey:[NSString stringWithFormat:@"runrecord:%lu",(unsigned long)networktask.taskIdentifier]];
            
        }
        

    });
}
-(void)download_runhistory:(id)taskobj{
    NSLog(@"download_runhistory");
    dispatch_async(self.dispatchqueue, ^{
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        Context.parentContext = appdelegate.managedObjectContext;
        TaskInfo* taskinfo = (TaskInfo*)[self getTaskInfoByTaskID:taskobj ByContex:Context];
        if(taskinfo == nil){
            NSLog(@"download_bonus no taskinfo");
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];

            return;
        }
//        self.run_task_count +=1;
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"ZZZZZ";
        
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString* url = [NSString stringWithFormat:@"%@%@",SERVER_URL,DATACENTER_URL];
        NSDictionary* paramlist = @{ACTION_KEY_CMDNAME:ACTION_CMD_DOWNLOAD_RUNHISTORY,
                                    ACTION_KEY_VERSION:PROTOCOL_VERSION,
                                    ACTION_KEY_SEQID:[self.commondata getSeqid],
                                    ACTION_KEY_BODY:@{
                                            ACTION_KEY_VID:self.commondata.vid,
                                            ACTION_KEY_TID:self.commondata.token,
                                            ACTION_KEY_DID:[self.commondata getdid],
                                            ACTION_KEY_UID:self.commondata.uid,
                                            ACTION_KEY_DATATYPE:DATATYPE_RUNHISTORY,
                                            ACTION_KEY_SYNCKEY:[NSNumber numberWithInt:taskinfo.currentkey.intValue],
                                            ACTION_KEY_TARGETKEY:[NSNumber numberWithInt:taskinfo.targetkey.intValue],
                                            ACTION_KEY_TIMEZONE:[format stringFromDate:[NSDate date]]
                                            }
                                    };
        //    NSLog(@"%@",paramlist);
        NSURLSessionDataTask* networktask = [manager POST:url parameters:paramlist progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"download_runhistory JSON: %@", responseObject);
            NSDictionary* retdict = (NSDictionary*)responseObject;
            NSString* errcode = [retdict objectForKey:RESPONE_KEY_ERRORCODE];
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"runhistory" ByContext:Context];
            BOOL isfinish = NO;
            if (errcode){
                if([errcode isEqualToString:ERROR_CODE_OK]) {
                    NSDictionary* body = [retdict objectForKey:RESPONE_KEY_BODY];
                    if (body) {
                        NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
                        if (synckey) {
                            NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
                            //                            NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
                            NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
                            taskinfo.currentkey = [NSNumber numberWithInt:syncvalue.intValue];
                            
                            if (syncvalue.intValue >= taskinfo.targetkey.intValue) {
                                //说明下载完成了
                                isfinish = YES;
                                
                            }else{
                                isfinish = NO;
                            }
                            //                            [self saveDB];
                        }
                        NSArray* datalist = [body objectForKey:RESPONE_KEY_DATALIST];
                        [self syncRunHistoryDBTask:datalist ByContext:Context];
                        
                    }
                    
                }
            }
            if (isfinish) {
                taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
            }else{
                taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            }
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"download_runhistory Error: %@", error);
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"runhistory" ByContext:Context];
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        }];
        if (networktask != nil) {
            [self.networktaskdict setObject:taskinfo.taskid forKey:[NSString stringWithFormat:@"runhistory:%lu",(unsigned long)networktask.taskIdentifier]];
            
        }
        

    });
}
-(void)download_bodyfunction:(id)taskobj{
    NSLog(@"download_bodyfunction");
    dispatch_async(self.dispatchqueue, ^{
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        Context.parentContext = appdelegate.managedObjectContext;
        TaskInfo* taskinfo = (TaskInfo*)[self getTaskInfoByTaskID:taskobj ByContex:Context];
        if(taskinfo == nil){
            NSLog(@"download_challenge no taskinfo");
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];

            return;
        }
        //        if (taskinfo.state.intValue == TASKSTATE_PROCEEDING) {
        //            NSLog(@"download_fitness task in proceed");
        //            return;
        //
        //        }
        //        taskinfo.state = [NSNumber numberWithInt:TASKSTATE_PROCEEDING];
        //        [self saveDB];
//        self.run_task_count +=1;
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"ZZZZZ";
        
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString* url = [NSString stringWithFormat:@"%@%@",SERVER_URL,DATACENTER_URL];
        NSDictionary* paramlist = @{ACTION_KEY_CMDNAME:ACTION_CMD_DOWNLOAD_BODYFUNCTION,
                                    ACTION_KEY_VERSION:PROTOCOL_VERSION,
                                    ACTION_KEY_SEQID:[self.commondata getSeqid],
                                    ACTION_KEY_BODY:@{
                                            ACTION_KEY_VID:self.commondata.vid,
                                            ACTION_KEY_TID:self.commondata.token,
                                            ACTION_KEY_DID:[self.commondata getdid],
                                            ACTION_KEY_UID:self.commondata.uid,
                                            ACTION_KEY_DATATYPE:DATATYPE_BODYFUNCTION,
                                            ACTION_KEY_SYNCKEY:[NSNumber numberWithInt:taskinfo.currentkey.intValue],
                                            ACTION_KEY_TARGETKEY:[NSNumber numberWithInt:taskinfo.targetkey.intValue],
                                            ACTION_KEY_TIMEZONE:[format stringFromDate:[NSDate date]]
                                            }
                                    };
        //    NSLog(@"%@",paramlist);
        NSURLSessionDataTask* networktask = [manager POST:url parameters:paramlist progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"download_bodyfunction JSON: %@", responseObject);
            NSDictionary* retdict = (NSDictionary*)responseObject;
            NSString* errcode = [retdict objectForKey:RESPONE_KEY_ERRORCODE];
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"bodyfunction" ByContext:Context];
            BOOL isfinish = NO;
            if (errcode){
                if([errcode isEqualToString:ERROR_CODE_OK]) {
                    NSDictionary* body = [retdict objectForKey:RESPONE_KEY_BODY];
                    if (body) {
                        NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
                        if (synckey) {
                            NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
                            //                            NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
                            NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
                            taskinfo.currentkey = [NSNumber numberWithInt:syncvalue.intValue];
                            
                            if (syncvalue.intValue >= taskinfo.targetkey.intValue) {
                                //说明下载完成了
                                isfinish = YES;
                                
                            }else{
                                isfinish = NO;
                            }
                            //                            [self saveDB];
                        }
                        NSArray* datalist = [body objectForKey:RESPONE_KEY_DATALIST];
                        [self syncBodyFunctionDBTask:datalist ByContext:Context];
                        
                    }
                    
                }
            }
            if (isfinish) {
                taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
            }else{
                taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            }
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"download_bodyfunction Error: %@", error);
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"bodyfunction" ByContext:Context];
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        }];
        if (networktask != nil) {
            [self.networktaskdict setObject:taskinfo.taskid forKey:[NSString stringWithFormat:@"bodyfunction:%lu",(unsigned long)networktask.taskIdentifier]];
            
        }
        

    });
}


-(void)syncFitnessDBTask:(NSArray*)jsonArray ByContext:(NSManagedObjectContext*)context{
    @try{
        if ([jsonArray count] == 0) {
            NSLog(@"syncFitnessDBTask:jsonArray empty");
            return;
        }
        NSError* error = nil;
        __block NSTimeInterval maxtimestamp = 0;
        __block NSTimeInterval mintimestamp = 0;
        [jsonArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary* datainfo = (NSDictionary*)obj;
            NSTimeInterval timestamp = [[datainfo objectForKey:ACTION_KEY_TIMESTAMP] doubleValue];
            if (timestamp > maxtimestamp) {
                maxtimestamp = timestamp;
            }
            if (timestamp < mintimestamp || mintimestamp == 0) {
                mintimestamp = timestamp;
            }
        }];
        
        NSFetchRequest *fetchDataRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *dataEntity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:context];
        [fetchDataRequest setEntity:dataEntity];
        // Specify criteria for filtering which objects to fetch
        NSDate* begindate = [NSDate dateWithTimeIntervalSince1970:mintimestamp];
        NSDate* enddate = [NSDate dateWithTimeIntervalSince1970:maxtimestamp];
        NSLog(@"syncFitnessDBTask begin = %@ end = %@",begindate,enddate);
        NSPredicate *dataPredicate = [NSPredicate predicateWithFormat:@"datetime between {%@,%@} and uid = %@", begindate, enddate,self.commondata.uid];
        
        [fetchDataRequest setPredicate:dataPredicate];
        NSArray *fetchedObjects = [context executeFetchRequest:fetchDataRequest error:&error];
        __block NSMutableDictionary* existdatadict = [[NSMutableDictionary alloc] init];
        if (fetchedObjects != nil) {
            [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                StepHistory* record = (StepHistory*)obj;
                NSString* key = [NSString stringWithFormat:@"%@:%.0f",record.macid,[record.datetime timeIntervalSince1970]];
                [existdatadict setObject:record forKey:key];
            }];
        }
        //入库
        [jsonArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary* datainfo = (NSDictionary*)obj;
            NSString* macid = [datainfo objectForKey:ACTION_KEY_MACID];
            if (macid == nil) {
                macid = @"";
            }
            macid = [macid uppercaseString];
            NSNumber* cal = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_CALORIES]) {
                cal = [datainfo objectForKey:ACTION_KEY_CALORIES];
            }
            NSNumber* distance = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_DISTANCE]) {
                distance = [datainfo objectForKey:ACTION_KEY_DISTANCE];
            }
            //与服务器做适配，模式要做转换
            NSNumber* mode = [NSNumber numberWithInt:HJT_STEP_MODE_DAILY];
            if ([datainfo.allKeys containsObject:ACTION_KEY_MODE]) {
                NSNumber* srvmode = [datainfo objectForKey:ACTION_KEY_MODE];
                switch (srvmode.intValue) {
                    case SERVER_STEP_MODE_SLEEP:
                        mode = [NSNumber numberWithInt:HJT_STEP_MODE_SLEEP];
                        break;
                    case SERVER_STEP_MODE_STEP:
                        mode = [NSNumber numberWithInt:HJT_STEP_MODE_DAILY];
                        break;
                    case SERVER_STEP_MODE_RUN:
                        mode = [NSNumber numberWithInt:HJT_STEP_MODE_SPORT];
                        break;
                    default:
                        //不同步异常数据
                        return;
                        break;
                }
//                mode = [datainfo objectForKey:ACTION_KEY_MODE];
            }
            NSNumber* steps = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_STEP]) {
                steps = [datainfo objectForKey:ACTION_KEY_STEP];
            }
            NSNumber* heartrate = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_HEARTRATE]) {
                heartrate = [datainfo objectForKey:ACTION_KEY_HEARTRATE];
            }
            NSNumber* type = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_TYPE]) {
                type = [datainfo objectForKey:ACTION_KEY_TYPE];
            }
            NSNumber* timestamp = [datainfo objectForKey:ACTION_KEY_TIMESTAMP];
            NSDate* datetime = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
            
            NSString* key = [NSString stringWithFormat:@"%@:%.0f",macid,[timestamp doubleValue]];
            if ([existdatadict.allKeys containsObject:key]) {
                StepHistory* record = [existdatadict objectForKey:key];
                record.steps = [NSNumber numberWithInt:steps.intValue];
                //                    record.ismmfsync = [NSNumber numberWithBool:ismmfsync.boolValue];
                //                    record.isvdsync = [NSNumber numberWithBool:isvdsync.boolValue];
                record.issync = [NSNumber numberWithBool:YES];
                //////////for healthkit/////////////
//                re
            }else{
                
                StepHistory* record = [NSEntityDescription insertNewObjectForEntityForName:@"StepHistory" inManagedObjectContext:context];
                record.cal = [NSNumber numberWithInt:cal.floatValue];
                record.datetime = [datetime copy];
                record.distance = [NSNumber numberWithInt:distance.intValue];
                record.issync = [NSNumber numberWithBool:YES];
                record.heartrate = heartrate;
                record.macid = macid;
                record.mode = [NSNumber numberWithInt:mode.intValue];
                record.steps = [NSNumber numberWithInt:steps.intValue];
                record.type = [NSNumber numberWithInt:type.intValue];
                record.uid = self.commondata.uid;
                record.memberid = self.commondata.memberid;
                //////////for healthkit/////////////
                record.issynchealthkit = [NSNumber numberWithBool:YES];
//                NSLog(@"new record = %@",record);
            }
            
        }];
        [self saveDB:context];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
}

-(void)syncRunRecordDBTask:(NSArray*)jsonArray ByContext:(NSManagedObjectContext*)context{
    @try{
        if ([jsonArray count] == 0) {
            NSLog(@"syncRunRecordDBTask:jsonArray empty");
            return;
        }
        NSError* error = nil;
        __block NSTimeInterval maxtimestamp = 0;
        __block NSTimeInterval mintimestamp = 0;
        [jsonArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary* datainfo = (NSDictionary*)obj;
            NSTimeInterval timestamp = [[datainfo objectForKey:ACTION_KEY_STARTTIMESTAMP] doubleValue];
            if (timestamp > maxtimestamp) {
                maxtimestamp = timestamp;
            }
            if (timestamp < mintimestamp || mintimestamp == 0) {
                mintimestamp = timestamp;
            }
        }];
        
        NSFetchRequest *fetchDataRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *dataEntity = [NSEntityDescription entityForName:@"RunRecord" inManagedObjectContext:context];
        [fetchDataRequest setEntity:dataEntity];
        // Specify criteria for filtering which objects to fetch
        NSDate* begindate = [[NSDate dateWithTimeIntervalSince1970:mintimestamp] dateByAddingTimeInterval:-1];
        NSDate* enddate = [[NSDate dateWithTimeIntervalSince1970:maxtimestamp] dateByAddingTimeInterval:1];
        NSLog(@"syncRunRecordDBTask begin = %@ end = %@",begindate,enddate);
        NSPredicate *dataPredicate = [NSPredicate predicateWithFormat:@"starttime between {%@,%@} and uid = %@", begindate, enddate,self.commondata.uid];
        
        [fetchDataRequest setPredicate:dataPredicate];
        NSArray *fetchedObjects = [context executeFetchRequest:fetchDataRequest error:&error];
        __block NSMutableDictionary* existdatadict = [[NSMutableDictionary alloc] init];
        if (fetchedObjects != nil) {
            [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                RunRecord* record = (RunRecord*)obj;
                NSString* key = [NSString stringWithFormat:@"%@",record.running_id];
                [existdatadict setObject:record forKey:key];
            }];
        }
        //入库
        [jsonArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary* datainfo = (NSDictionary*)obj;
            if (![datainfo.allKeys containsObject:ACTION_KEY_STARTTIMESTAMP] ||
                ![datainfo.allKeys containsObject:ACTION_KEY_ADDTIMESTAMP]) {
                NSLog(@"no addtimestamp");
                return;
            }
            NSNumber*  addtimestamp= [datainfo objectForKey:ACTION_KEY_ADDTIMESTAMP];
            NSNumber*  starttimestamp= [datainfo objectForKey:ACTION_KEY_STARTTIMESTAMP];
            NSString* runningid = @"";
            if ([datainfo.allKeys containsObject:ACTION_KEY_RUNNINGID]) {
                runningid = [datainfo objectForKey:ACTION_KEY_RUNNINGID];
            }
            NSString* macid = @"";
            if ([datainfo.allKeys containsObject:ACTION_KEY_MACID]) {
                macid = [datainfo objectForKey:ACTION_KEY_MACID];
            }
            macid = [macid uppercaseString];
            NSNumber* closed = @1;
            if ([datainfo.allKeys containsObject:ACTION_KEY_CLOSED]) {
                closed = [datainfo objectForKey:ACTION_KEY_CLOSED];
            }
            NSNumber* pace = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_PACE]) {
                pace = [datainfo objectForKey:ACTION_KEY_PACE];
            }
            
            NSNumber* totalcalories = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_TOTALCALORIES]) {
                totalcalories = [datainfo objectForKey:ACTION_KEY_TOTALCALORIES];
            }
            NSNumber* totaldistance = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_TOTALDISTANCE]) {
                totaldistance = [datainfo objectForKey:ACTION_KEY_TOTALDISTANCE];
            }
            NSNumber* totalstep = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_TOTALSTEP]) {
                totalstep = [datainfo objectForKey:ACTION_KEY_TOTALSTEP];
            }
            NSNumber* totaltime = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_TOTALTIME]) {
                totaltime = [datainfo objectForKey:ACTION_KEY_TOTALTIME];
            }
            NSNumber* type = [NSNumber numberWithInt:SPORT_TYPE_RUNNING];
            if ([datainfo.allKeys containsObject:ACTION_KEY_TYPE]) {
                NSNumber* tmptype = [datainfo objectForKey:ACTION_KEY_TYPE];
                switch (tmptype.intValue) {
                    case SERVER_TYPE_ROPE:
                        type = [NSNumber numberWithInt:SERVER_TYPE_ROPE];
                        break;
                    case SERVER_TYPE_JACK:
                        type = [NSNumber numberWithInt:SPORT_TYPE_JACK];
                        break;
                    case SERVER_TYPE_SITUP:
                        type = [NSNumber numberWithInt:SPORT_TYPE_SITUP];
                        break;
                    case SERVER_TYPE_TREADMILL:
                        type = [NSNumber numberWithInt:SPORT_TYPE_TREADMILL];
                        break;
                    case SERVER_TYPE_GPS_RUN:
                        type = [NSNumber numberWithInt:SPORT_TYPE_RUNNING];
                        break;
                    case SERVER_TYPE_GPS_BIKE:
                        type = [NSNumber numberWithInt:SPORT_TYPE_BICYCLE];
                        break;
                    case SERVER_TYPE_GPS_CLIMB:
                        type = [NSNumber numberWithInt:SPORT_TYPE_GPS_CLIMB];
                        break;
                    case SERVER_TYPE_BAND_SWIM:
                        type = [NSNumber numberWithInt:SPORT_TYPE_BAND_SWIM];
                        break;
                    case SERVER_TYPE_BAND_BIKE:
                        type = [NSNumber numberWithInt:SPORT_TYPE_BAND_BICYCLE];
                        break;
                        
                    default:
                        break;
                }

            }
            
            NSDate* adddatetime = [NSDate dateWithTimeIntervalSince1970:addtimestamp.doubleValue];
            NSDate* startdatetime = [NSDate dateWithTimeIntervalSince1970:starttimestamp.doubleValue];

            if ([existdatadict.allKeys containsObject:runningid]) {
                RunRecord* record = [existdatadict objectForKey:runningid];
                record.closed = closed;
                record.issync = [NSNumber numberWithBool:YES];
                record.totalstep = totalstep;
                record.totalcalories = totalcalories;
                record.totaldistance = totaldistance;
                record.totaltime = totaltime;
                record.pace = pace;
            }else{
                
                RunRecord* record = [NSEntityDescription insertNewObjectForEntityForName:@"RunRecord" inManagedObjectContext:context];
                record.adddate = adddatetime;
                record.closed = closed;
                record.issync = [NSNumber numberWithBool:YES];
                record.macid = macid;
                record.memberid = self.commondata.memberid;
                record.pace = pace;
                record.running_id = runningid;
                record.starttimestamp = starttimestamp;
                record.starttime = startdatetime;
                record.totalcalories = totalcalories;
                record.totaldistance = totaldistance;
                record.totalstep = totalstep;
                record.totaltime = totaltime;
                record.type = type;
                record.uid = self.commondata.uid;
                //////////for healthkit/////////////
                record.issynchealthkit = [NSNumber numberWithBool:YES];
//                NSLog(@"new record = %@",record);
            }
            
        }];
        [self saveDB:context];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    

}
-(void)syncSleepDBTask:(NSArray*)jsonArray ByContext:(NSManagedObjectContext*)context{
//    @try{
//
//    }
//    @catch (NSException *exception) {
//        NSLog(@"%@",exception);
//    }
    

}
-(void)syncRunHistoryDBTask:(NSArray*)jsonArray ByContext:(NSManagedObjectContext*)context{
    @try{
        if ([jsonArray count] == 0) {
            NSLog(@"syncRunHistoryDBTask jsonArray empty");
            return;
        }
        NSError* error = nil;
        __block NSTimeInterval maxtimestamp = 0;
        __block NSTimeInterval mintimestamp = 0;
        [jsonArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary* datainfo = (NSDictionary*)obj;
            NSTimeInterval timestamp = [[datainfo objectForKey:ACTION_KEY_ADDTIMESTAMP] doubleValue];
            if (timestamp > maxtimestamp) {
                maxtimestamp = timestamp;
            }
            if (timestamp < mintimestamp || mintimestamp == 0) {
                mintimestamp = timestamp;
            }
        }];
        
        NSFetchRequest *fetchDataRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *dataEntity = [NSEntityDescription entityForName:@"RunHistory" inManagedObjectContext:context];
        [fetchDataRequest setEntity:dataEntity];
        // Specify criteria for filtering which objects to fetch
        NSDate* begindate = [NSDate dateWithTimeIntervalSince1970:mintimestamp];
        NSDate* enddate = [NSDate dateWithTimeIntervalSince1970:maxtimestamp];
        NSLog(@"syncRunHistoryDBTask begin = %@ end = %@",begindate,enddate);
        NSPredicate *dataPredicate = [NSPredicate predicateWithFormat:@"adddate between {%@,%@} and uid = %@", begindate, enddate,self.commondata.uid];
        
        [fetchDataRequest setPredicate:dataPredicate];
        NSArray *fetchedObjects = [context executeFetchRequest:fetchDataRequest error:&error];
        __block NSMutableDictionary* existdatadict = [[NSMutableDictionary alloc] init];
        if (fetchedObjects != nil) {
            [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                RunHistory* record = (RunHistory*)obj;
                NSString* key = [NSString stringWithFormat:@"%@:%.0f",record.running_id,[record.adddate timeIntervalSince1970]];
                [existdatadict setObject:record forKey:key];
            }];
        }
        //入库
        [jsonArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary* datainfo = (NSDictionary*)obj;
            if (![datainfo.allKeys containsObject:ACTION_KEY_RUNNINGID] ||
                ![datainfo.allKeys containsObject:ACTION_KEY_ADDTIMESTAMP]) {
                NSLog(@"no addtimestamp,running_id");
                return;
            }
            NSNumber*  addtimestamp= [datainfo objectForKey:ACTION_KEY_ADDTIMESTAMP];
            NSString* runningid = [datainfo objectForKey:ACTION_KEY_RUNNINGID];
            
            NSString* macid  = @"";
            if ([datainfo.allKeys containsObject:ACTION_KEY_MACID]) {
                macid = [datainfo objectForKey:ACTION_KEY_MACID];
            }
            macid = [macid uppercaseString];
            
            NSNumber* altitude = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_ALTITUDE]) {
                altitude = [datainfo objectForKey:ACTION_KEY_ALTITUDE];
            }
            NSNumber* direction = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_DIRECTION]) {
                direction = [datainfo objectForKey:ACTION_KEY_DIRECTION];
            }
            NSNumber* latitude = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_LATITUDE]) {
                latitude = [datainfo objectForKey:ACTION_KEY_LATITUDE];
            }
            NSNumber* locType = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_LOCTYPE]) {
                locType = [datainfo objectForKey:ACTION_KEY_LOCTYPE];
            }
            NSNumber* longitude = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_LONGITUDE]) {
                longitude = [datainfo objectForKey:ACTION_KEY_LONGITUDE];
            }
            NSNumber* radius = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_RADIUS]) {
                radius = [datainfo objectForKey:ACTION_KEY_RADIUS];
            }
            NSNumber* satellite_number = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_SATELLITENUMBER]) {
                satellite_number = [datainfo objectForKey:ACTION_KEY_SATELLITENUMBER];
            }
            NSNumber* speed = @0;
            if ([datainfo.allKeys containsObject:ACTION_KEY_SPEED]) {
                speed = [datainfo objectForKey:ACTION_KEY_SPEED];
            }
            NSDate* adddatetime = [NSDate dateWithTimeIntervalSince1970:[addtimestamp doubleValue]];
            
            NSString* key = [NSString stringWithFormat:@"%@:%.0f",runningid,[adddatetime timeIntervalSince1970]];
            if ([existdatadict.allKeys containsObject:key]) {
                RunHistory* record = [existdatadict objectForKey:key];
                record.issync = [NSNumber numberWithBool:YES];
            }else{
                
                RunHistory* record = [NSEntityDescription insertNewObjectForEntityForName:@"RunHistory" inManagedObjectContext:context];
                record.adddate = adddatetime;
                record.addtimestamp = addtimestamp;
                record.altitude = altitude;
                record.direction = direction;
                record.issync = [NSNumber numberWithBool:YES];
                record.latitude = latitude;
                record.locType = locType;
                record.longitude = longitude;
                record.macid = macid;
                record.memberid = self.commondata.memberid;
                record.radius = radius;
                record.running_id = runningid;
                record.satellite_number = satellite_number;
                record.speed = speed;
                record.uid = self.commondata.uid;
//                NSLog(@"new record = %@",record);
            }
            
        }];
        [self saveDB:context];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    

}
-(void)syncBodyFunctionDBTask:(NSArray*)jsonArray ByContext:(NSManagedObjectContext*)context{
    @try{
        if ([jsonArray count] == 0) {
            NSLog(@"syncBodyFunctionDBTask jsonArray empty");
            return;
        }
        NSError* error = nil;
        __block NSTimeInterval maxtimestamp = 0;
        __block NSTimeInterval mintimestamp = 0;
        [jsonArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary* datainfo = (NSDictionary*)obj;
            NSTimeInterval timestamp = [[datainfo objectForKey:ACTION_KEY_TIMESTAMP] doubleValue];
            if (timestamp > maxtimestamp) {
                maxtimestamp = timestamp;
            }
            if (timestamp < mintimestamp || mintimestamp == 0) {
                mintimestamp = timestamp;
            }
        }];
        
        NSFetchRequest *fetchDataRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *dataEntity = [NSEntityDescription entityForName:@"Health_data_history" inManagedObjectContext:context];
        [fetchDataRequest setEntity:dataEntity];
        // Specify criteria for filtering which objects to fetch
        NSDate* begindate = [NSDate dateWithTimeIntervalSince1970:mintimestamp];
        NSDate* enddate = [NSDate dateWithTimeIntervalSince1970:maxtimestamp];
        NSLog(@"syncBodyFunctionDBTask begin = %@ end = %@",begindate,enddate);
        NSPredicate *dataPredicate = [NSPredicate predicateWithFormat:@"adddate between {%@,%@} and uid = %@", begindate, enddate,self.commondata.uid];
        
        [fetchDataRequest setPredicate:dataPredicate];
        NSArray *fetchedObjects = [context executeFetchRequest:fetchDataRequest error:&error];
        __block NSMutableDictionary* existdatadict = [[NSMutableDictionary alloc] init];
        if (fetchedObjects != nil) {
            [fetchedObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                Health_data_history* record = (Health_data_history*)obj;
                NSString* key = [NSString stringWithFormat:@"%d:%.0f",record.type.intValue,[record.adddate timeIntervalSince1970]];
                [existdatadict setObject:record forKey:key];
            }];
        }
        //入库
        [jsonArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary* datainfo = (NSDictionary*)obj;
            if (![datainfo.allKeys containsObject:ACTION_KEY_TYPE] ||
                ![datainfo.allKeys containsObject:ACTION_KEY_TIMESTAMP]||
                ![datainfo.allKeys containsObject:ACTION_KEY_VALUE]) {
                NSLog(@"no timestamp,type,value");
                return;
            }
            NSNumber*  timestamp= [datainfo objectForKey:ACTION_KEY_TIMESTAMP];
            NSNumber* type = [datainfo objectForKey:ACTION_KEY_TYPE];
            NSNumber* value = [datainfo objectForKey:ACTION_KEY_VALUE];
            NSNumber* value2 = [datainfo objectForKey:ACTION_KEY_VALUE2];
            if (value2 == nil) {
                value2 = @0;
            }
            NSString* macid  = @"";
            if ([datainfo.allKeys containsObject:ACTION_KEY_MACID]) {
                macid = [datainfo objectForKey:ACTION_KEY_MACID];
            }
            macid = [macid uppercaseString];
            
            NSString* key = [NSString stringWithFormat:@"%d:%.0f",type.intValue,[timestamp doubleValue]];
            if ([existdatadict.allKeys containsObject:key]) {
                Health_data_history* record = [existdatadict objectForKey:key];
                record.type = type;
                record.value = value;
                record.value2 = value2;
                record.issync = [NSNumber numberWithBool:YES];
            }else{
                
                Health_data_history* record = [NSEntityDescription insertNewObjectForEntityForName:@"Health_data_history" inManagedObjectContext:context];
                record.adddate = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
                record.issync = [NSNumber numberWithBool:YES];
                record.macid = macid;
                record.uid = self.commondata.uid;
                record.memberid = self.commondata.memberid;
                record.type = type;
                record.value = value;
                record.value2 = value2;
                //////////for healthkit/////////////
                record.issynchealthkit = [NSNumber numberWithBool:YES];
//                NSLog(@"new record = %@",record);
            }
            
        }];
        [self saveDB:context];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    

}

-(void)upload_fitness:(id)taskobj{
    NSLog(@"upload_fitness");
    dispatch_async(self.dispatchqueue, ^{
        if (self.commondata.is_login == NO) {
            NSLog(@"upload_fitness need login state.");
            return;
        }
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        Context.parentContext = appdelegate.managedObjectContext;
        TaskInfo* taskinfo = (TaskInfo*)[self getTaskInfoByTaskID:taskobj ByContex:Context];
        if(taskinfo == nil){
            NSLog(@"upload_fitness no taskinfo");
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];

            return;
        }
        
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"ZZZZZ";
        NSDateFormatter* format1 = [[NSDateFormatter alloc] init];
        [format1 setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
        format1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        format1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
        
        NSMutableArray* datalist = [[NSMutableArray alloc] init];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"StepHistory" inManagedObjectContext:Context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issync = %@ and uid = %@", [NSNumber numberWithBool:NO], self.commondata.uid];
        
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSError *error = nil;
        NSArray *fetchedObjects = [Context executeFetchRequest:fetchRequest error:&error];
        //    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
            NSLog(@"Fitness no data");
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
            [self saveDB:Context];
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];

            return;
        }else{
//            self.run_task_count +=1;

            for (StepHistory* record in fetchedObjects) {
                NSMutableDictionary* datainfo = [[NSMutableDictionary alloc] init];
                NSString* macid = record.macid;
                if (macid == nil) {
                    macid = @"";
                }
                macid = [macid uppercaseString];
                
                [datainfo setObject:macid forKey:ACTION_KEY_MACID];
                [datainfo setObject:[NSNumber numberWithInt:record.steps.intValue] forKey:ACTION_KEY_STEP];
                [datainfo setObject:[NSNumber numberWithFloat:record.cal.floatValue] forKey:ACTION_KEY_CALORIES];
                [datainfo setObject:[NSNumber numberWithFloat:record.distance.floatValue] forKey:ACTION_KEY_DISTANCE];
                NSNumber* mode = @0;
                if (record.mode.intValue == HJT_STEP_MODE_DAILY) {
                    mode = [NSNumber numberWithInt:SERVER_STEP_MODE_STEP];
                }else if (record.mode.intValue == HJT_STEP_MODE_SPORT){
                    mode = [NSNumber numberWithInt:SERVER_STEP_MODE_RUN];
                }else if (record.mode.intValue == HJT_STEP_MODE_SLEEP){
                    mode = [NSNumber numberWithInt:SERVER_STEP_MODE_SLEEP];
                }else{
                    continue;
                }
                [datainfo setObject:mode forKey:ACTION_KEY_MODE];
                [datainfo setObject:[NSNumber numberWithInt:record.type.intValue] forKey:ACTION_KEY_TYPE];
                [datainfo setObject:[NSNumber numberWithDouble:[[NSString stringWithFormat:@"%.0f",[record.datetime timeIntervalSince1970]] doubleValue]] forKey:ACTION_KEY_TIMESTAMP];
                [datainfo setObject:[NSNumber numberWithInt:60*10] forKey:ACTION_KEY_DURATION];
                [datainfo setObject:[NSNumber numberWithInt:record.heartrate.intValue] forKey:ACTION_KEY_HEARTRATE];
                [datainfo setObject:[format stringFromDate:[NSDate date]] forKey:ACTION_KEY_TIMEZONE];
                [datainfo setObject:[format1 stringFromDate:record.datetime] forKey:ACTION_KEY_DATETIME];
                
                [datalist addObject:datainfo];
            }
        }
        
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString* url = [NSString stringWithFormat:@"%@%@",SERVER_URL,DATACENTER_URL];
        NSDictionary* paramlist = @{ACTION_KEY_CMDNAME:ACTION_CMD_UPLOADFITNESS,
                                    ACTION_KEY_VERSION:PROTOCOL_VERSION,
                                    ACTION_KEY_SEQID:[self.commondata getSeqid],
                                    ACTION_KEY_BODY:@{
                                            ACTION_KEY_VID:self.commondata.vid,
                                            ACTION_KEY_TID:self.commondata.token,
                                            ACTION_KEY_DID:[self.commondata getdid],
                                            ACTION_KEY_UID:self.commondata.uid,
                                            ACTION_KEY_DATATYPE:DATATYPE_FITNESS,
                                            ACTION_KEY_TIMEZONE:[format stringFromDate:[NSDate date]],
                                            ACTION_KEY_DATALIST:datalist,
                                            }
                                    };
        //    NSLog(@"%@",paramlist);
        NSURLSessionDataTask* networktask = [manager POST:url parameters:paramlist progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"upload_fitness JSON: %@", responseObject);
            NSDictionary* retdict = (NSDictionary*)responseObject;
            NSString* errcode = [retdict objectForKey:RESPONE_KEY_ERRORCODE];
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"fitness" ByContext:Context];

            if (errcode){
                if([errcode isEqualToString:ERROR_CODE_OK]) {
                    NSDictionary* body = [retdict objectForKey:RESPONE_KEY_BODY];
                    if (body) {
                        NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
                        if (synckey) {
                            NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
                            NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
                            NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
                            NSMutableDictionary* memberinfo = [self.commondata getMemberInfo:self.commondata.memberid];
                            [memberinfo setObject:syncvalue forKey:synckeystr];
                            [self.commondata setMemberInfo:self.commondata.memberid Information:memberinfo];
                            
                        }
                        taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
                        [self saveDB:Context];

                        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_syncdata_to_network_ok
                                                                            object:nil
                                                                          userInfo:@{
                                                                                     @"tablename":@"StepHistory"
                                                                                     }];
                        
                    }
                }
            }
            
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"upload_fitness Error: %@", error);
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"fitness" ByContext:Context];
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        }];
        if (networktask != nil) {
            [self.networktaskdict setObject:taskinfo.taskid forKey:[NSString stringWithFormat:@"fitness:%lu",(unsigned long)networktask.taskIdentifier]];
            
        }

    });
}

//-(void)upload_sleep:(id)taskobj{
//    NSLog(@"upload_sleep");
//    dispatch_async(self.dispatchqueue, ^{
//        if (self.commondata.is_login == NO) {
//            NSLog(@"upload_sleep need login state.");
//            return;
//        }
//        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//        NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//        Context.parentContext = appdelegate.managedObjectContext;
//        TaskInfo* taskinfo = (TaskInfo*)[self getTaskInfoByTaskID:taskobj ByContex:Context];
//        if(taskinfo == nil){
//            NSLog(@"upload_sleep no taskinfo");
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
//                                                                object:nil
//                                                              userInfo:nil];
//            return;
//        }
//        NSDateFormatter* format = [[NSDateFormatter alloc] init];
//        format.dateFormat = @"ZZZZZ";
//        NSDateFormatter* format1 = [[NSDateFormatter alloc] init];
//        format1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
//        NSMutableArray* datalist = [[NSMutableArray alloc] init];
//        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SleepHistory" inManagedObjectContext:Context];
//        [fetchRequest setEntity:entity];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issync = %@ and uid = %@", [NSNumber numberWithBool:NO], self.commondata.uid];
//        //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@",self.commondata.uid];
//        
//        [fetchRequest setPredicate:predicate];
//        // Specify how the fetched objects should be sorted
//        NSError *error = nil;
//        NSArray *fetchedObjects = [Context executeFetchRequest:fetchRequest error:&error];
//        //    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
//            NSLog(@"Sleep no data");
//            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
//            [self saveDB:Context];
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
//                                                                object:nil
//                                                              userInfo:nil];
//            return;
//        }else{
//            self.run_task_count +=1;
//            for (SleepHistory* record in fetchedObjects) {
//                NSMutableDictionary* datainfo = [[NSMutableDictionary alloc] init];
//                [datainfo setObject:record.macid forKey:ACTION_KEY_MACID];
//                [datainfo setObject:[NSNumber numberWithInt:record.count.intValue] forKey:ACTION_KEY_COUNT];
//                [datainfo setObject:[NSNumber numberWithInt:record.state.intValue] forKey:ACTION_KEY_SLEEPSTATE];
//                [datainfo setObject:[NSNumber numberWithDouble:[[NSString stringWithFormat:@"%.0f",[record.datetime timeIntervalSince1970]] doubleValue]] forKey:ACTION_KEY_TIMESTAMP];
//                [datainfo setObject:[NSNumber numberWithInt:60] forKey:ACTION_KEY_DURATION];
//                [datainfo setObject:[format stringFromDate:[NSDate date]] forKey:ACTION_KEY_TIMEZONE];
//                [datainfo setObject:[format1 stringFromDate:record.datetime] forKey:ACTION_KEY_DATETIME];
//                [datalist addObject:datainfo];
//            }
//        }
//        
//        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
//        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.responseSerializer = [AFJSONResponseSerializer serializer];
//        manager.requestSerializer = [AFJSONRequestSerializer serializer];
//        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        NSString* url = [NSString stringWithFormat:@"%@%@",SERVER_URL,DATACENTER_URL];
//        NSDictionary* paramlist = @{ACTION_KEY_CMDNAME:ACTION_CMD_UPLOADSLEEP,
//                                    ACTION_KEY_VERSION:PROTOCOL_VERSION,
//                                    ACTION_KEY_SEQID:[self.commondata getSeqid],
//                                    ACTION_KEY_BODY:@{
//                                            ACTION_KEY_VID:self.commondata.vid,
//                                            ACTION_KEY_TID:self.commondata.token,
//                                            ACTION_KEY_DID:[self.commondata getdid],
//                                            ACTION_KEY_UID:self.commondata.uid,
//                                            ACTION_KEY_DATATYPE:DATATYPE_SLEEP,
//                                            ACTION_KEY_TIMEZONE:[format stringFromDate:[NSDate date]],
//                                            ACTION_KEY_DATALIST:datalist,
//                                            }
//                                    };
//        //    NSLog(@"%@",paramlist);
//        NSURLSessionDataTask* networktask = [manager POST:url parameters:paramlist progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"upload_sleep JSON: %@", responseObject);
//            NSDictionary* retdict = (NSDictionary*)responseObject;
//            NSString* errcode = [retdict objectForKey:RESPONE_KEY_ERRORCODE];
//            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//            Context.parentContext = appdelegate.managedObjectContext;
//            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"sleep" ByContext:Context];
//            
//            if (errcode){
//                if([errcode isEqualToString:ERROR_CODE_OK]) {
//                    NSDictionary* body = [retdict objectForKey:RESPONE_KEY_BODY];
//                    if (body) {
//                        NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
//                        if (synckey) {
//                            NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
//                            NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
//                            NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
//                            NSMutableDictionary* memberinfo = [self.commondata getCurrentMemberInfo:self.commondata.memberid];
//                            [memberinfo setObject:syncvalue forKey:synckeystr];
//                            [self.commondata setCurrentMemberInfo:self.commondata.memberid Information:memberinfo];
//                            
//                        }
//                        taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
//                        [self saveDB:Context];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_syncdata_to_network_ok
//                                                                            object:nil
//                                                                          userInfo:@{
//                                                                                     @"tablename":@"SleepHistory"
//                                                                                     }];
//                        
//                    }
//                }
//            }
//            self.run_task_count -= 1;
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
//                                                                object:nil
//                                                              userInfo:nil];
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"upload_sleep Error: %@", error);
//            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//            Context.parentContext = appdelegate.managedObjectContext;
//            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"sleep" ByContext:Context];
//            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
//            [self saveDB:Context];
//            self.run_task_count -= 1;
//            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
//                                                                object:nil
//                                                              userInfo:nil];
//        }];
//
//        if (networktask != nil) {
//            [self.networktaskdict setObject:taskinfo.taskid forKey:[NSString stringWithFormat:@"sleep:%lu",(unsigned long)networktask.taskIdentifier]];
//            
//        }
//    });
//   
//}

-(void)upload_runrecord:(id)taskobj{
    NSLog(@"upload_runrecord");
    dispatch_async(self.dispatchqueue, ^{
        if (self.commondata.is_login == NO) {
            NSLog(@"upload_runrecord need login state.");
            return;
        }
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        Context.parentContext = appdelegate.managedObjectContext;
        TaskInfo* taskinfo = (TaskInfo*)[self getTaskInfoByTaskID:taskobj ByContex:Context];
        if(taskinfo == nil){
            NSLog(@"upload_runrecord no taskinfo");
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];

            return;
        }
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"ZZZZZ";
//        NSDateFormatter* format1 = [[NSDateFormatter alloc] init];
//        format1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSMutableArray* datalist = [[NSMutableArray alloc] init];

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunRecord" inManagedObjectContext:Context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issync = %@ and uid = %@", [NSNumber numberWithBool:NO], self.commondata.uid];
        
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSError *error = nil;
        NSArray *fetchedObjects = [Context executeFetchRequest:fetchRequest error:&error];
        //    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
            NSLog(@"upload_runrecord no data");
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
            [self saveDB:Context];
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];

            return;
        }else{
//            self.run_task_count +=1;
            for (RunRecord* record in fetchedObjects) {
                NSMutableDictionary* datainfo = [[NSMutableDictionary alloc] init];
                [datainfo setObject:[record.macid uppercaseString] forKey:ACTION_KEY_MACID];
                NSNumber* type = [NSNumber numberWithInt:SERVER_TYPE_GPS_RUN];
                switch (record.type.intValue) {
                    case SPORT_TYPE_ROPE:
                        type = [NSNumber numberWithInt:SERVER_TYPE_ROPE];
                        break;
                    case SPORT_TYPE_JACK:
                        type = [NSNumber numberWithInt:SERVER_TYPE_JACK];
                        break;
                    case SPORT_TYPE_SITUP:
                        type = [NSNumber numberWithInt:SERVER_TYPE_SITUP];
                        break;
                    case SPORT_TYPE_TREADMILL:
                        type = [NSNumber numberWithInt:SERVER_TYPE_TREADMILL];
                        break;
                    case SPORT_TYPE_RUNNING:
                        type = [NSNumber numberWithInt:SERVER_TYPE_GPS_RUN];
                        break;
                    case SPORT_TYPE_BICYCLE:
                        type = [NSNumber numberWithInt:SERVER_TYPE_GPS_BIKE];
                        break;
                    case SPORT_TYPE_GPS_CLIMB:
                        type = [NSNumber numberWithInt:SERVER_TYPE_GPS_CLIMB];
                        break;
                    case SPORT_TYPE_BAND_SWIM:
                        type = [NSNumber numberWithInt:SERVER_TYPE_BAND_SWIM];
                        break;
                    case SPORT_TYPE_BAND_BICYCLE:
                        type = [NSNumber numberWithInt:SERVER_TYPE_BAND_BIKE];
                        break;
                        
                    default:
                        break;
                }
                [datainfo setObject:type forKey:ACTION_KEY_TYPE];
                [datainfo setObject:[NSNumber numberWithInt:record.pace.floatValue] forKey:ACTION_KEY_PACE];
                [datainfo setObject:[NSNumber numberWithInt:record.totalstep.intValue] forKey:ACTION_KEY_TOTALSTEP];
                [datainfo setObject:[NSNumber numberWithFloat:record.totalcalories.floatValue] forKey:ACTION_KEY_TOTALCALORIES];
                [datainfo setObject:[NSNumber numberWithFloat:record.totaldistance.floatValue] forKey:ACTION_KEY_TOTALDISTANCE];
                [datainfo setObject:[NSNumber numberWithInt:record.totaltime.intValue] forKey:ACTION_KEY_TOTALTIME];
                [datainfo setObject:[NSNumber numberWithDouble:[[NSString stringWithFormat:@"%.0f",[record.adddate timeIntervalSince1970]] doubleValue]] forKey:ACTION_KEY_ADDTIMESTAMP];
                [datainfo setObject:[NSNumber numberWithDouble:[[NSString stringWithFormat:@"%.0f",[record.starttime timeIntervalSince1970]] doubleValue]] forKey:ACTION_KEY_STARTTIMESTAMP];
                [datainfo setObject:[format stringFromDate:[NSDate date]] forKey:ACTION_KEY_TIMEZONE];
                [datainfo setObject:record.running_id forKey:ACTION_KEY_RUNNINGID];
                [datalist addObject:datainfo];
            }
        }
        
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString* url = [NSString stringWithFormat:@"%@%@",SERVER_URL,DATACENTER_URL];
        NSDictionary* paramlist = @{ACTION_KEY_CMDNAME:ACTION_CMD_UPLOAD_RUNRECORD,
                                    ACTION_KEY_VERSION:PROTOCOL_VERSION,
                                    ACTION_KEY_SEQID:[self.commondata getSeqid],
                                    ACTION_KEY_BODY:@{
                                            ACTION_KEY_VID:self.commondata.vid,
                                            ACTION_KEY_TID:self.commondata.token,
                                            ACTION_KEY_DID:[self.commondata getdid],
                                            ACTION_KEY_UID:self.commondata.uid,
                                            ACTION_KEY_DATATYPE:DATATYPE_RUNRECORD,
                                            ACTION_KEY_TIMEZONE:[format stringFromDate:[NSDate date]],
                                            ACTION_KEY_DATALIST:datalist,
                                            }
                                    };
        //    NSLog(@"%@",paramlist);
        NSURLSessionDataTask* networktask = [manager POST:url parameters:paramlist progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"upload_runrecord JSON: %@", responseObject);
            NSDictionary* retdict = (NSDictionary*)responseObject;
            NSString* errcode = [retdict objectForKey:RESPONE_KEY_ERRORCODE];
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"runrecord" ByContext:Context];
            
            if (errcode){
                if([errcode isEqualToString:ERROR_CODE_OK]) {
                    NSDictionary* body = [retdict objectForKey:RESPONE_KEY_BODY];
                    if (body) {
                        NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
                        if (synckey) {
                            NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
                            NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
                            NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
                            NSMutableDictionary* memberinfo = [self.commondata getMemberInfo:self.commondata.memberid];
                            [memberinfo setObject:syncvalue forKey:synckeystr];
                            [self.commondata setMemberInfo:self.commondata.memberid Information:memberinfo];
                            
                        }
                        taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
                        [self saveDB:Context];
                        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_syncdata_to_network_ok
                                                                            object:nil
                                                                          userInfo:@{
                                                                                     @"tablename":@"RunRecord"
                                                                                     }];
                        
                    }
                }
            }
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"upload_runrecord Error: %@", error);
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"runrecord" ByContext:Context];
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        }];
        if (networktask != nil) {
            [self.networktaskdict setObject:taskinfo.taskid forKey:[NSString stringWithFormat:@"runrecord:%lu",(unsigned long)networktask.taskIdentifier]];
            
        }

    });

}
-(void)upload_runhistory:(id)taskobj{
    NSLog(@"upload_runhistory");
    dispatch_async(self.dispatchqueue, ^{
        if (self.commondata.is_login == NO) {
            NSLog(@"upload_runhistory need login state.");
            return;
        }
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        Context.parentContext = appdelegate.managedObjectContext;
        TaskInfo* taskinfo = (TaskInfo*)[self getTaskInfoByTaskID:taskobj ByContex:Context];
        if(taskinfo == nil){
            NSLog(@"upload_runhistory no taskinfo");
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
            return;
        }
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"ZZZZZ";
//        NSDateFormatter* format1 = [[NSDateFormatter alloc] init];
//        format1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSMutableArray* datalist = [[NSMutableArray alloc] init];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunHistory" inManagedObjectContext:Context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issync = %@ and memberid = %@", [NSNumber numberWithBool:NO], self.commondata.memberid];
        
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSError *error = nil;
        NSArray *fetchedObjects = [Context executeFetchRequest:fetchRequest error:&error];
        //    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
            NSLog(@"upload_runhistory no data");
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
            [self saveDB:Context];
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
            return;
        }else{
//            self.run_task_count +=1;
            for (RunHistory* record in fetchedObjects) {
                NSMutableDictionary* datainfo = [[NSMutableDictionary alloc] init];
                [datainfo setObject:[record.macid uppercaseString] forKey:ACTION_KEY_MACID];
                [datainfo setObject:record.running_id forKey:ACTION_KEY_RUNNINGID];
                [datainfo setObject:[NSNumber numberWithInt:record.locType.intValue] forKey:ACTION_KEY_LOCTYPE];
                [datainfo setObject:[NSNumber numberWithDouble:[[NSString stringWithFormat:@"%.0f",[record.adddate timeIntervalSince1970]] doubleValue]] forKey:ACTION_KEY_ADDTIMESTAMP];
                [datainfo setObject:[NSNumber numberWithInt:record.satellite_number.intValue] forKey:ACTION_KEY_SATELLITENUMBER];
                [datainfo setObject:[NSNumber numberWithFloat:record.altitude.floatValue] forKey:ACTION_KEY_ALTITUDE];
                [datainfo setObject:[NSNumber numberWithFloat:record.direction.floatValue] forKey:ACTION_KEY_DIRECTION];
                [datainfo setObject:[NSNumber numberWithFloat:record.latitude.floatValue] forKey:ACTION_KEY_LATITUDE];
                [datainfo setObject:[NSNumber numberWithFloat:record.longitude.floatValue] forKey:ACTION_KEY_LONGITUDE];
                [datainfo setObject:[NSNumber numberWithFloat:record.radius.floatValue] forKey:ACTION_KEY_RADIUS];
                [datainfo setObject:[NSNumber numberWithFloat:record.speed.floatValue] forKey:ACTION_KEY_SPEED];
                [datainfo setObject:[format stringFromDate:[NSDate date]] forKey:ACTION_KEY_TIMEZONE];
                [datalist addObject:datainfo];
            }
        }
        
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString* url = [NSString stringWithFormat:@"%@%@",SERVER_URL,DATACENTER_URL];
        NSDictionary* paramlist = @{ACTION_KEY_CMDNAME:ACTION_CMD_UPLOAD_RUNHISTORY,
                                    ACTION_KEY_VERSION:PROTOCOL_VERSION,
                                    ACTION_KEY_SEQID:[self.commondata getSeqid],
                                    ACTION_KEY_BODY:@{
                                            ACTION_KEY_VID:self.commondata.vid,
                                            ACTION_KEY_TID:self.commondata.token,
                                            ACTION_KEY_DID:[self.commondata getdid],
                                            ACTION_KEY_UID:self.commondata.uid,
                                            ACTION_KEY_DATATYPE:DATATYPE_RUNHISTORY,
                                            ACTION_KEY_TIMEZONE:[format stringFromDate:[NSDate date]],
                                            ACTION_KEY_DATALIST:datalist,
                                            }
                                    };
        //    NSLog(@"%@",paramlist);
        NSURLSessionDataTask* networktask = [manager POST:url parameters:paramlist progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"upload_runhistory JSON: %@", responseObject);
            NSDictionary* retdict = (NSDictionary*)responseObject;
            NSString* errcode = [retdict objectForKey:RESPONE_KEY_ERRORCODE];
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"runhistory" ByContext:Context];
            
            if (errcode){
                if([errcode isEqualToString:ERROR_CODE_OK]) {
                    NSDictionary* body = [retdict objectForKey:RESPONE_KEY_BODY];
                    if (body) {
                        NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
                        if (synckey) {
                            NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
                            NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
                            NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
                            NSMutableDictionary* memberinfo = [self.commondata getMemberInfo:self.commondata.memberid];
                            [memberinfo setObject:syncvalue forKey:synckeystr];
                            [self.commondata setMemberInfo:self.commondata.memberid Information:memberinfo];
                            
                        }
                        taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
                        [self saveDB:Context];
                        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_syncdata_to_network_ok
                                                                            object:nil
                                                                          userInfo:@{
                                                                                     @"tablename":@"RunHistory"
                                                                                     }];
                        
                    }
                }
            }
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"upload_runhistory Error: %@", error);
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"runhistory" ByContext:Context];
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        }];
        if (networktask != nil) {
            [self.networktaskdict setObject:taskinfo.taskid forKey:[NSString stringWithFormat:@"runhistory:%lu",(unsigned long)networktask.taskIdentifier]];
            
        }
        
    });
}
-(void)upload_bodyfunction:(id)taskobj{
    NSLog(@"upload_bodyfunction");
    dispatch_async(self.dispatchqueue, ^{
        if (self.commondata.is_login == NO) {
            NSLog(@"upload_bodyfunction need login state.");
            return;
        }
        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        Context.parentContext = appdelegate.managedObjectContext;
        TaskInfo* taskinfo = (TaskInfo*)[self getTaskInfoByTaskID:taskobj ByContex:Context];
        if(taskinfo == nil){
            NSLog(@"upload_bodyfunction no taskinfo");
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];

            return;
        }
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"ZZZZZ";
        NSDateFormatter* format1 = [[NSDateFormatter alloc] init];
        [format1 setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
        format1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        format1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
        
        NSMutableArray* datalist = [[NSMutableArray alloc] init];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Health_data_history" inManagedObjectContext:Context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issync = %@ and uid = %@", [NSNumber numberWithBool:NO], self.commondata.uid];
        
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSError *error = nil;
        NSArray *fetchedObjects = [Context executeFetchRequest:fetchRequest error:&error];
        //    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || [fetchedObjects count] == 0) {
            NSLog(@"upload_bodyfunction no data");
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
            [self saveDB:Context];
            self.run_task_count -=1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];

            return;
        }else{
//            self.run_task_count +=1;
            for (Health_data_history* record in fetchedObjects) {
                NSMutableDictionary* datainfo = [[NSMutableDictionary alloc] init];
                [datainfo setObject:[NSNumber numberWithFloat:record.value.floatValue] forKey:ACTION_KEY_VALUE];
                [datainfo setObject:[NSNumber numberWithFloat:record.value2.floatValue] forKey:ACTION_KEY_VALUE2];
                [datainfo setObject:[NSNumber numberWithInt:record.type.intValue] forKey:ACTION_KEY_TYPE];
                [datainfo setObject:[record.macid uppercaseString] forKey:ACTION_KEY_MACID];
                [datainfo setObject:[NSNumber numberWithDouble:[[NSString stringWithFormat:@"%.0f",[record.adddate timeIntervalSince1970]] doubleValue]] forKey:ACTION_KEY_TIMESTAMP];
                [datainfo setObject:[format stringFromDate:[NSDate date]] forKey:ACTION_KEY_TIMEZONE];
                [datainfo setObject:[format1 stringFromDate:record.adddate] forKey:ACTION_KEY_DATETIME];
                [datalist addObject:datainfo];
            }
        }
        
        AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString* url = [NSString stringWithFormat:@"%@%@",SERVER_URL,DATACENTER_URL];
        NSDictionary* paramlist = @{ACTION_KEY_CMDNAME:ACTION_CMD_UPLOAD_BODYFUNCTION,
                                    ACTION_KEY_VERSION:PROTOCOL_VERSION,
                                    ACTION_KEY_SEQID:[self.commondata getSeqid],
                                    ACTION_KEY_BODY:@{
                                            ACTION_KEY_VID:self.commondata.vid,
                                            ACTION_KEY_TID:self.commondata.token,
                                            ACTION_KEY_DID:[self.commondata getdid],
                                            ACTION_KEY_UID:self.commondata.uid,
                                            ACTION_KEY_DATATYPE:DATATYPE_BODYFUNCTION,
                                            ACTION_KEY_TIMEZONE:[format stringFromDate:[NSDate date]],
                                            ACTION_KEY_DATALIST:datalist,
                                            }
                                    };
        //    NSLog(@"%@",paramlist);
        NSURLSessionDataTask* networktask = [manager POST:url parameters:paramlist progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"upload_bodyfunction JSON: %@", responseObject);
            NSDictionary* retdict = (NSDictionary*)responseObject;
            NSString* errcode = [retdict objectForKey:RESPONE_KEY_ERRORCODE];
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"bodyfunction" ByContext:Context];
            
            if (errcode){
                if([errcode isEqualToString:ERROR_CODE_OK]) {
                    NSDictionary* body = [retdict objectForKey:RESPONE_KEY_BODY];
                    if (body) {
                        NSString* synckey = [body objectForKey:RESPONE_KEY_SYNCKEY];
                        if (synckey) {
                            NSArray* synckeylist = [synckey componentsSeparatedByString:@"_"];
                            NSString* synckeystr = [NSString stringWithFormat:@"%@%@",SYNCKEY_PREFIX,synckeylist[0]];
                            NSNumber* syncvalue = [NSNumber numberWithInt:[synckeylist[1] intValue]];
                            NSMutableDictionary* memberinfo = [self.commondata getMemberInfo:self.commondata.memberid];
                            [memberinfo setObject:syncvalue forKey:synckeystr];
                            [self.commondata setMemberInfo:self.commondata.memberid Information:memberinfo];
                            
                        }
                        taskinfo.state = [NSNumber numberWithInt:TASKSTATE_FINISH];
                        [self saveDB:Context];
                        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_syncdata_to_network_ok
                                                                            object:nil
                                                                          userInfo:@{
                                                                                     @"tablename":@"Health_data_history"
                                                                                     }];
                        
                    }
                }
            }
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"upload_bodyfunction Error: %@", error);
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* Context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            Context.parentContext = appdelegate.managedObjectContext;
            TaskInfo* taskinfo = [self getTaskInfoByNetworkTaskID:task.taskIdentifier ByPrefix:@"bodyfunction" ByContext:Context];
            taskinfo.state = [NSNumber numberWithInt:TASKSTATE_WAITING];
            [self saveDB:Context];
            self.run_task_count -= 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_download_synckey_changed
                                                                object:nil
                                                              userInfo:nil];
        }];
        if (networktask != nil) {
            [self.networktaskdict setObject:taskinfo.taskid forKey:[NSString stringWithFormat:@"bodyfunction:%lu",(unsigned long)networktask.taskIdentifier]];
            
        }
        
    });
}
@end
