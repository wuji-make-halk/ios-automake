//
//  BandInfo+CoreDataProperties.h
//  SXRBand
//
//  Created by qf on 15/10/2.
//  Copyright © 2015年 SXR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BandInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BandInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *datetime;
@property (nullable, nonatomic, retain) NSString *macid;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *subgeartype;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *uuid;

@end

NS_ASSUME_NONNULL_END
