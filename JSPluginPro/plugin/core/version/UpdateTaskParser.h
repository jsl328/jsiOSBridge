//
//  UpdateTaskParser.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/21.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigPreference.h"
#import "IUpdateTaskDelegate.h"
@interface UpdateTaskParser : NSObject
/**
 * new updateTask对象
 *
 * param clazz
 * return
 */
+ (id<IUpdateTaskDelegate>) newUpdateTask:(Class) clazz ;
/**
 * 解析更新任务
 *
 * @param config
 * @return
 */
+(NSArray<id<IUpdateTaskDelegate>>*) parseUpdateTask:(NSString*) config class:(Class) clazz ;
/**
 * 解析JSON格式任务
 *
 * @param s
 * @return
 */
+(id<IUpdateTaskDelegate>) parseTaskForJson:(NSString*) config class:(Class) clazz ;

/**
 * 解析数组格式任务
 *
 * @param s
 * @return
 */
+ (id<IUpdateTaskDelegate>) parseTaskForArray:(NSString*) s class: (Class) clazz;



@end
