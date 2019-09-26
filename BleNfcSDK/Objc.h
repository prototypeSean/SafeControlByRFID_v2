//
//  Objc.h
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/9/14.
//  Copyright © 2019 DennisKao. All rights reserved.
//

#ifndef Objc_h
#define Objc_h


#endif /* Objc_h */
#import <Foundation/Foundation.h>

@interface ObjC : NSObject

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end
