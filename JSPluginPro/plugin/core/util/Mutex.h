//
//  Mutex.h
//  YXBuilder
//
//  Created by BruceXu on 2018/1/15.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Mutex : NSObject
-(id)init:(int)maxLockTime;
/**
 * 尝试获取授权
 *
 * return
 */
-(BOOL)obtain ;
/**
 * 释放授权
 */
-(void)doRelease ;
@end
