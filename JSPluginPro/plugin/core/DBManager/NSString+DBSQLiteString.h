//
//  NSString+DBSQLiteString.h
//  YXIMSDK
//
//  Created by guoxd on 2017/9/13.
//  Copyright © 2017年 guoxd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(DBSQLiteString)
/**
 生成insert语句
 
 @param tableName 表名
 @param dic 插入的字段名和值
 @return 返回insert的SQL语句
 */
+ (NSString *)sqlStringInsertToTable:(NSString *)tableName withDictionary:(NSDictionary *)dic;

/**
 生成delete语句
 
 @param tableName 表名
 @param dic 需要删除的字段名和值
 @param primeKey 主字段名
 @return 返回delete的SQL语句
 */
+ (NSString *)sqlStringDeleteFromTable:(NSString *)tableName withDictionary:(NSDictionary *)dic andPrimeKey:(NSArray *)primeKey;
/**
 生成update语句
 
 @param tableName 表名
 @param dic 需要更新的字段名和值
 @param primeKey 主字段名
 @return update的SQL语句
 */
+ (NSString *)sqlStringUpdateToTable:(NSString *)tableName withDictionary:(NSDictionary *)dic andPrimeKey:(NSArray *)primeKey;
/**
 生成select语句
 
 @param tableName 表名
 @param dic 查找时的字段名和值
 @param primeKey 主字段
 @param isOR 是否使用OR去筛选
 @return select的SQL语句
 */
+ (NSString *)sqlStringSelectFromTable:(NSString *)tableName withDictionary:(NSDictionary *)dic andPrimeKey:(NSArray *)primeKey isOR:(BOOL)isOR;
/**
 生成select语句

 @param tableName 表名
 @param dic 查找时的字段名和值
 @param primeKey 主字段
 @return select的SQL语句
 */
+ (NSString *)sqlStringSelectFromTable:(NSString *)tableName withDictionary:(NSDictionary *)dic andPrimeKey:(NSArray *)primeKey;

/**
 生成分页的select语句

 @param tableName 表名
 @param startNom 开始的位置
 @param limitNom 每页的数量
 @param dic 限制条件的字典
 @param primeKey 限制条件的字段数组
 @return 分页select的SQL语句
 */
+ (NSString *)sqlStringSelectFromTable:(NSString *)tableName startNom:(int)startNom limitNom:(int)limitNom withDictionary:(NSDictionary *)dic andPrimeKey:(NSArray *)primeKey;


@end
