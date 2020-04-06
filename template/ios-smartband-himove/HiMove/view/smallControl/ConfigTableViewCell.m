//
//  ConfigTableViewCell.m
//  HiMove
//
//  Created by qf on 2017/6/1.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "ConfigTableViewCell.h"

@implementation ConfigTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    //    self.imageView.bounds =CGRectMake(0,0,30,30);
    
    self.imageView.frame =CGRectMake(CGRectGetHeight(self.frame)*0.2,CGRectGetHeight(self.frame)*0.25,CGRectGetHeight(self.frame)*0.5,CGRectGetHeight(self.frame)*0.5);
    
    self.imageView.contentMode =UIViewContentModeScaleAspectFit;
    
    
    
    CGRect tmpFrame = self.textLabel.frame;
    
    tmpFrame.origin.x = CGRectGetMaxX(self.imageView.frame)+5;
    tmpFrame.size.width += 20;
    
    self.textLabel.frame = tmpFrame;
    self.textLabel.numberOfLines = 0;
    
    
    
//    tmpFrame = self.detailTextLabel.frame;
//    
//    tmpFrame.origin.x = CGRectGetHeight(self.frame)+5;
//    
//    self.detailTextLabel.frame = tmpFrame;
    
}


@end
