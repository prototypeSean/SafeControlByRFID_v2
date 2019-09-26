//
//  ComByteManager.h
//  ble_nfc_sdk
//
//  Created by Lochy on 16/6/22.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import <Foundation/Foundation.h>

//Command define
#define PAL_TEST_CHANNEL                  (0x00)            //协议测试通道
#define MIFARE_AUTH_COM                   (0x40)            //MIFARE卡验证密钥指令
#define MIFARE_COM                        (0x41)            //Mifare卡指令通道
#define FIRMWARE_OAD_COM                  (0x52)            //固件空中升级指令
#define SAVE_KEY_COM                      (0x5f)            //保存秘钥指令
#define SAVE_VARIABLE_COM                 (0x5e)            //保存可变序列指令
#define ACTIVATE_PICC_COM                 (0x62)            //激活卡片指令
#define AUTO_SEARCH_CARD_COM              (0x63)            //自动寻卡指令
#define ANTENNA_OFF_COM                   (0x6E)            //关闭天线指令
#define APDU_COM                          (0x6F)            //apdu指令
#define BPDU_COM                          (0x7F)            //身份证APDU指令通道
#define ISO7816_RESET_CMD                 (0x90)            //ISO7816复位指令
#define ISO7816_POWE_OFF_CMD              (0x91)            //ISO7816掉电指令
#define ISO7816_CMD                       (0x92)            //ISO7816命令传输指令
#define ULTRALIGHT_CMD                    (0xD0)            //ul卡指令通道
#define ULTRALIGHT_LONG_READ              (0xD1)            //UL卡任意长度读指令通道
#define ULTRALIGHT_LONG_WRITE             (0xD2)            //UL卡任意长度写指令通道
#define ISO15693_READ_SINGLE_BLOCK_COM    (0xE0)            /*ISO15693读单个块数据*/
#define ISO15693_READ_MULTIPLE_BLOCK_COM  (0xE1)            /*ISO15693读单个块数据*/
#define ISO15693_WRITE_SINGLE_BLOCK_COM   (0xE2)            /*ISO15693写单个块数据*/
#define ISO15693_WRITE_MULTIPLE_BLOCK_COM (0xE3)            /*ISO15693写单个块数据*/
#define ISO15693_LOCK_BLOCK_COM           (0xE4)            /*ISO15693锁块*/
#define ISO15693_CMD                      (0xE5)            /*ISO15693命令通道*/
#define GET_SUICA_BALANCE_COM             (0xF0)            //获取SUICA余额指令
#define FELICA_READ_COM                   (0xF1)            //读FeliCa指令
#define FELICA_COM                        (0xF2)            //FeliCa指令通道

#define GET_BT_VALUE_COM                  (0x70)            //获取电池电量
#define GET_VERSIONS_COM                  (0x71)            //获取设备版本号指令
#define BEEP_OPEN_COM                     (0x72)            //打开蜂鸣器
#define KEYBOARD_INPUT_COM                (0x73)            //键盘输入指令
#define NUMBER_DISPLAY_COM                (0x74)            //数码管显示指令
#define BUTTON_INPUT_COM                  (0x75)            //按键按下指令
#define ANTI_LOST_SWITCH_COM              (0x76)            //防丢器开关指令
#define SPEAK_COM                         (0x77)            //语音播报指令
#define CHANGE_BLE_NAME_COM               (0x79)            //修改蓝牙名称

#define VERIFY_START_COM                  (0x80)            //开始验证指令
#define VERIFY_RETURN_COM                 (0x82)            //服务器返回验证

//Comand run result define
#define COMAND_RUN_SUCCESSFUL             (0x90)            //命令运行成功
#define COMAND_RUN_ERROR                  (0x6E)            //命令运行出错

//Error code defie
#define NO_ERROR_CODE                     (0x00)            //运行正确时的错误码
#define DEFAULT_ERROR_CODE                (0x81)            //默认错误码

#define  ISO14443_P3                        1
#define  ISO14443_P4                        2
#define  PH_EXCHANGE_DEFAULT                0x0000
#define  PH_EXCHANGE_LEAVE_BUFFER_BIT       0x4000
#define  PH_EXCHANGE_BUFFERED_BIT           0x8000
#define  PH_EXCHANGE_BUFFER_FIRST           PH_EXCHANGE_DEFAULT | PH_EXCHANGE_BUFFERED_BIT
#define  PH_EXCHANGE_BUFFER_CONT            PH_EXCHANGE_DEFAULT | PH_EXCHANGE_BUFFERED_BIT | PH_EXCHANGE_LEAVE_BUFFER_BIT
#define  PH_EXCHANGE_BUFFER_LAST            PH_EXCHANGE_DEFAULT | PH_EXCHANGE_LEAVE_BUFFER_BIT

//Mifare Key type
#define  MIFARE_KEY_TYPE_A                  ((Byte)0x0A)
#define  MIFARE_KEY_TYPE_B                  ((Byte)0x0B)

#define  Start_Frame                        0
#define  Follow_Frame                       1

#define  MAX_FRAME_NUM                      63
#define  MAX_FRAME_LEN                      20
#define  MAX_FRAME_DATA_LEN                 (MAX_FRAME_NUM * MAX_FRAME_LEN)

#define  Rcv_Status_Idle                    0
#define  Rcv_Status_Start                   1
#define  Rcv_Status_Follow                  2
#define  Rcv_Status_Complete                3

//DKComByteManager代理
@protocol DKComByteManagerDelegate <NSObject>
-(void)comByteManagerCallback:(BOOL)isSuc rcvData:(NSData *)rcvData;
@end

@interface DKComByteManager : NSObject
@property (nonatomic) id<DKComByteManagerDelegate> delegate;

-(id)initWhitDelegate:(id)theDelegate;
-(Byte)getCmd;
-(BOOL)getCmdRunStatus;
-(NSInteger)getRcvDataLen;
-(BOOL)rcvData:(NSData *)rcvData;

//A卡激活指令
+(NSData *)cardActivityComData;
//指定激活卡片到哪一个协议层，例如cpu卡当成m1卡用时必须用此指令进行寻卡
+(NSData *)cardActivityComData:(Byte)protocolLayer;
//去激活指令(关闭天线)
+(NSData *)rfPowerOffComData;
//获取蓝牙读卡器电池电压指令
+(NSData *)getBtValueComData;
//获取设备版本号指令
+(NSData *)getVerisionsComData;
//非接接口Apdu指令
+(NSData *)rfApduCmdData:(NSData *)ApduData;
//Felica读余额指令通道
+(NSData *)requestRfmSuicaBalance;
//Felica读指令通道
+(NSData *)requestRfmFelicaRead:(NSData *)systemCode blockAddr:(NSData *)blockAddr;
//Felica指令通道
//wOption:PH_EXCHANGE_DEFAULT/PH_EXCHANGE_BUFFER_FIRST/PH_EXCHANGE_BUFFER_CONT/PH_EXCHANGE_BUFFER_LAST
//wN:等待时间
//data：指令
+(NSData *)felicaCmdData:(NSInteger)wOption waitN:(NSInteger)wN data:(NSData *)data;
//UL指令通道
+(NSData *)ultralightCmdData:(NSData *)ulCmdData;
//Bpdu指令通道
+(NSData *)rfBpduCmdData:(NSData *)BpduData;
//Mifare卡验证密码指令
+(NSData *)rfMifareAuthCmdData:(Byte)bBlockNo keyType:(Byte)bKeyType key:(NSData *)pKey uid:(NSData *)pUid;
//Mifarek卡数据交换指令
+(NSData *)rfMifareDataExchangeCmdData:(NSData *)data;
//通信协议测试通道指令
+(NSData *)getTestChannelData:(NSData *)data;
//ISO15693读单个块数据指令
//uid:要读的卡片的uid，必须4个字节
//addr：要读的块地址
+(NSData *)iso15693ReadSingleBlockCmdData:(NSData *)uid address:(Byte)addr;
//ISO15693读多个块数据指令
//uid:要读的卡片的uid，必须4个字节
//addr：要读的块地址
//number:要读的块数量,必须大于0
+(NSData *)iso15693ReadMultipleBlockCmdData:(NSData *)uid address:(Byte)addr number:(Byte)number;
//ISO15693写一个块
//uid:要写的卡片的uid，必须4个字节
//addr：要写卡片的块地址
//writeData:要写的数据，必须4个字节
+(NSData *)iso15693WriteSingleBlockCmdData:(NSData *)uid address:(Byte)addr writeData:(NSData *)writeData;
//ISO15693写多个块
//uid:要写的卡片的uid，必须4个字节
//addr：要写的块地址
//number:要写的块数量,必须大于0
//writeData: 要写的数据，必须number * 4字节
+(NSData *)iso15693WriteMultipleBlockCmdData:(NSData *)uid address:(Byte)addr number:(Byte)number writeData:(NSData *)writeData;
//ISO15693锁住一个块
//uid：要写的卡片的UID，必须4个字节
//addr：要锁住的块地址
+(NSData *)iso15693LockBlockCmdData:(NSData *)uid address:(Byte)addr;
//ISO15693指令通道
+(NSData *)iso15693CmdData:(NSData *)data;
//打开蜂鸣器指令
//onDelayMs: 打开蜂鸣器时间：0~0xffff，单位ms
//offDelayMs：关闭蜂鸣器时间：0~0xffff，单位ms
//n：蜂鸣器响多少声：0~255
+(NSData *)openBeepCmdData:(int)onDelayMs offDelay:(int)offDelayMs number:(int)n;
//打开蜂鸣器指令
//openTimeMs: 打开蜂鸣器时间：0~0xffff，单位ms
+(NSData *)openBeepCmdData:(int)openTimeMs;
//防丢器开关指令
//s：YES：打开防丢器功能 NO：关闭防丢器功能
+(NSData *)antiLostSwitchCmdData:(BOOL)s;

//PSam上电复位指令
+(NSData *)resetPSamCmdBytes;

//PSam掉电指令
+(NSData *)PSamPowerDownCmdBytes;

//PSam APDU传输命令
+(NSData *)PSamApduCmdBytes:(NSData *) data;

//自动寻卡
//en：true-开启自动寻卡，false：关闭自动寻卡
//delayMs：寻卡间隔,单位 10毫秒
//bytCardType: ISO14443_P3-寻M1/UL卡，ISO14443_P4-寻CPU卡
+(NSData *)autoSearchCardCmdBytes:(BOOL) en delay:(Byte)delayMs cardType:(Byte) bytCardType;

//修改蓝牙名称
//bytes：转换成bytes后的名称
+(NSData *)changeBleNameCmdBytes:(NSData *)data;

//UL卡快速读指令通道
//startAddress：要读的起始地址
//number：要读的块数量（一个块4 byte）， 0 < number < 0x3f
+(NSData *)ultralightLongReadCmdBytes:(Byte)startAddress number:(int)number;

//UL卡快速写指令通道
//startAddress：要写的起始地址
//data：要写的数据
+(NSData *)ultralightLongWriteCmdBytes:(Byte)startAddress data:(NSData *)data;
@end







