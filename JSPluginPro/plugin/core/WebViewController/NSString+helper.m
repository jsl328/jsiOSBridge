//
//  NSString+helper.m
//  QIMPro
//
//  Created by LiYuan on 2017/4/12.
//  Copyright © 2017年 hzh. All rights reserved.
//

#import "NSString+helper.h"

@implementation NSString (helper)

- (instancetype)firstCharactor
{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:self];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

- (BOOL)isChinese
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

- (BOOL)includeChinese
{
    for(int i=0; i< [self length];i++)
    {
        int a =[self characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

+ (instancetype)stringToDate:(NSString *)string formatter:(NSString *)format {
    NSTimeInterval second = string.longLongValue / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    NSString *res = [formatter stringFromDate:date];
    return res;
}

@end
