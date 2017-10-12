//
//  TCOpenOtherAppHelper.m
//  TC168
//
//  Created by Sam on 2017/1/10.
//  Copyright © 2017年 Facebook. All rights reserved.
//
//支付宝跳过开启动画打开扫码和付款码的 url scheme 分别是
//
//alipayqr://platformapi/startapp?saId=10000007
//alipayqr://platformapi/startapp?saId=20000056
//微信扫一扫的 url scheme 是
//
//weixin://dl/scan

#import "TCOpenOtherAppHelper.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@implementation TCOpenOtherAppHelper
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(openAlipay)
{
  [TCOpenOtherAppHelper openAlipay];
}

RCT_EXPORT_METHOD(openWeiXin)
{
  [TCOpenOtherAppHelper openWeiXin];
}

RCT_EXPORT_METHOD(screenShotSave)
{
  TCOpenOtherAppHelper *helper = [[TCOpenOtherAppHelper alloc] init];
  [helper sscreenShotSave];
}

+ (void)openAlipay{
  NSURL *url  = [NSURL URLWithString:@"alipayqr://"];
  [[UIApplication sharedApplication] openURL:url];
}

+ (void)openWeiXin{
  NSURL *url  = [NSURL URLWithString:@"weixin://"];
  [[UIApplication sharedApplication] openURL:url];
}

- (void)sscreenShotSave{
  AppDelegate *delagete = (AppDelegate *)[UIApplication sharedApplication].delegate;
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(delagete.window.bounds.size.width, delagete.window.bounds.size.height), YES, 2);
  [[delagete.window layer] renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *imag = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  CGImageRef ima =imag.CGImage;
  UIImage *sendImag = [UIImage imageWithCGImage:ima];
  UIImageWriteToSavedPhotosAlbum(sendImag, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark 用来监听图片保存到相册的状况
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
  if (error) {
  }else{
  }
  NSLog(@"%@",contextInfo);
}

@end
