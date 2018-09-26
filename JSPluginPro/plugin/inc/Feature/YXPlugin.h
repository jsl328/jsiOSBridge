//
//  YXPlugin.h
//  YXBuilder
//
//  Created by LiYuan on 2017/11/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//
#ifndef YXPlugin__FOX__
#define YXPlugin__FOX__
#import <JavaScriptCore/JavaScriptCore.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CocoaLumberjack.h"
//通过DEBUG模式设置全局日志等级，DEBUG时为Verbose，所有日志信息都可以打印，否则Error，只打印
#define DEBUGLOG 1
#ifdef DEBUGLOG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#define FOXLog(FORMAT, ...) DDLogInfo((@"[%s:%d行]" "%s" FORMAT), [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __FUNCTION__, ##__VA_ARGS__);
#else
static const DDLogLevel ddLogLevel = DDLogLevelError;
#define FOXLog(...);
#endif

#define TESTLOAD  (![[Platform getInstance].settings[@"ProductEnvironment"]boolValue ])

#define APPID [[[[NSBundle mainBundle] bundleIdentifier] componentsSeparatedByString:@"."] lastObject]
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
@interface YXPlugin : NSObject

+ (UIWebView *)webView;
+ (UIViewController *)rootViewController;

+ (void)setWebView:(UIWebView *)webView rootViewController:(UIViewController *)rootViewController;
-(UIViewController *)rootViewController;

@end
#endif
