//
//  IRKProgressBar.m
//  JSDBong
//
//  Created by qf on 14-6-25.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "IRKProgressBar.h"

@implementation IRKProgressBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.conerRadius = 3;
        self.progressoffset = 3;
        self.boarderLineWidth = 0.5;
        self.animationtime = 0.5;
        self.boardColor = [UIColor lightGrayColor];
        self.fillColor = [UIColor whiteColor];
        self.progressColor = [UIColor grayColor];
//        CGRect f = CGRectInset(frame, -1, -1);
        self.progressbar = [[UIView alloc] initWithFrame: CGRectMake(self.progressoffset, self.progressoffset, 0, frame.size.height-self.progressoffset*2)];
        self.progressbar.layer.cornerRadius = self.conerRadius;
        self.progressbar.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.progressbar];
    }
    return self;
}
-(void)reload{
    self.progressbar.frame = CGRectMake(self.progressoffset, self.progressoffset, 0, self.progressbar.frame.size.height);
    [self drawBoarder];
}

-(void) drawBoarder{
    self.layer.borderWidth = self.boarderLineWidth;
    self.layer.cornerRadius = self.conerRadius;
    self.layer.borderColor = self.boardColor.CGColor;
    self.layer.backgroundColor = self.fillColor.CGColor;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setProgress:(CGFloat)progress animated:(BOOL)animated{
    if (animated) {
        [UIView animateWithDuration:self.animationtime animations:^{
            self.progressbar.frame = CGRectMake(self.progressoffset, self.progressoffset, progress*(self.frame.size.width-2*self.progressoffset), self.frame.size.height-self.progressoffset*2);
            self.progressbar.backgroundColor = [self.delegate getBarColor:self withProgress:progress];
        }];
    }
    
}

-(UIColor*) getbackgroudcolor:(CGFloat)progress{
    if (progress > 0.8) {
        return [UIColor greenColor];
    }else if (progress>0.5) {
        return [UIColor yellowColor];
    }else if (progress >0.3){
        return [UIColor orangeColor];
    }else {
        return [UIColor redColor];
    }
}
@end
