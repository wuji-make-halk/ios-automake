//
//  HMTabbarButton.m
//  CZJKBand
//
//  Created by 周凯伦 on 17/3/15.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "HMTabbarButton.h"

@implementation HMTabbarButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imageW = contentRect.size.width;
    CGFloat imageH = (contentRect.size.height-8) * 0.6;
    return CGRectMake(0, 2, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat titleY = (contentRect.size.height-8) *0.6 + 4;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height - titleY - 4;
    return CGRectMake(0, titleY, titleW, titleH);
}

@end
