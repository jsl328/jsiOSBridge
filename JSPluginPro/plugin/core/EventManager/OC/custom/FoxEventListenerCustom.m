//
//  FoxEventListenerCustom.m
//  YXBuilder
//
//  Created by BruceXu on 2018/1/7.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "FoxEventListenerCustom.h"
#import "FoxEvent.h"
@interface  EventListenerCustom(){
    
}
@property(copy)EventCustomCallBack  onCustomEvent;
@end

@implementation EventListenerCustom

+(EventListenerCustom*) create:(NSString*)eventName callback:(EventCustomCallBack)callback
{
    EventListenerCustom* ret =   [EventListenerCustom new];
    if([ret init:eventName  callback:callback]){
        
    }
    
    return ret;
}

-(id)init:(ListenerID) listenerId callback:(EventCustomCallBack)  callback
{
    bool ret = false;
    
    _onCustomEvent = callback;
    
 id listener=^(Event* event){
        if(self.onCustomEvent){
            self.onCustomEvent((EventCustom*)event);
        }
    };
    
    if([super init:CUSTOM listenerID:listenerId callback:listener]){
        ret=YES;
    }
    
    return self;
}

-(EventListenerCustom*) clone
{
    EventListenerCustom* ret =   [EventListenerCustom new];
    if([ret init:self.listenerID callback:self.onCustomEvent]){
        
    }
    
    return ret;
    
}

-(BOOL)checkAvailable
{
    bool ret = false;
    if ( [super checkAvailable] && self.onCustomEvent != nil)
    {
        ret = true;
    }
    return ret;
    
}
-(void)dealloc{
    int iii=0;
    
}
@end
