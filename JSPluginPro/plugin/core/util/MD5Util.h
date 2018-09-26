//
//  MD5Util.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/22.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#define FileHashDefaultChunkSizeForReadingData 1024*8
#include <CommonCrypto/CommonDigest.h>

@interface MD5Util : NSObject
+(NSString*) digestMD5:(NSString*)fullPathFile;
+(NSString*) digestDataMD5:(NSData*)data;

@end
