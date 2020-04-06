//
//  mkMoveAnnotationView.m
//  Wishoney
//
//  Created by qf on 15/10/23.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import "mkMoveAnnotationView.h"
#import "mkMoveAnnotation.h"
#import <MapKit/MapKit.h>

#define POSITIONKEY1 @"positionAnimation1"
#define BOUNDSKEY1 @"boundsAnimation1"
static NSString *HGMovingAnnotationTransformsKey1 = @"TransformsGroupAnimation1";
#define  Arror_height 6

@implementation mkMoveAnnotationView

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.commondata = [IRKCommonData SharedInstance];
        //        self.backgroundColor = self.commondata.colorNav;
        self.backgroundColor = [UIColor clearColor];
        self.canShowCallout = NO;
        self.centerOffset = CGPointMake(0, -20);
        self.frame = CGRectMake(0, 0, 40, 40);
        self.draggable = YES;
        
        self.imageview = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageview.backgroundColor   = [UIColor clearColor];
        [self addSubview:self.imageview];
 //       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMoveAnnotation:) name:kObjectMovedNotification1 object:nil];
    }
    return self;
    
}

- (void)setAnnotation:(id <MKAnnotation>)anAnnotation
{
    
    if (anAnnotation) {
        if (anAnnotation != self.annotation) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMoveAnnotation:) name:kObjectMovedNotification1 object:anAnnotation];
        }
    }
    else {
        //		DLog(DEBUG_LEVEL_ERROR, @"%x removed. Clearing annotation object %x", self, anAnnotation);
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.layer removeAllAnimations];
        self.mapView = nil;
    }
    [super setAnnotation :anAnnotation];
 
    if (self.mapView && anAnnotation) {
        [self updateTransformsFromAnnotation:(mkMoveAnnotation*) anAnnotation animated:NO];
    }
    
    
}


- (void) didMoveAnnotation : (NSNotification*) notification
{
    [self updateTransformsFromAnnotation:[notification object] animated:YES];
}

- (void)updateTransformsFromAnnotation:(mkMoveAnnotation*)annotation animated:(BOOL)animated
{
//    CLLocationCoordinate2D coordinate = annotation.coordinate;
    CLLocationCoordinate2D coordinate =MKCoordinateForMapPoint(annotation.currentLocation);
 //   NSLog(@"currentannotation.coor= %f,%f",coordinate.latitude,coordinate.longitude);
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        
        NSMutableDictionary *transforms = [NSMutableDictionary dictionaryWithCapacity:2];
        [transforms setValue:[NSValue valueWithMKCoordinate:coordinate] forKey:@"coordinate"];
        
        [self applyTransforms:transforms animated:animated];
        
    }
    
}


#define IS_IOS7 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)


- (void)applyTransforms :(NSDictionary *)transforms animated:(BOOL)animated
{
    //extract the updated coordinate of the annotation from 'transforms' dictionary
    CLLocationCoordinate2D coordinate = [transforms[@"coordinate"] MKCoordinateValue];
    
    CGPoint toPos;
    if (IS_IOS7) {
        toPos = [self.mapView convertCoordinate:coordinate toPointToView:self.showView];
        toPos.x = toPos.x+self.centerOffset.x;
        toPos.y = toPos.y+self.centerOffset.y;
    }
    else{
        MKMapPoint toMapPoint = MKMapPointForCoordinate(coordinate);
        CGFloat mapScale = round(self.mapView.visibleMapRect.size.width / self.mapView.frame.size.width);
        toPos = (CGPoint){toMapPoint.x/mapScale, toMapPoint.y/mapScale};
    }
    
//    NSLog(@"mk::applyTransforms::center = %@",NSStringFromCGPoint(self.center));
//    NSLog(@"mk::applyTransforms::toPos = %@",NSStringFromCGPoint(toPos));
   
    if (animated) {
        
        CAAnimationGroup *theGroup = [CAAnimationGroup animation];
        
        theGroup.duration = 0.3;
        theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        theGroup.delegate = self;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:self.center];
        animation.toValue = [NSValue valueWithCGPoint:toPos];
        
        NSMutableArray *animArray = [NSMutableArray arrayWithCapacity:2];
        [animArray addObject:animation];
        
        theGroup.animations = animArray;
        
        [self.layer addAnimation:theGroup forKey:HGMovingAnnotationTransformsKey1];
        
    }
    else {
        // set final rotation value for the layer
        [self.layer setAffineTransform:CGAffineTransformMakeRotation([[transforms valueForKey:@"rotation"] floatValue])];
        self.center = toPos;
        
    }
    
    
}


- (void) animationDidStart:(CAAnimation *)anim;
{
    
    if ([anim respondsToSelector:@selector(animations)]) {
        // anim is actually CAAnimationGroup with multiple animations (namely position and rotation)
        NSArray *animations = ((CAAnimationGroup *) anim).animations;
        
        if (animations.count > 0) {
            self.layer.position = [((CABasicAnimation *) [animations objectAtIndex:0]).toValue CGPointValue];
        }
        if (animations.count > 1) {
            // set final rotation value for the layer
            [self.layer setAffineTransform:CGAffineTransformMakeRotation([((CABasicAnimation *) [animations objectAtIndex:1]).toValue floatValue])];
        }
        
    }
    else{
        // anim is a single animation (position)
        self.layer.position = [((CABasicAnimation *)anim).toValue CGPointValue];
    }
    
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        [self.annotation setCoordinate:MKCoordinateForMapPoint(((mkMoveAnnotation*)self.annotation).currentLocation)];
//        NSLog(@"after animation annotation.coor= %f,%f",self.annotation.coordinate.latitude,self.annotation.coordinate.longitude);

    }
}

- (void)setMapView:(MKMapView *)map
{
    _mapView = map;
    if (self.annotation && _mapView) {
        [self updateTransformsFromAnnotation:(mkMoveAnnotation*) self.annotation animated:NO];
    }
}

- (void)mapView :(MKMapView *)mapView didChangeZoomScale:(MKZoomScale)zoomScale
{
    
    CGFloat width = 20;
    if (zoomScale <= 16) {
        width = 28;
    }
    else if (zoomScale <= 32) {
        width = 25;
    }
    else if (zoomScale <= 64) {
        width = 20;
    }
    else if (zoomScale <= 128) {
        width = 15;
    }
    else if (zoomScale <= 256) {
        width = 10;
    }
    
    if (width != self.bounds.size.width) {
        [self setBounds:CGRectMake(0, 0, width, width) animated:YES];
    }
    
}

- (void)setBounds:(CGRect)rect animated :(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bounds = rect;
        }];
    }
    self.bounds = rect;
    
}

//-(void)drawRect:(CGRect)rect{
//    
//    [self drawInContext:UIGraphicsGetCurrentContext()];
//    
//    self.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.layer.shadowOpacity = 1.0;
//    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//    
//    
//}
//
//-(void)drawInContext:(CGContextRef)context
//{
//    
//    CGContextSetLineWidth(context, 2.0);
//    //    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor);
//    CGContextSetFillColorWithColor(context, self.commondata.colorNav.CGColor);
//    
//    [self getDrawPath:context];
//    CGContextFillPath(context);
//    
//}
//- (void)getDrawPath:(CGContextRef)context
//{
//    CGRect rrect = self.bounds;
//    CGFloat radius = 6.0;
//    
//    CGFloat minx = CGRectGetMinX(rrect),
//    midx = CGRectGetMidX(rrect),
//    maxx = CGRectGetMaxX(rrect);
//    CGFloat miny = CGRectGetMinY(rrect),
//    // midy = CGRectGetMidY(rrect),
//    maxy = CGRectGetMaxY(rrect)-Arror_height;
//    CGContextMoveToPoint(context, midx+Arror_height, maxy);
//    CGContextAddLineToPoint(context,midx, maxy+Arror_height);
//    CGContextAddLineToPoint(context,midx-Arror_height, maxy);
//    
//    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
//    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
//    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
//    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
//    CGContextClosePath(context);
//    //    CGContextFillPath(context);
//}


@end
