//
//  DeviceManager.h
//  ble_nfc_sdk
//
//  Created by Lochy on 16/6/22.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define BUTTON_VALUE_SHORT_ENTER   1    //按键短按
#define BUTTON_VALUE_LONG_ENTER    2    //按键长按按

typedef NSUInteger DKCardType;
NS_ENUM(DKCardType) {
    DKCardTypeDefault = 0,
    DKIso14443A_CPUType = 1,
    DKIso14443B_CPUType = 2,
    DKFeliCa_Type = 3,
    DKMifare_Type = 4,
    DKIso15693_Type = 5,
    DKUltralight_type = 6,
    DKDESFire_type = 7
};

//代码块定义
//获取设备连接回调
typedef void(^onReceiveConnectBtDeviceListener)(BOOL blnIsConnectSuc);
//断开设备连接回调
typedef void(^onReceiveDisConnectDeviceListener)(BOOL blnIsDisConnectDevice);
//检测设备状态回调
typedef void(^onReceiveConnectionStatusListener)(BOOL blnIsConnection);
//获取设备电量回调
typedef void(^onReceiveDeviceBtValueListener)(float btVlueMv);
//获取设备固件版本号回调
typedef void(^onReceiveDeviceVersionListener)(NSUInteger versionNum);
//非接寻卡回调
typedef void(^onReceiveRfnSearchCardListener)(BOOL isblnIsSus, DKCardType cardType, NSData *CardSn, NSData *bytCarATS);
//发送APDU指令回调
typedef void(^onReceiveRfmSentApduCmdListener)(BOOL isSuc, NSData *ApduRtnData);
//发送BPDU指令回调
typedef void(^onReceiveRfmSentBpduCmdListener)(BOOL isSuc, NSData *BpduRtnData);
//关闭天线回调
typedef void(^onReceiveRfmCloseListener)(BOOL blnIsCloseSuc);
//获取suica余额回调
typedef void(^onReceiveRfmSuicaBalanceListener)(BOOL blnIsSuc, NSData *BalanceData);
//读Felica回调
typedef void(^onReceiveRfmFelicaReadListener)(BOOL blnIsReadSuc, NSData *BlockData);
//Felica指令通道回调
typedef void(^onReceiveRfmFelicaCmdListener)(BOOL isSuc, NSData *returnData);
//ul卡指令接口回调
typedef void(^onReceiveRfmUltralightCmdListener)(BOOL isSuc, NSData *ulCmdRtnData);
//Mifare卡验证密码回调
typedef void(^onReceiveRfmMifareAuthListener)(BOOL isSuc);
//Mifare数据交换通道回调
typedef void(^onReceiveRfmMifareDataExchangeListener)(BOOL isSuc, NSData *returnData);
//测试通道回调
typedef void(^onReceivePalTestChannelListener)(NSData *returnData);

//打开蜂鸣器回调
typedef void(^onReceiveOpenBeepCmdListener)(BOOL isSuc);
//iso15693读单个块回调
typedef void(^onReceiveRfIso15693ReadSingleBlockListener)(BOOL isSuc, NSData *returnData);
//iso15693读多个块回调
typedef void(^onRecevieRfIso15693ReadMultipleBlockListener)(BOOL isSuc, NSData *returnData);
//iso15693写单个块回调
typedef void(^onReceiveRfIso15693WriteSingleBlockListener)(BOOL isSuc);
//iso15693写多个块回调
typedef void(^onReceiveRfIso15693WriteMultipleBlockListener)(BOOL isSuc);
//iso15693锁住块回调
typedef void(^onReceiveRfIso15693LockBlockListener)(BOOL isSuc);
//iso15693指令通道回调
typedef void(^onReceiveRfIso15693CmdListener)(BOOL isSuc, NSData *returnData);
//防丢器功能开关回调
typedef void(^onReceiveAntiLostSwitchListener)(BOOL isSuc);
//按键回调接口
typedef void(^onReceiveButtonEnterListener)(Byte keyValue);
//PSam上电复位通道接口
typedef void(^onReceivePSamResetListener)(BOOL isSuc, NSData* returnData);
//PSam掉电接口
typedef void(^onReceivePSamPowerDownListener)(BOOL isSuc);
//PSam apdu传输通道回调接口
typedef void(^onReceivePSamApduListener)(BOOL isSuc, NSData* returnData);
//修改蓝牙名称回调接口
typedef void(^onReceiveChangeBleNameListener)(BOOL isSuc);
//开启自动寻卡回调接口
typedef void(^onReceiveAutoSearchCardListener)(BOOL isSuc);
//ul卡任意长度读回调接口
typedef void(^onReceiveUlLongReadListener)(BOOL isSuc, NSData* returnData);
//ul卡任意长度写回调接口
typedef void(^onReceiveUlLongWriteListener)(BOOL isSuc);
    
    
//DKBleNfcDevice代理
@protocol DKBleNfcDeviceDelegate <NSObject>
//寻到卡代理
-(void)receiveRfnSearchCard:(BOOL)isblnIsSus cardType:(DKCardType)cardType uid:(NSData *)CardSn ats:(NSData *)bytCarATS;
@end

@interface DKDeviceManager : NSObject
@property (nonatomic,strong) NSNumber *autoSearchCardFlag;
@property (nonatomic) id<DKBleNfcDeviceDelegate> delegate;

//回调代码块设置相关接口
-(void)setOnReceiveConnectBtDeviceListenerBlock:(onReceiveConnectBtDeviceListener)block;
-(void)setOnReceiveDisConnectDeviceListenerBlock:(onReceiveDisConnectDeviceListener)block;
-(void)setOnReceiveConnectionStatusListenerBlock:(onReceiveConnectionStatusListener)block;
-(void)setOnReceiveDeviceBtValueListenerBlock:(onReceiveDeviceBtValueListener)block;
-(void)setOnReceiveDeviceVersionListenerBlock:(onReceiveDeviceVersionListener)block;
-(void)setOnReceiveRfnSearchCardListenerBlock:(onReceiveRfnSearchCardListener)block;
-(void)setOnReceiveRfmSentApduCmdListenerBlock:(onReceiveRfmSentApduCmdListener)block;
-(void)setOnReceiveRfmSentBpduCmdListenerBlock:(onReceiveRfmSentBpduCmdListener)block;
-(void)setOnReceiveRfmCloseListenerBlock:(onReceiveRfmCloseListener)block;
-(void)setOnReceiveRfmSuicaBalanceListenerBlock:(onReceiveRfmSuicaBalanceListener)block;
-(void)setOnReceiveRfmFelicaReadListenerBlock:(onReceiveRfmFelicaReadListener)block;
-(void)setOnReceiveRfmUltralightCmdListenerBlock:(onReceiveRfmUltralightCmdListener)block;
-(void)setOnReceiveRfmFelicaCmdListenerBlock:(onReceiveRfmFelicaCmdListener)block;
-(void)setOnReceiveRfmMifareAuthListenerBlock:(onReceiveRfmMifareAuthListener)block;
-(void)setOnReceiveRfmMifareDataExchangeListenerBlock:(onReceiveRfmMifareDataExchangeListener)block;
-(void)setOnReceivePalTestChannelListenerBlock:(onReceivePalTestChannelListener)block;
//-(void)requestConnectBleDevice:(CBPeripheral *)peripheral connectCallbackBlock:(onReceiveConnectBtDeviceListener)block;
//-(void)requestDisConnectDeviceWithCallbackBlock:(onReceiveDisConnectDeviceListener)block;
//-(void)requestConnectionStatusWithCallbackBlock:(onReceiveConnectionStatusListener)block;
-(void)setOnReceiveOpenBeepCmdListenerBlock:(onReceiveOpenBeepCmdListener)block;
-(void)setOnReceiveRfIso15693ReadSingleBlockListenerBlock:(onReceiveRfIso15693ReadSingleBlockListener)block;
-(void)setOnRecevieRfIso15693ReadMultipleBlockListenerBlock:(onRecevieRfIso15693ReadMultipleBlockListener)block;
-(void)setOnReceiveRfIso15693WriteSingleBlockListenerBlock:(onReceiveRfIso15693WriteSingleBlockListener)block;
-(void)setOnReceiveRfIso15693WriteMultipleBlockListenerBlock:(onReceiveRfIso15693WriteMultipleBlockListener)block;
-(void)setOonReceiveRfIso15693LockBlockListenerBlock:(onReceiveRfIso15693LockBlockListener)block;
-(void)setOonReceiveRfIso15693CmdListenerBlock:(onReceiveRfIso15693CmdListener)block;
-(void)setOonReceiveAntiLostSwitchListenerBlock:(onReceiveAntiLostSwitchListener)block;
-(void)setOonReceiveButtonEnterListenerBlock:(onReceiveButtonEnterListener)block;
-(void)setOnReceivePSamResetListener:(onReceivePSamResetListener)block;
-(void)setOnReceivePSamPowerDownListener:(onReceivePSamPowerDownListener)block;
-(void)setOnReceivePSamApduListener:(onReceivePSamApduListener)block;
-(void)setOnReceiveChangeBleNameListener:(onReceiveChangeBleNameListener)block;
-(void)setOnReceiveAutoSearchCardListener:(onReceiveAutoSearchCardListener)block;
-(void)setOnReceiveUlLongReadListener:(onReceiveUlLongReadListener)block;
-(void)setOnReceiveUlLongWriteListener:(onReceiveUlLongWriteListener)block;

/*************************************************************************************
 *  方法名：   getCard
 *  功能：     获取卡片实例
 *  入口参数：  无
 *  返回参数：  卡片的实例
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(id)getCard;

/*************************************************************************************
 *  方法名：   requestDeviceBtValueWithCallbackBlock:
 *  功能：     获取设备电池电压，单位v
 *  入口参数：  block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestDeviceBtValueWithCallbackBlock:(onReceiveDeviceBtValueListener)block;

/*************************************************************************************
 *  方法名：   requestDeviceVersionWithCallbackBlock:
 *  功能：     获取设备版本号 1byte
 *  入口参数：  block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestDeviceVersionWithCallbackBlock:(onReceiveDeviceVersionListener)block;

/*************************************************************************************
 *  方法名：   requestRfmSearchCard: callbackBlock
 *  功能：     寻卡（寻卡成功会自动打开天线，寻卡失败会自动关闭天线）
 *  入口参数：  cardType：寻卡类型 目前支持 DKCardTypeDefault
 *            block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmSearchCard:(DKCardType)cardType callbackBlock:(onReceiveRfnSearchCardListener)block;

/*************************************************************************************
 *  方法名：   requestRfmSentApduCmd: callbackBlock
 *  功能：     发送apdu指令，此命令只对iso14443-a的cpu卡有效
 *  入口参数：  apduData：要发送的apdu指令数据
 *            block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmSentApduCmd:(NSData *)apduData callbackBlock:(onReceiveRfmSentApduCmdListener)block;

/*************************************************************************************
 *  方法名：   requestRfmSentBpduCmd: callbackBlock
 *  功能：     发送apdu指令，此命令只对身份证有效
 *  入口参数：  apduData：要发送的apdu指令数据
 *            block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmSentBpduCmd:(NSData *)apduData callbackBlock:(onReceiveRfmSentBpduCmdListener)block;

/*************************************************************************************
 *  方法名：   requestRfmCloseWhitCallbackBlock:
 *  功能：     关闭天线指令（寻卡成功会自动打开天线）
 *  入口参数：  block：操作结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmCloseWhitCallbackBlock:(onReceiveRfmCloseListener)block;

/*************************************************************************************
 *  方法名：   requestRfmSuicaBalanceWhitCallbackBlock:
 *  功能：     读取suica（FeliCa协议）余额
 *  入口参数：  block：操作结果会通过block回调，回调中会返回6个字节数据，前两字节为小数点余数，后四位
 *            为整数位，低位在前。
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmSuicaBalanceWhitCallbackBlock:(onReceiveRfmSuicaBalanceListener)block;

/*************************************************************************************
 *  方法名：   requestRfmFelicaRead:
 *  功能：     读felica块数据
 *  入口参数：  systemCode：系统码，两字节，高位在前
 *            blockAddr：要读的块地址
 *            block：回调，回调中返回读到的块数据，总共16字节
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmFelicaRead:(NSData *)systemCode blockAddr:(NSData *)blockAddr callback:(onReceiveRfmFelicaReadListener)block;

/*************************************************************************************
 *  方法名：   requestRfmUltralightCmd:
 *  功能：     UL卡指令接口
 *  入口参数：  ulCmdData：ul指令
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmUltralightCmd:(NSData *)ulCmdData callback:(onReceiveRfmUltralightCmdListener)block;

/*************************************************************************************
 *  方法名：   requestRfmUltralightLongRead:
 *  功能：     UL卡快速读
 *  入口参数：  startAddress：要读的起始地址
 *            number：要读的块数量（一个块4 byte）， 0 < number < 0x3f
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmUltralightLongRead:(Byte)startAddress number:(int)number callback:(onReceiveUlLongReadListener)block;

/*************************************************************************************
 *  方法名：   requestRfmUltralightLongWrite:
 *  功能：     UL卡快速写
 *  入口参数：  startAddress：要写的起始地址
 *            data：要写的数据
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmUltralightLongWrite:(Byte)startAddress writeData:(NSData *)data callback:(onReceiveUlLongWriteListener)block;

/*************************************************************************************
 *  方法名：   requestRfmFelicaCmd:
 *  功能：     Felica卡指令接口
 *  入口参数：  wOption: PH_EXCHANGE_DEFAULT/PH_EXCHANGE_BUFFER_FIRST/PH_EXCHANGE_BUFFER_CONT/
                       PH_EXCHANGE_BUFFER_LAST
 *            wN: 等待时间
 *            data: 指令
 *            block: 指令结果通过block返回
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmFelicaCmd:(NSInteger)wOption waitN:(NSInteger)wN cmdData:(NSData *)data callback:(onReceiveRfmFelicaCmdListener)block;

/*************************************************************************************
 *  方法名：   requestRfmMifareAuth:
 *  功能：     Mifare卡验证密码
 *  入口参数：  bBlockNo：需要验证密码到块地址
 *            keyType: 密码类型 MIFARE_KEY_TYPE_A or MIFARE_KEY_TYPE_B
 *            key: 6字节密码
 *            uid: 4字节uid
 *            block：回调，回调中返回验证的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmMifareAuth:(Byte)bBlockNo keyType:(Byte)bKeyType key:(NSData *)key uid:(NSData *)uid callback:(onReceiveRfmMifareAuthListener)block;

/*************************************************************************************
 *  方法名：   requestRfmMifareDataExchange:
 *  功能：     Mifare卡数据通道
 *  入口参数：  data：需要与卡片交换地数据
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmMifareDataExchange:(NSData *)data callback:(onReceiveRfmMifareDataExchangeListener)block;

/*************************************************************************************
 *  方法名：   requestPalTestChannel:
 *  功能：     通讯协议测试通道
 *  入口参数：  data：从上位机到读卡器到数据
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestPalTestChannel:(NSData *)data callback:(onReceivePalTestChannelListener)block;

/*************************************************************************************
 *  方法名：   requestRfmIso15693WriteSingleBlock
 *  功能：     ISO15693写单个块
 *  入口参数：  uid:要写的卡片的uid，必须4个字节
 *            addr：要写卡片的块地址
 *            writeData:要写的数据，必须4个字节
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmIso15693WriteSingleBlock:(NSData *)uid address:(Byte)addr writeData:(NSData *)writeData callback:(onReceiveRfIso15693WriteSingleBlockListener)block;

/*************************************************************************************
 *  方法名：   requestRfmIso15693WriteMultipleBlock
 *  功能：     ISO15693写多个块
 *  入口参数：  uid:要写的卡片的uid，必须4个字节
 *            addr：要写卡片的块地址
 *            writeData:要写的数据，必须4 * number个字节
 *            number:要写的块数量,必须大于0
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmIso15693WriteMultipleBlock:(NSData *)uid address:(Byte)addr number:(Byte)number writeData:(NSData *)writeData callback:(onReceiveRfIso15693WriteMultipleBlockListener)block;

/*************************************************************************************
 *  方法名：   requestRfmIso15693LockBlock
 *  功能：     ISO15693锁块，被锁单块会变成只读，且不可逆
 *  入口参数：  uid:要锁的卡片的uid，必须4个字节
 *            addr：要锁卡片的块地址
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmIso15693LockBlock:(NSData *)uid address:(Byte)addr callback:(onReceiveRfIso15693LockBlockListener)block;

/*************************************************************************************
 *  方法名：   requestRfmIso15693ReadMultipleBlock
 *  功能：     ISO15693读多个块
 *  入口参数：  uid:要读的卡片的uid，必须4个字节
 *            addr：要读卡片的块地址
 *            number:要读的块数量,必须大于0
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmIso15693ReadMultipleBlock:(NSData *)uid address:(Byte)addr number:(Byte)number callback:(onRecevieRfIso15693ReadMultipleBlockListener)block;

/*************************************************************************************
 *  方法名：   requestRfmIso15693ReadSingleBlock
 *  功能：     ISO15693读单个块
 *  入口参数：  uid:要读的卡片的uid，必须4个字节
 *            addr：要读卡片的块地址
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmIso15693ReadSingleBlock:(NSData *)uid address:(Byte)addr callback:(onReceiveRfIso15693ReadSingleBlockListener)block;

/*************************************************************************************
 *  方法名：   requestRfmIso15693CmdData
 *  功能：     ISO15693指令通道
 *  入口参数：  data:要传输到指令
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmIso15693CmdData:(NSData *)data callback:(onReceiveRfIso15693CmdListener)block;

/*************************************************************************************
 *  方法名：   requestAntiLostSwitch
 *  功能：     防丢器功能开关指令
 *  入口参数：  s：YES：打开防丢器功能 NO：关闭防丢器功能
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestAntiLostSwitch:(BOOL)s callback:(onReceiveAntiLostSwitchListener)block;

/*************************************************************************************
 *  方法名：   requestButtonEnterWhitCallbackBlock
 *  功能：     获取按键键值指令
 *  入口参数：  block：回调，有按键按下时会回调到block中
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestButtonEnterWhitCallbackBlock:(onReceiveButtonEnterListener)block;

/*************************************************************************************
 *  方法名：   requestOpenBeep
 *  功能：     打开蜂鸣器
 *  入口参数：  opneTimeMs: 打卡蜂鸣器的时间，0~0xffff，单位ms
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestOpenBeep:(int)openTimeMs callback:(onReceiveOpenBeepCmdListener)block;

/*************************************************************************************
 *  方法名：   requestOpenBeep
 *  功能：     打开蜂鸣器
 *  入口参数：  onDelayMs: 打开蜂鸣器时间：0~0xffff，单位ms
 *            offDelayMs：关闭蜂鸣器时间：0~0xffff，单位ms
 *            n：蜂鸣器响多少声：0~255
 *            block：回调，回调中返回指令运行的结果
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestOpenBeep:(int)onDelayMs offDelay:(int)offDelayMs number:(int)n callback:(onReceiveOpenBeepCmdListener)block;

/*************************************************************************************
 *  方法名：   requestPSamReset
 *  功能：     PSam上电复位指令
 *  入口参数：  block:复位成功ATR会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestPSamReset:(onReceivePSamResetListener)block;

/*************************************************************************************
 *  方法名：   requestPSamPowerDown
 *  功能：     PSam掉电
 *  入口参数：  block:结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestPSamPowerDown:(onReceivePSamPowerDownListener)block;

/*************************************************************************************
 *  方法名：   requestChangeBleName
 *  功能：     修改蓝牙名称
 *  入口参数：  bleName：蓝牙名
 *            block:结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestChangeBleName:(NSString *)bleName callback:(onReceiveChangeBleNameListener)block;

//自动寻卡
//en：true-开启自动寻卡，false：关闭自动寻卡
//delayMs：寻卡间隔,单位 10毫秒
//bytCardType: ISO14443_P3-寻M1/UL卡，ISO14443_P4-寻CPU卡
/*************************************************************************************
 *  方法名：   requestRfmAutoSearchCard
 *  功能：     开启/关闭自动寻卡
 *  入口参数：  en：true-开启自动寻卡，false：关闭自动寻卡
 *            delayMs：寻卡间隔,单位 10毫秒
 *            bytCardType: ISO14443_P3-寻M1/UL卡，ISO14443_P4-寻CPU卡
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestRfmAutoSearchCard:(BOOL)en delay:(Byte)delayMs cardType:(Byte)bytCardType callback:(onReceiveAutoSearchCardListener)block;

/*************************************************************************************
 *  方法名：   requestPSamApdu
 *  功能：     PSam apdu指令传输
 *  入口参数：  data：要传输的数据
 *            block:结果会通过block回调
 *  返回参数：  无
 *  作者：     Lochy.Huang
 *************************************************************************************/
-(void)requestPSamApdu:(NSData *)data callback:(onReceivePSamApduListener)block;
@end















