//
//  SXRGearCell2.m
//  Walknote
//
//  Created by qf on 15/12/14.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import "SXRGearCell2.h"

@implementation SXRGearCell2

- (void)awakeFromNib
{
    // Initialization code
    self.image_connect.tag = 1;
    UITapGestureRecognizer* tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick:)];
    tap2.numberOfTapsRequired = 1;
    self.image_connect.userInteractionEnabled = YES;
    [self.image_connect addGestureRecognizer:tap2];
    
    self.label_rssi.font = [UIFont systemFontOfSize:10];
    self.label_rssi.textAlignment = NSTextAlignmentCenter;
    
    self.image_signal.contentMode = UIViewContentModeScaleAspectFit;
    [super awakeFromNib];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.image_signal = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.frame)*0.7, CGRectGetHeight(self.frame)*0.7)];
    self.image_signal.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.image_signal];
    
    self.label_rssi = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.image_signal.frame), CGRectGetWidth(self.image_signal.frame), CGRectGetHeight(self.frame)*0.3)];
    self.label_rssi.textAlignment = NSTextAlignmentCenter;
    self.label_rssi.adjustsFontSizeToFitWidth = YES;
    self.label_rssi.minimumScaleFactor = 0.5;
    self.label_rssi.font = [UIFont systemFontOfSize:10];
    self.label_rssi.textColor = [UIColor blackColor];
    [self addSubview:self.label_rssi];
    
    CGFloat xoffset = 20;
    CGFloat btnsize = CGRectGetHeight(self.frame);
//    CGFloat yoffset = btnsize*0.2;
//    CGFloat imageoffset = 7.5;

    self.btn_connect = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-xoffset-btnsize, 0, btnsize, btnsize)];
    self.btn_connect.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.btn_connect addTarget:self action:@selector(onClickconnect:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btn_connect];
    
    
//    self.image_sep1 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.btn_connect.frame)-0.5, yoffset, 1, btnsize-yoffset*2.0)];
//    self.image_sep1.backgroundColor = [UIColor lightGrayColor];
//    [self addSubview:self.image_sep1];
    
//    self.image_calldevice = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.btn_connect.frame)-btnsize-imageoffset, imageoffset, btnsize-imageoffset*2.0, btnsize-imageoffset*2.0)];
//    self.image_calldevice.contentMode = UIViewContentModeScaleAspectFit;
//    [self addSubview:self.image_calldevice];
    CGFloat textwidth = CGRectGetMinX(self.btn_connect.frame) -CGRectGetMaxX(self.image_signal.frame) -10;
    CGFloat text1height = CGRectGetHeight(self.frame)*0.7;
    CGFloat text2height = CGRectGetHeight(self.frame)*0.3;
    self.device_name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.image_signal.frame)+5, 0, textwidth, text1height)];
    self.device_name.textAlignment = NSTextAlignmentLeft;
    self.device_name.adjustsFontSizeToFitWidth = YES;
    self.device_name.minimumScaleFactor = 0.5;
    self.device_name.font = [UIFont boldSystemFontOfSize:17];
    self.device_name.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
    
    [self addSubview:self.device_name];
    
    self.device_id= [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.image_signal.frame)+5, CGRectGetMaxY(self.device_name.frame), textwidth, text2height)];
    self.device_id.textAlignment = NSTextAlignmentLeft;
    self.device_id.adjustsFontSizeToFitWidth = YES;
    self.device_id.minimumScaleFactor = 0.5;
    self.device_id.textColor = [UIColor colorWithRed:0xCC/255.0 green:0xCC/255.0 blue:0xCC/255.0 alpha:1.0];
    
    self.device_id.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.device_id];
   
    
    
    
    return self;
    
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    CGFloat xoffset = 20;
    CGFloat btnsize = CGRectGetHeight(self.frame);
//    CGFloat yoffset = btnsize*0.2;
//    CGFloat imageoffset = 7.5;
    
    self.btn_connect.frame = CGRectMake(CGRectGetWidth(self.frame)-xoffset-btnsize, 0, btnsize, btnsize);
    CGFloat textwidth = CGRectGetMinX(self.btn_connect.frame) -CGRectGetMaxX(self.image_signal.frame) -10;
    CGFloat text1height = CGRectGetHeight(self.frame)*0.7;
    CGFloat text2height = CGRectGetHeight(self.frame)*0.3;
    self.device_name.frame = CGRectMake(CGRectGetMaxX(self.image_signal.frame)+5, 0, textwidth, text1height);
    
    self.device_id.frame = CGRectMake(CGRectGetMaxX(self.image_signal.frame)+5, CGRectGetMaxY(self.device_name.frame), textwidth, text2height);
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}
-(void)reload{
    
    self.selfType = [self.delegate getSelfType:self];
    
    self.device_name.text = [self.delegate getDeviceName:self];
    self.device_id.text = [self.delegate getDeviceId:self];
    int rssi = [self.delegate getRssi:self];
    self.label_rssi.text = [NSString stringWithFormat:@"%d",rssi];
    

    if (rssi > RSSI_LEVEL4) {
        [self.image_signal setImage:[UIImage imageNamed:@"icon_signal4.png"]];
    }else if(rssi> RSSI_LEVEL3){
        [self.image_signal setImage:[UIImage imageNamed:@"icon_signal3.png"]];
    }else if(rssi> RSSI_LEVEL2){
        [self.image_signal setImage:[UIImage imageNamed:@"icon_signal2.png"]];
    }else if(rssi> RSSI_LEVEL1){
        [self.image_signal setImage:[UIImage imageNamed:@"icon_signal1.png"]];
    }else{
        [self.image_signal setImage:[UIImage imageNamed:@"icon_signal0.png"]];
        
    }
    [self.btn_connect setImageEdgeInsets:UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5)];
    
    
    if (self.selfType == 1) {
        //connected
        BOOL enable = [self.delegate getCallBtnEnable:self];
        if (enable) {
            self.image_sync.image = [UIImage imageNamed:@"icon_sync_band.png"];
            self.image_calldevice.image = [UIImage imageNamed:@"searchband.png"];

        }else{
            self.image_calldevice.image = [UIImage imageNamed:@"searchband_disable.png"];
            self.image_sync.image = [UIImage imageNamed:@"icon_sync_band_disable.png"];

        }


        [self.btn_connect setImage:[UIImage imageNamed:@"icon_yft_disconnect.png"] forState:UIControlStateNormal];
//        [self.btn_connect setImage:[UIImage imageNamed:@"icon_yft_disconnect_highlight.png"] forState:UIControlStateHighlighted];
        self.image_sync.hidden = YES;
        self.image_calldevice.hidden = NO;
        
        //        self.image_sep.image = [UIImage imageNamed:@"line_gender_seperator.png"];
        self.image_sep.hidden = NO;
        //        self.image_sep1.image = [UIImage imageNamed:@"line_gender_seperator.png"];
        self.image_sep1.hidden = YES;
        
        //        self.image_connect.image = [UIImage imageNamed:@"ble_device_disconnected.png"];
        //        self.image_connect.hidden = NO;
    }else{
        //wait to connected
        self.image_calldevice.hidden = YES;
        self.image_sync.image = [UIImage imageNamed:@"icon_sync_band.png"];
        self.image_calldevice.image = [UIImage imageNamed:@"searchband.png"];

        [self.btn_connect setImage:[UIImage imageNamed:@"icon_yft_connect.png"] forState:UIControlStateNormal];
//        [self.btn_connect setImage:[UIImage imageNamed:@"icon_yft_connect_highlight.png"] forState:UIControlStateHighlighted];

        self.image_sync.hidden = YES;
        
        //        self.image_sep.image = [UIImage imageNamed:@"line_gender_seperator.png"];
        self.image_sep.hidden = YES;
        //        self.image_sep1.image = [UIImage imageNamed:@"line_gender_seperator.png"];
        self.image_sep1.hidden = YES;
        
        //        self.image_connect.image = [UIImage imageNamed:@"ble_device_connected.png"];
        //        self.image_connect.hidden = NO;
        
    }
    
    
}

-(void)onClick:(UITapGestureRecognizer*)ges{
    switch (ges.view.tag) {
        case 0:
            if ([self.delegate getCallBtnEnable:self] == NO) {
                break;
            }
            if (self.iscalling) {
                [self.image_calldevice stopAnimating];
                [self.delegate didStopCall:self];
            }
            else{
                [self.image_calldevice startAnimating];
                [self.delegate didStartCall:self];
            }
            self.iscalling = !self.iscalling;
            
            break;
        case 1:
            [self.delegate didClickConnectImage:self];
            break;
        case 2:
            if ([self.delegate getCallBtnEnable:self] == NO) {
                break;
            }
            [self.delegate didStartSync:self];
            break;
            
        default:
            break;
    }
}
- (void)onClickconnect:(UIButton *)sender {
    [self.delegate didClickConnectImage:self];
}

@end
