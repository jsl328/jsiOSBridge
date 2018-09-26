//
//  ICallBackDelegate.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/18.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ICallBackDelegate<NSObject>
/**
 * 成功
 */
+(int) SUCCESS;

/**
 * 取消
 */
+(int) CANCEL;

/**
 * 错误
 */
+(int) ERROR;

/**
 * 回调处理
 *
 * param code
 * param message
 * param data
 */
-(void) run:(int) code message: (NSString*) message data:(id) data ;

@end
