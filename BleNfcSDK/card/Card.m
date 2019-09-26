//
//  Card.m
//  ble_nfc_sdk
//
//  Created by lochy on 16/10/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import "Card.h"
#import "DKCardNoResponseException.h"

onReceiveCloseListener mOnReceiveCloseListenerBlock = nil;

@implementation Card
-(id)init:(DKDeviceManager *)deviceManager {
    self = [super init];//获得父类的对象并进行初始化
    if (self){
        self.deviceManager = deviceManager;
    }
    return self;
}

-(id)init:(DKDeviceManager *)deviceManager uid:(NSData *)uid atr:(NSData *)atr {
    self = [super init];//获得父类的对象并进行初始化
    if (self){
        self.deviceManager = deviceManager;
        self.uid = uid;
        self.atr = atr;
    }
    return self;
}

/*************************************************************************************
 *  方法名：   close
 *  功能：     关闭天线，同步阻塞方式，注意：不能在主线程执行
 *  入口参数：  无
 *  返回参数：  YES: 天线关闭成功  NO:天线关闭失败
 *  异常:      指令无响应时会抛出 DKCardNoResponseException 异常，请用 @try @catch接收异常
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)close {
//    //创建信号量
//    __block BOOL status = NO;
//    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//    [self closeWithCallbackBlock:^(BOOL isOk) {
//        status = isOk;
//        dispatch_semaphore_signal(sema);   //释放信号量
//    }];
//    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
//        //等待信号量超时
//        @throw [DKCardNoResponseException
//                exceptionWithName: @"DKCardNoResponseException"
//                reason: @"卡片无响应"
//                userInfo: nil];
//    }
//    else {
//        return status;
//    }
    [self.deviceManager requestRfmCloseWhitCallbackBlock:nil];
}

/*************************************************************************************
 *  方法名：   closeWithCallbackBlock
 *  功能：     关闭天线，异步回调方式
 *  入口参数：  block：操作结果会是通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)closeWithCallbackBlock:(onReceiveCloseListener)block {
    mOnReceiveCloseListenerBlock = block;
    [self.deviceManager requestRfmCloseWhitCallbackBlock:^(BOOL blnIsCloseSuc){
        if (mOnReceiveCloseListenerBlock != nil) {
            mOnReceiveCloseListenerBlock(blnIsCloseSuc);
        }
    }];
}
@end
