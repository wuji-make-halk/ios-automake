//
//  IRKSportProgress.m
//  Lovewell
//
//  Created by qf on 14-7-11.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//
#import "UICountingLabel.h"
#import "IRKSportProgress.h"
#import "IRKCommonData.h"
#import "CommonDefine.h"
@interface IRKSportProgress ()
@property (assign, nonatomic) CGFloat outter_radius;
@property (assign, nonatomic) CGFloat outter_linewidth;
@property (assign, nonatomic) CGFloat track_radius;
@property (assign, nonatomic) CGFloat track_width;
@property (strong, nonatomic) UILabel* label_top;
@property (strong, nonatomic) UICountingLabel* label_mid;
@property (strong, nonatomic) UIView* view_dot;
@property (nonatomic, strong) UICountingLabel *label_mid2;
@property (strong, nonatomic) UILabel* label_bottom;
@property (strong, nonatomic) UILabel* label_extra;

@property (assign, nonatomic) CGPoint center_point;

@property (strong, nonatomic) CAShapeLayer * boardLayer;
@property (strong, nonatomic) CAShapeLayer * trackLayer;
@property (strong, nonatomic) CAShapeLayer * progressLayer;
@property (strong, nonatomic) CAGradientLayer* gradiLayer;
@property (strong, nonatomic) CALayer* midLayer;
@property (assign, nonatomic) CGFloat  last_tovalue;
@property (assign, nonatomic) NSInteger last_balance_tag;
@property (assign, nonatomic) CGFloat last_progress;
@property(nonatomic,strong) IRKCommonData *commondata;
@end

@implementation IRKSportProgress

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dataSegCount = 144;
        self.backgroundColor = [UIColor clearColor];
//        self.backgroundview = [[UIImageView alloc] initWithFrame:self.bounds];
//        self.backgroundview.image = self.backimg;
//        [self addSubview:self.backgroundview];
        self.boardLayer = [CAShapeLayer layer];
        self.trackLayer = [CAShapeLayer layer];
        self.gradiLayer = [CAGradientLayer layer];
        self.progressLayer = [CAShapeLayer layer];
        self.midLayer = [CALayer layer];
        
        self.outter_linewidth = 1;
        self.outter_radius = frame.size.width/2.0;
        self.track_radius = self.outter_radius*0.9;
        self.track_width = self.outter_radius*0.1;
        self.center_point = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
        self.radius = 99;
        self.linewidth = 19;
        self.label_top = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.label_top];
        self.label_mid = [[UICountingLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.label_mid];
        self.label_mid2 = [[UICountingLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.label_mid2];
        self.label_bottom = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label_bottom.adjustsFontSizeToFitWidth = YES;
        self.label_bottom.minimumScaleFactor = 0.5;
        [self addSubview:self.label_bottom];
        
        self.view_dot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.view_dot.layer.cornerRadius = 10;
        self.view_dot.hidden = YES;
        [self addSubview:self.view_dot];
        
        self.layers = [[NSMutableArray alloc] init];
        self.last_balance_tag = 0;
        self.last_tovalue = 0;
        self.last_progress = 0;
        self.commondata=[IRKCommonData SharedInstance];

        
    }
    return self;
}

-(void)drawBoard{
    self.boardLayer.frame = self.bounds;
    UIBezierPath* path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:self.center_point radius:self.outter_radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    self.boardLayer.path = path.CGPath;
    self.boardLayer.lineWidth = self.outter_linewidth;
    self.boardLayer.fillColor = [UIColor clearColor].CGColor;
    if (self.delegate && [self.delegate respondsToSelector:@selector(IRKSportProgressBoardColor:)]) {
        self.boardLayer.strokeColor = [self.delegate IRKSportProgressBoardColor:self].CGColor;
    }else{
        self.boardLayer.strokeColor = [UIColor colorWithRed:0xdb/255.0 green:0xdb/255.0 blue:0xdb/255.0 alpha:1].CGColor;
    }
    //[self.layer addSublayer:self.boardLayer];
}

-(void)drawTrack{
    self.trackLayer.frame = self.bounds;
    UIBezierPath* path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:self.center_point radius:self.track_radius startAngle:M_PI*2/3 endAngle:M_PI*2/3+M_PI*5/3 clockwise:YES];
    self.trackLayer.path = path.CGPath;
    self.trackLayer.lineWidth = 3.0;
    self.trackLayer.fillColor = [UIColor clearColor].CGColor;
    if (self.delegate && [self.delegate respondsToSelector:@selector(IRKSportProgressBoardColor:)]) self.trackLayer.strokeColor = [self.delegate IRKSportProgressBoardColor:self].CGColor;
    else self.trackLayer.strokeColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1].CGColor;
    [self.layer addSublayer:self.trackLayer];
}

-(void)drawProgress{
    
    CGFloat startangle = M_PI*2/3;
    CGFloat progress = [self.datasource getSportProgress];
    
    if (progress>1) {
        progress = 1;
    }
    
    if (self.last_progress == progress) {
        [self.layer insertSublayer:self.progressLayer above:self.trackLayer];
        return;
    }
    
    self.last_progress = progress;
    
    if (self.progressLayer) {
        [self.progressLayer removeFromSuperlayer];
        self.progressLayer = nil;
    }
    if (progress == 0) {
        return;
    }

    CGFloat endangle = progress*M_PI*5/3+startangle;
    
    [CATransaction begin];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 0;
    animation.removedOnCompletion = NO;
    animation.fromValue = @0; //shorthand for creating an NSNumber
    animation.toValue = @1; //shorthand for creating an NSNumber
    
    
    UIBezierPath* path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:self.center_point radius:self.track_radius startAngle:startangle endAngle:endangle clockwise:YES];
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.frame = self.bounds;
    self.progressLayer.path = path.CGPath;
    NSInteger balance_tag = [self.delegate IRKSportProgressCurrentSelectedBalance:self];
    if (balance_tag==3) {
        self.progressLayer.strokeColor = [UIColor colorWithRed:255/255.0 green:104/255.0 blue:91/255.0 alpha:1].CGColor;
        self.view_dot.backgroundColor = [UIColor colorWithRed:255/255.0 green:104/255.0 blue:91/255.0 alpha:1];
    }else if(balance_tag==2){
        self.progressLayer.strokeColor = [UIColor colorWithRed:0x6d/255.0 green:0xdb/255.0 blue:0xd8/255.0 alpha:1].CGColor;
        self.view_dot.backgroundColor = [UIColor colorWithRed:0x6d/255.0 green:0xdb/255.0 blue:0xd8/255.0 alpha:1];
    }else {
        self.progressLayer.strokeColor = [UIColor colorWithRed:0xef/255.0 green:0xca/255.0 blue:0x9e/255.0 alpha:1].CGColor;
        self.view_dot.backgroundColor = [UIColor colorWithRed:0xef/255.0 green:0xca/255.0 blue:0x9e/255.0 alpha:1];
    }
    //self.progressLayer.strokeColor = [self.datasource getSportProgressColor].CGColor;
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.lineCap = kCALineCapRound;
    self.progressLayer.lineWidth = 10;
    [self.progressLayer addAnimation:animation forKey:@"strokeEnd"];
    [self.layer addSublayer:self.progressLayer];
    [CATransaction commit];
    
    CGPoint point = [self pointForTrapezoidWithAngle:endangle andRadius:self.track_radius forCenter:self.center_point];
    self.view_dot.center = point;
    self.view_dot.hidden = NO;
    [self bringSubviewToFront:self.view_dot];
    
}

-(void) reinitLabels{

    CGFloat bigheight = self.frame.size.height/4.0;
    CGFloat smallheight = bigheight*0.3;
    CGFloat tovalue=0;//中间数字
    if ([self.datasource IRKSportProgressCurrentSteps:self]) {
        tovalue = [self.datasource IRKSportProgressCurrentSteps:self];
    }
    
    NSInteger balance_tag = [self.delegate IRKSportProgressCurrentSelectedBalance:self];
    
    if (balance_tag != self.last_balance_tag) {
        self.last_tovalue = 0;
    }
//    UIColor* titlecolor = [UIColor whiteColor];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(IRKSportProgressTitleColor:)]) {
//        titlecolor = [self.delegate IRKSportProgressTitleColor:self];
//        
//    }

    self.label_mid.frame = CGRectMake(CGRectGetWidth(self.frame)*0.1, self.frame.size.height/2.0-bigheight/2.0, CGRectGetWidth(self.frame)*0.8, bigheight);
    self.label_mid.adjustsFontSizeToFitWidth = YES;
    self.label_mid.minimumScaleFactor = 0.5;
    self.label_mid2.frame = CGRectMake(CGRectGetWidth(self.frame)*0.2, self.label_mid.frame.origin.y + bigheight+10, self.frame.size.width*0.6, smallheight*2);
    
    self.label_top.frame = CGRectMake(CGRectGetWidth(self.frame)*0.2, self.label_mid.frame.origin.y-smallheight*2.0-10, self.frame.size.width*0.6, smallheight*2);
    self.label_bottom.frame =CGRectMake(self.frame.size.width/2.0-self.track_radius/2+4, self.frame.size.height/2.0+self.track_radius-smallheight, self.track_radius-8, smallheight);
    self.label_top.font = [UIFont systemFontOfSize:smallheight*0.9];
    self.label_top.textAlignment = NSTextAlignmentCenter;
    self.label_mid.textAlignment = NSTextAlignmentCenter;
    self.label_mid2.textAlignment = NSTextAlignmentCenter;
    self.label_bottom.textAlignment = NSTextAlignmentCenter;
    self.label_bottom.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1];
    if (balance_tag==3){
        self.label_mid.textColor = [UIColor colorWithRed:255/255.0 green:104/255.0 blue:91/255.0 alpha:1];
    }else if(balance_tag==2){
        self.label_mid.textColor = [UIColor colorWithRed:0x6d/255.0 green:0xdb/255.0 blue:0xd8/255.0 alpha:1];
    }else {
        self.label_mid.textColor = [UIColor colorWithRed:0xef/255.0 green:0xca/255.0 blue:0x9e/255.0 alpha:1];
    }
    self.label_top.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1];
    
    self.label_top.text = [[self datasource] getSportText:1];
    self.label_bottom.text = [[self datasource] getSportText:3];
    
    self.label_bottom.font = [UIFont systemFontOfSize:smallheight*0.9];
    self.label_mid.font = [UIFont boldSystemFontOfSize:bigheight*0.9];
    
    self.label_top.adjustsFontSizeToFitWidth = YES;
    self.label_top.minimumScaleFactor = 0.5;
    self.label_top.numberOfLines = 0;
    self.label_mid2.adjustsFontSizeToFitWidth = YES;
    self.label_mid2.minimumScaleFactor = 0.5;
    self.label_mid2.numberOfLines = 0;
    
    self.label_mid.attributedFormatBlock = ^NSAttributedString* (float value){
        NSDictionary* highlight = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:bigheight*0.9]};
        NSString* prefix;
        if (balance_tag == 1||balance_tag==3) {
            prefix = [NSString stringWithFormat:@"%d", (int)value];
        }else{
            prefix = [NSString stringWithFormat:@"%.3f", value];
        }
        
        NSMutableAttributedString *prefixAttr = [[NSMutableAttributedString alloc] initWithString: prefix attributes: highlight];
//        if (balance_tag==3){
//            [prefixAttr appendAttributedString:[[NSAttributedString alloc]initWithString:NSLocalizedString(@"UNIT_KCAL", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}]];
//        }else if (balance_tag==2){
//            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//                [prefixAttr appendAttributedString:[[NSAttributedString alloc]initWithString:NSLocalizedString(@"UNIT_KM", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}]];
//            }else{
//                [prefixAttr appendAttributedString:[[NSAttributedString alloc]initWithString:NSLocalizedString(@"UNIT_MILE", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}]];
//            }
//        }else{
//            
//        }
        
        
        return prefixAttr;
    };
    [self.label_mid countFrom:self.last_tovalue to:tovalue withDuration:1];
    
    self.label_mid2.attributedFormatBlock = ^NSAttributedString* (float value){
        NSDictionary* highlight = @{ NSFontAttributeName: [UIFont systemFontOfSize:smallheight*0.8],NSForegroundColorAttributeName:[UIColor colorWithRed:0xCC/255.0 green:0xCC/255.0 blue:0xCC/255.0 alpha:1]};
        NSString* prefix;
        if (balance_tag == 1) {
            prefix = [NSString stringWithFormat:@"%@:%.0f%%", NSLocalizedString(@"sport_havedid", nil),value/self.commondata.target_steps*100];
        }else if (balance_tag==2){
            prefix = [NSString stringWithFormat:@"%@:%.0f%%", NSLocalizedString(@"sport_havedid", nil),value/self.commondata.target_distance*100];
        }else {
            prefix = [NSString stringWithFormat:@"%@:%.0f%%", NSLocalizedString(@"sport_havedid", nil),value/self.commondata.target_calorie*100];
        }
        
        NSMutableAttributedString *prefixAttr = [[NSMutableAttributedString alloc] initWithString: prefix attributes: highlight];
        return prefixAttr;
    };
    [self.label_mid2 countFrom:self.last_tovalue to:tovalue withDuration:1];
    
    
    self.last_tovalue = tovalue;
    self.last_balance_tag = balance_tag;

}
-(UIColor*)getColor:(CGFloat)f max:(int)maxcont pos:(float)angelinterval{

    float sr=253, sg=56, sb=0;
    float mr=174, mg=247, mb=73;
    float er=30, eg=204, eb=255;
    float wr=244, wg=0, wb=12;

    
    if (f>=-0.5*M_PI && f<0) {
        float r =(((mr-sr)/(maxcont/4.0))*(fabs(f-(-0.5*M_PI))/angelinterval)+sr)/255.;
        float g =(((mg-sg)/(maxcont/4.0))*(fabs(f-(-0.5*M_PI))/angelinterval)+sg)/255.;
        float b =(((mb-sb)/(maxcont/4.0))*(fabs(f-(-0.5*M_PI))/angelinterval)+sb)/255.;
        return [UIColor colorWithRed:r green:g blue:b alpha:1];
    }else if(f>0 && f<0.5*M_PI){
        float r =(((er-mr)/(maxcont/4.0))*((f)/angelinterval)+mr)/255.;
        float g =(((eg-mg)/(maxcont/4.0))*((f)/angelinterval)+mg)/255.;
        float b =(((eb-mb)/(maxcont/4.0))*((f)/angelinterval)+mb)/255.;
        return [UIColor colorWithRed:r green:g blue:b alpha:1];
    }else if(f>0.5*M_PI && f<M_PI){
        float r =(((wr-er)/(maxcont/4.0))*((f-(0.5*M_PI))/angelinterval)+er)/255.;
        float g =(((wg-eg)/(maxcont/4.0))*((f-(0.5*M_PI))/angelinterval)+eg)/255.;
        float b =(((wb-eb)/(maxcont/4.0))*((f-(0.5*M_PI))/angelinterval)+eb)/255.;
        return [UIColor colorWithRed:r green:g blue:b alpha:1];
        
    }else{
        float r =(((sr-wr)/(maxcont/4.0))*(fabs(f-(M_PI))/angelinterval)+wr)/255.;
        float g =(((sg-wg)/(maxcont/4.0))*(fabs(f-(M_PI))/angelinterval)+wg)/255.;
        float b =(((sb-wb)/(maxcont/4.0))*(fabs(f-(M_PI))/angelinterval)+wb)/255.;
        return [UIColor colorWithRed:r green:g blue:b alpha:1];
        
    }
    

}

-(void)drawTextBoard{
    if (self.midLayer) {
        [self.midLayer removeFromSuperlayer];
        self.midLayer = nil;
    }
    self.midLayer = [CALayer layer];
    self.midLayer.frame = CGRectMake(self.outter_linewidth, self.outter_linewidth, self.frame.size.width-self.outter_linewidth*2, self.frame.size.height-self.outter_linewidth*2);
    self.midLayer.cornerRadius = self.gradiLayer.frame.size.width/2.0;
    self.midLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.layer addSublayer:self.midLayer];
    
    
    if (self.gradiLayer) {
        [self.gradiLayer removeFromSuperlayer];
        self.gradiLayer = nil;
    }
    /*
    self.gradiLayer = [CAGradientLayer layer];
    self.gradiLayer.frame = CGRectMake(self.outter_linewidth, self.outter_linewidth, self.frame.size.width-self.outter_linewidth*2, self.frame.size.height-self.outter_linewidth*2);
//    self.gradiLayer.cornerRadius = self.gradiLayer.frame.size.width/2.0;
    
    UIColor *topColor = [UIColor colorWithRed:24/255.0 green:24/255.0 blue:24/255.0 alpha:1];
    UIColor *bottomColor = [UIColor colorWithRed:171/255.0 green:171/255.0 blue:171/255.0 alpha:1];
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = gradientColors;
    gradientLayer.locations = gradientLocations;
    [self.layer addSublayer:self.gradiLayer];
    
    [self.midLayer setMask:self.gradiLayer];
     */
}

-(void) reload{
    self.view_dot.hidden = YES;
    self.outter_linewidth = 1;
    self.outter_radius = self.frame.size.width/2.0;
    self.track_radius = self.outter_radius*0.87;
    self.track_width = self.outter_radius*0.13;
    self.center_point = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);

    if (self.boardLayer) {
        [self.boardLayer removeFromSuperlayer];
        self.boardLayer = nil;
    }
    self.boardLayer = [CAShapeLayer layer];
    if (self.trackLayer) {
        [self.trackLayer removeFromSuperlayer];
        self.trackLayer = nil;
    }
    self.trackLayer = [CAShapeLayer layer];
    
    
    
    [self drawBoard];//外圈

    [self drawTrack];
    
    self.radius = self.track_radius;
    self.linewidth = self.track_width;
    
    
    [self reinitLabels];
    
    [self drawProgress];
  

}
typedef void (^voidBlock)(void);
typedef float (^floatfloatBlock)(float);
typedef UIColor * (^floatColorBlock)(float,int, float);


-(CGPoint) pointForTrapezoidWithAngle:(float)a andRadius:(float)r  forCenter:(CGPoint)p{
    return CGPointMake(p.x + r*cos(a), p.y + r*sin(a));
}

-(void)drawGradientInContext:(CGContextRef)ctx  startingAngle:(float)a endingAngle:(float)b intRadius:(floatfloatBlock)intRadiusBlock outRadius:(floatfloatBlock)outRadiusBlock withGradientBlock:(floatColorBlock)colorBlock withSubdiv:(int)subdivCount withCenter:(CGPoint)center withScale:(float)scale
{
//    float angleDelta = (b-a)/subdivCount;
    CGFloat progress = [self.datasource getSportProgress];
    if (progress>1) {
        progress = 1;
    }

    float angleDelta = (1/(subdivCount*1.0))*2*M_PI;
//    float fractionDelta = 1.0/(subdivCount*1.0);
    
    CGPoint p0,p1,p2,p3, p4,p5;
    float currentAngle=a;
    p4=p0 = [self pointForTrapezoidWithAngle:currentAngle andRadius:intRadiusBlock(0) forCenter:center];
    p5=p3 = [self pointForTrapezoidWithAngle:currentAngle andRadius:outRadiusBlock(0) forCenter:center];
    CGMutablePathRef innerEnveloppe=CGPathCreateMutable(),
    outerEnveloppe=CGPathCreateMutable();
    
    CGPathMoveToPoint(outerEnveloppe, 0, p3.x, p3.y);
    CGPathMoveToPoint(innerEnveloppe, 0, p0.x, p0.y);
    CGContextSaveGState(ctx);
    
    CGContextSetLineWidth(ctx, (2*M_PI*self.radius)/(subdivCount*1.0));
    
    while (currentAngle<=b) {
        
 //       float fraction = (float)i/subdivCount;
        currentAngle=currentAngle+angleDelta;
        CGMutablePathRef trapezoid = CGPathCreateMutable();
        
        p1 = [self pointForTrapezoidWithAngle:currentAngle andRadius:intRadiusBlock(0) forCenter:center];
        p2 = [self pointForTrapezoidWithAngle:currentAngle andRadius:outRadiusBlock(0) forCenter:center];
        
        CGPathMoveToPoint(trapezoid, 0, p0.x, p0.y);
        CGPathAddLineToPoint(trapezoid, 0, p1.x, p1.y);
        CGPathAddLineToPoint(trapezoid, 0, p2.x, p2.y);
        CGPathAddLineToPoint(trapezoid, 0, p3.x, p3.y);
        CGPathCloseSubpath(trapezoid);
        
        CGPoint centerofTrapezoid = CGPointMake((p0.x+p1.x+p2.x+p3.x)/4, (p0.y+p1.y+p2.y+p3.y)/4);
        
        CGAffineTransform t = CGAffineTransformMakeTranslation(-centerofTrapezoid.x, -centerofTrapezoid.y);
        CGAffineTransform s = CGAffineTransformMakeScale(scale, scale);
        CGAffineTransform concat = CGAffineTransformConcat(t, CGAffineTransformConcat(s, CGAffineTransformInvert(t)));
        CGPathRef scaledPath = CGPathCreateCopyByTransformingPath(trapezoid, &concat);
        
        CGContextAddPath(ctx, scaledPath);
        CGContextSetFillColorWithColor(ctx,colorBlock(currentAngle,subdivCount,angleDelta).CGColor);
        CGContextSetStrokeColorWithColor(ctx, colorBlock(currentAngle,subdivCount,angleDelta).CGColor);
        if (progress>=1) {
            CGContextSetShadowWithColor(ctx, CGSizeZero, 5.0, colorBlock(currentAngle,subdivCount,angleDelta).CGColor);
        }
        
        CGContextSetMiterLimit(ctx, 0);
        
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
        CGPathRelease(trapezoid);
        p0=p1;
        p3=p2;
        
//        CGPathAddLineToPoint(outerEnveloppe, 0, p3.x, p3.y);
//        CGPathAddLineToPoint(innerEnveloppe, 0, p0.x, p0.y);
    }
//    CGContextSetLineWidth(ctx, 10);
//    CGContextSetLineJoin(ctx, kCGLineJoinRound);
//    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
//    CGContextAddPath(ctx, outerEnveloppe);
//    CGContextAddPath(ctx, innerEnveloppe);
//    CGContextMoveToPoint(ctx, p0.x, p0.y);
//    CGContextAddLineToPoint(ctx, p3.x, p3.y);
//    CGContextMoveToPoint(ctx, p4.x, p4.y);
 //   CGContextAddLineToPoint(ctx, p5.x, p5.y);
    CGContextStrokePath(ctx);
    
}
//#ifdef CUSTOM_VIVILIFE
//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef currentContext = UIGraphicsGetCurrentContext();
//    
//    CGGradientRef glossGradient;
//    CGColorSpaceRef rgbColorspace;
//    size_t num_locations = 2;
//    CGFloat locations[2] = { 0.0, 1.0 };
//    CGFloat components[8] = { 0x2b/255.0, 0x27/255.0, 0x28/255.0, 1,  // Start color
//        0xba/255.0, 0xb9/255.0, 0xb9/255.0, 1.0 }; // End color
//    
//    rgbColorspace = CGColorSpaceCreateDeviceRGB();
//    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
//    
//    CGRect currentBounds = self.bounds;
//    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
//    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
////    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
//    CGContextDrawRadialGradient(currentContext, glossGradient, self.center_point, 0, self.center_point, self.frame.size.width/2.0-self.outter_linewidth+1, 0);
//    CGGradientRelease(glossGradient);
//    CGColorSpaceRelease(rgbColorspace);
//}
//#endif
/*
-(void)drawRect:(CGRect)rect{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat startangle = -0.5*M_PI;
    CGFloat progress = [self.datasource getSportProgress];
    if (progress>1) {
        progress = 1;
    }
    if (progress == 0) {
        return;
    }
    CGFloat endangle = progress*2*M_PI+startangle;
    
    [self drawGradientInContext:ctx  startingAngle:startangle endingAngle:endangle intRadius:^float(float f) {
        //        return 0*f + radius/2*(1-f);
        //return 200+10*sin(M_PI*2*f*7);
        //        return 50+sqrtf(f)*200;
                return self.radius-self.linewidth/2.0;
    } outRadius:^float(float f) {
        //         return radius *f + radius/2*(1-f);
        return self.radius+self.linewidth/2.0;
        //        return 300+10*sin(M_PI*2*f*17);
    } withGradientBlock:^UIColor *(float f, int maxcont, float angelinterval) {
        
        //        return [UIColor colorWithHue:f saturation:1 brightness:1 alpha:1];
//        NSLog(@"f= %f",f);
//        float sr=255, sg=0, sb=0;
//        float mr=255, mg=255, mb=0;
//        float er=0, eg=255, eb=0;
        
        float sr=253, sg=56, sb=0;
        float mr=174, mg=247, mb=73;
        float er=30, eg=204, eb=255;
        float wr=244, wg=0, wb=12;
        
        
////        if (f<0.5*M_PI) {
//            float r =(((mr-sr)/(maxcont/2.0))*((f-(-0.5*M_PI))/angelinterval)+sr)/255.;
//            float g =(((mg-sg)/(maxcont/2.0))*((f-(-0.5*M_PI))/angelinterval)+sg)/255.;
//            float b =(((mb-sb)/(maxcont/2.0))*((f-(-0.5*M_PI))/angelinterval)+sb)/255.;
//            return [UIColor colorWithRed:r green:g blue:b alpha:1];
//        }else{
//            float r =(((er-mr)/(maxcont/2.0))*((f-(0.5*M_PI))/angelinterval)+mr)/255.;
//            float g =(((eg-mg)/(maxcont/2.0))*((f-(0.5*M_PI))/angelinterval)+mg)/255.;
//            float b =(((eb-mb)/(maxcont/2.0))*((f-(0.5*M_PI))/angelinterval)+mb)/255.;
//            return [UIColor colorWithRed:r green:g blue:b alpha:1];
//        }
////
 
        if (f>-0.5*M_PI && f<0) {
            float r =(((mr-sr)/(maxcont/4.0))*(fabsf(f-(-0.5*M_PI))/angelinterval)+sr)/255.;
            float g =(((mg-sg)/(maxcont/4.0))*(fabsf(f-(-0.5*M_PI))/angelinterval)+sg)/255.;
            float b =(((mb-sb)/(maxcont/4.0))*(fabsf(f-(-0.5*M_PI))/angelinterval)+sb)/255.;
            return [UIColor colorWithRed:r green:g blue:b alpha:1];
        }else if(f>0 && f<0.5*M_PI){
            float r =(((er-mr)/(maxcont/4.0))*((f)/angelinterval)+mr)/255.;
            float g =(((eg-mg)/(maxcont/4.0))*((f)/angelinterval)+mg)/255.;
            float b =(((eb-mb)/(maxcont/4.0))*((f)/angelinterval)+mb)/255.;
            return [UIColor colorWithRed:r green:g blue:b alpha:1];
        }else if(f>0.5*M_PI && f<M_PI){
            float r =(((wr-er)/(maxcont/4.0))*((f-(0.5*M_PI))/angelinterval)+er)/255.;
            float g =(((wg-eg)/(maxcont/4.0))*((f-(0.5*M_PI))/angelinterval)+eg)/255.;
            float b =(((wb-eb)/(maxcont/4.0))*((f-(0.5*M_PI))/angelinterval)+eb)/255.;
            return [UIColor colorWithRed:r green:g blue:b alpha:1];
            
        }else{
            float r =(((sr-wr)/(maxcont/4.0))*(fabsf(f-(M_PI))/angelinterval)+wr)/255.;
            float g =(((sg-wg)/(maxcont/4.0))*(fabsf(f-(M_PI))/angelinterval)+wg)/255.;
            float b =(((sb-wb)/(maxcont/4.0))*(fabsf(f-(M_PI))/angelinterval)+wb)/255.;
            return [UIColor colorWithRed:r green:g blue:b alpha:1];

        }

        
    } withSubdiv:360 withCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) withScale:1];
}
/*

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    
//        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGFloat startangle = -0.5*M_PI;
        CGFloat progress = [self.datasource getSportProgress];
        if (progress>1) {
            progress = 1;
        }
        if (progress == 0) {
            return;
        }
        CGFloat endangle = progress*2*M_PI+startangle;
        
        [self drawGradientInContext:ctx  startingAngle:startangle endingAngle:endangle intRadius:^float(float f) {
            //        return 0*f + radius/2*(1-f);
            //return 200+10*sin(M_PI*2*f*7);
            //        return 50+sqrtf(f)*200;
            return self.radius-self.linewidth/2.0;
        } outRadius:^float(float f) {
            //         return radius *f + radius/2*(1-f);
            return self.radius+self.linewidth/2.0;
            //        return 300+10*sin(M_PI*2*f*17);
        } withGradientBlock:^UIColor *(float f, int maxcont, float angelinterval) {
            
            //        return [UIColor colorWithHue:f saturation:1 brightness:1 alpha:1];
            //        NSLog(@"f= %f",f);
            //        float sr=255, sg=0, sb=0;
            //        float mr=255, mg=255, mb=0;
            //        float er=0, eg=255, eb=0;
            
            float sr=253, sg=56, sb=0;
            float mr=174, mg=247, mb=73;
            float er=30, eg=204, eb=255;
            float wr=244, wg=0, wb=12;
            
            if (f>-0.5*M_PI && f<0) {
                float r =(((mr-sr)/(maxcont/4.0))*(fabsf(f-(-0.5*M_PI))/angelinterval)+sr)/255.;
                float g =(((mg-sg)/(maxcont/4.0))*(fabsf(f-(-0.5*M_PI))/angelinterval)+sg)/255.;
                float b =(((mb-sb)/(maxcont/4.0))*(fabsf(f-(-0.5*M_PI))/angelinterval)+sb)/255.;
                return [UIColor colorWithRed:r green:g blue:b alpha:1];
            }else if(f>0 && f<0.5*M_PI){
                float r =(((er-mr)/(maxcont/4.0))*((f)/angelinterval)+mr)/255.;
                float g =(((eg-mg)/(maxcont/4.0))*((f)/angelinterval)+mg)/255.;
                float b =(((eb-mb)/(maxcont/4.0))*((f)/angelinterval)+mb)/255.;
                return [UIColor colorWithRed:r green:g blue:b alpha:1];
            }else if(f>0.5*M_PI && f<M_PI){
                float r =(((wr-er)/(maxcont/4.0))*((f-(0.5*M_PI))/angelinterval)+er)/255.;
                float g =(((wg-eg)/(maxcont/4.0))*((f-(0.5*M_PI))/angelinterval)+eg)/255.;
                float b =(((wb-eb)/(maxcont/4.0))*((f-(0.5*M_PI))/angelinterval)+eb)/255.;
                return [UIColor colorWithRed:r green:g blue:b alpha:1];
                
            }else{
                float r =(((sr-wr)/(maxcont/4.0))*(fabsf(f-(M_PI))/angelinterval)+wr)/255.;
                float g =(((sg-wg)/(maxcont/4.0))*(fabsf(f-(M_PI))/angelinterval)+wg)/255.;
                float b =(((sb-wb)/(maxcont/4.0))*(fabsf(f-(M_PI))/angelinterval)+wb)/255.;
                return [UIColor colorWithRed:r green:g blue:b alpha:1];
                
            }
            
            
        } withSubdiv:360 withCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) withScale:1];
    
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"storke"];
    animation.duration=8.0;
    animation.repeatCount=HUGE_VALF;
    animation.autoreverses=NO;
    animation.fromValue=[NSNumber numberWithFloat:0.0];
    animation.toValue=[NSNumber numberWithFloat:1];
    [layer addAnimation:animation forKey:@"stroke"];
}
 */
    
@end
