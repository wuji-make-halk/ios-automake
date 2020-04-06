//
//  YFTRegisterViewController.m
//  SXRBand
//
//  Created by qf on 16/1/11.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "YFTRegisterViewController.h"


@interface YFTRegisterViewController ()<UIAlertViewDelegate,UITextFieldDelegate>
@property (nonatomic, strong)IRKCommonData* commondata;
//@property (nonatomic, strong)UIImageView* image_background;

@property (nonatomic, strong)UITextField* username;
@property (nonatomic, strong)UITextField* password;
@property (nonatomic, strong)UIButton* btn_register;
@property (strong, nonatomic)UIActivityIndicatorView* indicator;
@property (strong,nonatomic)NSMutableData* recvdata;
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

@implementation YFTRegisterViewController

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
//    [self.navigationController.navigationBar setTranslucent:YES];
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x74/255.0 green:0xb7/255.0 blue:0xec/255.0 alpha:1];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
//    [self initNav];
//    self.view.backgroundColor=[UIColor colorWithRed:0x74/255.0 green:0xb7/255.0 blue:0xec/255.0 alpha:1];

    UIImageView* backgroundview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundview.image = [UIImage imageNamed:@"icon_background.png"];
    backgroundview.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:backgroundview];

    UIButton* backbtn = [[UIButton alloc] initWithFrame:self.view.bounds];
    [backbtn setBackgroundColor:[UIColor clearColor]];
    [backbtn setTitle:@"" forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(onTapBackgroundBtn:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:backbtn];
    

//    CGFloat logosize = CGRectGetHeight(self.view.frame)*0.3;
//    CGFloat btnsize = (CGRectGetHeight(self.view.frame)*0.6)/10;
//    CGFloat yoffset = (CGRectGetHeight(self.view.frame)*0.6-5*btnsize)/7.0;
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
    
//    CGFloat leftX = (CGRectGetWidth(self.view.frame) - logosize / 1.5) / 2.0;
//    UIImageView *titleLogo = [[UIImageView alloc] initWithFrame:CGRectMake(leftX, CGRectGetMaxY(logoview.frame), logosize / 1.5, logosize / 2.5)];
//    
//    titleLogo.contentMode = UIViewContentModeScaleAspectFit;
//    titleLogo.clipsToBounds = YES;
    //[self.view addSubview:titleLogo];
    
    self.username = [[UITextField alloc] initWithFrame:CGRectMake(0, 0 , cwidth, btnsize)];
//    self.username.placeholder = NSLocalizedString(@"Regist_Username_Tip", nil);
    self.username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Login_Username_Tip", nil) attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

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

    self.password = [[UITextField alloc] initWithFrame:CGRectMake(0, 0 , cwidth, btnsize*0.8)];
//    self.password.placeholder = NSLocalizedString(@"Regist_Password_Tip", nil);
    self.password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Login_Password_Tip", nil) attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    self.password.backgroundColor = [UIColor clearColor];
    self.password.textAlignment = NSTextAlignmentLeft;
//    self.password.layer.cornerRadius = 5;
//    self.password.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.password.layer.borderWidth = 0.5;
    self.password.delegate = self;
    [self.password setSecureTextEntry:YES];
    [self.password addTarget:self action:@selector(onDidEndEdit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.password.leftViewMode = UITextFieldViewModeAlways;
    UIView* leftview1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnsize, btnsize)];
    UIImageView* imgview1 = [[UIImageView alloc] initWithFrame:CGRectMake(btnsize/4.0, btnsize/4.0, btnsize/2.0, btnsize/2.0)];
    imgview1.contentMode = UIViewContentModeScaleAspectFit;
    imgview1.image = [UIImage imageNamed:@"icon_password.png"];
    [leftview1 addSubview:imgview1];
    self.password.leftView = leftview1;
    self.password.textColor = [UIColor whiteColor];
    [self.view addSubview:self.password];
    [self.password mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cwidth, btnsize*0.8));
        make.top.mas_equalTo(self.username.mas_bottom).with.offset(sep);
        make.left.mas_equalTo(@0).with.offset(xoffset);
        
    }];

    
    UIView* sep2 = [[UIView alloc] initWithFrame:CGRectZero];
    sep2.backgroundColor = [UIColor colorWithRed:0xEF/255.0 green:0xEF/255.0 blue:0xEF/255.0 alpha:1.0];
    [self.view addSubview:sep2];
    [sep2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cwidth, 0.5));
        make.top.mas_equalTo(self.password.mas_bottom);
        make.left.mas_equalTo(@0).with.offset(xoffset);
        
    }];
                                                                  
    
    self.btn_register = [[UIButton alloc] initWithFrame:CGRectMake(0,0, cwidth, btnsize)];
    self.btn_register.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.btn_register setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn_register setTitle:NSLocalizedString(@"Regist_Btn_Regist", nil) forState:UIControlStateNormal];
    [self.btn_register setBackgroundColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];
    self.btn_register.layer.cornerRadius = 5;
//    self.btn_register.layer.borderColor = self.commondata.colorLoginText.CGColor;
//    self.btn_register.layer.borderWidth = 1;
    [self.btn_register addTarget:self action:@selector(onClickRegist:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_register];
    [self.btn_register mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cwidth, btnsize));
        make.top.mas_equalTo(self.password.mas_bottom).with.offset(sep);
        make.left.mas_equalTo(@0).with.offset(xoffset);
        
    }];

    // Do any additional setup after loading the view.
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat halfButtonHeight = self.btn_register.bounds.size.height / 2;
    CGFloat buttonWidth = self.btn_register.bounds.size.width;
    self.indicator.center = CGPointMake(buttonWidth - halfButtonHeight , halfButtonHeight);
    [self.btn_register addSubview:self.indicator];
    self.indicator.hidden = YES;
    
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

//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

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
    label.text=NSLocalizedString(@"Regist_Title", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
    
}

-(void)onClickBack:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)onTapBackgroundBtn:(UIButton*)sender{
    UIView* first = [self.view findFirstResponder];
    [first resignFirstResponder];
}

- (void)onClickRegist:(id)sender {
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
//    self.btn_register.enabled = NO;
    
    
    NSString* seqid = [NSString stringWithFormat:@"%u",arc4random()];
    if (![self isValidateEmail:self.username.text]) {
        UIAlertView *alert          = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid_Email", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
        [self.indicator stopAnimating];
        return;
    }
    if (self.password.text.length==0||[self.password.text isEqualToString:@""]) {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No_Password", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alertView show];
        [self.indicator stopAnimating];
        return;
    }
    
    NSString* username = [self.username.text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"username = %@",username);
    
    
    
    
    
    
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"register",@"action_cmd",seqid,@"seq_id",@{@"username":username,@"pwd":self.password.text,@"vid":self.commondata.vid},@"body", nil];
    NSError* error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL]];
    NSLog(@"url = %@",url);
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:url];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //设置http-header:Content-Length
    NSString *postLength = [NSString stringWithFormat:@"%d",(int)[data length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:60];
    //第三步，连接服务器
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
    NSLog(@"sendLogin ok");
}

-(void)onDidEndEdit:(UITextField*)sender{
    [sender resignFirstResponder];
}

/////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"didReceiveResponse%@",[res allHeaderFields]);
    self.recvdata = [NSMutableData data];
    
    
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.recvdata appendData:data];
}
//数据传完之后调用此方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
    self.btn_register.enabled = YES;
    
    NSString *receiveStr = [[NSString alloc]initWithData:self.recvdata encoding:NSUTF8StringEncoding];
    NSLog(@"connectionDidFinishLoading :%@",receiveStr);
    NSError* error = nil;
    NSDictionary* result = [NSJSONSerialization JSONObjectWithData:self.recvdata options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"%@",result);
    //    [self.popup dismiss:YES];
    //    self.popup = nil;
    [self procData:result];
    
    
}


-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError%@",[error localizedDescription]);
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
    self.btn_register.enabled = YES;
    
    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Regist_Error", nil) message:NSLocalizedString(@"Login_Error_No_network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alertview show];
    
    return;
    
}

-(void)procData:(NSDictionary*)respjson{
    NSString* result_error = [respjson objectForKey:@"error_code"];
    if (result_error == nil) {
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Login_Error_No_network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alertview show];
        
        return;
        
    }
    if ([result_error isEqualToString:ERROR_CODE_OK]) {
        self.commondata.lastLoginUsername = self.username.text;
        [self.commondata saveconfig];
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Regist_Ok_login", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        alertview.tag = 100;
        [alertview show];
    }else{
        NSString* errorcode = [respjson objectForKey:@"error_code"];
        if (errorcode == nil) {
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Login_Error_No_network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
            [alertview show];
            return;
        }else{
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(errorcode, nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
            [alertview show];
            return;
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self onClickBack:nil];
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = 17 + frame.origin.y + frame.size.height*1.5 - (self.view.frame.size.height - 216.0);//键盘高度216
    
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


/**
 注册格式是否为邮箱

 @param email email description

 @return return value description
 */
- (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
