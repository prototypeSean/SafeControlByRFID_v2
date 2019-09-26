//
//  DKBleNfcDevice.h
//  ble_nfc_sdk
//
//  Created by lochy on 17/6/2.
//  Copyright © 2017年 Lochy. All rights reserved.
//

#import "DKDeviceManager.h"

#define  DEVICE_NO_RESPONSE_TIME  500

@interface DKBleNfcDevice : DKDeviceManager

-(id)initWithDelegate:(id)theDelegate;

/**
 * 获取设备名称
 * @return         设备名称
 */
-(NSString *)getDeviceName;

/**
 * 是否正在自动寻卡
 * @return         true - 正在自动寻卡
 *                  false - 自动寻卡已经关闭
 */
-(BOOL)isAutoSearchCard;

/**
 * 获取设备当前电池电压，同步阻塞方式，注意：不能在主线程里运行
 * @return         设备电池电压，单位：V
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(double)getDeviceBatteryVoltage;


/**
 * 获取设备版本号，同步阻塞方式，注意：不能在主线程里运行
 * @return         设备版本号，1 字节
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(Byte)getDeviceVersions;

/**
 * 打开关闭防丢器功能，同步阻塞方式，注意：不能在主线程里运行
 * @param s         true - 打开
 *                  false - 关闭
 * @return         true - 防丢器功能已打开
 *                  false - 防丢器功能已关闭
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)antiLostSwitch:(BOOL)en;

/**
 * 关闭蜂鸣器，同步阻塞方式，注意：不能在蓝牙初始化的线程里运行
 * @return           true - 操作成功
 *                    false - 操作失败
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)closeBeep;

/**
 * 打开蜂鸣器指令，同步阻塞方式，注意：不能在蓝牙初始化的线程里运行
 * @param onDelayMs  打开蜂鸣器时间：0~0xffff，单位ms
 * @param offDelayMs 关闭蜂鸣器时间：0~0xffff，单位ms
 * @param n          蜂鸣器响多少声：0~255
 * @return           true - 操作成功
 *                    false - 操作失败
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)openBeep:(int)onDelayMs offDelay:(int)offDelayMs cnt:(int)n;

/**
 * 修改蓝牙名，同步阻塞方式，注意：不能在蓝牙初始化的线程里运行
 * @param bleName   新蓝牙名称
 * @return         true - 操作成功
 *                  false - 操作失败
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)changeBleName:(NSString *)bleName;

/**
 * 开始自动寻卡，同步阻塞方式，注意：不能在蓝牙初始化的线程里运行
 * @param delayMsx10   寻卡间隔,单位 10毫秒
 * @param bytCardType  ISO14443_P3 - 寻M1/UL卡
 *                      ISO14443_P4-寻CPU卡
 * @return             true - 操作成功
 *                      false - 操作失败
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)startAutoSearchCard:(Byte)delayMsx10 cardType:(Byte)bytCardType;

/**
 * 停止自动寻卡，同步阻塞方式，注意：不能在蓝牙初始化的线程里运行
 * @return             true - 操作成功
 *                      false - 操作失败
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)stoptAutoSearchCard;

/**
 * 关闭RF天线，同步阻塞方式，注意：不能在蓝牙初始化的线程里运行
 * @return             true - 操作成功
 *                      false - 操作失败
 * @throws DeviceNoResponseException
 *                  操作无响应时会抛出异常
 */
-(BOOL)closeRf;
@end
