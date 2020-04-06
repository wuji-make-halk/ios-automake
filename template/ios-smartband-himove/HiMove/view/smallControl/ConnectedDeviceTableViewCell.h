//
//  ConnectedDeviceTableViewCell.h
//  HiMove
//
//  Created by qf on 2017/6/1.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ConnectedDeviceTableViewCell;
@protocol ConnectedDeviceDelegate <NSObject>
@required
-(NSString*)ConnectedDeviceTableViewCellGetDeviceName:(ConnectedDeviceTableViewCell*)cell;
-(NSString*)ConnectedDeviceTableViewCellGetDeviceId:(ConnectedDeviceTableViewCell*)cell;
-(void)ConnectedDeviceTableViewCellDidStartCall:(ConnectedDeviceTableViewCell*)cell;
-(void)ConnectedDeviceTableViewCellDidStopCall:(ConnectedDeviceTableViewCell*)cell;
-(void)ConnectedDeviceTableViewCellDisconnect:(ConnectedDeviceTableViewCell*)cell;
-(BOOL)ConnectedDeviceTableViewCellGetCallBtnEnable:(ConnectedDeviceTableViewCell*)cell;
@end

@interface ConnectedDeviceTableViewCell : UITableViewCell
@property (weak, nonatomic) id<ConnectedDeviceDelegate> delegate;
@property (assign, nonatomic) BOOL iscalling;
@property (strong, nonatomic) UILabel *device_name;
@property (strong, nonatomic) UILabel *device_id;
@property (strong, nonatomic) UIButton *btn_calldevice;
@property (strong, nonatomic) UIButton *btn_connect;
-(void)reload;
@end
