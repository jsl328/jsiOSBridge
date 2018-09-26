//
//  Trigger.h
//  IOSNetWorkDemo
//
//  Created by BruceXu on 2018/4/17.
//  Copyright © 2018年 孙伟伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trigger : NSObject
/**
 * HTTP协议头分割符
 */
+(NSData*) HEADER_SPLITOR;

/**
 * 分割符
 */
+(NSData*) SPLITOR;

/**
 * 构造函数
 *
 * @param key
 */
-(id)init:(NSData*) key;
/**
 * 获取key
 * @return
 */
-(NSData*) getKey;
/**
 * 获取key的长度
 * @return
 */
-(int) getKeyLength;
/**
 * 重置
 */
-(void) reset;

/**
 * 触发
 *
 * @param data
 * @return
 */
-(int) trigger:(NSData*) data ;

/**
 * 触发
 *
 * @param data
 * @param offset
 * @param length
 * @return
 */
-(int) trigger:(NSData*) data offset:(int) offset length: (int) length ;
@end
