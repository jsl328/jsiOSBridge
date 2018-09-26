//
//  FoxEventPushMessage.h
//  YXBuilder
//
//  Created by BruceXu on 2018/1/9.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FoxEvent.h"
@interface EventPushMessage : Event
-(NSString*)getMessageType;
-(void)setMessageType:(NSString*)messageType;
-(id)getMessage;
-(void)setMessage:(id)data;
@end
