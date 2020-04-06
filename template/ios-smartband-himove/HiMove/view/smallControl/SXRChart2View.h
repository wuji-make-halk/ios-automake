//
//  SXRChart2View.h
//  SXRBand
//
//  Created by qf on 16/4/15.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SXRChart2BartypeEnum) {
    BarTypeLine,
    BarTypeTwoPointBar,
    BarTypeHeartLine
};

@class SXRChart2View;//图表视图

@protocol SXRChart2ViewDelegate <NSObject>

-(UIColor*)SXRChart2ViewBackgroundColor:(SXRChart2View*)view;
-(UIColor*)SXRChart2ViewTextColor:(SXRChart2View*)view;
-(UIColor*)SXRChart2ViewSepLineColor:(SXRChart2View*)view;
-(UIColor*)SXRChart2ViewBarColor:(SXRChart2View*)view;
-(NSInteger)SXRChart2ViewBarCount:(SXRChart2View*)view;
-(NSArray*)SXRChart2ViewDataValueArray:(SXRChart2View*)view;
-(NSArray*)SXRChart2ViewXLabelArray:(SXRChart2View*)view;
-(NSInteger)SXRChart2ViewXLabelFilter:(SXRChart2View*)view;
-(CGFloat)SXRChart2ViewYLabelMaxValue:(SXRChart2View*)view;
-(NSAttributedString*)SXRChart2ViewTopLeftTip:(SXRChart2View*)view;
-(NSAttributedString*)SXRChart2ViewTopRightTip:(SXRChart2View*)view;
-(NSString*)SXRChart2ViewMaxValueTip:(SXRChart2View*)view;
-(NSString*)SXRChart2ViewMinValueTip:(SXRChart2View*)view;
-(NSDate*)SXRChart2ViewBeginDate:(SXRChart2View*)view;
-(NSInteger)SXRChart2ViewCurrentMode:(SXRChart2View*)view;
@optional
-(CGFloat)SXRChart2ViewMiddleLabel1Value:(SXRChart2View *)view;
-(CGFloat)SXRChart2ViewMiddleLabel2Value:(SXRChart2View *)view;
-(void)SXRChart2ViewBeginOnTouched:(SXRChart2View *)view;
-(BOOL)SXRChart2ViewNeedTips:(SXRChart2View *)view;

@end

@interface SXRChart2View : UIView

@property(weak,nonatomic)id<SXRChart2ViewDelegate> delegate;
//当前模式，日，周，月，年
@property(nonatomic,assign)NSInteger currentMode;
@property(nonatomic,strong)NSDate* beginDate;
@property(assign, nonatomic) CGFloat topTipHeight;
//当前图示类型1-连线图，2-最大最小点柱图
@property(assign, nonatomic)NSInteger barType;
-(void)reload;
-(void)hiddenTips;

@end
