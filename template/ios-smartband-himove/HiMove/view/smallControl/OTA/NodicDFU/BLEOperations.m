//
//  BLEOperations.m
//  nRF Toolbox
//
//  Created by Kamran Saleem Soomro on 07/07/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import "BLEOperations.h"
#import "Utility.h"

@implementation BLEOperations

bool isDFUPacketCharacteristicFound, isDFUControlPointCharacteristic, isDFUVersionCharacteristicFound, isDFUServiceFound;

-(BLEOperations *) initWithDelegate:(id<BLEOperationsDelegate>) delegate
{
    if (self = [super init])
    {
        self.bleDelegate = delegate;        
    }
    return self;
}

-(void)setBluetoothCentralManager:(CBCentralManager *)manager
{
    self.centralManager = manager;
    self.centralManager.delegate = self;
}

-(void)connectDevice:(CBPeripheral *)peripheral
{
    self.bluetoothPeripheral = peripheral;
    self.bluetoothPeripheral.delegate = self;
    [self.centralManager connectPeripheral:peripheral options:nil];
}

-(void)searchDFURequiredCharacteristics:(CBService *)service
{
    isDFUControlPointCharacteristic = NO;
    isDFUPacketCharacteristicFound = NO;
    isDFUVersionCharacteristicFound = NO;
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Found characteristic %@",characteristic.UUID);
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:dfuControlPointCharacteristicUUIDString]]) {
            NSLog(@"Control Point characteristic found");
            isDFUControlPointCharacteristic = YES;
            self.dfuControlPointCharacteristic = characteristic;
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:dfuPacketCharacteristicUUIDString]]) {
            NSLog(@"Packet Characteristic is found");
            isDFUPacketCharacteristicFound = YES;
            self.dfuPacketCharacteristic = characteristic;
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:dfuVersionCharacteritsicUUIDString]]) {
            NSLog(@"Version Characteristic is found");
            isDFUVersionCharacteristicFound = YES;
            self.dfuVersionCharacteristic = characteristic;
        }    }
}

#pragma mark - CentralManager delegates
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"centralManagerDidUpdateState");
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral");
    [self.bluetoothPeripheral discoverServices:nil];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didDisconnectPeripheral");
    [self.bleDelegate onDeviceDisconnected:peripheral];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral");
    [self.bleDelegate onDeviceDisconnected:peripheral];
}

#pragma mark - CBPeripheral delegates

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    isDFUServiceFound = NO;
    NSLog(@"didDiscoverServices, found %d services",peripheral.services.count);
    for (CBService *service in peripheral.services) {
        NSLog(@"discovered service %@",service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:dfuServiceUUIDString]]) {
            NSLog(@"DFU Service is found");
            isDFUServiceFound = YES;
        }
        [self.bluetoothPeripheral discoverCharacteristics:nil forService:service];
    }
    if (!isDFUServiceFound) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error on discovering service\n Message: Required DFU service not available on peripheral"];
        [self.centralManager cancelPeripheralConnection:peripheral];
        [self.bleDelegate onError:errorMessage];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"didDiscoverCharacteristicsForService");
    if ([service.UUID isEqual:[CBUUID UUIDWithString:dfuServiceUUIDString]]) {
        [self searchDFURequiredCharacteristics:service];
        if (isDFUControlPointCharacteristic && isDFUPacketCharacteristicFound && isDFUVersionCharacteristicFound) {
            [self.bluetoothPeripheral readValueForCharacteristic:self.dfuVersionCharacteristic];
            [self.bleDelegate onDeviceConnectedWithVersion:self.bluetoothPeripheral
                                  withPacketCharacteristic:self.dfuPacketCharacteristic
                             andControlPointCharacteristic:self.dfuControlPointCharacteristic
                                  andVersionCharacteristic:self.dfuVersionCharacteristic];            
        }
        else if (isDFUControlPointCharacteristic && isDFUPacketCharacteristicFound && isDFUVersionCharacteristicFound == NO) {
            [self.bleDelegate onDeviceConnected:self.bluetoothPeripheral
                       withPacketCharacteristic:self.dfuPacketCharacteristic
                  andControlPointCharacteristic:self.dfuControlPointCharacteristic];
        }
        else {
            NSString *errorMessage = [NSString stringWithFormat:@"Error on discovering characteristics\n Message: Required DFU characteristics are not available on peripheral"];
            [self.centralManager cancelPeripheralConnection:peripheral];
            [self.bleDelegate onError:errorMessage];
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
//    NSLog(@"didUpdateValueForCharacteristic");
    if (error) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error on BLE Notification\n Message: %@",[error localizedDescription]];
        NSLog(@"Error in Notification state: %@",[error localizedDescription]);
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:dfuVersionCharacteritsicUUIDString]]) {
            NSLog(@"Error in Reading DfuVersionCharacteritsic. Please enable Service Changed Indication in your firmware, reset Bluetooth from IOS Settings and then try again");
            errorMessage = [NSString stringWithFormat:@"Error on BLE Notification\n Message: %@\n Please enable Service Changed Indication in your firmware, reset Bluetooth from IOS Settings and then try again",[error localizedDescription]];
            [self.bleDelegate onReadDfuVersion:0];
        }
        [self.bleDelegate onError:errorMessage];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:dfuVersionCharacteritsicUUIDString]]) {
        const uint8_t *version = [characteristic.value bytes] ;
        NSLog(@"dfu Version Characteristic first byte is %d and second byte is %d",version[0],version[1]);        
        [self.bleDelegate onReadDfuVersion:version[0]];
    }
    else {
//        NSLog(@"received notification %@",characteristic.value);
        [self.bleDelegate onReceivedNotification:characteristic.value];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"error in writing characteristic %@ and error %@",characteristic.UUID,[error localizedDescription]);
    }
    else {
        NSLog(@"didWriteValueForCharacteristic %@ and value %@",characteristic.UUID,characteristic.value);
    }
}


@end
