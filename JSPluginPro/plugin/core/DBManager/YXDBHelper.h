//
//  YXDBHelper.h
//  YXIMSDK
//
//  Created by guoxd on 2017/9/11.
//  Copyright © 2017年 guoxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXFMDatabaseQueue.h"
@interface YXDBHelper : NSObject

@property (nonatomic,strong) YXFMDatabaseQueue *databaseQueue;

+(YXDBHelper *)sharedYXDBHelper;

/**
 创建表
 @param dictionary 数据库中表名和SQL语句的字典（表名为key，SQL语句为value）
 @return 创建是否成功
 */
- (BOOL)createDataBaseListWithDictionaryOfSQLAndListName:(NSDictionary *)dictionary;


@end
