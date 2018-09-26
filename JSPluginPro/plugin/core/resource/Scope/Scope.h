//
//  Scope.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSString(Scope)
/**
 * 判断是否匹配
 * @param path
 * @return
 */
-(BOOL)match:(NSString*) path;
@end

@interface Scope : NSObject

+(NSString*) LocalScope;
+(NSString*) LocalCacheScope;

/**
 * 获取协议
 * return
 */
//-(NSString*)getProtocol;

@end
