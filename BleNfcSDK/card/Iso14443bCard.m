//
//  Iso14443bCard.m
//  ble_nfc_sdk
//
//  Created by lochy on 16/10/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import "Iso14443bCard.h"
#import "DKCardNoResponseException.h"

onReceiveBpduExchangeListener mOnReceiveBpduExchangeListenerBlock = nil;

@implementation Iso14443bCard
-(void)bpduExchange:(NSData *)bpduData callbackBlock:(onReceiveBpduExchangeListener)block{
    mOnReceiveBpduExchangeListenerBlock = block;
    [self.deviceManager requestRfmSentBpduCmd:bpduData callbackBlock:^(BOOL isSuc, NSData *BpduRtnData) {
        if (mOnReceiveBpduExchangeListenerBlock != nil) {
            mOnReceiveBpduExchangeListenerBlock(isSuc, BpduRtnData);
        }
    }];
}

/**
 * B cpu卡指令传输，同步阻塞方式，注意：不能在主线程里运行
 * @param data     发送的数据
 * @return         返回的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)iso14443bCardTransceive:(NSData *)data {
    //创建信号量
    __block BOOL status = NO;
    __block NSData *returnDataTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self bpduExchange:data callbackBlock:^(BOOL isCmdRunSuc, NSData *apduRtnData) {
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
