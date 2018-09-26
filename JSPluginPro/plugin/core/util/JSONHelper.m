//
//  JSONHelper.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/19.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "JSONHelper.h"
#import "YXPlugin.h"
@implementation JSONHelper
+(NSString*)toJSONString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        FOXLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
+ (NSDictionary *)jsonToDictionary:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        FOXLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
