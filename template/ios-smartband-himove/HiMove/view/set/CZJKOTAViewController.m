//
//  CZJKOTAViewController.m
//  SXRBand
//
//  Created by qf on 16/4/18.
//  Copyright © 2016年 SXR. All rights reserved.
//

#import "CZJKOTAViewController.h"
#import "IRKProgressBar.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "FileTypeTableViewController.h"
#import "AppFilesTableViewController.h"
#import "DFUOperations.h"
#import "DFUHelper.h"
#import "Constants.h"
#import "UnzipFirmware.h"
#import "Utility.h"
#import <CommonCrypto/CommonDigest.h>

#define FileHashDefaultChunkSizeForReadingData 1024*8


@interface CZJKOTAViewController ()<UIAlertViewDelegate,DFUOperationsDelegate,CBCentralManagerDelegate,IRKProgressBarDelegate>
@property(nonatomic, strong)IRKCommonData* commondata;
@property(nonatomic, strong)BleControl* blecontrol;
@property(nonatomic, strong)MainLoop* mainloop;
@property(nonatomic, strong)UILabel* label_currentfireware;
@property(nonatomic, strong)UIButton* btn_update;
@property(nonatomic, strong)NSString* currentfw;
@property (strong, nonatomic)UIActivityIndicatorView* indicator;
@property (strong, nonatomic)UILabel* update_tips;
@property (strong, nonatomic)UILabel* update_rate;
@property (strong, nonatomic)IRKProgressBar* update_progress;
@property (strong, nonatomic)NSString* fwUrl;
@property (strong, nonatomic)NSString* filename;
@property (strong, nonatomic)NSString* md5;
@property (strong, nonatomic)dispatch_queue_t centralQueue;
@property (strong, nonatomic) CBPeripheral *selectedPeripheral;
@property (strong, nonatomic) DFUOperations *dfuOperations;
@property (strong, nonatomic) CBCentralManager * bleManager;
@property (strong, nonatomic) DFUHelper *dfuHelper;

@end

@implementation CZJKOTAViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x1F/255.0 green:0x96/255.0 blue:0xF2/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTranslucent:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKickoff:) name:notify_band_has_kickoff object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSendOta0:) name:notify_key_did_send_nodic_ota0 object:nil];
    self.update_tips.text = @"";
    self.update_rate.text = @"";
    
    [self refreshUI];
    if (_isJump) {
        [self onClickBtn:nil];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    self.blecontrol = [BleControl SharedInstance];
    self.mainloop = [MainLoop SharedInstance];
    
    self.centralQueue = dispatch_queue_create("com.keeprapid.general2k", DISPATCH_QUEUE_SERIAL);
    self.bleManager = [[CBCentralManager alloc]initWithDelegate:self queue:self.centralQueue];
    
    [self initNav];
    [self initControl];
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
    label.text=NSLocalizedString(@"Config_Cell_OTA", nil);
    label.font=[UIFont systemFontOfSize:18];
    [label sizeToFit];
    self.navigationItem.titleView=label;
}


-(void)onClickBack:(id)sender{
//    self.blecontrol.is_in_OTA = NO;
    if (!self.blecontrol.is_in_OTA) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];

    }
}

-(void)initControl{
    self.view.backgroundColor=[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    UILabel* tip = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, CGRectGetWidth(self.view.frame)-50, 24)];
    tip.textColor = [UIColor blackColor];
    tip.font = [UIFont systemFontOfSize:16];
    tip.text  = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"OTA_Tip", nil)];
    [self.view addSubview:tip];
    
    self.label_currentfireware = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tip.frame)+10, CGRectGetWidth(self.view.frame), 24)];
    self.label_currentfireware.textAlignment = NSTextAlignmentCenter;
    self.label_currentfireware.textColor = [UIColor colorWithRed:0x74/255.0 green:0xb7/255.0 blue:0xec/255.0 alpha:1];
    self.label_currentfireware.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.label_currentfireware];
    
    self.btn_update = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(self.label_currentfireware.frame)+50, CGRectGetWidth(self.view.frame)-100, 50)];
    self.btn_update.backgroundColor = [UIColor colorWithRed:0x74/255.0 green:0xb7/255.0 blue:0xec/255.0 alpha:1];
    [self.btn_update setTitle:NSLocalizedString(@"OTA_btn_check", nil) forState:UIControlStateNormal];
    [self.btn_update setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn_update addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.btn_update.layer.cornerRadius = 5;
    [self.view addSubview:self.btn_update];
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat halfButtonHeight = self.btn_update.bounds.size.height / 2;
    CGFloat buttonWidth = self.btn_update.bounds.size.width;
    self.indicator.center = CGPointMake(buttonWidth - halfButtonHeight , halfButtonHeight);
    [self.btn_update addSubview:self.indicator];
    self.indicator.hidden = YES;
    
    
    self.dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
    self.dfuHelper = [[DFUHelper alloc] initWithData:self.dfuOperations];
    
    self.update_tips = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.btn_update.frame)+20, CGRectGetWidth(self.view.frame), 80)];
    self.update_tips.numberOfLines = 0;
    self.update_tips.font = [UIFont systemFontOfSize:14];
    self.update_tips.textAlignment = NSTextAlignmentCenter;
    self.update_tips.textColor = [UIColor blackColor];
    self.update_tips.hidden = NO;
    [self.view addSubview:self.update_tips];
    
    self.update_progress = [[IRKProgressBar alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.update_tips.frame)+10, CGRectGetWidth(self.view.frame)-40, 20)];
    self.update_progress.delegate = self;
    self.update_progress.hidden = YES;
    [self.update_progress reload];
    [self.view addSubview:self.update_progress];
    [self.update_progress setProgress:0 animated:YES];
    
    self.update_rate = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.update_progress.frame)+10, CGRectGetWidth(self.view.frame), 20)];
    self.update_rate.font = [UIFont systemFontOfSize:14];
    self.update_rate.textAlignment = NSTextAlignmentCenter;
    self.update_rate.textColor = [UIColor blackColor];
    self.update_rate.hidden = NO;
    [self.view addSubview:self.update_rate];
    

}


-(void)onClickBtn:(id)sender{
    if (self.blecontrol.is_ble_poweron == NO) {
        [self.blecontrol restart_ble];
        return;
    }
    if (self.blecontrol.is_in_OTA){
        NSLog(@"already in ota");
    }else if (self.blecontrol.is_connected != IRKConnectionStateConnected) {
        UIAlertView* alerview = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Device_unavailable", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alerview show];
        return;
    }else{
        self.indicator.hidden = NO;
        [self.indicator startAnimating];
        [self getLatestFirwareVersionFromServer];
    }
}

-(void)onKickoff:(NSNotification*)notify{
    [self refreshUI];
}
-(void)onSendOta0:(NSNotification*)notify{
    NSLog(@"onSendOta0");
    [self.blecontrol IntoOTA:YES];
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
//    sleep(5);
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(otascandevie:) userInfo:nil repeats:NO];
//    [self.bleManager scanForPeripheralsWithServices:nil options:options];
//    [self.bleManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"00001530-1212-EFDE-1523-785FEABCD123"]] options:options];
//    [self.bleManager retrieveConnectedPeripheralsWithServices:@{[CBUUID UUIDWithString:@"]]
    
    /*
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
     NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:FIRMWARE_FILE_NAME];
     
     // We want the scanner to scan with dupliate keys (to refresh RRSI every second) so it has to be done using non-main queue
     
     
     [self.dfuOperations performDFUOnFile:[NSURL fileURLWithPath:filePath] firmwareType:APPLICATION];
     */
    
}
-(void)otascandevie:(NSNotification*)notify{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];

    [self.bleManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"00001530-1212-EFDE-1523-785FEABCD123"]] options:options];

}

-(void)updateFreshTips:(NSString*)tipstr BarProgress:(CGFloat)progress{
    if ([tipstr isEqualToString:@""]) {
        self.update_tips.text = NSLocalizedString(@"OTA_Tips", nil);
    }else{
        self.update_tips.text = tipstr;
    }
//    self.update_tips.text = NSLocalizedString(@"OTA_Tips", nil);

    if (progress>0) {
        self.update_rate.text = [NSString stringWithFormat:@"%.0f%%",progress*100];
        self.update_progress.hidden = NO;
        [self.update_progress setProgress:progress animated:YES];
    }else{
        [self.update_progress setProgress:0 animated:YES];
        self.update_progress.hidden = YES;
        self.update_rate.text = @"";
        
    }
    
}

-(void)refreshUI{
    if (self.blecontrol.is_connected == IRKConnectionStateConnected) {
        NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
        if (bonginfo) {
            NSString* fwinfo = [bonginfo objectForKey:BONGINFO_KEY_FIRMWARE];
            self.label_currentfireware.text = fwinfo;
            self.currentfw = fwinfo;
        }else{
            self.label_currentfireware.text = @"";
            self.currentfw = @"";
        }
    }else{
        self.label_currentfireware.text = @"";
        self.currentfw = @"";
    }
}

-(UIColor*)getBarColor:(IRKProgressBar*)Progress withProgress:(CGFloat)progress{
    return self.commondata.colorNav;
}

-(NSString*)getVersionCode:(NSString*)firmware{
    
    return [firmware substringWithRange:NSMakeRange([firmware length]-3, 3)];
}


-(void)getLatestFirwareVersionFromServer{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString* productcode = [self.commondata getValueFromBonginfoByKey:BONGINFO_KEY_PRODUCTCODE];
//        NSString* version = [self.commondata getValueFromBonginfoByKey:BONGINFO_KEY_VERSIONCODE];
        NSString* urlstr = [NSString stringWithFormat:FIRMWARE_VERSION_SERVER_URL,productcode];
        NSURL  *url = [NSURL URLWithString:urlstr];
        NSLog(@"url = %@",url);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateFreshTips:@"" BarProgress:0];
        });
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData )
        {
            //NSLog(@"%@",[NSString stringWithCharacters:[urlData bytes] length:urlData.length ]);
            NSError* error = nil;
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.indicator stopAnimating];
                self.indicator.hidden = YES;
            });
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateFreshTips:@"" BarProgress:0];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"OTA_FirmwareServer_ResponeError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                });
                return;
                
            }
            NSLog(@"%@",responseDict);
            NSDictionary* updatInfo = [responseDict objectForKey:FIRMINFO_DICT_UPDATEINFO];
            if (updatInfo) {
//                NSString* fwDesc = [updatInfo objectForKey:FIRMINFO_DICT_FWDESC];
//                NSString* fwName = [updatInfo objectForKey:FIRMINFO_DICT_FWNAME];
                self.fwUrl = [updatInfo objectForKey:FIRMINFO_DICT_FWURL];
                self.filename = [[NSURL URLWithString:self.fwUrl] lastPathComponent];
                NSString* versionCode = [updatInfo objectForKey:FIRMINFO_DICT_VERSIONCODE];
                NSString* versionName = [updatInfo objectForKey:FIRMINFO_DICT_VERSIONNAME];
                self.md5 = [updatInfo objectForKey:FIRMINFO_DICT_MD5];
//                NSString* currentfw = self.currentfw;
                
                //                NSArray* fwlist = [self.currentfw componentsSeparatedByString:@"_"];
                //                if ([fwlist count]>1) {
                //                    currentfw = [fwlist objectAtIndex:0];
                //               }
                NSString* currentCode = [self getVersionCode:self.currentfw];
                NSString* returnCode = [self getVersionCode:versionCode];
                NSComparisonResult result = [currentCode caseInsensitiveCompare:returnCode];
                if (result == NSOrderedAscending) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString* notifystr = [NSString stringWithFormat:@"%@\n\n%@%@(%@)",NSLocalizedString(@"OTA_FirmwareServer_Found_Latest", nil),
                                               NSLocalizedString(@"OTA_FirmwareServer_Newfirm", nil),
                                               versionCode,
                                               versionName];
                        
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:notifystr delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil),nil];
                        alert.tag = 100;
                        [alert show];
                        
                    });
                    
                    return;
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"OTA_FirmwareServer_Already_Latest", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                        [alert show];
                        [self updateFreshTips:@"" BarProgress:0];
                        
                    });
                    return;
                    
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"OTA_FirmwareServer_ResponeError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                    [self updateFreshTips:@"" BarProgress:0];
                    
                    
                });
                return;
                
            }
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicator stopAnimating];
                self.indicator.hidden = YES;
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"OTA_FirmwareServer_ResponeError", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
                [self updateFreshTips:@"" BarProgress:0];
                
                
            });
            return;
            
        }
    });
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self.indicator startAnimating];
            self.indicator.hidden = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateFreshTips:@"" BarProgress:0];
            });
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSString* filename = [self.fwUrl lastPathComponent];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSFileManager* filemanager = [[NSFileManager alloc] init];
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
                NSLog(@"%@",filePath);
                
                //                BOOL b = [filemanager fileExistsAtPath:filePath];
                //                NSString* s = [self getFileMD5WithPath:filePath] ;
                
                if ([filemanager fileExistsAtPath:filePath] && [[self getFileMD5WithPath:filePath] isEqualToString:self.md5]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //                        [self.indicator stopAnimating];
                        //                        self.indicator.hidden = YES;
                        NSLog(@"file exist start ota now!");
                        [self startOTA];
                    });
                    
                }else{

                    NSData* newFw = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.fwUrl]];
                    if(newFw){
                        NSLog(@"newfw = %@",newFw);
                        //                    NSString *filename = [NSString stringWithFormat:@"%@.jpg",self.commondata.uid];
                        
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.filename];
                        NSLog(@"%@",filePath);
                        [newFw writeToFile:filePath atomically:YES];
                        
                        NSData* d = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
                        NSLog(@"d.lenght = %lu",(unsigned long)d.length);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //                        [self.indicator stopAnimating];
                            //                        self.indicator.hidden = YES;
                            [self startOTA];
                        });
                        
                        
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.indicator stopAnimating];
                            self.indicator.hidden = YES;
                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"OTA_FirmwareServer_Download", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                            [alert show];
                        });
                        return;
                        
                    }
                }
                
            });
            
            
        }else{
            [self.indicator stopAnimating];
            self.indicator.hidden = YES;
            
        }
    }
}

-(void)startOTA{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateFreshTips:@"" BarProgress:0];
    });
    [self.mainloop startNodicOTA];

}

-(void)onDeviceConnected:(CBPeripheral *)peripheral{
    NSLog(@"DFU::onDeviceConnected");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateFreshTips:@"" BarProgress:0];
        self.navigationItem.leftBarButtonItem.enabled = NO;
    });
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.filename];
    // We want the scanner to scan with dupliate keys (to refresh RRSI every second) so it has to be done using non-main queue
    [self.dfuOperations performDFUOnFile:[NSURL fileURLWithPath:filePath] firmwareType:APPLICATION];
    
}
-(void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral{
    NSLog(@"DFU::onDeviceConnectedWithVersion");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateFreshTips:@"" BarProgress:0];
    });
    
    self.dfuHelper.isDfuVersionExist = YES;
    self.dfuHelper.enumFirmwareType = APPLICATION;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.filename];
    NSURL* url = [NSURL URLWithString:filePath];
    self.dfuHelper.selectedFileURL = url;
    if (self.dfuHelper.selectedFileURL) {
        NSLog(@"selectedFile URL %@",self.dfuHelper.selectedFileURL);
        NSString *selectedFileName = [[url path]lastPathComponent];
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        self.dfuHelper.selectedFileSize = fileData.length;
        NSLog(@"fileSelected %@",selectedFileName);
        
        //get last three characters for file extension
        NSString *extension = [selectedFileName substringFromIndex: [selectedFileName length] - 3];
        NSLog(@"selected file extension is %@",extension);
        if ([extension isEqualToString:@"zip"]) {
            NSLog(@"this is zip file");
            self.dfuHelper.isSelectedFileZipped = YES;
            self.dfuHelper.isManifestExist = NO;
            [self.dfuHelper unzipFiles:self.dfuHelper.selectedFileURL];
        }
        else {
            self.dfuHelper.isSelectedFileZipped = NO;
        }
        [self.dfuHelper checkAndPerformDFU];
    }
    // We want the scanner to scan with dupliate keys (to refresh RRSI every second) so it has to be done using non-main queue
    
    //    [self.dfuOperations performDFUOnFile:[NSURL fileURLWithPath:filePath] firmwareType:APPLICATION];
    
}
-(void)onDeviceDisconnected:(CBPeripheral *)peripheral{
    NSLog(@"DFU::onDeviceDisconnected");
    if (self.blecontrol.is_in_OTA) {
        self.bleManager.delegate = self;
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        [self.bleManager scanForPeripheralsWithServices:nil options:options];
    };
    
}
-(void)onReadDFUVersion:(int)version{
    NSLog(@"DFU::onReadDFUVersion version=%d",version);
    self.dfuHelper.dfuVersion = version;
    NSLog(@"DFU Version: %d",self.dfuHelper.dfuVersion);
    
}
-(void)onDFUStarted{
    NSLog(@"DFU::onDFUStarted");
    
}
-(void)onDFUCancelled{
    NSLog(@"DFU::onDFUCancelled");
    
}
-(void)onSoftDeviceUploadStarted{
    NSLog(@"DFU::onSoftDeviceUploadStarted");
    
}
-(void)onBootloaderUploadStarted{
    NSLog(@"DFU::onBootloaderUploadStarted");
    
}
-(void)onSoftDeviceUploadCompleted{
    NSLog(@"DFU::onSoftDeviceUploadCompleted");
    
}
-(void)onBootloaderUploadCompleted{
    NSLog(@"DFU::onBootloaderUploadCompleted");
    
}
-(void)onTransferPercentage:(int)percentage{
//    NSLog(@"DFU::onTransferPercentage : percentage:%d",percentage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateFreshTips:@"" BarProgress:percentage/100.0];
    });
    
    
}
-(void)onSuccessfulFileTranferred{
    NSLog(@"DFU::onSuccessfulFileTranferred");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.indicator stopAnimating];
        self.indicator.hidden = YES;
        self.bleManager.delegate = nil;
        self.bleManager = nil;
        [self.blecontrol IntoOTA:NO];
        
        [self updateFreshTips:NSLocalizedString(@"OTA_Tip_finish", nil) BarProgress:0];
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
//        [NSTimer time
//        [self.blecontrol connectDefaultDevice];
        [self performSelector:@selector(reconnectBleDeviceAfterOTA) withObject:nil afterDelay:5];
    });
    
}
-(void)reconnectBleDeviceAfterOTA{
    NSLog(@"reconnectBleDeviceAfterOTA");
//    [self.blecontrol restart_ble];
    [self.blecontrol connectDefaultDevice];

}

-(void)onError:(NSString *)errorMessage{
    NSLog(@"DFU::onError::%@",errorMessage);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"OTA_Tip_Error", nil),errorMessage] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [self.indicator stopAnimating];
        self.indicator.hidden = YES;
        [self.blecontrol IntoOTA:NO];
        
        [self updateFreshTips:@"" BarProgress:0];
    });
    
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"OTA::::::didfindble %@",peripheral);
//    if([peripheral.identifier.UUIDString isEqualToString:self.commondata.lastBongUUID]|| [[peripheral.name uppercaseString] hasPrefix:@"DFU"]){
    if([[peripheral.name uppercaseString] hasPrefix:@"W4S_OTA"]){
        [central stopScan];
        [self.dfuOperations setCentralManager:central];
        [self.dfuOperations connectDevice:peripheral];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSString*)getFileMD5WithPath:(NSString*)path
{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

@end
