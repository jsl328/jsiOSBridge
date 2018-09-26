//
//  FileAccessor.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXPlugin.h"
@interface FileAccessor : NSObject
+ (instancetype)getInstance;
-(NSString *)constructAbsolutePath:(NSString*)path;
- (NSArray*) allFilesPathAtFPath:(NSString*) dirString withType:(NSString *)type;
- (NSArray*) allFilesNameAtFPath:(NSString*) dirString withType:(NSString *)type;
-(NSArray*)loadAllXMLNameFromCustomBundle;
-(NSArray*)loadAllXMLPathFromCustomBundle;
-(NSString *)getLocalRoot;
/**
 * 获取local cache root path
 *
 * return
 */
-(NSString *)getLocalCacheRoot ;

/**
 * 获取default root path
 *
 * @return
 */

-(NSString *)getDefaultRoot ;

-(NSString*)getFile:(NSString *)path;
-(BOOL)deleteFile:(NSString*) file;
/**
 * 删除此抽象路径名表示的文件或目录
 *
 * @param path
 * @return BOOL
 */
- (BOOL)delete:(NSString *)path;
- (BOOL)exists:(NSString *)path;
- (BOOL)isDirectory:(NSString *)path;
- (BOOL)isFile:(NSString *)path;
- (BOOL)createDirectoryAtPath:(NSString *)path;
- (BOOL)copy:(NSString*)srcPath destPath:(NSString*)destPath;
- (BOOL)move:(NSString*)srcPath destPath:(NSString*)destPath;
- (NSArray *)list:(NSString*)path;
- (long)length:(NSString *)path;
- (NSString*)getContentAsString:(NSString*)path encoding:(NSStringEncoding) encoding;
- (NSString*)getContentAsBase64:(NSString*)path;
-(NSData*) openFileData:(NSString *)file;
@end
