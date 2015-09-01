//
//  ACVCMainViewController.m
//  Imitate163PageControlDemo
//
//  Created by 万众科技 on 15/8/29.
//  Copyright (c) 2015年 万众科技. All rights reserved.
//

#import "ACVCMainViewController.h"
#import "ContentViewController.h"




@interface ACVCMainViewController ()

@property (nonatomic,strong) UIViewController * currentVC;
@property (nonatomic,strong) UIButton * currentBtn;
@property (nonatomic,strong) UIScrollView * headScrollView;
@property (nonatomic,strong) NSArray * headTitleArray;
@property (nonatomic,strong) NSMutableArray * vcArray;

@end

@implementation ACVCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configHeadScrollView];
    [self configDefaultVC];
}


#pragma mark － 懒加载
-(NSArray *)headTitleArray {
    if (!_headTitleArray) {
        _headTitleArray = [NSArray arrayWithObjects:@"头条",@"娱乐",@"热点",@"体育",@"广州",@"财经",@"科技", nil];
    }
    return _headTitleArray;
}

-(NSMutableArray *)vcArray {
    if (!_vcArray ) {
        _vcArray = [[NSMutableArray alloc]init];
        
        //创建内容视图
        [self configVCArray];
    }
    return _vcArray;
}

- (void)configVCArray {
    CGRect childVCRect = CGRectMake(0, 64 + HEADSCROLLVIEW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - HEADSCROLLVIEW_HEIGHT);
    for (int i = 0; i < self.headTitleArray.count; i ++) {
        ContentViewController * VC = [[ContentViewController alloc]init];
        VC.typeName = self.headTitleArray[i];
        VC.view.frame = childVCRect;
        [_vcArray addObject:VC];
    }
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

- (void)addBtnsToHeadScrollView {
    
    for (int i = 0; i < self.headTitleArray.count; i ++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0 + 60 * i, 0, 60, 40);
        [button setTitle:self.headTitleArray[i] forState:UIControlStateNormal];
        [button setTag:1000 + i];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self.headScrollView addSubview:button];
        
        [button addTarget:self action:@selector(headScrollViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //默认当前为第一个频道
        if (!i) {
            [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
            self.currentBtn = button;
        }
    }
}

#pragma mark - 视图切换方法
- (void)configDefaultVC {
    
    //默认加载第一个标签页
    self.currentVC = self.vcArray[0];
    [self addChildViewController:self.currentVC];
    [self.view addSubview:self.currentVC.view];
    
}

- (void)headScrollViewButtonAction:(UIButton *)button {
    //点击频道按钮切换视图
    if (self.currentVC == self.vcArray[button.tag - 1000]) {
        //如果是当前频道，则不操作
        return;
    }else {
        
        //切换频道按钮
        [self.currentBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self.currentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        
        self.currentBtn = button;
        
        //切换VC
        NSInteger num = button.tag - 1000;
        [self switchNewVC:self.vcArray[num]];

    }
}

/**
 *  移除当前VC，替换新的VC
 */
- (void)switchNewVC:(UIViewController *)newViewController {
    
    //1、先加载新VC为ChildViewController
    [self addChildViewController:newViewController];
    //2、动画从当前VC切换到新VC
    /**
     *  transitionFromViewController 方法
     更详细了解到：http://blog.csdn.net/yongyinmg/article/details/40619727
     
     交换两个子视图控制器的位置（由于添加的顺序不同，所以子试图控制器在父视图控制器中存在层次关系）

     fromViewController：当前显示的子试图控制器，将被替换为非显示状态
     
     toViewController：将要显示的子视图控制器
     
     duration：交换动画持续的时间，单位秒
     
     options：动画的方式
     
     animations：动画Block
     
     completion：完成后执行的Block
     */
    [self transitionFromViewController:self.currentVC toViewController:newViewController duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        
        if (finished) {
            
            //3、动画完毕后，移除旧VC，设置新VC为当前VC
            /**
             关于willMoveToParentViewController方法和didMoveToParentViewController方法的使用
             
             1.这两个方法用在子试图控制器交换的时候调用！即调用transitionFromViewController 方法时，调用。
             
             2.当调用willMoveToParentViewController方法或didMoveToParentViewController方法时，要注意他们的参数使用：
             
             当某个子视图控制器将从父视图控制器中删除时，parent参数为nil。
             
             即：[将被删除的子试图控制器 willMoveToParentViewController:nil];
             
             当某个子试图控制器将加入到父视图控制器时，parent参数为父视图控制器。
             
             即：[将被加入的子视图控制器 didMoveToParentViewController:父视图控制器];
             */
            [newViewController didMoveToParentViewController:self];
            [self.currentVC willMoveToParentViewController:nil];
            [self.currentVC removeFromParentViewController];
            self.currentVC = newViewController;
        }
    }];
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
