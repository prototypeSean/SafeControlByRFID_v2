//
//  Iso15693Card.h
//  ble_nfc_sdk
//
//  Created by lochy on 16/10/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

//代码块定义
//数据交换回调接口
typedef void(^onReceiveIso15693CmdListener)(BOOL isSuc, NSData* returnData);
//读块回调
typedef void(^onReceiveIso15693ReadListener)(BOOL isSuc, NSData* returnData);
//读多个块回调
typedef void(^onReceiveIso15693ReadMultipleListener)(BOOL isSuc, NSData* returnData);
//写块回调
typedef void(^onReceiveIso15693WriteListener)(BOOL isSuc);
//写多个块回调
typedef void(^onReceiveIso15693WriteMultipleListener)(BOOL isSuc);
//锁块回调
typedef void(^onReceiveIso15693LockListener)(BOOL isSuc);

@interface Iso15693Card : Card

/*************************************************************************************
 *  方法名：   iso15693Read
 *  功能：     ISO15693读单个块
 *  入口参数：  addr：要读卡片的块地址
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)iso15693Read:(Byte)addr callback:(onReceiveIso15693ReadListener)block;

/*************************************************************************************
 *  方法名：   iso15693ReadMultiple
 *  功能：     ISO15693读多个块
 *  入口参数：  addr：要读卡片的块地址
 *            number:要读的块数量,必须大于0
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)iso15693ReadMultiple:(Byte)addr number:(Byte)number callback:(onReceiveIso15693ReadMultipleListener)block;

/*************************************************************************************
 *  方法名：   iso15693Write
 *  功能：     ISO15693写单个块
 *  入口参数：  addr：要写卡片的块地址
 *            writeData:要写的数据，必须4个字节
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)iso15693Write:(Byte)addr writeData:(NSData *)writeData callback:(onReceiveIso15693WriteListener)block;

/*************************************************************************************
 *  方法名：   iso15693LockBlock
 *  功能：     ISO15693锁块，被锁单块会变成只读，且不可逆
 *  入口参数：  addr：要锁卡片的块地址
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)iso15693LockBlock:(Byte)addr callback:(onReceiveIso15693LockListener)block;

/*************************************************************************************
 *  方法名：   iso15693Cmd
 *  功能：     ISO15693指令通道
 *  入口参数：  data:要传输到指令
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)iso15693Cmd:(NSData *)data callback:(onReceiveIso15693CmdListener)block;

/**
 * ISO15693读单个块数据，同步阻塞方式，注意：不能在主线程里运行
 * @param addr     要读的地址
 * @return         读取到的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)iso15693Read:(Byte)addr;

/**
 * ISO15693读多个块数据指令，同步阻塞方式，注意：不能在主线程里运行
 * @param addr     要读的块的起始地址
 * @param number   要读块的数量,必须大于0
 * @return         读取到的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)iso15693ReadMultiple:(Byte)addr number:(Byte)number;

/**
 * ISO15693写一个块，同步阻塞方式，注意：不能在主线程里运行
 * @param addr        要写的块的地址
 * @param writeData   要写的数据，必须4个字节
 * @return            true:写入成功   false：写入失败
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)iso15693Write:(Byte)addr writeData:(NSData *)writeData;

/**
 * ISO15693写多个块，同步阻塞方式，注意：不能在主线程里运行
 * @param addr        要写的块的地址
 * @param number      要写的块数量,必须大于0
 * @param writeData   要写的数据，必须4个字节
 * @return            true:写入成功   false：写入失败
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)iso15693WriteMultiple:(Byte)addr number:(Byte)number writeData:(NSData *)writeData;

/**
 * ISO15693锁住一个块，同步阻塞方式，注意：不能在主线程里运行
 * @param addr        要锁的块的起始地址
 * @return            true:写入成功   false：写入失败
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)iso15693LockBlock:(Byte)addr;

/**
 * ISO15693指令通道，同步阻塞方式，注意：不能在主线程里运行
 * @param data     发送的数据
 * @return         返回的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)iso15693Transceive:(NSData *)data;
@end











