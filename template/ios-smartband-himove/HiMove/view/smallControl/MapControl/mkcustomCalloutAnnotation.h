//
//  mkcustomCalloutAnnotation.h
//  Wishoney
//
//  Created by qf on 15/10/23.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface mkcustomCalloutAnnotation : NSObject<MKAnnotation>
@property (nonatomic) NSString* imei;

@property(retain,nonatomic) NSDictionary *locationInfo;//callout吹出框要显示的各信息



- (id)initWithImei:(NSString*)imei;
@end
