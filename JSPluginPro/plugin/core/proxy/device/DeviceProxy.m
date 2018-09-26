//
//  DeviceProxy.m
//  YXBuilder
//
//  Created by LiYuan on 2017/12/11.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "DeviceProxy.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "DeviceMap.h"
#import "DeviceTypeMap.h"
#import "Platform.h"
#import "ConfigPreference.h"
#import "ICallBackDelegate.h"
#import "ScopeEnum.h"
#import "ObjectFactory.h"
#import "IDeviceDelegate.h"
#import "CallBackObject.h"
#import "FoxDeviceCoreDelegate.h"
#import "JBridgeEventHandler.h"



@interface DeviceModule:NSObject
/**
 * device id
 */
@property(copy) NSString* deviceId;

/**
 * deviceName
 */
@property(copy) NSString*  deviceName;

/**
 * 蓝牙名
 */
@property(copy) NSString*  bluetoothName;

/**
 * device type
 */
@property(copy) NSString*  type;

/**
 * device type name
 */
@property(copy) NSString*  typeName;

/**
 * 类名
 */
@property(copy) NSString*  className;

/**
 * 范围
 */
@property(copy) NSString*  scope;

@end

@implementation DeviceModule
@end



@interface DeviceProxy () <FoxDeviceCoreDelegate>

@property (strong, nonatomic) JSManagedValue *callback;
/**
 * native map
 */
@property(strong) NSDictionary<NSString*,NSMutableArray<DeviceModule*>*>*deviceRegister;
/**
 * 外设类型映射
 */
@property(strong) DeviceTypeMap* deviceTypeMapping;
/**
 * 外设映射
 */
@property(strong) DeviceMap *deviceMapping;
@end

@implementation DeviceProxy

+(NSString*)DEVICE_POINT{
    return @"fox.device";
}

-(id)init{
    if(self=[super init]){
         //设备类型map映射
        self.deviceTypeMapping=[DeviceTypeMap new];
       
        self.deviceMapping=[DeviceMap new];
        
        self.deviceRegister=[self loadDeviceExtension:self.deviceTypeMapping];
        }
    return self;
}
/**
 * 加载设备扩展点
 *
 * param deviceTypeMapping
 * return
 */
-(NSDictionary<NSString*, NSMutableArray<DeviceModule*>*>*) loadDeviceExtension:(DeviceTypeMap*) deviceTypeMapping {
   
    //定义device mapping
    NSMutableDictionary<NSString*, NSMutableArray<DeviceModule*>*>* deviceMap = [NSMutableDictionary<NSString*, NSMutableArray<DeviceModule*>*> new ];
    
        // 加载proxy扩展点
        id<IExtensionPointDelegate> point = [[[Platform getInstance] getExtensionRegistry] getExtensionPoint:[DeviceProxy DEVICE_POINT]];
        NSArray<id<IExtensionDelegate>>* extensions = [point getExtensions];
        for (id<IExtensionDelegate> e in  extensions) {
            //获取父亲brand
           // NSString* parentBrand = [e getAttribute:@"brand"];
            NSArray<id<IConfigElementDelegate>>* nodes = [e getConfigElements];
            for (id<IConfigElementDelegate> node in nodes) {
                //获取device类型
                NSString* type = [node getAttribute:@"type"];
                //NSLog(@"type==%@",type);
                //device类型名称
                NSString* typeName = [deviceTypeMapping get:type];
                //NSLog(@"typeName==%@",typeName);
                //判断device type mapping是否存在外设类型
                if (typeName == nil) {
                    //获取device类型名称
                    typeName = [node getAttribute:@"typeName"];
                    typeName = (typeName == nil ? @"未知设备" : typeName);
                    //加入新的type类型,放到沙盒中扩展文件configuration/deviceType_mapping.properties中
                    [deviceTypeMapping put:type typeName:typeName];
                }
                //获取外设ID
                NSString *devId = [node getAttribute:@"devId"];
                //获取外设名
                NSString *devName = [node getAttribute:@"devName"];
                //获取device类
                NSString *className = [node getAttribute:@"class"];
                //获取scope
                NSString* scope = [node getAttribute:@"scope"];
                //获取蓝牙名称
                NSString *bluetoothName = [node getAttribute:@"bluetoothName"];
                
                //定义device模块
                DeviceModule *deviceModule = [DeviceModule new];
                deviceModule.type = type;
                deviceModule.typeName = typeName;
                deviceModule.deviceId = devId;
                deviceModule.bluetoothName = bluetoothName;
                deviceModule.deviceName = devName;
                deviceModule.className = className;
                deviceModule.scope = scope;
                
                //获取deviceModule队列
                NSMutableArray<DeviceModule*>* deviceModules = deviceMap[type];
                if (deviceModules == nil) {
                    deviceModules =  [NSMutableArray<DeviceModule*> new ];
                    [deviceMap setObject:deviceModules forKey:type];
                }
                //加入队列
                [deviceModules addObject:deviceModule];
            }
        }
    
    return deviceMap;
}

/**
 * 查找device module
 *
 * param type
 * return
 */
-(DeviceModule*) findDeviceModule:(NSString*) type {
    //获取device模块独立
    NSArray<DeviceModule*>* modules = _deviceRegister[type];
    if (modules == nil) {
        return nil;
    }
    
    //获取当前使用的外设ID
    NSString* deviceId = nil;
   
    deviceId = [self.deviceMapping get:type];
    //获取队列大小
    int size = (int)modules.count;
    //选中模块
    DeviceModule* selectedModule = nil;
    if (size > 0) {
        //获取默认模块
        selectedModule = modules[0];
        
        if (deviceId == nil) {
            //获取preference
            ConfigPreference *pref = [ConfigPreference getInstance];
            //是否自动查找
            BOOL autoSearch  =[pref getBoolean:@"device" key:@"autoSearch" defaultValue:true];
            
            if (autoSearch) {//蓝牙，暂时用不到
            }
        } else {
            //循环查找
            for (int i = 0; i < size; i++) {
                DeviceModule* module = modules[i];
                if([deviceId isEqualToString:(module.deviceId)])  {
                    selectedModule = module;
                    break;
                }
            }
        }
    }
    return selectedModule;
}

/**
 * 调用device接口
 *
 * param type
 * param action
 * param param
 * param callback
 */
-(void) call:(NSString *)type action: (NSString*) action
       param:(NSString*) param  callback:(CallBackObject*) callback {
    //获取device模块
    DeviceModule *module = [self findDeviceModule:type];
    if (module ==nil) {
        NSString * errorMsg = [NSString stringWithFormat:@"the device type[%@] 不存在",type ];
        FOXLog(@"%@",errorMsg);
        [callback run:CallBackObject.ERROR message:errorMsg data:@""];
        return;
    } else {
         NSString * msg = [NSString stringWithFormat:@"call device type[%@],id[%@],name[%@]",type ,module.deviceId,module.deviceName];
         FOXLog(@"%@",msg);
    }
    //定义prototype
    NSString *scope=ScopeEnum.prototype;
    if ([@"singleton" isEqualToString:module.scope]) {
        scope = ScopeEnum.singleton;
    }
    @try {
        //获取device接口
        id<IDeviceDelegate> device = (id<IDeviceDelegate>) [[ObjectFactory getInstance] get:module.className Scope:scope];
        
        //传入方法名调用接口,保存callbackid
        [device call:type action:action param:param  callback:callback];
        
        //分发消息到指定对象的方法
        //[[JBridgeEventHandler shareInstance]interfaceDeviceClass:device withAction:action params:param callback:callback];
    } @catch (NSException * e) {
        //打印日志
        FOXLog(@"error:%@",e);
        //NSString *fff=  NSHomeDirectory();
        //错误回调
        [callback run:CallBackObject.ERROR message:e.reason data:@"" ];
    }
}

- (void)callWithType:(NSString *)type action:(NSString *)action params:(NSString *)params callback:(NSString *)callback {
    // type == camera; action == front
    CallBackObject *fn =[[CallBackObject alloc]initWithCallback:callback];
//    CallBackObject *fn=[[CallBackObject alloc] initWithRunBlock:^(int code,NSString *message,id data){
//        //if(!data)data=@"";
//         //[[Platform getInstance].webViewBridge executeJs:callback params:@[@(code), message, data] ];
//    }];
    [self call:type action:action param:params callback:fn];
}
@end
