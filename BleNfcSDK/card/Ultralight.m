//
//  Ultralight.m
//  ble_nfc_sdk
//
//  Created by lochy on 16/10/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import "Ultralight.h"
#import "DKCardNoResponseException.h"

#define  UL_GET_VERSION_CMD         ((Byte)0x60)
#define  UL_READ_CMD                ((Byte)0x30)
#define  UL_FAST_READ_CMD           ((Byte)0x3A)
#define  UL_WRITE_CMD               ((Byte)0xA2)
#define  UL_READ_CNT_CMD            ((Byte)0x39)
#define  UL_PWD_AUTH_CMD            ((Byte)0x1B)


onReceiveUltralightGetVersionListener mOnReceiveUltralightGetVersionListenerBlock = nil;
onReceiveUltralightReadListener       mOnReceiveUltralightReadListenerBlock = nil;
onReceiveUltralightFastReadListener   mOnReceiveUltralightFastReadListenerBlock = nil;
onReceiveUltralightWriteListener      mOnReceiveUltralightWriteListenerBlock = nil;
onReceiveUltralightReadCntListener    mOnReceiveUltralightReadCntListenerBlock = nil;
onReceiveUltralightPwdAuthListener    mOnReceiveUltralightPwdAuthListenerBlock = nil;
onReceiveUltralightCmdListener        mOnReceiveUltralightCmdListenerBlock = nil;

@implementation Ultralight
-(void)ultralightGetVersionWithCallbackBlock:(onReceiveUltralightGetVersionListener)block {
    mOnReceiveUltralightGetVersionListenerBlock = block;
    Byte cmdByte[] = {UL_GET_VERSION_CMD};
    NSData *cmdData = [[NSData alloc] initWithBytes:cmdByte length:1];
    [self ultralightCmd:cmdData callbackBlock:^(BOOL isSuc, NSData *returnData) {
        if (mOnReceiveUltralightGetVersionListenerBlock != nil) {
            mOnReceiveUltralightGetVersionListenerBlock(isSuc, returnData);
        }
    }];
}

-(void)ultralightRead:(Byte)address callbackBlock:(onReceiveUltralightReadListener)block{
    mOnReceiveUltralightReadListenerBlock = block;
    Byte cmdByte[] = {UL_READ_CMD, address};
    NSData *cmdData = [[NSData alloc] initWithBytes:cmdByte length:2];
    [self ultralightCmd:cmdData callbackBlock:^(BOOL isSuc, NSData *returnData) {
        if (mOnReceiveUltralightReadListenerBlock != nil) {
            mOnReceiveUltralightReadListenerBlock(isSuc, returnData);
        }
    }];
}

-(void)ultralightFastRead:(Byte)startAddress end:(Byte)endAddress callbackBlock:(onReceiveUltralightFastReadListener)block{
    mOnReceiveUltralightFastReadListenerBlock = block;
    if (startAddress > endAddress) {
        if (mOnReceiveUltralightFastReadListenerBlock != nil) {
            mOnReceiveUltralightFastReadListenerBlock(NO, nil);
        }
        return;
    }
    Byte cmdByte[] = {UL_FAST_READ_CMD, startAddress, endAddress};
    NSData *cmdData = [[NSData alloc] initWithBytes:cmdByte length:3];
    [self ultralightCmd:cmdData callbackBlock:^(BOOL isSuc, NSData *returnData) {
        if (mOnReceiveUltralightFastReadListenerBlock != nil) {
            mOnReceiveUltralightFastReadListenerBlock(isSuc, returnData);
        }
    }];
}

-(void)ultralightWrite:(Byte)address data:(NSData *)data callbackBlock:(onReceiveUltralightWriteListener)block{
    mOnReceiveUltralightWriteListenerBlock = block;
    if (data.length != 4) {
        if (mOnReceiveUltralightWriteListenerBlock != nil) {
            mOnReceiveUltralightWriteListenerBlock(NO, nil);
        }
        return;
    }
    Byte *dataBytes = (Byte *)[data bytes];
    Byte cmdByte[] = {UL_WRITE_CMD, address, dataBytes[0], dataBytes[1], dataBytes[2], dataBytes[3]};
    NSData *cmdData = [[NSData alloc] initWithBytes:cmdByte length:6];
    [self ultralightCmd:cmdData callbackBlock:^(BOOL isSuc, NSData *returnData) {
        if (mOnReceiveUltralightWriteListenerBlock != nil) {
            mOnReceiveUltralightWriteListenerBlock(isSuc, returnData);
        }
    }];
}

-(void)ultralightReadCntWithCallbackBlock:(onReceiveUltralightReadCntListener)block{
    mOnReceiveUltralightReadCntListenerBlock = block;
    Byte cmdByte[] = {UL_READ_CNT_CMD, 0x02};
    NSData *cmdData = [[NSData alloc] initWithBytes:cmdByte length:2];
    [self ultralightCmd:cmdData callbackBlock:^(BOOL isSuc, NSData *returnData) {
        if (mOnReceiveUltralightReadCntListenerBlock != nil) {
            mOnReceiveUltralightReadCntListenerBlock(isSuc, returnData);
        }
    }];
}

-(void)ultralightPwdAuth:(NSData *)password callbackBlock:(onReceiveUltralightPwdAuthListener)block{
    mOnReceiveUltralightPwdAuthListenerBlock = block;
    Byte *pwdBytes = (Byte *)[password bytes];
    if (password.length != 4) {
        if (mOnReceiveUltralightPwdAuthListenerBlock != nil) {
            mOnReceiveUltralightPwdAuthListenerBlock(NO);
        }
        return;
    }
    Byte cmdByte[] = {UL_PWD_AUTH_CMD, pwdBytes[0], pwdBytes[1], pwdBytes[2], pwdBytes[3]};
    NSData *cmdData = [[NSData alloc] initWithBytes:cmdByte length:5];
    [self ultralightCmd:cmdData callbackBlock:^(BOOL isSuc, NSData *returnData) {
        if (mOnReceiveUltralightPwdAuthListenerBlock != nil) {
            mOnReceiveUltralightPwdAuthListenerBlock(isSuc);
        }
    }];
}

-(void)ultralightCmd:(NSData *)cmdData callbackBlock:(onReceiveUltralightCmdListener)block {
    mOnReceiveUltralightCmdListenerBlock = block;
    [self.deviceManager requestRfmUltralightCmd:cmdData callback:^(BOOL isSuc, NSData *ulCmdRtnData) {
        if (mOnReceiveUltralightCmdListenerBlock != nil) {
            mOnReceiveUltralightCmdListenerBlock(isSuc, ulCmdRtnData);
        }
    }];
}

/**
 * 读取卡片版本，同步阻塞方式，注意：不能在主线程里运行
 * @return         返回的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)ultralightGetVersion{
    //创建信号量
    __block BOOL status = NO;
    __block NSData *returnDataTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self ultralightGetVersionWithCallbackBlock:^(BOOL isCmdRunSuc, NSData *apduRtnData) {
        status = isCmdRunSuc;
        returnDataTemp = apduRtnData;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: @"卡片无响应"
                userInfo: nil];
    }
    else if (!status) {
        return nil;
    }
    else {
        return returnDataTemp;
    }
}

/**
 * 读单个块数据，同步阻塞方式，注意：不能在主线程里运行
 * @param addr     要读的地址
 * @return         读取到的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)ultralightRead:(Byte)addr{
    //创建信号量
    __block BOOL status = NO;
    __block NSData *returnDataTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self ultralightRead:addr callbackBlock:^(BOOL isCmdRunSuc, NSData *apduRtnData) {
        status = isCmdRunSuc;
        returnDataTemp = apduRtnData;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: @"卡片无响应"
                userInfo: nil];
    }
    else if (!status) {
        return nil;
    }
    else {
        return returnDataTemp;
    }
}

/**
 * 快速读，同步阻塞方式，注意：不能在主线程里运行
 * @param startAddress     要读起始地址
 * @param endAddress       要读的结束地址
 * @return                 读取到的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)ultralightFastRead:(Byte)startAddress end:(Byte)endAddress{
    //创建信号量
    __block BOOL status = NO;
    __block NSData *returnDataTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self ultralightFastRead:startAddress end:endAddress callbackBlock:^(BOOL isCmdRunSuc, NSData *apduRtnData) {
        status = isCmdRunSuc;
        returnDataTemp = apduRtnData;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: @"卡片无响应"
                userInfo: nil];
    }
    else if (!status) {
        return nil;
    }
    else {
        return returnDataTemp;
    }
}

/**
 * 快速读，同步阻塞方式，注意：不能在主线程里运行
 * @param startAddress     要读起始地址
 * @param number           要读的块数量（一个块4 byte）， 0 < number < 0x3f
 * @return                 读取到的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)ultralightLongReadSingle:(Byte)startAddress number:(int)number {
    //创建信号量
    __block BOOL status = NO;
    __block NSData *returnDataTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self.deviceManager requestRfmUltralightLongRead:startAddress number:number callback:^(BOOL isCmdRunSuc, NSData *apduRtnData) {
        status = isCmdRunSuc;
        returnDataTemp = apduRtnData;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(5*DISPATCH_TIME_NOW,CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: @"卡片无响应"
                userInfo: nil];
    }
    else if (!status) {
        return nil;
    }
    else {
        return returnDataTemp;
    }
}

/**
 * 写一个块，同步阻塞方式，注意：不能在主线程里运行
 * @param addr        要写的块的地址
 * @param data        要写的数据，必须4个字节
 * @return            true:写入成功   false：写入失败
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)ultralightWrite:(Byte)addr data:(NSData*)data {
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self ultralightWrite:addr data:data callbackBlock:^(BOOL isCmdRunSuc, NSData *apduRtnData) {
        if (apduRtnData != nil) {
            Byte *apduRtnBytes = (Byte *)[apduRtnData bytes];
            if ( (YES == isCmdRunSuc) && ((apduRtnBytes[0] & 0x0F) == 0x0a) ){
                status = YES;
            }
        }
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: @"卡片无响应"
                userInfo: nil];
    }
    else {
        return status;
    }
}

/**
 * 写一个块，同步阻塞方式，注意：不能在主线程里运行
 * @param startAddress   要写的块的起始地址
 * @param data        要写的数据，必须小于0x3f字节
 * @return            true:写入成功   false：写入失败
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)ultralightLongWriteSingle:(Byte)startAddress data:(NSData*)data{
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self.deviceManager requestRfmUltralightLongWrite:startAddress writeData:data callback:^(BOOL isOk) {
        status = isOk;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(5*DISPATCH_TIME_NOW,CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: @"卡片无响应"
                userInfo: nil];
    }
    else {
        return status;
    }
}

/**
 * 读次数，同步阻塞方式，注意：不能在主线程里运行
 * @return            返回的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)ultralightReadCnt{
    //创建信号量
    __block BOOL status = NO;
    __block NSData *returnDataTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self ultralightReadCntWithCallbackBlock:^(BOOL isCmdRunSuc, NSData *apduRtnData) {
        status = isCmdRunSuc;
        returnDataTemp = apduRtnData;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: @"卡片无响应"
                userInfo: nil];
    }
    else if (!status) {
        return nil;
    }
    else {
        return returnDataTemp;
    }
}


/**
 * 验证密码，同步阻塞方式，注意：不能在主线程里运行
 * @param password    要验证的密码，4 Bytes
 * @return            true:验证成功  false:验证失败
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)ultralightPwdAuth:(NSData *)password{
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self ultralightPwdAuth:password callbackBlock:^(BOOL isOk) {
        status = isOk;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: @"卡片无响应"
                userInfo: nil];
    }
    else {
        return status;
    }
}

/**
 * 指令传输通道，同步阻塞方式，注意：不能在主线程里运行
 * @param data     发送的数据
 * @return         返回的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)ultralightTransceive:(NSData *)data{
    //创建信号量
    __block BOOL status = NO;
    __block NSData *returnDataTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self ultralightCmd:data callbackBlock:^(BOOL isCmdRunSuc, NSData *apduRtnData) {
        status = isCmdRunSuc;
        returnDataTemp = apduRtnData;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,5*CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: @"卡片无响应"
                userInfo: nil];
    }
    else if (!status) {
        return nil;
    }
    else {
        return returnDataTemp;
    }
}
@end







