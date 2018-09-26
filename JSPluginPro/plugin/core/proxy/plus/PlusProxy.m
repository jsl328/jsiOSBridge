//
//  PlusProxy.m
//  core
//
//  Created by guoxd on 2018/4/24.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import "PlusProxy.h"
#import "Platform.h"
#import "FoxCoreNativeDelegate.h"
#import "PlusDelegate.h"
#import "ObjectFactory.h"
#import "ScopeEnum.h"
#import "CallBackObject.h"
@interface PlusModule:NSObject
@property(copy)NSString *className;//方法关联的类名
@property(copy)NSString *scope;//
@property(assign) int priority;
@end
@implementation PlusModule
@end

@interface PlusProxy () <NSXMLParserDelegate, FoxCoreNativeDelegate>

/*
 方法名
 */
@property (nonatomic, copy) NSString *action;

/*
 参数
 */
@property (nonatomic, strong) NSDictionary *params;

/*
 回调
 */
@property (nonatomic, copy) NSString *callback;


@property(strong)NSMutableDictionary<NSString*,PlusModule*> *plusMap;

@end
//DeviceProx 拖进对应文件夹
@implementation PlusProxy

+(NSString*)PLUS_POINT{
    return @"fox.plus";
}
-(id)init{
    if(self=[super init]){
        self.plusMap=[NSMutableDictionary<NSString*,PlusModule*> new];
        [self loadModule];
    }
    return self;
}

-(void)loadModule{
    //获取Object factory
    // ObjectFactory objectFactory = ObjectFactory.getInstance();
    
    // 加载proxy扩展点
    id<IExtensionPointDelegate> point = [[[Platform getInstance] getExtensionRegistry] getExtensionPoint:PlusProxy.PLUS_POINT];
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
            int priority=0;
            NSString *s= [node getAttribute:@"priority"];
            if(s!=nil){
                priority=[s intValue];
            }
            
            //获取已经加入的native module,并判断是否要覆盖加入
            PlusModule *prePlusModule = self.plusMap[action];
            if(prePlusModule != nil && prePlusModule.priority >= priority){
                continue;
            }
            
            //定义native模块
            PlusModule* plusModule =  [PlusModule new];
            plusModule.className = className;
            plusModule.scope = scope;
            plusModule.priority = priority;
            //加入注册表
            [self.plusMap setObject:plusModule forKey:action];
            
        }
    }
}


- (void)callWithAction:(NSString *)action params:(NSString *)params callback:(NSString *)callback {
    CallBackObject *fn=[[CallBackObject alloc] initWithRunBlock:^(int code,NSString *message,id data){
        [[Platform getInstance].webViewBridge executeJs:callback params:@[@(code), message, data] ];
        
    }];
    [self call:action param:params callback:fn];
    
}


/**
 * 调用native接口
 *
 * param type
 * param action
 * param param
 * param callback
 */
-(void) call:(NSString*) action
       param:(NSString*) param  callback:(CallBackObject*) callback {
    //获取native模块
    PlusModule *module =  self.plusMap[action];
    
    //定义prototype
    NSString *scope=ScopeEnum.prototype;
    if ([@"singleton" isEqualToString:module.scope]) {
        scope = ScopeEnum.singleton;
    }
    @try {
        //获取device接口
        id<PlusDelegate> device = (id<PlusDelegate>) [[ObjectFactory getInstance] get:module.className Scope:scope];
        //调用接口
        if(device){
            [device call:action param:param callback:callback];
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
