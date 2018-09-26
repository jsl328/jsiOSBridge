//
//  Statistics.h
//  YXBuilder
//
//  Created by LiYuan on 2018/1/9.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PVConst.h"

@interface StatisticsManager : NSObject

/** 初始化统计模块
 */
+ (void)setupStatistics;

/** 手动页面时长统计, 记录某个页面展示的时长.
 @param pageName 统计的页面名称.
 @param seconds 单位为秒，int型.
 */
+ (void)logPageView:(NSString *)pageName seconds:(int)seconds;

/** 自动页面时长统计, 开始记录某个页面展示时长.
 使用方法：必须配对调用beginLogPageView:和endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
 在该页面展示时调用beginLogPageView:，当退出该页面时调用endLogPageView:
 @param pageName 统计的页面名称.
 */
+ (void)beginLogPageView:(NSString *)pageName;

/** 自动页面时长统计, 结束记录某个页面展示时长.
 使用方法：必须配对调用beginLogPageView:和endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
 在该页面展示时调用beginLogPageView:，当退出该页面时调用endLogPageView:
 @param pageName 统计的页面名称.
 */
+ (void)endLogPageView:(NSString *)pageName;

@end
