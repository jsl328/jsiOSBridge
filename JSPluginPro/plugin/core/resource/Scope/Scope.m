//
//  Scope.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "Scope.h"
@implementation NSString(Scope)
/**
 * 判断是否匹配
 * @param path
 * @return
 */
-(BOOL)match:(NSString*) path{
    if(path==nil){
        return false;
    }
    return [path hasPrefix:self];
}
@end


@interface Scope(){
    
}

@end
@implementation Scope
//-(id)initWithProtocol:(NSString*)protocol_{
//    if(self=[super init]){
//
//    }
//    return self;
//}
+(NSString*) LocalScope{
    return @"local://";
}
+(NSString*) LocalCacheScope{
    return @"localCache://";
}

 
 

@end
