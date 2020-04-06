//
//  SXRPhoto2ViewController.m
//  SXRBand
//
//  Created by qf on 15/9/29.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import "SXRPhoto2ViewController.h"
#import "WJPhotoTool.h"
#import "SXRShowPhotoViewController.h"
#import "HMTabBarController.h"

@interface SXRPhoto2ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property(strong, nonatomic)UIButton* btn_flash;
@property(strong, nonatomic)UIButton* btn_switchcamera;
@property(strong, nonatomic)UIButton* btn_capture;
@property(strong, nonatomic)UISegmentedControl* btn_capturetype;

@property(strong, nonatomic)UIImageView* thumbnail;
@property(strong, nonatomic)UILabel* label_timer;
@property(nonatomic)UIImagePickerController* picker;
@property(strong, nonatomic)UIView* overlay;
@property(assign, nonatomic)BOOL isFront;

@property(assign, nonatomic)BOOL isStartVideo;
@property(assign, nonatomic)BOOL isFlashOn;
@property(assign, nonatomic)BOOL showFlash;
@property(assign, nonatomic)BOOL showSwitch;
@property(strong, nonatomic)UIButton* btn_back;
@property(assign, nonatomic)double timeval;
@property(strong, nonatomic)NSTimer* counttimer;

@property(strong, nonatomic)UIButton* btnPhoto;
@end

@implementation SXRPhoto2ViewController

-(void)viewWillAppear:(BOOL)animated{
    [self refreshUI];
}

-(void)viewWillDisappear:(BOOL)animated{

}
-(void)refreshUI{
    if (self.showFlash) {
        self.btn_flash.alpha = 1.0;
    }else{
        self.btn_flash.alpha = 0;
    }
    if (self.showSwitch) {
        self.btn_switchcamera.alpha = 1.0;
    }else{
        self.btn_switchcamera.alpha = 0;
    }
    
    if (self.isFlashOn) {
        self.btn_flash.selected = NO;
    }else{
        self.btn_flash.selected = YES;
    }

    if (self.isVideo) {
        [self.btn_capturetype setSelectedSegmentIndex:1];
        self.label_timer.alpha = 1;
        [self.btn_capture setImage:[UIImage imageNamed:@"icon_capture_video_start.png"] forState:UIControlStateNormal];
        [self.btn_capture setImage:[UIImage imageNamed:@"icon_capture_video_stop.png"] forState:UIControlStateSelected];
        if (self.isStartVideo) {
            self.btn_capture.selected = YES;
            self.btn_flash.alpha = 0;
            self.btn_switchcamera.alpha = 0;
        }else{
            self.btn_capture.selected = NO;
            self.btn_flash.alpha = 1;
            self.btn_switchcamera.alpha = 1;
        }
        
    }else{

        [self.btn_capturetype setSelectedSegmentIndex:0];
        self.label_timer.alpha = 0;
        [self.btn_capture setImage:[UIImage imageNamed:@"icon_capture_photo.png"] forState:UIControlStateNormal];
        [self.btn_capture setImage:[UIImage imageNamed:@"icon_capture_photo.png"] forState:UIControlStateSelected];
        self.btn_capture.selected = NO;
    }
    //延时2s再去获取
    [self performSelector:@selector(loadLastPhoto) withObject:nil afterDelay:2.0];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTakePhoto) name:notify_key_take_photo object:nil];

    self.isFlashOn = YES;
    self.isFront = NO;
    self.isVideo = NO;
    [self createImagePicker];

    self.overlay = [[UIView alloc] initWithFrame:CGRectZero];
    CGRect theRect = self.picker.view.frame;
    [self.overlay setFrame:theRect];

    self.btn_capture = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    self.btn_capture.center = CGPointMake(CGRectGetWidth(self.view.frame)/2.0, CGRectGetHeight(self.view.frame)-38);
    [self.overlay addSubview:self.btn_capture];
    
    UIView* upview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60)];
    upview.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.5];
    [self.overlay addSubview:upview];
    
    self.btn_back = [[UIButton alloc] initWithFrame:CGRectMake(5, 17, 40, 40)];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 12, 15)];
    image.image = [UIImage imageNamed:@"icon_back_white"];
    //image.contentMode = UIViewContentModeScaleAspectFit;
    [self.btn_back addSubview:image];
    //[self.btn_back setImage:[UIImage imageNamed:@"icon_back@2x.png"] forState:UIControlStateNormal];
    //self.btn_back.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.overlay addSubview:self.btn_back];
    [self.btn_back addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.btn_flash = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.btn_back.frame)+10, 15, 30, 30)];
    self.btn_flash.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.btn_flash setImage:[UIImage imageNamed:@"icon_flash_enable.png"] forState:UIControlStateNormal];
    [self.btn_flash setImage:[UIImage imageNamed:@"icon_flash_disable.png"] forState:UIControlStateSelected];
    [self.btn_flash addTarget:self action:@selector(onClickFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlay addSubview:self.btn_flash];

    self.btn_switchcamera = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-80 , 15, 60, 30)];
    self.btn_switchcamera.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.btn_switchcamera setImage:[UIImage imageNamed:@"icon_camera_switch"] forState:UIControlStateNormal];
    [self.btn_switchcamera addTarget:self action:@selector(onClickCameraSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlay addSubview:self.btn_switchcamera];
    
    self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(15, CGRectGetHeight(self.view.frame)-84, 64, 64)];
    self.thumbnail.contentMode = UIViewContentModeScaleAspectFit;
    [self.overlay addSubview:self.thumbnail];
    
    self.label_timer = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, CGRectGetWidth(self.view.frame), 30)];
    self.label_timer.textColor = [UIColor whiteColor];
    self.label_timer.textAlignment = NSTextAlignmentCenter;
    self.label_timer.font = [UIFont systemFontOfSize:16];
    self.label_timer.alpha = 0;
    self.label_timer.text = @"00:00:00";
    [self.overlay addSubview:self.label_timer];
    
    CGFloat btnsize = 48;
    _btnPhoto = [[UIButton alloc] initWithFrame:CGRectMake(15, CGRectGetHeight(self.view.frame)-btnsize-20, btnsize, btnsize)];
    [_btnPhoto setBackgroundColor:[UIColor colorWithWhite:0.388 alpha:0.8]];
    
    //获取相册最后一张照片并加载
    [self loadLastPhoto];
    
    [_btnPhoto addTarget:self action:@selector(onClickedOpenAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlay addSubview:_btnPhoto];
    CGFloat btnsize2 = 48;
    self.btn_capture = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2.0-btnsize2/2.0, CGRectGetHeight(self.view.frame)-btnsize2-20, btnsize2, btnsize2)];
    [self.btn_capture addTarget:self action:@selector(onCLickCapture:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlay addSubview:self.btn_capture];
    
    
//    self.btn_capturetype = [[UISegmentedControl alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-130, CGRectGetHeight(self.view.frame)-50, 120, 25)];
//    [self.btn_capturetype insertSegmentWithTitle:NSLocalizedString(@"Photo", nil) atIndex:0 animated:YES];
//    //[self.btn_capturetype insertSegmentWithTitle:NSLocalizedString(@"Video", nil) atIndex:1 animated:YES];
//    [self.btn_capturetype setSelectedSegmentIndex:0];
//    [self.btn_capturetype setTintColor:[UIColor clearColor]];
//    [self.btn_capturetype setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]} forState:UIControlStateSelected];
//    [self.btn_capturetype setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
//    
//    [self.btn_capturetype addTarget:self action:@selector(onClickMode:) forControlEvents:UIControlEventValueChanged];
//    [self.overlay addSubview:self.btn_capturetype];
    self.picker.cameraOverlayView = self.overlay;
    self.picker.modalPresentationStyle = UIModalPresentationCurrentContext;
//    self.picker.showsCameraControls = NO;

//
//    self.btn_capturetype = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-60, CGRectGetHeight(self.view.frame)-50, 50, 25)];
//    [self.btn_capturetype setTitle:NSLocalizedString(@"Photo", nil) forState:UIControlStateNormal];
//    [self.btn_capturetype setTitle:NSLocalizedString(@"Video", nil) forState:UIControlStateSelected];
//    [self.btn_capturetype addTarget:self action:@selector(onClickMode:) forControlEvents:UIControlEventTouchUpInside];
//    [self.overlay addSubview:self.btn_capturetype];
//    self.picker.cameraOverlayView = self.overlay;

    
    [self addChildViewController:self.picker];
    [self.view addSubview:self.picker.view];
    [self.picker didMoveToParentViewController:self];

//    [self presentViewController:self.picker animated:YES completion:nil];

    
    // Do any additional setup after loading the view.
}

- (void)loadLastPhoto
{
    //获取相册最后一张照片并加载
    [WJPhotoTool latestAsset:^(WJAsset * _Nullable asset) {
        [_btnPhoto setImage:asset.image forState:UIControlStateNormal];
    }];
}

- (void)onClickedOpenAlbum:(id)sender{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    //设置选择后的图片可被编辑
    picker.allowsEditing = NO;
    
//    [self presentModalViewController:picker animated:YES];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createImagePicker {
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    self.picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie",@"public.image",nil];
    if (self.isVideo) {
        self.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    }else{
        self.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    }

    
    self.picker.allowsEditing = NO;
    self.picker.showsCameraControls = NO;
//    self.picker.cameraViewTransform = CGAffineTransformIdentity;
    CGFloat camScaleup = 1.2;
    self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, camScaleup, camScaleup);
    
    // not all devices have two cameras or a flash so just check here
    if ( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceRear] ) {
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        self.isFront = NO;
        if ( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront] ) {
            self.showSwitch = YES;
        }else{
            self.showSwitch = NO;
        }
    } else {
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        self.isFront = YES;
        self.showSwitch = NO;
    }
    
    if ( [UIImagePickerController isFlashAvailableForCameraDevice:self.picker.cameraDevice] ) {
        self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        self.showFlash = YES;
        self.isFlashOn = NO;
    }else{
        self.showFlash = NO;
    }
    
    self.picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    self.picker.delegate = self;
}


-(void)onClickFlash:(UIButton*)sender{
    NSLog(@"before %d,self.isFlashOn=%d",self.picker.cameraFlashMode,self.isFlashOn);
    
    if (self.picker.cameraFlashMode == UIImagePickerControllerCameraFlashModeAuto || self.picker.cameraFlashMode == UIImagePickerControllerCameraFlashModeOn) {
        self.isFlashOn = NO;
        self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    }else{
        self.isFlashOn = YES;
        self.picker.showsCameraControls = YES;
        self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        self.picker.showsCameraControls = NO;

    }
    NSLog(@"after %d,self.isFlashOn=%d",self.picker.cameraFlashMode,self.isFlashOn);
    [self refreshUI];
}

-(void)onClickCameraSwitch:(UIButton*)sender{
    if (self.picker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        self.isFront = NO;
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }else{
        self.isFront = YES;
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}


-(void)onCLickCapture:(UIButton*)sender{
    if(self.picker.cameraCaptureMode == UIImagePickerControllerCameraCaptureModePhoto){
        [self.picker takePicture];
    }else{
        if (self.isStartVideo) {
            [self.picker stopVideoCapture];
            [self stopCounting];
            
        }else{
            [self.picker startVideoCapture];
            [self startCounting];

        }
        self.isStartVideo = !self.isStartVideo;
    }
    [self refreshUI];
    
}

-(void)onClickMode:(UIButton*)sender{
    if (self.picker.cameraCaptureMode == UIImagePickerControllerCameraCaptureModePhoto) {
        self.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        self.isVideo = YES;
        self.isStartVideo = NO;
        self.picker.cameraViewTransform = CGAffineTransformIdentity;
    }else{
        self.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        CGFloat camScaleup = 1.2;
        self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, camScaleup, camScaleup);
//        self.picker.cameraViewTransform = CGAffineTransformIdentity;

        self.isVideo = NO;
        self.isStartVideo = NO;
      
    }
    [self refreshUI];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    if(info)
    {
        // UIImagePickerControllerReferenceURL = "assets-library://asset/asset.JPG?id=3EF4B428-6FAE-494F-B46D-54DB6DBDB182&ext=JPG";
        //通过判断是否有UIImagePickerControllerReferenceURL这个key来区分是拍照还是选中了系统相册中的照片
        NSURL *tmpURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
        
        if(![[tmpURL absoluteString] length])
        {
            //拍照或摄像
            if (picker.cameraCaptureMode == UIImagePickerControllerCameraCaptureModeVideo) {
                NSURL *videoURL = [info valueForKey:UIImagePickerControllerMediaURL];
                NSString *pathToVideo = [videoURL path];
                BOOL okToSaveVideo = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToVideo);
                if (okToSaveVideo) {
                    UISaveVideoAtPathToSavedPhotosAlbum(pathToVideo, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
                } else {
                    [self video:pathToVideo didFinishSavingWithError:nil contextInfo:NULL];
                }
                
            }else{
                UIImage* originimg = [info valueForKey:UIImagePickerControllerOriginalImage];
                UIImageWriteToSavedPhotosAlbum(originimg, nil, nil, nil);
            }
        }
        else
        {
            //系统相册照片
            NSLog(@"system photo");
            
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            //image = [[image clipImageWithScaleWithsize:CGSizeMake(320, 480)] retain] ;
            [picker dismissViewControllerAnimated:NO completion:^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
                
                SXRShowPhotoViewController *fitler = [[SXRShowPhotoViewController alloc] init];
                NSLog(@"%@",fitler.image);
                fitler.image = image;
                [self presentModalViewController:fitler animated:YES];
            }];
            
        }
        
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    NSLog(@"save video %@ error = %@ context = %@",videoPath, error, contextInfo);
}


-(void)onClickBack:(id)sender{
    self.picker = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    HMTabBarController *tab=[HMTabBarController new];
//    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    appdelegate.window.rootViewController=tab;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)startCounting{
    self.timeval = 0;
    if (self.counttimer) {
        [self.counttimer invalidate];
        self.counttimer = nil;
    }
    self.label_timer.text = @"00:00:00";
    
    self.counttimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTime:) userInfo:nil repeats:YES];
    
}

-(void)stopCounting{
    if (self.counttimer) {
        [self.counttimer invalidate];
        self.counttimer = nil;
    }

}

-(void)onTime:(id)sender{
    self.timeval+=1;
    self.label_timer.text = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",(int)self.timeval/(60*60), ((int)self.timeval%3600)/60, (int)self.timeval%60];
    
}

-(void)onTakePhoto{
    [self onCLickCapture:nil];
}

-(void)getLastinAlbum{

}
@end
