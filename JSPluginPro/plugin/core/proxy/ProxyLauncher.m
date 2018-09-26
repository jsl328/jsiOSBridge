//
//  ProxyLauncher.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "ProxyLauncher.h"
#import "IProgressMonitorDelegate.h"
#import "Status.h"
#import "ProxyLoader.h"
#import "ContextManager.h"
#import "IExtensionPointDelegate.h"
#import "IConfigElementDelegate.h"
#import "Platform.h"
@interface ProxyLauncher(){
    BOOL started;
}
@end
@implementation ProxyLauncher

+(NSString*)PROXY_POINT{
    return @"fox.proxy";
}

-(Status*)start:(id)context monitor:(id<IProgressMonitorDelegate>)monitor{
    
//    [NSThread sleepForTimeInterval:2];
    /*
     <!--代理模块扩展-->
     <extension point="fox.proxy">
     <proxy name="_FOX_PROXY_HTTP" class="fox.core.proxy.comm.HttpClient" text="通信代理">
     </proxy>
     <proxy name="_FOX_PROXY_NATIVE" class="fox.core.proxy.system.NativeProxy" text="本地接口代理">
 
     </extension>
     
     */
    //获取代理加载器
    ProxyLoader* proxyLoader = [ProxyLoader getInstance];
    
    // 加载proxy扩展点
    id<IExtensionPointDelegate> point = [[[Platform getInstance] getExtensionRegistry] getExtensionPoint: ProxyLauncher.PROXY_POINT];
    
    NSArray<id<IExtensionDelegate>>* extensions = [point getExtensions];
    
    //JSContext *jscon = [ContextManager  getContext];
   
    for (id<IExtensionDelegate> e in extensions) {
        NSArray<id<IConfigElementDelegate>>* nodes = [e getConfigElements];
        for (id<IConfigElementDelegate> node in nodes) {
            //获取代理名称
            NSString *name = [node getAttribute:@"name"];
            //获取代理类
            NSString * className = [node getAttribute:@"class"];
            
            @try {
                
                Class clazz = NSClassFromString(className);
                //创建proxy对象
                SEL sel = NSSelectorFromString(@"new");
                id proxy= [(id)clazz performSelector:sel];
                //把实体类注入javascriptCore中
               // jscon[name] = proxy;
                
                if(!proxy){
                    continue;
                }
                //加入注册表
                [proxyLoader put:name proxy:proxy];//_FOX_PROXY_HTTP
            } @catch (NSException *ex) {
                FOXLog(@"error:%@",ex);
            }
        }
    }
    //设置启动状态
    started = true;
    
    return  [[Status alloc] initWithCode:Status.SUCCESS] ;
}
-(Status*)stop:(id)context monitor:(id<IProgressMonitorDelegate>)monitor{
    //设置关闭状态
     started = false;
    //获取代理加载器
    ProxyLoader* proxyLoader = [ProxyLoader getInstance];
    //清空代理
    [proxyLoader clear];
    return  [[Status alloc] initWithCode:Status.SUCCESS] ;
}
/**
 * 是否启动
 *
 * return
 */
-(BOOL)isStarted{
    return started;
}
@end
