//
//  FRSleepBottomView.m
//  CZJKBand
//
//  Created by 刘增述 on 16/9/9.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "FRSleepBottomView.h"
#import "UIView+Frame.h"

@interface FRSleepBottomView ()
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *deep;
@property (weak, nonatomic) IBOutlet UILabel *extreme;
@property (weak, nonatomic) IBOutlet UILabel *light;
@property (weak, nonatomic) IBOutlet UILabel *awake;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *syncBtn;

@end

@implementation FRSleepBottomView


+ (instancetype)sleepBottomView
{
    //从xib中加载subview
    NSBundle *bundle = [NSBundle mainBundle];
    //加载xib中得view
    FRSleepBottomView *subView = [[bundle loadNibNamed:@"FRSleepBottomView" owner:nil options:nil] lastObject];
    return subView;

}
-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor  = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.borderColor   = [UIColor whiteColor].CGColor;
    self.contentView.layer.borderWidth = 1;
    [self.syncBtn setTitle:NSLocalizedString(@"BottomView_sync_data", nil) forState:UIControlStateNormal];
    self.syncBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.syncBtn.layer.borderWidth = 1.0;
    self.syncBtn.layer.cornerRadius=10;
    self.syncBtn.clipsToBounds=YES;

}
-(void)setSleepModle:(FRWalkingDetailModel *)sleepModle
{
    _sleepModle      = sleepModle;
    self.title.text  = NSLocalizedString(@"BottomView_today_sleep", nil);
    self.deep.text   = sleepModle.deep;
    self.extreme.text = sleepModle.extremly;
    self.light.text   = sleepModle.light;
    self.awake.text   = sleepModle.awake;
    self.awake.textAlignment       = NSTextAlignmentLeft;
}
- (IBAction)clickSyncBtn:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(SyncButtonInSleepBottomView:)]) {
        [_delegate SyncButtonInSleepBottomView:self];
    }

    
}

@end
