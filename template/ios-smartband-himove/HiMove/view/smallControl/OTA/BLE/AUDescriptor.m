//
//  AUDescriptor.m
//  AMICCOM Updator
//
//  Created by Eason Chen on 2015/1/24.
//  Copyright (c) 2015年 funbuyfun. All rights reserved.
//

#import "AUDescriptor.h"
#import "CBUUID+StringExtraction.h"
#import "NSMutableArray+fifoQueue.h"
#import "LGCharacteristic.h"
#import "LGUtils.h"

@interface AUDescriptor ()
@property (strong, nonatomic) AUDescriptorReadCallback updateCallback;
@property (strong, nonatomic) NSMutableArray *notifyOperationStack;
@property (strong, nonatomic) NSMutableArray *readOperationStack;
@property (strong, nonatomic) NSMutableArray *writeOperationStack;
@end

@implementation AUDescriptor

- (NSString *)UUIDString
{
    return [self.cbDescriptor.UUID representativeString];
}
#if 0
- (void)writeValue:(NSData *)data withBlock:(void (^)(NSError *))writeCallback {
    [self.writeCallbacks push:[writeCallback copy]];
    [self.cbDescriptor.characteristic.service.peripheral writeValue:data forDescriptor:self.cbDescriptor];
}


- (void)writeByte:(int8_t)val withBlock:(void (^)(NSError *))writeCallback {
    NSData *data = [NSData dataWithBytes:&val length:1];
    [self writeValue:data withBlock:writeCallback];
}


- (void)readValueWithBlock:(void (^)(NSData *, NSError *))readCallback {
    
    NSLog(@"peripheral UUID:%@", [self.cbDescriptor.characteristic.service.UUID representativeString] );
    NSLog(@"read descriptor:%@", [self.cbDescriptor.UUID representativeString]);
    
    [self.readCallbacks push:[readCallback copy]];
    [self.cbDescriptor.characteristic.service.peripheral readValueForDescriptor:self.cbDescriptor];
}

- (void)executeReadCallback:(NSData *)data error:(NSError *)error {
    LGCharacteristicReadCallback readCB = [self.readCallbacks pop];
    readCB(data, error);
}

- (void)executeWriteCallback:(NSError *)error {
    LGCharacteristicWriteCallback writeCB = [self.writeCallbacks pop];
    writeCB(error);
}
#endif
/*----------------------------------------------------*/
#pragma mark - Public Methods -
/*----------------------------------------------------*/
- (void)writeValue:(NSData *)data
        completion:(AUDescriptorWriteCallback)aCallback
{
    if (aCallback) {
        [self push:aCallback toArray:self.writeOperationStack];
    }
    [self.cbDescriptor.characteristic.service.peripheral writeValue:data forDescriptor:self.cbDescriptor];
}

- (void)writeByte:(int8_t)aByte
       completion:(AUDescriptorWriteCallback)aCallback
{
    [self writeValue:[NSData dataWithBytes:&aByte length:1] completion:aCallback];
}

- (void)readValueWithBlock:(AUDescriptorReadCallback)aCallback
{
    // No need to read ;)
    if (!aCallback) {
        return;
    }
    [self push:aCallback toArray:self.readOperationStack];
    [self.cbDescriptor.characteristic.service.peripheral readValueForDescriptor:self.cbDescriptor];
}


/*----------------------------------------------------*/
#pragma mark - Getter/Setter -
/*----------------------------------------------------*/

- (NSMutableArray *)notifyOperationStack
{
    if (!_notifyOperationStack) {
        _notifyOperationStack = [NSMutableArray new];
    }
    return _notifyOperationStack;
}

- (NSMutableArray *)readOperationStack
{
    if (!_readOperationStack) {
        _readOperationStack = [NSMutableArray new];
    }
    return _readOperationStack;
}

- (NSMutableArray *)writeOperationStack
{
    if (!_writeOperationStack) {
        _writeOperationStack = [NSMutableArray new];
    }
    return _writeOperationStack;
}

/*----------------------------------------------------*/
#pragma mark - Handler Methods -
/*----------------------------------------------------*/
#if 0
- (void)handleSetNotifiedWithError:(NSError *)anError
{
    LGLog(@"descriptor - %@ notify changed with error - %@", self.cbDescriptor.UUID, anError);
    LGCharacteristicNotifyCallback callback = [self popFromArray:self.notifyOperationStack];
    if (callback) {
        callback(anError);
    }
}
#endif
- (void)handleReadValue:(NSData *)aValue error:(NSError *)anError
{
    //LGLog(@"Descriptor - %@ value - %s error - %@",
   //       self.cbDescriptor.UUID, [aValue bytes], anError);
    
    NSLog(@"Descriptor - %@ error - %@" ,
          self.cbDescriptor, anError);
    
    if (self.updateCallback) {
        self.updateCallback(aValue, anError);
    }
    
    AUDescriptorReadCallback callback = [self popFromArray:self.readOperationStack];
    if (callback) {
        callback(aValue, anError);
    }
}

- (void)handleWrittenValueWithError:(NSError *)anError
{
    LGLog(@"Descriptor - %@ wrote with error - %@", self.cbDescriptor.UUID, anError);
    AUDescriptorWriteCallback callback = [self popFromArray:self.writeOperationStack];
    if (callback) {
        callback(anError);
    }
}

/*----------------------------------------------------*/
#pragma mark - Private Methods -
/*----------------------------------------------------*/

- (void)push:(id)anObject toArray:(NSMutableArray *)aArray
{
    [aArray addObject:anObject];
}

- (id)popFromArray:(NSMutableArray *)aArray
{
    id aObject = nil;
    if ([aArray count] > 0) {
        aObject = [aArray objectAtIndex:0];
        [aArray removeObjectAtIndex:0];
    }
    return aObject;
}

/*----------------------------------------------------*/
#pragma mark - Lifecycle -
/*----------------------------------------------------*/

- (instancetype)initWithDescriptor:(CBDescriptor *)aDescriptor
{
    if (self = [super init]) {
        _cbDescriptor = aDescriptor;
    }
    return self;
}

@end
