//
//  HeadImageTableViewCell.m
//  HiMove
//
//  Created by qf on 2017/6/1.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "HeadImageTableViewCell.h"

@implementation HeadImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    //    self.imageView.bounds =CGRectMake(0,0,30,30);
    
    self.imageView.frame =CGRectMake(CGRectGetWidth(self.frame)*0.05,CGRectGetHeight(self.frame)*0.2,CGRectGetHeight(self.frame)*0.6,CGRectGetHeight(self.frame)*0.6);
    
    self.imageView.contentMode =UIViewContentModeScaleAspectFit;
    self.imageView.layer.cornerRadius = CGRectGetHeight(self.frame)*0.6*0.5;
    self.imageView.clipsToBounds = YES;
    
    
    CGRect tmpFrame = self.textLabel.frame;
    
    tmpFrame.origin.x = CGRectGetMaxX(self.imageView.frame)+5;
    tmpFrame.size.width = CGRectGetWidth(self.frame)-tmpFrame.origin.x - 20;
    
    self.textLabel.frame = tmpFrame;
    self.textLabel.numberOfLines = 0;
    
    
    
    //    tmpFrame = self.detailTextLabel.frame;
    //
    //    tmpFrame.origin.x = CGRectGetHeight(self.frame)+5;
    //
    //    self.detailTextLabel.frame = tmpFrame;
    
}


@end
