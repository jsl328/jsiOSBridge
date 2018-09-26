//
//  FoxEventCustom.m
//  YXBuilder
//
//  Created by BruceXu on 2018/1/7.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "FoxEventCustom.h"




@interface EventCustom(){
    id _userData;
     NSString* _eventName;
}
@end
@implementation EventCustom
+(id)create:(NSString*)eventName{
    if(eventName==nil)return nil;
    return [[EventCustom alloc]initWithName:eventName];
}

-(id)init{
    if(self=[super init]){
       
        
    }
    return self;
}


-(id)initWithName:(NSString*)eventName{
    if(self=[super initWithType:CUSTOM]){
         _userData=nil;
        _eventName=eventName;
        
    }
    return self;
}
-(void) setUserData:(id) data{
    _userData=data;
}
-(id) getUserData{
    return _userData;
}
-(NSString*) getEventName{
    return _eventName;
}
-(NSDictionary*)toDescriptionDic{
    NSMutableDictionary *dic=[NSMutableDictionary new];
    if(_userData){
       [dic setObject:_userData forKey:@"userdata"];
    }
    [dic setObject:_eventName forKey:@"eventname"];
    return [dic copy];
//    if([_userData isKindOfClass:[NSDictionary class]]){
//
//    }
//    else if([_userData isKindOfClass:[NSArray class]]){
//
//    }
}
@end
