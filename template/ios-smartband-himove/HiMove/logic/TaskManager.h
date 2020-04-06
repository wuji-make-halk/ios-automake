//
//  TaskManager.h
//  Yoo Fitness
//
//  Created by qf on 16/12/27.
//  Copyright © 2016年 Keeprapid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskManager : NSObject
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) IRKCommonData* commondata;
//@property (strong, nonatomic) MainLoop* mainloop;
@property (strong, nonatomic) BleControl* blecontrol;
+(TaskManager *)SharedInstance;
@property (strong,nonatomic)NSMutableData* recvdata;
-(void)AddDownLoadTaskBySyncKey:(NSString*)synckey From:(int)beginkey To:(int)endkey;
-(void)AddUpLoadTaskBySyncKey:(NSString*)synckey;
-(void)CheckSyncKey:(NSDictionary*)bodyinfo;
@end
