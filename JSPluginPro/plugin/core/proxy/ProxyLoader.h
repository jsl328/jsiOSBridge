//
//  ProxyLoader.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProxyLoader : NSObject
/**
 * 代理管理器实例
 */
+ (instancetype)getInstance;
/**
 * 代理扩展点
 */
+(NSString*)PROXY_POINT;
/**
 * 代理注册器
 */
@property(strong) NSMutableDictionary<NSString*,id>*proxyRegister;
/**
 * 获取所有代理
 *
 * return
 */
-(NSMutableDictionary<NSString*,id>*)getAll;
/**
 * 获取指定名称的代理
 *
 * param name
 * return
 */
-(id)get:(NSString *)name;
/**
 * 加入代理
 *
 * param name
 * param proxy
 */
-(void)put:(NSString*)name proxy:(id)object;
/**
 * 清空代理
 */
-(void)clear;
@end
