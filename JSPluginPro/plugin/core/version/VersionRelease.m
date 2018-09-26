//
//  VersionRelease.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/16.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "VersionRelease.h"
#import "ZipArchive.h"
#import "FoxFileManager.h"
#import "FileAccessor.h"
#import "Platform.h"


@interface VersionRelease(){
    
}

@end
@implementation VersionRelease
static VersionRelease *_instance;



+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
/**
 * 判断版本是否已经更新
 *
 *
 */
-(BOOL)isModified{//1-1.0.3
    //.........
    FileAccessor *fileAccessor=[FileAccessor getInstance];
    // 获取APP版本标识
    NSString* versionMark = [self getAppVersionMark];//比如升级之后 变为2.0 而version_init.properties为1.0，那么
    // 获取版本文件名称
    NSString* versionFileName = @"version/version_init.properties";
    NSString *file=[fileAccessor getFile:versionFileName];
    
    if([FoxFileManager isFileAtPath:file]){
        //获取当前版本号
        NSData * data = [NSData dataWithContentsOfFile: file];
        NSString *curVersionMark = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([versionMark isEqualToString:curVersionMark]) {
            return false;
        }
    }
    return YES;
}
/**
 * 恢复版本
 *
 * return
 */
-(BOOL)recover{
    
    NSString *bundlePath=  [[NSBundle mainBundle ]pathForResource:@"version" ofType:@"bundle"];
    NSArray * srcFileNames=  [[FileAccessor getInstance] allFilesNameAtFPath:bundlePath withType:@"zip"];
    
    if(srcFileNames&&srcFileNames.count>0){
        //发布版本列表
        NSMutableArray<NSString*>* releaseList =  [NSMutableArray<NSString*> new ];
        //获取包名
        NSString* packageName=@"fox.app";
        
        //优先查找和包名匹配的
        for (int i = 0; i < srcFileNames.count; i++) {
            //判断是否符合
            if ([srcFileNames[i] hasPrefix:packageName]) {
                [releaseList addObject:(srcFileNames[i])];
            }
        }
        //如果无法找到和包名匹配的，那么默认查找以version为前缀的文件
        if (releaseList.count == 0) {
            for (int i = 0; i < srcFileNames.count; i++) {
                //判断是否符合
                if ([srcFileNames[i] hasPrefix:@"version"]) {
                    [releaseList addObject:srcFileNames[i]];
                }
            }
        }
        
        int size = (int)releaseList.count;
        // 计算下载任务量
        int taskSize = 100 / size;
        if (taskSize == 0) {
            taskSize = 1;
        }
        
        //获取file accessor
        FileAccessor *fileAccessor = [FileAccessor getInstance];
        
        //获取输出目录
        NSString* outDir = [fileAccessor getDefaultRoot];
        //获取缓存目录
        NSString *cacheDir = [fileAccessor getLocalCacheRoot];
        
        //获取输出目录列表
        
        NSArray* files =  [FoxFileManager listFilesInDirectoryAtPath:cacheDir deep:NO];
        if (files != nil && files.count > 0) {
            //删除文件
            for (int i = 0; i < files.count; i++) {
                [fileAccessor deleteFile:   [cacheDir stringByAppendingPathComponent:files[i]]];
            }
        }
        
        for (int i = 0; i < size; i++) {
            NSString *fileName = releaseList[i];
            NSString *msg=[NSString stringWithFormat:@"解压初始版本文件:%@",fileName ];
            FOXLog(@"%@",msg);
            NSString* srcFilePath = [bundlePath stringByAppendingPathComponent:fileName];
            // 定义输入文件
            NSString * targetFile = [cacheDir stringByAppendingPathComponent:fileName];
            // 拷贝文件
            [self copy:srcFilePath targetFile:targetFile];
            // 解压文件
            ZipArchive *unzip = [[ZipArchive alloc] init];
            if ([unzip UnzipOpenFile:targetFile]) {
                BOOL success=   [unzip UnzipFileTo:outDir  overWrite:YES];
                FOXLog(@"解压结果:%@",success?@"成功":@"失败");
                FOXLog(@"解压路径=%@",outDir);
                [unzip UnzipCloseFile];
                
            }
            // 删除文件
            [[NSFileManager defaultManager] removeItemAtPath:targetFile error:nil];
        }
        return true;
    }
    
    // 返回失败
    return false;
}

/**
 * 发布版本
 *
 * param monitor
 * return
 */

-(Status*)release:(id<IProgressMonitorDelegate>)monitor{
    
    //判断手机剩余空间
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    
    NSNumber *leftSpace= [fattributes objectForKey:NSFileSystemFreeSize];
    float space=[leftSpace floatValue]/1024/1024;
    if(space<100){//M
        return   [[Status alloc] initWithCode:Status.EXIT];
    }
  NSString *fff=  NSHomeDirectory();
  if(TESTLOAD){
   
    /***************
     暂时屏蔽，为了防止增量更新覆盖
     ******************/
     [self  releaseToPath];
   
     [monitor done];
        return   [[Status alloc] initWithCode:Status.SUCCESS];
        
    }
    else{
    
    //判断版本是否已经修改
    BOOL flag = [self isModified];
    if (!flag) {
        FOXLog(@"%@",@"版本标志一致，不需要发布初始版本");
        [monitor done];
        return   [[Status alloc] initWithCode:Status.SUCCESS];
    }
    FOXLog(@"%@",@"版本标志不一致，需要发布初始版本");
    
    @try{
        NSString *bundlePath=  [[NSBundle mainBundle ]pathForResource:@"version" ofType:@"bundle"];
        NSArray * srcFileNames=  [[FileAccessor getInstance] allFilesNameAtFPath:bundlePath withType:@"zip"];
        
        if(srcFileNames&&srcFileNames.count>0){
            FileAccessor* fileAccessor =[FileAccessor getInstance];
            //发布版本列表
            NSMutableArray<NSString*>* releaseList =  [NSMutableArray<NSString*> new ];
            //NSString* packageName=@"fox.app";
             NSString* packageName=@"web-phone";
            //优先查找和包名匹配的
            for (int i = 0; i < srcFileNames.count; i++) {
                //判断是否符合
                if ([srcFileNames[i] hasPrefix:packageName]) {
                    [releaseList addObject:(srcFileNames[i])];
                }
            }
            //如果无法找到和包名匹配的，那么默认查找以version为前缀的文件
            if (releaseList.count == 0) {
                for (int i = 0; i < srcFileNames.count; i++) {
                    //判断是否符合
                    if ([srcFileNames[i] hasPrefix:@"version"]) {
                        [releaseList addObject:srcFileNames[i]];
                    }
                }
            }
            int size = (int)releaseList.count;
            if(size==0){
                  return  [[Status alloc] initWithCode:Status.FAIL];
            }
            // 计算下载任务量
            int taskSize = 100 / size;
            if (taskSize == 0) {
                taskSize = 1;
            }
            
            //获取输出目录
            NSString* outDir = [fileAccessor getDefaultRoot];
            //获取缓存目录
            NSString *cacheDir = [fileAccessor getLocalCacheRoot];
            
            for (int i = 0; i < size; i++) {
                NSString *fileName = releaseList[i];
                //设置任务任务名称
                NSString *taskName=[NSString stringWithFormat:@"解压初始版本文件(%d/%d)",(i + 1),size ];
                [monitor setTaskName:taskName];
                //打印日志
                NSString* msg =[NSString stringWithFormat:@"解压初始版本文件:%@",fileName ];
                FOXLog(@"%@",msg);
                
                NSString* srcFilePath = [bundlePath stringByAppendingPathComponent:fileName];
                
                // 定义输入文件
                NSString * targetFile = [cacheDir stringByAppendingPathComponent:fileName];
                // 拷贝文件
                [self copy:srcFilePath targetFile:targetFile];
                
                ZipArchive *unzip = [[ZipArchive alloc] init];
                if ([unzip UnzipOpenFile:targetFile]) {
                    BOOL success=   [unzip UnzipFileTo:outDir  overWrite:YES];
                    FOXLog(@"解压结果:%@",success?@"成功":@"失败");
                    FOXLog(@"解压路径=%@",outDir);
                    [unzip UnzipCloseFile];
                    
                }
                [[NSFileManager defaultManager] removeItemAtPath:targetFile error:nil];
                [monitor worked:taskSize];
            }
            
        }
        
        // 获取APP版本标识
        NSString *versionMark = [self getAppVersionMark];
        // 获取版本文件名称
        NSString* versionFileName =@"version/version_init.properties";
        
        NSString *filePath= [[FileAccessor getInstance] getFile:versionFileName];
        
        [FoxFileManager createFileAtPath:filePath  content:versionMark overwrite:YES];
        
        
        return  [[Status alloc] initWithCode:Status.SUCCESS];
    }
    @catch(NSException *e){
        FOXLog(@"%@",e);
        // 返回失败
        return  [[Status alloc] initWithCode:Status.FAIL];
    }
    @finally{
        [monitor done];
    }
    
    
    return nil;
    }
}


/**
 * 获取APP版本标识
 *
 *
 */
-(NSString*)getAppVersionMark{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return  app_Version;
    
    
}

//拷贝文件
-(BOOL)copy:(NSString*)srcFilePath targetFile:(NSString*)targetFile{
    if([[NSFileManager defaultManager] fileExistsAtPath:targetFile]){
        [[NSFileManager defaultManager] removeItemAtPath:targetFile error:nil];
    }
    NSString *parentDir =[FoxFileManager  directoryAtPath:targetFile];
    if(![FoxFileManager isExistsAtPath:parentDir]){
        [FoxFileManager createDirectoryAtPath:parentDir];
    }
    BOOL result=  [[NSFileManager defaultManager]copyItemAtPath:srcFilePath toPath:targetFile error:nil ];
    return result;
}


- (NSString *)releaseToPath {
    
    // 移动www路径
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    NSString *basePath = [[paths objectAtIndex:0] stringByAppendingPathComponent: TESTLOAD?@"Debug":@"Product"];
    
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Pandora/%@", APPID] ofType:@""];
    
    //移除basePath下的所有文件和文件夹
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:basePath];
    for (NSString *fileName in enumerator) {
     
        [[NSFileManager defaultManager] removeItemAtPath:[basePath stringByAppendingPathComponent:fileName] error:nil];
    }
    BOOL fff= [fileManager removeItemAtPath:basePath error:&error];
    NSLog(@"移除error=%@",error);
    BOOL fsdfdsf= [fileManager copyItemAtPath:resourcePath toPath:basePath error:&error];
     NSLog(@"拷贝error=%@",error);
    return [basePath stringByAppendingPathComponent:@"workspace"];
}












@end

