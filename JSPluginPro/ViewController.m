//
//  ViewController.m
//  JSPluginPro
//
//  Created by panluyao on 2018/9/4.
//  Copyright © 2018年 ccb. All rights reserved.
//

#import "ViewController.h"
#import "RootViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *btnTest;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //ccb.JSPluginPro
    // Do any additional setup after loading the view, typically from a nib.
    
    RootViewController *rootViewController=[[RootViewController alloc] init];
    [self.view addSubview:rootViewController.view];
    
    //[self.view addSubview:self.btnTest];
}

- (UIButton *)btnTest
{
    if (!_btnTest) {
        _btnTest = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 150, 80)  ];
        _btnTest.backgroundColor = [UIColor orangeColor];
        [_btnTest setTitle:@"测试" forState:UIControlStateNormal];
        [_btnTest addTarget:self action:@selector(onTestAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnTest;
}

- (void)onTestAction:(id)sender
{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
