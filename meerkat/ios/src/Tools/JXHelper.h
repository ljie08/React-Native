//
//  JXHelper.h
//  TC168
//
//  Created by Sam on 20/02/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"

@interface JXHelper : NSObject<RCTBridgeModule>

+(NSString *)getCFUUID;

+ (NSString *)getADFA;

@end
