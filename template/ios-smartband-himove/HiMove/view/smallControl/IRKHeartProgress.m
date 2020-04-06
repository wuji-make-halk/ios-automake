//
//  IRKHeartProgress.m
//  SXRBand
//
//  Created by qf on 16/4/18.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "IRKHeartProgress.h"
#import "SWTextAttachment.h"
#import "IRKCommonData.h"
#import "CommonDefine.h"
@interface IRKHeartProgress()

@property (assign, nonatomic) CGFloat track_radius;
@property (assign, nonatomic) CGFloat track_width;
@property (assign, nonatomic) CGFloat radius;

@property (strong, nonatomic) UICountingLabel* label_mid;
//@property (strong, nonatomic) UILabel* label_bottom;


@property (assign, nonatomic) CGPoint center_point;


@property (assign, nonatomic) CGFloat progress_radius;
@property (assign, nonatomic) CGFloat progress_linewidth;

@property (strong, nonatomic) UIColor* titlecolor;
@property (strong, nonatomic) UIColor* trackcolor;
@property (strong, nonatomic) UIColor* progresscolor;
@property (strong, nonatomic) IRKCommonData* commondata;
@property (strong, nonatomic) CAShapeLayer* trackLayer;
@property (strong, nonatomic) CAShapeLayer* progressLayer;
@property (assign, nonatomic) CGFloat current_angel;
@property (assign, nonatomic) CGFloat current_move;
@property (assign, nonatomic) CGFloat angel_pos;
@property (assign, nonatomic) NSInteger heartvalue;
@property (assign, nonatomic) CGFloat floatValue;

@property (strong, nonatomic) CADisplayLink* link;
@property (assign, nonatomic) NSInteger alpha;
@property (strong, nonatomic) UILabel *label_tips;
@property (strong, nonatomic) UIView* dot_view;
@property (strong, nonatomic) NSMutableArray* progresslayers;
@end

@implementation IRKHeartProgress

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.commondata = [IRKCommonData SharedInstance];
        self.center_point =CGPointMake(CGRectGetWidth(self.frame)/2.0,CGRectGetHeight(self.frame)/2.0);
        self.trackLayer = [CAShapeLayer layer];
        self.progressLayer = [CAShapeLayer layer];
        [self.layer addSublayer:self.progressLayer];
        self.trackcolor = [UIColor colorWithRed:0xdb/255.0 green:0xdb/255.0 blue:0xdb/255.0 alpha:1];
        
        self.progresslayers = [[NSMutableArray alloc] init];
        self.progresscolor = [UIColor colorWithRed:0xff/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1];
        self.titlecolor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        self.radius = frame.size.width*0.9/2.0;
        self.label_mid = [[UICountingLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.label_mid];
        self.label_tips = [[UILabel alloc] initWithFrame:CGRectZero];
        //[self addSubview:self.label_tips];
        self.label_bottom = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.label_bottom];
        self.current_angel = 0;
        self.angel_pos = 3*((2*M_PI)/360.0);
//        self.current_move = 2*((2*M_PI)/360.0);
        self.current_angel = M_PI*2/3;
        self.heartvalue = 0;
        self.isShowFloat = NO;
        self.floatValue = 0;
        self.alpha = 0;
        self.dot_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.dot_view.layer.cornerRadius  = 10;
        [self addSubview:self.dot_view];
        self.dot_view.hidden = YES;
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)reload{
    NSInteger balance_tag = [self.delegate IRKHeartProgressCurrentSelectedBalance:self];
    self.backgroundColor = [self.delegate IRKHeartProgressBackgroundColor:self];
    self.titlecolor = [self.delegate IRKHeartProgressTextColor:self];
    self.trackcolor = [self.delegate IRKHeartProgressTrackerColor:self];
    self.progresscolor = [self.delegate IRKHeartProgressCircleBarColor:self];
    self.track_width = [self.delegate IRKHeartProgressTrackerWidth:self];
    self.progress_linewidth = [self.delegate IRKHeartProgressCircleBarWidth:self];
    self.track_radius = self.radius-self.track_width/2.0;
    self.progress_radius = self.radius-self.progress_linewidth/2.0;
    
    CGFloat bigheight = self.frame.size.height/6.0;
    CGFloat smallheight = bigheight/3.0;
    self.label_mid.frame = CGRectMake(0, self.frame.size.height/2.0-bigheight/2.0, self.frame.size.width, bigheight);
    self.label_bottom.frame = CGRectMake(self.frame.size.width*0.2, self.label_mid.frame.origin.y-bigheight-12, self.frame.size.width*0.6, bigheight);
    self.label_tips.frame = CGRectMake(self.frame.size.width*0.2, CGRectGetMaxY(self.label_bottom.frame) + 2, self.frame.size.width*0.6, smallheight*2.0);
    self.label_mid.textAlignment = NSTextAlignmentCenter;
    self.label_bottom.textAlignment = NSTextAlignmentCenter;
    self.label_tips.textAlignment = NSTextAlignmentCenter;
    self.label_mid.textColor = self.titlecolor;
    self.label_bottom.textColor = self.titlecolor;
    self.label_bottom.adjustsFontSizeToFitWidth = YES;
    self.label_bottom.minimumScaleFactor = 0.5;
    self.label_bottom.numberOfLines = 0;

    self.label_tips.textColor = [UIColor whiteColor];

    self.label_tips.font = [UIFont systemFontOfSize:smallheight*0.9];
    self.label_mid.font = [UIFont systemFontOfSize:bigheight*0.9];


    self.label_tips.text = NSLocalizedString(@"heart_detail_tip", nil);

    
//    UIColor* tmpcolor = self.titlecolor;
    if (self.isShowFloat) {
        self.label_mid.attributedFormatBlock = ^NSAttributedString* (float value)
        {
            if (balance_tag==4) {
                NSDictionary* highlight = @{ NSFontAttributeName: [UIFont systemFontOfSize:45], NSForegroundColorAttributeName:[UIColor colorWithRed:0xfc/255.0 green:0x3c/255.0 blue:0x51/255.0 alpha:1] };
                NSString* prefix;
                if (value == 0) {
                    prefix = @"  0.0";
                }else{
                    prefix = [NSString stringWithFormat:@"  %.1f", value];
                }
                NSMutableAttributedString* prefixAttr = [[NSMutableAttributedString alloc] initWithString: prefix attributes: highlight];
                [prefixAttr appendAttributedString:[[NSAttributedString alloc] initWithString:@"BPM" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:16]}]];
                return prefixAttr;
            }else{
                NSDictionary* highlight = @{ NSFontAttributeName: [UIFont systemFontOfSize:45], NSForegroundColorAttributeName:[UIColor colorWithRed:0x7d/255.0 green:0x94/255.0 blue:0x9a/255.0 alpha:1] };
                NSString* prefix;
                if (value == 0) {
                    prefix = @" 0.0";
                }else{
                    prefix = [NSString stringWithFormat:@" %.1f", value];
                }
                NSMutableAttributedString* prefixAttr = [[NSMutableAttributedString alloc] initWithString: prefix attributes: highlight];
                [prefixAttr appendAttributedString:[[NSAttributedString alloc] initWithString:@"°C" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:16]}]];

                return prefixAttr;
            }
        };
        [self.label_mid countFrom:0 to:self.floatValue withDuration:1];
    }else{
        self.label_mid.attributedFormatBlock = ^NSAttributedString* (float value)
        {
            if (balance_tag==4) {
                NSDictionary* highlight = @{ NSFontAttributeName: [UIFont systemFontOfSize:45], NSForegroundColorAttributeName:[UIColor colorWithRed:0xfc/255.0 green:0x3c/255.0 blue:0x51/255.0 alpha:1] };
                NSString* prefix;
                if (value == 0) {
                    prefix = @"  0";
                }else{
                    prefix = [NSString stringWithFormat:@"  %.2d", (int)value];
                }
                NSMutableAttributedString* prefixAttr = [[NSMutableAttributedString alloc] initWithString: prefix attributes: highlight];
                [prefixAttr appendAttributedString:[[NSAttributedString alloc] initWithString:@"BPM" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:16]}]];
                return prefixAttr;
            }else{
                NSDictionary* highlight = @{ NSFontAttributeName: [UIFont systemFontOfSize:45], NSForegroundColorAttributeName:[UIColor colorWithRed:0x7d/255.0 green:0x94/255.0 blue:0x9a/255.0 alpha:1] };
                NSString* prefix;
                if (value == 0) {
                    prefix = @" 0";
                }else{
                    prefix = [NSString stringWithFormat:@" %.2d", (int)value];
                }
                NSMutableAttributedString* prefixAttr = [[NSMutableAttributedString alloc] initWithString: prefix attributes: highlight];
                return prefixAttr;
            }
        };
        [self.label_mid countFrom:0 to:self.heartvalue withDuration:1];
    }

    SWTextAttachment* imageattach = [[SWTextAttachment alloc] init];
    imageattach.image = [self.delegate IRKHeartProgressHeartImage:self];
    
    NSAttributedString* bottomstring = [NSAttributedString attributedStringWithAttachment:imageattach];
    
    NSMutableAttributedString* strtitle = [[NSMutableAttributedString alloc] initWithAttributedString:bottomstring];
    [strtitle appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [strtitle appendAttributedString:[[NSAttributedString alloc] initWithString:[self.delegate IRKHeartProgressText:self] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:18]}]];
    if (balance_tag==4) {
        self.label_bottom.attributedText = strtitle;
    }else{
        NSMutableAttributedString* Attr = [[NSMutableAttributedString alloc] initWithString: NSLocalizedString(@"Home_text8", nil) attributes: @{NSForegroundColorAttributeName:[UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        self.label_bottom.attributedText = Attr;
    }
    

    [self drawTrack];
    [self resetline];

    [self bringSubviewToFront:self.label_bottom];
}

-(void)drawTrack{
    if (self.trackLayer) {
        [self.trackLayer removeFromSuperlayer];
        self.trackLayer = nil;
    }
    self.trackLayer = [CAShapeLayer layer];
//    self.trackLayer.frame = self.bounds;
//    UIBezierPath* path = [[UIBezierPath alloc] init];
//    [path addArcWithCenter:self.center_point radius:self.track_radius startAngle:0 endAngle:2*M_PI clockwise:YES];
//    self.trackLayer.path = path.CGPath;
//    self.trackLayer.strokeColor = self.trackcolor.CGColor;
//    self.trackLayer.lineWidth = self.track_width;
//    self.trackLayer.fillColor = nil;
//    [self.layer addSublayer:self.trackLayer];
    
    self.trackLayer.frame = self.bounds;
    UIBezierPath* path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:self.center_point radius:self.track_radius startAngle:M_PI*2/3 endAngle:M_PI*2/3+M_PI*5/3 clockwise:YES];
    self.trackLayer.path = path.CGPath;
    self.trackLayer.lineWidth = self.track_width;
    self.trackLayer.fillColor = [UIColor clearColor].CGColor;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(IRKSportProgressBoardColor:)]) self.trackLayer.strokeColor = [self.delegate IRKSportProgressBoardColor:self].CGColor;
//    else self.trackLayer.strokeColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1].CGColor;
    self.trackLayer.strokeColor = self.trackcolor.CGColor;
    [self.layer addSublayer:self.trackLayer];

}
-(void)resetline{
//    if (self.path) {
//        self.path = nil;
//    }
    
//    if (self.progressLayer) {
//        [self.progressLayer removeFromSuperlayer];
//        self.progressLayer = nil;
//    }
    
//    self.progressLayer = [CAShapeLayer layer];
//    self.path = [[UIBezierPath alloc] init];
//    self.progressLayer.path = self.path.CGPath;
//    self.progressLayer.strokeColor = self.progresscolor.CGColor;
//    self.progressLayer.lineWidth = self.progress_linewidth;
//    self.progressLayer.fillColor = nil;
//    self.progressLayer.lineCap = kCALineCapRound;
//    
//    [self.layer addSublayer:self.progressLayer];
    [self.progresslayers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CAShapeLayer* layer = (CAShapeLayer*)obj;
        [layer removeFromSuperlayer];
    }];
    [self.progresslayers removeAllObjects];
    
    self.current_angel = M_PI*2/3;
    self.dot_view.backgroundColor = self.progresscolor;
    self.dot_view.center = [self pointForTrapezoidWithAngle:self.current_angel andRadius:self.track_radius forCenter:self.center_point];
    [self bringSubviewToFront:self.dot_view];
    self.dot_view.hidden = NO;

}


-(void)drawProgress{
//    NSLog(@"self.current_angel=%f",self.current_angel);
    if (self.current_angel+self.angel_pos>M_PI*2/3+M_PI*5/3) {
        [self resetline];
    }
    UIBezierPath* path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:self.center_point radius:self.progress_radius startAngle:self.current_angel endAngle:self.current_angel+self.angel_pos clockwise:YES];
    CAShapeLayer* layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.strokeColor = self.progresscolor.CGColor;
    layer.lineWidth = self.progress_linewidth;
    layer.fillColor = nil;
    layer.lineCap = kCALineCapRound;
    [self.layer addSublayer:layer];
    [self.progresslayers addObject:layer];
//    self.progressLayer.path = path.CGPath;
//    self.progressLayer.strokeColor = self.progresscolor.CGColor;
//    self.progressLayer.lineWidth = self.progress_linewidth;
//    self.progressLayer.fillColor = nil;
//    self.progressLayer.lineCap = kCALineCapRound;
    self.current_angel += self.angel_pos;
    
    self.dot_view.center = [self pointForTrapezoidWithAngle:self.current_angel andRadius:self.progress_radius forCenter:self.center_point];

    
//    self.label_bottom.alpha = (self.alpha%100)/100.0;
//    self.alpha += 5;
}

-(void)startAnimation{
    if (self.link) {
        [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.link = nil;
    }
    [self resetline];
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawProgress)];
    self.link.frameInterval = 2 ;
    self.alpha = 100;
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

}

-(void)stopAnimation{
    if (self.link) {
        [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.link = nil;
    }
    [self resetline];
    self.label_bottom.alpha = 1;
}

-(void)setHeartValue:(NSInteger)heart{
    NSInteger last = self.heartvalue;
    self.heartvalue = heart;
    [self.label_mid countFrom:last to:self.heartvalue withDuration:1];
}

-(void)setTempValue:(CGFloat)value{
    CGFloat last = self.floatValue;
    self.floatValue = value;
    [self.label_mid countFrom:last to:self.floatValue withDuration:1];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}


-(CGPoint) pointForTrapezoidWithAngle:(float)a andRadius:(float)r  forCenter:(CGPoint)p{
    return CGPointMake(p.x + r*cos(a), p.y + r*sin(a));
}

@end
