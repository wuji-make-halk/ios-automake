//
//  mkcustomCalloutAnnotation.m
//  Wishoney
//
//  Created by qf on 15/10/23.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import "mkcustomCalloutAnnotation.h"

@implementation mkcustomCalloutAnnotation
- (id)initWithImei:(NSString *)imei{
    if (self = [super init]) {
        self.imei = imei;
    }
    return self;
}

@end
