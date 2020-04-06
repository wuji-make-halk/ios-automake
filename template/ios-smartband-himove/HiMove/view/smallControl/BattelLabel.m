//
//  BattelLabel.m
//  pageviewtest
//
//  Created by qf on 14-5-4.
//  Copyright (c) 2014年 clousky. All rights reserved.
//

#import "BattelLabel.h"

@implementation BattelLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.BoardBodyRate = 0.9;
        self.conerRadius = 3;
        self.boarderLineWidth = 0.5;
        
        //self.degreeLayer = [CAShapeLayer layer];
        //[self.layer addSublayer:self.degreeLayer];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextDrawImage(context, rect, [[UIImage imageNamed:@"dianchi.png"] CGImage]);
    CGRect fillrect = CGRectMake(rect.origin.x+3, rect.origin.y+2.75, self._degree*17, 9);
    if(self._degree > 0.3){
        CGContextSetRGBFillColor(context, 112/255.0, 206/255.0, 21/255.0, 1);
    }
    else{
        CGContextSetRGBFillColor(context, 1.0, 0, 0, 1);
    }
    CGContextFillRect(context, fillrect);
    
}
 */

-(void) reload{
    [self drawBoarder];
    [self drawDegree];
    
}

-(void) drawBoarder{
    if(self.boardBodyLayer){
        [self.boardBodyLayer removeFromSuperlayer];
        self.boardBodyLayer = nil;
    }
    if(self.boardHeadLayer){
        [self.boardHeadLayer removeFromSuperlayer];
        self.boardHeadLayer = nil;
    }
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(RateForBoardBody:)])
    {
        self.BoardBodyRate = [self.dataSource RateForBoardBody:self];
    }
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(BoardColor:)])
    {
        self.boardColor = [self.dataSource BoardColor:self];
    }
    else{
        self.boardColor = [UIColor lightGrayColor];
    }
    
    self.boardBodyLayer = [CAShapeLayer layer];
    self.boardBodyLayer.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width * self.BoardBodyRate, self.bounds.size.height);
 //   NSLog(@"%f,%f,%f,%f",self.boardBodyLayer.frame.origin.x,self.boardBodyLayer.frame.origin.y,self.boardBodyLayer.frame.size.width, self.boardBodyLayer.frame.size.height);
    self.boardBodyLayer.backgroundColor = [UIColor whiteColor].CGColor;
    self.boardBodyLayer.geometryFlipped = YES;
    self.boardBodyLayer.cornerRadius = self.conerRadius;
    self.boardBodyLayer.borderColor = self.boardColor.CGColor;
    self.boardBodyLayer.borderWidth = self.boarderLineWidth;
    self.boardBodyLayer.hidden = NO;
    [self.layer addSublayer:self.boardBodyLayer];
    
    self.boardHeadLayer = [CAShapeLayer layer];
    self.boardHeadLayer.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * self.BoardBodyRate-self.boarderLineWidth/2, self.bounds.origin.y + self.bounds.size.height/4, self.bounds.size.width * (1- self.BoardBodyRate), self.bounds.size.height/2);
    self.boardHeadLayer.backgroundColor = [UIColor whiteColor].CGColor;
    self.boardHeadLayer.geometryFlipped = YES;
 //   self.boardHeadLayer.cornerRadius = 3;
    self.boardHeadLayer.borderColor = self.boardColor.CGColor;
    self.boardHeadLayer.borderWidth = self.boarderLineWidth;
    self.boardHeadLayer.hidden = NO;
    [self.layer addSublayer:self.boardHeadLayer];
    
    self.labeldegree = [[UILabel alloc] initWithFrame:self.boardBodyLayer.bounds];
    self.labeldegree.textAlignment = NSTextAlignmentCenter;
    self.labeldegree.textColor = [UIColor blackColor];
    self.labeldegree.backgroundColor = [UIColor clearColor];
    self.labeldegree.font = [UIFont systemFontOfSize:self.labeldegree.frame.size.height*0.7];
    //[self addSubview:self.labeldegree];
    
//#ifdef CUSTOM_FITBAND
//    self.labeldegree = [[UILabel alloc] initWithFrame:self.boardBodyLayer.bounds];
//    self.labeldegree.textAlignment = NSTextAlignmentCenter;
//    self.labeldegree.textColor = [UIColor blackColor];
//    self.labeldegree.font = [UIFont systemFontOfSize:self.labeldegree.frame.size.height*0.7];
//    [self addSubview:self.labeldegree];
//#endif
    
    
    
}

-(void) drawDegree{
    if(self.degreeLayer){
        [self.degreeLayer removeFromSuperlayer];
        self.degreeLayer = nil;
    }
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(DegreeOfBattel:)])
    {
        self.degree = [self.dataSource DegreeOfBattel:self];
  //      NSLog(@"degree = %f",self.degree);
    }
    else{
    
        self.degree = 0;
    }
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(BattelLabel:colorForDegree:)])
    {
        self.degreeColor = [self.dataSource BattelLabel:self colorForDegree:self.degree];
    }
    else{
        self.degreeColor = [UIColor greenColor];
    }
    

    CGFloat framewidth =  self.bounds.size.width * self.BoardBodyRate - self.conerRadius*2;
    CGFloat frameheigth = self.bounds.size.height-self.conerRadius*2;
    self.degreeLayer = [CAShapeLayer layer];
    self.degreeLayer.frame = CGRectMake(self.bounds.origin.x+self.conerRadius, self.bounds.origin.y + self.conerRadius, framewidth, frameheigth);
    self.degreeLayer.bounds = CGRectMake(self.bounds.origin.x+self.conerRadius, self.bounds.origin.y + self.conerRadius, framewidth, frameheigth);
    self.degreeLayer.geometryFlipped	= YES;

    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.bounds.origin.x + self.conerRadius, self.bounds.origin.y + self.conerRadius + frameheigth/2.0)];
    [path addLineToPoint:CGPointMake(self.bounds.origin.x+self.conerRadius + framewidth * self.degree, self.bounds.origin.y + self.conerRadius + frameheigth/2.0)];
    self.degreeLayer.path				= path.CGPath;
    self.degreeLayer.strokeColor		= self.degreeColor.CGColor;
    self.degreeLayer.lineWidth			= frameheigth;
    self.degreeLayer.lineJoin			= kCALineJoinBevel;
    //self.degreeLayer.hidden				= YES;
    
    
    
    [self.layer addSublayer:self.degreeLayer];
 //animation
//    [self.degreeLayer removeAllAnimations];
//	[CATransaction begin];
//	[CATransaction setAnimationDuration:1.0];
//    //	[CATransaction setAnimationDuration:1];
//	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
//	[CATransaction setCompletionBlock:nil];
//    
//	self.degreeLayer.hidden				= NO;
//	CABasicAnimation *pathAnimation	= [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//	pathAnimation.fromValue			= [NSNumber numberWithFloat:0.0f];
//	pathAnimation.toValue			= [NSNumber numberWithFloat:1.0f];
//	[self.degreeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
//    
//	[CATransaction commit];
    
    self.labeldegree.text = [NSString stringWithFormat:@"%.0f%%",self.degree*100];
    //[self bringSubviewToFront:self.labeldegree];
//#ifdef CUSTOM_FITBAND
//    self.labeldegree.text = [NSString stringWithFormat:@"%.0f%%",self.degree*100];
//    [self bringSubviewToFront:self.labeldegree];
//#endif
}

@end
