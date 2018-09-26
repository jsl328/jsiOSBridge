//
//  FileCache.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/17.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCache : NSObject
-(id)initWithPath:(NSString*)path_;


-(NSData*)read;
-(void)write:(NSData*)bytes;
/**
 * 判断文件是否存在
 * return
 */
-(BOOL) exists;
/**
 * 判断文件是否被修改
 *
 * 
 */
-(BOOL)isModified;


@end
