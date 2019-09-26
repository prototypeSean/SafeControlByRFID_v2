//
//  Iso14443bCard.h
//  ble_nfc_sdk
//
//  Created by lochy on 16/10/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

//代码块定义
//BPDU指令通道回调
typedef void(^onReceiveBpduExchangeListener)(BOOL isSuc, NSData* returnData);

@interface Iso14443bCard : Card
-(void)bpduExchange:(NSData *)bpduData callbackBlock:(onReceiveBpduExchangeListener)block;

/**
 * B cpu卡指令传输，同步阻塞方式，注意：不能在主线程里运行
 * @param data     发送的数据
 * @return         返回的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)iso14443bCardTransceive:(NSData *)data;
@end
