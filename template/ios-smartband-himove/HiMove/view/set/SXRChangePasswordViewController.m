//
//  SXRChangePasswordViewController.m
//  SXRBand
//
//  Created by qf on 14-12-8.
//  Copyright (c) 2014年 SXR. All rights reserved.
//

#import "SXRChangePasswordViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface SXRChangePasswordViewController ()
@property(strong, nonatomic)UITextField* oldpassword;
@property(strong, nonatomic)UITextField* newpassword;
@property(strong, nonatomic)UITextField* confirmpassword;
@property(strong, nonatomic)UIActivityIndicatorView* activityindicator;
@property (strong, nonatomic) IRKCommonData* commondata;

@end

@implementation SXRChangePasswordViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    [self initNav];
    [self initControl];
}

-(void)initNav{
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    UIImageView * backimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 22, 18)];
    backimg.image = [UIImage imageNamed:@"icon_back"];
    backimg.contentMode = UIViewContentModeScaleAspectFit;
    [btn addSubview:backimg];
    [btn addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectZero];
    label.textColor=[UIColor blackColor];
    label.text=NSLocalizedString(@"ChangePassword_Title", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}

-(void)initControl{
    self.view.backgroundColor = [UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    
    UIButton* backbtn = [[UIButton alloc] initWithFrame:self.view.bounds];
    [backbtn setBackgroundColor:[UIColor clearColor]];
    [backbtn setTitle:@"" forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(onTapBackgroundBtn:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:backbtn];
    
    CGFloat xoffset = self.view.frame.size.width*0.1;
    CGFloat ewidth = self.view.frame.size.width*0.8;
    CGFloat yoffset = 30;
    CGFloat eheight = 40;
    self.oldpassword = [[UITextField alloc] initWithFrame:CGRectMake(xoffset, yoffset, ewidth, eheight)];
    self.oldpassword.placeholder = NSLocalizedString(@"Input_Old_Password", nil);
    self.oldpassword.backgroundColor = [UIColor whiteColor];
    self.oldpassword.textAlignment = NSTextAlignmentCenter;
    self.oldpassword.layer.cornerRadius = eheight/4.0;
    self.oldpassword.font = [self.commondata getFontbySize:18 isBold:NO];
    self.oldpassword.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.oldpassword.layer.borderWidth = 0.5;
    [self.oldpassword setSecureTextEntry:YES];
    [self.oldpassword addTarget:self action:@selector(onEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:self.oldpassword];
    
    self.newpassword = [[UITextField alloc] initWithFrame:CGRectMake(xoffset, self.oldpassword.frame.origin.y+eheight+yoffset, ewidth, eheight)];
    self.newpassword.placeholder = NSLocalizedString(@"Input_New_Password", nil);
    self.newpassword.backgroundColor = [UIColor whiteColor];
    self.newpassword.textAlignment = NSTextAlignmentCenter;
    self.newpassword.font = [self.commondata getFontbySize:18 isBold:NO];
    self.newpassword.layer.cornerRadius = eheight/4.0;
    self.newpassword.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.newpassword.layer.borderWidth = 0.5;
    [self.newpassword setSecureTextEntry:YES];
    [self.newpassword addTarget:self action:@selector(onEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:self.newpassword];
    
    self.confirmpassword = [[UITextField alloc] initWithFrame:CGRectMake(xoffset, self.newpassword.frame.origin.y+eheight+yoffset, ewidth, eheight)];
    self.confirmpassword.placeholder = NSLocalizedString(@"Comfirm_New_Password", nil);
    self.confirmpassword.backgroundColor = [UIColor whiteColor];
    self.confirmpassword.textAlignment = NSTextAlignmentCenter;
    self.confirmpassword.layer.cornerRadius = eheight/4.0;
    self.confirmpassword.font =[self.commondata getFontbySize:18 isBold:NO];
    self.confirmpassword.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.confirmpassword.layer.borderWidth = 0.5;
    [self.confirmpassword addTarget:self action:@selector(onEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.confirmpassword setSecureTextEntry:YES];
    [self.view addSubview:self.confirmpassword];
    
    UIButton * submit = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, CGRectGetMaxY(self.confirmpassword.frame)+50, 200, 50)];
    submit.backgroundColor= [UIColor colorWithRed:0x74/255.0 green:0xb7/255.0 blue:0xec/255.0 alpha:1];
    submit.titleLabel.font = [self.commondata getFontbySize:20 isBold:NO];
    submit.titleLabel.textAlignment = NSTextAlignmentRight;
    [submit setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
    [submit addTarget:self action:@selector(onClickSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submit];
    
    self.activityindicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityindicator.frame = CGRectMake(150, 0, 50, 50);
    self.activityindicator.hidden = YES;
    [submit addSubview:self.activityindicator];
}

-(void)onClickBack:(UIButton*)sender{

    [self.navigationController popViewControllerAnimated:YES];
}
-(void)onTapBackgroundBtn:(UIButton*)sender{
    [self.oldpassword resignFirstResponder];
    [self.newpassword resignFirstResponder];
    [self.confirmpassword resignFirstResponder];
}

-(void)onEndOnExit:(UITextField*)sender{
    [sender resignFirstResponder];
}

-(void)onClickSubmit:(id)sender{
    NSString* old = self.oldpassword.text;
    NSString* new = self.newpassword.text;
    NSString* confirm = self.confirmpassword.text;
    if ([old isEqual:@""]) {
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ChangePasswordError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertview show];
        return;
    }
    if ([new isEqual:@""]) {
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ChangePasswordError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertview show];
        return;
    }
    if (![new isEqual:confirm]) {
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ChangePasswordError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertview show];
        return;
    }
    if ([old isEqual:new]) {
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ChangePasswordError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertview show];
        return;
    }
    self.activityindicator.hidden = NO;
    [self.activityindicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self changepassword];
    });
}
/////////////////////////////////////////
-(NSString*)getSeqid{
    return [NSString stringWithFormat:@"%d", arc4random()/100000];
}

- (NSString*)CalcPassword:(NSString*)password Verifycode:(NSString*)verifycode{
    const char* cStrValue = [verifycode UTF8String];
    unsigned char theResult[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStrValue, strlen(cStrValue), theResult);
    NSString * m0 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                     theResult[0], theResult[1], theResult[2], theResult[3],
                     theResult[4], theResult[5], theResult[6], theResult[7],
                     theResult[8], theResult[9], theResult[10], theResult[11],
                     theResult[12], theResult[13], theResult[14], theResult[15]];
    NSLog(@"m0 = %@",m0);
    NSString* tmp = [NSString stringWithFormat:@"%@%@",password,m0];
    const char* cpass = [tmp cStringUsingEncoding:NSASCIIStringEncoding];
    CC_MD5(cpass, strlen(cpass), theResult);
    NSString* m1 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                    theResult[0], theResult[1], theResult[2], theResult[3],
                    theResult[4], theResult[5], theResult[6], theResult[7],
                    theResult[8], theResult[9], theResult[10], theResult[11],
                    theResult[12], theResult[13], theResult[14], theResult[15]];
    NSLog(@"m1 = %@",m1);
    return m1;
    
}


-(void)changepassword{
    NSError* error = nil;
    
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"change_password",@"action_cmd",[self getSeqid],@"seq_id",@{@"tid":self.commondata.token,@"vid":self.commondata.vid,@"old_password":[self CalcPassword:self.oldpassword.text Verifycode:VERIFY_CODE],@"new_password":[self CalcPassword:self.newpassword.text Verifycode:VERIFY_CODE]},@"body", nil];
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
        self.activityindicator.hidden = YES;
        [self.activityindicator stopAnimating];

    });
    if (error) {
        NSLog(@"network error!! try again later");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ChangePasswordError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertview show];
            
        });
        return;
        
    }
    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"change_password result:%@",result);
    NSDictionary* respjson = [NSJSONSerialization
                              JSONObjectWithData:responseData //1
                              options:NSJSONReadingAllowFragments
                              error:&error];
    if (error) {
        NSLog(@"change_password decode json ERROR!!");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ChangePasswordError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertview show];
            
        });
        
        return;
    }
    NSString* errocode = [respjson objectForKey:@"error_code"];
    if (errocode == nil) {
        NSLog(@"change_password has no Errorcode!!");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ChangePasswordError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertview show];
            
        });
        
        return;
        
    }
    if ([errocode isEqualToString:ERROR_CODE_OK]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ChangePasswordOK", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            alertview.tag=10001;
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==10001) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
