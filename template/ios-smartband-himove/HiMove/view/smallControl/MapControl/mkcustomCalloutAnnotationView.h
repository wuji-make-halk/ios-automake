//
//  mkcustomCalloutAnnotationView.h
//  Wishoney
//
//  Created by qf on 15/10/23.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface mkcustomCalloutAnnotationView : MKAnnotationView
@property(nonatomic,retain) UIImageView *imageview;
@property(nonatomic,strong) IRKCommonData* commondata;
@end
