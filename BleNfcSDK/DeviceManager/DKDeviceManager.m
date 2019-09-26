//
//  DeviceManager.m
//  ble_nfc_sdk
//
//  Created by Lochy on 16/6/22.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import "DKDeviceManager.h"
#import "DKBleManager.h"
#import "DKComByteManager.h"
#import "NSData+Hex.h"
#import "DKBleNfc.h"

@interface DKDeviceManager() <DKComByteManagerDelegate>
@property(nonatomic,strong)DKComByteManager *comByteManager;
@property(nonatomic,strong)CpuCard          *cpuCard;
@property(nonatomic,strong)Ultralight       *ultralight;
@property(nonatomic,strong)Ntag21x          *ntag21x;
@property(nonatomic,strong)Mifare           *mifare;
@property(nonatomic,strong)Iso14443bCard    *iso14443bCard;
@property(nonatomic,strong)FeliCa           *feliCa;
@property(nonatomic,strong)DESFire          *desFire;
@property(nonatomic,strong)Iso15693Card     *iso15693Card;
@end

@implementation DKDeviceManager
@synthesize comByteManager;
static DKCardType mCardType;

//获取设备连接回调
onReceiveConnectBtDeviceListener onReceiveConnectBtDeviceListenerBlock = nil;
//断开设备连接回调
onReceiveDisConnectDeviceListener onReceiveDisConnectDeviceListenerBlock = nil;
//检测设备状态回调
onReceiveConnectionStatusListener onReceiveConnectionStatusListenerBlock = nil;
//获取设备电量回调
onReceiveDeviceBtValueListener onReceiveDeviceBtValueListenerBlock = nil;
//获取设备固件版本号回调
onReceiveDeviceVersionListener onReceiveDeviceVersionListenerBlock = nil;
//非接寻卡回调
onReceiveRfnSearchCardListener onReceiveRfnSearchCardListenerBlock = nil;
//发送APDU指令回调
onReceiveRfmSentApduCmdListener onReceiveRfmSentApduCmdListenerBlock = nil;
//发送BPDU指令回调
onReceiveRfmSentBpduCmdListener onReceiveRfmSentBpduCmdListenerBlock = nil;
//关闭天线回调
onReceiveRfmCloseListener onReceiveRfmCloseListenerBlock = nil;
//获取suica余额回调
onReceiveRfmSuicaBalanceListener onReceiveRfmSuicaBalanceListenerBlock = nil;
//读Felica回调
onReceiveRfmFelicaReadListener onReceiveRfmFelicaReadListenerBlock = nil;
//Felica指令通道回调
onReceiveRfmFelicaCmdListener onReceiveRfmFelicaCmdListenerBlock = nil;
//UL卡指令接口回调
onReceiveRfmUltralightCmdListener onReceiveRfmUltralightCmdListenerBlock = nil;
//Mifare卡验证密码回调
onReceiveRfmMifareAuthListener onReceiveRfmMifareAuthListenerBlock = nil;
//Mifare数据交换通道回调
onReceiveRfmMifareDataExchangeListener onReceiveRfmMifareDataExchangeListenerBlock = nil;
//测试通道回调
onReceivePalTestChannelListener onReceivePalTestChannelListenerBlock = nil;
//打开蜂鸣器回调
onReceiveOpenBeepCmdListener onReceiveOpenBeepCmdListenerBlock = nil;
//iso15693读单个块回调
onReceiveRfIso15693ReadSingleBlockListener onReceiveRfIso15693ReadSingleBlockListenerBlock = nil;
//iso15693读多个块回调
onRecevieRfIso15693ReadMultipleBlockListener onRecevieRfIso15693ReadMultipleBlockListenerBlock = nil;
//iso15693写单个块回调
onReceiveRfIso15693WriteSingleBlockListener onReceiveRfIso15693WriteSingleBlockListenerBlock = nil;
//iso15693写多个块回调
onReceiveRfIso15693WriteMultipleBlockListener onReceiveRfIso15693WriteMultipleBlockListenerBlock = nil;
//iso15693锁住块回调
onReceiveRfIso15693LockBlockListener onReceiveRfIso15693LockBlockListenerBlock = nil;
//iso15693指令通道回调
onReceiveRfIso15693CmdListener onReceiveRfIso15693CmdListenerBlock = nil;
//防丢器功能开关回调
onReceiveAntiLostSwitchListener onReceiveAntiLostSwitchListenerBlock = nil;
//按键回调接口
onReceiveButtonEnterListener onReceiveButtonEnterListenerBlock = nil;
//PSam上电复位通道接口
onReceivePSamResetListener onReceivePSamResetListenerBlock = nil;
//PSam掉电接口
onReceivePSamPowerDownListener onReceivePSamPowerDownListenerBlock = nil;
//PSam apdu传输通道回调接口
onReceivePSamApduListener onReceivePSamApduListenerBlock = nil;
//修改蓝牙名称回调接口
onReceiveChangeBleNameListener onReceiveChangeBleNameListenerBlock = nil;
//开启自动寻卡回调接口
onReceiveAutoSearchCardListener onReceiveAutoSearchCardListenerBlock = nil;
//ul卡任意长度读回调接口
onReceiveUlLongReadListener onReceiveUlLongReadListenerBlock = nil;
//ul卡任意长度写回调接口
onReceiveUlLongWriteListener onReceiveUlLongWriteListenerBlock = nil;

-(id)init{
    self = [super init];//获得父类的对象并进行初始化
    if (self) {
        self.cpuCard = nil;
        self.ultralight = nil;
        self.ntag21x = nil;
        self.mifare = nil;
        self.iso14443bCard = nil;
        self.feliCa = nil;
        self.desFire = nil;
        self.iso15693Card = nil;
        mCardType = DKCardTypeDefault;
        self.autoSearchCardFlag = [[NSNumber alloc] initWithBool:NO];
        self.comByteManager = [[DKComByteManager alloc] initWhitDelegate:self];
        [[DKBleManager sharedInstance] setOnReceiveDataListenerBlock:^(NSData *data) {
            [self.comByteManager rcvData:data];
        }];
    }
    return self;
}

//获取卡片
-(id)getCard{
    switch (mCardType) {
        case DKIso14443A_CPUType:
        return self.cpuCard;
        
        case DKIso14443B_CPUType:
        return self.iso14443bCard;
        
        case DKFeliCa_Type:
        return self.feliCa;
        
        case DKMifare_Type:
        return self.mifare;
        
        case DKIso15693_Type:
        return self.iso15693Card;
        
        case DKUltralight_type:
        return self.ntag21x;
        
        case DKDESFire_type:
        return self.desFire;
        
        default:
        return nil;
    }
}

//代码块设置
-(void)setOnReceiveConnectBtDeviceListenerBlock:(onReceiveConnectBtDeviceListener)block {
    onReceiveConnectBtDeviceListenerBlock = block;
}
-(void)setOnReceiveDisConnectDeviceListenerBlock:(onReceiveDisConnectDeviceListener)block{
    onReceiveDisConnectDeviceListenerBlock = block;
}
-(void)setOnReceiveConnectionStatusListenerBlock:(onReceiveConnectionStatusListener)block{
    onReceiveConnectionStatusListenerBlock = block;
}
-(void)setOnReceiveDeviceBtValueListenerBlock:(onReceiveDeviceBtValueListener)block{
    onReceiveDeviceBtValueListenerBlock = block;
}
-(void)setOnReceiveDeviceVersionListenerBlock:(onReceiveDeviceVersionListener)block{
    self.OnReceiveDeviceVersionListenerBlock = block;
}
-(void)setOnReceiveRfnSearchCardListenerBlock:(onReceiveRfnSearchCardListener)block{
    onReceiveRfnSearchCardListenerBlock = block;
}
-(void)setOnReceiveRfmSentApduCmdListenerBlock:(onReceiveRfmSentApduCmdListener)block{
    onReceiveRfmSentApduCmdListenerBlock = block;
}
-(void)setOnReceiveRfmSentBpduCmdListenerBlock:(onReceiveRfmSentBpduCmdListener)block{
    onReceiveRfmSentBpduCmdListenerBlock = block;
}
-(void)setOnReceiveRfmCloseListenerBlock:(onReceiveRfmCloseListener)block{
    onReceiveRfmCloseListenerBlock = block;
}
-(void)setOnReceiveRfmSuicaBalanceListenerBlock:(onReceiveRfmSuicaBalanceListener)block{
    onReceiveRfmSuicaBalanceListenerBlock = block;
}
-(void)setOnReceiveRfmFelicaReadListenerBlock:(onReceiveRfmFelicaReadListener)block{
    onReceiveRfmFelicaReadListenerBlock = block;
}
-(void)setOnReceiveRfmUltralightCmdListenerBlock:(onReceiveRfmUltralightCmdListener)block{
    onReceiveRfmUltralightCmdListenerBlock = block;
}
-(void)setOnReceiveRfmFelicaCmdListenerBlock:(onReceiveRfmFelicaCmdListener)block {
    onReceiveRfmFelicaCmdListenerBlock = block;
}
-(void)setOnReceiveRfmMifareAuthListenerBlock:(onReceiveRfmMifareAuthListener)block {
    onReceiveRfmMifareAuthListenerBlock = block;
}
-(void)setOnReceiveRfmMifareDataExchangeListenerBlock:(onReceiveRfmMifareDataExchangeListener)block {
    onReceiveRfmMifareDataExchangeListenerBlock = block;
}
-(void)setOnReceivePalTestChannelListenerBlock:(onReceivePalTestChannelListener)block {
    onReceivePalTestChannelListenerBlock = block;
}
-(void)setOnReceiveOpenBeepCmdListenerBlock:(onReceiveOpenBeepCmdListener)block {
    onReceiveOpenBeepCmdListenerBlock = block;
}
-(void)setOnReceiveRfIso15693ReadSingleBlockListenerBlock:(onReceiveRfIso15693ReadSingleBlockListener)block {
    onReceiveRfIso15693ReadSingleBlockListenerBlock = block;
}
-(void)setOnRecevieRfIso15693ReadMultipleBlockListenerBlock:(onRecevieRfIso15693ReadMultipleBlockListener)block {
    onRecevieRfIso15693ReadMultipleBlockListenerBlock = block;
}
-(void)setOnReceiveRfIso15693WriteSingleBlockListenerBlock:(onReceiveRfIso15693WriteSingleBlockListener)block {
    onReceiveRfIso15693WriteSingleBlockListenerBlock = block;
}
-(void)setOnReceiveRfIso15693WriteMultipleBlockListenerBlock:(onReceiveRfIso15693WriteMultipleBlockListener)block {
    onReceiveRfIso15693WriteMultipleBlockListenerBlock = block;
}
-(void)setOonReceiveRfIso15693LockBlockListenerBlock:(onReceiveRfIso15693LockBlockListener)block {
    onReceiveRfIso15693WriteMultipleBlockListenerBlock = block;
}
-(void)setOonReceiveRfIso15693CmdListenerBlock:(onReceiveRfIso15693CmdListener)block {
    onReceiveRfIso15693CmdListenerBlock = block;
}
-(void)setOonReceiveAntiLostSwitchListenerBlock:(onReceiveAntiLostSwitchListener)block {
    onReceiveAntiLostSwitchListenerBlock = block;
}
-(void)setOonReceiveButtonEnterListenerBlock:(onReceiveButtonEnterListener)block {
    onReceiveButtonEnterListenerBlock = block;
}
-(void)setOnReceivePSamResetListener:(onReceivePSamResetListener)block{
    onReceivePSamResetListenerBlock = block;
}
-(void)setOnReceivePSamPowerDownListener:(onReceivePSamPowerDownListener)block {
    onReceivePSamPowerDownListenerBlock = block;
}
-(void)setOnReceivePSamApduListener:(onReceivePSamApduListener)block{
    onReceivePSamApduListenerBlock = block;
}
-(void)setOnReceiveChangeBleNameListener:(onReceiveChangeBleNameListener)block{
    onReceiveChangeBleNameListenerBlock = block;
}
-(void)setOnReceiveAutoSearchCardListener:(onReceiveAutoSearchCardListener)block{
    onReceiveAutoSearchCardListenerBlock = block;
}
-(void)setOnReceiveUlLongReadListener:(onReceiveUlLongReadListener)block{
    onReceiveUlLongReadListenerBlock = block;
}
-(void)setOnReceiveUlLongWriteListener:(onReceiveUlLongWriteListener)block{
    onReceiveUlLongWriteListenerBlock = block;
}

-(void)requestConnectBleDevice:(CBPeripheral *)peripheral
          connectCallbackBlock:(onReceiveConnectBtDeviceListener)block {
    onReceiveConnectBtDeviceListenerBlock = block;
    [[DKBleManager sharedInstance] connect:peripheral callbackBlock:^(BOOL isConnectSucceed) {
        block(isConnectSucceed);
        if (!isConnectSucceed) {
            self.autoSearchCardFlag = [NSNumber numberWithBool:NO];
        }
    }];
}
-(void)requestDisConnectDeviceWithCallbackBlock:(onReceiveDisConnectDeviceListener)block {
    onReceiveDisConnectDeviceListenerBlock = block;
    [[DKBleManager sharedInstance] cancelConnectWithCallbackBlock:^{
        block(YES);
        self.autoSearchCardFlag = [NSNumber numberWithBool:NO];
    }];
}
-(void)requestConnectionStatusWithCallbackBlock:(onReceiveConnectionStatusListener)block {
    onReceiveConnectionStatusListenerBlock = block;
    block([[DKBleManager sharedInstance] isConnect]);
}
-(void)requestDeviceBtValueWithCallbackBlock:(onReceiveDeviceBtValueListener)block{
    onReceiveDeviceBtValueListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager getBtValueComData];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestDeviceVersionWithCallbackBlock:(onReceiveDeviceVersionListener)block{
    onReceiveDeviceVersionListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager getVerisionsComData];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmSearchCard:(DKCardType)cardType callbackBlock:(onReceiveRfnSearchCardListener)block{
    onReceiveRfnSearchCardListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager cardActivityComData:cardType];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmSentApduCmd:(NSData *)apduData callbackBlock:(onReceiveRfmSentApduCmdListener)block{
    onReceiveRfmSentApduCmdListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager rfApduCmdData:apduData];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmSentBpduCmd:(NSData *)apduData callbackBlock:(onReceiveRfmSentBpduCmdListener)block{
    onReceiveRfmSentBpduCmdListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager rfBpduCmdData:apduData];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmCloseWhitCallbackBlock:(onReceiveRfmCloseListener)block{
    onReceiveRfmCloseListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager rfPowerOffComData];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmSuicaBalanceWhitCallbackBlock:(onReceiveRfmSuicaBalanceListener)block{
    onReceiveRfmSuicaBalanceListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager requestRfmSuicaBalance];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmFelicaRead:(NSData *)systemCode blockAddr:(NSData *)blockAddr callback:(onReceiveRfmFelicaReadListener)block{
    onReceiveRfmFelicaReadListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager requestRfmFelicaRead:systemCode blockAddr:blockAddr];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmUltralightCmd:(NSData *)ulCmdData callback:(onReceiveRfmUltralightCmdListener)block{
    onReceiveRfmUltralightCmdListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager ultralightCmdData:ulCmdData];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmUltralightLongRead:(Byte)startAddress number:(int)number callback:(onReceiveUlLongReadListener)block{
    onReceiveUlLongReadListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager ultralightLongReadCmdBytes:startAddress number:number];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmUltralightLongWrite:(Byte)startAddress writeData:(NSData *)data callback:(onReceiveUlLongWriteListener)block{
    onReceiveUlLongWriteListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager ultralightLongWriteCmdBytes:startAddress data:data];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmFelicaCmd:(NSInteger)wOption waitN:(NSInteger)wN cmdData:(NSData *)data callback:(onReceiveRfmFelicaCmdListener)block{
    onReceiveRfmFelicaCmdListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager felicaCmdData:wOption waitN:wN data:data];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmMifareAuth:(Byte)bBlockNo keyType:(Byte)bKeyType key:(NSData *)key uid:(NSData *)uid callback:(onReceiveRfmMifareAuthListener)block{
    onReceiveRfmMifareAuthListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager rfMifareAuthCmdData:bBlockNo keyType:bKeyType key:key uid:uid];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmMifareDataExchange:(NSData *)data callback:(onReceiveRfmMifareDataExchangeListener)block {
    onReceiveRfmMifareDataExchangeListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager rfMifareDataExchangeCmdData:data];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestPalTestChannel:(NSData *)data callback:(onReceivePalTestChannelListener)block{
    onReceivePalTestChannelListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager getTestChannelData:data];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmIso15693WriteSingleBlock:(NSData *)uid address:(Byte)addr writeData:(NSData *)writeData callback:(onReceiveRfIso15693WriteSingleBlockListener)block{
    onReceiveRfIso15693WriteSingleBlockListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager iso15693WriteSingleBlockCmdData:uid address:addr writeData:writeData];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmIso15693WriteMultipleBlock:(NSData *)uid address:(Byte)addr number:(Byte)number writeData:(NSData *)writeData callback:(onReceiveRfIso15693WriteMultipleBlockListener)block{
    onReceiveRfIso15693WriteMultipleBlockListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager iso15693WriteMultipleBlockCmdData:uid address:addr number:number writeData:writeData];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmIso15693LockBlock:(NSData *)uid address:(Byte)addr callback:(onReceiveRfIso15693LockBlockListener)block{
    onReceiveRfIso15693LockBlockListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager iso15693LockBlockCmdData:uid address:addr];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmIso15693ReadMultipleBlock:(NSData *)uid address:(Byte)addr  number:(Byte)number callback:(onRecevieRfIso15693ReadMultipleBlockListener)block{
    onRecevieRfIso15693ReadMultipleBlockListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager iso15693ReadMultipleBlockCmdData:uid address:addr number:number];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmIso15693ReadSingleBlock:(NSData *)uid address:(Byte)addr callback:(onReceiveRfIso15693ReadSingleBlockListener)block{
    onReceiveRfIso15693ReadSingleBlockListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager iso15693ReadSingleBlockCmdData:uid address:addr];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmIso15693CmdData:(NSData *)data callback:(onReceiveRfIso15693CmdListener)block{
    onReceiveRfIso15693CmdListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager iso15693CmdData:data];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestAntiLostSwitch:(BOOL)s callback:(onReceiveAntiLostSwitchListener)block{
    onReceiveAntiLostSwitchListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager antiLostSwitchCmdData:s];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestButtonEnterWhitCallbackBlock:(onReceiveButtonEnterListener)block{
    onReceiveButtonEnterListenerBlock = block;
}
-(void)requestOpenBeep:(int)openTimeMs callback:(onReceiveOpenBeepCmdListener)block{
    onReceiveOpenBeepCmdListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager openBeepCmdData:openTimeMs];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestOpenBeep:(int)onDelayMs offDelay:(int)offDelayMs number:(int)n callback:(onReceiveOpenBeepCmdListener)block{
    onReceiveOpenBeepCmdListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager openBeepCmdData:onDelayMs offDelay:offDelayMs number:n];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestPSamReset:(onReceivePSamResetListener)block{
    onReceivePSamResetListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager resetPSamCmdBytes];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestPSamPowerDown:(onReceivePSamPowerDownListener)block{
    onReceivePSamPowerDownListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager PSamPowerDownCmdBytes];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestChangeBleName:(NSString *)bleName callback:(onReceiveChangeBleNameListener)block{
    onReceiveChangeBleNameListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSString * urlStr = [bleName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *theData = [DKComByteManager changeBleNameCmdBytes:[NSData dataWithUrlString:urlStr]];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestRfmAutoSearchCard:(BOOL)en delay:(Byte)delayMs cardType:(Byte)bytCardType callback:(onReceiveAutoSearchCardListener)block{
    onReceiveAutoSearchCardListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager autoSearchCardCmdBytes:en delay:delayMs cardType:bytCardType];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}
-(void)requestPSamApdu:(NSData *)data callback:(onReceivePSamApduListener)block{
    onReceivePSamApduListenerBlock = block;
    CBCharacteristic * theCharacteristic = [DKBleManager sharedInstance].apduCharacteristic;
    NSData *theData = [DKComByteManager PSamApduCmdBytes:data];
    [[DKBleManager sharedInstance] wtireDataToCharacteristic:theCharacteristic writeData:theData];
}

#pragma mark - DKComByteManagerDelegate
-(void)comByteManagerCallback:(BOOL)isSuc rcvData:(NSData *)rcvData {
    Byte *rcvBytes = (Byte *)[rcvData bytes];
    switch ([self.comByteManager getCmd] - 1) {
        case GET_VERSIONS_COM:
            if ( [comByteManager getCmdRunStatus] && (onReceiveDeviceVersionListenerBlock != nil) ) {
                onReceiveDeviceVersionListenerBlock((NSInteger)(rcvBytes[0]));
            }
            break;
        case GET_BT_VALUE_COM:
            if ([comByteManager getCmdRunStatus] && (onReceiveDeviceBtValueListenerBlock != nil) ) {
                float btValue = (float)(((unsigned int)rcvBytes[0] << 8) | (unsigned int)rcvBytes[1]) / 100.0;
                onReceiveDeviceBtValueListenerBlock(btValue);
            }
            break;
        case ANTENNA_OFF_COM:
            if (onReceiveRfmCloseListenerBlock != nil) {
                onReceiveRfmCloseListenerBlock(YES);
            }
            break;
        case ACTIVATE_PICC_COM:
            if ( [comByteManager getCmdRunStatus] && (rcvData.length >= 1) ) {
                self.cpuCard = nil;
                self.ultralight = nil;
                self.ntag21x = nil;
                self.mifare = nil;
                self.iso14443bCard = nil;
                self.feliCa = nil;
                self.desFire = nil;
                self.iso15693Card = nil;
                mCardType = DKCardTypeDefault;
                DKCardType cardType = (DKCardType)rcvBytes[0];
                mCardType = cardType;
                NSData *uidData = [NSData dataWithHexString:@"00000000"];;
                NSData *atrData;
                if (cardType == DKIso14443A_CPUType) {
                    uidData = [rcvData subdataWithRange:NSMakeRange(1, 4)];
                    atrData = [rcvData subdataWithRange:NSMakeRange(5, rcvData.length - 5)];
                    self.cpuCard = [[CpuCard alloc] init:self uid:uidData atr:atrData];
                }
                else if (cardType == DKMifare_Type) {
                    uidData = [rcvData subdataWithRange:NSMakeRange(1, 4)];
                    atrData = [rcvData subdataWithRange:NSMakeRange(5, rcvData.length - 5)];
                    self.mifare = [[Mifare alloc] init:self uid:uidData atr:atrData];
                }
                else if (cardType == DKIso15693_Type) {
                    uidData = [rcvData subdataWithRange:NSMakeRange(1, 8)];
                    atrData = [NSData dataWithHexString:@"00"];
                    self.iso15693Card = [[Iso15693Card alloc] init:self uid:uidData atr:atrData];
                }
                else if (cardType == DKUltralight_type) {
                    uidData = [rcvData subdataWithRange:NSMakeRange(1, 7)];
                    atrData = [rcvData subdataWithRange:NSMakeRange(8, rcvData.length - 8)];
                    self.ultralight = [[Ultralight alloc] init:self uid:uidData atr:atrData];
                    self.ntag21x = [[Ntag21x alloc] init:self uid:uidData atr:atrData];
                }
                else if (cardType == DKDESFire_type) {
                    uidData = [rcvData subdataWithRange:NSMakeRange(1, 7)];
                    atrData = [rcvData subdataWithRange:NSMakeRange(8, rcvData.length - 8)];
                    self.desFire = [[DESFire alloc] init:self uid:uidData atr:atrData];
                }
                else if (cardType == DKIso14443B_CPUType) {
                    uidData = [NSData dataWithHexString:@"00000000"];
                    atrData = [rcvData subdataWithRange:NSMakeRange(1, rcvData.length - 1)];
                    self.iso14443bCard = [[Iso14443bCard alloc] init:self uid:uidData atr:atrData];
                }
                else if (cardType == DKFeliCa_Type) {
                    uidData = [NSData dataWithHexString:@"00000000"];
                    atrData = [rcvData subdataWithRange:NSMakeRange(1, rcvData.length - 1)];
                    self.feliCa = [[FeliCa alloc] init:self uid:uidData atr:atrData];
                }
                else {
                    uidData = [NSData dataWithHexString:@"00000000"];
                    atrData = [rcvData subdataWithRange:NSMakeRange(1, rcvData.length - 1)];
                }
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(receiveRfnSearchCard: cardType: uid: ats:)]) {
                    [self.delegate receiveRfnSearchCard:YES cardType:cardType uid:uidData ats:atrData];
                }
                
                if (onReceiveRfnSearchCardListenerBlock != nil) {
                    onReceiveRfnSearchCardListenerBlock(YES, cardType, uidData, atrData);
                }
            }
            else {
                if (onReceiveRfnSearchCardListenerBlock != nil) {
                    onReceiveRfnSearchCardListenerBlock(NO, 0, nil, nil);
                }
            }
            break;
        case APDU_COM:
            if (onReceiveRfmSentApduCmdListenerBlock != nil) {
                onReceiveRfmSentApduCmdListenerBlock([comByteManager getCmdRunStatus], rcvData);
            }
            break;
            
        case BPDU_COM:
            if (onReceiveRfmSentBpduCmdListenerBlock != nil) {
                onReceiveRfmSentBpduCmdListenerBlock([comByteManager getCmdRunStatus], rcvData);
            }
            break;
            
        case GET_SUICA_BALANCE_COM:
            if (onReceiveRfmSuicaBalanceListenerBlock != nil) {
                onReceiveRfmSuicaBalanceListenerBlock(isSuc, rcvData);
            }
            break;
            
        case FELICA_READ_COM:
            if (onReceiveRfmFelicaReadListenerBlock != nil) {
                onReceiveRfmFelicaReadListenerBlock(isSuc, rcvData);
            }
            break;
            
        case ULTRALIGHT_CMD:
            if (onReceiveRfmUltralightCmdListenerBlock != nil) {
                onReceiveRfmUltralightCmdListenerBlock([comByteManager getCmdRunStatus], rcvData);
            }
            break;
            
        case FELICA_COM:
            if (onReceiveRfmFelicaCmdListenerBlock != nil) {
                onReceiveRfmFelicaCmdListenerBlock([comByteManager getCmdRunStatus], rcvData);
            }
            break;
            
        case MIFARE_AUTH_COM:
            if (onReceiveRfmMifareAuthListenerBlock != nil) {
                onReceiveRfmMifareAuthListenerBlock([comByteManager getCmdRunStatus]);
            }
            break;
            
        case MIFARE_COM:
            if (onReceiveRfmMifareDataExchangeListenerBlock != nil) {
                onReceiveRfmMifareDataExchangeListenerBlock([comByteManager getCmdRunStatus], rcvData);
            }
            break;
            
        case PAL_TEST_CHANNEL:
            if (onReceivePalTestChannelListenerBlock != nil) {
                onReceivePalTestChannelListenerBlock(rcvData);
            }
            break;
            
        case ISO15693_READ_SINGLE_BLOCK_COM:
            if (onReceiveRfIso15693ReadSingleBlockListenerBlock != nil) {
                if (rcvData != nil && rcvData.length >= 1) {
                    NSRange range = NSMakeRange(1, rcvData.length - 1);
                    rcvData = [rcvData subdataWithRange:range];
                }
                onReceiveRfIso15693ReadSingleBlockListenerBlock([comByteManager getCmdRunStatus], rcvData);
            }
            break;
            
        case ISO15693_READ_MULTIPLE_BLOCK_COM:
            if (onRecevieRfIso15693ReadMultipleBlockListenerBlock != nil) {
                if (rcvData != nil && rcvData.length >= 1) {
                    NSRange range = NSMakeRange(1, rcvData.length - 1);
                    rcvData = [rcvData subdataWithRange:range];
                }
                onRecevieRfIso15693ReadMultipleBlockListenerBlock([comByteManager getCmdRunStatus], rcvData);
            }
            break;
            
        case ISO15693_WRITE_SINGLE_BLOCK_COM:
            if (onReceiveRfIso15693WriteSingleBlockListenerBlock != Nil) {
                onReceiveRfIso15693WriteSingleBlockListenerBlock([comByteManager getCmdRunStatus]);
            }
            break;
            
        case ISO15693_WRITE_MULTIPLE_BLOCK_COM:
            if (onReceiveRfIso15693WriteMultipleBlockListenerBlock != nil) {
                onReceiveRfIso15693WriteMultipleBlockListenerBlock([comByteManager getCmdRunStatus]);
            }
            break;
            
        case ISO15693_CMD:
            if (onReceiveRfIso15693CmdListenerBlock != nil) {
                onReceiveRfIso15693CmdListenerBlock([comByteManager getCmdRunStatus], rcvData);
            }
            
        case ANTI_LOST_SWITCH_COM:
            if (onReceiveAntiLostSwitchListenerBlock != nil) {
                onReceiveAntiLostSwitchListenerBlock([comByteManager getCmdRunStatus]);
            }
            break;
            
        case BUTTON_INPUT_COM:
            if (onReceiveButtonEnterListenerBlock != nil) {
                onReceiveButtonEnterListenerBlock(rcvBytes[0]);
            }
            break;
            
        case BEEP_OPEN_COM:
            if (onReceiveOpenBeepCmdListenerBlock != nil) {
                onReceiveOpenBeepCmdListenerBlock([comByteManager getCmdRunStatus]);
            }
            break;
            
        case ULTRALIGHT_LONG_READ:
            if (onReceiveUlLongReadListenerBlock != nil) {
                onReceiveUlLongReadListenerBlock([comByteManager getCmdRunStatus], rcvData);
            }
            break;
            
        case ULTRALIGHT_LONG_WRITE:
            if (onReceiveUlLongWriteListenerBlock != nil) {
                onReceiveUlLongWriteListenerBlock([comByteManager getCmdRunStatus]);
            }
            break;
            
        case ISO7816_RESET_CMD:
            if (onReceivePSamResetListenerBlock != nil) {
                onReceivePSamResetListenerBlock([comByteManager getCmdRunStatus], rcvData);
            }
            break;
            
        case ISO7816_POWE_OFF_CMD:
            if (onReceivePSamPowerDownListenerBlock != nil) {
                onReceivePSamPowerDownListenerBlock([comByteManager getCmdRunStatus]);
            }
            break;
            
        case ISO7816_CMD:
            if (onReceivePSamApduListenerBlock != nil) {
                onReceivePSamApduListenerBlock([comByteManager getCmdRunStatus], rcvData);
            }
            break;
        
        case CHANGE_BLE_NAME_COM:
            if (onReceiveChangeBleNameListenerBlock != nil) {
                onReceiveChangeBleNameListenerBlock([comByteManager getCmdRunStatus]);
            }
            break;
            
        case AUTO_SEARCH_CARD_COM:
            self.autoSearchCardFlag = [NSNumber numberWithBool:[comByteManager getCmdRunStatus]];
            if (onReceiveAutoSearchCardListenerBlock != nil) {
                onReceiveAutoSearchCardListenerBlock([comByteManager getCmdRunStatus]);
            }
            break;
        
        default:
            break;
    }
}
@end




