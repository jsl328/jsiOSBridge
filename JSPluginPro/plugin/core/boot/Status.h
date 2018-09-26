//
//  Status.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Status : NSObject

-(id)initWithCode:(int)code;

-(id)initWithCode:(int)code message:(NSString*)message;

/**
 * 结果代码
 */
@property(assign) int resultCode;


/**
 * 消息
 */
@property(copy) NSString *message;

+(int)SUCCESS;
+(int)FAIL;
+(int)RESTART;
+(int)EXIT;

///**
// * 成功
// */
//@property int SUCCESS = 0;
//
///**
// * 失败
// */
//public final static int FAIL = 1;
//
///**
// * 重启
// */
//public final static int RESTART = 3;
//
///**
// * 退出
// */
//public final static int EXIT = 4;



@end
