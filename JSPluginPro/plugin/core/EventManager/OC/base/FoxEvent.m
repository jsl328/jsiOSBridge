//
//  FoxEvent.m
//  YXBuilder
//
//  Created by BruceXu on 2018/1/7.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "FoxEvent.h"
@interface Event(){
    Type _type;
    EventObject* _currentTarget;
}
@end
@implementation Event
-(id)initWithType:(Type)type{
    if(self=[super init]){
        _type=type;
        _currentTarget=nil;
    }
    return self;
    
}

-(Type) getType{
    return _type;
}

-(EventObject*) getCurrentTarget{
    return _currentTarget;
}

-(void) setCurrentTarget:(EventObject* )target{
    _currentTarget=target;
}
-(NSDictionary*)toDescriptionDic{
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:@(_type) forKey:@"type"];
    return [dic copy];
}
@end
