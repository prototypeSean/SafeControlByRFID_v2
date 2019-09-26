//
//  Objc.m
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/9/14.
//  Copyright © 2019 DennisKao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjC.h"

@implementation ObjC

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:exception.userInfo];
        return NO;
    }
}

@end
