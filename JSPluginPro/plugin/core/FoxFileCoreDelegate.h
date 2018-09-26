//
//  FoxFileCoreDelegate.h
//  YXBuilder
//
//  Created by LiYuan on 2017/12/22.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@protocol FoxFileCoreDelegate <JSExport>

JSExportAs (openFile, - (void)openFile:(NSString *)path title:(NSString*)titile water:(NSString*)water  callback:(NSString *)callback);

JSExportAs (getAbsolutePath, - (NSString *)getAbsolutePath:(NSString *)path);

JSExportAs (getContentAsString, - (void)getContentAsString:(NSString *)path encoding:(NSString *)encoding  callback:(NSString *)callback);

JSExportAs (getContentAsBase64, - (void)getContentAsBase64:(NSString *)path  callback:(NSString *)callback);

JSExportAs (exists, - (BOOL)exists:(NSString *)path);

JSExportAs (isDirectory, - (BOOL)isDirectory:(NSString *)path);

JSExportAs (isFile, - (BOOL)isFile:(NSString *)path);

JSExportAs (length, - (NSInteger)length:(NSString *)path);

JSExportAs (delete, - (void)deletePath:(NSString *)path callback:(NSString *)callback);

JSExportAs (list, - (void)list:(NSString *)path callback:(NSString *)callback);

JSExportAs (copy, - (void)copySrcPath:(NSString *)srcPath destPath:(NSString *)destPath  callback:(NSString *)callback);

JSExportAs (move, - (void)moveSrcPath:(NSString *)srcPath destPath:(NSString *)destPath  callback:(NSString *)callback);

JSExportAs (choose, - (void)choose:(NSString *)path reqData:(NSString *)reqData  callback:(NSString *)callback);

@end
