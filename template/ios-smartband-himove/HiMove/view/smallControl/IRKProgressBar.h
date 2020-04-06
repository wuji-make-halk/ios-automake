//
//  IRKProgressBar.h
//  JSDBong
//
//  Created by qf on 14-6-25.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IRKProgressBar;
@protocol IRKProgressBarDelegate <NSObject>

@required
-(UIColor*)getBarColor:(IRKProgressBar*)Progress withProgress:(CGFloat)progress;

@end
@interface IRKProgressBar : UIView
@property (assign,nonatomic) id<IRKProgressBarDelegate> delegate;
@property CGFloat progress;

@property UIColor * boardColor;
@property UIColor * fillColor;
@property UIColor * progressColor;
@property CGFloat conerRadius;
@property CGFloat boarderLineWidth;
@property CGFloat progressoffset;
@property CGFloat animationtime;

@property UIView* progressbar;

-(void)reload;

-(void) setProgress:(CGFloat)progress animated:(BOOL)animated;
@end
