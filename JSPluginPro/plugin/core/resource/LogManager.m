//
//  LogManager.m
//  YXBuilder
//
//  Created by LiYuan on 2017/12/29.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "LogManager.h"
#import "FileAccessor.h"
#import "CocoaLumberjack.h"
@interface LogManager ()

@end

@implementation LogManager

static LogManager *_instance;

+ (instancetype)getIntance {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    @synchronized (self) {
        // 为了防止多线程同时访问对象，造成多次分配内存空间，所以要加上线程锁
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
            
            NSString *printPath = @"local://log/print";
            NSString *crashPath = @"local://log/crash";
            if (![[FileAccessor getInstance] exists:printPath]) {
                [[FileAccessor getInstance] createDirectoryAtPath:printPath];
            }
            if (![[FileAccessor getInstance] exists:crashPath]) {
                [[FileAccessor getInstance] createDirectoryAtPath:crashPath];
            }
            _instance.printAbsolutePath = [[FileAccessor getInstance] getFile:printPath];
            _instance.crashAbsolutePath = [[FileAccessor getInstance] getFile:crashPath];
        }
        return _instance;
    }
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return _instance;
}
- (instancetype)mutableCopyWithZone:(NSZone *)zone
{
    return _instance;
}

- (void)startLogWithCache:(BOOL)isCache {
    @try {
        
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        if (isCache) {
          
            // 设置文件路径
            DDLogFileManagerDefault *fileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:_printAbsolutePath];
            DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:fileManager];
            // 每天1个Log文件
            fileLogger.rollingFrequency = 60 * 60 * 24;
            // 单个文件最大5M
            fileLogger.maximumFileSize = 1024 * 1024 * 5;
            // 保存一周的日志文件
            fileManager.maximumNumberOfLogFiles = 7;
            // 总计最大35M，否则自动清理最前面的记录
            fileManager.logFilesDiskQuota = 1024 * 1024 * 35;
            [DDLog addLogger:fileLogger];
            
            
            }
    } @catch (NSException* e) {
        FOXLog(@"%@",e);
    }
}

@end
