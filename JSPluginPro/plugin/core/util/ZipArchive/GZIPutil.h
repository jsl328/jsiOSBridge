//
//  GZIPutil.h
//  core
//
//  Created by BruceXu on 2018/4/20.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GZIPutil : NSObject
+(void) doZipAtPath:(NSString*)sourcePath to:(NSString*)destZipFile;
+ (NSData *)unzip:(NSData*)data;
+(NSData *)zip:(NSData *)uncompressedData;
@end
