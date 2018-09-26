//
//  DataBaseOperate.m
//  YXBuilder
//
//  Created by guoxd on 2018/1/8.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "DataBaseOperate.h"
#import "YXPropertyDictionary.h"
#import "DataBaseManager.h"
#import "NSString+DBSQLiteString.h"
#import "ICallBackDelegate.h"
#import "CallBackObject.h"
#define PATH2 [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define ROOTDIR @"DataBase"
#define TABLENAME @"app_contact"
#define DATABASENAME @"context.db"
#define PATH  [PATH2 stringByAppendingPathComponent:ROOTDIR]

@implementation DataBaseOperate
-(void)call:(NSString*) type action: (NSString*) action param: (NSString*) param  callback: (id<ICallBackDelegate>) callback{
    FOXLog(@"type = %@,action = %@,params = %@,callback = %@",type,action,param,callback);
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    if (param.length >0) {
         paramDic = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    }
    NSString *result;
    //增
    if ([action isEqualToString:@"addData"]) {
        NSDictionary *dictionary = [YXPropertyDictionary reflexPropertyToDataBase:paramDic];
        NSString *addSqlString = [NSString sqlStringInsertToTable:TABLENAME withDictionary:dictionary];
        result = [DataBaseManager executeUpdateWithSQL:addSqlString toDB:DATABASENAME atPath:PATH DBTable:TABLENAME error:nil];
        if ([result isEqualToString:@"1"]) {
            [callback run:CallBackObject.SUCCESS message:@"" data:@"add data success!"];
        }
        else{
            [callback run:CallBackObject.ERROR message:result data:@""];
        }
    }
    //删
    if([action isEqualToString:@"deleteData"]){
        NSDictionary *dictionary = [YXPropertyDictionary reflexPropertyToDataBase:paramDic];
        NSString *sqlString =[NSString sqlStringDeleteFromTable:TABLENAME withDictionary:dictionary andPrimeKey:@[@"APP_VERSION"]];
        result = [DataBaseManager executeUpdateWithSQL:sqlString toDB:DATABASENAME atPath:PATH DBTable:TABLENAME error:nil];
        if ([result isEqualToString:@"1"]) {
            [callback run:CallBackObject.SUCCESS message:@"" data:@"delete data success!"];
        }
        else{
            [callback run:CallBackObject.ERROR message:result data:@""];
        }
    }
    //改
    if ([action isEqualToString:@"updateData"]) {
        NSDictionary *dictionary = [YXPropertyDictionary reflexPropertyToDataBase:paramDic];
        NSString *updateString = [NSString sqlStringUpdateToTable:TABLENAME withDictionary:dictionary andPrimeKey:@[@"APP_VERSION"]];
        result = [DataBaseManager executeUpdateWithSQL:updateString toDB:DATABASENAME atPath:PATH DBTable:TABLENAME error:nil];
        if ([result isEqualToString:@"1"]) {
            [callback run:CallBackObject.SUCCESS message:@"" data:@"update data success!"];
        }
        else{
            [callback run:CallBackObject.ERROR message:result data:@""];
        }
    }
    //查
    if ([action isEqualToString:@"searchData"]) {
        NSDictionary *dictionary = [YXPropertyDictionary reflexPropertyToDataBase:paramDic];
        NSString *searchString = [NSString sqlStringSelectFromTable:TABLENAME withDictionary:dictionary andPrimeKey:@[@"APP_VERSION"]];
        NSArray *array = [DataBaseManager executeQueryWithSQL:searchString fromDB:DATABASENAME atPath:PATH DBTable:TABLENAME error:nil];
        NSMutableArray *resultArray = [NSMutableArray array];
        if(array.count>0){
            for(NSDictionary *dictionary in array)
            {
                NSDictionary *reflexDic = [YXPropertyDictionary reflexDataBaseToProperty:dictionary];
                [resultArray addObject:reflexDic];
            }
        }
        if (resultArray.count >0) {
            [callback run:CallBackObject.SUCCESS message:@"" data:resultArray];
        }
        else{
            [callback run:CallBackObject.ERROR message:@"没有查找到数据" data:@""];
        }
    }
    if ([action isEqualToString:@"getAllData"]) {
        NSString *string = [NSString sqlStringSelectFromTable:TABLENAME withDictionary:nil andPrimeKey:nil];
        NSArray *array = [DataBaseManager executeQueryWithSQL:string fromDB:DATABASENAME atPath:PATH DBTable:TABLENAME error:nil];
        NSMutableArray *resultArray = [NSMutableArray array];
        if(array.count>0){
            for(NSDictionary *dictionary in array)
            {
                NSDictionary *reflexDic = [YXPropertyDictionary reflexDataBaseToProperty:dictionary];
                [resultArray addObject:reflexDic];
            }
        }
        if (resultArray.count >0) {
            [callback run:CallBackObject.SUCCESS message:@"" data:resultArray];
        }
        else{
            [callback run:CallBackObject.ERROR message:@"没有查找到数据" data:@""];
        }
    }
    
}
@end
