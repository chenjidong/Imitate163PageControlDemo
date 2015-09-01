//
//  ViewController.m
//  Imitate163PageControlDemo
//
//  Created by 万众科技 on 15/8/29.
//  Copyright (c) 2015年 万众科技. All rights reserved.
//

#import "ViewController.h"
#import "ACVCMainViewController.h"
#import "ASVCMainViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
        self.title = @"仿163新闻首页滚动视图Demo - by KevinSu";
}
#pragma mark 使用addChildViewController切换
- (IBAction)switchByAddChildViewController:(id)sender {
    
    ACVCMainViewController * VC = [[ACVCMainViewController alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}
#pragma mark 使用ScrollViewController切换
- (IBAction)switchByScrollView:(id)sender {
    
    ASVCMainViewController * VC = [[ASVCMainViewController alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
