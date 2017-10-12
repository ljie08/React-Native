//
//  JXNetworkReachability.h
//  TC168
//
//  Created by Sam on 19/07/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^JXSuccessReachabilityBlock)(BOOL isExistenceNetwork);

@interface JXNetworkReachability : NSObject

+ (instancetype)shareNetworkReachability;

- (void)startNotifier:(JXSuccessReachabilityBlock)callBackBlock;


@end
