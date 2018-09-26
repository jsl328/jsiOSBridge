//
//  YXDBHelper.m
//  YXIMSDK
//
//  Created by guoxd on 2017/9/11.
//  Copyright © 2017年 guoxd. All rights reserved.
//

#import "YXDBHelper.h"
#import "YXFMDatabase.h"
#define ROOTDIR @"DataBase"
@implementation YXDBHelper
static YXDBHelper *_databaseHelper;
+(YXDBHelper *)sharedYXDBHelper
{
    static dispatch_once_t onceTonken;
    dispatch_once(&onceTonken, ^{
        if (!_databaseHelper) {
            _databaseHelper = [[YXDBHelper alloc]init];
        }
    });
    return _databaseHelper;
}

-(YXFMDatabaseQueue *)databaseQueue
{
    if (!_databaseQueue) {
        _databaseQueue = [YXFMDatabaseQueue databaseQueueWithPath:[YXDBHelper getDataBasePath]];
    }
    return _databaseQueue;
}

+(NSString *)getDataBasePath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *rootDir = [path stringByAppendingPathComponent:ROOTDIR];
    if(![[NSFileManager defaultManager] isExecutableFileAtPath:rootDir])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:rootDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return [[rootDir stringByAppendingPathComponent:@"context"]stringByAppendingString:@".db"];
}

- (BOOL)createDataBaseListWithDictionaryOfSQLAndListName:(NSDictionary *)dictionary
{
    if (dictionary) {
        NSArray *keyArray = [dictionary allKeys];
        __block BOOL isSuccess = NO;
        [self.databaseQueue inDatabase:^(YXFMDatabase *db) {
            if ([db open]) {
                for(NSString *keyString in keyArray){
                    //添加表
                    NSString *sqlStr = [NSString stringWithFormat:@"create table if not exists %@(%@)",keyString,[dictionary objectForKey:keyString]];
                    isSuccess = [db executeUpdate:sqlStr];
                    if (!isSuccess) {
                        break;
                    }
                }
            }
            [db close];
        }];
        return isSuccess;
    }
    return NO;
}

@end
