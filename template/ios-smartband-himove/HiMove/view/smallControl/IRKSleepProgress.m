//
//  IRKSleepProgress.m
//  JSDBong
//
//  Created by qf on 14-6-26.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//
#import "UICountingLabel.h"
#import "IRKSleepProgress.h"
@interface IRKSleepProgress ()
@property (strong, nonatomic) CAShapeLayer * deepLayer;
@property (strong, nonatomic) CAShapeLayer * lightLayer;
@property (strong, nonatomic) CAShapeLayer * unsleepLayer;
@property (strong, nonatomic) CAShapeLayer * exlightLayer;
@property (strong, nonatomic) CAShapeLayer * boardLayer;
@property (strong, nonatomic) CAShapeLayer * trackLayer;
@property (strong, nonatomic) CAShapeLayer * graduateLayer;


@property (assign, nonatomic) CGFloat outter_radius;
@property (assign, nonatomic) CGFloat outter_linewidth;
@property (assign, nonatomic) CGFloat track_radius;
@property (assign, nonatomic) CGFloat track_width;
@property (strong, nonatomic) UILabel* label_top;
@property (strong, nonatomic) UICountingLabel* label_mid;
@property (strong, nonatomic) UILabel* label_mid_unit;
@property (strong, nonatomic) UILabel* label_bottom;
@property (strong, nonatomic) UILabel* label_exbottom;


@property (assign, nonatomic) CGPoint center_point;

@property (assign, nonatomic) CGFloat graduate_width;
@property (assign, nonatomic) CGFloat graduate_height;
@property (assign, nonatomic) CGFloat graduate_fontsize;
@property (assign, nonatomic) CGSize graduate_textsize;
@property (assign, nonatomic) CGFloat progress_radius;
@property (assign, nonatomic) CGFloat progress_linewidth;
@property (strong, nonatomic) UILabel* Label_PM12;
@property (strong, nonatomic) UILabel* Label_PM6;
@property (strong, nonatomic) UILabel* Label_AM12;
@property (strong, nonatomic) UILabel* Label_AM6;
@property (strong, nonatomic) UILabel* Label_PM9;
@property (strong, nonatomic) UILabel* Label_PM3;
@property (strong, nonatomic) UILabel* Label_AM9;
@property (strong, nonatomic) UILabel* Label_AM3;

@property (strong, nonatomic) UILabel* Label_TimeTop;
@property (strong, nonatomic) UILabel* Label_TimeLeft;
@property (strong, nonatomic) UILabel* Label_TimeBottom;
@property (strong, nonatomic) UILabel* Label_TimeRight;

@property (strong, nonatomic) UIColor* titlecolor;

@end

@implementation IRKSleepProgress

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.commondata = [IRKCommonData SharedInstance];
        self.dataSegCount = 144;
//        self.backgroundview = [[UIImageView alloc] initWithFrame:self.bounds];
//        self.backgroundview.image = self.backimg;
//        [self addSubview:self.backgroundview];
        self.boardLayer = [CAShapeLayer layer];
        self.deepLayer = [CAShapeLayer layer];
        self.lightLayer = [CAShapeLayer layer];
        self.unsleepLayer = [CAShapeLayer layer];
        self.exlightLayer = [CAShapeLayer layer];
        self.graduateLayer = [CAShapeLayer layer];
        self.trackLayer = [CAShapeLayer layer];
        self.Label_PM12 = [[UILabel alloc] initWithFrame:CGRectZero];
        self.Label_PM6 = [[UILabel alloc] initWithFrame:CGRectZero];
        self.Label_AM12 = [[UILabel alloc] initWithFrame:CGRectZero];
        self.Label_AM6 = [[UILabel alloc] initWithFrame:CGRectZero];
        self.Label_PM3 = [[UILabel alloc] initWithFrame:CGRectZero];
        self.Label_PM9 = [[UILabel alloc] initWithFrame:CGRectZero];
        self.Label_AM3 = [[UILabel alloc] initWithFrame:CGRectZero];
        self.Label_AM9 = [[UILabel alloc] initWithFrame:CGRectZero];
        self.Label_TimeTop = [[UILabel alloc] initWithFrame:CGRectZero];
        self.Label_TimeBottom = [[UILabel alloc] initWithFrame:CGRectZero];
        self.Label_TimeRight = [[UILabel alloc] initWithFrame:CGRectZero];
        self.Label_TimeLeft = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.Label_PM12];
        [self addSubview:self.Label_AM12];
        [self addSubview:self.Label_PM6];
        [self addSubview:self.Label_AM6];
        [self addSubview:self.Label_PM3];
        [self addSubview:self.Label_AM3];
        [self addSubview:self.Label_PM9];
        [self addSubview:self.Label_AM9];
        [self addSubview:self.Label_TimeTop];
        [self addSubview:self.Label_TimeBottom];
        [self addSubview:self.Label_TimeRight];
        [self addSubview:self.Label_TimeLeft];
        
//        self.textLayerTop = [CATextLayer layer];
//        self.textLayerMiddle = [CATextLayer layer];
//        self.textLayerBottom = [CATextLayer layer];
        
        self.radius = 99;
        self.linewidth = 19;
        self.label_top = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label_top.adjustsFontSizeToFitWidth = YES;
        self.label_top.minimumScaleFactor = 0.5;
        self.label_top.numberOfLines = 0;
        [self addSubview:self.label_top];
        self.label_mid = [[UICountingLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.label_mid];
        self.label_bottom = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label_bottom.adjustsFontSizeToFitWidth = YES;
        self.label_bottom.minimumScaleFactor = 0.5;
        self.label_bottom.numberOfLines = 0;
        [self addSubview:self.label_bottom];
        self.label_mid_unit = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.label_mid_unit];
        self.label_exbottom = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.label_exbottom];
    }
    return self;
}
-(void) reinitLabels{
    CGFloat bigheight = self.frame.size.height/4.0;
    CGFloat smallheight = bigheight/3.0;
    
    self.label_mid.frame = CGRectMake(0, self.frame.size.height/2.0-bigheight/2.0, self.frame.size.width, bigheight);

    self.label_top.frame = CGRectMake(self.frame.size.width*0.2, self.label_mid.frame.origin.y-smallheight*2.0-10, self.frame.size.width*0.6, smallheight*2.0);
    self.label_bottom.frame = CGRectMake(self.frame.size.width*0.2, self.label_mid.frame.origin.y + bigheight+10, self.frame.size.width*0.6, smallheight*2.0);

//    self.label_bottom.frame = CGRectMake(0, self.label_mid.frame.origin.y + bigheight, self.frame.size.width, smallheight);
    
    self.label_top.textAlignment = NSTextAlignmentCenter;
    self.label_mid.textAlignment = NSTextAlignmentCenter;
    self.label_bottom.textAlignment = NSTextAlignmentCenter;

    self.label_bottom.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1];
    self.label_mid.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0xcd/255.0 alpha:1];
    self.label_top.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1];
    
    self.label_top.text = [[self datasource] getText:1];
    
    self.label_bottom.text = [[self datasource] getText:3];
    
    self.label_top.font = [UIFont systemFontOfSize:smallheight*0.9];
    //self.label_bottom.font = [UIFont systemFontOfSize:smallheight*0.9];
    self.label_bottom.font = [UIFont systemFontOfSize:11];
    self.label_mid.font = [UIFont boldSystemFontOfSize:bigheight*0.9];
    
    CGFloat tovalue = [self.datasource IRKSleepProgressCurrentSleep:self];
    UIColor* tmpcolor = self.titlecolor;
    self.label_mid.attributedFormatBlock = ^NSAttributedString* (float value)
    {
        NSDictionary* highlight = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:bigheight*0.9], NSForegroundColorAttributeName:tmpcolor };
        
        NSString* prefix = [NSString stringWithFormat:@"%d:%.2d", (int)(value/3600),(int)(((int)value%3600)/60) ];
        NSMutableAttributedString* prefixAttr = [[NSMutableAttributedString alloc] initWithString: prefix
                                                                                       attributes: highlight];
        return prefixAttr;
    };
    [self.label_mid countFrom:0 to:tovalue withDuration:1];
    /*
    self.label_mid.layer.shadowColor      = [UIColor lightGrayColor].CGColor;
    self.label_mid.layer.shadowOffset     = CGSizeZero;
    self.label_mid.layer.masksToBounds    = YES;
    self.label_mid.layer.shadowOpacity    = 0.8;
    self.label_mid.layer.shadowRadius     = 5;
 */
}

-(void)drawGraduate{
    self.graduate_fontsize = 10;
    self.Label_PM12.frame = CGRectMake(0,0,self.graduate_height,self.graduate_height);
    self.Label_PM12.center = CGPointMake(CGRectGetWidth(self.frame)/2.0, self.graduate_height/2.0);
    self.Label_PM12.textAlignment = NSTextAlignmentCenter;
    if([self.commondata is24time])
        self.Label_PM12.text = @"0";//@"00:00";
    else
        self.Label_PM12.text = NSLocalizedString(@"12AM", nil);
    
    self.Label_PM12.font = [UIFont systemFontOfSize:self.graduate_fontsize];
    self.Label_PM12.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];

    self.Label_AM12.frame = CGRectMake(0,0,self.graduate_height,self.graduate_height);
    self.Label_AM12.center = CGPointMake(CGRectGetWidth(self.frame)/2.0,CGRectGetHeight(self.frame)-self.graduate_height/2.0);
    self.Label_AM12.textAlignment = NSTextAlignmentCenter;
    if([self.commondata is24time])
        self.Label_AM12.text = @"12";//@"12:00";
    else
        self.Label_AM12.text = NSLocalizedString(@"12PM", nil);
    self.Label_AM12.font = [UIFont systemFontOfSize:self.graduate_fontsize];
    self.Label_AM12.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];

    self.Label_PM6.frame = CGRectMake(0,0,self.graduate_height,self.graduate_height);
    self.Label_PM6.center = CGPointMake(self.graduate_height/2.0,CGRectGetHeight(self.frame)/2.0);

    self.Label_PM6.textAlignment = NSTextAlignmentCenter;
    if([self.commondata is24time])
        self.Label_PM6.text = @"18";//@"18:00";
    else
        self.Label_PM6.text = NSLocalizedString(@"6PM", nil);
    self.Label_PM6.font = [UIFont systemFontOfSize:self.graduate_fontsize];
    self.Label_PM6.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];

    self.Label_AM6.frame = CGRectMake(0,0,self.graduate_height,self.graduate_height);
    self.Label_AM6.center = CGPointMake(CGRectGetWidth(self.frame) - self.graduate_height/2.0,CGRectGetHeight(self.frame)/2.0);

    self.Label_AM6.textAlignment = NSTextAlignmentCenter;
    if([self.commondata is24time])
        self.Label_AM6.text = @"6";//@"6:00";
    else
        self.Label_AM6.text = NSLocalizedString(@"6AM", nil);
    self.Label_AM6.font = [UIFont systemFontOfSize:self.graduate_fontsize];
    self.Label_AM6.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
    
    self.Label_AM12.minimumScaleFactor = 0.5;
    self.Label_AM12.adjustsFontSizeToFitWidth = YES;
    self.Label_PM12.minimumScaleFactor = 0.5;
    self.Label_PM12.adjustsFontSizeToFitWidth = YES;
    self.Label_AM6.minimumScaleFactor = 0.5;
    self.Label_AM6.adjustsFontSizeToFitWidth = YES;
    self.Label_PM6.minimumScaleFactor = 0.5;
    self.Label_PM6.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.Label_AM12];
    [self addSubview:self.Label_PM12];
    [self addSubview:self.Label_AM6];
    [self addSubview:self.Label_PM6];

    self.graduateLayer.frame = self.bounds;
    UIBezierPath* path = [[UIBezierPath alloc] init];
    int count = 24;
    CGFloat degree_pos = (1/(count*1.0))*360;
    
    for (int i = 0; i<count; i++) {
        if (i%6 == 0) {
            continue;
        }
        CGFloat degree = ((degree_pos*i)/360)*2*M_PI;
        CGPoint start_pt = [self pointForTrapezoidWithAngle:degree andRadius:self.radius/*-self.outter_linewidth*/  forCenter:self.center_point];
        CGPoint end_pt = [self pointForTrapezoidWithAngle:degree andRadius:self.radius/*-self.outter_linewidth*/ - self.graduate_height + self.track_width/2.0 forCenter:self.center_point];
        [path moveToPoint:start_pt];
        [path addLineToPoint:end_pt];
    }
    
    
    
    
    
    self.graduateLayer.path = path.CGPath;
    self.graduateLayer.lineWidth = self.graduate_width;
    self.graduateLayer.fillColor = [UIColor clearColor].CGColor;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(IRKSleepProgressBoardColor:)]) {
//        self.graduateLayer.strokeColor = [self.delegate IRKSleepProgressBoardColor:self].CGColor;
//    }else{
        //self.graduateLayer.strokeColor = [UIColor colorWithRed:0xdb/255.0 green:0xdb/255.0 blue:0xdb/255.0 alpha:1].CGColor;
        self.graduateLayer.strokeColor = [UIColor whiteColor].CGColor;
    //}
    [self.layer addSublayer:self.graduateLayer];
    
    
}
-(void)drawBoard{
    self.boardLayer.frame = self.bounds;
    UIBezierPath* path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:self.center_point radius:self.outter_radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    self.boardLayer.path = path.CGPath;
    self.boardLayer.lineWidth = self.outter_linewidth;
    self.boardLayer.fillColor = [UIColor clearColor].CGColor;
    if (self.delegate && [self.delegate respondsToSelector:@selector(IRKSleepProgressBoardColor:)]) {
        self.boardLayer.strokeColor = [self.delegate IRKSleepProgressBoardColor:self].CGColor;
    }else{
        self.boardLayer.strokeColor = [UIColor colorWithRed:0xdb/255.0 green:0xdb/255.0 blue:0xdb/255.0 alpha:1].CGColor;
    }
    [self.layer addSublayer:self.boardLayer];
}

-(void)drawProgress{
    
    
    self.deepLayer.frame = self.bounds;
    self.deepLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.lightLayer.frame = self.bounds;
    self.lightLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.unsleepLayer.frame = self.bounds;
    self.unsleepLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.exlightLayer.frame = self.bounds;
    self.exlightLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    UIBezierPath* pathdeep = [UIBezierPath bezierPath];
    UIBezierPath* pathlight = [UIBezierPath bezierPath];
    UIBezierPath* pathexlight = [UIBezierPath bezierPath];
    UIBezierPath* pathun = [UIBezierPath bezierPath];
    
    CGFloat startangle_c = M_PI;
//    CGFloat endangle_c = M_PI+M_2_PI;
    if ([[self delegate] performSelector:@selector(getDataSegCount)]) {
        self.dataSegCount = [[self delegate] getDataSegCount];
    }
    CGFloat pos = (1/(self.dataSegCount*1.0))*2*M_PI;
    for (int idx = 0; idx<self.dataSegCount; idx++) {
        CGFloat startangle = startangle_c + idx*pos;
        CGFloat endangle = startangle_c + (idx+1)*pos;
        IRKSleepType sleeptype = [[self datasource] getSleepTypeByIndex:idx];
        //        NSLog(@"idx = %d startangle = %f, end = %f", idx, startangle, endangle);
        if (sleeptype == IRKSleepTypeDeepSleep) {
            //            NSLog(@"DEEP startangle = %f, end = %f", startangle, endangle);
            [pathdeep appendPath:[UIBezierPath bezierPathWithArcCenter:self.center_point radius:self.progress_radius startAngle:startangle endAngle:endangle clockwise:YES]];
        }else if (sleeptype == IRKSleepTypeLightSleep){
            //            NSLog(@"LIGHT startangle = %f, end = %f", startangle, endangle);
            [pathlight appendPath:[UIBezierPath bezierPathWithArcCenter:self.center_point radius:self.progress_radius startAngle:startangle endAngle:endangle clockwise:YES]];
            
        }else if (sleeptype == IRKSleepTypeExLightSleep){
            //            NSLog(@"LIGHT startangle = %f, end = %f", startangle, endangle);
            [pathexlight appendPath:[UIBezierPath bezierPathWithArcCenter:self.center_point radius:self.progress_radius startAngle:startangle endAngle:endangle clockwise:YES]];
        }else if (sleeptype == IRKSleepTypeAwake){
            //            NSLog(@"UN startangle = %f, end = %f", startangle, endangle);
            [pathun appendPath:[UIBezierPath bezierPathWithArcCenter:self.center_point radius:self.progress_radius startAngle:startangle endAngle:endangle clockwise:YES]];
            
        }
        
    }
    
    self.deepLayer.fillRule = kCAFillRuleNonZero;
    self.deepLayer.fillColor = nil;
    self.deepLayer.path				= pathdeep.CGPath;
    self.deepLayer.strokeColor		= [[self datasource] getColorByType:IRKSleepTypeDeepSleep ].CGColor;
    self.deepLayer.lineWidth			= self.progress_linewidth;
    self.deepLayer.lineJoin			= kCALineJoinBevel;
    /*
    self.deepLayer.shadowColor      = [[self datasource] getColorByType:IRKSleepTypeDeepSleep ].CGColor;
    self.deepLayer.shadowOffset     = CGSizeZero;
    self.deepLayer.masksToBounds    = YES;
    self.deepLayer.shadowOpacity    = 0.8;
    self.deepLayer.shadowRadius     = 5;
    */
    self.lightLayer.fillRule = kCAFillRuleNonZero;
    self.lightLayer.fillColor = nil;
    self.lightLayer.path				= pathlight.CGPath;
    self.lightLayer.strokeColor		= [[self datasource] getColorByType:IRKSleepTypeLightSleep ].CGColor;
    self.lightLayer.lineWidth			= self.progress_linewidth;
    self.lightLayer.lineJoin			= kCALineJoinBevel;

    self.exlightLayer.fillRule = kCAFillRuleNonZero;
    self.exlightLayer.fillColor = nil;
    self.exlightLayer.path				= pathexlight.CGPath;
    self.exlightLayer.strokeColor		= [[self datasource] getColorByType:IRKSleepTypeExLightSleep ].CGColor;
    self.exlightLayer.lineWidth			= self.progress_linewidth;
    self.exlightLayer.lineJoin			= kCALineJoinBevel;

    self.unsleepLayer.fillRule = kCAFillRuleNonZero;
    self.unsleepLayer.fillColor = nil;
    self.unsleepLayer.path				= pathun.CGPath;
    self.unsleepLayer.strokeColor		= [[self datasource] getColorByType:IRKSleepTypeAwake ].CGColor;
    self.unsleepLayer.lineWidth			= self.progress_linewidth;
    self.unsleepLayer.lineJoin			= kCALineJoinBevel;
    
    
    [self.layer addSublayer:self.deepLayer];
    [self.layer addSublayer:self.lightLayer];
    [self.layer addSublayer:self.unsleepLayer];
    [self.layer addSublayer:self.exlightLayer];
    
    
    [CATransaction begin];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 1.0f;
    animation.removedOnCompletion = NO;
    animation.fromValue = @0; //shorthand for creating an NSNumber
    animation.toValue = @1; //shorthand for creating an NSNumber
    
    [self.deepLayer addAnimation:animation forKey:@"animateStrokeEnd"];
    [self.lightLayer addAnimation:animation forKey:@"animateStrokeEnd"];
    [self.exlightLayer addAnimation:animation forKey:@"animateStrokeEnd"];
    [self.unsleepLayer addAnimation:animation forKey:@"animateStrokeEnd"];
    
    [CATransaction commit];
    
}
-(void)calcGraduateSize{
//    self.graduate_fontsize = 13;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(IRKSleepProgressGraduateFontSize:)]) {
//        self.graduate_fontsize = [self.delegate IRKSleepProgressGraduateFontSize:self];
//    }
//    self.graduate_textsize = CGSizeZero;
//    UIFont* font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    CGSize size = CGSizeZero;
//    double version = [[UIDevice currentDevice].systemVersion doubleValue];
//    NSString* str = NSLocalizedString(@"6PM", nil);
//    if (version >= 7.0){
//        size = [str sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
//    }else{
//        size = [str sizeWithFont:font];
//    }
//    if (self.graduate_textsize.width < size.width) {
//        self.graduate_textsize = CGSizeMake(size.width, self.graduate_textsize.height);
//    }
//    if (self.graduate_textsize.height < size.height) {
//        self.graduate_textsize = CGSizeMake(self.graduate_textsize.width, size.height);
//    }
//    
//    str = NSLocalizedString(@"6AM", nil);
//    if (version >= 7.0){
//        size = [str sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
//    }else{
//        size = [str sizeWithFont:font];
//    }
//    if (self.graduate_textsize.width < size.width) {
//        self.graduate_textsize = CGSizeMake(size.width, self.graduate_textsize.height);
//    }
//    if (self.graduate_textsize.height < size.height) {
//        self.graduate_textsize = CGSizeMake(self.graduate_textsize.width, size.height);
//    }
//    
//    str = NSLocalizedString(@"12AM", nil);
//    if (version >= 7.0){
//        size = [str sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
//    }else{
//        size = [str sizeWithFont:font];
//    }
//    if (self.graduate_textsize.width < size.width) {
//        self.graduate_textsize = CGSizeMake(size.width, self.graduate_textsize.height);
//    }
//    if (self.graduate_textsize.height < size.height) {
//        self.graduate_textsize = CGSizeMake(self.graduate_textsize.width, size.height);
//    }
//    
//    str = NSLocalizedString(@"12PM", nil);
//    if (version >= 7.0){
//        size = [str sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
//    }else{
//        size = [str sizeWithFont:font];
//    }
//    if (self.graduate_textsize.width < size.width) {
//        self.graduate_textsize = CGSizeMake(size.width, self.graduate_textsize.height);
//    }
//    if (self.graduate_textsize.height < size.height) {
//        self.graduate_textsize = CGSizeMake(self.graduate_textsize.width, size.height);
//    }
//    self.graduate_height = self.graduate_textsize.height;
//    self.graduate_width = 1;
    

}
-(void)calcGraduateSize2{
    self.graduate_fontsize = 13;//self.outter_linewidth * 0.3;

    self.graduate_textsize = CGSizeZero;
    
    UIFont* font = [UIFont systemFontOfSize:self.graduate_fontsize];
    CGSize size = CGSizeZero;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    //PM
    NSString* str =@"AM";
    if (version >= 7.0){
        size = [str sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    }else{
        size = [str sizeWithFont:font];
    }
    if (self.graduate_textsize.width < size.width) {
        self.graduate_textsize = CGSizeMake(size.width, self.graduate_textsize.height);
    }
    if (self.graduate_textsize.height < size.height) {
        self.graduate_textsize = CGSizeMake(self.graduate_textsize.width, size.height);
    }
    //AM
    str = @"PM";
    if (version >= 7.0){
        size = [str sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    }else{
        size = [str sizeWithFont:font];
    }
    if (self.graduate_textsize.width < size.width) {
        self.graduate_textsize = CGSizeMake(size.width, self.graduate_textsize.height);
    }
    if (self.graduate_textsize.height < size.height) {
        self.graduate_textsize = CGSizeMake(self.graduate_textsize.width, size.height);
    }
    //AM
    str = @"6";
    if (version >= 7.0){
        size = [str sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    }else{
        size = [str sizeWithFont:font];
    }
    if (self.graduate_textsize.width < size.width) {
        self.graduate_textsize = CGSizeMake(size.width, self.graduate_textsize.height);
    }
    if (self.graduate_textsize.height < size.height) {
        self.graduate_textsize = CGSizeMake(self.graduate_textsize.width, size.height);
    }
    //PM
    str = @"12";
    if (version >= 7.0){
        size = [str sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    }else{
        size = [str sizeWithFont:font];
    }
    if (self.graduate_textsize.width < size.width) {
        self.graduate_textsize = CGSizeMake(size.width, self.graduate_textsize.height);
    }
    if (self.graduate_textsize.height < size.height) {
        self.graduate_textsize = CGSizeMake(self.graduate_textsize.width, size.height);
    }
    self.graduate_height = self.graduate_textsize.height;
    self.graduate_width = 1;

}


//-(void)drawTrack{
//    self.trackLayer.frame = self.bounds;
//    UIBezierPath* path = [[UIBezierPath alloc] init];
//    [path addArcWithCenter:self.center_point radius:self.progress_radius startAngle:0 endAngle:2*M_PI clockwise:YES];
//    
//    self.trackLayer.path = path.CGPath;
//    self.trackLayer.lineWidth = self.progress_linewidth;
//    self.trackLayer.fillColor = [UIColor clearColor].CGColor;
//    self.trackLayer.strokeColor = [UIColor colorWithRed:0xd1/255.0 green:0xd1/255.0 blue:0xd1/255.0 alpha:1.0f].CGColor;
//
//    [self.layer addSublayer:self.trackLayer];
//
//}

-(void) reload{
    if (self.deepLayer) {
        [self.deepLayer removeFromSuperlayer];
        self.deepLayer = nil;
    }
    self.deepLayer = [CAShapeLayer layer];
    if (self.lightLayer) {
        [self.lightLayer removeFromSuperlayer];
        self.lightLayer = nil;
    }
    self.lightLayer = [CAShapeLayer layer];
    if (self.unsleepLayer) {
        [self.unsleepLayer removeFromSuperlayer];
        self.unsleepLayer = nil;
    }
    self.unsleepLayer = [CAShapeLayer layer];

    if (self.exlightLayer) {
        [self.exlightLayer removeFromSuperlayer];
        self.exlightLayer = nil;
    }
    self.exlightLayer = [CAShapeLayer layer];

    if (self.boardLayer) {
        [self.boardLayer removeFromSuperlayer];
        self.boardLayer = nil;
    }
    self.boardLayer = [CAShapeLayer layer];
    
    if (self.graduateLayer) {
        [self.graduateLayer removeFromSuperlayer];
        self.graduateLayer = nil;
    }
    self.graduateLayer = [CAShapeLayer layer];

    if (self.trackLayer) {
        [self.trackLayer removeFromSuperlayer];
        self.trackLayer = nil;
    }
    self.trackLayer = [CAShapeLayer layer];

    self.center_point = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    self.titlecolor = [UIColor whiteColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(IRKSleepProgressTitleColor:)]) {
        self.titlecolor = [self.delegate IRKSleepProgressTitleColor:self];
        
    }

    self.radius = self.frame.size.width/2.0;
    //self.outter_linewidth = self.frame.size.width*0.1;
    self.outter_linewidth = 5;
    self.graduate_width = 1;
    self.graduate_height = self.outter_linewidth*4;
    self.outter_radius = self.radius - self.outter_linewidth/2.0 - self.graduate_height;
    
    self.progress_linewidth = 10;
    self.progress_radius = self.outter_radius;
    [self calcGraduateSize];

    [self drawBoard];
    [self drawGraduate];
    [self drawProgress];
    [self reinitLabels];
    

}

-(CGPoint) pointForTrapezoidWithAngle:(float)a andRadius:(float)r  forCenter:(CGPoint)p{
    return CGPointMake(p.x + r*cos(a), p.y + r*sin(a));
}
//-(void)drawGraduate2{
//    self.Label_AM12.frame = CGRectMake(self.center_point.x - self.graduate_textsize.width/2.0, 0, self.graduate_textsize.width, self.graduate_textsize.height);
//    self.Label_AM12.textAlignment = NSTextAlignmentCenter;
//    self.Label_AM12.text = @"12";
//    self.Label_AM12.font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    self.Label_AM12.textColor = self.titlecolor;
//    [self bringSubviewToFront:self.Label_AM12];
//
//    self.Label_TimeTop.frame = CGRectMake(self.center_point.x - self.graduate_textsize.width/2.0, 0-self.graduate_textsize.height,self.graduate_textsize.width, self.graduate_textsize.height);
//    self.Label_TimeTop.textAlignment = NSTextAlignmentCenter;
//    self.Label_TimeTop.text = NSLocalizedString(@"AM", nil);
//    self.Label_TimeTop.font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    self.Label_TimeTop.textColor = self.titlecolor;
//
//    self.Label_PM12.frame = CGRectMake(self.center_point.x - self.graduate_textsize.width/2.0, self.frame.size.height - self.graduate_textsize.height, self.graduate_textsize.width, self.graduate_textsize.height);
//    self.Label_PM12.textAlignment = NSTextAlignmentCenter;
//    self.Label_PM12.text = @"12";
//    self.Label_PM12.font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    self.Label_PM12.textColor = self.titlecolor;
//    [self bringSubviewToFront:self.Label_PM12];
//
//    self.Label_TimeBottom.frame = CGRectMake(self.center_point.x - self.graduate_textsize.width/2.0, self.frame.size.height ,self.graduate_textsize.width, self.graduate_textsize.height);
//    self.Label_TimeBottom.textAlignment = NSTextAlignmentCenter;
//    self.Label_TimeBottom.text = NSLocalizedString(@"PM", nil);
//    self.Label_TimeBottom.font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    self.Label_TimeBottom.textColor = self.titlecolor;
//
//    self.Label_PM6.frame = CGRectMake(0, self.center_point.y - self.graduate_textsize.height/2.0, self.graduate_textsize.width, self.graduate_textsize.height);
//    self.Label_PM6.textAlignment = NSTextAlignmentCenter;
//    self.Label_PM6.text = @"6";
//    self.Label_PM6.font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    self.Label_PM6.textColor = self.titlecolor;
//    [self bringSubviewToFront:self.Label_PM6];
//
//    self.Label_TimeLeft.frame = CGRectMake(0 - self.graduate_textsize.width, self.center_point.y - self.graduate_textsize.height/2.0 ,self.graduate_textsize.width, self.graduate_textsize.height);
//    self.Label_TimeLeft.textAlignment = NSTextAlignmentCenter;
//    self.Label_TimeLeft.text = NSLocalizedString(@"PM", nil);
//    self.Label_TimeLeft.font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    self.Label_TimeLeft.textColor = self.titlecolor;
//
//    self.Label_AM6.frame = CGRectMake(self.frame.size.width - self.graduate_textsize.width ,self.center_point.y - self.graduate_textsize.height/2.0, self.graduate_textsize.width, self.graduate_textsize.height);
//    self.Label_AM6.textAlignment = NSTextAlignmentCenter;
//    self.Label_AM6.text = @"6";
//    self.Label_AM6.font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    self.Label_AM6.textColor = self.titlecolor;
//    [self bringSubviewToFront:self.Label_AM6];
//
//    CGPoint subpoint = [self pointForTrapezoidWithAngle:-45*(1/360.0)*2*M_PI andRadius:self.radius-self.outter_linewidth*0.25 forCenter:self.center_point];
//    self.Label_AM3.frame = CGRectMake(0 ,0, self.graduate_textsize.width, self.graduate_textsize.height);
//    self.Label_AM3.center = subpoint;
//    self.Label_AM3.textAlignment = NSTextAlignmentCenter;
//    self.Label_AM3.text = @"3";
//    self.Label_AM3.font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    self.Label_AM3.textColor = self.titlecolor;
//    [self bringSubviewToFront:self.Label_AM3];
//
//    subpoint = [self pointForTrapezoidWithAngle:135*(1/360.0)*2*M_PI andRadius:self.radius-self.outter_linewidth*0.25 forCenter:self.center_point];
//    self.Label_PM3.frame = CGRectMake(0 ,0, self.graduate_textsize.width, self.graduate_textsize.height);
//    self.Label_PM3.center = subpoint;
//    self.Label_PM3.textAlignment = NSTextAlignmentCenter;
//    self.Label_PM3.text = @"3";
//    self.Label_PM3.font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    self.Label_PM3.textColor = self.titlecolor;
//    [self bringSubviewToFront:self.Label_PM3];
//
//    subpoint = [self pointForTrapezoidWithAngle:45*(1/360.0)*2*M_PI andRadius:self.radius-self.outter_linewidth*0.25 forCenter:self.center_point];
//    self.Label_AM9.frame = CGRectMake(0 ,0, self.graduate_textsize.width, self.graduate_textsize.height);
//    self.Label_AM9.center = subpoint;
//    self.Label_AM9.textAlignment = NSTextAlignmentCenter;
//    self.Label_AM9.text = @"9";
//    self.Label_AM9.font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    self.Label_AM9.textColor = self.titlecolor;
//    [self bringSubviewToFront:self.Label_AM9];
//
//    subpoint = [self pointForTrapezoidWithAngle:-135*(1/360.0)*2*M_PI andRadius:self.radius-self.outter_linewidth*0.25 forCenter:self.center_point];
//    self.Label_PM9.frame = CGRectMake(0 ,0, self.graduate_textsize.width, self.graduate_textsize.height);
//    self.Label_PM9.center = subpoint;
//    self.Label_PM9.textAlignment = NSTextAlignmentCenter;
//    self.Label_PM9.text = @"9";
//    self.Label_PM9.font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    self.Label_PM9.textColor = self.titlecolor;
//    [self bringSubviewToFront:self.Label_PM9];
//
//
//    self.Label_TimeRight.frame = CGRectMake(self.frame.size.width, self.center_point.y - self.graduate_textsize.height/2.0 ,self.graduate_textsize.width, self.graduate_textsize.height);
//    self.Label_TimeRight.textAlignment = NSTextAlignmentCenter;
//    self.Label_TimeRight.text = NSLocalizedString(@"AM", nil);
//    self.Label_TimeRight.font = [UIFont systemFontOfSize:self.graduate_fontsize];
//    self.Label_TimeRight.textColor = self.titlecolor;
//
//    self.graduate_width = 1;
//    self.graduateLayer.frame = self.bounds;
//    UIBezierPath* path = [[UIBezierPath alloc] init];
//    int count = 24;
//    CGFloat degree_pos = (1/(count*1.0))*360;
//
//    for (int i = 0; i<count; i++) {
//        if (i%3 == 0) {
//            CGFloat degree = ((degree_pos*i)/360)*2*M_PI;
//            CGPoint start_pt = [self pointForTrapezoidWithAngle:degree andRadius:self.radius-self.outter_linewidth+self.progress_linewidth  forCenter:self.center_point];
//            CGPoint end_pt = [self pointForTrapezoidWithAngle:degree andRadius:self.radius-self.outter_linewidth*0.5 forCenter:self.center_point];
//            [path moveToPoint:start_pt];
//            [path addLineToPoint:end_pt];
//        }else{
//            CGFloat degree = ((degree_pos*i)/360)*2*M_PI;
//            CGPoint start_pt = [self pointForTrapezoidWithAngle:degree andRadius:self.radius-self.outter_linewidth+self.progress_linewidth  forCenter:self.center_point];
//            CGPoint end_pt = [self pointForTrapezoidWithAngle:degree andRadius:self.radius forCenter:self.center_point];
//            [path moveToPoint:start_pt];
//            [path addLineToPoint:end_pt];
//        }
//    }
//
//
//
//
//
//    self.graduateLayer.path = path.CGPath;
//    self.graduateLayer.lineWidth = self.graduate_width;
//    self.graduateLayer.fillColor = [UIColor clearColor].CGColor;
//    self.graduateLayer.strokeColor = [UIColor colorWithRed:0xd1/255.0 green:0xd1/255.0 blue:0xd1/255.0 alpha:1.0f].CGColor;
//
//    [self.layer addSublayer:self.graduateLayer];
//
//
//}
@end
