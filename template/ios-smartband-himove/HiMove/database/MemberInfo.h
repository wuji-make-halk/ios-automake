//
//  MemberInfo.h
//  SXRBand
//
//  Created by qf on 14-12-1.
//  Copyright (c) 2014年 SXR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MemberInfo : NSManagedObject

@property (nonatomic, retain) NSString * member_name;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSString * headimgurl;
@property (nonatomic, retain) NSString * user_profile;

@end
