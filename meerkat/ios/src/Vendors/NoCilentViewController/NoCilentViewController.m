//
//  NoCilentViewController.m
//  TC168
//
//  Created by HongShun Chen on 2017/7/20.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "NoCilentViewController.h"

@interface NoCilentViewController ()

@end

@implementation NoCilentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  UIButton *backBtn =[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 25, 25)];
//  backBtn.backgroundColor =[UIColor redColor];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"come_back.png"] forState:UIControlStateNormal];    //设置button背景显示图片
  [backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
  
  UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
  image.image =[UIImage imageNamed:@"yindao.png"];
  [self.view addSubview:image];
  
  
  [image addSubview:backBtn];
  image.userInteractionEnabled = YES;
  [self.view addSubview:image];
    // Do any additional setup after loading the view.
}

-(void)backBtnAction{
  [self dismissViewControllerAnimated:YES completion:nil];
//  [self.navigationController popViewControllerAnimated:YES];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
