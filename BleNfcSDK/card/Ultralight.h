//
//  Ultralight.h
//  ble_nfc_sdk
//
//  Created by lochy on 16/10/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

#define  UL_MAX_FAST_READ_BLOCK_NUM (4)
#define  LONG_READ_MAX_NUMBER       (0x30)

//代码块定义
//读取卡片版本回调
typedef void(^onReceiveUltralightGetVersionListener)(BOOL isSuc, NSData* returnData);
//读块回调
typedef void(^onReceiveUltralightReadListener)(BOOL isSuc, NSData* returnData);
//快速读回调
typedef void(^onReceiveUltralightFastReadListener)(BOOL isSuc, NSData* returnData);
//写块回调
typedef void(^onReceiveUltralightWriteListener)(BOOL isSuc, NSData* returnData);
//读次数回调
typedef void(^onReceiveUltralightReadCntListener)(BOOL isSuc, NSData* returnData);
//验证密码回调
typedef void(^onReceiveUltralightPwdAuthListener)(BOOL isSuc);
//指令通道回调
typedef void(^onReceiveUltralightCmdListener)(BOOL isSuc, NSData* returnData);

@interface Ultralight : Card

/*************************************************************************************
 *  方法名：   getVersionWithCallbackBlock:
 *  功能：     获取卡片版本
 *  入口参数：  block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)ultralightGetVersionWithCallbackBlock:(onReceiveUltralightGetVersionListener)block;

/*************************************************************************************
 *  方法名：   read
 *  功能：     读块，将返还16字节数据（4 block）
 *  入口参数：  address：要读的块地址
 *            block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)ultralightRead:(Byte)address callbackBlock:(onReceiveUltralightReadListener)block;

/*************************************************************************************
 *  方法名：   fastRead
 *  功能：     快速读指令，建议一次读不要超过20个block
 *  入口参数：  startAddress：要读的块的起始地址
 *            endAddress：要读块的结束地址
 *            block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)ultralightFastRead:(Byte)startAddress end:(Byte)endAddress callbackBlock:(onReceiveUltralightFastReadListener)block;

/*************************************************************************************
 *  方法名：   write
 *  功能：     写块
 *  入口参数：  address：要写的块地址
 *            data：要写的数据，4 byte
 *            block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)ultralightWrite:(Byte)address data:(NSData *)data callbackBlock:(onReceiveUltralightWriteListener)block;

/*************************************************************************************
 *  方法名：   readCntWithCallbackBlock
 *  功能：     读标签次数
 *  入口参数：  block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)ultralightReadCntWithCallbackBlock:(onReceiveUltralightReadCntListener)block;

/*************************************************************************************
 *  方法名：   pwdAuth
 *  功能：     验证标签密码
 *  入口参数：  password：密码，4 byte
 *            block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)ultralightPwdAuth:(NSData *)password callbackBlock:(onReceiveUltralightPwdAuthListener)block;

/*************************************************************************************
 *  方法名：   cmd
 *  功能：     通用指令通道
 *  入口参数：  cmdData：指令码，任意长度
 *            block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)ultralightCmd:(NSData *)cmdData callbackBlock:(onReceiveUltralightCmdListener)block;

/**
 * 读取卡片版本，同步阻塞方式，注意：不能在主线程里运行
 * @return         返回的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)ultralightGetVersion;

/**
 * 读单个块数据，同步阻塞方式，注意：不能在主线程里运行
 * @param addr     要读的地址
 * @return         读取到的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)ultralightRead:(Byte)addr;

/**
 * 快速读，同步阻塞方式，注意：不能在主线程里运行
 * @param startAddress     要读起始地址
 * @param endAddress       要读的结束地址
 * @return                 读取到的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)ultralightFastRead:(Byte)startAddress end:(Byte)endAddress;

/**
 * 快速读，同步阻塞方式，注意：不能在主线程里运行
 * @param startAddress     要读起始地址
 * @param number           要读的块数量（一个块4 byte）， 0 < number < 0x3f
 * @return                 读取到的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)ultralightLongReadSingle:(Byte)startAddress number:(int)number;

/**
 * 写一个块，同步阻塞方式，注意：不能在主线程里运行
 * @param addr        要写的块的地址
 * @param data        要写的数据，必须4个字节
 * @return            true:写入成功   false：写入失败
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)ultralightWrite:(Byte)addr data:(NSData*)data;

/**
 * 写一个块，同步阻塞方式，注意：不能在主线程里运行
 * @param startAddress   要写的块的起始地址
 * @param data        要写的数据，必须小于0x3f字节
 * @return            true:写入成功   false：写入失败
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)ultralightLongWriteSingle:(Byte)startAddress data:(NSData*)data;

/**
 * 读次数，同步阻塞方式，注意：不能在主线程里运行
 * @return            返回的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)ultralightReadCnt;


/**
 * 验证密码，同步阻塞方式，注意：不能在主线程里运行
 * @param password    要验证的密码，4 Bytes
 * @return            true:验证成功  false:验证失败
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)ultralightPwdAuth:(NSData *)password;

/**
 * 指令传输通道，同步阻塞方式，注意：不能在主线程里运行
 * @param data     发送的数据
 * @return         返回的数据
 * @throws CardNoResponseException
 *                  操作无响应时会抛出异常
 */
-(NSData *)ultralightTransceive:(NSData *)data;
@end










