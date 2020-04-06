//
//  SXRPersonalinfoViewController.m
//  SXRBand
//
//  Created by qf on 14-7-23.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "SXRPersonalinfoViewController.h"
#import "SyncCmdNotifyView.h"
#import "YFTLoginViewController.h"
#import "SXRChangePasswordViewController.h"
#import "HeadImageTableViewCell.h"
#import "IRKCommonData.h"
#import "CommonDefine.h"
#import "FFNavbarMenu.h"


@interface SXRPersonalinfoViewController ()<UITextFieldDelegate,SyncCmdNotifyViewDelegate,FFNavbarMenuDelegate>
@property(nonatomic,strong)KLCPopup* popup;
@property(nonatomic,strong)UIView* notifyView;
@property(nonatomic,strong)FFNavbarMenu *menu;
@property (nonatomic,copy)NSString *birthStr;
@property(nonatomic, strong)UITextField *textField;
@property(nonatomic, strong)UIView* backgroundview;

@end

@implementation SXRPersonalinfoViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self member_update];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.mainloop = [MainLoop SharedInstance];
    self.blecontrol = [BleControl SharedInstance];
    [self initNav];
    [self initcontrol];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidGetHeadimage:) name:notify_key_did_get_headimage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidGetMemberInfo:) name:notify_key_did_get_member_info object:nil];
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
    label.text=NSLocalizedString(@"LeftMenu_Person", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
    
    UIButton * btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImageView * backimg2 = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 25, 25)];
    backimg2.image = [UIImage imageNamed:@"icon_setting_person_menu.png"];
    backimg2.contentMode = UIViewContentModeScaleAspectFit;
    [btn2 addSubview:backimg2];
    [btn2 addTarget:self action:@selector(onClickMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn2];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_setting_person_menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onClickMenu:)];

}

-(void)onClickBack:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initcontrol{
    self.backgroundview = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundview.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-65) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
    self.tableview.tableFooterView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 70)];
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(self.view.frame)-40, 40)];
        [btn setBackgroundColor:[UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if (self.commondata.is_login) {
            [btn setTitle:NSLocalizedString(@"Personinfo_Cell_Loginout", nil) forState:UIControlStateNormal];

        }else{
            [btn setTitle:NSLocalizedString(@"Personinfo_Cell_Loginin", nil) forState:UIControlStateNormal];
        }
        [btn addTarget:self action:@selector(onClickLogin:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4;
        [view addSubview:btn];
        view;
    });
    
    [self.view addSubview:self.tableview];
    FFNavbarMenuItem *item1 = [FFNavbarMenuItem ItemWithTitle:NSLocalizedString(@"Personinfo_Cell_SyncInfo", nil) icon:nil];
    FFNavbarMenuItem *item2 = [FFNavbarMenuItem ItemWithTitle:NSLocalizedString(@"Personinfo_Cell_ChangePassword", nil) icon:nil];

    self.menu = [[FFNavbarMenu alloc] initWithItems:@[item1,item2] width:CGRectGetWidth(self.view.frame) maximumNumberInRow:1];
    self.menu.backgroundColor = [UIColor whiteColor];
    self.menu.separatarColor = [UIColor lightGrayColor];
    self.menu.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
    self.menu.delegate = self;
//    self.menu.
    
}

-(void)onClickLogin:(UIButton*)sender{
    if(self.commondata.is_login){
        [self logout];
    }
    UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[YFTLoginViewController new]];
    
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appdelegate.window.rootViewController = navi;
    [appdelegate.window makeKeyAndVisible];

}

#pragma Headimage picker
-(void)onChangeHeadImage:(UITapGestureRecognizer*)ges{
    if (self.commondata.is_login == NO) {
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Headimg_Title_Login", nil) message:NSLocalizedString(@"Headimg_error_loginfirst", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles: nil];
        [alertview show];
        return;
    }
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"personinfo_Headimg_TakePhoto", nil), NSLocalizedString(@"personinfo_Headimg_Album", nil), nil];
    choiceSheet.tag = 100;
    [choiceSheet showInView:self.view];
}
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}


- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 100) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {}
        else if(buttonIndex == actionSheet.firstOtherButtonIndex){
            //takephoto
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([self isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller animated:YES completion:^(void){NSLog(@"Picker View Controller is presented");}];
            }
        }else{
            //select album
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller animated:YES completion:^(void){NSLog(@"Picker View Controller is presented");}];
            }
        }
    }
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
//        SXRHeadImageMakerViewController *imgEditorVC = [[SXRHeadImageMakerViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        CGFloat x = self.view.center.x - HEADIMAGE_WIDTH/2.0;
        CGFloat y = self.view.center.y - HEADIMAGE_HEIGHT/2.0;
        
        SXRHeadImageMakerViewController *imgEditorVC = [[SXRHeadImageMakerViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(x, y, HEADIMAGE_WIDTH, HEADIMAGE_HEIGHT) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}
#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    CGFloat maxwidth = [UIScreen mainScreen].bounds.size.width;
    
    if (sourceImage.size.width < maxwidth) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = maxwidth;
        btWidth = sourceImage.size.width * (maxwidth / sourceImage.size.height);
    } else {
        btWidth = maxwidth;
        btHeight = sourceImage.size.height * (maxwidth / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(SXRHeadImageMakerViewController *)cropperViewController didFinished:(UIImage *)editedImage {
//    self.portraitImageView.image = editedImage;

//    UIImageView* imageview = [self.tableview viewWithTag:555];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"test.jpg"]];
    NSData* imagedata = UIImageJPEGRepresentation(editedImage, 0);
//    [imagedata writeToFile:filePath atomically:YES];
    
//    imageview.image = editedImage;
    //上传文件
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError* error = nil;
        NSString* base64image = [imagedata base64EncodedStringWithOptions:0];
        
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"user_headimg_upload",@"action_cmd",[self getSeqid],@"seq_id",@{@"tid":self.commondata.token,@"vid":self.commondata.vid,@"uid":self.commondata.uid,@"img":base64image,@"format":@"jpg"},@"body", nil];
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
        NSString *postLength = [NSString stringWithFormat:@"%d",(int)[data length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        //设置http-header:Content-Length
        NSHTTPURLResponse* urlResponse = nil;
        //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        if (error) {
            NSLog(@"network error!! try again later");
//            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Headimg_error", nil) message:NSLocalizedString(@"Headimg_error_network", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles: nil];
            //[alertview show];
            [self saveProfileLocal:imagedata];
            
            return;
        }
        NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"user_add result:%@",result);
        NSDictionary* respjson = [NSJSONSerialization
                                  JSONObjectWithData:responseData //1
                                  options:NSJSONReadingAllowFragments
                                  error:&error];
        if (error) {
            NSLog(@"user_add decode json ERROR!!");
//            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Headimg_error", nil) message:NSLocalizedString(@"Headimg_error_network", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles: nil];
            //[alertview show];
            [self saveProfileLocal:imagedata];
            
            return;
            
        }
        NSString* errocode = [respjson objectForKey:@"error_code"];
        if (errocode == nil) {
            NSLog(@"user_add has no Errorcode!!");
//            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Headimg_error", nil) message:NSLocalizedString(@"Headimg_error_network", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles: nil];
            //[alertview show];
            [self saveProfileLocal:imagedata];
            
            return;
        }
        if ([errocode isEqualToString:ERROR_CODE_OK]) {
            NSMutableDictionary* body = [respjson objectForKey:@"body"];
            if (body == nil) {
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Headimg_error", nil) message:NSLocalizedString(@"Headimg_error_serverexception", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles: nil];
                //[alertview show];
                [self saveProfileLocal:imagedata];
                
                return;
            }
            NSString* img_url = [body objectForKey:@"img_url"];
            if (img_url == nil) {
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Headimg_error", nil) message:NSLocalizedString(@"Headimg_error_serverexception", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles: nil];
               // [alertview show];
                [self saveProfileLocal:imagedata];
                
                return;
            }
            //从服务器获取头像数据
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:img_url]];
                NSString *filename = [NSString stringWithFormat:@"%@.jpg",self.commondata.uid];
//                NSString *imagefilepath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];

                [data writeToFile:filePath atomically:YES];
                self.commondata.has_custom_headimage = YES;
                self.commondata.headimg_url = [filename copy];
                [self.commondata saveconfig];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_headimage object:nil];
                });
                
                
            });
            return;
            
            
        }else if([errocode isEqualToString:ERROR_CODE_TOKENOOS]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self logout];
                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Headimg_Title_Login", nil) message:NSLocalizedString(@"Headimg_error_loginfirst", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles: nil];
                [alertview show];
            });
        }else{
            NSLog(@"error = %@ ",NSLocalizedString(errocode, nil));
//            UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Headimg_error", nil) message:NSLocalizedString(@"Headimg_error_network", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles: nil];
            //[alertview show];
            
            [self saveProfileLocal:imagedata];
           
        }
        

    });
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(SXRHeadImageMakerViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)saveProfileLocal:(NSData *)imagedata
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.commondata.uid]];
    [imagedata writeToFile:filePath atomically:YES];
    self.commondata.has_custom_headimage = YES;
    [self.commondata saveconfig];
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_get_headimage object:nil];
}

///////////////////////////////////////////////////////////////////////
#pragma tabelview delegate









//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 50;
//}

-(void)onClickBtn:(UIButton*)sender{
    NSLog(@"onclickbtn tag=%ld",(long)sender.tag);
}

#pragma custom controller delegate
//ActionsheetCustomDelegate

- (void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView{
    switch (actionSheetPicker.tag) {
        case 400:
            pickerView.tag = 4000;
            if (self.commondata.male == 1) {
                [pickerView selectRow:0 inComponent:0 animated:YES];
            }else{
                [pickerView selectRow:1 inComponent:0 animated:YES];
            }
            break;

        case 401:
            pickerView.tag = 4011;
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                [pickerView selectRow:ceil(self.commondata.height)-1 inComponent:0 animated:YES];
            }else{
//                int totalinch = ceil(self.commondata.height*CM2INCH);
//                float offset = totalinch - self.commondata.height*CM2INCH;
//                if (offset>0.5) {
//                    totalinch = totalinch-1;
//                }
//                int row = totalinch/12-3;
//                if (row<0) {
//                    row = 0;
//                }
                int totalinch = ceil(self.commondata.height*CM2INCH);
                int row = totalinch/12;
                if (row<0) {
                    row = 0;
                }

                [pickerView selectRow:row inComponent:0 animated:YES];
                [pickerView selectRow:totalinch%12 inComponent:1 animated:YES];
            }
            break;
        case 402:
            pickerView.tag = 4022;
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                int row = ceil(self.commondata.weight)-1;
                if (row<0) {
                    row = 0;
                }
                [pickerView selectRow:row inComponent:0 animated:YES];
            }else{
                int row = ceil(self.commondata.weight*KG2LB)-1;
                if (row<0) {
                    row = 0;
                }
                [pickerView selectRow:row inComponent:0 animated:YES];
            }
            break;
        case 403:
            pickerView.tag = 4033;
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                int row = ceil(self.commondata.stride)-1;
                if (row<0) {
                    row = 0;
                }
                [pickerView selectRow:row inComponent:0 animated:YES];
            }else{
                int row = ceil(self.commondata.stride*CM2INCH)-1;
                if (row<0) {
                    row = 0;
                }
                [pickerView selectRow:row inComponent:0 animated:YES];
            }
            break;
        case 405:
            pickerView.tag = 4055;
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                [pickerView selectRow:0 inComponent:0 animated:YES];
            }else{
                [pickerView selectRow:1 inComponent:0 animated:YES];
            }
            break;
            
        default:
            break;
    }
}
- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin{
    switch (actionSheetPicker.tag) {
        case  400:{
            UIPickerView * picker = (UIPickerView *)actionSheetPicker.pickerView;
            if ([picker selectedRowInComponent:0] == 0) {
                self.commondata.male = 1;
            }else{
                self.commondata.male = 2;
            }
            [self.commondata saveconfig];
        }
            break;
        case  401:{
            UIPickerView * picker = (UIPickerView *)actionSheetPicker.pickerView;
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                self.commondata.height = [picker selectedRowInComponent:0]+1;
            }else{
                NSInteger feet = [picker selectedRowInComponent:0];
                NSInteger inch = [picker selectedRowInComponent:1];
                if (self.commondata.measureunit == MEASURE_UNIT_US) {
                    self.commondata.height = floor((feet*12+inch)/CM2INCH);
                }
                
            }
            
            [self.commondata saveconfig];
            break;
        }
        case  402:{
            UIPickerView * picker = (UIPickerView *)actionSheetPicker.pickerView;
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                self.commondata.weight = [picker selectedRowInComponent:0]+1;
            }else{
                self.commondata.weight = floor(([picker selectedRowInComponent:0]+1)/KG2LB);
            }
            [self.commondata saveconfig];
            break;
        }
        case  403:{
            UIPickerView * picker = (UIPickerView *)actionSheetPicker.pickerView;
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                self.commondata.stride = ([picker selectedRowInComponent:0]+1);
            }else{
                self.commondata.stride = floor(([picker selectedRowInComponent:0]+1)/CM2INCH);
            }
            [self.commondata saveconfig];
            break;
        }
        case  405:{
            UIPickerView * picker = (UIPickerView *)actionSheetPicker.pickerView;
            if ([picker selectedRowInComponent:0] == 0) {
                self.commondata.measureunit = MEASURE_UNIT_METRIX;
            }else{
                self.commondata.measureunit = MEASURE_UNIT_US;
            }
            [self.commondata saveconfig];
            break;
        }
            
        default:
            break;
    }
    
    self.commondata.is_memberinfo_change = YES;
    [self.tableview reloadData];
 
}

///////////////////////////////////////////////////////////////////
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (pickerView.tag == 4011) {
        if (self.commondata.measureunit==MEASURE_UNIT_METRIX) {
            return 1;
        }else{
            return 2;
        }
    }
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (pickerView.tag) {
        case 4000:
            return 2;
            break;

        case 4011:
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                return 250;
            }else{
                if (component == 0) {
                    return ceil(250*CM2INCH)/12+1;
//                    return 6;
                }else{
                    return 12;
                }
            }
            break;
        case 4022:
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                return 200;
            }else{
                return ceil(200*KG2LB);
            }
            break;
        case 4033:
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                return 150;
            }else{
                return ceil(150*CM2INCH);
            }
            break;
        case 4055:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (pickerView.tag) {
        case 4000:
            if (row == 0) {
                return NSLocalizedString(@"male", nil);
            }else{
                return NSLocalizedString(@"female", nil);
            }
            break;
            
        case 4011:
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                return [NSString stringWithFormat:@"%d",(int)row+1];
            }else{
                if (component == 0) {
                    return [NSString stringWithFormat:@"%d",(int)row];
                }else{
                    return [NSString stringWithFormat:@"%d",(int)row];
                }
            }
            
            break;
        case 4022:
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                return [NSString stringWithFormat:@"%d",(int)row+1];
            }else{
                return [NSString stringWithFormat:@"%d",(int)row+1];
            }

            break;
        case 4033:
            return [NSString stringWithFormat:@"%d",(int)row+1];
            break;
        case 4055:
            if (row == 0) {
                return NSLocalizedString(@"PersonData_Measureunit_metrix", nil);
            }else{
                return NSLocalizedString(@"PersonData_Measureunit_US", nil);
            }
        default:
            return @"";
            break;
    }
}


///////////////////////////////////////////////////////notify delegate///////////////////
-(NSString*)SXRNotifyView:(SXRNotifyView*)view stringByAction:(NSString*)action{
    if ([action isEqualToString:notify_key_connect_timeout ]){
        return NSLocalizedString(@"sync_connecterr", nil);
    }else if ([action isEqualToString:notify_key_did_finish_send_cmd ]){
        return NSLocalizedString(@"Sync_setpersoninfo_ok", nil);
    }else if ([action isEqualToString:notify_key_did_finish_modeset ]){
        return NSLocalizedString(@"Sync_setpersoninfo_ok", nil);
    }else if ([action isEqualToString:notify_key_did_finish_modeset_err ]){
        return NSLocalizedString(@"ModeSet_Fail", nil);
    }else if ([action isEqualToString:notify_key_did_finish_send_cmd_err ]){
        return NSLocalizedString(@"ModeSet_Fail", nil);
    }else if ([action isEqualToString:notify_band_has_kickoff ]){
        return NSLocalizedString(@"Sync_connected", nil);
    }else if ([action isEqualToString:notify_key_start_set_personinfo ]){
        return NSLocalizedString(@"Sync_setpersoninfo", nil);
    }else{
        return NSLocalizedString(@"Sync_waiting", nil);
    }
}



-(void)logout{
    NSLog(@"logout now");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.commondata.is_login = NO;
        self.commondata.token = @"";
        self.commondata.uid = @"";
        self.commondata.headimg_url = @"";
        self.commondata.has_custom_headimage = NO;
        self.commondata.is_memberinfo_change = NO;
        self.commondata.weight = DEFAULT_WEIGHT;
        self.commondata.height = DEFAULT_HEIGHT;
        self.commondata.stride = DEFAULT_STRIDE;
        self.commondata.birthyear = DEFAULT_BIRTH;
        self.commondata.bloodtype = DEFAULT_BLOODTYPE;
        self.commondata.nickname = @"";
        [self.commondata saveconfig];

        NSError* error = nil;
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"logout",@"action_cmd",[self getSeqid],@"seq_id",@{@"tid":self.commondata.token,@"app_lang":NSLocalizedString(@"GetBackPasswordLang", nil),@"sys_lang":[IRKCommonData getSysLanguage],@"nation":[IRKCommonData getCountryCode],@"nation_code":[IRKCommonData getCountryNum],@"mac_id":self.commondata.current_macid,@"phone_id":[self.commondata getPhoneId],@"phone_os":[self.commondata getPhoneOS],@"phone_name":[self.commondata getPhoneName],@"device_name":[self getDeviceName],@"phone_type":[self.commondata getPhoneType],@"vid":self.commondata.vid},@"body", nil];
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
        NSString *postLength = [NSString stringWithFormat:@"%d",(int)[data length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        //设置http-header:Content-Length
        NSHTTPURLResponse* urlResponse = nil;
        //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        if (error) {
            NSLog(@"network error!! try again later");
        }
        return;
    });
}

-(void)member_update{
    if (self.commondata.is_login && self.commondata.is_memberinfo_change) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSError* error = nil;
            NSString* name = [self.commondata.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString* gender;
            if (self.commondata.male == 1) {
                gender = @"1";
            }else{
                gender = @"2";
            }
            if (self.commondata.token == nil) {
                return;
            }
            if (self.commondata.birthyear == nil) {
                self.commondata.birthyear = DEFAULT_BIRTH;
            }
            
            NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:PROTOCOL_VERSION,@"version",@"user_update",@"action_cmd",[self getSeqid],@"seq_id",@{@"tid":self.commondata.token,@"vid":self.commondata.vid,@"uid":self.commondata.uid,@"name":name,@"gender":gender,@"height":[NSString stringWithFormat:@"%.1f",self.commondata.height],@"weight":[NSString stringWithFormat:@"%.1f",self.commondata.weight],@"stride":[NSString stringWithFormat:@"%.1f",self.commondata.stride ],@"bloodtype":self.commondata.bloodtype,@"birth":self.commondata.birthyear,@"unit":[NSNumber numberWithInt:(int)self.commondata.measureunit]},@"body", nil];
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
            NSString *postLength = [NSString stringWithFormat:@"%d",(int)[data length]];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            //设置http-header:Content-Length
            NSHTTPURLResponse* urlResponse = nil;
            //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
            if (error) {
                NSLog(@"network error!! try again later");
                return;
            }
            NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"user_update result:%@",result);
            NSDictionary* respjson = [NSJSONSerialization
                                      JSONObjectWithData:responseData //1
                                      options:NSJSONReadingAllowFragments
                                      error:&error];
            if (error) {
                NSLog(@"user_update decode json ERROR!!");
                return;
                
            }
            NSString* errocode = [respjson objectForKey:@"error_code"];
            if (errocode == nil) {
                NSLog(@"user_update has no Errorcode!!");
                //使用默认数据
                return;
            }
            if ([errocode isEqualToString:ERROR_CODE_OK]) {
                self.commondata.is_memberinfo_change = NO;
                [self.commondata saveconfig];
                
            }else if([errocode isEqualToString:ERROR_CODE_TOKENOOS]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //通知用户需要登陆
                    [self notifyOOS];
                    
                });
            }else{
                NSLog(@"error = %@ ",NSLocalizedString(errocode, nil));
            }
            return;
        });
    }
}

-(void)notifyOOS{
    [self logout];
    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login_Error", nil) message:NSLocalizedString(ERROR_CODE_TOKENOOS, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alertview show];
}

-(void)onSyncFinish:(NSNotification*)notify{
    NSLog(@"::::::::::::notify = %@",notify);
    [self.popup dismissPresentingPopup];
    self.popup = nil;
    self.notifyView = nil;
}

-(void)SyncCmdNotifyViewClickBackBtn:(SyncNotifyView *)view{
    if (self.popup) {
        [self.popup dismissPresentingPopup];
    }
}

#pragma mark --------TextField Method--------
-(void)onChangeName:(UITextField*)sender{
    self.commondata.nickname = sender.text;
    self.commondata.is_memberinfo_change = YES;
    [self.commondata saveconfig];
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_modify_nickname object:nil];
}

-(void)ondidEndEdit:(UITextField*)sender{
    self.commondata.nickname = sender.text;
    [sender resignFirstResponder];
    self.commondata.is_memberinfo_change = YES;
    [self.commondata saveconfig];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.tableview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    _textField = textField;
    CGRect frame = textField.frame;
    frame.origin.y = 50 * 5;
    int offset = 20 + frame.origin.y + frame.size.height*1.5 - (self.view.frame.size.height - 216);//键盘高度216
    if(offset > 216)
        offset = 216;
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.tableview.frame = CGRectMake(0.0f, -offset, self.tableview.frame.size.width, self.tableview.frame.size.height);
    [UIView commitAnimations];
}
//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.tableview.frame =CGRectMake(0, 0, self.tableview.frame.size.width, self.tableview.frame.size.height);
}
//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    switch (textField.tag) {
            
        case 1010:{
            ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"Personinfo_Cell_Height", nil) delegate:self showCancelButton:YES origin:self.view];
            ap.tag = 401;
            [ap showActionSheetPicker];
            return NO;
        }
            break;
        case 1020:{
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX)
            {
                ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"Personinfo_Cell_Weight", nil) delegate:self showCancelButton:YES origin:self.view];
                ap.tag = 402;
                [ap showActionSheetPicker];
                
                return NO;
            }
            else
            {
                _textField.text = [NSString stringWithFormat:@"%.1f",self.commondata.weight * KG2LB];
                return YES;
            }
        }
            break;
        case 1030:{
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX){
                textField.text = [NSString stringWithFormat:@"%.1f",self.commondata.stride];
            }else{
                textField.text = [NSString stringWithFormat:@"%.1f",self.commondata.stride*CM2INCH];
            }
            return YES;
        }
            break;
        default: break;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField.tag == 1020 || textField.tag == 1030)
        return [self validateNumber:string];
    return YES;
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if(textField.tag == 1020){
        self.commondata.weight = textField.text.floatValue / KG2LB;
        [self.commondata saveconfig];
        
        //主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
            
        });
    }
    else if(textField.tag == 1030){
        if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
            self.commondata.stride = textField.text.floatValue;
        }else{
            self.commondata.stride = textField.text.floatValue / CM2INCH;
        }
        
        [self.commondata saveconfig];
        
        //主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
            
        });
    }
    return YES;
}



#pragma mark --------TableView Method--------
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 60;
    }else{
        return 50;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) return 1;
    else if (section==1) return 5;
    else return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSString* simple = @"simple";
    NSString* headcell = @"headcell";
//    NSString* btncell = @"btncell";
    CGFloat textfieldwidth = 180;
    UIColor* titlecolor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
    UIColor* contentcolor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
    CGFloat cellheigt = 50;
    UIFont* cellfont = [self.commondata getFontbySize:20 isBold:NO];
    if (section == 0){
        switch (row){
            case 0:{
                HeadImageTableViewCell *cell = (HeadImageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:headcell];
                if (cell == nil) {
                    cell = [[HeadImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headcell];
                }
                cell.backgroundColor = [UIColor whiteColor];
                cell.imageView.image = [self.commondata getHeadimage];
                
                cell.textLabel.text = [NSString stringWithFormat:@"%@ >",NSLocalizedString(@"change_avata", nil)];
                cell.textLabel.textAlignment = NSTextAlignmentRight;
                cell.textLabel.textColor = contentcolor;
//                cell.textLabel.font = cellfont;
//                UILabel* text_value = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 60)];
//                text_value.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
//                text_value.text = [NSString stringWithFormat:@"%@ >",NSLocalizedString(@"change_avata", nil)];
//                cell.textLabel.font = cellfont;
//                cell.textLabel.numberOfLines = 0;
//                cell.textLabel.minimumScaleFactor = 0.5;
//                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.tag = 110;
//                cell.accessoryView = text_value;
                return cell;
            } break;
            default:
                return nil;
                break;
        }
    }else if(section == 1){
        switch (row) {
             case 0:{
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:simple];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simple];
                }
                cell.textLabel.text = NSLocalizedString(@"Personinfo_Nickname", nil);
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.textColor = titlecolor;
                cell.backgroundColor = [UIColor whiteColor];
                
                UITextField* text_value = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, textfieldwidth, cellheigt)];
                text_value.textAlignment = NSTextAlignmentRight;
                text_value.returnKeyType = UIReturnKeyDone;
                text_value.delegate = self;
                text_value.textColor = contentcolor;
                text_value.adjustsFontSizeToFitWidth = YES;
                text_value.minimumFontSize = 0.5;
//                text_value.placeholder = NSLocalizedString(@"Input_yournickname", nil);
                [text_value addTarget:self action:@selector(ondidEndEdit:) forControlEvents:UIControlEventEditingDidEndOnExit];
                [text_value addTarget:self action:@selector(onChangeName:) forControlEvents:UIControlEventEditingChanged];
                cell.textLabel.font = cellfont;
                text_value.font = cellfont;
                
                cell.tag = 111;
                if (![self.commondata.nickname isEqualToString:@""]) {
                    text_value.text = self.commondata.nickname;
                }
//                NSString *str=NSLocalizedString(@"Default_Nickname", nil);
//                NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc]initWithString:str];
//                [attributedString addAttribute:NSForegroundColorAttributeName value:contentcolor range:NSMakeRange(0, str.length)];
//                
//                text_value.attributedPlaceholder=attributedString;
                cell.accessoryView = text_value;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.minimumScaleFactor = 0.5;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                text_value.tag = 1110;
                return cell;
            } break;
            case 1:{
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:simple];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simple];
                }
                cell.textLabel.text = NSLocalizedString(@"Personinfo_Cell_Gender", nil);
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.textColor = titlecolor;
                cell.backgroundColor = [UIColor whiteColor];
                
                UILabel* text_value = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textfieldwidth, cellheigt)];
                text_value.textAlignment = NSTextAlignmentRight;
                text_value.textColor = contentcolor;
                
                cell.tag = 100;
                if (self.commondata.male == 1){
                    text_value.text = NSLocalizedString(@"male", nil);
                }else{
                    text_value.text = NSLocalizedString(@"female", nil);
                }
                cell.textLabel.font = cellfont;
                text_value.font = cellfont;
                cell.accessoryView = text_value;
                cell.tag = 100;
                text_value.tag = 1000;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.minimumScaleFactor = 0.5;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                return cell;
            } break;
            case 2:{
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:simple];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simple];
                }
                cell.textLabel.text = NSLocalizedString(@"Personinfo_Cell_Height", nil);
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.textColor = titlecolor;
                cell.backgroundColor = [UIColor whiteColor];
                
                UITextField* text_value = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, textfieldwidth, cellheigt)];
                text_value.textAlignment = NSTextAlignmentRight;
                text_value.returnKeyType = UIReturnKeyDone;
                text_value.delegate = self;
                text_value.textColor = contentcolor;
                cell.textLabel.font = cellfont;
                text_value.font = cellfont;
                
                if (self.commondata.measureunit == MEASURE_UNIT_METRIX){
                    text_value.text = [NSString stringWithFormat:@"%.0f%@",self.commondata.height,NSLocalizedString(@"UNIT_CM", nil)];
                }else{
                    int totalinch = ceil(self.commondata.height*CM2INCH);
                    text_value.text = [NSString stringWithFormat:@"%d%@%d%@",totalinch/12,NSLocalizedString(@"UNIT_FEET", nil),totalinch%12,NSLocalizedString(@"UNIT_INCH", nil)];
                    
                }
                cell.accessoryView = text_value;
                text_value.delegate = self;
                cell.tag = 101;
                text_value.tag = 1010;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.minimumScaleFactor = 0.5;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                return cell;
            } break;
            case 3:{
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:simple];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simple];
                }
                cell.textLabel.text = NSLocalizedString(@"Personinfo_Cell_Weight", nil);
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.backgroundColor = [UIColor whiteColor];
                cell.textLabel.textColor = titlecolor;
                
                UITextField* text_value = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, textfieldwidth, cellheigt)];
                
                _textField = text_value;
                
                text_value.returnKeyType = UIReturnKeyDone;
//                text_value.keyboardType = 
                text_value.textAlignment = NSTextAlignmentRight;
                text_value.delegate = self;
                text_value.textColor = contentcolor;
                cell.textLabel.font = cellfont;
                text_value.font = cellfont;
                
                if (self.commondata.measureunit == MEASURE_UNIT_METRIX){
                    text_value.text = [NSString stringWithFormat:@"%.1f%@",self.commondata.weight,NSLocalizedString(@"UNIT_KG", nil)];
                }else{
                    
                    //text_value.text = [NSString stringWithFormat:@"%.0f%@",ceil(self.commondata.weight*KG2LB),NSLocalizedString(@"UNIT_LBS", nil)];
                    text_value.text = [NSString stringWithFormat:@"%.1f%@",self.commondata.weight*KG2LB,NSLocalizedString(@"UNIT_LBS", nil)];
                }
                cell.accessoryView = text_value;
                text_value.delegate = self;
                cell.tag = 102;
                text_value.tag = 1020;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.minimumScaleFactor = 0.5;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                return cell;
            } break;

            case 4:{
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:simple];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simple];
                }
                cell.textLabel.text = NSLocalizedString(@"Personinfo_Cell_Birthday", nil);
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.textColor = titlecolor;
                cell.backgroundColor = [UIColor whiteColor];
                
                UILabel* text_value = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textfieldwidth, cellheigt)];
                text_value.textAlignment = NSTextAlignmentRight;
                text_value.textColor = contentcolor;
                cell.textLabel.font = cellfont;
                text_value.font = cellfont;
                NSDateFormatter* format = [[NSDateFormatter alloc] init];
                format.dateFormat = @"yyyy-MM-dd";
                NSDate* date = [format dateFromString:self.commondata.birthyear];
                format.dateFormat = @"dd-MM-yyyy";
                _birthStr = [format stringFromDate:date];
                text_value.text = _birthStr;
                //                NSLog(@"--------%@",self.commondata.birthyear);
                //                text_value.text = self.commondata.birthyear;
                cell.accessoryView = text_value;
                cell.tag = 104;
                text_value.tag = 1040;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.minimumScaleFactor = 0.5;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                return cell;
            } break;
                
            default:
                return nil;
                break;
        }
    }else if(section == 2){
        switch (row) {
            case 0:{
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:simple];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simple];
                }
                cell.textLabel.text = NSLocalizedString(@"Personinfo_Cell_Stride", nil);
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.textColor = titlecolor;
                cell.backgroundColor = [UIColor whiteColor];
                
                UITextField* text_value = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, textfieldwidth, cellheigt)];
                text_value.returnKeyType = UIReturnKeyDone;
                text_value.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                text_value.delegate = self;
                text_value.textAlignment = NSTextAlignmentRight;
                text_value.textColor = contentcolor;
                cell.textLabel.font = cellfont;
                text_value.font = cellfont;
                
                if (self.commondata.measureunit == MEASURE_UNIT_METRIX){
                    text_value.text = [NSString stringWithFormat:@"%.1f%@",self.commondata.stride,NSLocalizedString(@"UNIT_CM", nil)];
                }else{
                    text_value.text = [NSString stringWithFormat:@"%.1f%@",self.commondata.stride*CM2INCH,NSLocalizedString(@"UNIT_INCH", nil)];
                }
                cell.accessoryView = text_value;
                text_value.delegate = self;
                cell.tag = 103;
                text_value.tag = 1030;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.minimumScaleFactor = 0.5;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                return cell;
            } break;
            case 1:{
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:simple];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simple];
                }
                cell.textLabel.text = NSLocalizedString(@"PersonData_Measureunit", nil);
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.textColor = titlecolor;
                cell.backgroundColor = [UIColor whiteColor];
                
                UILabel* text_value = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textfieldwidth, cellheigt)];
                text_value.textAlignment = NSTextAlignmentRight;
                text_value.textColor = contentcolor;
                if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
                    text_value.text = NSLocalizedString(@"PersonData_Measureunit_metrix", nil);
                }else{
                    text_value.text = NSLocalizedString(@"PersonData_Measureunit_US", nil);
                }
                cell.textLabel.font = cellfont;
                text_value.font = cellfont;
                cell.accessoryView = text_value;
                cell.tag = 105;
                text_value.tag = 1050;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.minimumScaleFactor = 0.5;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                return cell;
            } break;
            default:
                break;
        }
    }
//    }else{
//        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:btncell];
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:btncell];
//        }
//        cell.backgroundColor = [UIColor clearColor];
//        NSMutableParagraphStyle* p = [NSMutableParagraphStyle new];
//        p.alignment = NSTextAlignmentCenter;
//        switch (section) {
//            case 1:{
//                switch (row) {
//                    case 0:{
//                        NSAttributedString *str = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Personinfo_Cell_SyncInfo", nil) attributes:@{NSFontAttributeName: [self.commondata getFontbySize:18 isBold:NO], NSParagraphStyleAttributeName: p, NSForegroundColorAttributeName:[UIColor whiteColor]}];
//                        cell.backgroundColor = [UIColor colorWithRed:0x74/255.0 green:0xb7/255.0 blue:0xec/255.0 alpha:1];
//                        cell.textLabel.textColor = [UIColor whiteColor];
//                        cell.textLabel.adjustsFontSizeToFitWidth = YES;
//                        cell.textLabel.minimumScaleFactor = 0.5;
//                        cell.textLabel.numberOfLines = 0;
//                        cell.tag = 106;
//                        cell.textLabel.attributedText = str;
//                        cell.textLabel.numberOfLines = 0;
//                        cell.textLabel.minimumScaleFactor = 0.5;
//                        cell.textLabel.adjustsFontSizeToFitWidth = YES;
//                        return cell;
//                    } break;
//                    default: break;
//                }
//            } break;
//            case 2:{
//                switch (row) {
//                    case 0:{
//                        NSAttributedString *str = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Personinfo_Cell_ChangePassword", nil) attributes:@{NSFontAttributeName: [self.commondata getFontbySize:18 isBold:NO], NSParagraphStyleAttributeName: p}];
//                        cell.backgroundColor = [UIColor colorWithRed:0x74/255.0 green:0xb7/255.0 blue:0xec/255.0 alpha:1];
//                        cell.textLabel.textColor = [UIColor whiteColor];
//                        cell.tag = 108;
//                        cell.textLabel.attributedText = str;
//                        cell.textLabel.adjustsFontSizeToFitWidth = YES;
//                        cell.textLabel.minimumScaleFactor = 0.5;
//                        cell.textLabel.numberOfLines = 0;
//                        cell.textLabel.numberOfLines = 0;
//                        cell.textLabel.minimumScaleFactor = 0.5;
//                        cell.textLabel.adjustsFontSizeToFitWidth = YES;
//                        return cell;
//                    } break;
//                    default: break;
//                }
//            }
//            case 3:{
//                switch (row) {
//                    case 0:{
//                        NSAttributedString *str;
//                        if (self.commondata.is_login) {
//                            str = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Personinfo_Cell_Loginout", nil) attributes:@{NSFontAttributeName: [self.commondata getFontbySize:18 isBold:NO], NSParagraphStyleAttributeName: p, NSForegroundColorAttributeName:[UIColor whiteColor]}];
//                        }else{
//                            str = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Personinfo_Cell_Loginin", nil) attributes:@{NSFontAttributeName: [self.commondata getFontbySize:18 isBold:NO], NSParagraphStyleAttributeName: p, NSForegroundColorAttributeName:[UIColor whiteColor]}];
//                        }
//                        cell.backgroundColor = [UIColor orangeColor];
//                        cell.tag = 107;
//                        cell.textLabel.attributedText = str;
//                        cell.textLabel.adjustsFontSizeToFitWidth = YES;
//                        cell.textLabel.minimumScaleFactor = 0.5;
//                        cell.textLabel.numberOfLines = 0;
//                        cell.textLabel.numberOfLines = 0;
//                        cell.textLabel.minimumScaleFactor = 0.5;
//                        cell.textLabel.adjustsFontSizeToFitWidth = YES;
//                        return cell;
//                    } break;
//                    default: break;
//                }
//            } break;
//            default: break;
//        }
//    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case 110: [self onChangeHeadImage:nil]; break;
        case 100:{
            ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"Personinfo_Cell_Gender", nil) delegate:self showCancelButton:YES origin:self.view];
            ap.tag = 400;
            [ap showActionSheetPicker];
        } break;
        case 101:{
            ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"Personinfo_Cell_Height", nil) delegate:self showCancelButton:YES origin:self.view];
            ap.tag = 401;
            [ap showActionSheetPicker];
        } break;
        case 102:{
            if (self.commondata.measureunit == MEASURE_UNIT_METRIX){
                ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"Personinfo_Cell_Weight", nil) delegate:self showCancelButton:YES origin:self.view];
                ap.tag = 402;
                [ap showActionSheetPicker];
            }
        } break;
        case 103: break;
        case 104:{
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
            format.dateFormat = @"yyyy-MM-dd 00:00:00";
            NSDate* date = [format dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",self.commondata.birthyear]];
            ActionSheetDatePicker *ap = [[ActionSheetDatePicker alloc] initWithTitle:NSLocalizedString(@"Personinfo_Cell_Birthday", nil) datePickerMode:UIDatePickerModeDate selectedDate:date doneBlock:^(ActionSheetDatePicker *picker, NSDate *selectedDate, id origin) {
                NSDateFormatter* format = [[NSDateFormatter alloc] init];
                //                [format setTimeStyle:NSDateFormatterNoStyle];
                //                [format setDateStyle:NSDateFormatterMediumStyle];
                format.dateFormat = @"yyyy-MM-dd";
                self.commondata.birthyear = [format stringFromDate:selectedDate];
//                NSLog(@"========%@",self.commondata.birthyear);
                self.commondata.is_memberinfo_change = YES;
                [self.commondata saveconfig];
                [self.tableview reloadData];
            } cancelBlock:nil origin:self.view];
            [ap showActionSheetPicker];
        } break;
        case 105:{
            ActionSheetCustomPicker* ap = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"PersonData_Measureunit", nil) delegate:self showCancelButton:YES origin:self.view];
            ap.tag = 405;
            [ap showActionSheetPicker];
        } break;
//        case 106:{
//            if(self.blecontrol.is_connected != IRKConnectionStateConnected){
//                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Sync_connect_first", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil] show];
//                return NO;
//            }
//            SXRNotifyView* syncview = [[SXRNotifyView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
//            syncview.delegate = self;
//            KLCPopup* popup = [KLCPopup popupWithContentView:syncview showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeSlideOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
//            [popup show];
//            [self.mainloop StartSetPersonInfo];
//            [self.mainloop StartSetScreenTime];
//            //同时同步到网络
//            if (self.commondata.is_memberinfo_change) {
//                [self member_update];
//            }
//            
//        }
//            
//            break;
        case 107:{
            if(self.commondata.is_login){
                [self logout];
            }
            UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:[YFTLoginViewController new]];
            
            AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            appdelegate.window.rootViewController = navi;
            [appdelegate.window makeKeyAndVisible];
        } break;
//        case 108:{
//            if(!self.commondata.is_login){
//                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ChangePasswordError", nil) message:NSLocalizedString(@"Headimg_error_loginfirst", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//                [alertview show];
//                return NO;
//            }else{
//                [self.navigationController pushViewController:[SXRChangePasswordViewController new] animated:nil];
//            }
//        } break;
        default:
            break;
    }
    
    return  NO;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 4.5;
}
#pragma mark --------Auxiliary Method--------
-(NSString*)getSeqid{
    return [NSString stringWithFormat:@"%d", arc4random()/10000000];
}

-(NSString*)getVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *label = [NSString stringWithFormat:@"%@ v%@ (build %@)", name, version, build];
    return label;
}

-(NSString*)getDeviceName{
    CBPeripheral* currentperipheral = [self.blecontrol.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
    if (currentperipheral) {
        return [currentperipheral.name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }else{
        return NSLocalizedString(@"Gear_Unknown", nil);
    }
}
#pragma mark --------Notification Method--------
-(void)onDidGetHeadimage:(NSNotification*)notify{
    [self.tableview reloadData];
    return;
    
    UIImageView* headview = (UIImageView*)[self.tableview.tableHeaderView viewWithTag:555];
    if (headview) {
        NSString *filename = [NSString stringWithFormat:@"%@.jpg",self.commondata.uid];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
        UIImage * image = [UIImage imageWithContentsOfFile:filePath];
        if (image) {
            headview.image = image;
            [self.tableview reloadData];
        }
        
    }
    
}
-(void)onDidGetMemberInfo:(NSNotification*)notify{
    NSLog(@"onDidGetMemberInfo");
    [self.tableview reloadData];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)onClickMenu:(UIButton*)sender{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.menu.isOpen) {
        [self.menu dismissWithAnimation:YES];
        [self.backgroundview removeFromSuperview];
    } else {
        [self.view addSubview:self.backgroundview];
        [self.menu showInNavigationController:self.navigationController];
    }
    
}
- (void)didSelectedMenu:(FFNavbarMenu *)menu atIndex:(NSInteger)index {
     switch (index) {
        case 0:{
            if(self.blecontrol.is_connected != IRKConnectionStateConnected){
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"Sync_connect_first", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil] show];
                return;
            }
            SXRNotifyView* syncview = [[SXRNotifyView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
            syncview.delegate = self;
            KLCPopup* popup = [KLCPopup popupWithContentView:syncview showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeSlideOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
            [popup show];
            [self.mainloop StartSetPersonInfo];
            [self.mainloop StartSetScreenTime];
            //同时同步到网络
            if (self.commondata.is_memberinfo_change) {
                [self member_update];
            }
            
        }
        
            break;
        case 1:{
            if(!self.commondata.is_login){
                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ChangePasswordError", nil) message:NSLocalizedString(@"Headimg_error_loginfirst", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alertview show];
                return;
            }else{
                [self.navigationController pushViewController:[SXRChangePasswordViewController new] animated:NO];
            }

        }
            break;
        default:
            break;
    }
}
- (void)didShowMenu:(FFNavbarMenu *)menu {
//    [self.navigationItem.rightBarButtonItem setTitle:@"隐藏"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(FFNavbarMenu *)menu {
//    [self.navigationItem.rightBarButtonItem setTitle:@"菜单"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.backgroundview removeFromSuperview];
}
@end
