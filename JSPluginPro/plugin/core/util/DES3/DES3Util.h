//
//  DES3Util.h
//  Check
//
//  Created by guoxd on 16/1/6.
//  Copyright © 2016年 yaosx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXGTMBase64.h"
#import <CommonCrypto/CommonCryptor.h>
@interface DES3Util : NSObject
// 加密方法
+ (NSString*)encrypt:(NSString*)plainText key:(NSString *)key;
// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText key:(NSString *)key;
@end
