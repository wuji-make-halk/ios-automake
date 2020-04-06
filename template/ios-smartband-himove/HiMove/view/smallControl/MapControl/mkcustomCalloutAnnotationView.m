//
//  mkcustomCalloutAnnotationView.m
//  Wishoney
//
//  Created by qf on 15/10/23.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import "mkcustomCalloutAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

#define  Arror_height 6

@implementation mkcustomCalloutAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.commondata = [IRKCommonData SharedInstance];
        //        self.backgroundColor = self.commondata.colorNav;
        self.backgroundColor = [UIColor clearColor];
        self.canShowCallout = NO;
        self.centerOffset = CGPointMake(0, 0);
        self.frame = CGRectMake(0, 0, 40, 40);
        
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, self.frame.size.width-15, self.frame.size.height-15)];
        self.imageview.backgroundColor   = [UIColor clearColor];
        [self addSubview:self.imageview];
    }
    return self;
    
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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchbegin");
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_click_on_annotation object:nil userInfo:@{@"tag":[NSNumber numberWithLong:self.tag]}];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchend");
    //    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_click_on_annotation object:nil userInfo:@{@"tag":[NSNumber numberWithInt:self.tag]}];
    
}


@end
