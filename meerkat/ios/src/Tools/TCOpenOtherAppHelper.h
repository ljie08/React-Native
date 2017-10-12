//
//  TCOpenOtherAppHelper.h
//  TC168
//
//  Created by Sam on 2017/1/10.
//  Copyright © 2017年 Facebook. All rights reserved.
//
#import "RCTBridgeModule.h"
#import <Foundation/Foundation.h>

@interface TCOpenOtherAppHelper : NSObject<RCTBridgeModule>

+ (void)openAlipay;
+ (void)openWeiXin;

@end
