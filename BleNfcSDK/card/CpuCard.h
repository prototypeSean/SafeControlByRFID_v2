//
//  CpuCard.h
//  ble_nfc_sdk
//
//  Created by lochy on 16/10/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

//代码块定义
//APDU指令通道回调代码块
typedef void(^onReceiveApduExchangeListener)(BOOL isCmdRunSuc, NSData* apduRtnData);

@interface CpuCard : Card
-(void)apduExchange:(NSData *)apduData callback:(onReceiveApduExchangeListener)block;

/**
 * cpu卡指令传输，同步阻塞方式，注意：不能在主线程里运行
 * @param data     发送的数据
 * @return         返回的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)cpuCardTransceive:(NSData *)data;
@end
