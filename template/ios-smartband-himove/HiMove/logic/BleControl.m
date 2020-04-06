//
//  BleControl.m
//  IntelligentRingKing
//
//  Created by qf on 14-5-30.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#import "BleControl.h"
#import "CZJKOTAViewController.h"
@implementation BleControl

+(BleControl *)SharedInstance
{
    static BleControl *ble = nil;
    if (ble == nil) {
        ble = [[BleControl alloc] init];
    }
    return ble;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.commondata = [IRKCommonData SharedInstance];
        self.is_thread_run = YES;
        self.is_scaning = NO;
        self.is_writeable = NO;
        self.is_adv_writeable = NO;
        self.is_find_bong_notify = NO;
        self.is_find_bong_write = NO;
        self.is_ready_for_next_command = YES;
        self.need_respone = YES;
        self.is_in_connecting = NO;
        self.recvpackege = 0;
        self.needrecvpackege = 0;
        self.isOta = NO;
        self.isOTAData = NO;
        self.isOTACmd = NO;
        self.is_in_OTA = NO;
        
        self.recvlen = 0;
        self.current_protocol_cmdkey = -1;
        self.commandArray = [[NSMutableArray alloc] init];
        self.is_connected = IRKConnectionStateUnknown;
        self.blequeue = dispatch_queue_create("com.keeprapid.ble", DISPATCH_QUEUE_CONCURRENT);

        self.bleManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.scanDevicelist = [[NSMutableArray alloc] init];
        self.connectedDevicelist =[[NSMutableDictionary alloc] init];
        self.NotifyCharacteristicDict =[[NSMutableDictionary alloc] init];
        self.WriteCharacteristicDict =[[NSMutableDictionary alloc] init];
        self.ReadCharacteristicDict =[[NSMutableDictionary alloc] init];


//#ifdef CUSTOM_API2
//#else
//        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(mainloop:) userInfo:nil repeats:YES];
//#endif
//        [NSThread detachNewThreadSelector:@selector(mainloop:) toTarget:self withObject:nil];

    }
    return self;
}
-(void)stopMainLoop{
    self.is_thread_run = NO;
}
#pragma ble recv thread
//-(void) mainloop:(id)sender{
// //   NSLog(@"mainloop");
//    if(self.is_connected == IRKConnectionStateConnected && self.is_find_bong_write){
//        //read RSSI
//        /*
//        CBPeripheral* currentperipheral = [self.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
//        if (currentperipheral) {
//            [currentperipheral readRSSI];
//        }
//         */
//        //write指令
//        if(self.is_ready_for_next_command){
//#ifdef HAS_OTA
//            if (self.isOta) {
//                return;
//            }
//#endif
//            if([self.commandArray count]){
//                NSDictionary* cmdinfo = (NSDictionary*)[self.commandArray objectAtIndex:0];
//                NSString* cmdtype = (NSString*)[cmdinfo objectForKey:@"cmdtype"];
//                if([cmdtype isEqual:@"write"]){
//                    
//                    NSNumber* cmdkey = (NSNumber*)[cmdinfo objectForKey:@"protocolcmd"];
//                    self.current_protocol_cmdkey = [cmdkey intValue];
//                    NSNumber* respon = (NSNumber*)[cmdinfo objectForKey:@"respon"];
//                    NSData* data = (NSData*)[cmdinfo objectForKey:@"data"];
//                    NSString * pkey = (NSString*)[cmdinfo objectForKey:@"peripheralkey"];
//                    NSString* ckey = (NSString*)[cmdinfo objectForKey:@"characteristickey"];
//                    [self writeDataToBle:data forPeripheralKey:pkey forCharacteristicKey:ckey withRespon: [respon boolValue]];
//                }
//                else if([cmdtype isEqual:@"read"]){
//                    NSString * pkey = (NSString*)[cmdinfo objectForKey:@"peripheralkey"];
//                    NSString* ckey = (NSString*)[cmdinfo objectForKey:@"characteristickey"];
//                    [self readDataToBle:pkey forCharacteristicKey:ckey];
//                    self.current_protocol_cmdkey = 0;
//                }
//                else{
//                    NSLog(@"UNKOWN cmdInfo %@", cmdinfo);
//                }
//                [self.commandArray removeObject:cmdinfo];
//            }
//        }
//    }
//
//}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma ble api
-(NSInteger)scanDevice:(NSArray*)serviceUUIDs withOption:(NSDictionary*)option withNotifyName:(NSString*)notifyname{
    if (self.is_ble_poweron){
        [self.scanDevicelist removeAllObjects];
        self.is_in_connecting = NO;
        self.scanNotifyName = nil;
        if (notifyname != nil){
            self.scanNotifyName = [NSString stringWithString:notifyname];
        }
        [self.bleManager scanForPeripheralsWithServices:serviceUUIDs options:option];
        
        return IRKFindBleDeviceOK;
    }else{
        return IRKFindBleDeviceFAILWithBleNotPowerON;
    }
    
}
-(void)connectDevice:(NSInteger)index{
    if(self.is_ble_poweron){
        //需要断开当前连接？
        CBPeripheral* currentperipheral = [self.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];

        if(currentperipheral){
            [self.bleManager cancelPeripheralConnection:currentperipheral];
            self.is_peripheral_wait_for_connect = YES;
            self.waitConnectIndex = index;
        }
        else{
        
            NSDictionary* d = (NSDictionary*)[self.scanDevicelist objectAtIndex:index];
            if (d == nil) {
                return;
            }
            CBPeripheral* peripheral = (CBPeripheral*)[d objectForKey:@"peripheral"];
            if(peripheral){
                [self.bleManager connectPeripheral:peripheral options:nil];
//                [self.bleManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:[NSNumber numberWithBool:YES], CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:YES], CBConnectPeripheralOptionNotifyOnNotificationKey:[NSNumber numberWithBool:YES]}];
            }
        }
    }
//    
}
-(void)disconnectDevice:(NSInteger)index{
    NSLog(@"disconnectDevice %ld",(long)index);
    if(self.is_ble_poweron ){//&& self.is_connected == IRKConnectionStateConnected){
        //需要断开当前连接？
        
        CBPeripheral* currentperipheral = [self.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
        if(currentperipheral){
            if(currentperipheral.delegate != self)
                currentperipheral.delegate = self;
            if (self.needReconnectPeripheral) {
                self.needReconnectPeripheral = nil;
            }
            self.bleManager.delegate = self;
            [self.connectedDevicelist removeObjectForKey:BLECONNECTED_DEVICE_BONG_KEY];
            self.commondata.lastBongUUID = nil;
            self.commondata.gear_subtype = @"";
            [self.commondata saveconfig];
            [self.bleManager cancelPeripheralConnection:currentperipheral];

            self.is_connected = IRKConnectionStateUnConnected;
            CBCharacteristic* notifych = (CBCharacteristic*)[self.NotifyCharacteristicDict objectForKey:BLECONNECTED_DEVICE_BONG_NOTIFY_CHARATERISTIC_KEY];
            
            if(notifych){
                 [self.NotifyCharacteristicDict removeObjectForKey:BLECONNECTED_DEVICE_BONG_NOTIFY_CHARATERISTIC_KEY];
            }
            
            [self.WriteCharacteristicDict removeObjectForKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY];
            self.is_writeable = NO;
            self.is_adv_writeable = NO;
            self.is_find_bong_write = NO;
            self.is_find_bong_notify = NO;
            self.is_in_connecting = NO;
            self.recvdata = nil;
            self.recvlen = 0;
            self.is_ready_for_next_command = YES;
            [self.commandArray removeAllObjects];
            if (self.recvdatatimeout) {
                [self.recvdatatimeout invalidate];
                self.recvdatatimeout = nil;
            }
            
            [self.connectedDevicelist removeObjectForKey:BLECONNECTED_DEVICE_BONG_KEY];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_disconnect_device object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_connect_state_changed object:nil userInfo:nil];
            [[self delegate] disconnect];

        }
        
    }
}

-(void)disconnectDevice2{
    if(self.is_ble_poweron && self.is_connected == IRKConnectionStateConnected){
        //需要断开当前连接？
        
        CBPeripheral* currentperipheral = [self.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
        if(currentperipheral){
            if(currentperipheral.delegate != self)
                currentperipheral.delegate = self;
            [self.bleManager cancelPeripheralConnection:currentperipheral];
            [self.commondata saveconfig];
        }
        
    }
}
-(void)connectDefaultDevice{
    if (self.is_in_OTA) {
        //       [self.bleManager stopScan];
        NSLog(@"in OTA mode, blecontrol don't connect bong till ota has finished");
        return;
    }
    if(self.is_ble_poweron /*&& self.isOta == NO*/){
        if(self.is_connected != IRKConnectionStateConnected){
            
            if(self.commondata.lastBongUUID && [self.commondata.lastBongUUID length]>0){
                
                NSArray* identifys = @[[[NSUUID alloc] initWithUUIDString:self.commondata.lastBongUUID]];
                NSArray* pers = [self.bleManager retrievePeripheralsWithIdentifiers:identifys];
                if([pers count]){
                    CBPeripheral * peripheral = (CBPeripheral*)[pers objectAtIndex:0];
                    NSLog(@"need to connect default Bong [%@][%@] now",self.commondata.lastBongUUID,peripheral);
                    if(peripheral.delegate != self)
                        peripheral.delegate = self;
                    [self.connectedDevicelist setObject:peripheral forKey:BLECONNECTED_DEVICE_BONG_KEY];
                    [self.bleManager connectPeripheral:peripheral options:nil];
                    //                [self.bleManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:[NSNumber numberWithBool:YES], CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:YES], CBConnectPeripheralOptionNotifyOnNotificationKey:[NSNumber numberWithBool:YES]}];
                    
                }
            }
        }else{
//            if( !self.is_find_bong_notify || !self.is_find_bong_write){
//                CBPeripheral* currentperipheral =[self.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
//                if(currentperipheral){
////                    NSLog(@"need find characteristic now");
////                    self.findchtimeout = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(findCharacteristicTimeout) userInfo:NO repeats:NO];
//
//                    if(currentperipheral.delegate != self){
//                        currentperipheral.delegate = self;
//                        [currentperipheral discoverServices:nil];
//                    }
//                }
//                
//            }
        }
    }

    
}
-(void)disconnetDefaultDevice{
    if(self.is_connected == IRKConnectionStateConnected){
        CBPeripheral* currentperipheral = [self.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
        if(currentperipheral){
            [self.bleManager cancelPeripheralConnection:currentperipheral];
        }

    }
}

-(void)submit_writeData:(NSData*)data forPeripheralKey:(NSString*)pKey forCharacteristicKey:(NSString*)ckey withRespon:(BOOL)Respon protocolcmd:(int)pcmd{
//#ifdef CUSTOM_API2
    if(self.is_ble_poweron && self.is_connected == IRKConnectionStateConnected && self.is_writeable){
        CBPeripheral* peripheral = (CBPeripheral*)[self.connectedDevicelist objectForKey:pKey];
        if(peripheral){
            CBCharacteristic* ch = (CBCharacteristic*)[self.WriteCharacteristicDict objectForKey:ckey];
            if(ch){
                //                NSLog(@"write data = %@",data);
                Byte* array = (Byte*)data.bytes;
                int cmdname = array[0];
                int cmdlen = (int)[data length];
                self.current_protocol_cmdkey = cmdname;
                int packegs;
                if (cmdlen<= 20) {
                    packegs = 1;
                }else{
                    packegs = cmdlen/20 +1;
                }
                for (int i = 0; i<packegs; i++) {
                    NSRange range;
                    if (i == packegs -1) {
                        range = NSMakeRange(i*20, cmdlen%20?cmdlen%20:20);
                    }else{
                        range = NSMakeRange(i*20, 20);
                    }
                    NSLog(@"Write data: %@ ",[data subdataWithRange:range]);
//                    NSLog(@"Write data: %@ to [%@]",[data subdataWithRange:range],ch);
                    [peripheral writeValue:[data subdataWithRange:range] forCharacteristic:ch type:CBCharacteristicWriteWithResponse];
                }
            }
            
        }
    }
//#else
//    if(self.is_ble_poweron && self.is_connected == IRKConnectionStateConnected && self.is_writeable){
//
//        
//        NSDictionary* cmdinfo = [[NSDictionary alloc] initWithObjectsAndKeys: data,@"data",pKey,@"peripheralkey",ckey, @"characteristickey",[NSNumber numberWithBool:Respon], @"respon", @"write", @"cmdtype",[NSNumber numberWithInt:pcmd], @"protocolcmd",nil];
// //       NSLog(@"%@",self.commandArray);
//        {
////            NSLog(@"check cmds");
//            if ([self.commandArray count]) {
//                for (NSDictionary* dict in self.commandArray) {
//                    NSNumber* cmd = [dict objectForKey:@"protocolcmd"];
//                    NSLog(@"protocolcmd = %d",cmd.intValue);
//                    if (cmd.intValue == pcmd) {
//                        NSLog(@"%d is already in commandArray",pcmd);
//                        return;
//                    }
//                }
//            }
//        }
//        if (pcmd >= 0xf0) {
//            [self.commandArray insertObject:cmdinfo atIndex:0];
//        }else{
//            [self.commandArray addObject:cmdinfo];
//        }
////        NSLog(@"%@",self.commandArray);
//    }
//#endif
}
-(void)submit_readData:(NSString*)peripheralKey forCharacteristicKey:(NSString*)ckey{
    if(self.is_ble_poweron && self.is_connected == IRKConnectionStateConnected){
//#ifdef CUSTOM_API2
        [self readDataToBle:peripheralKey forCharacteristicKey:ckey];
//#else
//        NSDictionary* cmdinfo = [[NSDictionary alloc] initWithObjectsAndKeys: peripheralKey,@"peripheralkey",ckey, @"characteristickey", @"read", @"cmdtype", nil];
//        [self.commandArray addObject:cmdinfo];
//#endif
    }

}

//-(void)writeDataToBle:(NSData*)data forPeripheralKey:(NSString*)pKey forCharacteristicKey:(NSString*)ckey withRespon:(BOOL)Respon{
//    if(self.is_ble_poweron && self.is_connected == IRKConnectionStateConnected && self.is_writeable){
//        CBPeripheral* peripheral = (CBPeripheral*)[self.connectedDevicelist objectForKey:pKey];
//        if(peripheral){
//            CBCharacteristic* ch = (CBCharacteristic*)[self.WriteCharacteristicDict objectForKey:ckey];
//            if(ch){
//                NSLog(@"write data = %@",data);
//                Byte* array = (Byte*)data.bytes;
//                int cmdname = array[0];
//                int cmdlen = [data length];
//                self.current_protocol_cmdkey = cmdname;
//                if (!Respon){
//                    NSLog(@"need_respone = NO");
//#if defined(CMD_HAS_RESPONSE)
//                    self.need_respone = YES;
//                    self.is_ready_for_next_command = NO;
//#else
//                    self.need_respone = NO;
//                    self.is_ready_for_next_command = YES;
//#endif
//                }else{
//                    NSLog(@"need_respone = YES");
//                    self.need_respone = YES;
//                    self.is_ready_for_next_command = NO;
//                    
//                }
//                
//                int packegs;
//                if (cmdlen<= 20) {
//                    packegs = 1;
//                }else{
//                    packegs = cmdlen/20 +1;
//                }
//                for (int i = 0; i<packegs; i++) {
//                    NSRange range;
//                    if (i == packegs -1) {
//                        range = NSMakeRange(i*20, cmdlen%20?cmdlen%20:20);
//                    }else{
//                        range = NSMakeRange(i*20, 20);
//                    }
//                    [peripheral writeValue:[data subdataWithRange:range] forCharacteristic:ch type:CBCharacteristicWriteWithResponse];
//                    NSLog(@"write to ble: %@",[data subdataWithRange:range]);
//#if defined(CMD_HAS_RESPONSE)
//#else
//                    if (cmdname == HJT_CMD_PHONE2DEVICE_MODESET) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_modeset object:nil];
//                    }else if (cmdname == HJT_CMD_PHONE2DEVICE_WEATHER){
//                        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_finish_weather_cmd object:nil];
//                    }
//#endif
//                }
//
////                [peripheral writeValue:data forCharacteristic:ch type:CBCharacteristicWriteWithResponse];
//                
//            }
//        
//        }
//        
//    }
//}
-(void)readDataToBle:(NSString*)peripheralKey forCharacteristicKey:(NSString*)ckey {
    if(self.is_ble_poweron && self.is_connected == IRKConnectionStateConnected){
        CBPeripheral* peripheral = (CBPeripheral*)[self.connectedDevicelist objectForKey:peripheralKey];
        if(peripheral){
            CBCharacteristic* ch = (CBCharacteristic*)[self.ReadCharacteristicDict objectForKey:ckey];
            if(ch){
                [peripheral readValueForCharacteristic:ch];
                
            }
            
        }
        
    }
}
-(void)recvDataTimeout{
    NSLog(@"BleControl::recvDataTimeout");
    if (self.recvdatatimeout) {
        [self.recvdatatimeout invalidate];
        self.recvdatatimeout = nil;
    }

    [[self delegate] recvTimeout];
    self.recvdata = nil;
    self.needrecvpackege = 0;
    self.recvpackege = 0;
    self.recvdata = nil;
    self.recvlen = 0;
    self.is_ready_for_next_command = YES;
    
}
-(void)findCharacteristicTimeout{
    NSLog(@"BleControl::findCharacteristicTimeout");
    [self disconnetDefaultDevice];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma ble bluemanager protocol
-(void)stopScanDevice{
    if(self.bleManager){
        self.is_scaning = NO;
        [self.bleManager stopScan];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            // Scans for any peripheral
            NSLog(@"CBCentralManagerStatePoweredOn");
            self.is_ble_poweron = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_ble_power_on object:nil];
            [self connectDefaultDevice];
            break;
        default:
            self.is_ble_poweron = NO;
            self.is_connected = IRKConnectionStateUnConnected;
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_ble_power_off object:nil];
            NSLog(@"Central Manager did change state");
            break;
    }
}
static NSComparisonResult RssiCompare(NSDictionary* d1, NSDictionary* d2, void* context)
{
    // 你要实现的函数, 返回值为NSOrderedAscending, NSOrderedSame, NSOrderedDescending中的一个
    NSNumber* rssi1 = [d1 objectForKey:@"RSSI"];
    NSNumber* rssi2 = [d2 objectForKey:@"RSSI"];
    if (rssi1.intValue > rssi2.intValue) {
        return NSOrderedAscending;
    }else if(rssi1.intValue == rssi2.intValue){
        return NSOrderedSame;
    }else{
        return NSOrderedDescending;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    // Stops scanning for peripheral
    //   [self.manager stopScan];
    if (RSSI.intValue == 127) {
        return;
    }
    NSArray *arrayBle = [self.commondata.bleName componentsSeparatedByString:@","];
    BOOL isfind = NO;
    for (NSString* bleprefix in arrayBle) {
        if ([peripheral.name hasPrefix:bleprefix]) {
            isfind = YES;
            break;
        }
    }
    if (isfind == NO) {
        return;
    }
    NSLog(@"find %@ Rssi:%d", peripheral, RSSI.intValue);

    if(peripheral.name!=nil){
//#ifdef CUSTOM_HAIER
        NSData *data = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
        uint8_t* bytearray = (uint8_t*)[data bytes];
        
        NSString *lastStr = @"";
//#ifndef CUSTOM_ZZB
        if([data length] > 6)
        {
            for(int i = (int)[data length] - 2;i < [data length];i++)
            {
                NSString *newHexStr = [NSString stringWithFormat:@"%.2x",bytearray[i]&0xff];///16进制数
                lastStr = [NSString stringWithFormat:@"%@%@",lastStr,newHexStr];
            }
        }
//#endif
        NSDictionary* p = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral,@"peripheral",RSSI,@"RSSI",lastStr,@"LAST_NAME", nil];

        
//        NSDictionary* p = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral,@"peripheral",RSSI,@"RSSI", nil];
        __block NSString* uuid = peripheral.identifier.UUIDString;
        __block BOOL isfind = NO;
        [self.scanDevicelist enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary* dict = (NSDictionary*)obj;
            CBPeripheral* peri = [dict objectForKey:@"peripheral"];
            if ([peri.identifier.UUIDString isEqualToString:uuid]) {
                isfind = YES;
                *stop = YES;
            }
            
        }];
        if (isfind == NO) {
            [self.scanDevicelist addObject:p];
            [self.scanDevicelist sortUsingFunction:RssiCompare context:nil];
        }
        
        NSLog(@"find %@ Rssi:%d", peripheral, RSSI.intValue);
        //       [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_scan_device object:nil userInfo:nil];
//        if (RSSI.intValue < AUTO_CONNECT_RSSI) {
//            
//            return;
//        }
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_scan_device object:nil userInfo:nil];
        //       [self.bleManager stopScan];
//        if (self.is_in_connecting == NO) {
//            [self.bleManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:[NSNumber numberWithBool:YES], CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:YES], CBConnectPeripheralOptionNotifyOnNotificationKey:[NSNumber numberWithBool:YES]}];
//            self.is_in_connecting = YES;
//        }

    }


}
    
    
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"BleControl::didConnectPeripheral %@",peripheral);
    [self.connectedDevicelist setObject:peripheral forKey:BLECONNECTED_DEVICE_BONG_KEY];
    self.is_connected = IRKConnectionStateConnected;
    NSString* lastuuid = self.commondata.lastBongUUID;
    self.commondata.lastBongUUID = [peripheral.identifier UUIDString];
    [self.commondata saveconfig];
    if(![self.commondata.lastBongUUID isEqualToString:lastuuid]){
        //切换手环时要去重置datacenter
        //[[NSNotificationCenter defaultCenter] postNotificationName:notify_key_sycn_finish_need_reloaddata object:nil];
    }

//    for(CBPeripheral* p in self.scanDevicelist){
    
    for(NSDictionary* d in self.scanDevicelist)
    {
        CBPeripheral* p = (CBPeripheral*)[d objectForKey:@"peripheral"];
        if([p.identifier.UUIDString isEqual:peripheral.identifier.UUIDString]){
            
            //将last_4_name保存到bonginfo
            NSString *last_name = [d objectForKey:@"LAST_NAME"];
            
            NSMutableDictionary* bonginfo = (NSMutableDictionary*)[self.commondata getBongInformation:self.commondata.lastBongUUID];
            if (bonginfo == nil) {
                bonginfo = [[NSMutableDictionary alloc] init];
            }
            [bonginfo setObject:last_name forKey:BONGINFO_KEY_LAST4NAME];
            [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bonginfo];
            
            [self.scanDevicelist removeObject:d];
            break;
        }
        
    }
//    for(NSDictionary* d in self.scanDevicelist){
//        CBPeripheral* p = (CBPeripheral*)[d objectForKey:@"peripheral"];
//        if([p.identifier.UUIDString isEqual:peripheral.identifier.UUIDString]){
//            [self.scanDevicelist removeObject:d];
//            break;
//        }
//    }
    
    
    //发现服务
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    [peripheral readRSSI];

    NSMutableDictionary* bi = [self.commondata getBongInformation:self.commondata.lastBongUUID];
    if (bi == nil) {
        bi = [[NSMutableDictionary alloc] init];
    }
    //    NSString* name = [[peripheral.name stringByReplacingOccurrencesOfString:@" " withString:@""] uppercaseString];
    NSString* name = peripheral.name;
    [bi setObject:name forKey:BONGINFO_KEY_BLENAME];
    
//    if ([name hasPrefix:GEAR_BLE_NAME_B108]) {
//        self.commondata.gear_subtype = GEAR_SUBTYPE_B108;
//        [bi setObject:GEAR_SUBTYPE_B108 forKey:BONGINFO_KEY_SUBGEARTYPE];
//    }else if ([name hasPrefix:GEAR_BLE_NAME_LEWO]){
//        self.commondata.gear_subtype = GEAR_SUBTYPE_LEWO;
//        [bi setObject:GEAR_SUBTYPE_LEWO forKey:BONGINFO_KEY_SUBGEARTYPE];
//        
//    }else if ([name hasPrefix:GEAR_BLE_NAME_FITRIST]){
//        self.commondata.gear_subtype = GEAR_SUBTYPE_FITRIST;
//        [bi setObject:GEAR_SUBTYPE_FITRIST forKey:BONGINFO_KEY_SUBGEARTYPE];
//        
//    }else if([name hasPrefix:GEAR_BLE_NAME_SMART]){
//        self.commondata.gear_subtype = GEAR_SUBTYPE_SMART;
//        [bi setObject:GEAR_SUBTYPE_SMART forKey:BONGINFO_KEY_SUBGEARTYPE];
//    }
//    else if([name hasPrefix:GEAR_BLE_NAME_EIROGA]){
//        self.commondata.gear_subtype = GEAR_SUBTYPE_EIROGA;
//        [bi setObject:GEAR_SUBTYPE_EIROGA forKey:BONGINFO_KEY_SUBGEARTYPE];
//    }else if([name hasPrefix:GEAR_BLE_NAME_FIT_BAND]){
//        self.commondata.gear_subtype = GEAR_SUBTYPE_FITBAND;
//        [bi setObject:GEAR_SUBTYPE_FITBAND forKey:BONGINFO_KEY_SUBGEARTYPE];
//    }
//    [self.commondata saveconfig];
    [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bi];

    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_connect_device object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_connect_state_changed object:nil userInfo:nil];
    
//强制OTA
    //[self getLatestFirwareVersionFromServer];
}


//-(void)getLatestFirwareVersionFromServer{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        NSString* productcode = [self.commondata getValueFromBonginfoByKey:BONGINFO_KEY_PRODUCTCODE];
////        NSString* version = [self.commondata getValueFromBonginfoByKey:BONGINFO_KEY_VERSIONCODE];
//        NSString* urlstr = [NSString stringWithFormat:@"http://download.keeprapid.com/apps/smartband/mgcool/fwupdater/en/%@/update.json",productcode];
//        NSLog(@"urlstr=%@",urlstr);
//        NSURL  *url = [NSURL URLWithString:urlstr];
//        NSLog(@"url = %@",url);
//        
//        NSData *urlData = [NSData dataWithContentsOfURL:url];
//        if ( urlData ){
//            NSError* error = nil;
//            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&error];
//            if (error) {return;}
//            NSLog(@"%@",responseDict);
//            NSDictionary* updatInfo = [responseDict objectForKey:FIRMINFO_DICT_UPDATEINFO];
//            if (updatInfo) {
////                NSString* fwDesc = [updatInfo objectForKey:FIRMINFO_DICT_FWDESC];
////                NSString* fwName = [updatInfo objectForKey:FIRMINFO_DICT_FWNAME];
//                NSString* fwUrl = [updatInfo objectForKey:FIRMINFO_DICT_FWURL];
////                NSString* filename = [[NSURL URLWithString:fwUrl] lastPathComponent];
//                NSString* versionCode = [updatInfo objectForKey:FIRMINFO_DICT_VERSIONCODE];
//                NSString* versionName = [updatInfo objectForKey:FIRMINFO_DICT_VERSIONNAME];
//                NSString* currentfw;
//                
//                NSMutableDictionary* bonginfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
//                if (bonginfo) {
//                    NSString* fwinfo = [bonginfo objectForKey:BONGINFO_KEY_FIRMWARE];
//                    currentfw = fwinfo;
//                }else{
//                    currentfw = @"";
//                }
//                
//                NSString* currentCode = [self getVersionCode:currentfw];
//                NSString* returnCode = [self getVersionCode:versionCode];
//                NSComparisonResult result = [currentCode caseInsensitiveCompare:returnCode];
//                
//                if (result == NSOrderedAscending) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSString* notifystr = [NSString stringWithFormat:@"%@\n\n%@%@(%@)",NSLocalizedString(@"OTA_FirmwareServer_Found_Latest", nil),
//                                               NSLocalizedString(@"OTA_FirmwareServer_Newfirm", nil),
//                                               versionCode,
//                                               versionName];
//                        
//                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:notifystr delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OTA_Confirm", nil),nil];
//                        alert.tag = 100;
//                        [alert show];
//                        
//                    });
//                    return;
//                }else{return;}
//            }else{return;}
//        }else{return;}
//    });
//}
//
//-(NSString*)getVersionCode:(NSString*)firmware{
//    
//    return [firmware substringWithRange:NSMakeRange([firmware length]-3, 3)];
//}

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (alertView.tag == 100) {
//        if (buttonIndex != alertView.cancelButtonIndex) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                CZJKOTAViewController *otaview = [[CZJKOTAViewController alloc] init];
//                otaview.isJump=YES;
//                UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:otaview];
//                AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//                [delegate.window.rootViewController presentViewController:navi animated:YES completion:nil];
//            });
//        }
//    }
//}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"BleControl::didFailToConnectPeripheral %@",peripheral);
    self.is_connected = IRKConnectionStateUnknown;
    self.is_in_connecting = NO;
 //   [self.connectedDevicelist setObject:nil forKey:BLECONNECTED_DEVICE_BONG_KEY];
    [self.connectedDevicelist removeObjectForKey:BLECONNECTED_DEVICE_BONG_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_connect_device_err object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_connect_state_changed object:nil userInfo:nil];
    [self.bleManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:[NSNumber numberWithBool:YES], CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:YES], CBConnectPeripheralOptionNotifyOnNotificationKey:[NSNumber numberWithBool:YES]}];

    
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"BleControl::didDisconnectPeripheral %@",peripheral);
    self.is_connected = IRKConnectionStateUnConnected;
    CBCharacteristic* notifych = (CBCharacteristic*)[self.NotifyCharacteristicDict objectForKey:BLECONNECTED_DEVICE_BONG_NOTIFY_CHARATERISTIC_KEY];
    
    if(notifych){
        [peripheral setNotifyValue:NO forCharacteristic:notifych];
        if ([self.NotifyCharacteristicDict.allKeys containsObject:BLECONNECTED_DEVICE_BONG_NOTIFY_CHARATERISTIC_KEY]) {
            [self.NotifyCharacteristicDict removeObjectForKey:BLECONNECTED_DEVICE_BONG_NOTIFY_CHARATERISTIC_KEY];
            
        }
//       [self.NotifyCharacteristicDict removeObjectForKey:BLECONNECTED_DEVICE_BONG_NOTIFY_CHARATERISTIC_KEY];
    }
    if ([self.WriteCharacteristicDict.allKeys containsObject:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY]) {
        [self.WriteCharacteristicDict removeObjectForKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY];

    }

#ifdef HAS_OTA
    CBCharacteristic* otacmdch = (CBCharacteristic*)[self.NotifyCharacteristicDict objectForKey:BLECONNECTED_DEVICE_BONG_NOTIFY_OTACMD_CHARATERISTIC_KEY];
    if(otacmdch){
        [peripheral setNotifyValue:NO forCharacteristic:otacmdch];
        if ([self.NotifyCharacteristicDict.allKeys containsObject:BLECONNECTED_DEVICE_BONG_NOTIFY_OTACMD_CHARATERISTIC_KEY]) {
            [self.NotifyCharacteristicDict removeObjectForKey:BLECONNECTED_DEVICE_BONG_NOTIFY_OTACMD_CHARATERISTIC_KEY];
            
        }
        //        [self.NotifyCharacteristicDict removeObjectForKey:BLECONNECTED_DEVICE_BONG_NOTIFY_ADV_CHARATERISTIC_KEY];
    }
    CBCharacteristic* otadatach = (CBCharacteristic*)[self.NotifyCharacteristicDict objectForKey:BLECONNECTED_DEVICE_BONG_NOTIFY_OTADATA_CHARATERISTIC_KEY];
    if(otadatach){
        [peripheral setNotifyValue:NO forCharacteristic:otadatach];
        if ([self.NotifyCharacteristicDict.allKeys containsObject:BLECONNECTED_DEVICE_BONG_NOTIFY_OTADATA_CHARATERISTIC_KEY]) {
            [self.NotifyCharacteristicDict removeObjectForKey:BLECONNECTED_DEVICE_BONG_NOTIFY_OTADATA_CHARATERISTIC_KEY];
            
        }
        //        [self.NotifyCharacteristicDict removeObjectForKey:BLECONNECTED_DEVICE_BONG_NOTIFY_ADV_CHARATERISTIC_KEY];
    }
    if ([self.WriteCharacteristicDict.allKeys containsObject:BLECONNECTED_DEVICE_BONG_WRITE_OTADATA_CHARATERISTIC_KEY]) {
        [self.WriteCharacteristicDict removeObjectForKey:BLECONNECTED_DEVICE_BONG_WRITE_OTADATA_CHARATERISTIC_KEY];
        
    }

#endif

    
    self.is_writeable = NO;
    self.is_adv_writeable = NO;
    self.is_find_bong_write = NO;
    self.is_find_bong_notify = NO;
    self.recvdata = nil;
    self.isOTAData = NO;
    self.isOTACmd = NO;
    self.recvlen = 0;
    self.is_ready_for_next_command = YES;
    if ([self.commandArray respondsToSelector:@selector(removeAllObjects)]) {
        [self.commandArray removeAllObjects];
    }else{
        self.commandArray = [[NSMutableArray alloc] init];
    }
    
    if (self.recvdatatimeout) {
        [self.recvdatatimeout invalidate];
        self.recvdatatimeout = nil;
    }

    
//    [self.connectedDevicelist removeObjectForKey:BLECONNECTED_DEVICE_BONG_KEY];
//    [self.scanDevicelist addObject:[self.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY]];
    if ([self.connectedDevicelist.allKeys containsObject:BLECONNECTED_DEVICE_BONG_KEY]) {
        [self.connectedDevicelist removeObjectForKey:BLECONNECTED_DEVICE_BONG_KEY];
        
    }
//    [self.connectedDevicelist removeObjectForKey:BLECONNECTED_DEVICE_BONG_KEY];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_disconnect_device object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_connect_state_changed object:nil userInfo:nil];
    [[self delegate] disconnect];
    if(self.is_peripheral_wait_for_connect){
        self.is_peripheral_wait_for_connect = NO;
        if (self.scanDevicelist.count > self.waitConnectIndex) {
            NSDictionary* d = (NSDictionary*)[self.scanDevicelist objectAtIndex:self.waitConnectIndex];
            CBPeripheral* p = (CBPeripheral*)[d objectForKey:@"peripheral"];
            if(p){
                [self.bleManager connectPeripheral:p options:nil];
            }

        }
    }else{
        if (![self.commondata.lastBongUUID isEqualToString:@""]) {
//            self.needReconnectPeripheral = peripheral;
//            NSLog(@"need to connect [%@] when disconnect happend",self.commondata.lastBongUUID);
//            [self.bleManager connectPeripheral:self.needReconnectPeripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:[NSNumber numberWithBool:YES], CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:YES], CBConnectPeripheralOptionNotifyOnNotificationKey:[NSNumber numberWithBool:YES]}];
            [self connectDefaultDevice];
        }
    }
    
    
}
#pragma ble peripheral protocol
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"BleControl::peripheral:didDiscoverServices");
    for(CBService* service in peripheral.services){
        NSLog(@"%@",service);
//        [peripheral discoverCharacteristics:nil forService:service];

#ifdef HAS_OTA
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:self.commondata.BongNotifyCharacterUUID],[CBUUID UUIDWithString:self.commondata.BongWriteCharacterUUID],[CBUUID UUIDWithString:self.commondata.BongBatteryCharacterUUID],[CBUUID UUIDWithString:self.commondata.BongOtaDataCharaterUUID],[CBUUID UUIDWithString:self.commondata.BongOtaCMDCharaterUUID]] forService:service];
#else
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:self.commondata.BongNotifyCharacterUUID],[CBUUID UUIDWithString:self.commondata.BongWriteCharacterUUID],[CBUUID UUIDWithString:self.commondata.BongBatteryCharacterUUID]] forService:service];
#endif
    }
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"BleControl::peripheral:didDiscoverCharacteristicsForService error%@",error);
    if(error)
        return;
    if(self.findchtimeout){
        [self.findchtimeout invalidate];
        self.findchtimeout = nil;
    }
    for(CBCharacteristic* ch in service.characteristics){
        NSLog(@"%@",ch);
        if([[self getUUID:ch.UUID] isEqual:self.commondata.BongNotifyCharacterUUID] && (ch.properties & CBCharacteristicPropertyNotify)){

            [peripheral setNotifyValue:YES forCharacteristic:ch];
        }else if([[self getUUID:ch.UUID] isEqual:self.commondata.BongWriteCharacterUUID] && (ch.properties & CBCharacteristicPropertyWrite)){
            [self.WriteCharacteristicDict setObject:ch forKey:BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY];
            self.is_writeable = YES;
            self.is_find_bong_write = YES;
//            [[self delegate] getReady];
        }else if([[self getUUID:ch.UUID] isEqual:self.commondata.BongBatteryCharacterUUID]){
            //            if(ch.properties | CBCharacteristicPropertyNotify)
            //                [peripheral setNotifyValue:YES forCharacteristic:ch];
            [peripheral setNotifyValue:YES forCharacteristic:ch];
            
            [self.ReadCharacteristicDict setObject:ch forKey:BLECONNECTED_DEVICE_BONG_BATTERY_CHARATERISTIC_KEY];
        }

#ifdef HAS_OTA
        else if([[self getUUID:ch.UUID] isEqual:self.commondata.BongOtaCMDCharaterUUID]){
            [peripheral setNotifyValue:YES forCharacteristic:ch];
            [self.NotifyCharacteristicDict setObject:ch forKey:BLECONNECTED_DEVICE_BONG_NOTIFY_OTACMD_CHARATERISTIC_KEY];
        }
        else if([[self getUUID:ch.UUID] isEqual:self.commondata.BongOtaDataCharaterUUID]){
            [peripheral setNotifyValue:YES forCharacteristic:ch];
            [self.NotifyCharacteristicDict setObject:ch forKey:BLECONNECTED_DEVICE_BONG_NOTIFY_OTADATA_CHARATERISTIC_KEY];
            [self.WriteCharacteristicDict setObject:ch forKey:BLECONNECTED_DEVICE_BONG_WRITE_OTADATA_CHARATERISTIC_KEY];
        }

#endif
        
    }

    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"BleControl::didUpdateValueForCharacteristic %@",characteristic.value);

    NSData *data = [characteristic.value copy];
#ifdef HAS_OTA
    if ([[self getUUID:characteristic.UUID] isEqualToString:self.commondata.BongOtaCMDCharaterUUID]||
        [[self getUUID:characteristic.UUID] isEqualToString:self.commondata.BongOtaDataCharaterUUID]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_ble_ota_resp object:data userInfo:nil];
        return;
    }
#endif
 //   NSLog(@"%@",data);
    //NSDictionary* userinfo = @{@"data":data};
//#ifdef CUSTOM_API2
    if([[self getUUID:characteristic.UUID] isEqualToString:self.commondata.BongNotifyCharacterUUID]|| [[self getUUID:characteristic.UUID] isEqualToString:self.commondata.BongAdvNotifyCharacterUUID]){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[self delegate] ReceiveData2:[data copy]];
//            
//        });
        [[self delegate] ReceiveData2:[data copy]];
    }else if([[self getUUID:characteristic.UUID] isEqualToString:self.commondata.BongBatteryCharacterUUID]){
        NSDictionary* userinfo = @{@"data":data};
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_ble_characteristic_batterylevel_notify_update object:nil userInfo:userinfo];
    }
//#else
//    if([[self getUUID:characteristic.UUID] isEqualToString:self.commondata.BongNotifyCharacterUUID]|| [[self getUUID:characteristic.UUID] isEqualToString:self.commondata.BongAdvNotifyCharacterUUID]){
//        //解析第一个包的内容获得要获取的包的长度
//        if(self.recvdata == nil){
//             Byte* barray = (Byte*)data.bytes;
//            int cmdname = barray[0];
//            //不是要收的消息
//            if(cmdname == 0xf5 || cmdname == 0xF3 || cmdname == 0xF4 ||cmdname == 0xF6 || cmdname == 0xFA){
////                self.recvlen = 8;
////                self.needrecvpackege = 1;
//                self.recvlen = barray[1];
//                self.needrecvpackege = (self.recvlen+2)/20+1;
//            }
//            else{
//                BOOL is_correct = [self.delegate isCorrectRsp:cmdname byCmdname:self.current_protocol_cmdkey];
//                if (is_correct == NO) {
//                    NSLog(@"UNKNOW MESSAGE discard");
//                    return;
//                }
//                self.recvlen = barray[1];
//                self.needrecvpackege = (self.recvlen+3)/20+1;
//            }
//            self.recvdata = [[NSMutableData alloc] init];
//            NSLog(@"recvlen = %d", self.recvlen);
//            
//        }
//        self.recvpackege +=1;
//        [self.recvdata appendData:data];
//        NSLog(@"recvdata len=%lu,needrecvpackege=%d, recvpackege = %d, %@", (unsigned long)[self.recvdata length],self.needrecvpackege,self.recvpackege, self.recvdata);
//        if(self.recvpackege == self.needrecvpackege){
//            if (self.recvdatatimeout) {
//                [self.recvdatatimeout invalidate];
//                self.recvdatatimeout = nil;
//            }
//
//            [[self delegate] ReceiveData:[self.recvdata copy]];
//            self.is_ready_for_next_command =YES;
//            self.recvdata = nil;
//            self.recvlen = 0;
//            self.needrecvpackege = 0;
//            self.recvpackege = 0;
//        }
//    }else if([[self getUUID:characteristic.UUID] isEqualToString:self.commondata.BongBatteryCharacterUUID]){
//        NSDictionary* userinfo = @{@"data":data};
//        if (self.recvdatatimeout) {
//            [self.recvdatatimeout invalidate];
//            self.recvdatatimeout = nil;
//        }
//        Byte* bytearray = (Byte*)data.bytes;
//        
//        CGFloat batterylevel = bytearray[0]/100.0;
//        NSMutableDictionary* bandinfo = [self.commondata getBongInformation:self.commondata.lastBongUUID];
//        if (bandinfo) {
//            [bandinfo setObject:[NSNumber numberWithFloat:batterylevel] forKey:BONGINFO_KEY_BATTERYLEVEL];
//        }
//        [self.commondata setBongInformation:self.commondata.lastBongUUID Information:bandinfo];
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_ble_characteristic_batterylevel_notify_update object:nil userInfo:userinfo];
//        self.is_ready_for_next_command =YES;
//        self.recvdata = nil;
//        self.needrecvpackege = 0;
//        self.recvpackege = 0;
//        self.recvdata = nil;
//        self.recvlen = 0;
//
//    }
//#endif
    
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"BleControl::didWriteValueForCharacteristic self.current_protocol_cmdkey = %d",self.current_protocol_cmdkey);
    if (error) {
        NSLog(@"BleControl::didWriteValueForCharacteristic error = %@",error);
    }
#ifdef HAS_OTA
    if ([[self getUUID:characteristic.UUID] isEqualToString:self.commondata.BongOtaDataCharaterUUID] ||
        [[self getUUID:characteristic.UUID] isEqualToString:self.commondata.BongOtaCMDCharaterUUID] ) {
        NSLog(@"OTADATA characteristic did write error = %@",error);
        return;
    }
#endif
//#ifdef CUSTOM_API2
    if(self.current_protocol_cmdkey == 0x24 || self.current_protocol_cmdkey == 0xFC){
        [self.delegate doNext];
    }
//#else
//    if (self.is_ready_for_next_command == NO) {
//        self.is_ready_for_next_command = NO;
//        self.recvdata = nil;
//        if (self.need_respone) {
//            if (self.recvdatatimeout) {
//                [self.recvdatatimeout invalidate];
//                self.recvdatatimeout = nil;
//            }
//            self.recvdatatimeout = [NSTimer scheduledTimerWithTimeInterval:BLE_RECV_DATA_TIMEOUT target:self selector:@selector(recvDataTimeout) userInfo:NO repeats:NO];
//            
//        }else{
//            if (self.recvdatatimeout) {
//                [self.recvdatatimeout invalidate];
//                self.recvdatatimeout = nil;
//            }
//            self.is_ready_for_next_command = YES;
//        }
//        self.needrecvpackege = 0;
//        self.recvpackege = 0;
//        self.recvdata = nil;
//        self.recvlen = 0;
//    }
//#endif

    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"BleControl::didUpdateNotificationStateForCharacteristic [%@]", [self getUUID:characteristic.UUID]);
    if([[self getUUID:characteristic.UUID] isEqual:self.commondata.BongNotifyCharacterUUID]){
        self.is_find_bong_notify = YES;
        [self.NotifyCharacteristicDict setObject:characteristic forKey:BLECONNECTED_DEVICE_BONG_NOTIFY_CHARATERISTIC_KEY];
#ifdef HAS_OTA
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_ble_ota_charater_change object:characteristic userInfo:nil];
#endif
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[self delegate] getReady];
//
//        });
        [[self delegate] getReady];
    }
    
    //modify:新的获取电池电量的方法
    if([[self getUUID:characteristic.UUID] isEqual:self.commondata.BongBatteryCharacterUUID])
    {
        if(characteristic.value != nil)
        {
            NSLog(@"=====================================================%@",characteristic.value);
            NSDictionary* userinfo = @{@"data":characteristic.value};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_ble_characteristic_batterylevel_notify_update object:nil userInfo:userinfo];
        }

    }

#ifdef HAS_OTA
    else if([[self getUUID:characteristic.UUID] isEqual:self.commondata.BongOtaCMDCharaterUUID]){
        self.isOTACmd = YES;
//        [self.NotifyCharacteristicDict setObject:characteristic forKey:BLECONNECTED_DEVICE_BONG_NOTIFY_OTACMD_CHARATERISTIC_KEY];
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_ble_ota_charater_change object:characteristic userInfo:nil];
    }
    else if([[self getUUID:characteristic.UUID] isEqual:self.commondata.BongOtaDataCharaterUUID]){
        self.isOTAData = YES;
//        [self.NotifyCharacteristicDict setObject:characteristic forKey:BLECONNECTED_DEVICE_BONG_NOTIFY_OTADATA_CHARATERISTIC_KEY];
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_ble_ota_charater_change object:characteristic userInfo:nil];
    }

#endif
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    
    if (error){
        NSLog(@"peripheralDidUpdateRSSI %@",error);
        //        [peripheral readRSSI];
    }else{
 //       NSLog(@"peripheralDidUpdateRSSI %@",peripheral.RSSI);
//        [[self delegate] UpdateRSSI:[peripheral.RSSI intValue]];
//        NSNumber* r = [NSNumber numberWithInt:peripheral.RSSI.intValue];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notify_key_did_update_rssi object:nil userInfo:@{@"RSSI":[NSNumber numberWithInt:peripheral.RSSI.intValue]}];

    }
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(ReadRssiTimeout) userInfo:nil repeats:NO];

}
-(void)ReadRssiTimeout{
    CBPeripheral* currentperipheral = [self.connectedDevicelist objectForKey:BLECONNECTED_DEVICE_BONG_KEY];
    if (currentperipheral) {
        //           NSLog(@"readRSSI");
        [currentperipheral readRSSI];
    }
    
}

-(NSString*)getUUID:(CBUUID*)uuid{
    /*
    if ([cbuuid respondsToSelector:@selector(UUIDString)]) {
        return cbuuid.UUIDString;
    }else{
        NSData* data = cbuuid.data;
        if ([data length] == 2)
        {
            const unsigned char *tokenBytes = [data bytes];
            return [NSString stringWithFormat:@"%02x%02x", tokenBytes[0], tokenBytes[1]];
        }
        else if ([data length] == 16)
        {
            NSUUID* nsuuid = [[NSUUID alloc] initWithUUIDBytes:[data bytes]];
            return [nsuuid UUIDString];
        }
        
        return [cbuuid description]; // an error?
    }
     */
    NSString* aStr;
    if ([uuid respondsToSelector:@selector(UUIDString)]) {
        return [uuid.UUIDString uppercaseString];
    }
    else{
        if ([uuid.data length] == 2) {
            const unsigned char *tokenBytes = [uuid.data bytes];
            aStr = [NSString stringWithFormat:@"%02x%02x", tokenBytes[0], tokenBytes[1]];
        }
        else{
            NSUUID* tmpuuid = [[NSUUID alloc] initWithUUIDBytes:[uuid.data bytes]];
            aStr = tmpuuid.UUIDString;
        }
        //        aStr = [[NSString alloc] initWithData:ch.UUID.data encoding:NSUTF8StringEncoding];
        aStr = [aStr uppercaseString];
//        NSLog(@"astr = %@",aStr);
        return aStr;
    }
    
}
-(void)restart_ble{
    if (self.bleManager) {
        self.bleManager = nil;
    }
    self.bleManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

-(void)IntoOTA:(BOOL)flag{
    self.is_in_OTA = flag;
}
        
@end
