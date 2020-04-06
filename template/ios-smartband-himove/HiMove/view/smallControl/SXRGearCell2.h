//
//  SXRGearCell2.h
//  Walknote
//
//  Created by qf on 15/12/14.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SXRGearCell2;
@protocol SXRGearCell2Delegate <NSObject>
@required
-(NSString*)getDeviceName:(SXRGearCell2*)cell;
-(NSString*)getDeviceId:(SXRGearCell2*)cell;
-(void)didStartCall:(SXRGearCell2*)cell;
-(void)didStopCall:(SXRGearCell2*)cell;
-(void)didStartSync:(SXRGearCell2*)cell;
-(void)didClickConnectImage:(SXRGearCell2*)cell;
-(BOOL)getCallBtnEnable:(SXRGearCell2*)cell;
-(int)getSelfType:(SXRGearCell2*)cell;
-(int)getRssi:(SXRGearCell2*)cell;


@end

@interface SXRGearCell2 : UITableViewCell

@property (assign, nonatomic) int selfType;
@property (weak, nonatomic) id<SXRGearCell2Delegate> delegate;
@property (assign, nonatomic) BOOL iscalling;
@property (strong, nonatomic) UILabel *device_name;
@property (strong, nonatomic) UILabel *device_id;
@property (strong, nonatomic) UIImageView *image_calldevice;
@property (strong, nonatomic) UIImageView *image_sep;
@property (strong, nonatomic) UIImageView *image_connect;
@property (strong, nonatomic) UIButton *btn_connect;
@property (strong, nonatomic) UIImageView *image_sep1;
@property (strong, nonatomic) UIImageView *image_sync;
@property (strong, nonatomic) UIImageView *image_signal;
@property (strong, nonatomic) UILabel *label_rssi;

-(void)reload;
@end
