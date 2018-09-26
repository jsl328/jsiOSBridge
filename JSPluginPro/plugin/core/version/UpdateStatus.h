//
//  UpdateStatus.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateStatus : NSObject
/**
 *  成功
 */
+(int) SUCCESS;

/**
 *  无法连接
 */
+(int) NOT_CONNECT;

/**
 * 不需要更新
 */
+(int) NOT_NEED_UPDATE;

/**
 * 更新错误
 */
+ (int) UPDATE_FAIL;

/**
 * 更新错误并提示
 */
+(int) UPDATE_FAIL_AND_TIP;

/**
 * 更新错误并退出
 */
+(int) UPDATE_FAIL_AND_EXIT;

/**
 * 删除错误
 */
+(int) DELETE_FAIL;

/**
 *  成功并需要重启
 */
+(int) SUCCESS_AND_RESTART;

/**
 *  成功并需要退出
 */
+(int) SUCCESS_AND_EXIT;

/**
 *  忽略更新
 */
+(int) IGNORE;


-(id)initWithCode:(int)code_ message:(NSString*)message_;
-(int)getCode;
-(NSString*)getMessage;

@end
