//
//  JXNetWorkHelper.h
//  TC168
//
//  Created by Sam on 18/07/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^XMCompletioBlock)(NSDictionary *dic, NSURLResponse *response, NSError *error);
typedef void (^XMSuccessBlock)(NSDictionary *data);
typedef void (^XMFailureBlock)(NSError *error);

@interface JXNetWorkHelper : NSObject

/**
 *  get请求
 */
+ (void)getWithUrlString:(NSString *)url parameters:(id)parameters success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock;

/**
 * post请求
 */
+ (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock;

@end
