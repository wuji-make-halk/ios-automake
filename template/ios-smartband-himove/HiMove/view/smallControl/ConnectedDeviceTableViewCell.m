//
//  ConnectedDeviceTableViewCell.m
//  HiMove
//
//  Created by qf on 2017/6/1.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "ConnectedDeviceTableViewCell.h"

@implementation ConnectedDeviceTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    CGFloat xoffset = 20;
    CGFloat btnsize = CGRectGetHeight(self.frame)-15;
    //    CGFloat yoffset = btnsize*0.2;
    //    CGFloat imageoffset = 7.5;
    NSLog(@"cell frame = %@",NSStringFromCGRect(self.frame));
    
    
    //    self.image_sep1 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.btn_connect.frame)-0.5, yoffset, 1, btnsize-yoffset*2.0)];
    //    self.image_sep1.backgroundColor = [UIColor lightGrayColor];
    //    [self addSubview:self.image_sep1];
    
    //    self.image_calldevice = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.btn_connect.frame)-btnsize-imageoffset, imageoffset, btnsize-imageoffset*2.0, btnsize-imageoffset*2.0)];
    //    self.image_calldevice.contentMode = UIViewContentModeScaleAspectFit;
    //    [self addSubview:self.image_calldevice];
    CGFloat textwidth = CGRectGetWidth(self.frame) -10 - btnsize*2 - 30;
    CGFloat text1height = CGRectGetHeight(self.frame)*0.7;
    CGFloat text2height = CGRectGetHeight(self.frame)*0.3;
    self.device_name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textwidth, text1height)];
    self.device_name.textAlignment = NSTextAlignmentLeft;
    self.device_name.adjustsFontSizeToFitWidth = YES;
    self.device_name.minimumScaleFactor = 0.5;
    self.device_name.font = [UIFont boldSystemFontOfSize:17];
    self.device_name.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
    
    [self addSubview:self.device_name];
    [self.device_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(textwidth, text1height));
        make.top.mas_equalTo(@0);
        make.left.mas_equalTo(@10);
    }];

    
    self.device_id= [[UILabel alloc] initWithFrame:CGRectMake(0,0, textwidth, text2height)];
    self.device_id.textAlignment = NSTextAlignmentLeft;
    self.device_id.adjustsFontSizeToFitWidth = YES;
    self.device_id.minimumScaleFactor = 0.5;
    self.device_id.textColor = [UIColor colorWithRed:0xCC/255.0 green:0xCC/255.0 blue:0xCC/255.0 alpha:1.0];
    
    self.device_id.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.device_id];
    
    [self.device_id mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(textwidth, text2height));
        make.top.mas_equalTo(self.device_name.mas_bottom);
        make.left.mas_equalTo(@10);
    }];
    
    
    self.btn_calldevice = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnsize, btnsize)];
    self.btn_calldevice.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.btn_calldevice addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn_calldevice setImage:[UIImage imageNamed:@"searchband.png"] forState:UIControlStateNormal];
    [self.btn_calldevice setImage:[UIImage imageNamed:@"searchband_disable.png"] forState:UIControlStateDisabled];
    [self addSubview:self.btn_calldevice];
    [self.btn_calldevice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(btnsize, btnsize));
        make.top.mas_equalTo(@7.5);
        make.left.mas_equalTo(self.device_name.mas_right).with.offset(15);
    }];
    
    self.btn_connect = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-xoffset-btnsize, 0, btnsize, btnsize)];
    self.btn_connect.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.btn_connect setImage:[UIImage imageNamed:@"icon_yft_disconnect.png"] forState:UIControlStateNormal];
    [self.btn_connect addTarget:self action:@selector(onClickconnect:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btn_connect];
    [self.btn_connect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(btnsize, btnsize));
        make.top.mas_equalTo(@7.5);
        make.left.mas_equalTo(self.btn_calldevice.mas_right).with.offset(15);
    }];

    
    return self;
    
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
//    CGFloat xoffset = 20;
    CGFloat btnsize = CGRectGetHeight(self.frame)-15;
    CGFloat textwidth = CGRectGetWidth(self.frame) -10 - btnsize*2 - 30;
    CGFloat text1height = CGRectGetHeight(self.frame)*0.7;
    CGFloat text2height = CGRectGetHeight(self.frame)*0.3;
    self.device_name.frame = CGRectMake(10, 0, textwidth, text1height);
    self.device_id.frame = CGRectMake(10, text1height, textwidth, text2height);
    self.btn_calldevice.frame = CGRectMake(textwidth+15, 7.5, btnsize, btnsize);
    self.btn_connect.frame = CGRectMake(textwidth+22.5+btnsize, 7.5, btnsize, btnsize);
    
//    [self.device_name mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(textwidth, text1height));
//        make.top.mas_equalTo(@0);
//        make.left.mas_equalTo(@10);
//    }];
//    [self.device_id mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(textwidth, text2height));
//        make.top.mas_equalTo(self.device_name.mas_bottom);
//        make.left.mas_equalTo(@20);
//    }];
//    [self.btn_calldevice mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(btnsize, btnsize));
//        make.top.mas_equalTo(@7.5);
//        make.left.mas_equalTo(self.device_name.mas_right).with.offset(15);
//    }];
//    [self.btn_connect mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(btnsize, btnsize));
//        make.top.mas_equalTo(@7.5);
//        make.left.mas_equalTo(self.btn_calldevice.mas_right).with.offset(15);
//    }];
//    //    CGFloat yoffset = btnsize*0.2;
//    //    CGFloat imageoffset = 7.5;
//    
//    self.btn_connect.frame = CGRectMake(CGRectGetWidth(self.frame)-xoffset-btnsize, 0, btnsize, btnsize);
//    CGFloat textwidth = CGRectGetMinX(self.btn_calldevice.frame) -20;
//    CGFloat text1height = CGRectGetHeight(self.frame)*0.7;
//    CGFloat text2height = CGRectGetHeight(self.frame)*0.3;
//    self.device_name.frame = CGRectMake(CGRectGetMaxX(self.image_signal.frame)+5, 0, textwidth, text1height);
//    
//    self.device_id.frame = CGRectMake(CGRectGetMaxX(self.image_signal.frame)+5, CGRectGetMaxY(self.device_name.frame), textwidth, text2height);
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}
-(void)reload{
    
    
    self.device_name.text = [self.delegate ConnectedDeviceTableViewCellGetDeviceName:self];
    self.device_id.text = [self.delegate ConnectedDeviceTableViewCellGetDeviceId:self];

    
//    [self.btn_connect setImageEdgeInsets:UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5)];
    
    self.btn_calldevice.imageView.animationImages = @[[UIImage imageNamed:@"searchband.png"],[UIImage imageNamed:@"searchband1.png"],[UIImage imageNamed:@"searchband2.png"],[UIImage imageNamed:@"searchband3.png"]];
    self.btn_calldevice.imageView.animationDuration = 2;
    BOOL enable = [self.delegate ConnectedDeviceTableViewCellGetCallBtnEnable:self];
    if (enable) {
        [self.btn_calldevice setEnabled:YES];
        
    }else{
        [self.btn_calldevice setEnabled:NO];
    }
}

-(void)onClick:(UIButton*)sender{
    if (self.iscalling) {
        self.iscalling = NO;
        [self.btn_calldevice.imageView stopAnimating];
        if (self.delegate && [self.delegate respondsToSelector:@selector(ConnectedDeviceTableViewCellDidStopCall:)]) {
            [[self delegate] ConnectedDeviceTableViewCellDidStopCall:self];
        }

    }else{
        self.iscalling = YES;
        [self.btn_calldevice.imageView startAnimating];
        if (self.delegate && [self.delegate respondsToSelector:@selector(ConnectedDeviceTableViewCellDidStartCall:)]) {
            [[self delegate] ConnectedDeviceTableViewCellDidStartCall:self];
        }

    }
    [self setNeedsLayout];
}
- (void)onClickconnect:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ConnectedDeviceTableViewCellDisconnect:)]) {
        [[self delegate] ConnectedDeviceTableViewCellDisconnect:self];
    }
}

@end
