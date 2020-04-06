//
//  IRKHeartProgress.h
//  SXRBand
//
//  Created by qf on 16/4/18.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICountingLabel.h"
@class IRKHeartProgress;

@protocol IRKHeartProgressDelegate <NSObject>

-(UIColor*)IRKHeartProgressBackgroundColor:(IRKHeartProgress*)view;
-(UIColor*)IRKHeartProgressCircleBarColor:(IRKHeartProgress*)view;
-(CGFloat)IRKHeartProgressCircleBarWidth:(IRKHeartProgress*)view;
-(UIColor*)IRKHeartProgressTextColor:(IRKHeartProgress*)view;
-(UIColor*)IRKHeartProgressTrackerColor:(IRKHeartProgress*)view;
-(CGFloat)IRKHeartProgressTrackerWidth:(IRKHeartProgress*)view;
-(NSString*)IRKHeartProgressText:(IRKHeartProgress*)view;
-(UIImage*)IRKHeartProgressHeartImage:(IRKHeartProgress*)view;

-(NSInteger)IRKHeartProgressCurrentSelectedBalance:(IRKHeartProgress*)view;


@end


@interface IRKHeartProgress : UIView
@property (strong, nonatomic) UILabel* label_bottom;
@property(weak,nonatomic)id<IRKHeartProgressDelegate>delegate;
@property (assign, nonatomic) BOOL isShowFloat;
-(void)reload;
-(void)startAnimation;
-(void)stopAnimation;
-(void)setHeartValue:(NSInteger)heart;
-(void)setTempValue:(CGFloat)value;
@end
