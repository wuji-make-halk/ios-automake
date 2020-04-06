//
//  mkMoveAnnotation.m
//  Wishoney
//
//  Created by qf on 15/10/23.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import "mkMoveAnnotation.h"

@implementation mkMoveAnnotation
@synthesize currentLocation;

//- (CLLocationCoordinate2D) coordinate
//{
//    return MKCoordinateForMapPoint(self.currentLocation);
//}

-(void)SetMapPoint:(MKMapPoint)point{
    self.currentLocation = point;
 //   NSLog(@"send kObjectMovedNotification1");
 //   NSLog(@"annotation:coor %f,%f",self.coordinate.latitude,self.coordinate.longitude);
    [[NSNotificationCenter defaultCenter] postNotificationName:kObjectMovedNotification1 object:self];
}

//- (void)changeCoordinate:(CLLocationCoordinate2D)_coordinate {
//    [self willChangeValueForKey:@"coordinate"];
//    [self setCoordinate:_coordinate];
//    [self didChangeValueForKey:@"coordinate"];
//    
//}
@end
