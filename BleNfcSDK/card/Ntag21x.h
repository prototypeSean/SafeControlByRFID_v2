//
//  Ntag21x.h
//  ble_nfc_sdk
//
//  Created by lochy on 16/10/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ultralight.h"

#define SIZE_NTAG213  144
#define SIZE_NTAG215  504
#define SIZE_NTAG216  888
#define SIZE_DEFAULT  SIZE_NTAG213

#define ERR_MEMORY_OUT  @"Data is too long for this tag!"
#define ERR_WRITE_FAIL  @"Write data fail!"
#define ERR_NO_ERROR    @"No error"

//代码块定义
//任意长度读回调
typedef void(^onReceiveNtag21xLongReadListener)(BOOL isSuc, NSData* returnData);
//任意长度写回调
typedef void(^onReceiveNtag21xLongWriteListener)(BOOL isSuc, NSString* error);
//写一个NDEF文本格式到标签回调
typedef void(^onReceiveNdefTextWriteListener)(BOOL isSuc, NSString* error);
//从标签中读取一个NEDF文本格式的数据回调
typedef void(^onReceiveNdefTextReadListener)(BOOL isSuc, NSString* error, NSString* returnString);



@interface Ntag21x : Ultralight

/*
 * 方 法 名： ntag21xLongRead
 * 功    能：ntag21x任意长度读
 * 参    数：startAddress - 读起始地址
 *          endAddress   - 读块结束地址
 *          block        - 读块结果回调函数
 * 返 回 值：无
 */
-(void)ntag21xLongRead:(Byte)startAddress endAddress:(Byte)endAddress callbackBlock:(onReceiveNtag21xLongReadListener)block;

/*
 * 方 法 名： ntag21xLongWrite
 * 功    能：ntag21x任意长度写
 * 参    数：startAddress - 写起始地址
 *          writeData    - 要写的数据
 *          block        - 写块结果回调函数
 * 返 回 值：无
 */
-(void)ntag21xLongWrite:(Byte)startAddress writeData:(NSData*)writeData callbackBlock:(onReceiveNtag21xLongWriteListener)block;

/*
 * 方 法 名： NdefTextWrite
 * 功    能：ntag21x写一个NDEF格式的文本
 * 参    数：text         - 要写的文本
 *          block        - 结果回调函数
 * 返 回 值：无
 */
-(void)NdefTextWrite:(NSString *)text callbackBlock:(onReceiveNdefTextWriteListener)block;

/*
 * 方 法 名： NdefTextRead
 * 功    能：Ndef读取一个NDEF格式的数据
 * 参    数：block        - 结果回调函数
 * 返 回 值：无
 */
-(void)NdefTextReadWithCallbackBlock:(onReceiveNdefTextReadListener)block;

/**
 * 任意长度读，同步阻塞方式，注意：不能在主线程里运行
 * @param startAddress 要读取的起始地址
 * @param endAddress 要读取的结束地址
 * @return         读取到的数据
 * @throws CardNoResponseException
 *                  卡片无响应时会抛出异常
 */
-(NSData *)ntag21xLongRead:(Byte)startAddress endAddress:(Byte)endAddress;

/**
 * 任意长度写，同步阻塞方式，注意：不能在主线程里运行
 * @param startAddress 要写入的起始地址
 * @param writeBytes 要写入的数据
 * @return         true：写入成功，  false：写入失败
 * @throws CardNoResponseException
 *                  卡片无响应时会抛出异常
 */
-(BOOL)ntag21xLongWrite:(Byte)startAddress writeData:(NSData*)writeData;
@end





