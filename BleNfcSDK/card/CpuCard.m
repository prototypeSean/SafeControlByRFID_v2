//
//  CpuCard.m
//  ble_nfc_sdk
//
//  Created by lochy on 16/10/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import "CpuCard.h"
#import "DKCardNoResponseException.h"

onReceiveApduExchangeListener mOnReceiveApduExchangeListenerBlock = nil;

@implementation CpuCard

//apdu指令通道，异步回调方式
-(void)apduExchange:(NSData *)apduData callback:(onReceiveApduExchangeListener)block {
    mOnReceiveApduExchangeListenerBlock = block;
    [self.deviceManager requestRfmSentApduCmd:apduData callbackBlock:^(BOOL isSuc, NSData *ApduRtnData) {
        if (mOnReceiveApduExchangeListenerBlock != nil) {
            mOnReceiveApduExchangeListenerBlock(isSuc, ApduRtnData);
        }
    }];
}

/**
 * cpu卡指令传输，同步阻塞方式，注意：不能在主线程里运行
 * @param data     发送的数据
 * @return         返回的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)cpuCardTransceive:(NSData *)data {
    //创建信号量
    __block BOOL status = NO;
    __block NSData *returnDataTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self apduExchange:data callback:^(BOOL isCmdRunSuc, NSData *apduRtnData) {
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
