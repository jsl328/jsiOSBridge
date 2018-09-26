//
//  FoxEventListenerPushMessage.m
//  YXBuilder
//
//  Created by BruceXu on 2018/1/9.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "FoxEventListenerPushMessage.h"
@interface EventListenerPushMessage(){
    
}

@property(copy)EventPushMessageCallBack  onPushEvent;
@end

@implementation EventListenerPushMessage
static const NSString* LISTENER_ID=@"fox_pushmessage_event";

-(id)init:(EventPushMessageCallBack)  callback{
   
    
    _onPushEvent = callback;
    
    id listener=^(Event* event){
        if(self.onPushEvent){
            self.onPushEvent((EventPushMessage*)event);
        }
    };
    
    if([super init:PUSHMESSAGE listenerID:(NSString*)LISTENER_ID callback:listener]){
        self.keepAlive=YES;
    }
    
    return self;
}
+(EventListenerPushMessage*) create:(EventPushMessageCallBack)callback{
    EventListenerPushMessage* ret =   [EventListenerPushMessage new];
    if([ret init:callback]){
        
    }
    
    return ret;
}
+(NSString*)LISTENER_ID{
    return (NSString*)LISTENER_ID;
}
-(BOOL)checkAvailable
{
    bool ret = false;
    if ( [super checkAvailable] && self.onPushEvent != nil)
    {
        ret = true;
    }
    return ret;
    
}
@end
