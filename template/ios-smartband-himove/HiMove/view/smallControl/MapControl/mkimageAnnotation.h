//
//  mkimageAnnotation.h
//  Wishoney
//
//  Created by qf on 15/10/23.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface mkimageAnnotation : MKPointAnnotation
@property (nonatomic,strong)NSMutableDictionary* userinfo;
@property (nonatomic,assign)NSInteger tag;
@end
