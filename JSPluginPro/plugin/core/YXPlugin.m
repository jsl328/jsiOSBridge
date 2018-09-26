//
//  YXPlugin.m
//  YXBuilder
//
//  Created by LiYuan on 2017/11/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "YXPlugin.h"
 
static UIWebView *staticWebView;
static UIViewController *staticRootViewController;

@implementation YXPlugin

//void uncaughtExceptionHandler(NSException *exception){
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSLog(@"infoDictionary==%@",infoDictionary.description);
//
//    // app名称
//    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
//    NSLog(@"app_Name==%@",app_Name);
//
//    // app版本
//
//    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//    NSLog(@"app_Version==%@",app_Version);
//
//    // app build版本
//
//    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
//    NSLog(@"app_build==%@",app_build);
//
//    //异常堆栈信息
//    NSArray *stackArray = [exception callStackSymbols];
//
//    // 出现异常的原因
//    NSString *reason = [exception reason];
//
//    // 异常名称
//    NSString *name = [exception name];
//
//    //userInfor
//    NSDictionary *userInfor = [exception userInfo];
//
//    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception name == %@\nException reason == %@\nException stack == %@\nUserInfor == %@",name, reason, stackArray, userInfor.description];
//
//    NSLog(@"exceptionInfo ：%@", exceptionInfo);
//
//    NSMutableArray *tmpArr = [NSMutableArray arrayWithObject:exceptionInfo];
//
//    [tmpArr insertObject:reason atIndex:0];    //保存到本地  --  当然你可以在下次启动的时候，上传这个log
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyyMMddHHmmss"];
//    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
//
//
//    if([CrashHelper createCrashLog:exceptionInfo fileName:dateTime]){
//        NSLog(@"崩溃日志生成成功");
//        //先不传，下次启动再穿
//        //[CrashHelper updateAsynToServer];
//    }
//
//
//}
//+ (void) initialize {
//    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
//}
//
//+ (void) load {
//    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
//}



+ (void)setWebView:(UIWebView *)webView_ rootViewController:(UIViewController *)rootViewController_ {
    staticWebView = webView_;
    staticRootViewController = rootViewController_;
}

+ (UIWebView *)webView {
    return staticWebView;
}

+ (UIViewController *)rootViewController {
    return staticRootViewController;
}
-(UIViewController *)rootViewController{
     return staticRootViewController;
}
@end

