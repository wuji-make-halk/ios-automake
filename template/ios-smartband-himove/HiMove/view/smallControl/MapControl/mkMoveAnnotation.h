//
//  mkMoveAnnotation.h
//  Wishoney
//
//  Created by qf on 15/10/23.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import <MapKit/MapKit.h>
#define kObjectMovedNotification1			@"Object Moved Notification1"

@interface mkMoveAnnotation : MKPointAnnotation{
    MKMapPoint currentLocation;
}


@property (nonatomic, assign) MKMapPoint currentLocation;  // current location of the vehicle
-(void)SetMapPoint:(MKMapPoint)point;

//- (void)changeCoordinate:(CLLocationCoordinate2D)_coordinate;

@end
