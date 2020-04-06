//
//  YFTForgetPasswordViewController.m
//  SXRBand
//
//  Created by qf on 16/1/11.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "YFTForgetPasswordViewController.h"

@interface YFTForgetPasswordViewController ()<UIAlertViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong)IRKCommonData* commondata;

@property (nonatomic, strong)UITextField* username;
@property (nonatomic, strong)UIButton* btn_getback;
@property (strong, nonatomic)UIActivityIndicatorView* indicator;

@end

@implementation UIView (FindFirstResponder)
- (UIView *)findFirstResponder{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findFirstResponder];
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    return nil;
}

@end

@implementation YFTForgetPasswordViewController

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
//    [self.navigationController.navigationBar setTranslucent:YES];
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x74/255.0 green:0xb7/255.0 blue:0xec/255.0 alpha:1];
    if(![self.commondata.lastLoginUsername isEqual:@""]){
        self.username.text = self.commondata.lastLoginUsername;
    }
    
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    UIImageView* backgroundview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundview.image = [UIImage imageNamed:@"icon_background.png"];
    backgroundview.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:backgroundview];

//    [self initNav];
//    self.view.backgroundColor=[UIColor colorWithRed:0x74/255.0 green:0xb7/255.0 blue:0xec/255.0 alpha:1];
    
//    CGFloat logosize = CGRectGetHeight(self.view.frame)*0.3;
//    CGFloat btnsize = (CGRectGetHeight(self.view.frame)*0.6)/10;
//    CGFloat yoffset = (CGRectGetHeight(self.view.frame)*0.6-5*btnsize)/7.0;

    UIButton* backbtn = [[UIButton alloc] initWithFrame:self.view.bounds];
    [backbtn setBackgroundColor:[UIColor clearColor]];
    [backbtn setTitle:@"" forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(onTapBackgroundBtn:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:backbtn];
    
    CGFloat logosize = CGRectGetHeight(self.view.frame)/8.0;
    CGFloat btnsize = logosize/2.0;
    CGFloat sep = CGRectGetHeight(self.view.frame)/20.0;

    UIImageView* logoview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,logosize,logosize)];
    logoview.image = [UIImage imageNamed:@"icon_logo_big"];
    logoview.contentMode = UIViewContentModeScaleAspectFit;
    logoview.clipsToBounds = YES;
    [self.view addSubview:logoview];
    [logoview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(logosize, logosize));
        make.top.mas_equalTo(@0).with.offset(logosize);
        make.left.mas_equalTo(@0).with.offset((CGRectGetWidth(self.view.frame)-logosize)/2.0);
    }];

    
    CGFloat xoffset = self.view.frame.size.width*0.1;
    CGFloat cwidth = CGRectGetWidth(self.view.frame)-2*xoffset;

    self.username = [[UITextField alloc] initWithFrame:CGRectMake(0, 0 , cwidth, btnsize)];
//    self.username.placeholder = NSLocalizedString(@"GetBackPassword_username_tip", nil);
    self.username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"GetBackPassword_username_tip", nil) attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    self.username.backgroundColor = [UIColor clearColor];
    self.username.textAlignment = NSTextAlignmentLeft;
//    self.username.layer.cornerRadius = 5;
//    self.username.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.username.layer.borderWidth = 0.5;
    [self.username setReturnKeyType:UIReturnKeyDone];
    self.username.delegate = self;
    [self.username addTarget:self action:@selector(onDidEndEdit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.username.tag = 1024;
    self.username.leftViewMode = UITextFieldViewModeAlways;
    UIView* leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnsize, btnsize)];
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(btnsize/4.0, btnsize/4.0, btnsize/2.0, btnsize/2.0)];
    imgview.contentMode = UIViewContentModeScaleAspectFit;
    imgview.image = [UIImage imageNamed:@"icon_email.png"];
    [leftview addSubview:imgview];
    self.username.leftView = leftview;
    self.username.textColor = [UIColor whiteColor];
    [self.view addSubview:self.username];
    [self.username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cwidth, btnsize*0.8));
        make.top.mas_equalTo(logoview.mas_bottom).with.offset(sep);
        make.left.mas_equalTo(@0).with.offset(xoffset);
        
    }];

    UIView* sep1 = [[UIView alloc] initWithFrame:CGRectZero];
    sep1.backgroundColor = [UIColor colorWithRed:0xEF/255.0 green:0xEF/255.0 blue:0xEF/255.0 alpha:1.0];
    [self.view addSubview:sep1];
    [sep1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cwidth, 0.5));
        make.top.mas_equalTo(self.username.mas_bottom);
        make.left.mas_equalTo(@0).with.offset(xoffset);
        
    }];

    
    self.btn_getback = [[UIButton alloc] initWithFrame:CGRectMake(0,0, cwidth, btnsize)];
    self.btn_getback.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.btn_getback setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn_getback setTitle:NSLocalizedString(@"GetBackPassword_Title", nil) forState:UIControlStateNormal];
    [self.btn_getback setBackgroundColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];
    self.btn_getback.layer.cornerRadius = 5;
//    self.btn_getback.layer.borderWidth = 1;
//    self.btn_getback.layer.borderColor = self.commondata.colorLoginText.CGColor;
    [self.btn_getback addTarget:self action:@selector(onClickGetback:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_getback];
    
    [self.btn_getback mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cwidth, btnsize));
        make.top.mas_equalTo(self.username.mas_bottom).with.offset(sep);
        make.left.mas_equalTo(@0).with.offset(xoffset);
        
    }];

    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    [btn setImage:[UIImage imageNamed:@"icon_back_white"] forState:UIControlStateNormal];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //    UIImageView * backimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 22, 18)];
    //    backimg.image = [UIImage imageNamed:@"icon_back_white"];
    //    backimg.contentMode = UIViewContentModeScaleAspectFit;
    //    [btn addSubview:backimg];
    [btn addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 25));
        make.top.mas_equalTo(@30);
        make.left.mas_equalTo(@0);
        
    }];

    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat halfButtonHeight = self.btn_getback.bounds.size.height / 2;
    CGFloat buttonWidth = self.btn_getback.bounds.size.width;
    self.indicator.center = CGPointMake(buttonWidth - halfButtonHeight , halfButtonHeight);
    [self.btn_getback addSubview:self.indicator];
    self.indicator.hidden = YES;
}

-(void)initNav{
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    UIImageView * backimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 22, 18)];
    backimg.image = [UIImage imageNamed:@"icon_back_white"];
    backimg.contentMode = UIViewContentModeScaleAspectFit;
    [btn addSubview:backimg];
    [btn addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectZero];
    label.textColor=[UIColor whiteColor];
    label.text=NSLocalizedString(@"GetBackPassword_Title", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}

-(void)onClickBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onTapBackgroundBtn:(UIButton*)sender{
    UIView* first = [self.view findFirstResponder];
    [first resignFirstResponder];
}

- (void)onClickGetback:(id)sender {
    [self.username resignFirstResponder];
    if ([self.username.text isEqual:@""]) {
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"GetBackPasswordError_username_is_nil", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alertview show];
        return;
        
    }
    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"GetBackPassword_confirm", nil),self.username.text]  delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
    alertview.tag = 100;
    [alertview show];
    return;
}

-(void)onDidEndEdit:(UITextField*)sender{
    [sender resignFirstResponder];
}
-(NSString*)getSeqid{
    return [NSString stringWithFormat:@"%d", arc4random()/100000];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        }else{
            self.indicator.hidden = NO;
            [self.indicator startAnimating];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self Send_ForgetPassword];
            });
            
            return;
        }
    }
}

-(void)Send_ForgetPassword{
    NSError* error = nil;
    NSString* username = [self.username.text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"getback_password",@"action_cmd",[self getSeqid],@"seq_id",@{@"vid":self.commondata.vid,@"lang":NSLocalizedString(@"GetBackPasswordLang", nil),@"username":username},@"body", nil];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL]];
    NSLog(@"url = %@",url);
    NSLog(@"postdata = %@",dict);
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:url];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *postLength = [NSString stringWithFormat:@"%d",[data length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //设置http-header:Content-Length
    NSHTTPURLResponse* urlResponse = nil;
    //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicator.hidden = YES;
        [self.indicator stopAnimating];
        
    });
    if (error) {
        NSLog(@"network error!! try again later");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"GetBackPasswordError_server_abnormal", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertview show];
            
        });
        return;
        
    }
    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"getback_password result:%@",result);
    NSDictionary* respjson = [NSJSONSerialization
                              JSONObjectWithData:responseData //1
                              options:NSJSONReadingAllowFragments
                              error:&error];
    if (error) {
        NSLog(@"getback_password decode json ERROR!!");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"GetBackPasswordError_server_abnormal", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertview show];
            
        });
        
        return;
    }
    NSString* errocode = [respjson objectForKey:@"error_code"];
    if (errocode == nil) {
        NSLog(@"getback_password has no Errorcode!!");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"GetBackPasswordError_server_abnormal", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertview show];
            
        });
        
        return;
        
    }
    if ([errocode isEqualToString:ERROR_CODE_OK]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"GetBackPasswordOK_Tips", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertview show];
            
        });
        
        return;
        
    }else{
        NSLog(@"error = %@ ",NSLocalizedString(errocode, nil));
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errocode, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertview show];
            
        });
        
        return;
    }
    return;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect frame = textField.frame;
    int offset = 20 + frame.origin.y + frame.size.height*1.5 - (self.view.frame.size.height - 216.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
