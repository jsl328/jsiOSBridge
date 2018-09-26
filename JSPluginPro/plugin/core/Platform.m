//
//  Platform.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/12.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "Platform.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

//#import <GTSDK/GeTuiSdk.h>
#import "FoxEventDispatcher.h"
//#import "Platform+Push.h"
#import "ExtensionRegistry.h"
 #import "YXCreateAllList.h"
@interface Platform()
{
    
}
@property(strong)ExtensionRegistry* extensionRegistry;
@end
@implementation Platform

static Platform *_instance;
-(void)run{
 
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [YXCreateAllList createAllList];
    });
    
}
-(id)init{
    if(self=[super init]){
        self.eventDispatcher=[EventDispatcher new];
        self.settings=[NSMutableDictionary new];
        
        
    }
    return self;
}
+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}








/**
 * 获取扩展点注册表
 *
 * return
 */
-(ExtensionRegistry*)getExtensionRegistry{
    if(self.extensionRegistry==nil){
        self.extensionRegistry=[[ExtensionRegistry alloc] initWithRoot:[Platform getInstance].rootViewController];
    }
    return self.extensionRegistry;
}

+ (id)handleSysEvent:(FoxCoreSysEvent)evt withObject:(id)object{
    switch (evt) {
        case FoxCoreSysEventNetChange:
        {
            
            break;
        }
        case FoxCoreSysEventEnterBackground:/// 程序进入后台事件
        {
            
            break;
        }
        case FoxCoreSysEventEnterForeGround:/// 程序进入前台事件
        {
            
            break;
        }
        case FoxCoreSysEventOpenURL:/// 打开URL事件
        {
            
            break;
        }
        case FoxCoreSysEventRevLocalNotification:/// 本地自定义消息提醒
        {
            //[self localNotificationHandle:object];
            break;
        }
        case FoxCoreSysEventRevRemoteNotification:/// APNS事件
        {
            //[self remoteNotificationHandle:object];
            break;
        }
        case FoxCoreSysEventRevDeviceToken:/// 获取到APNS DeviceToken事件
        {
            //[self revDeviceTokenHandle:object];
            break;
        }
        case FoxCoreSysEventRegRemoteNotificationsError:/// 获取到APNS错误
        {
            
            break;
        }
        case FoxCoreSysEventReceiveMemoryWarning:/// 低内存警告
        {
            
            break;
        }
        case FoxCoreSysEventInterfaceOrientation:/// 屏幕旋转事件 Reserved
        {
            
            break;
        }
        case FoxCoreSysEventKeyEvent:/// 按键事件
        {
            
            break;
        }
        case FoxCoreSysEventEnterFullScreen:/// 全屏
        {
            
            break;
        }
        case FoxCoreSysEventPeekQuickAction:/// 点击了shortcut Reserved
        {
            
            break;
        }
        case FoxCoreSysEventResignActive:/// 应用暂停，被其他应用覆盖
        {
            
            break;
        }
        case FoxCoreSysEventBecomeActive:/// 应用被激活，重新处于活动状态
        {
            
            break;
        }
            
        default:
            break;
    }
    
    return  self;
}
- (id)handleSysEvent:(FoxCoreSysEvent)evt withObject:(id)object{
    return self;
}



@end
