//
//  BrowSerWebView.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/19.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "BrowSerWebView.h"
#import "YXPlugin.h"
#import "IWebViewBridgeDelegate.h"
#import "WebViewBridge.h"
#import "ProxyLoader.h"
#import "ConfigPreference.h"
#import "FoxFileManager.h"
#import "ProxyLauncher.h"
#import "ContextManager.h"
#import "Platform.h"
#import "FileAccessor.h"
@interface BrowSerWebView()<UIWebViewDelegate>{
    
    
}
@property(weak)UIViewController *root;
/**
 * 开始URL
 */
@property(copy) NSString *startUrl;
@end
@implementation BrowSerWebView


- (instancetype)initWithRoot:(UIViewController*)rootVC frame:(CGRect)frame {
    if(self = [super init]){
        self.root=rootVC;
        self.delegate=self;
        self.frame = frame;
      
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        self.opaque=NO;
        self.backgroundColor=[UIColor whiteColor];
        
        // 设置web view桥接
        id<IWebViewBridgeDelegate> webViewBridge =  [[WebViewBridge alloc] initWithWebView:self];
        [[Platform getInstance] setWebViewBridge:webViewBridge];
        [YXPlugin setWebView:self rootViewController:rootVC];
        
        [self startWeb];
        
//        if (@available(iOS 11.0, *)) {
//            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        } else {
//            self.root.automaticallyAdjustsScrollViewInsets = NO;
//        }
     
    }
     return self;
}

-(void)startWeb{
    
//    NSString *defaultStartUrl = @"local:///workspace/web-phone/index.html";
//    // 获取配置
//    ConfigPreference* pref = [ConfigPreference getInstance];
//    // 获取启动URL
//    _startUrl = [pref getString:@"web" key:@"startUrl" defaultValue:defaultStartUrl];
//
    // 工程内资源 这里改过
//    if ([self.startUrl hasPrefix:@"http://"] && ![self.startUrl hasPrefix:@"https://"] && ![self.startUrl hasPrefix:@"file:///"]) {
//        FileAccessor *fileAccessor = [FileAccessor getInstance];
//        NSString * file = [fileAccessor getFile :_startUrl ];
//
//        if([FoxFileManager isFileAtPath:file error:nil]){
//            NSString *htmlString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:NULL];
//            NSString* indexHtml= [[file componentsSeparatedByString:@"/"] lastObject];
//            NSString * directiry= [file substringToIndex:[file rangeOfString:indexHtml].location];
//            [self loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:directiry isDirectory:YES]];
//        }
//        else{
//            FOXLog(@"无法找到启动页面");
//        }
//    }else{
//
//    }
//
    //jsl.... 加载网络的html //192.168.1.5:9090/#/jsbridge http://192.168.1.5:9090/jsbt/#jsbridge //172.20.10.3
    
    NSURL *url =[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@",@"http://172.20.10.3:8080/jsbt/#/jsbridge"]];///http://192.168.43.45:8080/#/
    NSURLRequest *request =[[NSURLRequest alloc]initWithURL:url];
    [self loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    ProxyLoader* proxyLoader = [ProxyLoader getInstance];
    NSDictionary<NSString*,id>*proxyDic=[proxyLoader getAll];
    for(id name in proxyDic.allKeys){
        JSContext *context= [ContextManager getContext];
        context[name]=proxyDic[name];
    }
    [ContextManager registerGlobalJSBridgeMethod];
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        //移除splash页面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SplashViewRemoveNoti" object:nil];
    });
    
    //去掉双击放大
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView stringByEvaluatingJavaScriptFromString:injectionJSString];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    FOXLog(@"webViewError:%@",error);
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}
@end

