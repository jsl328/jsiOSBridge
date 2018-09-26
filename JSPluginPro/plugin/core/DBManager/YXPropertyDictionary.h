//
//  YXPropertyDictionary.h
//  YXIMSDK
//
//  Created by guoxd on 2017/9/13.
//  Copyright © 2017年 guoxd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXPropertyDictionary : NSObject

/**
 获取属性名和值
 
 @param cla 类
 @return 属性名和属性值的字典
 */
+(NSDictionary *)getNameAndValueOfProperty:(id)cla;

/**
 反射属性到数据库

 @param dictionary 属性名为key，属性值为value的字典
 */
+(NSDictionary *)reflexPropertyToDataBase:(NSDictionary *)dictionary;
/**
 反射数据库数据
 
 @param dictionary 属性名为key，属性值为value的字典
 */
+(NSDictionary *)reflexDataBaseToProperty:(NSDictionary *)dictionary;
/**
 反射数据库的数据到属性值

 @param dictionary 数据库的字段为key，字段值为value的字典
 */
+(void)reflexDataBaseToProperty:(NSDictionary *)dictionary AndClass:(id)cla;

/**
 字符串首字母大写

 @param aString 需要首字母大写的字符串
 @return 完成的字符串
 */
+ (NSString *)getFirstLetterFromString:(NSString *)aString;

@end
