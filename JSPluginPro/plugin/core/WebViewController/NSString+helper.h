//
//  NSString+helper.h
//  QIMPro
//
//  Created by LiYuan on 2017/4/12.
//  Copyright © 2017年 hzh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (helper)

- (BOOL)isChinese;//判断是否是纯汉字

- (BOOL)includeChinese;//判断是否含有汉字

- (instancetype)firstCharactor;

+ (instancetype)stringToDate:(NSString *)string formatter:(NSString *)format;

@end
