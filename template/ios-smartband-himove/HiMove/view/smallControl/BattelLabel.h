//
//  BattelLabel.h
//  pageviewtest
//
//  Created by qf on 14-5-4.
//  Copyright (c) 2014年 clousky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BattelLabel;
@protocol BattelLabelDataSource <NSObject>
@required

- (CGFloat)DegreeOfBattel:(BattelLabel *)battelLabel;
- (UIColor *)BattelLabel:(BattelLabel *)battelLabel colorForDegree:(CGFloat)degree;
- (UIColor *)BoardColor:(BattelLabel *)battelLabel;

@optional
- (CGFloat )RateForBoardBody:(BattelLabel *)battelLabel;

@end

@protocol BattelLabelDelegate <NSObject>


@end


@interface BattelLabel : UIView

@property(nonatomic, strong) UIView *view;
@property CGFloat degree;
@property (weak, nonatomic) id <BattelLabelDataSource> dataSource;
@property (weak, nonatomic) id <BattelLabelDelegate> delegate;
@property UIColor * boardColor;
@property UIColor * degreeColor;
@property CGFloat BoardBodyRate;
@property CGFloat conerRadius;
@property CGFloat boarderLineWidth;

@property CAShapeLayer * boardBodyLayer;
@property CAShapeLayer * boardHeadLayer;
@property CAShapeLayer * degreeLayer;
//#ifdef CUSTOM_FITBAND
//@property (strong, nonatomic) UILabel* labeldegree;
//#endif
@property (strong, nonatomic) UILabel* labeldegree;

-(void) reload;

@end
