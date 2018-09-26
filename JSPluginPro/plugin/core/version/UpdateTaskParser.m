//
//  UpdateTaskParser.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/21.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "UpdateTaskParser.h"
#import "ConfigPreference.h"
#import "IUpdateTaskDelegate.h"
#import "FileAccessor.h"
@interface UpdateTaskParser(){
   

}

@end
@implementation UpdateTaskParser

/**
 * 批量下载单元大小
 */
  static long downloadUnitSize = 1024 * 1024 * 3;

/**
 * 批量下载单元数量
 */
static int downloadUnitCount =50;

/**
 * 大文件大小
 */
  static long largeFileSize = 1024 * 1024 * 5;
+ (void)initialize {
    
   downloadUnitSize = [[ConfigPreference getInstance] getLong:@"version" key:@"downloadUnitSize" defaultValue:1024 * 1024 * 3];
    //批量下载单元数量(100个)
   
    downloadUnitCount = [[ConfigPreference getInstance] getInt:@"version" key:@"downloadUnitCount" defaultValue:50];
    //大文件大小(5M)
    largeFileSize = [[ConfigPreference getInstance] getLong:@"version" key:@"largeFileSize" defaultValue:1024 * 1024 * 5L];
    
}


/**
 * new updateTask对象
 *
 * param clazz
 * return
 */
+ (id<IUpdateTaskDelegate>) newUpdateTask:(Class) clazz {
   
        id<IUpdateTaskDelegate> updateTask = (id<IUpdateTaskDelegate>)[[clazz alloc] init];
        return updateTask;
   
    
}

/**
 * 解析更新任务
 *
 * param config
 * return
 */
+(NSArray<id<IUpdateTaskDelegate>>*) parseUpdateTask:(NSString*) config class:(Class) clazz {
    if (config == nil || config.length == 0) {
        return nil;
    }

    // 获取任务item
    NSArray* configItems = [config componentsSeparatedByString:@";"];
    if (configItems.count == 0) {
        return nil;
    }


    // 定义更新任务列表
    NSMutableArray<id<IUpdateTaskDelegate>>*updateTaskList= [NSMutableArray<id<IUpdateTaskDelegate>> new];
    
    for (int i = 0; i < configItems.count; i++) {
        NSString *s = configItems[i];
        if(!s||s.length==0) continue;
        int len = (int)s.length;
        if(([s characterAtIndex:0] == '[')&&([s characterAtIndex:len - 1] == ']')){
           
            s=[s substringFromIndex:1];
            s=[s substringToIndex:s.length-1];
            id<IUpdateTaskDelegate> task =[self parseTaskForArray:s class:clazz];
            if (task != nil) {
                [updateTaskList addObject:task];
            }
        } else if(([s characterAtIndex:0] == '{')&&([s characterAtIndex:len - 1] == '}')){
            s=[s substringFromIndex:1];
            s=[s substringToIndex:s.length-1];
            id<IUpdateTaskDelegate> task =[self parseTaskForJson:s class: clazz];
            if (task !=nil) {
                [updateTaskList addObject:task];
            }
        } else {
            NSLog(@"%@%@",@"更新任务解析错误 src:", s);
        }
    }
    return updateTaskList;
   
    
}
/**
 * 解析JSON格式任务
 *
 * param s
 * return
 */
+(id<IUpdateTaskDelegate>) parseTaskForJson:(NSString*) s class:(Class) clazz {
    // 获取File访问器
    FileAccessor *fileAccessor = [FileAccessor getInstance];
    // 获取参数
    NSArray<NSString*>* ss =  [s componentsSeparatedByString:@","];
    @try {
        // 定义任务
         id<IUpdateTaskDelegate> updateTask =[self newUpdateTask:clazz];
        //设置默认值
        [updateTask setDownloadUnitCount:downloadUnitCount];
        [updateTask setDownloadUnitSize:(downloadUnitSize)];
        [updateTask setLargeFileSize:largeFileSize];
        
        for (int i = 0; i < ss.count; i++) {
            
            NSArray<NSString*> *items =  [ss[i] componentsSeparatedByString:@":"];
            NSString* key = items[0];
            NSString *value = items[1];
            if([@"requestPath" isEqualToString:key.lowercaseString ]){
               [updateTask setRequestPath:value];
               
            } else  if([@"savePath" isEqualToString:key.lowercaseString ]){
                NSString* saveFile = [fileAccessor getFile:value];
                [updateTask setSaveFile:saveFile];
               
            } else  if([@"updatedRestart" isEqualToString:key.lowercaseString ]){
                BOOL updatedRestart = [@"true" isEqualToString:((NSString*)value).lowercaseString ];
                [updateTask setUpdatedRestart:updatedRestart];
          
            } else if([@"necessary" isEqualToString:key.lowercaseString ]){
                BOOL necessary = [@"true" isEqualToString:((NSString*)value).lowercaseString ];
                [updateTask setNecessary:necessary];
            
            } else if([@"timeout" isEqualToString:key.lowercaseString ]){
                int timeout = [value intValue];
                [updateTask setTimeout:timeout];
          
            } else  if([@"downloadUnitCount" isEqualToString:key.lowercaseString ]){
                int downloadUnitCount = [value intValue];
                [updateTask setDownloadUnitCount:downloadUnitCount];
            
            } else  if([@"downloadUnitSize" isEqualToString:key.lowercaseString ]){
                long downloadUnitSize =[value longLongValue];
                [updateTask setDownloadUnitSize:downloadUnitSize];
            
            } else if([@"largeFileSize" isEqualToString:key.lowercaseString ]){
                long largeFileSize =[value longLongValue];
                [updateTask setLargeFileSize:largeFileSize];
            } else {
                NSLog(@"%@%@",@"更新任务解析错误，未知属性 attr:" , key);
            }
        }
        return updateTask;
    } @catch (NSException* e) {
        NSLog(@"%@",e);
        return nil;
    }
    
}

/**
 * 解析数组格式任务
 *
 * param s
 * return
 */
+ (id<IUpdateTaskDelegate>) parseTaskForArray:(NSString*) s class: (Class) clazz{
    
    // 获取File访问器
    FileAccessor* fileAccessor = [FileAccessor getInstance];
    // 获取参数
    NSArray* ss =  [s componentsSeparatedByString:@","];
    @try {
        // 定义任务
        id<IUpdateTaskDelegate> updateTask =[self newUpdateTask:clazz];
        if (ss.count == 2) {
            // 参数列表:requestPath,savePath
            NSString *requestPath = ss[0];
            NSString * saveFile = [fileAccessor getFile:ss[1]];
            [updateTask setRequestPath:requestPath];
            [updateTask setSaveFile:saveFile];

            [updateTask setDownloadUnitCount:downloadUnitCount];
            [updateTask setDownloadUnitSize:(downloadUnitSize)];
            [updateTask setLargeFileSize:largeFileSize];
        } else if (ss.count == 3) {
            // 参数列表:requestPath,savePath，updatedRestart
            NSString* requestPath = ss[0];
            NSString* saveFile = [fileAccessor getFile:ss[1]];
            
           BOOL updatedRestart = [@"true" isEqualToString:((NSString*)ss[2]).lowercaseString ];

            [updateTask setRequestPath:requestPath];
            [updateTask setSaveFile:saveFile];
            [updateTask setUpdatedRestart:updatedRestart];

            [updateTask setDownloadUnitCount:downloadUnitCount];
            [updateTask setDownloadUnitSize:(downloadUnitSize)];
            [updateTask setLargeFileSize:largeFileSize];
        } else {
            // 参数列表:requestPath,savePath,updatedRestart,necessary,timeout,batchDownloadThreshold
            NSString *requestPath = ss[0];
            NSString* saveFile = [fileAccessor getFile: ss[1]];
            BOOL updatedRestart = [@"true" isEqualToString:((NSString*)ss[2]).lowercaseString ];
            BOOL necessary = [@"true" isEqualToString:((NSString*)ss[3]).lowercaseString ];
            int timeout = [((NSString*)ss[4]) intValue ];
            int downloadUnitCount = [((NSString*)ss[5]) intValue ];
            long downloadUnitSize = [((NSString*)ss[6]) longLongValue ];
            long largeFileSize =  [((NSString*)ss[7]) longLongValue ];

            [updateTask setRequestPath:requestPath];
            [updateTask setSaveFile:saveFile];
            [updateTask setUpdatedRestart:updatedRestart];
            [updateTask setTimeout:timeout];
            [updateTask setNecessary:necessary];

            [updateTask setDownloadUnitCount:downloadUnitCount];
            [updateTask setDownloadUnitSize:(downloadUnitSize)];
            [updateTask setLargeFileSize:largeFileSize];
        }
        return updateTask;
    } @catch (NSException * e) {
        NSLog(@"%@",e);
        return nil;
    }
    
}





















@end
