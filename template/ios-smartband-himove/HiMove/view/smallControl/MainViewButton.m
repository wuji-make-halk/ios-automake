//
//  MainViewButton.m
//  HiMove
//
//  Created by qf on 2017/6/15.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "MainViewButton.h"

@implementation MainViewButton


- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imageW = CGRectGetWidth(contentRect)*0.2;
    CGFloat imageH = CGRectGetHeight(contentRect)*0.5;
    return CGRectMake(CGRectGetWidth(contentRect)*0.1, CGRectGetHeight(contentRect)*0.25, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
//    CGFloat titleY = (contentRect.size.height-8) *0.6 + 4;
//    CGFloat titleW = contentRect.size.width;
//    CGFloat titleH = contentRect.size.height - titleY - 4;
    return CGRectMake(CGRectGetWidth(contentRect)*0.3,
                      CGRectGetHeight(contentRect)*0.1,
                      CGRectGetWidth(contentRect)*0.7,
                      CGRectGetHeight(contentRect)*0.8);
}


@end
