//
//  EnvReady.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "EnvReady.h"
#import "IProgressMonitorDelegate.h"
#import "Status.h"
#import "ConfigPreference.h"
#import "FileAccessor.h"
//test
#import "HttpClient.h"
#import "ZipArchive.h"
#import "FoxFileManager.h"
@interface EnvReady(){
    /**
     * 标志是否已经启动
     */
    BOOL started;
    HttpClient *client;
}
@end
@implementation EnvReady
-(id)init{
    if(self=[super init]){
        started=NO;
    }
    return self;
}
-(Status*)start:(id)context monitor:(id<IProgressMonitorDelegate>)monitor{
  
  client=[HttpClient new];
//  [client directDownload:@"https://y.gtimg.cn/mediastyle/app/download/img/mac/pic_1.jpg?max_age=2592000" savePath:@"" timeout:@"100" callback:nil];
//
    
    
     
    　 
    
    
    
   
    
    
//    //Caches路径
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
//    //zip压缩包保存路径
//    NSString *path = [cachesPath stringByAppendingPathComponent:@"testZip.zip"];//创建不带密
//
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    ZipArchive * zipArchive = [ZipArchive new];
//    [zipArchive CreateZipFile2:path];
//
//     NSString *dd=[cachesPath stringByAppendingPathComponent:@"testZip"] ;
//
//    NSArray *subPaths = [fileManager subpathsAtPath:dd];// 关键是subpathsAtPath方法
//    for(NSString *subPath in subPaths){
//        NSString *fullPath = [dd stringByAppendingPathComponent:subPath];
//        BOOL isDir;
//        if([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir)// 只处理文件
//        {
//            [zipArchive addFileToZip:fullPath newname:subPath];
//        }
//    }
//    [zipArchive CloseZipFile2];
//
    
    
    
    
   // [NSThread sleepForTimeInterval:1];
    // 获取配置
    ConfigPreference* pref = [ConfigPreference getInstance];
    // 获取服务器地址
    NSString *s = [pref getString:@"environment" key:@"clearDirs" defaultValue:@""];
    
    
    NSArray* ss =[s componentsSeparatedByString:@","];

    // 获取文件访问器
    FileAccessor* fileAccessor = [FileAccessor getInstance];

    for (int i = 0; i < ss.count; i++) {
        // 删除目录
        [fileAccessor delete:ss[i]];
    }
    
    return  [[Status alloc] initWithCode:Status.SUCCESS] ;
}
-(Status*)stop:(id)context monitor:(id<IProgressMonitorDelegate>)monitor{
  return  [[Status alloc] initWithCode:Status.SUCCESS] ;
}
-(BOOL)isStarted{
    return YES;
}
@end
