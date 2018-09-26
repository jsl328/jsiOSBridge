//
//  NSObject+crash.m
//  YXBuilder
//
//  Created by LiYuan on 2017/12/29.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "NSObject+crash.h"
#import "CrashHelper.h"
#import "YXPlugin.h"
@implementation NSObject (crash)

void uncaughtExceptionHandler(NSException *exception){
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
    
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    // app build版本
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    //异常堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    
    // 出现异常的原因
    NSString *reason = [exception reason];
    
    // 异常名称
    NSString *name = [exception name];
    
    //userInfor
    NSDictionary *userInfor = [exception userInfo];
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception app Name == %@\nException app Version == %@\nException app Build == %@\nException name == %@\nException reason == %@\nException stack == %@\nUserInfor == %@", app_Name, app_Version, app_build, name, reason, stackArray, userInfor.description];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    
    if([CrashHelper createCrashLog:exceptionInfo fileName:dateTime]){
        
        FOXLog(@"崩溃日志生成成功");
        //先不传，下次启动再穿
//        [CrashHelper updateAsynToServer];
    }
    
    FOXLog(@"数据执行完毕!!!");
    
}

+ (void) load {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

@end
