//
//  DataBaseManager.m
//  YXIMSDK
//
//  Created by guoxd on 2017/9/13.
//  Copyright © 2017年 guoxd. All rights reserved.
//

#import "DataBaseManager.h"
#import "YXFMDatabaseAdditions.h"

@implementation DataBaseManager

/**
 executeUpdate——主要进行的数据库操作有delete、insert、update
 
 @param SQL sql语句
 @param dbName 数据库名
 @param dbPath 数据库地址
 @param error 错误信息
 @param tableName 表名
 @return 操作是否成功
 */
+ (NSString *)executeUpdateWithSQL:(NSString *)SQL toDB:(NSString *)dbName atPath:(NSString *)dbPath DBTable:(NSString *)tableName error:(NSError **)error
{
    __block NSString *string;
    //先判断数据库是否存在
    if ([self existDB:dbName atPath:dbPath error:error]) {
        //判断表是否存在
        if ([self existTable:tableName withinDB:dbName atPath:dbPath error:error]) {
            YXDBHelper *dbHelper = [YXDBHelper sharedYXDBHelper];
            [dbHelper.databaseQueue inDatabase:^(YXFMDatabase *db) {
                if ([db open]) {
                    BOOL isSuccess = [db executeUpdate:SQL];
                    if (isSuccess) {
                        string = @"1";
                    }
                    else{
                        string = [NSString stringWithFormat:@"%d:%@",[db lastErrorCode],[db lastErrorMessage]];
                    }
                }
                [db close];
            }];
        }
    }
    return string;
}


/**
 executeQuery——主要进行的数据库操作有select
 
 @param SQL sql语句
 @param dbName 数据库名
 @param dbPath 数据库地址
 @param tableName 表名
 @param error 错误信息
 @return 查询的数据（数组中存储的是字典类型，每一个字典代表一条数据）
 */
+ (NSMutableArray *)executeQueryWithSQL:(NSString *)SQL fromDB:(NSString *)dbName atPath:(NSString *)dbPath DBTable:(NSString *)tableName error:(NSError **)error
{
    NSMutableArray *rtnList = [NSMutableArray array];
    // 判断DB是否存在
    if ([self existDB:dbName atPath:dbPath error:error]) {
        // 获取db指针
        YXDBHelper *dbHelper = [YXDBHelper sharedYXDBHelper];
        [dbHelper.databaseQueue inDatabase:^(YXFMDatabase *db) {
            // 打开db
            if ([db open]) {
                // 获取结果集中的colums的总数
                YXFMResultSet *rs = [db executeQuery:SQL];
                // 封装dictionary
                while ([rs next]) {
                    int cls = [rs columnCount];
                    NSMutableDictionary *colDic = [NSMutableDictionary dictionary];
                    for (int i = 0 ; i < cls ; i++) {
                        // 获取column的名称 作为dictionary的key
                        NSString *key = [rs columnNameForIndex:i];
                        // 获取column的值 作为dictionary的value
                        id obj = [rs objectForColumnIndex:i];
                        if ([obj isKindOfClass:[NSNull class]]) {
                            obj = nil;
                        }
                        // 添加到dictionary中
                        [colDic setValue:obj forKey:key];
                    }
                    [rtnList addObject:colDic];
                }
                [rs close];
            }
            [db close];
        }];
    }
    return rtnList;
}


/**
 判断数据库是否存在
 */
+ (BOOL)existDB:(NSString *)dbName atPath:(NSString *)dbPath error:(NSError **)error
{
    NSFileManager *fileMng = [NSFileManager defaultManager];
    return [fileMng fileExistsAtPath:[dbPath stringByAppendingPathComponent:dbName]];
}

/**
 判断表是否存在
 */
+ (BOOL)existTable:(NSString *)tableName withinDB:(NSString *)dbName atPath:(NSString *)dbPath error:(NSError **)error
{
    // 检查db是否存在
    if (![self existDB:dbName atPath:dbPath error:error]) {
        return NO;
    }
    // 检查table是否存在
    YXFMDatabase *db = [YXFMDatabase databaseWithPath:[dbPath stringByAppendingPathComponent:dbName]];
    BOOL rtnBool = NO;
    if ([db open]) {
        rtnBool = [db tableExists:tableName];
        [db close];
    }
    return rtnBool;
}

@end
