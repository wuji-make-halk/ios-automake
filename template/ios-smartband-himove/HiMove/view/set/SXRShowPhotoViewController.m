//
//  SXRShowPhotoViewController.m
//  smartwristband
//
//  Created by 张志鹏 on 16/5/30.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "SXRShowPhotoViewController.h"

@interface SXRShowPhotoViewController ()

@property (nonatomic, strong)UIImageView *photoImage;
@property (nonatomic, strong)UIButton *btnBack;

@end

@implementation SXRShowPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnBack setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [_btnBack setFrame:CGRectMake(10, 25, 34, 34)];
    [_btnBack addTarget:self action:@selector(onClickedBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnBack];
    
    
//    CGFloat space = 35;
    CGFloat imageHeight = CGRectGetHeight(self.view.frame) - 70 * 2;
    _photoImage =  [[UIImageView alloc] initWithFrame:CGRectMake(0, 70, CGRectGetWidth(self.view.frame), imageHeight)];
    
    [_photoImage setBackgroundColor:[UIColor colorWithWhite:0.388 alpha:0.8]];
    
    [_photoImage setImage:_image];
    [self.view addSubview:_photoImage];
}

- (void)onClickedBack:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
