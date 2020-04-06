//
//  BleControl.h
//  IntelligentRingKing
//
//  Created by qf on 14-5-30.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
@protocol BleControlDelegate
@optional

-(void)UpdateRSSI:(int)rssi;
-(void)getReady;
-(void)disconnect;
-(void)recvTimeout;
-(BOOL)isCorrectRsp:(int)response byCmdname:(int)request;
-(void)doNext;
@required
//-(void)ReceiveData:(uint8_t*)buf length:(int)len;
//-(void)ReceiveData:(NSData*)recvdata;
-(void)ReceiveData2:(NSData*)recvdata;
@end



@interface BleControl : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate> 

@property (nonatomic,assign) id <BleControlDelegate> delegate;
@property (nonatomic, assign) BOOL is_thread_run;
@property (nonatomic, assign) IRKConnectionState is_connected;
@property (nonatomic, assign) BOOL is_scaning;
@property (nonatomic, assign) BOOL is_ble_poweron;
@property (nonatomic, assign) BOOL is_peripheral_wait_for_connect;
@property (nonatomic, assign) BOOL is_writeable;
@property (nonatomic, assign) BOOL is_adv_writeable;
@property (nonatomic, assign) BOOL is_find_bong_notify;
@property (nonatomic, assign) BOOL is_find_bong_write;
@property (nonatomic, assign) BOOL is_in_connecting;
@property BOOL is_ready_for_next_command;
@property int current_protocol_cmdkey;
@property NSMutableData* recvdata;
@property int recvlen;
@property NSTimer* recvdatatimeout;
@property NSTimer* findchtimeout;
@property int recvpackege;
@property int needrecvpackege;

@property BOOL need_respone;
@property (nonatomic, assign) NSInteger waitConnectIndex;
@property (nonatomic, strong) CBCentralManager *bleManager;
@property (nonatomic, strong) NSMutableData *data;

@property (nonatomic, strong) NSMutableArray * scanDevicelist;
@property (nonatomic, assign) NSString * scanNotifyName;

@property (nonatomic, strong) NSMutableDictionary * connectedDevicelist;
@property (nonatomic, strong) IRKCommonData* commondata;

@property (nonatomic, strong)NSMutableDictionary* NotifyCharacteristicDict;
@property (nonatomic, strong)NSMutableDictionary* WriteCharacteristicDict;
@property (nonatomic, strong)NSMutableDictionary* ReadCharacteristicDict;
//生科OTA使用
@property (nonatomic, assign) BOOL isOta;
//nordicOTA使用
@property (nonatomic, assign) BOOL is_in_OTA;

@property NSMutableArray* commandArray;
@property (nonatomic, assign) BOOL isOTAData;
@property (nonatomic, assign) BOOL isOTACmd;
@property (nonatomic, assign) CBPeripheral* needReconnectPeripheral;
@property(nonatomic,strong) dispatch_queue_t blequeue;
@property(nonatomic,assign) BOOL is_autoconnect;


-(void)stopMainLoop;

+(BleControl*)SharedInstance;

-(NSInteger)scanDevice:(NSArray*)serviceUUIDs withOption:(NSDictionary*)option withNotifyName:(NSString*)notifyname;
-(void)stopScanDevice;
-(void)connectDevice:(NSInteger)index;
-(void)disconnectDevice:(NSInteger)index;
-(void)connectDefaultDevice;
//断链但不删除默认手环
-(void)disconnectDevice2;

//sendAPI
//-(void)writeDataToBle:(NSData*)data forPeripheralKey:(NSString*)pKey forCharacteristicKey:(NSString*)ckey withRespon:(BOOL)Respon;
//-(void)readDataToBle:(NSString*)peripheralKey forCharacteristicKey:(NSString*)ckey;
-(void)submit_writeData:(NSData*)data forPeripheralKey:(NSString*)pKey forCharacteristicKey:(NSString*)ckey withRespon:(BOOL)Respon protocolcmd:(int)pcmd;
-(void)submit_readData:(NSString*)peripheralKey forCharacteristicKey:(NSString*)ckey;
-(void)restart_ble;
//为nordicOTA升级使用
-(void)IntoOTA:(BOOL)flag;
@end
