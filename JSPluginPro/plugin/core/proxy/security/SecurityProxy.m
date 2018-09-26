//
//  SecurityProxy.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/14.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "SecurityProxy.h"
#import "Platform.h"
#import "FoxCoreSecurityDelegate.h"
#import "ISecurityDelegate.h"
#import "ObjectFactory.h"
#import "ScopeEnum.h"
#import "CallBackObject.h"
#import "YXPlugin.h"
@interface SecurityModule : NSObject

@property (copy, nonatomic) NSString *className;
@property (copy, nonatomic) NSString *scope;
@property (assign, nonatomic) int priority;

@end

@implementation SecurityModule

@end

@interface SecurityProxy () <FoxCoreSecurityDelegate>

@property(strong, nonatomic) NSMutableDictionary<NSString*,SecurityModule*> *securityMap;

@end
@implementation SecurityProxy

+ (NSString*)SECURITY_POINT {
    return @"fox.security";
}
- (id)init {
    
    if (self = [super init]) {
        self.securityMap = [NSMutableDictionary<NSString*,SecurityModule*> new];
        [self loadModule];
    }
    return self;
}

-(void)loadModule{
    
    // 加载proxy扩展点
    id<IExtensionPointDelegate> point = [[[Platform getInstance] getExtensionRegistry] getExtensionPoint:SecurityProxy.SECURITY_POINT];
    NSArray<id<IExtensionDelegate>>* extensions = [point getExtensions];
    for (id<IExtensionDelegate> e in  extensions) {
        NSArray<id<IConfigElementDelegate>> * nodes = [e getConfigElements];
        for (id<IConfigElementDelegate> node in nodes) {
            //获取native名称
            NSString* action = [node getAttribute:@"action"];
            //获取native类
            NSString *className = [node getAttribute:@"class"];
            //获取scope
            NSString *scope = [node getAttribute:@"scope"];
            //获取优先级
            int priority = 0;
            NSString *s = [node getAttribute:@"priority"];
            if(s != nil){
                priority = [s intValue];
            }
            
            //获取已经加入的native module,并判断是否要覆盖加入
            SecurityModule *preNativeModule = self.securityMap[action];
            if(preNativeModule != nil && preNativeModule.priority >= priority){
                continue;
            }
            
            //定义native模块
            SecurityModule* securityModule =  [SecurityModule new];
            securityModule.className = className;
            securityModule.scope = scope;
            securityModule.priority = priority;
            //加入注册表
            [self.securityMap setObject:securityModule forKey:action];
            
        }
    }
}

- (void)callWithAction:(NSString *)action params:(NSDictionary *)params callback:(NSString *)callback {
    CallBackObject *fn=[[CallBackObject alloc] initWithRunBlock:^(int code,NSString *message,id data){
        [[Platform getInstance].webViewBridge executeJs:callback params:@[@(code), message, data] ];
    }];
    [self call:action params:params callback:fn];
}


/**
 * 调用native接口
 *
 * param type
 * param action
 * param param
 * param callback
 */
- (void)call:(NSString*)action
       params:(NSDictionary*)params callback:(CallBackObject*)callback {
    //获取device模块
    SecurityModule *module =  self.securityMap[action];
    
    //定义prototype
    NSString *scope=ScopeEnum.prototype;
    if ([@"singleton" isEqualToString:module.scope]) {
        scope = ScopeEnum.singleton;
    }
    @try {
        //获取device接口
        id<ISecurityDelegate> device = (id<ISecurityDelegate>) [[ObjectFactory getInstance] get:module.className Scope:scope];
        //调用接口
        if(device){
            [device call:action params:params callback:callback];
        }
        else{
            FOXLog(@"error:%@",@"本地对象不存在");
            [callback run:CallBackObject.ERROR message:@"本地对象不存在" data:@"" ];
        }
    } @catch (NSException * e) {
        //打印日志
        FOXLog(@"error:%@",e);
        //错误回调
        [callback run:CallBackObject.ERROR message:e.reason data:@"" ];
    }
}

@end
