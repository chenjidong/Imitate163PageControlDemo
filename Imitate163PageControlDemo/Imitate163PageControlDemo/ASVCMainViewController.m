//
//  ASVCMainViewController.m
//  Imitate163PageControlDemo
//
//  Created by 万众科技 on 15/8/29.
//  Copyright (c) 2015年 万众科技. All rights reserved.
//

#import "ASVCMainViewController.h"
#import "ContentViewController.h"



@interface ASVCMainViewController ()<UIScrollViewDelegate>

@property (nonatomic,assign) int currentPage;
@property (nonatomic,strong) UIScrollView * headScrollView;
@property (nonatomic,strong) UIScrollView * contentScrollView;
@property (nonatomic,strong) NSArray * headTitleArray;

@end

@implementation ASVCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configHeadScrollView];
    [self configContentScrollView];
}

#pragma mark － 懒加载
//频道列表
-(NSArray *)headTitleArray {
    if (!_headTitleArray) {
        _headTitleArray = [NSArray arrayWithObjects:@"头条",@"娱乐",@"热点",@"体育",@"广州",@"财经",@"科技", nil];
    }
    return _headTitleArray;
}

#pragma mark - 顶部频道配置
- (void)configHeadScrollView {
    self.headScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, HEADSCROLLVIEW_HEIGHT)];
    self.headScrollView.backgroundColor = [UIColor purpleColor];
    self.headScrollView.contentSize = CGSizeMake(self.headTitleArray.count * 60, 40);
    self.headScrollView.bounces = NO;
    [self.view addSubview:self.headScrollView];
    
    [self addBtnsToHeadScrollView];
}


//加频道按钮
- (void)addBtnsToHeadScrollView {
    
    for (int i = 0; i < self.headTitleArray.count; i ++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0 + 60 * i, 0, 60, 40);
        [button setTitle:self.headTitleArray[i] forState:UIControlStateNormal];
        [button setTag:1000 + i];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self scaleButton:button withScale:0];
        [self.headScrollView addSubview:button];
        
        [button addTarget:self action:@selector(headScrollViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //默认当前为第一个频道
        if (!i) {
            [self scaleButton:button withScale:1];
        }
        
    }
}

#pragma mark - 配置内容ScrollView
- (void)configContentScrollView {
    CGRect contentScrollViewRect = CGRectMake(0, 64 + HEADSCROLLVIEW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - HEADSCROLLVIEW_HEIGHT);
    self.contentScrollView = [[UIScrollView alloc]initWithFrame:contentScrollViewRect];
    self.contentScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * self.headTitleArray.count, contentScrollViewRect.size.height);
    self.contentScrollView.bounces = NO;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.delegate = self;
    [self.view addSubview:self.contentScrollView];
    
    [self addContentVC];
}

/**
 *  加入视图控制器
 1、先加入ChildViewController   无
 2、设置frame                   VC会调用viewDidLoad方法
 3、加入superView               VC会调用viewWillApper、viewDidApper方法
 
 */
- (void)addContentVC {
    
    for (int i = 0; i < self.headTitleArray.count; i ++) {
        ContentViewController * VC = [[ContentViewController alloc]init];
        VC.typeName = self.headTitleArray[i];
        [self addChildViewController:VC];
        
        //默认加载第一页
        if (!i) {
            [self loadScrollViewWithPage:i];
        }
    }
}

- (CGRect)getRect:(int)currentPage {
    CGRect rect = CGRectMake(SCREEN_WIDTH * currentPage, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - HEADSCROLLVIEW_HEIGHT);
    return rect;
}

- (void)loadScrollViewWithPage:(int)page {
    
    if (page < 0 || page >= self.headTitleArray.count) {
        return;
    }
    //判断页面是否已经显示，如果未显示则让其显示
    ContentViewController * VC = [self.childViewControllers objectAtIndex:page];
    if (VC.view.superview == nil) {
        VC.view.frame = [self getRect:page];
        [self.contentScrollView addSubview:VC.view];
    }else {
        return;
    }
    
}


#pragma mark - scrollViewDelegate

//用户滑动屏幕切换频道的情景：ScrollView滚动停止的时候调用该方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView == self.contentScrollView) {
        CGFloat pageWidth = SCREEN_WIDTH;
        self.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        //加载页面
        [self loadScrollViewWithPage:self.currentPage];
        
        //滚动标题栏
        [self scrollHeadScrollView];
        
        //修正切换太快导致频道按钮出现缩放不正确的问题
        [self.headScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if ([obj isKindOfClass:[UIButton class]] && idx != self.currentPage) {
                [self scaleButton:obj withScale:0];
            }
            
        }];
        
        
    }
    
}

//用户点击导航频道切换内容的情景：
// 调用以下函数，来自动滚动到想要的位置，此过程中设置有动画效果，停止时，触发该函数
// UIScrollView的setContentOffset:animated:
// UIScrollView的scrollRectToVisible:animated:
// UITableView的scrollToRowAtIndexPath:atScrollPosition:animated:
// UITableView的selectRowAtIndexPath:animated:scrollPosition:
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:self.contentScrollView];
}


//用户滑动屏幕的情况：实时改变频道按钮的大小
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat value = scrollView.contentOffset.x / SCREEN_WIDTH;
    //计算出需要改变大小的按钮的位置
    int leftBtnIndex = (int)value;
    int rightBtnIndex = leftBtnIndex + 1;
    //计算出需要改变大小的倍数
    CGFloat rightScale = value - leftBtnIndex;
    CGFloat leftScale = 1 - rightScale;
    
    //改变大小
    UIButton * leftBtn = [self.headScrollView.subviews objectAtIndex:leftBtnIndex];
    [self scaleButton:leftBtn withScale:leftScale];
    if (rightBtnIndex < self.headTitleArray.count) {
        UIButton * rightBtn = [self.headScrollView.subviews objectAtIndex:rightBtnIndex];
        [self scaleButton:rightBtn withScale:rightScale];
    }
    
    
}


//改变按钮大小
- (void)scaleButton:(UIButton *)button withScale:(CGFloat)scale {
    [button setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 - scale alpha:1.0] forState:UIControlStateNormal];
    CGFloat minScale = 0.8;
    CGFloat trueScale = minScale + (1 - minScale) * scale;
    button.transform = CGAffineTransformMakeScale(trueScale, trueScale);
}

//改变频道按钮的坐标
- (void)scrollHeadScrollView {
    
    CGFloat x = self.currentPage * 60 + 60 * 0.5 - SCREEN_WIDTH * 0.5;
    if (x >= 0) {
        if (x >= self.headScrollView.contentSize.width - SCREEN_WIDTH) {
            x = self.headScrollView.contentSize.width - SCREEN_WIDTH;
            [self.headScrollView setContentOffset:CGPointMake(x, 0) animated:YES];   //向右滚动到尽头
        }else
            [self.headScrollView setContentOffset:CGPointMake(x, 0) animated:YES];
    }else
        [self.headScrollView setContentOffset:CGPointMake(0, 0) animated:YES];  //向左滚动到尽头
}


//点击频道按钮切换
- (void)headScrollViewButtonAction:(UIButton *)button {
    
    NSInteger currentPage = button.tag - 1000;
    [self.contentScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * currentPage, 0) animated:YES];
    
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
