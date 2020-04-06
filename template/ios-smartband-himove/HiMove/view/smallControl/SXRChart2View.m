//
//  SXRChart2View.m
//  SXRBand
//
//  Created by qf on 16/4/15.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "SXRChart2View.h"
#import "IRKCommonData.h"
@interface SXRChart2View()
//上下左右的缩进
@property (assign, nonatomic) CGFloat board_offset;
//图标框的左右缩进
@property (assign, nonatomic) CGFloat chart_rightoffset;
@property (assign, nonatomic) CGFloat chart_leftoffset;

//左右两侧的顶部提示框
@property (strong, nonatomic) UILabel* leftTip;
@property (strong, nonatomic) UILabel* rightTip;
@property (strong, nonatomic) UILabel* maxValueLabel;
@property (strong, nonatomic) UILabel* minValueLabel;
@property (strong, nonatomic) UILabel* middleValueLabel1;
@property (strong, nonatomic) UILabel* middleValueLabel2;

//上下的分割线
@property (strong, nonatomic) UIView* topSep;
@property (strong, nonatomic) UIView* bottomSep;


@property (assign, nonatomic) CGFloat topTargetHeight;
@property (assign, nonatomic) CGFloat bottomLabelHeight;
@property (assign, nonatomic) CGFloat chartHeight;
@property (assign, nonatomic) CGFloat chartWidth;

//图表的原点(左下点)
@property (assign, nonatomic) CGPoint pointDot;

//每列的宽度
@property (assign, nonatomic) CGFloat barWidth;
//每个像素代表的value
@property (assign, nonatomic) CGFloat yPos;

@property (assign, nonatomic) NSUInteger numberOfBars;
//x轴
@property (strong, nonatomic) NSMutableArray *barLabels;
@property (assign, nonatomic) CGFloat xLabelMaxWidth;
@property (assign, nonatomic) CGFloat xLabelFontSize;
@property (assign, nonatomic) NSUInteger xMarkFilter;

@property (assign, nonatomic) CGFloat yTopValue;

//分割线颜色
@property (strong, nonatomic) UIColor* seperatorColor;
@property (strong, nonatomic) UIColor* barColor;
@property (strong, nonatomic) UIColor* textColor;


//bar layer
@property (strong, nonatomic) CAShapeLayer * barLayer;
@property (strong, nonatomic) NSMutableArray* barPathLayers;
@property (assign, nonatomic) CGFloat animationDuration;
@property (assign, nonatomic) CGFloat barGap;
@property (strong, nonatomic) CAShapeLayer * middleLayer;

//bar的值
@property (strong, nonatomic) NSMutableArray* valuearray;
//bar的显示值
@property (strong, nonatomic) NSMutableArray* xbarLabelarray;

@property (strong, nonatomic) IRKCommonData* commondata;
@property (strong, nonatomic) CAGradientLayer* gradLayer;
@property (strong, nonatomic) CAShapeLayer* dotLayer;

@property (nonatomic,assign) BOOL isGradient;
//可产生提示框的值
@property (nonatomic,strong) NSMutableArray* needtiparray;

@property (nonatomic,strong) UILabel* tipLabel;
@property (nonatomic,strong) UILabel* tipLineView;
@property (nonatomic,assign) BOOL needTip;
@property (nonatomic,strong) UIColor* backcolor;
@end

@implementation SXRChart2View

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.commondata = [IRKCommonData SharedInstance];
        self.board_offset = 10;
        self.chart_leftoffset = 10;
        self.chart_rightoffset = 40;
        self.barGap = 2;
        self.topTipHeight = CGRectGetHeight(self.frame)*0.25;
        self.bottomLabelHeight = CGRectGetHeight(self.frame)*0.2;
        self.topTargetHeight = 12;
        self.xLabelFontSize = 10;
        self.needTip = NO;
        self.chartHeight = CGRectGetHeight(self.frame)-self.topTipHeight-self.bottomLabelHeight - self.topTargetHeight;
        self.chartWidth = CGRectGetWidth(self.frame)-self.chart_leftoffset-self.chart_rightoffset- self.chart_leftoffset;
        self.pointDot = CGPointMake(self.chart_leftoffset, CGRectGetHeight(self.frame)-self.bottomLabelHeight);
        
        self.valuearray = [[NSMutableArray alloc] init];
        self.xbarLabelarray = [[NSMutableArray alloc] init];
        
        self.leftTip = [[UILabel alloc] initWithFrame:CGRectMake(self.board_offset, 0, CGRectGetWidth(self.frame)/2.0-self.board_offset, self.topTipHeight)];
        self.leftTip.numberOfLines = 0;
        self.leftTip.textAlignment = NSTextAlignmentLeft;
        [self.leftTip setTextColor:[UIColor blackColor]];
        [self addSubview:self.leftTip];
        
        self.rightTip = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2.0, 0, CGRectGetWidth(self.frame)/2.0-self.board_offset, self.topTipHeight)];
        self.rightTip.numberOfLines = 0;
        self.rightTip.textAlignment = NSTextAlignmentRight;
        [self.rightTip setTextColor:[UIColor blackColor]];
        [self addSubview:self.rightTip];
        
        self.topSep = [[UIView alloc] initWithFrame:CGRectMake(self.board_offset, CGRectGetMaxY(self.leftTip.frame), CGRectGetWidth(self.frame)-2*self.board_offset, 0.5)];
        [self addSubview:self.topSep];
        
        self.bottomSep = [[UIView alloc] initWithFrame:CGRectMake(self.board_offset, CGRectGetHeight(self.frame)-self.bottomLabelHeight, CGRectGetWidth(self.frame)-2*self.board_offset, 0.5)];
        [self addSubview:self.bottomSep];
 
        self.maxValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-self.chart_rightoffset-self.board_offset, CGRectGetMaxY(self.rightTip.frame), self.chart_rightoffset, self.topTargetHeight)];
        self.maxValueLabel.textAlignment = NSTextAlignmentRight;
        self.maxValueLabel.font = [self.commondata getFontbySize:10 isBold:NO];
        self.maxValueLabel.adjustsFontSizeToFitWidth = YES;
        self.maxValueLabel.minimumScaleFactor = 0.5;
        [self.maxValueLabel setTextColor:[UIColor blackColor]];
        [self addSubview:self.maxValueLabel];
        
        self.minValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-self.chart_rightoffset-self.board_offset, CGRectGetMinY(self.bottomSep.frame)-self.topTargetHeight, self.chart_rightoffset, self.topTargetHeight)];
        self.minValueLabel.textAlignment = NSTextAlignmentRight;
        self.minValueLabel.font = [self.commondata getFontbySize:10 isBold:NO];
        self.minValueLabel.adjustsFontSizeToFitWidth = YES;
        self.minValueLabel.minimumScaleFactor = 0.5;
        [self.maxValueLabel setTextColor:[UIColor blackColor]];
        [self addSubview:self.minValueLabel];

        
        self.middleValueLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        self.middleValueLabel1.textAlignment = NSTextAlignmentRight;
        self.middleValueLabel1.font = [self.commondata getFontbySize:10 isBold:NO];
        self.middleValueLabel1.adjustsFontSizeToFitWidth = YES;
        self.middleValueLabel1.minimumScaleFactor = 0.5;
        [self.middleValueLabel1 setTextColor:[UIColor blackColor]];
        [self addSubview:self.middleValueLabel1];
        self.middleValueLabel1.hidden = YES;

        self.middleValueLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        self.middleValueLabel2.textAlignment = NSTextAlignmentRight;
        self.middleValueLabel2.font = [self.commondata getFontbySize:10 isBold:NO];
        self.middleValueLabel2.adjustsFontSizeToFitWidth = YES;
        self.middleValueLabel2.minimumScaleFactor = 0.5;
        [self.middleValueLabel2 setTextColor:[UIColor blackColor]];
        [self addSubview:self.middleValueLabel2];
        self.middleValueLabel2.hidden = YES;

        
        self.barLabels				= [[NSMutableArray alloc] init];
        self.valuearray             = [[NSMutableArray alloc] init];
        self.yTopValue              = 0;
        self.xMarkFilter            = 7;
        
        
        //       self.xLabelFontSize         = 14;
        
        //axis轴坐标view
        
        self.barLayer				= [CAShapeLayer layer];
        //        [self.layer addSublayer:self.barLayer];
        self.barPathLayers          = [[NSMutableArray alloc] init];
        self.animationDuration      = 0.5;
        
        _isGradient = NO;
        

    }
    return self;
}


-(void)reload{

    //self.backgroundColor = [self.delegate SXRChart2ViewBackgroundColor:self];
    if (self.tipLabel) {
        [self.tipLabel removeFromSuperview];
        self.tipLabel = nil;
    }
    if (self.tipLineView) {
        [self.tipLineView removeFromSuperview];
        self.tipLineView = nil;
    }

    self.backcolor = [UIColor blackColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(SXRChart2ViewBackgroundColor:)]) {
        self.backcolor = [self.delegate SXRChart2ViewBackgroundColor:self];
    }
    //渐变色只加载一次，每次点击切换日、周、月、年的时候会造成多次加载渐变色从而导致渐变色失效（原因未知）
    if(!_isGradient){
        _isGradient = YES;
        //方法一：实现渐变色
        UIColor *beforeColor = [self.backcolor colorWithAlphaComponent:0.5];
        //UIColor *centerColor = [[self.delegate SXRChart2ViewBackgroundColor:self] colorWithAlphaComponent:0.5];
        UIColor *afterColor = [self.backcolor colorWithAlphaComponent:1.0];
        CAGradientLayer *layer = [CAGradientLayer new];
        layer.colors = @[(id)beforeColor.CGColor,(id)afterColor.CGColor];
        layer.startPoint = CGPointMake(0, 0);
        layer.endPoint = CGPointMake(0, 1);
        layer.frame = self.bounds;
        [self.layer addSublayer:layer];
    }
      //方法二：实现渐变色
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.frame = self.frame;
//    // 设置渐变层的颜色，随机颜色渐变
//    gradientLayer.colors = @[(id)[self randomColor].CGColor, (id)[self randomColor].CGColor,(id)[self randomColor].CGColor];
//    // 疑问:渐变层能不能加在label上
//    // 疑问:渐变层能不能加在label上
//    // 不能，mask原理：默认会显示mask层底部的内容，如果渐变层放在mask层上，就不会显示了
//    // 添加渐变层到控制器的view图层上
//    [self.layer addSublayer:gradientLayer];
//    // mask层工作原理:按照透明度裁剪，只保留非透明部分，文字就是非透明的，因此除了文字，其他都被裁剪掉，这样就只会显示文字下面渐变层的内容，相当于留了文字的区域，让渐变层去填充文字的颜色。
//    // 设置渐变层的裁剪层
//    gradientLayer.mask = self.layer;
//    // 注意:一旦把label层设置为mask层，label层就不能显示了,会直接从父层中移除，然后作为渐变层的mask层，且label层的父层会指向渐变层，这样做的目的：以渐变层为坐标系，方便计算裁剪区域，如果以其他层为坐标系，还需要做点的转换，需要把别的坐标系上的点，转换成自己坐标系上点，判断当前点在不在裁剪范围内，比较麻烦。
//    // 父层改了，坐标系也就改了，需要重新设置label的位置，才能正确的设置裁剪区域。
//    self.frame = gradientLayer.bounds;
    
    self.textColor = [self.delegate SXRChart2ViewTextColor:self];
    self.currentMode = [self.delegate SXRChart2ViewCurrentMode:self];
    self.beginDate = [self.delegate SXRChart2ViewBeginDate:self];
    self.barColor = [self.delegate SXRChart2ViewBarColor:self];
    UIColor* sepcolor = [self.delegate SXRChart2ViewSepLineColor:self];
    self.xMarkFilter =  [self.delegate SXRChart2ViewXLabelFilter:self];
//    self.xbarLabelarray = [[self.delegate SXRChart2ViewXLabelArray:self] mutableCopy];
    self.valuearray = [[self.delegate SXRChart2ViewDataValueArray:self] mutableCopy];
    self.numberOfBars = [self.delegate SXRChart2ViewBarCount:self];
    self.yTopValue = [self.delegate SXRChart2ViewYLabelMaxValue:self];
    self.topSep.backgroundColor = sepcolor;
    self.bottomSep.backgroundColor = sepcolor;
    self.leftTip.attributedText = [self.delegate SXRChart2ViewTopLeftTip:self];
    self.rightTip.attributedText = [self.delegate SXRChart2ViewTopRightTip:self];
    self.maxValueLabel.textColor = self.textColor;
    self.minValueLabel.textColor = self.textColor;
    self.middleValueLabel2.textColor = self.textColor;
    self.middleValueLabel1.textColor = self.textColor;
    self.maxValueLabel.text = [self.delegate SXRChart2ViewMaxValueTip:self];
    self.minValueLabel.text = [self.delegate SXRChart2ViewMinValueTip:self];
    if (self.numberOfBars<=0) {
        self.barWidth = 0;
    }else{
        self.barWidth = self.chartWidth/(self.numberOfBars*1.0);

    }
    self.yPos = self.chartHeight/(self.yTopValue*1.0);
    if (self.delegate && [self.delegate respondsToSelector:@selector(SXRChart2ViewNeedTips:)]) {
        self.needTip = [self.delegate SXRChart2ViewNeedTips:self];
    }
    if (self.needTip) {
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,50,30)];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.font = [self.commondata getFontbySize:10 isBold:NO];
//        self.tipLabel.adjustsFontSizeToFitWidth = YES;
//        self.tipLabel.minimumScaleFactor = 0.5;
        [self.tipLabel setTextColor:[UIColor whiteColor]];
        self.tipLabel.numberOfLines = 2;
        self.tipLabel.layer.borderWidth = 0.5;
        self.tipLabel.backgroundColor = [self.backcolor colorWithAlphaComponent:0.7];
        self.tipLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.tipLabel.layer.cornerRadius = 2;
        [self addSubview:self.tipLabel];
        self.tipLabel.hidden = YES;
        
        self.tipLineView = [[UILabel alloc] initWithFrame:CGRectMake(0,CGRectGetMinY(self.topSep.frame),1,CGRectGetMinY(self.bottomSep.frame)-CGRectGetMaxY(self.topSep.frame))];
        self.tipLineView.backgroundColor=[UIColor whiteColor];
        [self addSubview:self.tipLineView];
        self.tipLineView.hidden = YES;

    }
    

    
    [self drawAxisLabel];
    [self drawMiddleLine];
    [self drawline];
    
    //添加layer的方法会把图层下面的字覆盖
    [self bringSubviewToFront:self.leftTip];
    [self bringSubviewToFront:self.rightTip];
    [self bringSubviewToFront:self.topSep];
    [self bringSubviewToFront:self.bottomSep];
    [self bringSubviewToFront:self.minValueLabel];
    [self bringSubviewToFront:self.maxValueLabel];
    [self bringSubviewToFront:self.middleValueLabel2];
    [self bringSubviewToFront:self.middleValueLabel1];
    [self bringSubviewToFront:self.tipLabel];
    [self bringSubviewToFront:self.tipLineView];
//    if (self.barType == BarTypeHeartLine) {
//        [self bringSubviewToFront:self.middleValueLabel2];
//        [self bringSubviewToFront:self.middleValueLabel1];
//    }else{
//        self.middleValueLabel1.hidden = YES;
//        self.middleValueLabel2.hidden = YES;
//    }
}

-(void)drawMiddleLine{
    if (self.barType == BarTypeHeartLine) {
        if (self.middleLayer) {
            [self.middleLayer removeFromSuperlayer];
            self.middleLayer = nil;
        }
        self.middleLayer = [CAShapeLayer layer];
        self.middleLayer.frame = self.bounds;

        float middle1value = 0;
        float middle2value = 0;
        if (self.delegate && [self.delegate respondsToSelector:@selector(SXRChart2ViewMiddleLabel1Value:)]) {
            middle1value = [self.delegate SXRChart2ViewMiddleLabel1Value:self];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(SXRChart2ViewMiddleLabel2Value:)]) {
            middle2value = [self.delegate SXRChart2ViewMiddleLabel2Value:self];
        }
        UIBezierPath* path = [[UIBezierPath alloc] init];
        if (middle1value>0) {
            CGFloat barheight = middle1value*self.yPos;
            if (barheight>self.chartHeight) {
                barheight = self.chartHeight;
            }
            [path moveToPoint:CGPointMake(self.board_offset, self.pointDot.y - barheight)];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(self.topSep.frame), self.pointDot.y -barheight)];
            self.middleValueLabel1.frame = CGRectMake(CGRectGetWidth(self.frame)-self.chart_rightoffset-self.board_offset,  self.pointDot.y -barheight, self.chart_rightoffset, self.topTargetHeight);
            self.middleValueLabel1.hidden = NO;
            self.middleValueLabel1.text = [NSString stringWithFormat:@"%.0f",middle1value];
        }
        if (middle2value>0) {
            CGFloat barheight = middle2value*self.yPos;
            if (barheight>self.chartHeight) {
                barheight = self.chartHeight;
            }
            [path moveToPoint:CGPointMake(self.board_offset, self.pointDot.y -barheight)];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(self.topSep.frame), self.pointDot.y -barheight)];
            self.middleValueLabel2.frame = CGRectMake(CGRectGetWidth(self.frame)-self.chart_rightoffset-self.board_offset,  self.pointDot.y -barheight, self.chart_rightoffset, self.topTargetHeight);
            self.middleValueLabel2.hidden = NO;
            self.middleValueLabel2.text = [NSString stringWithFormat:@"%.0f",middle2value];
       }
        
        
        self.middleLayer.path = path.CGPath;
        self.middleLayer.fillColor = nil;//self.barColor.CGColor;
        self.middleLayer.strokeColor = self.barColor.CGColor;
        self.middleLayer.lineWidth = 0.5;
        self.middleLayer.fillRule = kCAFillRuleNonZero;
        self.middleLayer.lineDashPattern = @[@4,@4];
        [self.layer addSublayer:self.middleLayer];
    }
}
//画X轴的文字
-(void)drawAxisLabel{
    __block CGPoint xbarcenter = CGPointMake(self.chart_leftoffset+self.board_offset+self.chartWidth/2.0, CGRectGetHeight(self.frame)-self.bottomLabelHeight/2.0);
   [self.xbarLabelarray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel* label = (UILabel*)obj;
        [UIView animateWithDuration:self.animationDuration/2.0 animations:^{
            label.center = xbarcenter;

        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
       
        label = nil;
    }];
    [self.xbarLabelarray removeAllObjects];
    
    int startindex;
    int filter;
    int labelcount;
    
    switch (self.currentMode) {
        case 0:{
//            if(self.barType == BarTypeHeartLine){
            startindex = 0;
            filter = (int)self.numberOfBars/2;
            labelcount = (int)self.numberOfBars/filter +1;
//            NSCalendar* calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
//            NSDateComponents* comp = [[NSDateComponents alloc] init];
//            comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:self.beginDate];
            
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
            format.dateFormat= @"h a";
            for (int i = 0; i<labelcount; i++) {
                int index = i* filter + startindex;
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
//                 comp.hour += index;
                if(self.numberOfBars == 1440){
                    label.text = [format stringFromDate:[self.beginDate dateByAddingTimeInterval:index*60]];
                }else{
                    label.text = [format stringFromDate:[self.beginDate dateByAddingTimeInterval:index*60*60]];
                }
                label.textColor = self.textColor;
                label.font = [self.commondata getFontbySize:self.xLabelFontSize isBold:NO];
                [label sizeToFit];
                label.center = xbarcenter;
                [self addSubview:label];
                
                [self.xbarLabelarray addObject:label];
                
                [UIView animateWithDuration:self.animationDuration animations:^{
                    CGFloat centerx = self.pointDot.x+self.barWidth/2.0+self.barWidth*index;
                    if (centerx-self.pointDot.x < CGRectGetWidth(label.frame)/2.0) {
                        centerx = self.pointDot.x+ CGRectGetWidth(label.frame)/2.0;
                    }
                    label.center = CGPointMake(centerx, xbarcenter.y);
                    
                }];
            }
            if (self.barType == BarTypeHeartLine) {
                for (int i = 0; i<=24; i++) {
                    int index = i* 60 + startindex;
                    
                    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(self.pointDot.x+self.barWidth/2.0+self.barWidth*index, CGRectGetHeight(self.frame)-self.bottomLabelHeight-2, 4, 4)];
                    label.backgroundColor = [UIColor whiteColor];
                    label.layer.cornerRadius = 2;
                    label.clipsToBounds = YES;
                    [self addSubview:label];
                    
                    [self.xbarLabelarray addObject:label];

                }
            }

        }
            break;
 
        case 1:{
            startindex = 0;
            filter = 1;
            labelcount = (int)self.numberOfBars;
            NSCalendar* calendar = [[NSCalendar alloc ] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents* comp = [[NSDateComponents alloc] init];
            comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.beginDate];
            
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
            format.dateFormat= [NSString stringWithFormat:@"MMMd%@",NSLocalizedString(@"Show_Day", nil)];
            NSDateFormatter* format1 = [[NSDateFormatter alloc] init];
            int lastmonth = -1;
            format1.dateFormat= @"d";
            for (int i = 0; i<labelcount; i++) {
                int index = i* filter + startindex;
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
                NSDate* date = [self.beginDate dateByAddingTimeInterval:i*24*60*60];
                comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
                if (comp.month != lastmonth){
                    label.text = [format stringFromDate:date];
                }else{
                    label.text = [format1 stringFromDate:date];
                }
                lastmonth = (int)comp.month;

                label.textColor = self.textColor;
                label.font = [self.commondata getFontbySize:self.xLabelFontSize isBold:NO];
                [label sizeToFit];
                label.center = xbarcenter;
                [self addSubview:label];
                [self.xbarLabelarray addObject:label];
                
                [UIView animateWithDuration:self.animationDuration animations:^{
                    label.center = CGPointMake(self.pointDot.x+self.barWidth/2.0+self.barWidth*index, xbarcenter.y);
                    
                }];
                
                if (self.tag<=2) {
                    UILabel* label1 = [[UILabel alloc] initWithFrame:CGRectMake(self.pointDot.x+self.barWidth/2.0+self.barWidth*index, CGRectGetHeight(self.frame)-self.bottomLabelHeight-2, 4, 4)];
                    label1.backgroundColor = [UIColor whiteColor];
                    label1.layer.cornerRadius = 2;
                    label1.clipsToBounds = YES;
                    [self addSubview:label1];
                    
                    [self.xbarLabelarray addObject:label1];
                    
                }
            }

        }
            break;

        case 2:{
            startindex = 2;
            filter = 7;

            labelcount = (int)self.numberOfBars/filter+1;
            NSCalendar* calendar = [[NSCalendar alloc ] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents* comp = [[NSDateComponents alloc] init];
            comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.beginDate];
            
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
            format.dateFormat= [NSString stringWithFormat:@"MMMd%@",NSLocalizedString(@"Show_Day", nil)];
            NSDateFormatter* format1 = [[NSDateFormatter alloc] init];
            int lastmonth = -1;
            format1.dateFormat= @"d";
            for (int i = 0; i<labelcount; i++) {
                int index = i* filter + startindex;
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
                NSDate* date = [self.beginDate dateByAddingTimeInterval:index*24*60*60];
                comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
                if (comp.month != lastmonth){
                    label.text = [format stringFromDate:date];
                }else{
                    label.text = [format1 stringFromDate:date];
                }
                lastmonth = (int)comp.month;
                
                label.textColor = self.textColor;
                label.font = [self.commondata getFontbySize:self.xLabelFontSize isBold:NO];
                [label sizeToFit];
                label.center = xbarcenter;
                [self addSubview:label];
                [self.xbarLabelarray addObject:label];
                
                [UIView animateWithDuration:self.animationDuration animations:^{
                    label.center = CGPointMake(self.pointDot.x+self.barWidth/2.0+self.barWidth*index, xbarcenter.y);
                    
                }];
                
            }
            if (self.tag<=2) {
                for(int i = 0 ; i<self.numberOfBars; i++){
//                    int index = i* filter + startindex;
                    UILabel* label1 = [[UILabel alloc] initWithFrame:CGRectMake(self.pointDot.x+self.barWidth/2.0+self.barWidth*i, CGRectGetHeight(self.frame)-self.bottomLabelHeight-2, 4, 4)];
                    label1.backgroundColor = [UIColor whiteColor];
                    label1.layer.cornerRadius = 2;
                    label1.clipsToBounds = YES;
                    [self addSubview:label1];
                    
                    [self.xbarLabelarray addObject:label1];

                }
                
            }

        }

            break;

        case 3:{
            startindex = 2;
            filter = 3;
            
            labelcount = (int)self.numberOfBars/filter;
//            NSCalendar* calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
//            NSDateComponents* comp = [[NSDateComponents alloc] init];
//            comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.beginDate];
            
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
            format.dateFormat= @"yyyy,MMM";
            NSDateFormatter* format1 = [[NSDateFormatter alloc] init];
            int lastyear = -1;
            format1.dateFormat= @"MMM";
            for (int i = 0; i<labelcount; i++) {
                int index = i* filter + startindex;
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
                NSCalendar* calendar = [[NSCalendar alloc ] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents* comp = [[NSDateComponents alloc] init];
                NSDateComponents* comp1 = [[NSDateComponents alloc] init];
                comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.beginDate];
                comp.month += (index+1);

                NSDate* date = [calendar dateFromComponents:comp];
                comp1 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
                if (comp1.year != lastyear){
                    label.text = [format stringFromDate:date];
                }else{
                    label.text = [format1 stringFromDate:date];
                }
                
                //如果大于当前月份的不显示
                if (comp1.year == lastyear)
                {
                    NSDateFormatter* format3 = [[NSDateFormatter alloc] init];
                    format3.dateFormat= @"MM";
                    NSString *tmpMonth = [format3 stringFromDate:date];
                    NSString *curMonth = [format3 stringFromDate:[NSDate date]];
                    
                    if(tmpMonth.intValue > curMonth.intValue)
                        return;
                }
                
                lastyear = (int)comp1.year;
                

                
                label.textColor = self.textColor;
                label.font = [self.commondata getFontbySize:self.xLabelFontSize isBold:NO];
                [label sizeToFit];
                label.center = xbarcenter;
                [self addSubview:label];
                [self.xbarLabelarray addObject:label];
                
                [UIView animateWithDuration:self.animationDuration animations:^{
                    label.center = CGPointMake(self.pointDot.x+self.barWidth/2.0+self.barWidth*index, xbarcenter.y);
                    
                }];
                if (self.tag<=2) {
                    for(int i = 0 ; i<self.numberOfBars; i++){
                        //                    int index = i* filter + startindex;
                        UILabel* label1 = [[UILabel alloc] initWithFrame:CGRectMake(self.pointDot.x+self.barWidth/2.0+self.barWidth*i, CGRectGetHeight(self.frame)-self.bottomLabelHeight-2, 4, 4)];
                        label1.backgroundColor = [UIColor whiteColor];
                        label1.layer.cornerRadius = 2;
                        label1.clipsToBounds = YES;
                        [self addSubview:label1];
                        
                        [self.xbarLabelarray addObject:label1];
                        
                    }
                    
                }

            }
            
        }
            break;

        default:
            break;
    }
    
}

-(void)drawline{
    if (self.barLayer) {
        [self.barLayer removeFromSuperlayer];
        self.barLayer = nil;
    }
    self.barLayer = [CAShapeLayer layer];
    self.barLayer.frame = self.bounds;
    
//    NSLog(@"self.bounds = %@",self.bounds);
    if (self.dotLayer){
        [self.dotLayer removeFromSuperlayer];
        self.dotLayer = nil;
    }
    self.dotLayer = [CAShapeLayer layer];
    self.dotLayer.frame = self.bounds;
    UIBezierPath* pathdot = [[UIBezierPath alloc] init];
    UIBezierPath* path = [[UIBezierPath alloc] init];
    CGFloat minY = self.pointDot.y;
    switch (self.currentMode) {
        case 0:
        case 1:
        case 2:
        case 3:{
            if (self.barType == BarTypeLine) {
                CGPoint lastpoint = CGPointZero;
                
                for (int i = 0; i<self.numberOfBars; i++) {
                    
                    NSNumber* value =@0;
                    if (self.valuearray.count>=i+1) {
                        value =[self.valuearray objectAtIndex:i];
                    }
                    
                    if (value.intValue < 0) {
                        value = @0;
                    }
                    CGFloat x = self.barWidth/2.0+self.barWidth*i + self.pointDot.x;
                    CGFloat barheight = value.floatValue*self.yPos;
                    if (barheight>self.chartHeight) {
                        barheight = self.chartHeight;
                    }
                    CGFloat y = self.pointDot.y - barheight;
                    if (y<minY) {
                        minY = y;
                    }
                    if (lastpoint.x == CGPointZero.x && lastpoint.y == CGPointZero.y) {
                        //不划线
                        [path moveToPoint:CGPointMake(x, y)];
                    }else{
                        
                        [path addLineToPoint:CGPointMake(x, y)];
                    }
                    
                    [pathdot moveToPoint:CGPointMake(x, y)];
                    //                mutablpath pathdot = CGPathCreateMutable();
                    //                [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:self.barGap startAngle:0 endAngle:2*M_PI clockwise:YES];
                    [pathdot addArcWithCenter:CGPointMake(x, y) radius:self.barGap startAngle:0 endAngle:2*M_PI clockwise:YES];
                    lastpoint = CGPointMake(x, y);
                }

            }else if(self.barType == BarTypeTwoPointBar){
                for (int i = 0; i<self.numberOfBars; i++) {
                    
                    NSNumber* maxvalue =@0;
                    NSNumber* minvalue = @0;
                    if (self.valuearray.count>=i+1) {
                        NSDictionary* dict  = (NSDictionary*)[self.valuearray objectAtIndex:i];
                        maxvalue = [dict objectForKey:@"max"];
                        minvalue = [dict objectForKey:@"min"];
                    }
//                    NSLog(@"maxvlue = %f,minvalue=%f",maxvalue.floatValue,minvalue.floatValue);
                    if (maxvalue.floatValue == 0 && minvalue.floatValue == 0) {
                        continue;
                    }
                    CGFloat x = self.barWidth/2.0+self.barWidth*i + self.pointDot.x;
                    CGFloat max_yheight = maxvalue.floatValue*self.yPos;
                    CGFloat min_yheight = minvalue.floatValue*self.yPos;
                    
                    
                    if (max_yheight>self.chartHeight) {
                        max_yheight = self.chartHeight;
                    }
                    if (min_yheight>self.chartHeight) {
                        min_yheight = self.chartHeight;
                    }
                    CGFloat max_y = self.pointDot.y-max_yheight;
                    CGFloat min_y = self.pointDot.y-min_yheight;
                    

//                    CGFloat y = self.pointDot.y - barheight;
//                    if (y<minY) {
//                        minY = y;
//                    }
//                    if()
//                    if (lastpoint.x == CGPointZero.x && lastpoint.y == CGPointZero.y) {
//                        //不划线
//                        [path moveToPoint:CGPointMake(x, y)];
//                    }else{
//                        
//                        [path addLineToPoint:CGPointMake(x, y)];
//                    }
                    [path moveToPoint:CGPointMake(x, min_y)];
                    [path addLineToPoint:CGPointMake(x, max_y)];
                    
                    [pathdot moveToPoint:CGPointMake(x, min_y)];
                    [pathdot addArcWithCenter:CGPointMake(x, min_y) radius:self.barGap startAngle:0 endAngle:2*M_PI clockwise:YES];
                    [pathdot moveToPoint:CGPointMake(x, max_y)];
                    [pathdot addArcWithCenter:CGPointMake(x, max_y) radius:self.barGap startAngle:0 endAngle:2*M_PI clockwise:YES];
                }

            }else{
                //barHeartLine
                CGPoint lastpoint = CGPointZero;
                CGPoint firstpoint = CGPointZero;
                for (int i = 0; i<self.numberOfBars; i++) {
                    
                    NSNumber* value =@0;
                    if (self.valuearray.count>=i+1) {
                        value =[self.valuearray objectAtIndex:i];
                    }
                    
                    if (value.floatValue < 0) {
                        value = @0;
                    }
                    
                    if (value.floatValue == 0) {
                        continue;
                    }
                    
                    CGFloat x = self.barWidth/2.0+self.barWidth*i + self.pointDot.x;
                    CGFloat barheight = value.floatValue*self.yPos;
                    if (barheight>self.chartHeight) {
                        barheight = self.chartHeight;
                    }
                    CGFloat y = self.pointDot.y - barheight;
                    if (y<minY) {
                        minY = y;
                    }
                    if (lastpoint.x == CGPointZero.x && lastpoint.y == CGPointZero.y) {
                        //不划线
                        [path moveToPoint:CGPointMake(x, y)];
                    }else{
                        
                        [path addLineToPoint:CGPointMake(x, y)];
                    }
                    
//                    [pathdot moveToPoint:CGPointMake(x, y)];
//                    //                mutablpath pathdot = CGPathCreateMutable();
//                    //                [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:self.barGap startAngle:0 endAngle:2*M_PI clockwise:YES];
//                    [pathdot addArcWithCenter:CGPointMake(x, y) radius:self.barGap startAngle:0 endAngle:2*M_PI clockwise:YES];
                    lastpoint = CGPointMake(x, y);
                    if (firstpoint.x == 0 && firstpoint.y == 0 ) {
                        firstpoint = CGPointMake(x, y);
                    }
                }
                if (CGPointEqualToPoint(lastpoint, firstpoint)) {
                    //只有一个点的时候画圆圈
                    [path addArcWithCenter:firstpoint radius:1 startAngle:0 endAngle:2*M_PI clockwise:YES];
                }

            }
        }
            break;

            
        default:
            break;
    }
    if (self.barType == BarTypeLine) {
        self.barLayer.path = path.CGPath;
        self.barLayer.fillColor = nil;//self.barColor.CGColor;
        self.barLayer.strokeColor = self.barColor.CGColor;
        self.barLayer.lineWidth = 1;
        self.barLayer.fillRule = kCAFillRuleNonZero;
        
        
        
        if (self.gradLayer) {
            [self.gradLayer removeFromSuperlayer];
            self.gradLayer = nil;
        }
        self.gradLayer = [CAGradientLayer layer];
        self.gradLayer.frame = self.bounds;
        self.gradLayer.colors = @[(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor,(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor];
        self.gradLayer.locations = @[@(0.4f) ,@(0.8f)];
        self.gradLayer.startPoint = CGPointMake(0, 0);
        self.gradLayer.endPoint = CGPointMake(0, 1);
        
        CAShapeLayer* mask = [CAShapeLayer layer];
        mask.frame = self.bounds;
        //    UIBezierPath* path1 = [[UIBezierPath alloc] init];
        //    [path1 moveToPoint:self.pointDot];
        //    [path1 addLineToPoint:CGPointMake(self.pointDot.x, minY)];
        //    [path1 addLineToPoint:CGPointMake(self.pointDot.x+self.chartWidth, minY)];
        //    [path1 addLineToPoint:CGPointMake(self.pointDot.x+self.chartWidth, self.pointDot.y)];
        //    [path1 closePath];
        [path addLineToPoint:CGPointMake(self.pointDot.x + self.chartWidth, self.pointDot.y)];
        [path addLineToPoint:self.pointDot];
        [path closePath];
        mask.path = path.CGPath;
        mask.fillColor = [UIColor orangeColor].CGColor;
        [self.gradLayer setMask:mask];
        //    self.gradLayer.hidden = YES;
        [self.layer addSublayer:self.gradLayer];
        
        
        
        [self.layer addSublayer:self.barLayer];
        
        
        self.dotLayer.path = pathdot.CGPath;
        self.dotLayer.fillColor = self.barColor.CGColor;
        self.dotLayer.strokeColor = self.barColor.CGColor;
        self.dotLayer.lineWidth = 1;
        self.dotLayer.fillRule = kCAFillRuleNonZero;
        [self.layer addSublayer:self.dotLayer];
        [CATransaction begin];
        [CATransaction setAnimationDuration:self.animationDuration*2];
        //	[CATransaction setAnimationDuration:1];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [CATransaction setCompletionBlock:nil];
        
        self.barLayer.hidden				= NO;
        [self.barLayer removeAllAnimations];
        
        CABasicAnimation *pathAnimation	= [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.fromValue			= [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue			= [NSNumber numberWithFloat:1.0f];
        [self.barLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
        
        //    self.gradLayer.hidden				= NO;
        //    [self.gradLayer removeAllAnimations];
        //
        //    CABasicAnimation *pathAnimation1	= [CABasicAnimation animationWithKeyPath:@"fillColor"];
        //    pathAnimation1.fromValue			= [NSNumber numberWithFloat:0.0f];
        //    pathAnimation1.toValue			= [NSNumber numberWithFloat:1.0f];
        //    [self.gradLayer addAnimation:pathAnimation1 forKey:@"fillColor"];
        [CATransaction commit];
        //设置渐变颜色方向
        //    self.gradLayer.startPoint = CGPointMake(0, 0);
        //    self.gradLayer.endPoint = CGPointMake(1, 0);
        ////    [self.barLayer addSublayer:self.gradLayer];
        //    [self.layer addSublayer:self.gradLayer];
        //    [self.gradLayer setMask:self.barLayer];

    }else if(self.barType == BarTypeTwoPointBar){
        self.barLayer.path = path.CGPath;
        self.barLayer.fillColor = nil;//self.barColor.CGColor;
        self.barLayer.strokeColor = [self.barColor colorWithAlphaComponent:0.5].CGColor;
        self.barLayer.lineWidth = self.barGap*2;
        self.barLayer.fillRule = kCAFillRuleNonZero;
        
        
        
        if (self.gradLayer) {
            [self.gradLayer removeFromSuperlayer];
            self.gradLayer = nil;
        }
//        self.gradLayer = [CAGradientLayer layer];
//        self.gradLayer.frame = self.bounds;
//        self.gradLayer.colors = @[(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor,(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor];
//        self.gradLayer.locations = @[@(0.4f) ,@(0.8f)];
//        self.gradLayer.startPoint = CGPointMake(0, 0);
//        self.gradLayer.endPoint = CGPointMake(0, 1);
//        
//        CAShapeLayer* mask = [CAShapeLayer layer];
//        mask.frame = self.bounds;
//        [path addLineToPoint:CGPointMake(self.pointDot.x + self.chartWidth, self.pointDot.y)];
//        [path addLineToPoint:self.pointDot];
//        [path closePath];
//        mask.path = path.CGPath;
//        mask.fillColor = [UIColor orangeColor].CGColor;
//        [self.gradLayer setMask:mask];
//        [self.layer addSublayer:self.gradLayer];
//        
//        
        
        [self.layer addSublayer:self.barLayer];
        
        
        self.dotLayer.path = pathdot.CGPath;
        self.dotLayer.fillColor = self.barColor.CGColor;
        self.dotLayer.strokeColor = self.barColor.CGColor;
        self.dotLayer.lineWidth = 1;
        self.dotLayer.fillRule = kCAFillRuleNonZero;
        [self.layer addSublayer:self.dotLayer];
        [CATransaction begin];
        [CATransaction setAnimationDuration:self.animationDuration*2];
        //	[CATransaction setAnimationDuration:1];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [CATransaction setCompletionBlock:nil];
        
        self.barLayer.hidden				= NO;
        [self.barLayer removeAllAnimations];
        
        CABasicAnimation *pathAnimation	= [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.fromValue			= [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue			= [NSNumber numberWithFloat:1.0f];
        [self.barLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
        
        [CATransaction commit];

    }else{
        self.barLayer.path = path.CGPath;
        self.barLayer.fillColor = nil;//self.barColor.CGColor;
        self.barLayer.strokeColor = self.barColor.CGColor;
        self.barLayer.lineWidth = 1;
        self.barLayer.fillRule = kCAFillRuleNonZero;
//        if (self.gradLayer) {
//            [self.gradLayer removeFromSuperlayer];
//            self.gradLayer = nil;
//        }
//        self.gradLayer = [CAGradientLayer layer];
//        self.gradLayer.frame = self.bounds;
//        self.gradLayer.colors = @[(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor,(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor];
//        self.gradLayer.locations = @[@(0.4f) ,@(0.8f)];
//        self.gradLayer.startPoint = CGPointMake(0, 0);
//        self.gradLayer.endPoint = CGPointMake(0, 1);
//        
//        CAShapeLayer* mask = [CAShapeLayer layer];
//        mask.frame = self.bounds;
//        //    UIBezierPath* path1 = [[UIBezierPath alloc] init];
//        //    [path1 moveToPoint:self.pointDot];
//        //    [path1 addLineToPoint:CGPointMake(self.pointDot.x, minY)];
//        //    [path1 addLineToPoint:CGPointMake(self.pointDot.x+self.chartWidth, minY)];
//        //    [path1 addLineToPoint:CGPointMake(self.pointDot.x+self.chartWidth, self.pointDot.y)];
//        //    [path1 closePath];
//        [path addLineToPoint:CGPointMake(self.pointDot.x + self.chartWidth, self.pointDot.y)];
//        [path addLineToPoint:self.pointDot];
//        [path closePath];
//        mask.path = path.CGPath;
//        mask.fillColor = [UIColor orangeColor].CGColor;
//        [self.gradLayer setMask:mask];
//        //    self.gradLayer.hidden = YES;
//        [self.layer addSublayer:self.gradLayer];
        
        
        
        [self.layer addSublayer:self.barLayer];
        
        
//        self.dotLayer.path = pathdot.CGPath;
//        self.dotLayer.fillColor = self.barColor.CGColor;
//        self.dotLayer.strokeColor = self.barColor.CGColor;
//        self.dotLayer.lineWidth = 1;
//        self.dotLayer.fillRule = kCAFillRuleNonZero;
//        [self.layer addSublayer:self.dotLayer];
        [CATransaction begin];
        [CATransaction setAnimationDuration:self.animationDuration*2];
        //	[CATransaction setAnimationDuration:1];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [CATransaction setCompletionBlock:nil];
        
        self.barLayer.hidden				= NO;
        [self.barLayer removeAllAnimations];
        
        CABasicAnimation *pathAnimation	= [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.fromValue			= [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue			= [NSNumber numberWithFloat:1.0f];
        [self.barLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
        
        //    self.gradLayer.hidden				= NO;
        //    [self.gradLayer removeAllAnimations];
        //
        //    CABasicAnimation *pathAnimation1	= [CABasicAnimation animationWithKeyPath:@"fillColor"];
        //    pathAnimation1.fromValue			= [NSNumber numberWithFloat:0.0f];
        //    pathAnimation1.toValue			= [NSNumber numberWithFloat:1.0f];
        //    [self.gradLayer addAnimation:pathAnimation1 forKey:@"fillColor"];
        [CATransaction commit];

    }
    

}
-(int)getNextDatabyIndex:(int)index{
    int loopi = index;
    if (index > self.numberOfBars - 1 || index < 0) {
        return -1;
    }
    NSNumber* nvalue = nil;
    for (int i = index; i<self.numberOfBars; i++) {
        nvalue = [self.valuearray objectAtIndex:i];
        loopi = i;
        if (nvalue.floatValue != 0) {
            break;
        }
    }
    if (loopi<self.numberOfBars && nvalue.floatValue != 0) {
        return loopi;
    }else{
        for (int i = index; i>=0; i--) {
            nvalue = [self.valuearray objectAtIndex:i];
            loopi = i;
            if (nvalue.floatValue != 0) {
                break;
            }
        }
        if (loopi>=0 && loopi<self.numberOfBars && nvalue.floatValue != 0) {
            return loopi;
        }else{
            return -1;
        }

    }
}

-(void)showTipsOnPoint:(CGPoint)point{
    
    CGFloat deltax = point.x - self.pointDot.x;
    if (deltax < 0) {
        deltax = 0;
    }
    int index = floor(deltax/self.barWidth);
//    NSLog(@"index = %d",index);
    int nextindex = [self getNextDatabyIndex:index];
//    NSLog(@"nextindex = %d",nextindex);
    if (nextindex < 0){
        return;
    }
    NSNumber* value = [self.valuearray objectAtIndex:nextindex];
    CGFloat x = self.barWidth/2.0+self.barWidth*nextindex + self.pointDot.x;
    CGFloat barheight = value.floatValue*self.yPos;
    if (barheight>self.chartHeight) {
        barheight = self.chartHeight;
    }
    CGFloat y = self.pointDot.y - barheight;
    

    CGRect f = self.tipLineView.frame;
    f.origin.x = x;
    self.tipLineView.frame = f;
    self.tipLineView.hidden = NO;
    NSString* timestr = [NSDateFormatter localizedStringFromDate:[self.beginDate dateByAddingTimeInterval:nextindex*60] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    NSString* tiptext = [NSString stringWithFormat:@"%@\n%@",[NSNumberFormatter localizedStringFromNumber:value numberStyle:NSNumberFormatterDecimalStyle],timestr];
    self.tipLabel.text = tiptext;
//    [self.tipLabel sizeToFit];
    self.tipLabel.hidden = NO;
    f = self.tipLabel.frame;
    if (x >= CGRectGetWidth(self.frame)*0.7) {
        f.origin.x = x-f.size.width;
    }else{
        f.origin.x = x;
    }
    f.origin.y = y-f.size.height;
    self.tipLabel.frame = f;
    
  

}

-(void)hiddenTips{
    self.tipLineView.hidden = YES;
    self.tipLabel.hidden = YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSLog(@"touchesBegan %@,%@",touches,event);

    if (self.delegate && [self.delegate respondsToSelector:@selector(SXRChart2ViewBeginOnTouched:)]) {
        [self.delegate SXRChart2ViewBeginOnTouched:self];
    }
    if (self.needTip == NO) {
        return;
    }
    UITouch* touch = [touches anyObject];
    CGPoint tp = [touch locationInView:self];
//    NSLog(@"tp = %@",NSStringFromCGPoint(tp));
    [self showTipsOnPoint:tp];

}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSLog(@"touchesMoved %@,%@",touches,event);
    if (self.needTip == NO) {
        return;
    }
    UITouch* touch = [touches anyObject];
    CGPoint tp = [touch locationInView:self];
//    NSLog(@"tp = %@",NSStringFromCGPoint(tp));
    [self showTipsOnPoint:tp];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.needTip == NO) {
        return;
    }
    
}
@end
