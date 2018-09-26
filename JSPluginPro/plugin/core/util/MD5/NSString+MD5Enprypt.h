//
//  NSString+MD5.h
//  DEVSNS
//
//  Created by lee peter on 13-9-6.
//  Copyright (c) 2013年 sun lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5Enprypt)
//md5加密，小写
+(NSString *)md5Enprypt:(NSString *)str;
//md5加密，大写
+(NSString *)MD5Enprypt:(NSString *)str;

@end
