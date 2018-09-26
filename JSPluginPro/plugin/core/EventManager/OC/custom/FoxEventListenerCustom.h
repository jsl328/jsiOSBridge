//
//  FoxEventListenerCustom.h
//  YXBuilder
//
//  Created by BruceXu on 2018/1/7.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "FoxEventListener.h"
#import "FoxEventCustom.h"
typedef void(^EventCustomCallBack)(EventCustom* type);


@interface EventListenerCustom : EventListener
-(id)init:(ListenerID) listenerId callback:(EventCustomCallBack)  callback;
+(EventListenerCustom*) create:(NSString*)eventName callback:(EventCustomCallBack)callback;
@end
