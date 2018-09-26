//
//  FoxEventDispatcher.m
//  YXBuilder
//
//  Created by BruceXu on 2018/1/7.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "FoxEventDispatcher.h"
#import "FoxEventListener.h"
#import "FoxEventListenerPushMessage.h"
#import "Platform.h"
//#import "Platform+Push.h"
@interface EventListenerVector:NSObject{
    NSMutableArray<EventListener*>* _fixedListeners;
    int _gt0Index;
}
-(int)size;
-(bool) empty;
-(void)push_back:(EventListener*) listener;
-(void) clearFixedListeners;
-(void) clear;
-(NSMutableArray<EventListener*>*)getFixedPriorityListeners ;
-(int) getGt0Index;
-(void) setGt0Index:(int) index;
@end
@implementation EventListenerVector
-(id)init{
    if([super init]){
        _fixedListeners=nil;
        _gt0Index=0;
    }
    return self;
}
-(void)dealloc{
    if(_fixedListeners){
        [_fixedListeners removeAllObjects];
        _fixedListeners=nil;
    }
}
-(int) getGt0Index { return _gt0Index; }
-(void) setGt0Index:(int) index{ _gt0Index = index; }

-(NSMutableArray<EventListener*>*)getFixedPriorityListeners { return _fixedListeners; }
-(int)size{
    int ret=0;
    if(_fixedListeners){
        ret+=_fixedListeners.count;
    }
    return ret;
}

-(bool) empty
{
    return  (_fixedListeners == nil || _fixedListeners.count==0);
}

-(void)push_back:(EventListener*) listener
{
    
    if (_fixedListeners == nil)
    {
        _fixedListeners = [NSMutableArray<EventListener*> new ];
        
    }
    
    [_fixedListeners addObject:listener];
    
}
-(void) clearFixedListeners
{
    if (_fixedListeners)
    {
        NSMutableArray<EventListener*> *temp=[NSMutableArray<EventListener*> new];
        for(EventListener* listner in _fixedListeners){
            if(listner.keepAlive){
                [temp addObject:listner];
            }
        }
        [_fixedListeners removeAllObjects];
        if(temp){
            [_fixedListeners setArray:temp];
        }
        else{
             _fixedListeners = nil;
        }

    }
}
-(void) clear
{
    [self clearFixedListeners];
}


@end




@interface EventDispatcher(){
    /** Listeners map */
    NSMutableDictionary<ListenerID, EventListenerVector*>* _listenerMap;
}
@end
@implementation EventDispatcher
+(ListenerID) __getListenerID:(Event*) event
{
    ListenerID ret;
    switch ([event getType])
    {
            
        case CUSTOM:
        {
            EventCustom* customEvent = (EventCustom*)(event);
            ret = [customEvent getEventName];
            break;
        }
        case PUSHMESSAGE:{
            ret = EventListenerPushMessage.LISTENER_ID;
            break;
        }
           
        default:break;
    }
    
    return ret;
}

-(id)init{
    if(self=[super init]){
        _listenerMap=[NSMutableDictionary<ListenerID, EventListenerVector*> new];
    }
    return self;
}

-(void)addEventListener:(EventListener*) listener
{
   [self forceAddEventListener:listener];
}

-(void)forceAddEventListener:(EventListener*) listener
{
    EventListenerVector* listeners = nil;
     ListenerID listenerID = [listener getListenerID];
    id itr = _listenerMap[listenerID];
    if (itr == nil)
    {
        
        listeners =  [EventListenerVector new];
        [_listenerMap setObject:listeners forKey:listenerID];
    }
    else
    {
        listeners = itr;
    }
    
    [listeners push_back:listener];
    
    
}

-(void)addEventListenerWithFixedPriority:(EventListener*) listener fixedPriority:(int) fixedPriority
{
    
    if (![listener checkAvailable])
        return;
    
    //注册推送
    if([listener isKindOfClass:[EventListenerPushMessage class]]){
        //[Platform  registerPush];
    }
   
    
    
    
    [listener setAssociatedNode:nil];
    [listener setFixedPriority:fixedPriority];
    [listener setRegistered:true];
    
    
   [self addEventListener:listener];
}

-(EventListenerCustom*) addCustomEventListener:(  NSString *)eventName callback:(EventCustomCallBack)callback
{
    EventListenerCustom *listener =  [EventListenerCustom create:eventName callback:callback];
    [self addEventListenerWithFixedPriority:listener fixedPriority: 1];
    return listener;
}

-(void) removeEventListener:(EventListener*) listener
{
    if (listener == nil)
        return;
    
    __block bool isFound = false;
    void (^removeListenerInVector)(NSMutableArray<EventListener*>* listeners)
    =^(NSMutableArray<EventListener*>* listeners){
        if (listeners == nil)
            return;
        for (id iter in listeners)
        {
            EventListener* l = iter;
            if (l == listener)
            {
                
                [l setRegistered:false];
                if ([l getAssociatedNode] != nil)
                {
                    
                }
                
                [listeners removeObject:l];
                [self releaseListener:l];
                isFound = true;
                break;
            }
        }
        
    };
    
    
   for (id key in [_listenerMap allKeys])
    {
       id iter= _listenerMap[key];
        EventListenerVector* listeners = iter;
        NSMutableArray<EventListener*>* fixedPriorityListeners = [listeners getFixedPriorityListeners];
       
        removeListenerInVector(fixedPriorityListeners);
        if ([iter empty])
        {
            [_listenerMap removeObjectForKey:key];
        }
        if (isFound)
            break;
    }
    
    if (isFound)
    {
        [self releaseListener:listener];
    }
    
}
-(void)setPriority:(EventListener*) listener fixedPriority:(int) fixedPriority
{
    if (listener == nil)
        return;
    
    for (id key in [_listenerMap allKeys])
    {
        id iter= _listenerMap[key];
        id fixedPriorityListeners = [iter getFixedPriorityListeners];
        if (fixedPriorityListeners)
        {
           
            
            BOOL found =  [fixedPriorityListeners containsObject:listener];
            
            if (found)
            {
                
                if ([listener getFixedPriority] != fixedPriority)
                {
                    [listener setFixedPriority:fixedPriority];
                    
                }
                return;
            }
        }
    }
}

-(void )dispatchEventToListeners:(EventListenerVector*) listeners callback: (EventListenerCallBack) onEvent
{
    bool shouldStopPropagation = false;
    NSMutableArray<EventListener*>* fixedPriorityListeners = [listeners getFixedPriorityListeners];
    
    
    int i = 0;
   
    if (fixedPriorityListeners)
    {
        
        
        if ([fixedPriorityListeners count])
        {
            for (; i < [listeners getGt0Index]; ++i)
            {
                EventListener* l = fixedPriorityListeners[i];
                if ([l isRegistered] && onEvent(l))
                {
                    shouldStopPropagation = true;
                    break;
                }
            }
        }
    }
    
    
}
-(void) dispatchEvent:(Event*) event
{
    
    ListenerID listenerID = [EventDispatcher __getListenerID:event];
    
   [self sortEventListeners:listenerID];
    
    EventListenerVector* iter = _listenerMap[listenerID];
    if (iter)
    {
        id listeners = iter;
        
       bool (^onEvent)(EventListener* listener) =^bool(EventListener* listener){
            listener.onEvent(event);
           return NO;
        };
        
      [self dispatchEventToListeners:listeners callback:onEvent];
        
        
    }
    
    [self updateListeners:event];
}

-(void) dispatchCustomEvent:(NSString*)eventName userData:(id) optionalUserData
{
    EventCustom* ev =[[EventCustom alloc] initWithName:eventName];
    [ev setUserData:optionalUserData];
    [self dispatchEvent:ev];
}

-(BOOL)hasEventListener:(ListenerID) listenerID
{
    return [self getListeners:listenerID] != nil;
}


-(void)updateListeners:(Event*) event
{
    
    void (^onUpdateListeners)(ListenerID listenerID) =^(ListenerID listenerID){
        
        id listenersIter = _listenerMap[listenerID];
        if (!listenersIter)
            return;
        
        EventListenerVector* listeners =  listenersIter;
        
        NSMutableArray<EventListener*>* fixedPriorityListeners = [listeners getFixedPriorityListeners];
        
        
        
        if (fixedPriorityListeners)
        {
            for ( id iter in fixedPriorityListeners)
            {
                EventListener* l = iter;
                if (![l isRegistered])
                {
                    [fixedPriorityListeners removeObject:l];
                    [self releaseListener:l];
                }
               
            }
        }
        
        if (fixedPriorityListeners && fixedPriorityListeners.count)
        {
            [listeners clearFixedListeners];
        }
        
        };
    
       onUpdateListeners( [EventDispatcher __getListenerID:event]);
    
    
    
    
    for ( id iter in _listenerMap.allKeys )
    {
        EventListenerVector* value=_listenerMap[iter];
        if ([value empty])
        {
            [_listenerMap removeObjectForKey:iter];
        }
        
    }
    
    
}

-(void) sortEventListeners:(ListenerID) listenerID
{
    [self sortEventListenersOfFixedPriority:listenerID];
}

-(void)sortEventListenersOfFixedPriority:(ListenerID) listenerID
{
    id listeners = [self getListeners:listenerID];
    
    if (listeners ==nil)
        return;
    
    NSMutableArray<EventListener*>* fixedListeners = [listeners getFixedPriorityListeners];
    if (fixedListeners == nil)
        return;
    
   
    NSArray *newArray = [fixedListeners sortedArrayUsingComparator:
                       ^NSComparisonResult(EventListener*obj1, EventListener* obj2) {
                           
                         return [obj1 getFixedPriority] > [obj2 getFixedPriority];
                      
                       }];
    
    
    
    
    [fixedListeners removeAllObjects];
    [fixedListeners addObjectsFromArray:newArray];
    
   
    int index = 0;
    for (id listener in fixedListeners)
    {
        NSLog(@"%@",listener);
        //        if ([listener getFixedPriority] >= 0)
        //            break;
        ++index;
    }
    [listeners setGt0Index:index];
    
    
    
}
-(EventListenerVector*) getListeners:(ListenerID) listenerID
{
    return _listenerMap[listenerID];
}
-(void)removeEventListenersForListenerID:(ListenerID) listenerID
{
    id listenerItemIter = _listenerMap[listenerID];
    
    if (listenerItemIter)
    {
       EventListenerVector* listeners = listenerItemIter;
        id fixedPriorityListeners = [listeners getFixedPriorityListeners];
        
        void (^removeAllListenersInVector)(NSMutableArray<EventListener*>* listenerVector) =^(NSMutableArray<EventListener*>* listenerVector){
            if (listenerVector == nil)
                return;
           
            for (id iter in  listenerVector)
            {
                EventListener* l = iter;
                [l setRegistered:false];
                [listenerVector removeObject:iter];
                [self releaseListener:l];
            }
        } ;
        
        
        removeAllListenersInVector(fixedPriorityListeners);
        
        [listeners clear];
        [_listenerMap removeObjectForKey:listenerID];
        
    }
    
    
}

-(void)removeCustomEventListeners:(NSString*) customEventName
{
    [self removeEventListenersForListenerID:customEventName];
}

-(void) removeAllEventListeners
{
    bool cleanMap = true;
    NSMutableArray<ListenerID>* types=[ NSMutableArray<ListenerID> new];
    
    
    for (id e in _listenerMap.allKeys)
    {
        [types  addObject:e];
    }
    
    for (ListenerID type in types)
    {
       [self removeEventListenersForListenerID:type];
    }
    
    if ( cleanMap)
    {
        [_listenerMap removeAllObjects];
    }
}

-(void)releaseListener:(EventListener*) listener
{
    if([listener isKindOfClass:[EventListenerPushMessage class]]){
        //[Platform  removePush];//移除推送
    }
    listener=nil;
}

@end
