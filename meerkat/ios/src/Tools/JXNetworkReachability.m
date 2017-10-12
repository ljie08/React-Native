//
//  JXNetworkReachability.m
//  TC168
//
//  Created by Sam on 19/07/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "Reachability.h"
#import "JXNetworkReachability.h"

@interface JXNetworkReachability()
@property (nonatomic,strong)Reachability *conn;
@property (nonatomic,copy) JXSuccessReachabilityBlock block;
@end


@implementation JXNetworkReachability

static JXNetworkReachability *_instance;

+(instancetype)shareNetworkReachability
{
  return [[self alloc]init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if (_instance == nil) {
      _instance = [super allocWithZone:zone];
    }
  });
  return _instance;
}

-(id)copyWithZone:(NSZone *)zone
{
  return _instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone
{
  return _instance;
}

- (void)startNotifier:(JXSuccessReachabilityBlock)callBackBlock
{
  // 监听网络状态改变的通知
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
  self.conn = [Reachability reachabilityForInternetConnection];
  self.block = callBackBlock;
  [self networkStateChange];
  [self.conn startNotifier];
}

- (void)networkStateChange
{
  BOOL isExistenceNetwork;
  Reachability *reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
  
  switch([reachability currentReachabilityStatus]){
    case NotReachable: isExistenceNetwork = FALSE;
      break;
    case ReachableViaWWAN: isExistenceNetwork = TRUE;
      break;
    case ReachableViaWiFi: isExistenceNetwork = TRUE;
      break;
  }
  if (self.block) {
    self.block(isExistenceNetwork);
  }
}

@end
