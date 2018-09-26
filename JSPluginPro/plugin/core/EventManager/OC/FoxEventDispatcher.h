//
//  FoxEventDispatcher.h
//  YXBuilder
//
//  Created by BruceXu on 2018/1/7.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "FoxEventObject.h"
#import "FoxEventCustom.h"

#import "FoxEventListenerCustom.h"
@class EventListenerVector;
typedef bool(^EventListenerCallBack)(EventListener* listener);
@interface EventDispatcher : EventObject

-(void)addEventListener:(EventListener*) listener;


-(void)addEventListenerWithFixedPriority:(EventListener*) listener fixedPriority:(int) fixedPriority;


-(EventListenerCustom*) addCustomEventListener:( NSString *)eventName callback:(EventCustomCallBack)callback;

-(void) removeEventListener:(EventListener*) listener;

-(void)setPriority:(EventListener*) listener fixedPriority:(int) fixedPriority;

-(void )dispatchEventToListeners:(EventListenerVector*) listeners callback: (EventListenerCallBack) onEvent;
-(void) dispatchEvent:(Event*) event;

-(void) dispatchCustomEvent:(NSString*)eventName userData:(id) optionalUserData;
-(BOOL)hasEventListener:(ListenerID) listenerID;


-(void)updateListeners:(Event*) event;

-(void) sortEventListeners:(ListenerID) listenerID;

-(void)sortEventListenersOfFixedPriority:(ListenerID) listenerID;
-(EventListenerVector*) getListeners:(ListenerID) listenerID;
-(void)removeEventListenersForListenerID:(ListenerID) listenerID;

-(void)removeCustomEventListeners:(NSString*) customEventName;
-(void) removeAllEventListeners;

-(void)releaseListener:(EventListener*) listener;



@end
