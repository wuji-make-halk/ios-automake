//
//  IRKSleepProgress.h
//  JSDBong
//
//  Created by qf on 14-6-26.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//  睡眠时 中间的 圆圈数值画图类

#import <UIKit/UIKit.h>
typedef enum
{
	IRKSleepTypeUnSleep,	// 纯色
    IRKSleepTypeAwake,
    IRKSleepTypeExLightSleep,
	IRKSleepTypeLightSleep, // 奇偶色
	IRKSleepTypeDeepSleep		//网格
} IRKSleepType;

@class IRKSleepProgress;

@protocol IRKSleepProgressDataSource <NSObject>

@required
-(IRKSleepType)getSleepTypeByIndex:(NSUInteger)index;
-(UIColor*)getColorByType:(IRKSleepType)type;
// index 1-top 2-middle 3- bottom
-(NSString*)getText:(int)index;
-(CGFloat)IRKSleepProgressCurrentSleep:(IRKSleepProgress*)view;


@optional
-(CGFloat)getTextSize:(int)index;


@end

@protocol IRKSleepProgressDelegate <NSObject>
@required

@optional
-(UIColor*)IRKSleepProgressBoardColor:(IRKSleepProgress*)view;
-(UIColor*)IRKSleepProgressTitleColor:(IRKSleepProgress*)view;
-(CGFloat)IRKSleepProgressGraduateFontSize:(IRKSleepProgress*)view;
-(NSUInteger)getDataSegCount;

@end

@interface IRKSleepProgress : UIView
@property (strong, nonatomic) IRKCommonData *commondata;
@property (weak, nonatomic) id<IRKSleepProgressDataSource> datasource;
@property (weak, nonatomic) id<IRKSleepProgressDelegate> delegate;
//@property (strong, nonatomic) UIImageView* backgroundview;
//@property (strong, nonatomic) UIImage * backimg;

//@property CATextLayer * textLayerTop;
//@property CATextLayer * textLayerMiddle;
//@property CATextLayer * textLayerBottom;
@property NSInteger dataSegCount;

@property CGFloat radius;
@property CGFloat linewidth;

-(void) reload;

@end
