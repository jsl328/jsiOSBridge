//
//  FoxEventListenerPushMessage.h
//  YXBuilder
//
//  Created by BruceXu on 2018/1/9.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FoxEventListener.h"
#import "FoxEventPushMessage.h"
typedef void(^EventPushMessageCallBack)(EventPushMessage* type);

@interface EventListenerPushMessage : EventListener
-(id)init:(EventPushMessageCallBack)  callback;
+(EventListenerPushMessage*) create:(EventPushMessageCallBack)callback;
+(NSString*)LISTENER_ID;
@end
