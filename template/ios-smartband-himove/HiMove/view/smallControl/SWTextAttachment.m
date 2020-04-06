//
//  SWTextAttachment.m
//  SXRBand
//
//  Created by qf on 15/11/18.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import "SWTextAttachment.h"

@implementation SWTextAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGFloat width = lineFrag.size.width;
    CGFloat height = lineFrag.size.width;
    // Scale how you want
    float scalingFactor = 0.5;
    CGSize imageSize = [self.image size];
    float imgscal = imageSize.width/imageSize.height;
//    float imgw  = imageSize.width;
//    float imgh  = imageSize.height;
//    if (width < imageSize.width)
//        if (height< imageSize.height) {
//            
//        }
//        scalingFactor = width / imageSize.width;
    
    CGRect rect = CGRectMake(0, -lineFrag.size.height*0.15, lineFrag.size.height*imgscal, lineFrag.size.height);
    
    return rect;
}


@end
