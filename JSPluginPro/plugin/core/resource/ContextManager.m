//
//  ContextManager.m
//  YXBuilder
//
//  Created by LiYuan on 2017/12/26.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "ContextManager.h"
#import "FoxEventListenerCustom.h"
#import "Base64Native.h"
@implementation ContextManager

+ (JSContext *)getContext {
    
    // 获取上下文
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue)
    {
        [JSContext currentContext].exception = exceptionValue;
        FOXLog(@"exception:%@",[exceptionValue toString]);
    };
    
    return context;
    
}
+(void)registerGlobalJSBridgeMethod{
    
    JSContext *context =[ContextManager getContext];
    //*************************全局注入**********************//
    //log
//    context[@"yu"][@"log"]=^(NSString *ff){
//        NSLog(@"yu log=%@",ff);
//    };
    //判断设备类型
//    context[@"yu"][@"isPhoneOriPad"]=^BOOL(){
//        int iiiii=0;
//        iiiii=0;
//        iiiii=0;
//        iiiii=0;
//        iiiii=0;
//        iiiii=0;
//        return YES;
//    };
    //全局事件通知注册
    //context[@"fox"][@"_EventListenerCustom"]=[EventListenerCustom class] ;
//    context[@"yu"][@"EventCustom"]=[EventCustom class] ;
    //base64编码解码
//    context[@"yu"][@"NativeBase64"]=[Base64Native class];
    
}
@end
