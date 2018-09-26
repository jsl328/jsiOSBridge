//
//  DataBaseManager.h
//  YXIMSDK
//
//  Created by guoxd on 2017/9/13.
//  Copyright © 2017年 guoxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXDBHelper.h"
@interface DataBaseManager : NSObject

/**
 executeUpdate——主要进行的数据库操作有delete、insert、update

 @param SQL sql语句
 @param dbName 数据库名
 @param dbPath 数据库地址
 @param tableName 表名
 @param error 错误信息
 @return 操作是否成功
 */
+ (NSString *)executeUpdateWithSQL:(NSString *)SQL toDB:(NSString *)dbName atPath:(NSString *)dbPath DBTable:(NSString *)tableName error:(NSError **)error;

/**
 executeQuery——主要进行的数据库操作有select

 @param SQL sql语句
 @param dbName 数据库名
 @param dbPath 数据库地址
 @param tableName 表名
 @param error 错误信息
 @return 查询的数据（数组中存储的是字典类型，每一个字典代表一条数据）
 */
+ (NSMutableArray *)executeQueryWithSQL:(NSString *)SQL fromDB:(NSString *)dbName atPath:(NSString *)dbPath DBTable:(NSString *)tableName error:(NSError **)error;


@end
