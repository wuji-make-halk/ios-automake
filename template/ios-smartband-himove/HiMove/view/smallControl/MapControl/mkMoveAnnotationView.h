//
//  mkMoveAnnotationView.h
//  Wishoney
//
//  Created by qf on 15/10/23.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface mkMoveAnnotationView : MKAnnotationView{
    
    MKMapPoint lastReportedLocation;
    BOOL animating;
    BOOL observingMovement;
}

@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) UIView* showView;
@property(nonatomic,retain) UIImageView *imageview;
@property(nonatomic,strong) IRKCommonData* commondata;

@end
