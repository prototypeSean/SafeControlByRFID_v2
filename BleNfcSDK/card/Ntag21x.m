//
//  Ntag21x.m
//  ble_nfc_sdk
//
//  Created by lochy on 16/10/23.
//  Copyright © 2016年 Lochy. All rights reserved.
//

#import "Ntag21x.h"
#import "DKCardNoResponseException.h"

//任意长度读回调
onReceiveNtag21xLongReadListener mOnReceiveNtag21xLongReadListenerBlock = nil;
//任意长度写回调
onReceiveNtag21xLongWriteListener mOnReceiveNtag21xLongWriteListenerBlock = nil;
//写一个NDEF文本格式到标签回调
onReceiveNdefTextWriteListener mOnReceiveNdefTextWriteListenerBlock = nil;
//从标签中读取一个NEDF文本格式的数据回调
onReceiveNdefTextReadListener mOnReceiveNdefTextReadListenerBlock = nil;

@implementation Ntag21x
/*
 * 方 法 名： ntag21xLongRead
 * 功    能：ntag21x任意长度读
 * 参    数：startAddress - 读起始地址
 *          endAddress   - 读块结束地址
 *          block        - 读块结果回调函数
 * 返 回 值：无
 */
-(void)ntag21xLongRead:(Byte)startAddress endAddress:(Byte)endAddress callbackBlock:(onReceiveNtag21xLongReadListener)block{
    mOnReceiveNtag21xLongReadListenerBlock = block;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSData *returnData = [self ntag21xLongRead:startAddress endAddress:endAddress];
            if (mOnReceiveNtag21xLongReadListenerBlock != nil) {
                mOnReceiveNtag21xLongReadListenerBlock(YES, returnData);
            }
        } @catch (DKCardNoResponseException *exception) {
            if (mOnReceiveNtag21xLongReadListenerBlock != nil) {
                mOnReceiveNtag21xLongReadListenerBlock(NO, nil);
            }
        } @finally {
        }
    });
}

/**
 * 任意长度读，同步阻塞方式，注意：不能在主线程里运行
 * @param startAddress 要读取的起始地址
 * @param endAddress 要读取的结束地址
 * @return         读取到的数据
 * @throws CardNoResponseException
 *                  卡片无响应时会抛出异常
 */
-(NSData *)ntag21xLongRead:(Byte)startAddress endAddress:(Byte)endAddress {
    if ( (startAddress & 0x00ff) > (endAddress & 0x00ff) ) {
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: @"Start Address must be smaller than end Address"
                userInfo: nil];
    }
    
    NSMutableData *readData = [[NSMutableData alloc] init];
    int readDataLen = 0;
    
    int currentStartAddress = startAddress & 0x00ff;
    int currentEndAddress = currentStartAddress + LONG_READ_MAX_NUMBER - 1;
    NSData *returnData;
    
    if ( ((endAddress & 0x00ff) - (startAddress & 0x00ff) + 1) >=  LONG_READ_MAX_NUMBER) {
        while ((currentEndAddress & 0x00ff) <= (endAddress & 0x00ff)) {
            returnData = [self ultralightLongReadSingle:startAddress number:LONG_READ_MAX_NUMBER];
            [readData appendData:returnData];
            readDataLen += LONG_READ_MAX_NUMBER * 4;
            currentStartAddress = (currentEndAddress & 0x00ff) + 1;
            currentEndAddress += LONG_READ_MAX_NUMBER;
        }
    }
    
    int surplusBlock = ((endAddress & 0x00ff) - (startAddress & 0x00ff) + 1) % LONG_READ_MAX_NUMBER;
    if ( surplusBlock != 0 ) {
        returnData = [self ultralightLongReadSingle:(Byte)(currentStartAddress & 0x00ff) number:surplusBlock];
        [readData appendData:returnData];
    }
    return readData;
}

/*
 * 方 法 名： ntag21xLongWrite
 * 功    能：ntag21x任意长度写
 * 参    数：startAddress - 写起始地址
 *          writeData    - 要写的数据
 *          block        - 写块结果回调函数
 * 返 回 值：无
 */
-(void)ntag21xLongWrite:(Byte)startAddress writeData:(NSData*)writeData callbackBlock:(onReceiveNtag21xLongWriteListener)block{
    mOnReceiveNtag21xLongWriteListenerBlock = block;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            BOOL isSuc = [self ultralightLongWriteSingle:startAddress data:writeData];
            if (isSuc) {
                if (mOnReceiveNtag21xLongWriteListenerBlock != nil) {
                    mOnReceiveNtag21xLongWriteListenerBlock(YES, nil);
                }
            }
            else {
                if (mOnReceiveNtag21xLongWriteListenerBlock != nil) {
                    mOnReceiveNtag21xLongWriteListenerBlock(NO, ERR_WRITE_FAIL);
                }
            }
        } @catch (NSException *exception) {
            if (mOnReceiveNtag21xLongWriteListenerBlock != nil) {
                mOnReceiveNtag21xLongWriteListenerBlock(NO, [exception reason]);
            }
        } @finally {
        }
    });
}

/**
 * 任意长度写，同步阻塞方式，注意：不能在主线程里运行
 * @param startAddress 要写入的起始地址
 * @param writeBytes 要写入的数据
 * @return         true：写入成功，  false：写入失败
 * @throws CardNoResponseException
 *                  卡片无响应时会抛出异常
 */
-(BOOL)ntag21xLongWrite:(Byte)startAddress writeData:(NSData*)writeData {
    Byte startAddressTemp;
    startAddressTemp = startAddress;
    
    //标签容量
    int size = SIZE_DEFAULT;
    Byte* returnBytes;
    NSData *returnData = [self ultralightRead:0];
    if ((returnData != nil) && (returnData.length == 16)) {
        returnBytes = (Byte *)[returnData bytes];
        switch (returnBytes[14]) {
            case 0x12:
            size = SIZE_NTAG213;
            break;
            case 0x3e:
            size = SIZE_NTAG215;
            break;
            case 0x6d:
            case 0x6f:
            size = SIZE_NTAG216;
            break;
            default:
            size = SIZE_DEFAULT;
            break;
        }
    }
    
    //写入数据长度超过卡片容量
    if (writeData.length + (startAddressTemp & 0x00ff) * 4 > (size + 16)) {
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: ERR_MEMORY_OUT
                userInfo: nil];
    }
    
    int currentWriteAddress = startAddress & 0x00ff;
    NSData* writeDataTemp;
    int i = 0;
    for (i = 0; (i+LONG_READ_MAX_NUMBER) <= (writeData.length / 4); i += LONG_READ_MAX_NUMBER) {
        NSRange range = NSMakeRange(i * 4, LONG_READ_MAX_NUMBER * 4);
        writeDataTemp = [writeData subdataWithRange:range];
        BOOL isSuc = [self ultralightLongWriteSingle:(Byte) (currentWriteAddress & 0x00ff) data:writeDataTemp];
        if (!isSuc) {
            return NO;
        }
        currentWriteAddress += LONG_READ_MAX_NUMBER;
    }
    
    if (writeData.length % (LONG_READ_MAX_NUMBER * 4) > 0) {
        NSRange range = NSMakeRange(i * 4, writeData.length % (LONG_READ_MAX_NUMBER * 4));
        writeDataTemp = [writeData subdataWithRange:range];
        BOOL isSuc = [self ultralightLongWriteSingle:(Byte) (currentWriteAddress & 0x00ff) data:writeDataTemp];
        if (!isSuc) {
            return NO;
        }
    }
    return YES;
}

/*
 * 方 法 名： NdefTextWrite
 * 功    能：ntag21x写一个NDEF格式的文本
 * 参    数：text         - 要写的文本
 *          block        - 结果回调函数
 * 返 回 值：无
 */
-(void)NdefTextWrite:(NSString *)text callbackBlock:(onReceiveNdefTextWriteListener)block{
    mOnReceiveNdefTextWriteListenerBlock = block;
    
    NSData *writeData = [text dataUsingEncoding:NSUTF8StringEncoding];
    Byte NDEFTextByte[] = {0x03,(Byte)0xE8,(Byte)0xD1, 0x01, 0x12, 0x54, 0x02, 0x7a, 0x68};
    NDEFTextByte[1] = (Byte)(writeData.length + 7);
    NDEFTextByte[4] = (Byte)(writeData.length + 3);
    NSMutableData *NDEFData = [[NSMutableData alloc] initWithBytes:NDEFTextByte length:9];
    [NDEFData appendData:writeData];
    NDEFTextByte[0] = (Byte)0xFE;
    [NDEFData appendBytes:NDEFTextByte length:1];
    
    [self ntag21xLongWrite:4 writeData:NDEFData callbackBlock:^(BOOL isSuc, NSString *error) {
        if (mOnReceiveNdefTextWriteListenerBlock != nil) {
            mOnReceiveNdefTextWriteListenerBlock(isSuc, error);
        }
    }];
}

/*
 * 方 法 名： NdefTextWrite，同步阻塞方式，注意：不能在主线程里运行
 * 功    能：ntag21x写一个NDEF格式的文本
 * 参    数：text         - 要写的文本
 * 返 回 值：YES->写成功 NO->写失败
 * @throws CardNoResponseException
 *                  卡片无响应时会抛出异常
 */
-(BOOL)NdefTextWrite:(NSString *)text {
    //创建信号量
    __block BOOL status = NO;
    __block NSString *returnDataTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self NdefTextWrite:text callbackBlock:^(BOOL isSuc, NSString* error) {
        status = isSuc;
        returnDataTemp = error;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,5*CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: @"卡片无响应"
                userInfo: nil];
    }
    else if (!status) {
        return NO;
    }
    else {
        return YES;
    }
}

/*
 * 方 法 名： NdefTextRead
 * 功    能：Ndef读取一个NDEF格式的数据
 * 参    数：block        - 结果回调函数
 * 返 回 值：无
 */
-(void)NdefTextReadWithCallbackBlock:(onReceiveNdefTextReadListener)block{
    mOnReceiveNdefTextReadListenerBlock = block;
    [self ultralightRead:4 callbackBlock:^(BOOL isSuc, NSData *returnData) {
        Byte *returnBytes = (Byte *)[returnData bytes];
        if (!isSuc || returnData.length != 16) {
            if (mOnReceiveNdefTextReadListenerBlock != nil) {
                mOnReceiveNdefTextReadListenerBlock(NO, @"Read card fail", nil);
            }
            return;
        }
        if (returnBytes[0] == 0x03) {
            if (returnBytes[1] == (Byte) 0xff) {
                int recordLen = ((returnBytes[2] & 0x00ff) << 8) | (returnBytes[3] & 0x00ff);
                Byte recordEndAddress = (Byte) ((recordLen + 4) / 4 + 4);
                [self ntag21xLongRead:4 endAddress:recordEndAddress callbackBlock:^(BOOL isSuc, NSData *returnData) {
                    Byte *returnBytes = (Byte *)[returnData bytes];
                    if (!isSuc || (returnData.length < recordLen) || (returnData.length - 11 < recordLen - 7)) {
                        if (mOnReceiveNdefTextReadListenerBlock != nil) {
                            mOnReceiveNdefTextReadListenerBlock(NO, @"Read card fail", nil);
                        }
                        return;
                    }
                    
                    Byte payload[recordLen - 7];
                    memcpy(payload, &returnBytes[11], recordLen - 7);
                    //处理bit5-0。bit5-0表示语言编码长度（字节数）
                    int languageCodeLength = payload[0] & 0x3f;
                    NSString* text = [[NSString alloc] initWithBytes:&payload[languageCodeLength + 1] length:recordLen - 7 - languageCodeLength - 1 encoding:NSUTF8StringEncoding];
                    if (mOnReceiveNdefTextReadListenerBlock != nil) {
                        mOnReceiveNdefTextReadListenerBlock(YES, nil, text);
                    }
                }];
            } else {
                int recordLen = returnBytes[1] & 0x00ff;
                Byte recordEndAddress = (Byte) ((recordLen + 2) / 4 + 4);
                
                [self ntag21xLongRead:4 endAddress:recordEndAddress callbackBlock:^(BOOL isSuc, NSData *returnData) {
                    Byte *returnBytes = (Byte *)[returnData bytes];
                    if (!isSuc || (returnData.length < recordLen) || (returnData.length - 6 < recordLen - 4)) {
                        if (mOnReceiveNdefTextReadListenerBlock != nil) {
                            mOnReceiveNdefTextReadListenerBlock(NO, @"Read card fail", nil);
                        }
                        return;
                    }
                    
                    Byte payload[recordLen - 4];
                    memcpy(payload, &returnBytes[6], recordLen - 4);
                    //处理bit5-0。bit5-0表示语言编码长度（字节数）
                    int languageCodeLength = payload[0] & 0x3f;
                    NSString* text = [[NSString alloc] initWithBytes:&payload[languageCodeLength + 1] length:recordLen - 4 - languageCodeLength - 1 encoding:NSUTF8StringEncoding];
                    if (mOnReceiveNdefTextReadListenerBlock != nil) {
                        mOnReceiveNdefTextReadListenerBlock(YES, nil, text);
                    }
                }];
            }
        }
        else {
            if (mOnReceiveNdefTextReadListenerBlock != nil) {
                mOnReceiveNdefTextReadListenerBlock(NO, @"No NDEF text payload!", nil);
            }
        }
    }];
}

/*
 * 方 法 名： NdefTextRead，同步阻塞方式，注意：不能在主线程里运行
 * 功    能：Ndef读取一个NDEF格式的数据
 * 参    数：block        - 结果回调函数
 * @throws CardNoResponseException
 *                  卡片无响应时会抛出异常
 * 返 回 值：读取到的文本
 */
-(NSString *)NdefTextRead {
    //创建信号量
    __block BOOL status = NO;
    __block NSString *returnDataTemp = nil;
    __block NSString *errorTemp = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self NdefTextReadWithCallbackBlock:^(BOOL isSuc, NSString* error, NSString* returnString) {
        status = isSuc;
        returnDataTemp = returnString;
        errorTemp = error;
        dispatch_semaphore_signal(sema);   //释放信号量
    }];
    if ( dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW,5*CAR_NO_RESPONSE_TIME_MS*NSEC_PER_MSEC)) != 0 ) {  //等待信号量
        //等待信号量超时
        @throw [DKCardNoResponseException
                exceptionWithName: @"DKCardNoResponseException"
                reason: @"卡片无响应"
                userInfo: nil];
    }
    else if (!status) {
        return nil;
    }
    else {
        return returnDataTemp;
    }
}
@end












