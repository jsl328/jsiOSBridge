//
//  YXPropertyDictionary.m
//  YXIMSDK
//
//  Created by guoxd on 2017/9/13.
//  Copyright © 2017年 guoxd. All rights reserved.
//

#import "YXPropertyDictionary.h"
#import <objc/runtime.h>
#import <objc/message.h>
#include <ctype.h>
@implementation YXPropertyDictionary
+(NSDictionary *)getNameAndValueOfProperty:(id)cla
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    NSString *property_data_type = nil;
    unsigned int outCount = 0, i = 0;
    objc_property_t *properties = class_copyPropertyList([cla class], &outCount);
    for (i=0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //获得属性名
        const char *property_name = property_getName(property);
        NSString *propertyName = [NSString stringWithFormat:@"%s",property_name];
        //获得属性类型
        const char * property_attr = property_getAttributes(property);
        
        //If the property is a type of Objective-C class, then substring the variable of `property_attr` in order to getting its real type
        if (property_attr[1] == '@') {
            char * occurs1 =  strchr(property_attr, '@');
            char * occurs2 =  strrchr(occurs1, '"');
            char dest_str[40]= {0};
            strncpy(dest_str, occurs1, occurs2 - occurs1);
            char * realType = (char *)malloc(sizeof(char) * 50);
            int i = 0, j = 0, len = (int)strlen(dest_str);
            for (; i < len; i++) {
                if ((dest_str[i] >= 'a' && dest_str[i] <= 'z') || (dest_str[i] >= 'A' && dest_str[i] <= 'Z')) {
                    realType[j++] = dest_str[i];
                }
            }
            property_data_type = [NSString stringWithFormat:@"%s", realType];
            
            free(realType);
        } else {
            //Otherwise, take the second subscript character for comparing to the @encode()
            char * realType = [self getPropertyRealType:property_attr];
            property_data_type = [NSString stringWithFormat:@"%s", realType];
        }
        //构建setter方法名
        NSString *setterName = propertyName;
        //通过setter方法名反射setter方法
        SEL propertySelector = NSSelectorFromString(setterName);
        
        if ([cla respondsToSelector:propertySelector]) {
            if ([property_data_type isEqualToString:@"NSInteger"]||[property_data_type isEqualToString:@"int"]) {
                NSInteger propert = ((id (*)(id, SEL))objc_msgSend)(cla,propertySelector);
                [dictionary setObject:@(propert) forKey:propertyName];
            }
            else if ([property_data_type isEqualToString:@"BOOL"])
            {
                BOOL boolProperty = ((id (*)(id, SEL))objc_msgSend)(cla, propertySelector);
                [dictionary setObject:[NSString stringWithFormat:@"%d",boolProperty] forKey:propertyName];
            }
            else if([property_data_type isEqualToString:@"NSString"]){
                NSString *propertyValue = ((id (*)(id, SEL))objc_msgSend)(cla,propertySelector);
                if (propertyValue.length>0) {
                   [dictionary setObject:propertyValue forKey:propertyName];
                }
            }
//            else if([property_data_type isEqualToString:@"YXMessageBody"]){
//                NSString *propertyValue = objc_msgSend(cla,NSSelectorFromString(@"msgBody"));
//                if (propertyValue) {
//                    [dictionary setObject:propertyValue forKey:@"msgBody"];
//                }
//            }
        }
 
    }
    return dictionary;
}

+ (char *)getPropertyRealType:(const char *)property_attr {
    char * type;
    
    char t = property_attr[1];
    NSString *typ = [NSString stringWithFormat:@"%c",t];
    const char *tt = [typ UTF8String];
    
    if (strcmp(tt, @encode(char)) == 0) {
        type = "char";
    } else if (strcmp(tt, @encode(BOOL)) == 0) {
        type = "BOOL";
    }else if (strcmp(tt, @encode(NSInteger)) == 0) {
        type = "NSInteger";
    }else if (strcmp(tt, @encode(id)) == 0) {
        type = "id";
    } else if (strcmp(tt, @encode(Class)) == 0) {
        type = "Class";
    } else if (strcmp(tt, @encode(SEL)) == 0) {
        type = "SEL";
    }else if (strcmp(tt, @encode(int)) == 0) {
        type = "int";
    } else if (strcmp(tt, @encode(short)) == 0) {
        type = "short";
    }  else if (strcmp(tt, @encode(long long)) == 0) {
        type = "long long";
    } else if (strcmp(tt, @encode(unsigned char)) == 0) {
        type = "unsigned char";
    } else if (strcmp(tt, @encode(unsigned int)) == 0) {
        type = "unsigned int";
    } else if (strcmp(tt, @encode(unsigned short)) == 0) {
        type = "unsigned short";
    } else if (strcmp(tt, @encode(unsigned long)) == 0) {
        type = "unsigned long";
    } else if (strcmp(tt, @encode(unsigned long long)) == 0) {
        type = "unsigned long long";
    } else if (strcmp(tt, @encode(float)) == 0) {
        type = "float";
    } else if (strcmp(tt, @encode(double)) == 0) {
        type = "double";
    }  else if (strcmp(tt, @encode(void)) == 0) {
        type = "void";
    } else if (strcmp(tt, @encode(char *)) == 0) {
        type = "char *";
    } else if(strcmp(tt, @encode(long))==0){
        type = "NSInteger";
    }
    else{
        type = "";
    }
    return type;
}

/**
 获取属性名和属性类型
 
 @param cla 类
 @return 属性名和属性类型的字典
 */
+(NSDictionary *)getNameAndTypeOfProperty:(id)cla
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    unsigned int outCount = 0, i = 0;
    NSString *property_data_type = nil;
    objc_property_t *properties = class_copyPropertyList([cla class], &outCount);
    for (i=0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //获得属性名
        const char *property_name = property_getName(property);
        NSString *propertyName = [NSString stringWithFormat:@"%s",property_name];
        
        //获得属性类型
        const char * property_attr = property_getAttributes(property);
        
        //If the property is a type of Objective-C class, then substring the variable of `property_attr` in order to getting its real type
        if (property_attr[1] == '@') {
            char * occurs1 =  strchr(property_attr, '@');
            char * occurs2 =  strrchr(occurs1, '"');
            char dest_str[40]= {0};
            strncpy(dest_str, occurs1, occurs2 - occurs1);
            char * realType = (char *)malloc(sizeof(char) * 50);
            int i = 0, j = 0, len = (int)strlen(dest_str);
            for (; i < len; i++) {
                if ((dest_str[i] >= 'a' && dest_str[i] <= 'z') || (dest_str[i] >= 'A' && dest_str[i] <= 'Z')) {
                    realType[j++] = dest_str[i];
                }
            }
            property_data_type = [NSString stringWithFormat:@"%s", realType];
            
            free(realType);
        } else {
            //Otherwise, take the second subscript character for comparing to the @encode()
            char * realType = [self getPropertyRealType:property_attr];
            property_data_type = [NSString stringWithFormat:@"%s", realType];
        }

        [dictionary setObject:property_data_type forKey:propertyName];
    }
    return dictionary;
}

/**
 反射属性到数据库
 
 @param dictionary 属性名为key，属性值为value的字典
 */
+(NSDictionary *)reflexPropertyToDataBase:(NSDictionary *)dictionary
{
    NSArray *keyArray = [dictionary allKeys];
    NSMutableDictionary *reflexDic = [NSMutableDictionary dictionary];
    for(NSString *keyString in keyArray){
        const char *keyChar = [keyString UTF8String];
        NSMutableString *mutableString = [NSMutableString string];
        id value = [dictionary objectForKey:keyString];
        unsigned long length = strlen(keyChar);
        int temp = 0;
        for (int i=0; i<length+1; i++) {
            if (keyChar[i] !='\0') {
                if (isupper(keyChar[i])) {
                    //截取字符串
                    NSRange range = NSMakeRange(temp, i-temp);
                    
                    NSString *startString = [keyString substringWithRange:range];
                    if (temp != 0) {
                        [mutableString appendString:@"_"];
                    }
                    [mutableString appendString:[startString uppercaseString]];
                    temp = i;
                }
                
            }
            else{
                NSRange range = NSMakeRange(temp, i-temp);
                NSString *subString = [keyString substringWithRange:range];
                if (temp == 0) {
                    [mutableString appendString:[subString uppercaseString]];
                }
                else{
                    [mutableString appendString:@"_"];
                    [mutableString appendString:[subString uppercaseString]];
                }
                break;
            }
            
        }
        [reflexDic setObject:value forKey:mutableString];
    }
    return reflexDic;
}

+(NSDictionary *)reflexDataBaseToProperty:(NSDictionary *)dictionary
{
    NSArray *keyArray = [dictionary allKeys];
    NSMutableDictionary *reflexDic = [NSMutableDictionary dictionary];
    for(NSString *keyString in keyArray)
    {
        //将数据库的名字转换为字符串名
        NSArray *array = [keyString componentsSeparatedByString:@"_"];
        NSMutableString *mutableString = [NSMutableString string];
        if (array.count>0) {
            for (int i=0;i<array.count;i++) {
                NSString *string = [array objectAtIndex:i];
                NSString *lowString = [string lowercaseString];
                if (i==0) {
                    [mutableString appendString:lowString];
                }
                else{
                    [mutableString appendString: [self getFirstLetterFromString:lowString]];
                }
            }
        }
        else{
            [mutableString appendString:[keyString lowercaseString]];
        }
        [reflexDic setObject:[dictionary objectForKey:keyString] forKey:mutableString];
    }
    return reflexDic;
}

/**
 反射数据库的数据到属性值
 
 @param dictionary 数据库的字段为key，字段值为value的字典
 */
+(void)reflexDataBaseToProperty:(NSDictionary *)dictionary AndClass:(id)cla
{
    NSDictionary *propertyDic = [self getNameAndTypeOfProperty:cla];
    NSArray *propertyArray = [propertyDic allKeys];
    NSArray *keyArray = [dictionary allKeys];
    for(NSString *keyString in keyArray)
    {
        //将数据库的名字转换为属性名
        NSArray *array = [keyString componentsSeparatedByString:@"_"];
        //存储属性名字
        NSMutableString *mutableString = [NSMutableString string];
        if (array.count>0) {
            for (int i=0;i<array.count;i++) {
                NSString *string = [array objectAtIndex:i];
                NSString *lowString = [string lowercaseString];
                if (i==0) {
                    [mutableString appendString:lowString];
                }
                else{
                    [mutableString appendString: [self getFirstLetterFromString:lowString]];
                }
            }
        }
        else{
            [mutableString appendString:[keyString lowercaseString]];
        }
        
//        if([cla isKindOfClass:[YXMessage class]]){
//            if([mutableString isEqualToString:@"msgBody"]){
//                mutableString=[NSMutableString stringWithFormat:@"%@",@"body" ];
//            }
//        }
        
        
        for(NSString *propertyString in propertyArray)
        {
            if ([propertyString isEqualToString:mutableString]) {
               //构建setter方法名
                NSString *setterName = [NSString stringWithFormat:@"set%@:",[self getFirstLetterFromString:propertyString]];
                
                //通过setter方法名反射setter方法
                SEL propertySelector = NSSelectorFromString(setterName);
                
                if ([cla respondsToSelector:propertySelector]) {
                    if ([[propertyDic objectForKey:propertyString]isEqualToString:@"NSInteger"]) {
                        NSInteger value = [[dictionary objectForKey:keyString]integerValue];
                        ((void(*)(id, SEL,NSInteger))objc_msgSend)(cla,propertySelector,value);
                       
                    }
                   else if ([[propertyDic objectForKey:propertyString]isEqualToString:@"int"]) {
                        NSInteger value = [[dictionary objectForKey:keyString]integerValue];
                        ((void(*)(id, SEL,NSInteger))objc_msgSend)(cla,propertySelector,value);
                        
                    }
                    else if ([[propertyDic objectForKey:propertyString]isEqualToString:@"BOOL"]){
                        BOOL value = [dictionary objectForKey:keyString];
                        ((void(*)(id, SEL,BOOL))objc_msgSend)(cla,propertySelector,value);
                    }
                   //
//                    else if([[propertyDic objectForKey:propertyString]isEqualToString:@"YXMessageBody"]){
//                        if([cla isKindOfClass:[YXMessage class]]){
//
//                            if([propertyString isEqualToString:@"body"]){
//                                NSString *value=[dictionary objectForKey:keyString];
//                                ((void(*)(id, SEL,NSString*))objc_msgSend)(cla,NSSelectorFromString(@"setMsgBody:"),value);
//                            }
//                        }
//
//                    }
                    else{
                        id value = [dictionary objectForKey:keyString];
                        value=[NSString stringWithFormat:@"%@",value ];
                        ((void(*)(id, SEL,NSString*))objc_msgSend)(cla,propertySelector,value);
                    }
                }
            }
        }
    }
}

//获取字符串首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)getFirstLetterFromString:(NSString *)aString
{
    if (aString.length>0) {
        //转成了可变字符串
        NSMutableString *str = [NSMutableString string];
        //转化为大写拼音
        NSString *firstChar = [[aString substringToIndex:1] uppercaseString];
        
        NSString *lastString = [aString substringFromIndex:1];
        
        [str appendString:firstChar];
        
        [str appendString:lastString];
        
        //获取并返回首字母
        return str;

    }
    return nil;
}

@end
