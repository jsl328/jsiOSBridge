//
//  RootViewController.m
//  YXBuilder
//
//  Created by LiYuan on 2017/11/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "RootViewController.h"

#import "Platform.h"
#import "SplashViewController.h"
#import "ProgressMonitor.h"
#import "Status.h"
#import "BootManager.h"
#import "ContainerView.h"
#import "LogManager.h"
#import "StatisticsManager.h"
//#import "LicenseManager.h"
#import "SplashManager.h"


#import "NewFeatureManager.h"
#import "SimulatorManager.h"

#import "FoxEventDispatcher.h"
#import "FoxEventListenerCustom.h"
#import "FoxEventCustom.h"
#import "FoxEventPushMessage.h"
#import "FoxEventListenerPushMessage.h"
#import "YXPlugin.h"
#import "FileAccessor.h"

//using namespace Fox;
#define manifestDic [NSJSONSerialization JSONObjectWithData:[[NSData alloc]initWithContentsOfFile:[[FileAccessor getInstance] constructAbsolutePath:@"configuration/launchImage.json"]] options:NSJSONReadingMutableLeaves error:nil]

@interface RootViewController () <UIWebViewDelegate,UIEventExecutorDelegate, NewFeatureDelegate>{
    SplashViewController *splashVC;
    long  startTime;
    ContainerView *container; //wx86fecedee64000a5
    
}
@property (nonatomic, readwrite, strong) dispatch_queue_t queue;

@end

@implementation RootViewController
@synthesize queue;
static int loadOne=0;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(splashViewRemove) name:@"SplashViewRemoveNoti" object:nil];
//*********************************原生推送事件分发调试************************************/
//    EventDispatcher * dispatcher =   [Platform getInstance].eventDispatcher;
//
//
//    void(^callback)(EventPushMessage* event) = ^(EventPushMessage* event){
//
//        if([[event getMessageType] isEqualToString:@"receive"]){//收到推送消息
//            NSDictionary *msg=[event getMessage];
//
//            if(msg[@"aps"]) {  //
//                NSLog(@"接收到在线APNS消息：" );
//            } else {
//                NSLog(@"接收到在线透传消息：");//应用在前台，socket发送，或者自己创建本地推送收到
//            }
//            [self logoutPushMsg:msg];
//        }
//        else if([[event getMessageType] isEqualToString:@"click"]){//收到点击消息
//             NSDictionary *msg=[event getMessage];
//             id payload=msg[@"payload"];
//            if([payload isKindOfClass:[NSString class]]){
//                if([payload isEqualToString:@"LocalMSG"]){//本地创建推送点击之后的回调
//                    NSLog(@"点击本地创建消息启动：");
//                }
//            }
//            else if([payload isKindOfClass:[NSDictionary class]]){
//                NSLog(@"点击离线推送消息启动：");////应用关闭和应用退出  点击推送启动之后的回调（可能由apns触发，也可能由个推）
//            }
//
//
//            [self logoutPushMsg:msg];
//
//        }
//    };
//
//    EventListenerPushMessage *listener= [EventListenerPushMessage create:callback];
//
//    [dispatcher addEventListenerWithFixedPriority:listener fixedPriority:22];
//    void(^callback2)(EventCustom* event) = ^(EventCustom* event){
//        NSLog(@"呵呵fffffff");
//    };
////
//    listener= [EventListenerCustom create:@"test" callback:callback2];
//
//    [dispatcher addEventListenerWithFixedPriority:listener fixedPriority:23];
//    EventPushMessage *event2=[[EventPushMessage alloc] init];
//    [dispatcher dispatchEvent:event2];
//    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
//    
//    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//        [dispatcher removeAllEventListeners];
//    });
    
}
/**
 * 日志输入推送消息内容
 */
-(void)logoutPushMsg:(NSDictionary*) msg  {
    NSMutableString *outLine=[NSMutableString new];
    [outLine appendFormat:@"title: %@",msg[@"title"] ];
    [outLine appendFormat:@"content: %@",msg[@"content"] ];
   if (msg[@"payload"] ) {
        if ( [msg[@"payload"] isKindOfClass:[NSString class]] ) {
            [outLine appendFormat: @"payload(String): %@",msg[@"payload"] ];
        } else {
            [outLine appendFormat: @"payload(JSON): %@",msg[@"payload"] ];
            
        }
    } else {
         [outLine appendFormat: @"payload: undefined%@",@"" ];
       
    }
    if ( msg[@"aps"] ) {
         [outLine appendFormat: @"aps:%@",msg[@"aps"] ];
       }
    NSLog(@"%@",[outLine copy]);
}


-(void)viewDidAppear:(BOOL)animated{

//    if (![LicenseManager licenseCheck]) return;
    
    if(loadOne==0){
        //启动开始时间
        startTime= [[NSDate date] timeIntervalSince1970];
        
        [self config];
        
        [self prepare];
        
        [self boot];
        
        //    dispatch_queue_t queue  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //
        //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), queue, ^{
        //        ProgressMonitor *monitor=[[ProgressMonitor alloc] initWithRootViewController:self];
        //        [BootManager unload:self monitor:monitor];
        //    });
        
    }
    loadOne++;
}
/**
 * 准备
 */
-(void)prepare{
    FOXLog(@"准备环境");
    Platform *platform=[Platform getInstance];
    platform.rootViewController=self;
      // 注册UI Event执行器
    platform.uiEventExecutor=self;
    FOXLog(@"%@",platform);
}


/**
 * 配置
 */
-(void)config {
    [self logConfig];
}

- (void)logConfig {
    [[LogManager getIntance] startLogWithCache:YES];
    FOXLog(@"配置日志完毕");
    [StatisticsManager setupStatistics];
    FOXLog(@"埋点日志完毕");
}

//启动
-(void)boot{
    self.queue = dispatch_queue_create("foxThreadQue",
                                       DISPATCH_QUEUE_SERIAL);
    // 启动加载界面
    splashVC=[[SplashViewController alloc] init];
    [self.view addSubview:splashVC.view];
   // [self initWebView];
    dispatch_async(queue, ^{
        ProgressMonitor *monitor=[[ProgressMonitor alloc] initWithRootViewController:self];
            NSArray<Status*>*statusList=  [BootManager load:self monitor:monitor];
            for (int i = 0; i < statusList.count; i++) {
                // 判断是否启动失败
                if ([statusList[i] resultCode] == Status.FAIL) {
                    // 取消启动
                    [self cancelBoot];
                    return;
                }
                // 判断是否需要重启
                if ([statusList[i] resultCode] == Status.RESTART) {
                    // 重启
                    [self reBoot];
                    return;
                }
                // 判断是否需要退出
                if ([statusList[i] resultCode] == Status.EXIT) {
                    // 取消启动
                    [self cancelBoot];
                    return;
                }
            }
            // 完成启动
            dispatch_sync(dispatch_get_main_queue(),^{
                NSLog(@">>>>>>>>>>加载完成");
                [self finishBoot];
            });
    });
}

-(void)reBoot{
    FOXLog(@"重新启动,具体UI在确认");
    //启动开始时间
    startTime= [[NSDate date] timeIntervalSince1970];
    [self config];
    [self prepare];

    [self boot];
}
-(void)cancelBoot{
    FOXLog(@"取消启动");
    [self exitApp];
}
-(void)finishBoot{
    [self initWebView];
    return;
    
    // 启动时间要大于启动时间，避免splash页面切换太快
    long time = [[NSDate date] timeIntervalSince1970] - startTime;//毫秒差
    int minBootTime = 800;
    minBootTime -= time;
    if (minBootTime > 0) { //以这个无关，加载不出进度条
         [NSThread sleepForTimeInterval:minBootTime/1000];
        
    }
    //不去掉splashVC，等webview加载html完毕的时候在隐藏
    //[splashVC.view removeFromSuperview];
   
    if ([[manifestDic objectForKey:@"simulator_enable"] isEqualToString:@"false"]) {
        if ([SimulatorManager SimulatorCheck]) return;
    }

    if ([[manifestDic objectForKey:@"ad_enable"] isEqualToString:@"true"]) {
        //广告类型：图片，html
        [SplashManager shareManager].adType = [[manifestDic objectForKey:@"ad_type"] isEqualToString:@"ad_type_pic"] ? ShowADTypePic : ShowADTypeHtml;
        
        if ([[manifestDic objectForKey:@"ad_type_num"] intValue] == 0) {
            [SplashManager shareManager].adUrl = [manifestDic objectForKey:@"ad_type_pic_url"];
        } else {
            [SplashManager shareManager].adUrl = [manifestDic objectForKey:@"ad_type_html_url"];
        }
        

        [SplashManager shareManager].openUrlStr = [manifestDic objectForKey:@"ad_open_url"];

        [SplashManager shareManager].duration = [[manifestDic objectForKey:@"ad_duration"] integerValue];

        [[SplashManager shareManager] splashFinished:^(BOOL isFinish) {
            if (isFinish) {
                if ([[manifestDic objectForKey:@"guide_enable"] isEqualToString:@"true"]) {
                    NSArray *picStrArr = [manifestDic objectForKey:@"guide_image_names"];
                    [NewFeatureManager shareManagerWithDelegate:self picStrArr:picStrArr];
                }
            }
        }];
    } else if ([[manifestDic objectForKey:@"guide_enable"] isEqualToString:@"true"]) {
        NSArray *picStrArr = [manifestDic objectForKey:@"guide_image_names"];
        [NewFeatureManager shareManagerWithDelegate:self picStrArr:picStrArr];
    } 
   

   // #ifdef DEBUG
 
  //  #ifdef DEBUG
 
//    NSString *logtxt=[NSString stringWithFormat:@"启动程序完成，耗时:%ld 毫秒",(long)[[NSDate date] timeIntervalSince1970] - startTime ];
//    FOXLog(@"%@",logtxt);
  //  #else
    
   // #endif

}
-(void)exitApp{
    exit(0);

    
    
    
    
    
    
    //    UIWindow *window = [UIApplication sharedApplication].delegate.window;
//
//    [UIView animateWithDuration:1.0f animations:^{
//        window.alpha = 0;
//        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
//    } completion:^(BOOL finished) {
//
//    }];
}
-(void)setBootStatus:(const NSString *) status finishRate:(const int)finishRate{
   // dispatch_group_async(group, queue, ^{
        dispatch_sync(dispatch_get_main_queue(),^{
            FOXLog(@">>>>>>>>>>加载状态=%@,百分比=%d",status,finishRate);
            [splashVC setStatus:status finishRate:finishRate];
        });
   // });
    
}
-(void)splashViewRemove{
    [splashVC.view removeFromSuperview];
     splashVC=nil;
}

- (void)initWebView {
    container = [[ContainerView alloc] initWithRoot:self fullScreen:YES statusColor:[UIColor grayColor]];
    [self.view addSubview:container];
    //放到splash下面
    [self.view bringSubviewToFront:splashVC.view];
}

/**
 * 判断是否为UI线程
 * return
 */
-(BOOL) isUIThread{
    return ([NSThread currentThread]== [NSThread mainThread]);
}

/**
 * 执行UI事件
 * param runnable
 */
-(void) run{
    
}

- (void)newFeatureDidLoadFinished {
    
}

@end
