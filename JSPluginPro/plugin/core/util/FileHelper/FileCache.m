//
//  FileCache.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/17.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "FileCache.h"
#import "FoxFileManager.h"
@interface FileCache()
/**
 * 文件最后修改时间
 */
@property(assign) long lastModified ;
/**
 * 缓存
 */
@property(strong) NSData * cache;
/**
 * 文件路径
 */
@property(copy) NSString* path;
@end
@implementation FileCache
-(id)initWithPath:(NSString*)path_{
    if(self=[super init]){
        self.path=path_;
        self.cache=nil;
    }
    return self;
}
-(NSData*)read{
    if(![FoxFileManager isFileAtPath:_path]){
        return nil;
    }
    //标志是否需要重新加载文件
    BOOL reload = false;
    if(self.cache==nil){
        reload=YES;
    }
    else{
        long curModified= [[FoxFileManager attributeOfItemAtPath:self.path forKey:NSFileModificationDate] timeIntervalSince1970];
        if(self.lastModified!=curModified){
            reload=YES;
        }
        
    }
    //重新加载文件
    if (reload) {
        _lastModified=[[FoxFileManager attributeOfItemAtPath:self.path forKey:NSFileModificationDate] timeIntervalSince1970];
        
       _cache=  [NSData dataWithContentsOfFile:self.path];
    }
    return [self.cache copy];
    
}
-(void)write:(NSData*)bytes{
    NSData *newBytes=[bytes copy];
    self.cache=newBytes;
    //不存在文件，新建文件
    if(![FoxFileManager isExistsAtPath:_path])
    {
        [FoxFileManager createFileAtPath:_path];
    }
    [FoxFileManager writeFileAtPath:_path content:newBytes];
    _lastModified=[[FoxFileManager attributeOfItemAtPath:self.path forKey:NSFileModificationDate] timeIntervalSince1970];
    int iii=0;
}
/**
 * 判断文件是否存在
 * return
 */
-(BOOL) exists{
  return  [FoxFileManager isExistsAtPath:self.path];
}
/**
 * 判断文件是否被修改
 *
 * return
 */
-(BOOL)isModified{
    if([self exists]==false){
        return false;
    }
    if(self.cache==nil){
        return YES;
    }
    else{
        long curModified= [[FoxFileManager  attributeOfItemAtPath:self.path forKey:NSFileModificationDate] timeIntervalSince1970];
        if (self.lastModified != curModified) {
            return true;
        }
    }
    return false;
}












@end
