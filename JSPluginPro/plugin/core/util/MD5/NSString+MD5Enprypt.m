//
//  NSString+MD5.m
//  DEVSNS
//
//  Created by lee peter on 13-9-6.
//  Copyright (c) 2013年 sun lin. All rights reserved.
//

#import "NSString+MD5Enprypt.h"

#import <CommonCrypto/CommonDigest.h>


@implementation NSString (MD5Enprypt)

+(NSString *)md5Enprypt:(NSString *)str {

    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (int)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(NSString *)MD5Enprypt:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, (int)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
