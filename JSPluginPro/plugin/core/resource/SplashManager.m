//
//  SplashManager.m
//  YXBuilder
//
//  Created by LiYuan on 2018/1/4.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "SplashManager.h"
#import "XHLaunchAd.h"
#import "ADWebViewController.h"
 

@interface SplashManager() <XHLaunchAdDelegate, ADWebViewDelegate, NSCopying, UIGestureRecognizerDelegate> {
    finishBlock finishB;
    BOOL isFinishFailed;
    NSString *_urlString;
    XHLaunchAd *_launchAd;
}

@end

@implementation SplashManager

+ (SplashManager *)shareManager {
    static SplashManager *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[SplashManager alloc] init];
    });
    return instance;
}

-(id)copyWithZone:(NSZone *)zone {
    SplashManager *newClass = [[SplashManager alloc]init];
    newClass = self;
    return newClass;
}

-(void)setupXHLaunchAd {
    
    //配置广告数据
    XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration new];
    //广告停留时间
    if (self.duration) {
        imageAdconfiguration.duration = self.duration;
    }
    //广告frame
    imageAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);// * 0.8
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    NSString *imageString = [NSString string];
    
    switch ((int)height) {
        case 480:
            imageString = @"Default@2x";
            break;
        case 568:
            imageString = @"Default-568h@2x";
            break;
        case 667:
            imageString = @"Default-667h@2x";
            break;
        case 736:
            imageString = @"Default-736h@3x";
            break;
        case 812:
            imageString = @"Default-812h@3x";
            break;
        default:
            imageString = @"Default-736h@3x";
            break;
    }
    
    if (self.adType == ShowADTypePic) {
        if (self.adUrl.length > 0) {
            imageString = self.adUrl;
        }
    } else {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:imageAdconfiguration.frame];
        [webView loadRequest:[[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:self.adUrl]]];
        _urlString = self.openUrlStr;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadClickView:)];
        tapGesture.delegate = self;
        [webView addGestureRecognizer:tapGesture];
        imageAdconfiguration.subViews = [NSArray arrayWithObject:webView];
    }
    //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
    imageAdconfiguration.imageNameOrURLString = imageString;
//    //设置GIF动图是否只循环播放一次(仅对动图设置有效)
//    imageAdconfiguration.GIFImageCycleOnce = NO;
    //图片填充模式
    imageAdconfiguration.contentMode = UIViewContentModeScaleAspectFill;
    //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    imageAdconfiguration.openModel = self.openUrlStr;
    //广告显示完成动画
    imageAdconfiguration.showFinishAnimate =ShowFinishAnimateFadein;
    //广告显示完成动画时间
    imageAdconfiguration.showFinishAnimateTime = 0.8;
    //跳过按钮类型
    imageAdconfiguration.skipButtonType = SkipTypeRoundProgressText;
    //后台返回时,是否显示广告
    imageAdconfiguration.showEnterForeground = NO;
    //设置要添加的子视图(可选)
//    imageAdconfiguration.subViews = [self launchAdSubViews];
    //显示开屏广告
    _launchAd = [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - XHLaunchAd delegate - 其他
/**
 广告点击事件回调
 */
-(void)xhLaunchAd:(XHLaunchAd *)launchAd clickAndOpenModel:(id)openModel clickPoint:(CGPoint)clickPoint{

    /** openModel即配置广告数据设置的点击广告时打开页面参数(configuration.openModel) */
    if(openModel==nil) return;
    _urlString = (NSString *)openModel;
    isFinishFailed = YES;
    
    [self loadClickView:YES];
}

- (void)loadClickView:(BOOL)isHiden {
    if (!isHiden) {
        [_launchAd removeAndAnimateDefault];
    }
    
    ADWebViewController *VC = [[ADWebViewController alloc] init];
    VC.myDelegate = self;
    VC.URLString = _urlString;
    //此处不要直接取keyWindow
    UIViewController* rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    [rootVC presentViewController:VC animated:YES completion:nil];
}

-(void)xhLaunchAdShowFinish:(XHLaunchAd *)launchAd {
    if (isFinishFailed) {
        isFinishFailed = NO;
        finishB(NO);
    } else {
        finishB(YES);
    }
}

- (void)splashFinished:(finishBlock)finish {
    finishB = finish;
    isFinishFailed = NO;
    
    //初始化开屏广告
    [self setupXHLaunchAd];
}

@end
