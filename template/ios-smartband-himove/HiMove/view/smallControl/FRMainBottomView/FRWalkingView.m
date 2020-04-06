//
//  FRWalkingView.m
//  CZJKBand
//
//  Created by 刘增述 on 16/9/9.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "FRWalkingView.h"
#import "BleControl.h"

@interface FRWalkingView ()
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIView *sunView;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *calBurned;
@property (weak, nonatomic) IBOutlet UIButton *syncBtn;

@property (strong, nonatomic) BleControl* blecontrol;


@end
@implementation FRWalkingView


+ (instancetype)WalkingView
{
    //从xib中加载subview
    NSBundle *bundle = [NSBundle mainBundle];
    //加载xib中得view
    FRWalkingView *subView = [[bundle loadNibNamed:@"FRWalkingView" owner:nil options:nil] lastObject];
//    subView.syncBtn.hidden = YES;
    [subView.syncBtn setTitle:NSLocalizedString(@"BottomView_sync_data", nil) forState:UIControlStateNormal];
    subView.syncBtn.layer.masksToBounds = YES;
    subView.syncBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    subView.syncBtn.layer.borderWidth = 1.0;
    subView.syncBtn.layer.cornerRadius=10;
    subView.syncBtn.clipsToBounds=YES;
    
    return subView;
}

-(void)awakeFromNib{
    
    [super awakeFromNib];
    self.backgroundColor  = [UIColor clearColor];
    self.sunView.backgroundColor = [UIColor clearColor];
    self.sunView.layer.masksToBounds = YES;
    self.sunView.layer.borderColor   = [UIColor whiteColor].CGColor;
    self.sunView.layer.borderWidth = 1;
    
}

-(void)setWalkingModel:(FRWalkingDetailModel *)walkingModel
{
    _walkingModel = walkingModel;
    switch (walkingModel.index) {
        case 0:
            self.title.text=NSLocalizedString(@"BottomView_today_activity", nil);
            self.distance.text  = walkingModel.totalDistance;
            self.calBurned.text = walkingModel.calBurned;
            break;
        case 1:
            self.title.text=NSLocalizedString(@"BottomView_today_activity", nil);
            self.distance.text  = walkingModel.totalTime;
            self.calBurned.text = walkingModel.runCalBurned;
            break;
        case 3:
            self.title.text     = NSLocalizedString(@"BottomView_previous_data", nil);
            self.distance.text  = walkingModel.BPM;
            self.calBurned.text = walkingModel.BPM_time;
            break;
            
        default:
            break;
    }
}
//同步按钮代理
- (IBAction)syncBtn:(id)sender {

    if ([_syncDelegate respondsToSelector:@selector(SyncButtonInWalkingView:)]) {
        
        [_syncDelegate SyncButtonInWalkingView:self];
    }

}

-(void)setIsHiddenSyncBtn:(BOOL)isHiddenSyncBtn{
    if (!isHiddenSyncBtn) {
        self.syncBtn.hidden = NO;
    }
}

@end
