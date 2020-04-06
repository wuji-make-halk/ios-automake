//
//  AUDescriptor.h
//  AMICCOM Updator
//
//  Created by Eason Chen on 2015/1/24.
//  Copyright (c) 2015年 funbuyfun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class CBDescriptor;

@interface AUDescriptor : NSObject

typedef void (^AUDescriptorReadCallback)  (NSData *data, NSError *error);
typedef void (^AUDescriptorWriteCallback) (NSError *error);
typedef void (^AUDescriptorReadCallback)  (NSData *data, NSError *error);
/**
 * Core Bluetooth's CBDescriptor instance
 */
//@property (strong, nonatomic, readonly) CBDescriptor *cbDescriptor;
@property  (strong, nonatomic, readonly) CBDescriptor *cbDescriptor;

/**
 * NSString representation of 16/128 bit CBUUID
 */
@property (weak, nonatomic, readonly) NSString *UUIDString;

/**
 FIFO queue for reads.
 
 Each element is a block of type CBReadCallbackBlockType.
 */
@property (atomic, strong) NSMutableArray *readCallbacks;

/**
 FIFO queue for writes.
 
 Each element is a block of type CBWriteCallbackBlockType.
 */
@property (atomic, strong) NSMutableArray *writeCallbacks;


/** @name Issuing a Write Request */
/**
 
 Issue write with value data and execute callback block writeCallback upon response.
 
 The callback block writeCallback has one argument: `error`:
 
 * `error` is populated with the returned `error` object from the delegate method
 peripheral:didWriteValueForCharacteristic:error: implemented in CBPeripheral.
 
 @param data The value to be written
 @param writeCallback Callback block to execute upon response.
 
 */
//- (void)writeValue:(NSData *)data withBlock:(void (^)(NSError *error))writeCallback;
-(void)writeValue:(NSData *)data completion:(AUDescriptorWriteCallback)aCallback;
/**
 Issue write with byte val and execute callback block writeCallback upon response.
 
 The callback block writeCallback has one argument: `error`:
 
 * `error` is populated with the returned `error` object from the delegate method
 peripheral:didWriteValueForCharacteristic:error: implemented in CBPeripheral.
 
 @param val Byte value to be written
 @param writeCallback Callback block to execute upon response.
 
 */
//- (void)writeByte:(int8_t)val withBlock:(void (^)(NSError *error))writeCallback;
- (void)writeByte:(int8_t)aByte completion:(AUDescriptorWriteCallback)aCallback;


/** @name Issuing a Read Request */
/**
 Issue read and execute callback block readCallback upon response.
 
 The callback block readCallback has two arguments: `data` and `error`:
 
 * `data` is populated with the `value` property of [CBCharacteristic cbCharacteristic].
 * `error` is populated with the returned `error` object from the delegate method peripheral:didUpdateValueForCharacteristic:error: implemented in CBPeripheral.
 
 
 @param readCallback Callback block to execute upon response.
 */
//- (void)readValueWithBlock:(void (^)(NSData *data, NSError *error))readCallback;
- (void)readValueWithBlock:(AUDescriptorReadCallback)aCallback;
/** @name Callback Handler Methods */
/**
 Handler method to process first callback in readCallbacks.
 
 @param data Value returned from read request.
 @param error Error object, if failed.
 */
//- (void)executeReadCallback:(NSData *)data error:(NSError *)error;
- (void)handleReadValue:(NSData *)aValue error:(NSError *)anError;
/**
 Handler method to process first callback in writeCallbacks.
 
 @param error Error object, if failed.
 */
//- (void)executeWriteCallback:(NSError *)error;
- (void)handleWrittenValueWithError:(NSError *)anError;
/**
 * @return Wrapper object over Core Bluetooth's CBCharacteristic
 */
- (instancetype)initWithDescriptor:(CBDescriptor *)aDescriptor;

@end
