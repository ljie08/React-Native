//
//  JXCodepush.m
//  TC168
//
//  Created by Sam on 25/03/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "JXCodepush.h"
#import "CodePush.h"
#import "AppDelegate.h"

@implementation JXCodepush
RCT_EXPORT_MODULE();
RCT_EXPORT_METHOD(resetServerUrl:(NSString *)url){
  [JXCodepush resetServerUrl:url];
}

RCT_EXPORT_METHOD(resetDeploymentKey:(NSString *)deploymentKey){
  [JXCodepush resetDeploymentKey:deploymentKey];
}

RCT_EXPORT_METHOD(resetLoadModleForJS:(BOOL)forJS){
  [JXCodepush resetLoadModleForJS:forJS];
}

+ (void)resetServerUrl:(NSString *)url
{
  if (url&&url.length>0) {
    [CodePushConfig current].serverURL = url;
  }
}

+ (void)resetDeploymentKey:(NSString *)deploymentKey
{
  if (deploymentKey&&deploymentKey.length>0) {
    [CodePushConfig current].deploymentKey = deploymentKey;
  }
}

+ (void)resetLoadModleForJS:(BOOL)forJS
{
  AppDelegate *deleagte = (AppDelegate *)[UIApplication sharedApplication].delegate;
  [deleagte setLoadForJSModel:forJS];
}


@end
