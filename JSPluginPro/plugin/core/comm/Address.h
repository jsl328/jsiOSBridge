//
//  Address.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject
/**
 * socket地址
 */
@property(copy) NSString* socketAddress;
/**
 * HTTP地址
 */
@property(copy)NSString* httpAddress;
-(BOOL)isSSLSocket;
/**
 * 是否为SSL HTTP
 * return
 */
-(BOOL) isSSLHttp;
-(NSString*) toString;
+(Address*) parse:(NSString*) param;
/**
 * 设置属性
 *
 * return param
 */
-(void) setProperty:(NSString*) param ;
@end
