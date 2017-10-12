/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"
#import "CodePush.h"

#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"
#import "UMMobClick/MobClick.h"
#import <UMSocialCore/UMSocialCore.h>
#import "TCOpenOtherAppHelper.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "JPUSHService.h"
//#import "ViewController.h"
#import "JXNetWorkHelper.h"
#import "JXNetworkReachability.h"

#import "noCilentOneViewController.h"
#import "AFURLSessionManager.h"
//#import "JXNavigationController.h"
#import <React/RCTEventEmitter.h>

#import "ForestViewController.h"
#import "BaseNavigationController.h"

//极光 933_app
static NSString *jpushAppKey = @"b865845cc2f991e852553364";

static NSString *umengAppKey = @"59cb226da40fa32a6100004f";


static NSString *channel = @"933";
static BOOL isProduction = TRUE;

@interface AppDelegate ()<JPUSHRegisterDelegate>
@property(nonatomic,strong) RCTRootView *rootView;
@property(nonatomic,assign) BOOL isLoadForJS;
@property(nonatomic,assign) BOOL checkUpdateEnd;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;

  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  
  
#ifdef DEBUG
//  jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"index.ios" withExtension:@"jsbundle"];
    jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];
#else
    jsCodeLocation = [CodePush bundleURL];
#endif

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"TC168"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  self.rootView = rootView;
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];


  
#ifdef DEBUG

#else
  //设置友盟appkey
  UMConfigInstance.appKey = umengAppKey;
  UMConfigInstance.channelId = @"App Store";
  NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  [MobClick setAppVersion:version];
  [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
#endif

  if ([self getLoadforJSModel]) {
    [self loadController2:self.rootView];
  }else{
    [self loadController];
  }
  
  [self JPushWithOptions:launchOptions];
  
  
//  [JXNetWorkHelper getWithUrlString:@"https://www.cp03866788.com/api/v1/ip/user/checkIpInfoDomains?clientId=87" parameters:nil success:^(NSDictionary *data) {
//    if (data&&[[data objectForKey:@"allowAppUpdate"] boolValue]) {
////      [self loadController2:self.rootView];
//    }
//  } failure:^(NSError *error) {
//    
//  }];
  
  if (@available(iOS 11, *)) {
    [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
  }
  NSString *version1 = [UIDevice currentDevice].systemVersion;
//  if (version1.floatValue >= 10) {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![[userDefaults objectForKey:@"ios10AppFirstOpenFinished"] boolValue]) {
      
      [[JXNetworkReachability shareNetworkReachability] startNotifier:^(BOOL isExistenceNetwork) {
        if (isExistenceNetwork) {
          [userDefaults setObject:@"1" forKey:@"ios10AppFirstOpenFinished"];
          [userDefaults synchronize];
          
          NSLog(@"------有网络了 请关闭网络异常提示");
        }else{
          NSLog(@"-----没有网络了 请显示网络异常提示");
          [self popAlertViewController];
        }
      }];
//    }
}

  

  return YES;
}


//弹框
-(void)popAlertViewController{
//  //初始化弹窗口控制器
//
//  //  UIWindow  *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//  //
//  //  alertWindow.rootViewController = [[UIViewController alloc] init];
//  //
//  self.window.windowLevel = UIWindowLevelAlert + 1;
//
//  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"网络异常,请点击设置" preferredStyle:UIAlertControllerStyleAlert];
//
//  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
////    [alertController   dismissViewControllerAnimated:YES completion:nil];
//    NoCilentViewController *noCilent = [[NoCilentViewController alloc]init];
//
//    [self.window.rootViewController presentViewController:noCilent animated:YES completion:nil];
////    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
//  }];
//
//  [alertController addAction:cancelAction];
//
//  //显示弹出框
//
//  [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
  
  noCilentOneViewController *noCilent = [[noCilentOneViewController alloc]init];
  
  [self.window.rootViewController presentViewController:noCilent animated:YES completion:nil];
  
  
}

- (void)loadController {
//  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.checkUpdateEnd &&!self.isLoadForJS) {
      return;
    }
    self.isLoadForJS = NO;
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
  
  ForestViewController *forest = [[ForestViewController alloc] init];
  BaseNavigationController *base = [[BaseNavigationController alloc] initWithRootViewController:forest];
  
  self.window.rootViewController = base;
  
    [self.window makeKeyAndVisible];
    
//  });
}

- (void)loadController2:(UIView *)rootView {
  if (self.isLoadForJS) {
    return;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    self.isLoadForJS = YES;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *rootViewController = [UIViewController new];
    rootViewController.view = rootView;
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
  });
  
}

- (BOOL)getLoadforJSModel{
  NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
  BOOL appForJS = [[defaults objectForKey:@"appForJS"] boolValue];
  if (appForJS) {
    return YES;
  }
  return NO;
}

- (void)setLoadForJSModel:(BOOL)loadForJS
{
  self.checkUpdateEnd = YES;
  NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
  if (loadForJS) {
    [self loadController2:self.rootView];
    [defaults setObject:@"1" forKey:@"appForJS"];
  }else {
    [self loadController];
    [defaults setObject:@"0" forKey:@"appForJS"];
  }
  [defaults synchronize];
}

- (void)setUMConfig
{
  
}



#pragma mark- JPUSH
- (void)JPushWithOptions:(NSDictionary *)launchOptions
{
  [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
  
  if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
#endif
  } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
    //可以添加自定义categories
    [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                      UIUserNotificationTypeSound |UIUserNotificationTypeAlert)categories:nil];
  } else {
    //categories 必须为nil
    [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert) categories:nil];
  }
  
  //如不需要使用IDFA，advertisingIdentifier 可为nil
  [JPUSHService setupWithOption:launchOptions appKey:jpushAppKey
                        channel:channel
               apsForProduction:isProduction
          advertisingIdentifier:nil];
  
  //2.1.9版本新增获取registration id block接口。
  [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
    if(resCode == 0){
      NSLog(@"registrationID获取成功：%@",registrationID);
    } else {
      NSLog(@"registrationID获取失败，code：%d",resCode);
    }
  }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  /// Required - 注册 DeviceToken
  [JPUSHService registerDeviceToken:deviceToken];
}

#pragma mark- JPUSHRegisterDelegate
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
  // Required
  NSDictionary * userInfo = notification.request.content.userInfo;
  if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [JPUSHService handleRemoteNotification:userInfo];
  }
  completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
  // Required
  NSDictionary * userInfo = response.notification.request.content.userInfo;
  if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [JPUSHService handleRemoteNotification:userInfo];
  }
  completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  
  // Required, iOS 7 Support
  [JPUSHService handleRemoteNotification:userInfo];
  completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  
  // Required,For systems with less than or equal to iOS6
  [JPUSHService handleRemoteNotification:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
  
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  
}


- (void)applicationWillTerminate:(UIApplication *)application {
  
}


@end
