//
//  NSString+DBSQLiteString.m
//  YXIMSDK
//
//  Created by guoxd on 2017/9/13.
//  Copyright © 2017年 guoxd. All rights reserved.
//

#import "NSString+DBSQLiteString.h"

@implementation NSString(DBSQLiteString)

/**
 生成insert语句

 @param tableName 表名
 @param dic 插入的字段名和值
 @return 返回insert的SQL语句
 */
+ (NSString *)sqlStringInsertToTable:(NSString *)tableName withDictionary:(NSDictionary *)dic
{
    NSMutableString *executeSQL = [NSMutableString stringWithFormat:@"insert into %@ ",tableName];
    NSMutableString *keys   = [NSMutableString stringWithFormat:@"("];
    NSMutableString *values = [NSMutableString stringWithFormat:@" values ("];
    NSArray *insertKeys = [dic allKeys];
    for (id col in insertKeys) {
        [keys appendFormat:@"%@,",col];
        id value = [self convertToSqlValue:[dic valueForKey:col]];
        [values appendFormat:@"%@,",value];
    }
    keys = [NSMutableString stringWithString:[keys substringToIndex:keys.length-1]];
    [keys appendString:@") "];
    
    values = [NSMutableString stringWithString:[values substringToIndex:values.length-1]];
    [values appendString:@") "];
    
    [executeSQL appendFormat:@"%@%@",keys,values];
    [executeSQL appendString:@";"];
    return executeSQL;
}


/**
 生成delete语句

 @param tableName 表名
 @param dic 需要删除的字段名和值
 @param primeKey 主字段名
 @return 返回delete的SQL语句
 */
+ (NSString *)sqlStringDeleteFromTable:(NSString *)tableName withDictionary:(NSDictionary *)dic andPrimeKey:(NSArray *)primeKey
{
    NSMutableString *executeSQL = [NSMutableString stringWithFormat:@"delete from %@ where ",tableName];
    
    NSString *where = @"";
    for (NSString *key in primeKey) {
        id value = [self convertToSqlValue:[dic valueForKey:key]];
        
        if (value != nil) {
            where = [where stringByAppendingFormat:@" %@=%@ and ", key, value];
        }
    }
    if ([where isEqualToString:@""])
        return nil;
    
    where = [where substringToIndex:where.length-4];    //去掉 "and "
    [executeSQL appendString:where];
    return executeSQL;
}

/**
 生成update语句

 @param tableName 表名
 @param dic 需要更新的字段名和值
 @param primeKey 主字段名数组
 @return update的SQL语句
 */
+ (NSString *)sqlStringUpdateToTable:(NSString *)tableName withDictionary:(NSDictionary *)dic andPrimeKey:(NSArray *)primeKey
{
    NSMutableString *executeSQL = [NSMutableString stringWithFormat:@"update %@ set ",tableName];
    
    // set value
    for (NSString *key in [dic allKeys]) {
        if (![primeKey containsObject:key]) {
            id value = [self convertToSqlValue:[dic valueForKey:key]];
            if (value != nil) {
                [executeSQL appendFormat:@"%@=%@ ,", key, value];
            }
        }
    }
    [executeSQL deleteCharactersInRange:NSMakeRange(executeSQL.length-1, 1)];
    
    // where
    [executeSQL appendString:@" where "];
    NSString *where = @"";
    for (NSString *key in primeKey) {
        
        id value = [self convertToSqlValue:[dic valueForKey:key]];
        if (value != nil) {
            where = [where stringByAppendingFormat:@" %@=%@ and ", key, value];
        }
    }
    if ([where isEqualToString:@""])
        return nil;
    
    where = [where substringToIndex:where.length-4];    //去掉 "and "
    [executeSQL appendString:where];
    return executeSQL;
}

/**
 生成select语句
 
 @param tableName 表名
 @param dic 查找时的字段名和值
 @param primeKey 主字段
 @param isOR 是否使用OR去筛选
 @return select的SQL语句
 */
+ (NSString *)sqlStringSelectFromTable:(NSString *)tableName withDictionary:(NSDictionary *)dic andPrimeKey:(NSArray *)primeKey isOR:(BOOL)isOR
{
    NSMutableString *executeSQL = [NSMutableString stringWithFormat:@"select * from %@ where",tableName];
    NSString *where = @"";
    for (NSString *key in primeKey) {
        id value = [self convertToSqlValue:[dic valueForKey:key]];
        
        if (value != nil && !isOR) {
            where = [where stringByAppendingFormat:@" %@=%@ and ", key, value];
        } else {
            where = [where stringByAppendingFormat:@" %@=%@ or ", key, value];
        }
    }
    if ([where isEqualToString:@""])
        return [NSString stringWithFormat:@"select * from %@",tableName];;
    
    where = [where substringToIndex:where.length - (isOR ? 3 : 4)];    //去掉 "or/and "
    [executeSQL appendString:where];
    return executeSQL;
}

/**
 生成select语句
 
 @param tableName 表名
 @param dic 查找时的字段名和值
 @param primeKey 主字段
 @return select的SQL语句
 */
+ (NSString *)sqlStringSelectFromTable:(NSString *)tableName withDictionary:(NSDictionary *)dic andPrimeKey:(NSArray *)primeKey
{
    
    NSMutableString *executeSQL = [NSMutableString stringWithFormat:@"select * from %@ where",tableName];
    NSString *where = @"";
    for (NSString *key in primeKey) {
        id value = [self convertToSqlValue:[dic valueForKey:key]];
        
        if (value != nil) {
            where = [where stringByAppendingFormat:@" %@=%@ and ", key, value];
        }
    }
    if ([where isEqualToString:@""])
        return [NSString stringWithFormat:@"select * from %@",tableName];;
    
    where = [where substringToIndex:where.length-4];    //去掉 "and "
    [executeSQL appendString:where];
    return executeSQL;
}

+ (NSString *)sqlStringSelectFromTable:(NSString *)tableName startNom:(int)startNom limitNom:(int)limitNom withDictionary:(NSDictionary *)dic andPrimeKey:(NSArray *)primeKey
{
    NSMutableString *executeSQL = [NSMutableString stringWithFormat:@"select * from %@   limit %d,%d where",tableName,startNom,limitNom];
    NSString *where = @"";
    for (NSString *key in primeKey) {
        id value = [self convertToSqlValue:[dic valueForKey:key]];
        
        if (value != nil) {
            where = [where stringByAppendingFormat:@" %@=%@ and ", key, value];
        }
    }
    if ([where isEqualToString:@""])
        return nil;
    
    where = [where substringToIndex:where.length-4];    //去掉 "and "
    [executeSQL appendString:where];
    return executeSQL;
}



+(id)convertToSqlValue:(id)value {
    if (value == nil || [value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    const char *type = [NSStringFromClass([value class]) UTF8String];
    if (strcmp(type, @encode(BOOL)) == 0) {
        return [value boolValue] ? @"'1'" : @"'0'";
    }
    else if (strcmp(type, @encode(int32_t)) == 0) {
        return [NSString stringWithFormat:@"%@",value];
    }
    else if (strcmp(type, @encode(int64_t)) == 0) {
        return [NSString stringWithFormat:@"%@",value];
    }
    else if (strcmp(type, @encode(float)) == 0) {
        return [NSString stringWithFormat:@"%@",value];
    }
    else if (strcmp(type, @encode(double)) == 0) {
        return [NSString stringWithFormat:@"%@",value];
    }
    else if (strcmp(type, @encode(id)) == 0) {
        return [NSString stringWithFormat:@"%@",value];
    }
    else if([value isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%@",value];
    }
    else {
        return [NSString stringWithFormat:@"'%@'",value];
    }
}
@end
