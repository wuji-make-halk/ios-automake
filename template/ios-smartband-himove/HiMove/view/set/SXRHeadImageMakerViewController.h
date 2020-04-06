//
//  SXRHeadImageMakerViewController.h
//  SXRBand
//
//  Created by qf on 14-11-26.
//  Copyright (c) 2014年 SXR. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SXRHeadImageMakerViewController;

@protocol SXRHeadImageMakerDelegate <NSObject>

- (void)imageCropper:(SXRHeadImageMakerViewController *)cropperViewController didFinished:(UIImage *)editedImage;
- (void)imageCropperDidCancel:(SXRHeadImageMakerViewController *)cropperViewController;

@end


@interface SXRHeadImageMakerViewController : UIViewController
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) id<SXRHeadImageMakerDelegate> delegate;
@property (nonatomic, assign) CGRect cropFrame;

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

@end
