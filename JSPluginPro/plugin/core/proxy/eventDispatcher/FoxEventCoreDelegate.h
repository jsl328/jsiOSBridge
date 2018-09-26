//
//  FoxEventCoreDelegate.h
//  YXBuilder
//
//  Created by BruceXu on 2018/1/8.
//  Copyright © 2018年 YUSYS. All rights reserved.
//
#import <JavaScriptCore/JavaScriptCore.h>
@class EventListener;
@class EventCustom;
@class Event;
@protocol FoxEventCoreDelegate <JSExport>
//创建自定义listner
JSExportAs (createCustomEventListner, - (EventListener*)createCustomEventListner:(NSString *)eventName  callback:(NSString *)callback);
//创建推送listner
JSExportAs (createPushEventListner, - (EventListener*)createPushEventListnerWithcallback:(NSString *)callback);
-(EventCustom*)createEventCustom:(NSString*)eventName;

JSExportAs (addEventListenerWithFixedPriority,-(void)addEventListenerWithFixedPriority:(EventListener*) listener fixedPriority:(int) fixedPriority);

-(void) dispatchEvent:(Event*) event;
-(void)removeListener:(EventListener*)listener;
@end

