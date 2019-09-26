//
//  DKBleNfcDevice.m
//  ble_nfc_sdk
//
//  Created by lochy on 17/6/2.
//  Copyright © 2017年 Lochy. All rights reserved.
//

#import "DKBleNfcDevice.h"
#import "DKBleManager.h"
#import "DKDeviceNoResponseException.h"

@implementation DKBleNfcDevice

//带代理初始化
-(id)initWithDelegate:(id)theDelegate {
    self = [super init];
    if (self){
        self.delegate = theDelegate;
    }
    return self;
}

/**
 * 获取设备名称
 * @return         设备名称
 */
-(NSString *)getDeviceName {
    return [[DKBleManager sharedInstance] currentPeripheral].name;
}

/**
 * 是否正在自动寻卡
 * @return         true - 正在自动寻卡
 *                  false - 自动寻卡已经关闭
 */
-(BOOL)isAutoSearchCard{
    return [[self autoSearchCardFlag] boolValue];
}

/**
 * 获取设备当前电池电压，同步阻塞方式，注意：不能在主线程里运行
 * @return         设备电池电压，单位：V
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(double)getDeviceBatteryVoltage{
    //创建信号量
    __block float returnDataTemp = 0;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self requestDeviceBtValueWithCallbackBlock:^(float btVlueMv) {
        returnDataTemp = btVlueMv;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,DEVICE_NO_RESPONSE_TIME*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKDeviceNoResponseException
                exceptionWithName: @"DKDeviceNoResponseException"
                reason: @"设备无响应"
                userInfo: nil];
    }
    else {
        return returnDataTemp;
    }
}


/**
 * 获取设备版本号，同步阻塞方式，注意：不能在主线程里运行
 * @return         设备版本号，1 字节
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(Byte)getDeviceVersions{
    //创建信号量
    __block NSUInteger returnTemp = 0;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self requestDeviceVersionWithCallbackBlock:^(NSUInteger versionNum) {
        returnTemp = versionNum;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,DEVICE_NO_RESPONSE_TIME*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKDeviceNoResponseException
                exceptionWithName: @"DKDeviceNoResponseException"
                reason: @"设备无响应"
                userInfo: nil];
    }
    else {
        return returnTemp;
    }
}

/**
 * 打开关闭防丢器功能，同步阻塞方式，注意：不能在主线程里运行
 * @param s         true - 打开
 *                  false - 关闭
 * @return         true - 防丢器功能已打开
 *                  false - 防丢器功能已关闭
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)antiLostSwitch:(BOOL)en {
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self requestAntiLostSwitch:en callback:^(BOOL isOk) {
        status = isOk;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,DEVICE_NO_RESPONSE_TIME*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKDeviceNoResponseException
                exceptionWithName: @"DKDeviceNoResponseException"
                reason: @"设备无响应"
                userInfo: nil];
    }
    else {
        return status;
    }
}

/**
 * 关闭蜂鸣器，同步阻塞方式，注意：不能在蓝牙初始化的线程里运行
 * @return           true - 操作成功
 *                    false - 操作失败
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)closeBeep {
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self requestOpenBeep:0 offDelay:0 number:0 callback:^(BOOL isOk) {
        status = isOk;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,DEVICE_NO_RESPONSE_TIME*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKDeviceNoResponseException
                exceptionWithName: @"DKDeviceNoResponseException"
                reason: @"设备无响应"
                userInfo: nil];
    }
    else {
        return status;
    }
}

/**
 * 打开蜂鸣器指令，同步阻塞方式，注意：不能在蓝牙初始化的线程里运行
 * @param onDelayMs  打开蜂鸣器时间：0~0xffff，单位ms
 * @param offDelayMs 关闭蜂鸣器时间：0~0xffff，单位ms
 * @param n          蜂鸣器响多少声：0~255
 * @return           true - 操作成功
 *                    false - 操作失败
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)openBeep:(int)onDelayMs offDelay:(int)offDelayMs cnt:(int)n {
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self requestOpenBeep:onDelayMs offDelay:offDelayMs number:n callback:^(BOOL isOk) {
        status = isOk;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,DEVICE_NO_RESPONSE_TIME*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKDeviceNoResponseException
                exceptionWithName: @"DKDeviceNoResponseException"
                reason: @"设备无响应"
                userInfo: nil];
    }
    else {
        return status;
    }
}

/**
 * 修改蓝牙名，同步阻塞方式，注意：不能在蓝牙初始化的线程里运行
 * @param bleName   新蓝牙名称
 * @return         true - 操作成功
 *                  false - 操作失败
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)changeBleName:(NSString *)bleName {
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self requestChangeBleName:bleName callback:^(BOOL isOk) {
        status = isOk;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,DEVICE_NO_RESPONSE_TIME*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKDeviceNoResponseException
                exceptionWithName: @"DKDeviceNoResponseException"
                reason: @"设备无响应"
                userInfo: nil];
    }
    else {
        return status;
    }
}

/**
 * 开始自动寻卡，同步阻塞方式，注意：不能在蓝牙初始化的线程里运行
 * @param delayMsx10   寻卡间隔,单位 10毫秒
 * @param bytCardType  ISO14443_P3 - 寻M1/UL卡
 *                      ISO14443_P4-寻CPU卡
 * @return             true - 操作成功
 *                      false - 操作失败
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)startAutoSearchCard:(Byte)delayMsx10 cardType:(Byte)bytCardType {
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self requestRfmAutoSearchCard:YES delay:delayMsx10 cardType:bytCardType callback:^(BOOL isOk) {
        status = isOk;
        printf("釋放信號量");
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,DEVICE_NO_RESPONSE_TIME*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKDeviceNoResponseException
                exceptionWithName: @"DKDeviceNoResponseException"
                reason: @"设备无响应"
                userInfo: nil];
    }
    else {
        return status;
    }
}

/**
 * 停止自动寻卡，同步阻塞方式，注意：不能在蓝牙初始化的线程里运行
 * @return             true - 操作成功
 *                      false - 操作失败
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)stoptAutoSearchCard{
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self requestRfmAutoSearchCard:NO delay:100 cardType:0 callback:^(BOOL isOk) {
        status = isOk;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,DEVICE_NO_RESPONSE_TIME*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKDeviceNoResponseException
                exceptionWithName: @"DKDeviceNoResponseException"
                reason: @"设备无响应"
                userInfo: nil];
    }
    else {
        return status;
    }
}

/**
 * 关闭RF天线，同步阻塞方式，注意：不能在蓝牙初始化的线程里运行
 * @return             true - 操作成功
 *                      false - 操作失败
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)closeRf{
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self requestRfmCloseWhitCallbackBlock:^(BOOL isOk) {
        status = isOk;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,DEVICE_NO_RESPONSE_TIME*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKDeviceNoResponseException
                exceptionWithName: @"DKDeviceNoResponseException"
                reason: @"设备无响应"
                userInfo: nil];
    }
    else {
        return status;
    }
}
@end






