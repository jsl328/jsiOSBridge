//
//  YXCreateAllList.m
//  YXIMSDK
//
//  Created by guoxd on 2017/9/18.
//  Copyright © 2017年 guoxd. All rights reserved.
//

#import "YXCreateAllList.h"
#import "YXDBHelper.h"
@implementation YXCreateAllList
+(BOOL)createAllList
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
#pragma mark============================app_contact================================

    NSMutableDictionary *contactsDic = [NSMutableDictionary dictionary];
    [contactsDic setObject:@"integer primary key" forKey:@"ID"];//主键
    [contactsDic setObject:@"text not null unique" forKey:@"APP_VERSION"];//APP版本号、
    [contactsDic setObject:@"text" forKey:@"APP_SETTING"];//APP设置
    [contactsDic setObject:@"text" forKey:@"APP_CACHE"];//APP的缓存
    [contactsDic setObject:@"text" forKey:@"APP_USERINFO"];//APP的详细信息
    [contactsDic setObject:@"text" forKey:@"DEVICE_VERSION"];//设备版本号
    [contactsDic setObject:@"text" forKey:@"DEVICE_UUID"];//设备唯一编号
    [contactsDic setObject:@"text" forKey:@"DEVICE_PHONE_NUMBER"];//本机号码
    [contactsDic setObject:@"text" forKey:@"EXTEND_USERINFO"];//扩展字段
    NSString *contantsString = [self sqlString:contactsDic isForeignKey:NO andForeignKeyDic:nil];
    [dictionary setObject:contantsString forKey:@"app_contact"];

#pragma mark============================app_====================================
//    NSDictionary *branchDic = @{
//                                @"ID":@"integer primary key",//无业务含义主键
//                                @"BRH_NO":@"text",//机构编号
//                                @"BRH_NAME":@"text",//机构名称
//                                @"BRH_DESC":@"text",//机构描述
//                                @"FIRM_NO":@"text",//公司编号
//                                @"PARENT_NO":@"text",//父机构编号
//                                @"BRH_ORDER":@"integer",//排序
//                                @"IS_LEAF":@"text",//是否叶子节点.。T-是；F-否；
//                                @"BRH_TEL":@"text",//机构电话
//                                @"BRH_EMAIL":@"text",//机构邮箱
//                                @"BRH_ADDR":@"text",//机构地址
//                                @"REMARK":@"text"//备注
//                                };
//    NSString *branchString = [self sqlString:branchDic isForeignKey:NO andForeignKeyDic:nil];
//    [dictionary setObject:branchString forKey:@"app_branch"];
    
    BOOL isSuccess = [[YXDBHelper sharedYXDBHelper]createDataBaseListWithDictionaryOfSQLAndListName:dictionary];
    
    return isSuccess;
}

+ (NSString *)sqlString:(NSDictionary *)dictionary isForeignKey:(BOOL)isForeignKey andForeignKeyDic:(NSDictionary *)foreignKeyDic
{
    if (dictionary) {
        //拼接字段类型和字段
        NSMutableString *appendString = [NSMutableString string];
        NSArray *keyArray = [dictionary allKeys];
        for(int i=0;i<keyArray.count;i++)
        {
            NSString *keyString = keyArray[i];
            id value = [dictionary objectForKey:keyString];
            if ([keyString isEqualToString:@"ID"]) {
                if (i == (keyArray.count-1)) {
                    if (appendString.length>0) {
                        NSString *tempString = [appendString substringToIndex:(appendString.length-1)];
                        NSMutableString *tempMutableString = [NSMutableString  stringWithFormat:@"%@ %@,",keyString,value];
                        [tempMutableString appendString:tempString];
                        appendString = tempMutableString;
                    }
                    else{
                        [appendString appendString:[NSString stringWithFormat:@"%@ %@",keyString,value]];
                    }
                }
                else{
                    NSString *tempString = appendString;
                    NSMutableString *tempMutableString = [NSMutableString  stringWithFormat:@"%@ %@,",keyString,value];
                    [tempMutableString appendString:tempString];
                    appendString = tempMutableString;
                }
            }
            else{
                if (i == (keyArray.count-1)) {
                    [appendString appendString:[NSString stringWithFormat:@"%@ %@",keyString,value]];
                }
                else{
                    [appendString appendString:[NSString stringWithFormat:@"%@ %@,",keyString,value]];
                }
            }
        }
        if (isForeignKey && foreignKeyDic) {
            [appendString appendString:@","];
            NSString *listNameString = [[foreignKeyDic allKeys] objectAtIndex:0];
            NSString *foreignKeyString = [foreignKeyDic objectForKey:listNameString];
            [appendString appendString:[NSString stringWithFormat:@"foreign key(%@) references %@(%@)",foreignKeyString,listNameString,foreignKeyString]];
        }
        return appendString;
    }
    return nil;

}
@end
