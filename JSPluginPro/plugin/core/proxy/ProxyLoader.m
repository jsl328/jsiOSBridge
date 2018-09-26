//
//  ProxyLoader.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "ProxyLoader.h"

@implementation ProxyLoader
static ProxyLoader *_instance;

-(id)init{
    if(self=[super init]){
        self.proxyRegister=[NSMutableDictionary<NSString*,id> new];
    }
    return self;
}

+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
+(NSString*)PROXY_POINT{
    return @"fox.proxy";
}
-(NSMutableDictionary<NSString*,id>*)getAll{
    return [self.proxyRegister mutableCopy];
}
-(id)get:(NSString *)name{
    return [self.proxyRegister[name] copy];
}
-(void)put:(NSString*)name proxy:(id)object{
    if(object)
    [self.proxyRegister setObject:object forKey:name];
}
-(void)clear{
    [self.proxyRegister removeAllObjects];
}
@end
