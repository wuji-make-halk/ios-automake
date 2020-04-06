//
//  FRAboutViewController.m
//  SXRBand
//
//  Created by qf on 16/4/19.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "FRAboutViewController.h"
#import "LogfileViewController.h"


@interface FRAboutViewController ()

@property (nonatomic, strong) UIButton *showView;

@end

@implementation FRAboutViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor =[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    [self initNav];
    [self initcontrol];
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
    label.text=NSLocalizedString(@"About_Title", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}
-(void)onClickBack:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initcontrol{
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-64) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-64)];
        UIImageView *iconimg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.4, 60, CGRectGetWidth(self.view.frame)*0.2, CGRectGetWidth(self.view.frame)*0.2)];
        iconimg.image = [UIImage imageNamed:@"icon_about_logo.png"];
        iconimg.contentMode = UIViewContentModeScaleAspectFill;
        [view addSubview:iconimg];
        UILabel* version = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iconimg.frame)+40, CGRectGetWidth(self.view.frame), 20)];
        version.text = [self getVersion];
        version.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];;
        version.textAlignment = NSTextAlignmentCenter;
        version.font = [self.commondata getFontbySize:14 isBold:NO];
        [view addSubview:version];
        
        UILongPressGestureRecognizer* gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
//        gesture.numberOfTapsRequired = 1;
        gesture.minimumPressDuration = 2;
//        gesture.allowableMovement = YES;
        [iconimg addGestureRecognizer:gesture];
        iconimg.userInteractionEnabled = YES;
        
        UILabel* sw = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(version.frame)+20, CGRectGetWidth(self.view.frame), 20)];
        sw.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Firmware", nil)];
        sw.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];;
        sw.textAlignment = NSTextAlignmentCenter;
        sw.font = [self.commondata getFontbySize:14 isBold:NO];
        [view addSubview:sw];
        
        UILabel* fw = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(sw.frame)+20, CGRectGetWidth(self.view.frame), 20)];
        fw.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];;
        fw.textAlignment = NSTextAlignmentCenter;
        fw.font = [self.commondata getFontbySize:14 isBold:NO];
        NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
        NSString* fwinfo = [bonginfo objectForKey:BONGINFO_KEY_FIRMWARE];
        if (fwinfo) {
            fw.text = [fwinfo stringByReplacingOccurrencesOfString:@"WDB" withString:@"W"];
        }
        else  fw.text = @"V00?";
        [view addSubview:fw];
        
//        //增加更新按钮
//        CGFloat btnWidth = CGRectGetWidth(self.view.frame) / 1.3;
//        CGFloat btnX = (CGRectGetWidth(self.view.frame) - btnWidth) / 2.0;
//        CGFloat btnY = CGRectGetMaxY(fw.frame)+10;
//        UIButton *btnUpdate = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, 45)];
//        btnUpdate.backgroundColor=[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
//        [btnUpdate setTitle:NSLocalizedString(@"Check_for_updates", nil) forState:UIControlStateNormal];
//        [btnUpdate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        btnUpdate.titleLabel.font = [self.commondata getFontbySize:17 isBold:NO];
//        btnUpdate.layer.cornerRadius = 5;
//        [btnUpdate addTarget:self action:@selector(onClickUpdate) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:btnUpdate];
//        
//        NSLog(@"%f",CGRectGetMaxY(iconimg.frame));
//        NSLog(@"%f",CGRectGetMinY(btnUpdate.frame) - CGRectGetMaxY(iconimg.frame));
//        
//        CGFloat viewX = CGRectGetWidth(self.view.frame) * 0.15;
//        _showView = [[UIButton alloc] initWithFrame:CGRectMake(viewX, CGRectGetMinY(fw.frame) , CGRectGetWidth(self.view.frame) * 0.7, 65)];
//        _showView.layer.cornerRadius = 15;
//        _showView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.9];
//        _showView.titleLabel.numberOfLines = 0;
//        [_showView setTitle:NSLocalizedString(@"last_version_tip_title", nil) forState:UIControlStateNormal];
//        [_showView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [view addSubview:_showView];
//        _showView.hidden = YES;
        view;
    });
    [self.view addSubview:self.tableview];
}

-(void)onLongPress:(UILongPressGestureRecognizer*)ges{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSDictionary* upinfo = [data objectForKey:@"applog_upload_qiniu"];
    if (upinfo != nil) {
        NSNumber* enable = [upinfo objectForKey:@"enable"];
        if (enable != nil && enable.boolValue == YES) {
            UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[LogfileViewController new]];
            [self presentViewController:navi animated:YES completion:nil];

        }
    }

}

- (void)onClickUpdate{
    _showView.hidden = NO;
    [self performSelector:@selector(hideView) withObject:nil afterDelay:1.5];
}

- (void)hideView{
    _showView.hidden = YES;
}

-(NSString*)getVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *label = [NSString stringWithFormat:@"%@ v%@ (build %@)", name, version, build];
    return label;
}
///////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }
    else {
        return 2;
    }
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return YES;
    }
    return  NO;
}

/*
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 return 60;
 }
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    static NSString* simplecell = @"simpel";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:simplecell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simplecell];
    }
    
    if (section == 0){
        switch (row){
            case 0:{
                cell.textLabel.text = NSLocalizedString(@"About_Software_license", nil);
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.backgroundColor = [UIColor clearColor];
                cell.tag = 100;
                return cell;
            }
                break;
            case 1:{
                cell.textLabel.text = NSLocalizedString(@"About_Data_Protocol", nil);
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.backgroundColor = [UIColor clearColor];
                cell.tag = 101;
                return cell;
                
            }
                break;
                
            default:
                break;
        }
        
    }else{
        switch (row) {
            case 0:{
                cell.backgroundColor = [UIColor clearColor];
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.text = NSLocalizedString(@"About_Studio_name", nil);
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.tag = 102;
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 10)];
                label.textAlignment = NSTextAlignmentRight;
                label.textColor = [UIColor lightGrayColor];
                label.font = [UIFont systemFontOfSize:10];
                label.text = NSLocalizedString(@"About_Studio_name_value", nil);
                cell.accessoryView = label;
                return cell;
            }
                break;
            case 1:{
                cell.backgroundColor = [UIColor clearColor];
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.text = NSLocalizedString(@"About_Contact_us", nil);
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.tag = 103;
                UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 12)];
                UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0,0,160,12)];
                [button setTitle:NSLocalizedString(@"About_Studio_email", nil) forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                button.titleLabel.textAlignment = NSTextAlignmentRight;
                [button addTarget:self action:@selector(sendMailInApp) forControlEvents:UIControlEventTouchUpInside];
                button.titleLabel.font = [UIFont systemFontOfSize:11];
                [view addSubview:button];
                
                cell.accessoryView = view;
                return cell;
            }
                break;
                
                
            default:
                return cell;
                break;
        }
        
    }
    return nil;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //    return 2;
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //该方法响应列表中行的点击事件
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case 100:
            [self performSegueWithIdentifier:@"SoftwareSegue" sender:nil];
            break;
        case 101:
            [self performSegueWithIdentifier:@"DataProtocolSegue" sender:nil];
            break;
            
        default:
            break;
    }
}
/////////////////////////////////////////////
- (void)sendMailInApp
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tip_Error", nil) message:NSLocalizedString(@"About_Email_error1", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (![mailClass canSendMail]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tip_Error", nil)  message:NSLocalizedString(@"About_Email_error2", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];
        return;
    }
    [self displayMailPicker];
}

//调出邮件发送窗口
- (void)displayMailPicker
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"your subject"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: NSLocalizedString(@"About_Studio_email", nil)];
    [mailPicker setToRecipients: toRecipients];
    
    NSString *emailBody = @"";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentModalViewController: mailPicker animated:YES];
}

#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
