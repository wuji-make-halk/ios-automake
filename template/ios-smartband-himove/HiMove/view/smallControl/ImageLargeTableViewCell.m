//
//  ImageLargeTableViewCell.m
//  SXRBand
//
//  Created by qf on 16/3/22.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "ImageLargeTableViewCell.h"

@implementation ImageLargeTableViewCell

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
    
    self.imageView.frame =CGRectMake(CGRectGetHeight(self.frame)*0.1,CGRectGetHeight(self.frame)*0.1,CGRectGetHeight(self.frame)*0.8,CGRectGetHeight(self.frame)*0.8);
    
    self.imageView.contentMode =UIViewContentModeScaleAspectFit;
    
    
    
    CGRect tmpFrame = self.textLabel.frame;
    
    tmpFrame.origin.x = CGRectGetHeight(self.frame)+5;
    tmpFrame.size.width += 20;
    
    self.textLabel.frame = tmpFrame;
    self.textLabel.numberOfLines = 0;
    
    
    
    tmpFrame = self.detailTextLabel.frame;
    
    tmpFrame.origin.x = CGRectGetHeight(self.frame)+5;
    
    self.detailTextLabel.frame = tmpFrame;
    
}

@end
