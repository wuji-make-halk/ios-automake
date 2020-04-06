//
//  LogfileViewController.m
//  HiMove
//
//  Created by qf on 2017/9/11.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "LogfileViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <Qiniu/QiniuSDK.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "QN_GTM_Base64.h"


@interface LogfileViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView* tableview;
@property (nonatomic,strong)NSMutableArray* fileArr;
@property (nonatomic,strong)NSString* token;
@property (nonatomic,strong)UIButton* btn;
@end

@implementation LogfileViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor =[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initNav];
    self.view.backgroundColor=[UIColor colorWithRed:0xEE/255.0 green:0xEE/255.0 blue:0xEE/255.0 alpha:1];

    self.token = @"";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSDictionary* upinfo = [data objectForKey:@"applog_upload_qiniu"];
    if (upinfo != nil) {
        NSNumber* enable = [upinfo objectForKey:@"enable"];
        if (enable != nil && enable.boolValue == YES) {
            NSString* scope = [upinfo objectForKey:@"scope"];
            NSString* accesskey = [upinfo objectForKey:@"accesskey"];
            NSString* secretkey = [upinfo objectForKey:@"secretkey"];
            self.token = [self createTokenWithScope:scope andAccessKey:accesskey andSecretKey:secretkey];
        }
    }
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-65) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.tableview];
    self.tableview.tableFooterView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
        self.btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame)*0.5, 40)];
        [self.btn setTitle:@"Upload Log" forState:UIControlStateNormal];
        [self.btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.btn addTarget:self action:@selector(onUpload:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:self.btn];
        UIButton* btn1 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.5, 0, CGRectGetWidth(self.view.frame)*0.5, 40)];
        [btn1 setTitle:@"Clear Log" forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(onClear:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn1];
        view;
    });
    [self reload];

    
}
-(void)initNav{
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    UIImageView * backimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 22, 18)];
    backimg.image = [UIImage imageNamed:@"icon_back_white.png"];
    backimg.contentMode = UIViewContentModeScaleAspectFit;
    [btn addSubview:backimg];
    [btn addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectZero];
    label.textColor=[UIColor whiteColor];
    label.text=NSLocalizedString(@"files", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}
-(void)onClickBack:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)onClear:(id)sender{
    if ([self.fileArr count]==0) {
        return;
    }
    [self.fileArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* filename = (NSString*)obj;
        NSFileManager* manager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filepath = [documentsDirectory stringByAppendingPathComponent:filename];
        if([manager isDeletableFileAtPath:filepath]){
            [manager createFileAtPath:filepath contents:[NSData data] attributes:nil];
        }
    }];
    [self reload];
}
-(void)onUpload:(id)sender{
    
    NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [allPaths objectAtIndex:0];
//    NSString *filename = [[NSString stringWithFormat:@"app_%@_%@%@.log",[[IRKCommonData SharedInstance] getPhoneId],[[IRKCommonData SharedInstance] getPhoneOS],[[IRKCommonData SharedInstance] getPhoneType]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appname = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *filename = [[NSString stringWithFormat:@"app%@_%@_%@%@.log",appname,[[IRKCommonData SharedInstance] getPhoneId],[[IRKCommonData SharedInstance] getPhoneOS],[[IRKCommonData SharedInstance] getPhoneType]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *pathForLog = [documentsDirectory stringByAppendingPathComponent:filename];

    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:@"text/plain" progressHandler:^(NSString *key, float percent) {
        [self.btn setTitle:[NSString stringWithFormat:@"%.2f",percent] forState:UIControlStateNormal];
//        NSLog(@"上传进度 %.2f", percent);
    }
                                                                 params:nil
                                                               checkCrc:NO
                                                     cancellationSignal:nil];
    [upManager putFile:pathForLog key:filename token:self.token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        // 发送通知用户获取图片使用
        [self.btn setTitle:@"Upload Log" forState:UIControlStateNormal];
        UIAlertController* ac = [UIAlertController alertControllerWithTitle:nil message:@"Upload OK" preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:ac animated:YES completion:nil];
    }
     
                option:uploadOption];

}

-(void)reload{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.fileArr = [[NSMutableArray alloc] init];
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* filename = (NSString*)obj;
        if([[filename pathExtension] isEqualToString:@"log"]){
            [self.fileArr addObject:filename];
        }
        
    }];
    [self.tableview reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fileArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"file"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"file"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor=[UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
        //        cell.detailTextLabel.textColor=[UIColor whiteColor];
    }
    NSString* filename = [self.fileArr objectAtIndex:indexPath.row];
    cell.textLabel.text = filename;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [documentsDirectory stringByAppendingPathComponent:filename];
    NSDictionary* fileinfo = [manager attributesOfItemAtPath:filepath error:nil];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[fileinfo objectForKey:NSFileSize]];
    cell.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:[[fileinfo objectForKey:NSFileSize] longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
    return cell;

}

//-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString* filename = [self.fileArr objectAtIndex:indexPath.row];
////    [ShareSDK ]
////    NSURL* url = [[NSBundle mainBundle] URLForResource:[filename stringByDeletingPathExtension]  withExtension:[filename pathExtension]];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSURL* url = [NSURL URLWithString:[documentsDirectory stringByAppendingPathComponent:filename]];
//    NSData* data = [NSData dataWithContentsOfFile:url.absoluteString];
//    NSArray* items = @[data];
//    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
//    activity.excludedActivityTypes = @[UIActivityTypeAirDrop];
//    
//    // incorrect usage
//    // [self.navigationController pushViewController:activity animated:YES];
//    
//    UIPopoverPresentationController *popover = activity.popoverPresentationController;
//    if (popover) {
//        popover.sourceView = self.view;
//        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
//    }
//    
//    [self presentViewController:activity animated:YES completion:NULL];
    
// }

-(NSString*)createTokenWithScope:(NSString*)scope andAccessKey:(NSString*)accesskey andSecretKey:(NSString*)secretkey {
    
    if (!scope.length || !accesskey.length || !secretkey.length) {
        return @"";
    }
    
    // 将上传策略中的scrop和deadline序列化成json格式
    NSMutableDictionary *authInfo = [NSMutableDictionary dictionary];
    [authInfo setObject:scope forKey:@"scope"];
    [authInfo
     setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970] + 7 * 24 * 3600]
     forKey:@"deadline"];
    
    NSData *jsonData =
    [NSJSONSerialization dataWithJSONObject:authInfo options:NSJSONWritingPrettyPrinted error:nil];
    
    // 对json序列化后的上传策略进行URL安全的base64编码
    NSString *encodedString = [self urlSafeBase64Encode:jsonData];
    
    // 用secretKey对编码后的上传策略进行HMAC-SHA1加密，并且做安全的base64编码，得到encoded_signed
    NSString *encodedSignedString = [self HMACSHA1:secretkey text:encodedString];
    
    // 将accessKey、encodedSignedString和encodedString拼接，中间用：分开，就是上传的token
    NSString *token =
    [NSString stringWithFormat:@"%@:%@:%@", accesskey, encodedSignedString, encodedString];
    
    return token;
    
}

- (NSString *)urlSafeBase64Encode:(NSData *)text {
    NSString *base64 =
    [[NSString alloc] initWithData:[QN_GTM_Base64 encodeData:text] encoding:NSUTF8StringEncoding];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return base64;
}

- (NSString *)HMACSHA1:(NSString *)key text:(NSString *)text {
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash = [self urlSafeBase64Encode:HMAC];
    return hash;
}
@end
