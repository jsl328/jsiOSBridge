//
//  EventDispatcherProxy.m
//  YXBuilder
//
//  Created by BruceXu on 2018/1/8.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "EventDispatcherProxy.h"
#import "Platform.h"
//EventCustom代理
@protocol EventCustomDelegate <JSExport>
-(void) setUserData:(id) data;
-(id) getUserData;
@end

@interface EventCustom(EventCustomCore)<EventCustomDelegate>
@end
@implementation EventCustom(EventCustomCore)
@end



@interface EventDispatcherProxy()<FoxEventCoreDelegate>{
    
    
}

@end
@implementation EventDispatcherProxy
//创造自定义事件
- (EventListener*)createCustomEventListner:(NSString *)eventName  callback:(NSString *)callback{
   
    EventListenerCustom * listener=nil;
    void(^callbackBlock)(EventCustom* event) = ^(EventCustom* event){
    
        [[Platform getInstance].webViewBridge executeJs:callback params:@[@(0), @"", [event toDescriptionDic]] ];
    };
    listener= [EventListenerCustom create:eventName callback:callbackBlock];
    
    return listener;
    
    
    
}
- (EventListener*)createPushEventListnerWithcallback:(NSString *)callback{
    
    EventListenerPushMessage * listener=nil;
    void(^callbackBlock)(EventPushMessage* event) = ^(EventPushMessage* event){
        NSDictionary *dic=[event toDescriptionDic];
        [[Platform getInstance].webViewBridge executeJs:callback params:@[@(0), @"", dic] ];
    };
    listener= [EventListenerPushMessage create:callbackBlock];
    return listener;
}

//事件添加
-(void)addEventListenerWithFixedPriority:(EventListener*) listener fixedPriority:(int) fixedPriority{
     EventDispatcher *dispatcher=[Platform getInstance].eventDispatcher;
     [dispatcher addEventListenerWithFixedPriority:listener fixedPriority:fixedPriority];
    
    if([listener isKindOfClass:[EventListenerPushMessage class]]){
        //开启推送
        // [GeTuiSdk setPushModeForOff:NO];
    }
    
}
//创建EventCustom对象
-(EventCustom*)createEventCustom:(NSString*)eventName{
    return [[EventCustom alloc] initWithName:eventName];
}
//分发事件
-(void) dispatchEvent:(Event*) event{
    EventDispatcher *dispatcher=[Platform getInstance].eventDispatcher;
    [dispatcher dispatchEvent:event];
}
//移除事件
-(void)removeListener:(EventListener*)listener{
    if(listener){
        EventDispatcher *dispatcher=[Platform getInstance].eventDispatcher;
        [dispatcher removeEventListener:listener];
    }
}


@end
