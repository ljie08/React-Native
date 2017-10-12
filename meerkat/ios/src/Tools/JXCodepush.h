//
//  JXCodepush.h
//  TC168
//
//  Created by Sam on 25/03/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"

@interface JXCodepush : NSObject<RCTBridgeModule>

+ (void)resetServerUrl:(NSString *)url;
+ (void)resetDeploymentKey:(NSString *)deploymentKey;

//default NO
+ (void)resetLoadModleForJS:(BOOL)forJS;


@end
