//
//  SplashViewController.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "SplashViewController.h"
#import "FoxProgressView.h"
#import <UIKit/UIKit.h>
@interface SplashViewController (){
    FoxProgressView *progressView;
    UILabel *lblText;
    UIImageView *backImg;
}
@end

@implementation SplashViewController
- (void)viewWillAppear:(BOOL)animated {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    backImg=[UIImageView new];
    backImg.frame=self.view.bounds;
    [self.view addSubview:backImg];
    
    [self loadBackImage];
    
    //进度条
    progressView = [[FoxProgressView alloc] initWithFrame:CGRectMake(0,0, 200, 15)];
    progressView.progress = 0;
    progressView.center=self.view.center;
    [self.view addSubview:progressView];
    lblText=[UILabel new];
    lblText.frame=CGRectMake(0, progressView.frame.origin.y+progressView.frame.size.height+20, self.view.bounds.size.width, 30);
    [self.view addSubview:lblText];
    lblText.textAlignment=NSTextAlignmentCenter;
    self.view.backgroundColor=[UIColor whiteColor];
    
    // [self hideProgress];
    [self showBackImage];
    
}
-(void)loadBackImage{
    
   
    
    CGFloat greaterPixelDimension = (CGFloat) fmaxf(((float)[[UIScreen mainScreen]bounds].size.height),
                                                    ((float)[[UIScreen mainScreen]bounds].size.width));
    switch ((NSInteger)greaterPixelDimension) {
        case 480:
            backImg.image=[UIImage imageNamed:@"Default"];
            break;
        case 568:
            backImg.image=[UIImage imageNamed:@"Default-568h@2x"];
            break;
        case 667:
            backImg.image=[UIImage imageNamed:@"Default-667h@2x"];
            break;
        case 736:
            backImg.image=[UIImage imageNamed:@"Default-736h@3x"];
            break;
        default:
            backImg.image=[UIImage imageNamed:@"Default-736h@3x"];
            break;
    }
    
    
}
-(void)hideProgress{
    progressView.hidden=YES;
    lblText.hidden=YES;
}
-(void)showProgress{
    progressView.hidden=NO;
    lblText.hidden=NO;
}
-(void)hideBackImage{
    backImg.hidden=YES;
}
-(void)showBackImage{
    backImg.hidden=NO;
}

-(void)setStatus:(const NSString *) status finishRate:(const int)finishRate{
    progressView.progress=(float)finishRate/100;
    lblText.text=(NSString *)status;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    int ii=0;
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
