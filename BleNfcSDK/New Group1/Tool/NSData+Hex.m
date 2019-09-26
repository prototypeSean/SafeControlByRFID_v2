//
//  NSData+Hex.m
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import "NSData+Hex.h"

@implementation NSData(Hex)
- (NSString *)hexadecimalString {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

+ (NSData *)dataWithHexString:(NSString *)hexstring{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hexstring.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexstring substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

+(NSData *)dataWithUrlString:(NSString *)urlString {
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int i=0; i<urlString.length; ) {
        if ([urlString characterAtIndex:i] == '%') {
            if ((i + 2) < urlString.length) {
                NSRange range = NSMakeRange(i+1, 2);
                [string appendString:[urlString substringWithRange:range]];
            }
            i += 3;
        } else {
            [string appendString:[NSString stringWithFormat:@"%02x", [urlString characterAtIndex:i] & 0xff]];
            i++;
        }
    }
    
    return [NSData dataWithHexString:string];
}
@end





