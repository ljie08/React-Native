//
//  noCilentOneViewController.m
//  TC168
//
//  Created by HongShun Chen on 2017/7/20.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "noCilentOneViewController.h"

#import "NoCilentViewController.h"
@interface noCilentOneViewController ()

@end

@implementation noCilentOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  self.view.backgroundColor   = [UIColor whiteColor];
  
  
  
  UIButton *backBtn =[[UIButton alloc]initWithFrame:CGRectMake(10, 20, 25, 25)];
  //  backBtn.backgroundColor =[UIColor redColor];
  [backBtn setBackgroundImage:[UIImage imageNamed:@"come_back.png"] forState:UIControlStateNormal];    //设置button背景显示图片
  [backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:backBtn];
  
  UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/6, self.view.frame.size.height/6, self.view.frame.size.width/6*4, 200)];
  imageView.image =[UIImage imageNamed:@"yichang.png"];
  [self.view addSubview:imageView];
  
  
  UIButton *questionBtn =[[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-150)/2, CGRectGetMaxY(imageView.frame)+20, 150, 40)];
  //  backBtn.backgroundColor =[UIColor redColor];
  [questionBtn setTitle:@"查看解决方案" forState:UIControlStateNormal];
  [questionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  questionBtn.layer.borderWidth =0.5;
  questionBtn.layer.cornerRadius=5;
  //  [backBtn setBackgroundImage:[UIImage imageNamed:@"come_back.png"] forState:UIControlStateNormal];    //设置button背景显示图片
  [questionBtn addTarget:self action:@selector(questionAction) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:questionBtn];
  
}
-(void)questionAction{
  NoCilentViewController *noCilent =[[NoCilentViewController alloc]init];
  
  [self presentViewController:noCilent animated:YES completion:nil];
}


-(void)backBtnAction{
  
  [self dismissViewControllerAnimated:YES completion:nil];
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
