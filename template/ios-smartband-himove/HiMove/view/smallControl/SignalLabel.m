//
//  SignalLabel.m
//  SXRBand
//
//  Created by qf on 14-12-15.
//  Copyright (c) 2014年 SXR. All rights reserved.
//

#import "SignalLabel.h"

@implementation SignalLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.commondata = [IRKCommonData SharedInstance];
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/2.0, self.frame.size.height)];
        self.image.contentMode = UIViewContentModeScaleAspectFit;

    self.signal_images = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"icon_pz_signal0.png"], [UIImage imageNamed:@"icon_pz_signal1.png"], [UIImage imageNamed:@"icon_pz_signal2.png"], [UIImage imageNamed:@"icon_pz_signal3.png"], [UIImage imageNamed:@"icon_pz_signal4.png"], nil];
        self.image.image = [self.signal_images objectAtIndex:0];
        [self addSubview:self.image];
        
        self.rssi_label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2.0, 0, self.frame.size.width/2.0, self.frame.size.height)];
        self.rssi_label.textAlignment = NSTextAlignmentLeft;
        self.rssi_label.textColor = self.commondata.colorSingalText;
        self.rssi_label.adjustsFontSizeToFitWidth = YES;
        self.rssi_label.minimumScaleFactor = 0.5;
        self.rssi_label.font = [UIFont systemFontOfSize:self.frame.size.height*0.8];
        [self addSubview:self.rssi_label];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:notify_key_did_update_rssi object:nil];
    }
    return self;
}

-(void)dealloc{
    NSLog(@"signalLabel dealloc");
}

-(void)start{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:notify_key_did_update_rssi object:nil];
}

-(void)stop{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)reload:(NSNotification*)notify{
    if (notify == nil || notify.userInfo == nil) {
        [self.image setImage:[self.signal_images objectAtIndex:0]];
        self.rssi_label.text = @"0";
        return;
    }
    NSDictionary* userinfo = notify.userInfo;
    NSNumber* RSSI = [userinfo objectForKey:@"RSSI"];
    if (RSSI) {
        int rssiint = RSSI.intValue;
        self.rssi_label.text = [NSString stringWithFormat:@"%d",rssiint];
        if (rssiint > RSSI_LEVEL4) {
            [self.image setImage:[self.signal_images objectAtIndex:4]];
        }else if(rssiint> RSSI_LEVEL3){
            [self.image setImage:[self.signal_images objectAtIndex:3]];
        }else if(rssiint> RSSI_LEVEL2){
            [self.image setImage:[self.signal_images objectAtIndex:2]];
        }else if(rssiint> RSSI_LEVEL1){
            [self.image setImage:[self.signal_images objectAtIndex:1]];
        }else{
            [self.image setImage:[self.signal_images objectAtIndex:0]];
            
        }

    }else{
        [self.image setImage:[self.signal_images objectAtIndex:0]];
        self.rssi_label.text = @"0";

    }
}
@end
