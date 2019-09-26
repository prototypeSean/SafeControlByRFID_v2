//
//  Iso15693Card.m
//  ble_nfc_sdk
//
//  Created by lochy on 16/10/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import "Iso15693Card.h"
#import "DKCardNoResponseException.h"

//数据交换回调接口
onReceiveIso15693CmdListener mOnReceiveIso15693CmdListenerBlock = nil;
//读块回调
onReceiveIso15693ReadListener mOnReceiveIso15693ReadListenerBlock = nil;
//读多个块回调
onReceiveIso15693ReadMultipleListener mOnReceiveIso15693ReadMultipleListenerBlock = nil;
//写块回调
onReceiveIso15693WriteListener mOnReceiveIso15693WriteListenerBlock = nil;
onReceiveIso15693WriteMultipleListener mOnReceiveIso15693WriteMultipleListenerBlock = nil;
//锁块回调
onReceiveIso15693LockListener mOnReceiveIso15693LockListener = nil;

@implementation Iso15693Card
/*************************************************************************************
 *  方法名：   iso15693Read
 *  功能：     ISO15693读单个块
 *  入口参数：  addr：要读卡片的块地址
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)iso15693Read:(Byte)addr callback:(onReceiveIso15693ReadListener)block{
    mOnReceiveIso15693CmdListenerBlock = block;
    [self.deviceManager requestRfmIso15693ReadSingleBlock:self.uid address:addr callback:^(BOOL isSuc, NSData *returnData) {
        if (mOnReceiveIso15693CmdListenerBlock != nil) {
            mOnReceiveIso15693CmdListenerBlock(isSuc, returnData);
        }
    }];
}

/*************************************************************************************
 *  方法名：   iso15693ReadMultiple
 *  功能：     ISO15693读多个块
 *  入口参数：  addr：要读卡片的块地址
 *            number:要读的块数量,必须大于0
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)iso15693ReadMultiple:(Byte)addr number:(Byte)number callback:(onReceiveIso15693ReadMultipleListener)block{
    mOnReceiveIso15693ReadMultipleListenerBlock = block;
    [self.deviceManager requestRfmIso15693ReadMultipleBlock:self.uid address:addr number:number callback:^(BOOL isSuc, NSData *returnData) {
        if (mOnReceiveIso15693ReadMultipleListenerBlock != nil) {
            mOnReceiveIso15693ReadMultipleListenerBlock(isSuc, returnData);
        }
    }];
}

/*************************************************************************************
 *  方法名：   iso15693Write
 *  功能：     ISO15693写单个块
 *  入口参数：  addr：要写卡片的块地址
 *            writeData:要写的数据，必须4个字节
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)iso15693Write:(Byte)addr writeData:(NSData *)writeData callback:(onReceiveIso15693WriteListener)block{
    mOnReceiveIso15693WriteListenerBlock = block;
    [self.deviceManager requestRfmIso15693WriteSingleBlock:self.uid address:addr writeData:writeData callback:^(BOOL isSuc) {
        if (mOnReceiveIso15693WriteListenerBlock != nil) {
            mOnReceiveIso15693WriteListenerBlock(isSuc);
        }
    }];
}

/*************************************************************************************
 *  方法名：   iso15693WriteMultiple
 *  功能：     ISO15693写多个块
 *  入口参数：  addr：要写卡片的块地址
 *            number:要写的块数量,必须大于0
 *            writeData: 要写的数据，必须(number+1) * 4字节
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)iso15693WriteMultiple:(Byte)addr number:(Byte)number writeData:(NSData *)writeData callback:(onReceiveIso15693WriteMultipleListener) block{
    mOnReceiveIso15693WriteMultipleListenerBlock = block;
    [self.deviceManager requestRfmIso15693WriteMultipleBlock:self.uid address:addr number:number writeData:writeData callback:^(BOOL isSuc) {
        if (mOnReceiveIso15693WriteMultipleListenerBlock != nil) {
            mOnReceiveIso15693WriteMultipleListenerBlock(isSuc);
        }
    }];
}

/*************************************************************************************
 *  方法名：   iso15693LockBlock
 *  功能：     ISO15693锁块，被锁单块会变成只读，且不可逆
 *  入口参数：  addr：要锁卡片的块地址
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)iso15693LockBlock:(Byte)addr callback:(onReceiveIso15693LockListener)block{
    mOnReceiveIso15693LockListener = block;
    [self.deviceManager requestRfmIso15693LockBlock:self.uid address:addr callback:^(BOOL isSuc) {
        if (mOnReceiveIso15693LockListener != nil) {
            mOnReceiveIso15693LockListener(isSuc);
        }
    }];
}

/*************************************************************************************
 *  方法名：   iso15693Cmd
 *  功能：     ISO15693指令通道
 *  入口参数：  data:要传输到指令
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)iso15693Cmd:(NSData *)data callback:(onReceiveIso15693CmdListener)block {
    mOnReceiveIso15693CmdListenerBlock = block;
    [self.deviceManager requestRfmIso15693CmdData:data callback:^(BOOL isSuc, NSData *returnData) {
        if (mOnReceiveIso15693CmdListenerBlock != nil) {
            mOnReceiveIso15693CmdListenerBlock(isSuc, returnData);
        }
    }];
}

/**
 * ISO15693读单个块数据，同步阻塞方式，注意：不能在主线程里运行
 * @param addr     要读的地址
 * @return         读取到的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)iso15693Read:(Byte)addr{
    //创建信号量
    __block BOOL status = NO;
    __block NSData *returnDataTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self iso15693Read:addr callback:^(BOOL isCmdRunSuc, NSData *apduRtnData) {
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
 * ISO15693读多个块数据指令，同步阻塞方式，注意：不能在主线程里运行
 * @param addr     要读的块的起始地址
 * @param number   要读块的数量,必须大于0
 * @return         读取到的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)iso15693ReadMultiple:(Byte)addr number:(Byte)number{
    //创建信号量
    __block BOOL status = NO;
    __block NSData *returnDataTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self iso15693ReadMultiple:addr number:number callback:^(BOOL isCmdRunSuc, NSData *apduRtnData) {
        status = isCmdRunSuc;
        returnDataTemp = apduRtnData;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(4*DISPATCH_TIME_NOW,CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
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
 * ISO15693写一个块，同步阻塞方式，注意：不能在主线程里运行
 * @param addr        要写的块的地址
 * @param writeData   要写的数据，必须4个字节
 * @return            true:写入成功   false：写入失败
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)iso15693Write:(Byte)addr writeData:(NSData *)writeData{
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self iso15693Write:addr writeData:writeData callback:^(BOOL isOk) {
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
 * ISO15693写多个块，同步阻塞方式，注意：不能在主线程里运行
 * @param addr        要写的块的地址
 * @param number      要写的块数量,必须大于0
 * @param writeData   要写的数据，必须4个字节
 * @return            true:写入成功   false：写入失败
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)iso15693WriteMultiple:(Byte)addr number:(Byte)number writeData:(NSData *)writeData {
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self iso15693WriteMultiple:addr number:number writeData:writeData callback:^(BOOL isOk) {
        status = isOk;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(4*DISPATCH_TIME_NOW,CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
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
 * ISO15693锁住一个块，同步阻塞方式，注意：不能在主线程里运行
 * @param addr        要锁的块的起始地址
 * @return            true:写入成功   false：写入失败
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)iso15693LockBlock:(Byte)addr {
    //创建信号量
    __block BOOL status = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self iso15693LockBlock:addr callback:^(BOOL isOk) {
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
 * ISO15693指令通道，同步阻塞方式，注意：不能在主线程里运行
 * @param data     发送的数据
 * @return         返回的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)iso15693Transceive:(NSData *)data{
    //创建信号量
    __block BOOL status = NO;
    __block NSData *returnDataTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self iso15693Cmd:data callback:^(BOOL isSuc, NSData* returnData) {
        status = isSuc;
        returnDataTemp = returnData;
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
