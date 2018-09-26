//
//  BootManager.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "BootManager.h"
#import "IBootDelegate.h"
#import "IProgressMonitorDelegate.h"
#import "IExtensionPointDelegate.h"
#import "IConfigElementDelegate.h"
#import "Platform.h"
#import "IExtensionDelegate.h"
#import "Status.h"
#import "SubProgressMonitor.h"
#import "YXPlugin.h"
#import "AlertDialog.h"
/**
 * 启动模块
 */
@interface BootModule:NSObject
@property(copy)NSString *text;
@property(weak)id<IBootDelegate>boot;

@end
@implementation BootModule

@end


@implementation BootManager
+(NSString*)BOOT_POINT{
    return @"fox.boot";
    
}
static NSMutableDictionary<NSString*,BootModule*> *bootMap;
+(NSArray<Status*>*)load:(id)root monitor:(id<IProgressMonitorDelegate>)monitor{
    
    //一次初始化
    bootMap=[NSMutableDictionary<NSString*,BootModule*> new ];
    // 配置map
    NSMutableDictionary<NSString *,id<IConfigElementDelegate>>*configMap=[NSMutableDictionary<NSString *,id<IConfigElementDelegate>> new];
    //依赖关系映射
    NSMutableDictionary<NSString *,NSArray<NSString*>*>*relationMap=[NSMutableDictionary<NSString *,NSArray<NSString*>*> new];
    
    // 加载startup扩展点
    id<IExtensionPointDelegate> point=[[[Platform getInstance] getExtensionRegistry] getExtensionPoint:BootManager.BOOT_POINT];
    ////获取数组里所有的【<extension point="fox.boot">，<extension point="fox.boot">】
    NSArray<id<IExtensionDelegate>>*extensions=[point getExtensions];
    FOXLog(@"%@",extensions);
    
    /*
     *
     * 参考：
     * <extension point="fox.boot">
     <boot name="versionUpdate" class="fox.core.version.VersionManager" text="版本管理器">
     </boot>
     <boot name="evnReady" class="fox.core.environment.EnvReady" text="环境准备器">
     <depend name="versionUpdate"></depend>
     </boot>
     <boot name="proxyLoader" class="fox.core.proxy.ProxyLauncher" text="代理加载器">
     <depend name="versionUpdate"></depend>
     </boot>
     </extension>
     
     *
     * */
    for (id<IExtensionDelegate> e in  extensions) {
        NSArray<id<IConfigElementDelegate>>* nodes = [e getConfigElements];//[<boot>,<boot>]
        for (id<IConfigElementDelegate> node in nodes) {
            NSString* name = [node getAttribute:@"name"];//versionUpdate or evnReady or proxyLoader
            [configMap setObject:node forKey:name];
            NSMutableArray<NSString*>*dependSet=[NSMutableArray<NSString*> new];
            // 依赖关系set
            NSArray<id<IConfigElementDelegate>>* children = [node getChildren:@"depend"];//[ <depend name="versionUpdate"></depend>,....]
            // 读取依赖关系
            for (id<IConfigElementDelegate> child in children) {
                NSString* depend = [child getAttribute:@"name"];
                [dependSet addObject :depend ];
            }
            [relationMap setObject:dependSet forKey:name];//{"evnReady"：[versionUpdate,....]} 依赖字典
            
        }
    }
    // 检查依赖关系的合法性
    // 加载顺序队列
    NSMutableArray<NSString*>* loadRelationList =[NSMutableArray<NSString*> new ];
    for (NSString *name in relationMap.allKeys) {
        // 判断是否已经已经检查
        if ([loadRelationList containsObject:name]) {
            continue;
        }
        NSMutableArray<NSArray<NSString*>*>* checkedRelationSet = [NSMutableArray<NSArray<NSString*>*> new ];
        @try {
            //参数： evnReady，{"evnReady"：[versionUpdate,....],"versionUpdate":[..]},集合空，集合空
            //checkAndConstructDependRelation(name, relationMap, checkedRelationSet, loadRelationList);
        [self checkAndConstructDependRelation:name relationMap:relationMap checkedRelationSet: checkedRelationSet loadRelationList:loadRelationList];
        
        } @catch (NSException* e) {
            FOXLog(@"%@",e);
            //返回启动失败
            Status *state =  [[Status alloc] initWithCode:Status.FAIL];
            
            return  [(NSArray<Status*>*)(@[state]) copy];
        }
    }
    
    if (loadRelationList.count > 0) {//里面是顺序加载的类
        
        // 任务数量
        int count = (int)loadRelationList.count;
        // 获取子任务量
        int subWork = 100 / count;
        
        //记录启动状态
        NSMutableArray<Status*>* status = [NSMutableArray<Status*> new];
        
        for (int i = 0; i < count; i++) {
            // 获取boot模块的名称
            NSString* name = loadRelationList[i];
            //获取配置
            //e 比如=<boot name="versionUpdate" class="fox.core.version.VersionManager" text="版本管理器"> </boot>
            
           id<IConfigElementDelegate> e = configMap[name];//configMap.name=//versionUpdate or evnReady or proxyLoader
            //获取text
            NSString* text = [e getAttribute:@"text"];//版本管理器  环境准备器  代理加载器
            if (text == nil) {
                text = name;
            }
            // 定义子启动进程monitor
            SubProgressMonitor* subProgressMonitor =  [[SubProgressMonitor alloc]initMonitor:monitor subWork:subWork ];
            
 
            NSString *msg=[NSString stringWithFormat:@"加载%@",text];
            
            //打印日志
            FOXLog(@"%@",msg);
            
            [subProgressMonitor setTaskName:msg];
            
            @try {
                //获取类名
                NSString* className = [e getAttribute:@"class"];
                //获取class
                Class clazz = NSClassFromString(className);
              
                //创建boot对象
                SEL sel = NSSelectorFromString(@"new");
                id classInstance = [(id)clazz performSelector:sel];

                if(!classInstance){
                    continue;
                }
                id<IBootDelegate> boot = (id<IBootDelegate>)classInstance;
             
                //启动boot
                Status* state = [boot start:root  monitor:subProgressMonitor];
                if ([state resultCode] == Status.FAIL) {
                    return  [(NSArray<Status*>*)(@[state]) copy];
                }
                if ([state resultCode] == Status.EXIT) {
                    return  [(NSArray<Status*>*)(@[state]) copy];
                }
                //加入队列
                [status addObject:state];

                //定义启动模块
                BootModule* bootModule =   [BootModule new];
                bootModule.text = text;
                bootModule.boot = boot;

                // 加入预启动列表
                [bootMap setObject:bootModule forKey:name] ;

                //拼装日志
                NSString *msg=[NSString stringWithFormat:@"加载%@完成",text];
                FOXLog(@"%@",msg);
               
               
//
            } @catch (NSException* ex) {
                FOXLog(@"error:%@",ex);
                //提示
                NSString* message =[NSString stringWithFormat:@"加载启动模块失败 cause: %@" , ex ];
                [AlertDialog  show:@"提示" message:message buttonTexts:@[@"退出"]
                      buttonValues:@[@0]];
                
                Status *state =  [[Status alloc] initWithCode:Status.FAIL];
                return  [(NSArray<Status*>*)(@[state]) copy];
            } @finally {
               
                [subProgressMonitor done];
            }
        }
        //返回结果
        return status;
    }
    //返回空的状态
   return [(NSArray<Status*>*)(@[]) copy];
}
+(void)checkAndConstructDependRelation:(NSString*)name relationMap:(NSDictionary<NSString*,NSArray<NSString*>*>*)relationMap checkedRelationSet:(NSMutableArray<NSArray<NSString*>*>*)checkedRelationSet loadRelationList:(NSMutableArray<NSString*>*)loadRelationList{
    // 获取模块的依赖set
    NSArray<NSString*>* dependSet = relationMap[name];
    if (dependSet != nil) {
        // 判断是否存在循环依赖关系
        if ([checkedRelationSet containsObject:dependSet]) {
            FOXLog(@"%@",[NSString stringWithFormat:@"error:预启动模块存在循环依赖关系，请检查预启动模块[%@]的依赖关系",name]);
            return;
        }
        
        // 加入已经检查relation set
        [checkedRelationSet addObject:dependSet];
        
        
        // 检查依赖关系的合法性
        for (NSString *depend in dependSet) {
            if (![[relationMap allKeys] containsObject:depend]) {
                 FOXLog(@"%@",[NSString stringWithFormat:@"error:预启动模块['%@'],没有注册",depend]);
                return;
            
            } else if ([name isEqualToString:depend]) {//依赖自己
                
               FOXLog(@"%@",[NSString stringWithFormat:@"error:预启动模块存在循环依赖关系，请检查预启动模块['%@']的依赖关系",depend]);
                return;
            }
            // 迭代检查
            [self checkAndConstructDependRelation:depend relationMap:relationMap checkedRelationSet: checkedRelationSet loadRelationList:loadRelationList];
        }
    }
    
    // 加入加载顺序队列
    if (![loadRelationList containsObject:name]) {
        [loadRelationList addObject:name];
    }
}



+(NSArray<Status*>*)unload:(id)root monitor:(id<IProgressMonitorDelegate>)monitor{
    // 获取启动模块数量
    int count = (int)bootMap.count;
    //记录结果
    NSMutableArray<Status*>* status = [NSMutableArray<Status*> new];
    
    // 定义卸载顺序队列
    NSMutableArray<NSString*>* unLoadRelationList =  [NSMutableArray<NSString*> new ];
   
    for (NSString *name in bootMap.allKeys) {
        [unLoadRelationList insertObject:name atIndex:0];
    }
    
    // 获取子任务量
    int subWork = 100 / count;
    // 卸载预启动模块
    for (int i = 0; i < unLoadRelationList.count; i++) {
        // 获取卸载模块名称
        NSString *name = unLoadRelationList[i];
        //获取卸载模块
        BootModule *bootModule = bootMap[name];
        
        // 定义子启动进程monitor
        SubProgressMonitor *subProgressMonitor = [[SubProgressMonitor alloc] initMonitor:monitor subWork:subWork];
        
        NSString *text=[NSString stringWithFormat:@"卸载:%@",bootModule.text];
        [subProgressMonitor setTaskName:text];
       
        
        
        @try {
            if (!bootModule.boot.isStarted) {
                continue;
            }
            // 关闭模块
            id mode=  [bootModule.boot stop:root monitor:subProgressMonitor];
            if(mode)
            [status addObject: mode];
        } @catch (NSException* e) {
            FOXLog(@"error:%@",e);
        } @finally {
            [subProgressMonitor done];
        }
    }
    //清空启动boot模块
    [bootMap removeAllObjects];
    return status;
}














@end



