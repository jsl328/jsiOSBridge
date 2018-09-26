//
//  FoxEventListener.m
//  YXBuilder
//
//  Created by BruceXu on 2018/1/7.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "FoxEventListener.h"
@interface EventType:NSObject
+(int)CUSTOM;
@end
@implementation EventType
+(int)CUSTOM{
    return 1;
}
@end

@interface EventListener()
{
    
}

@end
@implementation EventListener



-(id)init:(int)t listenerID:(ListenerID)listenerID callback:(EventCallBack)callback{
    if(self=[super init]){
        _type=t;
        _listenerID=listenerID;
        self.onEvent=callback;
        self.keepAlive=NO;
    }
    return self;
}

-(BOOL)checkAvailable{
    return YES;
}


-(EventListener*) clone{
    return nil;
}


-(void) setEnabled:(bool) enabled{ _isEnabled = enabled; }


-(BOOL)isEnabled { return _isEnabled; }


-(void) setRegistered:(BOOL) registered { _isRegistered = registered; }


-(BOOL)isRegistered { return _isRegistered; }


-(int) getType  { return _type; }


 -(ListenerID) getListenerID { return _listenerID; }


-(void) setFixedPriority:(int) fixedPriority { _fixedPriority = fixedPriority; }

 
-(int) getFixedPriority { return _fixedPriority; }


-(void) setAssociatedNode:(EventObject*) node { _node = node; }


-(EventObject*) getAssociatedNode  { return _node; }






@end
