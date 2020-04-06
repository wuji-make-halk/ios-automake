//
//  SignalLabel.h
//  SXRBand
//
//  Created by qf on 14-12-15.
//  Copyright (c) 2014年 SXR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignalLabel : UIView
@property (strong, nonatomic)IRKCommonData* commondata;
@property (strong, nonatomic)UIImageView* image;
@property (strong, nonatomic)NSArray* signal_images;
@property (strong, nonatomic)UILabel* rssi_label;
-(void)start;
-(void)stop;

@end
