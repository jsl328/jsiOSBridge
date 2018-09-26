//
//  licenseList.h
//  licenseList
//
//  Created by LiYuan on 16/8/24.
//  Copyright © 2016年 yusys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface licenseList : NSObject

/**
 *  检验json文件
 *
 *  @param licenseName lsc文件的文件名
 *
 *  @return 检验结果
 */
+ (NSString *)checkJsonStringOfProjectLicense:(NSString *)licenseName;

/**
 *  检验插件工程的lsc文件
 *
 *  @param licenseName lsc文件的文件名
 *
 *  @return 解密、验签后的信息
 */
+ (NSDictionary *)DecryptionStringOfLicenseFile:(NSString *)licenseName;
@end
