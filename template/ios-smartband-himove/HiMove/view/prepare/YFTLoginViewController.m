//
//  YFTLoginViewController.m
//  SXRBand
//
//  Created by qf on 16/1/11.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "YFTLoginViewController.h"
#import "AppDelegate.h"
#import "KLCPopup.h"
#import <CommonCrypto/CommonDigest.h>
#import <Contacts/Contacts.h>
#import "HMTabBarController.h"
#import "YFTRegisterViewController.h"
#import "YFTForgetPasswordViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "TaskManager.h"



@interface YFTLoginViewController ()<UITextFieldDelegate>
@property (nonatomic, strong)IRKCommonData* commondata;
//@property (nonatomic, strong)UIImageView* backgroundview;
@property (nonatomic, strong)UIImageView* logoview;
@property (nonatomic, strong)UILabel* label;
@property (nonatomic, strong)UITextField* username;
@property (nonatomic, strong)UITextField* password;
@property (nonatomic, strong)UIButton* btn_login;
@property (nonatomic, strong)UIButton* btn_register;
@property (nonatomic, strong)UIButton* btn_skip;
@property (nonatomic, strong)UIButton* btn_fogetpwd;
@property (strong,nonatomic)NSMutableData* recvdata;
@property (strong,nonatomic)KLCPopup* popup;
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

@implementation YFTLoginViewController

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    if (![self.commondata.lastLoginUsername isEqualToString:@""]) {
        self.username.text = self.commondata.lastLoginUsername;
        [self fillpassword];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
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
    
    CGFloat logosize = CGRectGetHeight(self.view.frame)/8.0;
    CGFloat btnsize = logosize/2.0;
    CGFloat sep = CGRectGetHeight(self.view.frame)/20.0;
//    CGFloat yoffset = (CGRectGetHeight(self.view.frame)*0.6-5*btnsize)/7.0;
//    CGFloat logoWidth = CGRectGetWidth(self.view.frame) / 1.6;
//    CGFloat xffset = (CGRectGetWidth(self.view.frame) - logoWidth) / 2.0;

    self.logoview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,logosize,logosize)];
    self.logoview.image = [UIImage imageNamed:@"icon_logo_big"];
    self.logoview.contentMode = UIViewContentModeScaleAspectFit;
    self.logoview.clipsToBounds = YES;
    [self.view addSubview:self.logoview];
    [self.logoview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(logosize, logosize));
        make.top.mas_equalTo(@0).with.offset(logosize);
        make.left.mas_equalTo(@0).with.offset((CGRectGetWidth(self.view.frame)-logosize)/2.0);
    }];
    
    CGFloat xoffset = self.view.frame.size.width*0.1;
    CGFloat cwidth = CGRectGetWidth(self.view.frame)-2*xoffset;
    self.username = [[UITextField alloc] initWithFrame:CGRectMake(0, 0 , cwidth, btnsize)];
//    self.username.placeholder = NSLocalizedString(@"Login_Username_Tip", nil);
    self.username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Login_Username_Tip", nil) attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.username.backgroundColor = [UIColor clearColor];
    self.username.textAlignment = NSTextAlignmentLeft;
//    self.username.layer.cornerRadius = 5;
//    self.username.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.username.layer.borderWidth = 0.5;
    [self.username setReturnKeyType:UIReturnKeyDone];
    self.username.delegate = self;
    [self.username addTarget:self action:@selector(onDidEndEdit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.username addTarget:self action:@selector(ondidValueChange:) forControlEvents:UIControlEventEditingChanged];
    self.username.tag = 1024;
    self.username.leftViewMode = UITextFieldViewModeAlways;
    UIView* leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnsize, btnsize*0.8)];
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(btnsize/4.0, btnsize/4.0, btnsize/2.0, btnsize/2.0)];
    imgview.contentMode = UIViewContentModeScaleAspectFit;
    imgview.image = [UIImage imageNamed:@"icon_email.png"];
    [leftview addSubview:imgview];
    self.username.leftView = leftview;
    self.username.textColor = [UIColor whiteColor];
    [self.view addSubview:self.username];
    [self.username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cwidth, btnsize*0.8));
        make.top.mas_equalTo(self.logoview.mas_bottom).with.offset(sep);
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
//    self.password.placeholder = NSLocalizedString(@"Login_Password_Tip", nil);
    self.password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Login_Password_Tip", nil) attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.password.backgroundColor = [UIColor clearColor];
    self.password.textColor = [UIColor whiteColor];
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

    
    self.btn_login = [[UIButton alloc] initWithFrame:CGRectMake(0,0, cwidth, btnsize)];
    self.btn_login.titleLabel.textAlignment = NSTextAlignmentCenter;
    //    self.btn_login.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:24];
//    [self.btn_login setTitleColor:self.commondata.colorLoginText forState:UIControlStateNormal];
    [self.btn_login setBackgroundColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];
    [self.btn_login setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [self.btn_login setBackgroundColor:[UIColor colorWithRed:0x34/255.0 green:0xd8/255.0 blue:0x94/255.0 alpha:1.0]];
    self.btn_login.layer.cornerRadius = 5;
//    self.btn_login.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.btn_login.layer.borderWidth = 1;
    [self.btn_login setTitle:NSLocalizedString(@"Login_Btn_Login", nil) forState:UIControlStateNormal];
    [self.btn_login addTarget:self action:@selector(onClickLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_login];
    [self.btn_login mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cwidth, btnsize));
        make.top.mas_equalTo(self.password.mas_bottom).with.offset(sep);
        make.left.mas_equalTo(@0).with.offset(xoffset);
        
    }];
  
    //    UIView* sep1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.btn_register.frame)-1, CGRectGetMinY(self.btn_register.frame), 2, btnsize/2.0)];
    //    sep1.backgroundColor = [UIColor darkGrayColor];
    //    [self.view addSubview:sep1];
    
    self.btn_register = [[UIButton alloc] initWithFrame:CGRectMake(0,0, cwidth/2.0, btnsize/2.0)];
    //    self.btn_register.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.btn_register setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    //    self.btn_register.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16];
    [self.btn_register setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn_register setTitle:NSLocalizedString(@"Login_Btn_Regist", nil) forState:UIControlStateNormal];
    [self.btn_register addTarget:self action:@selector(onClickRegist:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_register];
    [self.btn_register mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cwidth/2.0, btnsize/2.0));
        make.top.mas_equalTo(self.btn_login.mas_bottom).with.offset(sep);
        make.left.mas_equalTo(@0).with.offset(xoffset);
        
    }];

    
    self.btn_fogetpwd = [[UIButton alloc] initWithFrame:CGRectMake(0,0, cwidth/2.0, btnsize/2.0)];
    [self.btn_fogetpwd setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    //    self.btn_register.titleLabel.textAlignment = NSTextAlignmentRight;
//    self.btn_fogetpwd.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16];
    [self.btn_fogetpwd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btn_fogetpwd.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.btn_fogetpwd.titleLabel.minimumScaleFactor = 0.5;
    [self.btn_fogetpwd setTitle:NSLocalizedString(@"Login_Btn_FogetPassword", nil) forState:UIControlStateNormal];
    [self.btn_fogetpwd addTarget:self action:@selector(onClickFogetpsw:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_fogetpwd];
    [self.btn_fogetpwd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cwidth/2.0, btnsize/2.0));
        make.top.mas_equalTo(self.btn_login.mas_bottom).with.offset(sep);
        make.left.mas_equalTo(self.btn_register.mas_right);
        
    }];
 
    
    
    self.btn_skip = [[UIButton alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth(self.view.frame), btnsize/2.0)];
    //    self.btn_skip.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.btn_skip setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    //    self.btn_skip.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:16];
    [self.btn_skip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn_skip setTitle:NSLocalizedString(@"Login_Btn_Skip", nil) forState:UIControlStateNormal];
    [self.btn_skip addTarget:self action:@selector(onClickSkip:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_skip];
    [self.btn_skip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.frame), btnsize/2.0));
        make.top.mas_equalTo(self.view.mas_bottom).with.offset(-sep);
        make.left.mas_equalTo(@0);
        
    }];
    
    
    // Do any additional setup after loading the view.
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat halfButtonHeight = self.btn_login.bounds.size.height / 2;
    CGFloat buttonWidth = self.btn_login.bounds.size.width;
    self.indicator.center = CGPointMake(buttonWidth - halfButtonHeight , halfButtonHeight);
    [self.btn_login addSubview:self.indicator];
    self.indicator.hidden = YES;
    
    
}

- (void)onClickSkip:(id)sender {
    [self switchtoMain];
}

-(void)onTapBackgroundBtn:(UIButton*)sender{
    UIView* first = [self.view findFirstResponder];
    [first resignFirstResponder];
}

- (NSString*)CalcPassword:(NSString*)password Verifycode:(NSString*)verifycode{
    const char* cStrValue = [verifycode UTF8String];
    unsigned char theResult[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStrValue, (CC_LONG)strlen(cStrValue), theResult);
    NSString * m0 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                     theResult[0], theResult[1], theResult[2], theResult[3],
                     theResult[4], theResult[5], theResult[6], theResult[7],
                     theResult[8], theResult[9], theResult[10], theResult[11],
                     theResult[12], theResult[13], theResult[14], theResult[15]];
    NSLog(@"m0 = %@",m0);
    NSString* tmp = [NSString stringWithFormat:@"%@%@",password,m0];
    const char* cpass = [tmp cStringUsingEncoding:NSASCIIStringEncoding];
    CC_MD5(cpass, (CC_LONG)strlen(cpass), theResult);
    NSString* m1 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                    theResult[0], theResult[1], theResult[2], theResult[3],
                    theResult[4], theResult[5], theResult[6], theResult[7],
                    theResult[8], theResult[9], theResult[10], theResult[11],
                    theResult[12], theResult[13], theResult[14], theResult[15]];
    NSLog(@"m1 = %@",m1);
    return m1;
    
}
-(NSString*)getVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *label = [NSString stringWithFormat:@"%@ v%@ (build %@)", name, version, build];
    return label;
}
-(NSString*)getPhoneType{
    return [[UIDevice currentDevice] model];
}
-(NSString*)getPhoneOS{
    return [NSString stringWithFormat:@"%@:%@",[[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
}
-(NSString*)getPhoneName{
    return [[UIDevice currentDevice] name];
}
-(NSString*)getPhoneId{
    //    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return  [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}
-(NSString*)getSeqid{
    return [NSString stringWithFormat:@"%d", arc4random()/100000];
}

- (void)onClickLogin:(id)sender {
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    self.commondata.lastLoginUsername = self.username.text;
    [self.commondata saveconfig];
    
    [self.btn_login setTitle:NSLocalizedString(@"Login_Start_to_login", nil) forState:UIControlStateNormal];
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
    if ([self.username.text isEqual:@""]) {
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"GetBackPasswordError_username_is_nil", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [self.indicator stopAnimating];
        [alertview show];
        return;
        
    }
    if (self.password.text.length==0||[self.password.text isEqualToString:@""]) {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No_Password", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alertView show];
        [self.indicator stopAnimating];
        return;
    }
    NSString* seqid = [NSString stringWithFormat:@"%u",arc4random()];
    NSString* password = [self CalcPassword:self.password.text Verifycode:VERIFY_CODE];
    NSString* username = [self.username.text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"username = %@",username);
    
    
//    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"login",@"action_cmd",seqid,@"seq_id",@{@"username":username,@"pwd":password,@"vid":VID,@"phone_name":[self getPhoneName],@"phone_os":[self getPhoneOS],@"phone_id":[self getPhoneId],@"app_version":[self getVersion],@"phone_type":[self.commondata getPhoneType]},@"body", nil];

    
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,ACTION_KEY_VERSION,
                          ACTION_CMD_LOGIN,ACTION_KEY_CMDNAME,
                          seqid,ACTION_KEY_SEQID,
                          @{ACTION_KEY_USERNAME:username,
                            ACTION_KEY_PASSWORD:password,
                            ACTION_KEY_VID:self.commondata.vid,
                            ACTION_KEY_APPLANG:NSLocalizedString(@"GetBackPasswordLang", nil),
                            ACTION_KEY_SYSLANG:[IRKCommonData getSysLanguage],
                            ACTION_KEY_NATION:[IRKCommonData getCountryCode],
                            ACTION_KEY_NATIONCODE:[IRKCommonData getCountryNum],
                            ACTION_KEY_PHONENAME:[self.commondata getPhoneName],
                            ACTION_KEY_PHONEOS:[self.commondata getPhoneOS],
                            ACTION_KEY_PHONEID:[self.commondata getPhoneId],
                            ACTION_KEY_PHONETYPE:[self.commondata getPhoneType],
                            ACTION_KEY_APPVERSION:[self.commondata getVersion]},ACTION_KEY_BODY, nil];
    
    NSString* url =[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL];
    NSLog(@"url = %@",url);
    NSLog(@"postdata = %@",dict);
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Login JSON: %@", responseObject);
        NSDictionary* respjson = (NSDictionary*)responseObject;
        NSString* errocode = [respjson objectForKey:RESPONE_KEY_ERRORCODE];
        
        if ([errocode isEqualToString:ERROR_CODE_OK]) {
            NSDictionary* body = [respjson objectForKey:RESPONE_KEY_BODY];
            if (body){
                NSString* tid = [body objectForKey:RESPONE_KEY_TID];
                NSString* memberid = [body objectForKey:RESPONE_KEY_MEMBERID];
                self.commondata.token = tid;
                self.commondata.memberid = memberid;
                self.commondata.is_login = YES;
                self.commondata.lastLoginTime = [[NSDate date] timeIntervalSince1970];
                [self.commondata saveconfig];
                [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_has_Login object:nil];
                [[ServerLogic SharedInstance] updateUserInfotoCommonData:[body mutableCopy]];
                [[TaskManager SharedInstance] CheckSyncKey:[body mutableCopy]];
                [self switchtoMain];
                
            }
            
        }else {
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login_Error", nil) message:NSLocalizedString(errocode, nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
            [alertview show];
            return;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Login error= %@",error);
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login_Error", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alertview show];
        return;
        
    }];

    
    
//    NSString* seqid = [NSString stringWithFormat:@"%u",arc4random()];
//    NSString* password = [self CalcPassword:self.password.text Verifycode:VERIFY_CODE];
//    NSString* username = [self.username.text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"username = %@",username);
//    
//    
//    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"login",@"action_cmd",seqid,@"seq_id",@{@"username":username,@"pwd":password,@"vid":VID,@"phone_name":[self getPhoneName],@"phone_os":[self getPhoneOS],@"phone_id":[self getPhoneId],@"app_version":[self getVersion],@"phone_type":[self.commondata getPhoneType]},@"body", nil];
//    NSError* error = nil;
//    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,MEMBER_URL]];
//    NSLog(@"url = %@",url);
//    //第二步，创建请求
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
//    [request setURL:url];
//    [request setHTTPBody:data];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    //设置http-header:Content-Length
//    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[data length]];
//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
//    [request setTimeoutInterval:60];
//    //第三步，连接服务器
//    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
//    [connection start];
//    NSLog(@"sendLogin ok");
    
}
-(void)onClickFogetpsw:(UIButton*)sender{
    YFTForgetPasswordViewController *vc=[YFTForgetPasswordViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)onClickRegist:(id)sender {
    YFTRegisterViewController *vc=[YFTRegisterViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)onDidEndEdit:(UITextField*)sender{
    [sender resignFirstResponder];
}

-(void)switchtoMain{
    
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IPhone" bundle:nil];
//    SXRRootViewController* n1 = [storyboard instantiateViewControllerWithIdentifier:@"rootViewController"];
//    appdelegate.window.rootViewController = n1;
//    [appdelegate.window makeKeyAndVisible];
    HMTabBarController *tb=[HMTabBarController new];
    appdelegate.window.rootViewController = tb;
    [appdelegate.window makeKeyAndVisible];
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
    [self.btn_login setTitle:NSLocalizedString(@"Login_Btn_Login", nil) forState:UIControlStateNormal];
    
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
 didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError%@",[error localizedDescription]);
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
    [self.btn_login setTitle:NSLocalizedString(@"Login_Btn_Login", nil) forState:UIControlStateNormal];
    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Login_Error_No_network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
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
        NSDictionary* body = [respjson objectForKey:@"body"];
        NSString* tid = [body objectForKey:@"tid"];
        self.commondata.token = tid;
        self.commondata.is_login = YES;
        self.commondata.lastLoginTime = [[NSDate date] timeIntervalSince1970];
        [self.commondata saveconfig];
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_has_Login object:nil];
        [self switchtoMain];
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
///////////////////////////////////////////////
#pragma UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect frame = textField.frame;
    int offset = 15 + frame.origin.y + frame.size.height*1.5 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(void)ondidValueChange:(UITextField*)sender{
    switch (sender.tag) {
        case 1024:{
            [self fillpassword];
            break;
        }
        default:
            break;
    }
}

-(void)fillpassword{
    if (![self.username.text isEqualToString:@""]) {
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        NSString* password = [ud objectForKey:self.username.text];
        if (password!= nil) {
            self.password.text = password;
        }else{
            self.password.text = @"";
        }
    }
}
//-(void)addWhatsappContact{
//    
////    ABAddressBookRef addressBook = ABAddressBookCreate();
////    CFStringRef cfName = CFSTR("Pulzz customer service");
////    NSArray * people = (__bridge NSArray*)ABAddressBookCopyPeopleWithName(addressBook,cfName);
//    if (self.commondata.is_first_run) {
//        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
//        if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted) {
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"This app previously was refused permissions to contacts; Please go to settings and grant permission to this app so it can add the desired contact" preferredStyle:UIAlertControllerStyleAlert];
//            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//            [self presentViewController:alert animated:TRUE completion:nil];
////            CFRelease(cfName);
//            return;
//        }
//        
//        CNContactStore *store = [[CNContactStore alloc] init];
//        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
//            if (!granted) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    // user didn't grant access;
//                    // so, again, tell user here why app needs permissions in order  to do it's job;
//                    // this is dispatched to the main queue because this request could be running on background thread
//                });
//                return;
//            }else {
//                CNContactStore * stroe = [[CNContactStore alloc]init];
//                //检索条件，检索所有名字
//                NSPredicate * predicate = [CNContact predicateForContactsMatchingName:@"Pulzz customer service"];
//                //提取数据
//                NSArray * people = [stroe unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactFamilyNameKey] error:nil];
//                //已经添加客服号
//                if (people.count != 0) {
//                    return;
//                }else{
//                    //添加联系人
//                    CNMutableContact *contact = [[CNMutableContact alloc] init];
//                    contact.familyName = @"Pulzz customer service";
//                    //            contact.namePrefix = @"PUZZLE";
//                    CNLabeledValue *homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:@"+91 8750355913"]];
//                    contact.phoneNumbers = @[homePhone];
//                    CNSaveRequest *request = [[CNSaveRequest alloc] init];
//                    [request addContact:contact toContainerWithIdentifier:nil];
//                    
//                    // save it
//                    NSError *saveError;
//                    if (![store executeSaveRequest:request error:&saveError]) {
//                        NSLog(@"error = %@", saveError);
//                    }
//
//                }
//
//            }
//            
//        }];
//        
//    }
//    
//}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
