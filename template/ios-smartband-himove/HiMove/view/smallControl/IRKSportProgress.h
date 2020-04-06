//
//  IRKSportProgress.h
//  Lovewell
//
//  Created by qf on 14-7-11.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//  运动时 中间的 圆圈数值画图类

#import <UIKit/UIKit.h>


@class IRKSportProgress;

@protocol IRKSportProgressDataSource <NSObject>

@required
-(UIColor*)getSportProgressColor;
-(NSString*)getSportText:(int)index;
-(CGFloat)getSportProgress;
-(CGFloat)getSportTextSize:(int)index;
-(CGFloat)IRKSportProgressCurrentSteps:(IRKSportProgress*)view;


@optional


@end

@protocol IRKSportProgressDelegate <NSObject>
@required
-(NSInteger)IRKSportProgressCurrentSelectedBalance:(IRKSportProgress*)view;

@optional
-(UIColor*)IRKSportProgressBoardColor:(IRKSportProgress*)view;
//-(UIColor*)IRKSportProgressTitleColor:(IRKSportProgress*)view;

@end

@interface IRKSportProgress : UIView
@property (weak, nonatomic) id<IRKSportProgressDataSource> datasource;
@property (weak, nonatomic) id<IRKSportProgressDelegate> delegate;
//@property (strong, nonatomic) UIImageView* backgroundview;
//@property (strong, nonatomic) UIImage * backimg;
@property (assign, nonatomic) CGFloat radius;
@property (assign, nonatomic) CGFloat linewidth;

@property NSInteger dataSegCount;
@property (strong, nonatomic) NSMutableArray* layers;



-(void) reload;

@end
