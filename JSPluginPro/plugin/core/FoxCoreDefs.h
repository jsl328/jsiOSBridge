//
//  FoxCoreDefs.h
//  YXBuilder
//
//  Created by BruceXu on 2018/1/3.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#ifndef FoxCoreDefs_h
#define FoxCoreDefs_h

/// 系统事件类型定义
typedef NS_ENUM(NSInteger, FoxCoreSysEvent) {
    /// 网络状态改变事件 Reserved
    FoxCoreSysEventNetChange = 0,
    /// 程序进入后台事件
    FoxCoreSysEventEnterBackground = 1,
    /// 程序进入前台事件
    FoxCoreSysEventEnterForeGround = 2,
    /// 打开URL事件
    FoxCoreSysEventOpenURL = 3,
    /// 本地自定义消息提醒
    FoxCoreSysEventRevLocalNotification = 4,
    /// APNS事件
    FoxCoreSysEventRevRemoteNotification = 5,
    /// 获取到APNS DeviceToken事件
    FoxCoreSysEventRevDeviceToken = 6,
    /// 获取到APNS错误
    FoxCoreSysEventRegRemoteNotificationsError = 7,
    /// 低内存警告
    FoxCoreSysEventReceiveMemoryWarning = 8,
    /// 屏幕旋转事件 Reserved
    FoxCoreSysEventInterfaceOrientation = 9,
    /// 按键事件
    FoxCoreSysEventKeyEvent = 10,
    /// 全屏
    FoxCoreSysEventEnterFullScreen = 11,
    /// 点击了shortcut Reserved
    FoxCoreSysEventPeekQuickAction = 12,
    /// 应用暂停，被其他应用覆盖
    FoxCoreSysEventResignActive = 13,
    /// 应用被激活，重新处于活动状态
    FoxCoreSysEventBecomeActive = 14
};

#endif /* FoxCoreDefs_h */
