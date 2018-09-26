//
//  Platform.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/12.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtensionRegistry.h"
#import "IWebViewBridgeDelegate.h"
#import "UIEventExecutorDelegate.h"
#import "FoxCoreDefs.h"
@class EventDispatcher;
@interface Platform : NSObject
+ (instancetype)getInstance;
@property (nonatomic, strong) NSMutableDictionary* settings;
-(ExtensionRegistry*)getExtensionRegistry;
@property(weak)id rootViewController;
@property(strong) id<IWebViewBridgeDelegate>webViewBridge;
@property(weak) id<UIEventExecutorDelegate> uiEventExecutor;
@property(strong) EventDispatcher *eventDispatcher;

//推送token
@property(copy)  NSString*token;

-(void)run;

/// @brief 通知runtime处理指定的事件
+ (id)handleSysEvent:(FoxCoreSysEvent)evt withObject:(id)object;
- (id)handleSysEvent:(FoxCoreSysEvent)evt withObject:(id)object;
@end
