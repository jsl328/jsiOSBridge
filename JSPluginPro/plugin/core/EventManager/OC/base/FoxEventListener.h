//
//  FoxEventListener.h
//  YXBuilder
//
//  Created by BruceXu on 2018/1/7.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "FoxEventObject.h"
#import "FoxEvent.h"

typedef NSString * ListenerID;
typedef void(^EventCallBack)(Event* type);

@interface EventListener : EventObject

@property(assign) BOOL isEnabled;
@property(assign) BOOL isRegistered;
@property(copy) ListenerID listenerID;
@property(assign) int   fixedPriority;
@property(strong) EventObject* node;
@property(assign) int type;

//执行完回调之后是否移除，比如推送回调之后，下次仍可回调
@property(assign)BOOL keepAlive;
@property(copy) EventCallBack onEvent;

-(id)init:(int)type listenerID:(ListenerID)listenerID callback:(EventCallBack)callback;

-(BOOL)checkAvailable;


-(EventListener*) clone;


-(void) setEnabled:(bool) enabled;


-(BOOL)isEnabled;

/** 把监听注册到 EventDispatcher */
-(void) setRegistered:(BOOL) registered ;

/** 监测监听是否注册到 EventDispatcher */
-(BOOL)isRegistered ;

/**
 *    得道监听类型
 */
-(int) getType ;

/**
 *  获取监听ID
 */
-(ListenerID) getListenerID;

/**
 *  设置执行优先级，越大优先级越高，最小为1
 *
 */
-(void) setFixedPriority:(int) fixedPriority ;

/**
 *   得道执行优先级
 */
-(int) getFixedPriority ;

//设置关联对象
-(void) setAssociatedNode:(EventObject*) node ;

//得道关联对象
-(EventObject*) getAssociatedNode ;




@end
