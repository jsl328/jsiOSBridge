//
//  BreakPointDownLoad.m
//  core
//
//  Created by guoxd on 2018/1/24.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import "BreakPointDownLoad.h"
#import "CallBackObject.h"
#import "AFNetworking.h"
@interface BreakPointDownLoad()
@property (nonatomic,strong) NSURLSessionDataTask *task;
@property (nonatomic,strong) AFURLSessionManager *manager;
@property (nonatomic,strong) NSString *urlString;
@property (nonatomic,assign) double completed;
@property (nonatomic,strong) CallBackObject *callBackID;

/** AFNetworking断点下载（支持离线）需用到的属性 **********/
/** 文件的总长度 */
@property (nonatomic, assign) NSInteger fileLength;
/** 当前下载长度 */
@property (nonatomic, assign) NSInteger currentLength;
/** 文件句柄对象 */
@property (nonatomic, strong) NSFileHandle *fileHandle;
//是否需要验证证书
@property (nonatomic,assign) BOOL isValidatesCer;
@end
@implementation BreakPointDownLoad

-(void)call:(NSString *)action param:(NSString *)param callback:(id<ICallBackDelegate>)callback
{
    self.callBackID = callback;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    self.urlString = [dictionary objectForKey:@"url"];
    self.isValidatesCer = [[dictionary objectForKey:@"domainname"]boolValue];
    
    if([action isEqualToString:@"startBreakPointDownload"])
    {
        //文件保存路径
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DownLoads"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:path])
        {
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *filePath = [path stringByAppendingPathComponent:@"test.zip"];
        NSInteger currentLength = [self fileLengthForPath:filePath];
        //开始下载/继续下载
        if (currentLength > 0) {
            self.currentLength = currentLength;
        }
        [self.task resume];
        NSLog(@"self.task = %p",self.task);
    }
    else{
        NSLog(@"self.task = %p",self.task);
        [self.task suspend];
        self.task = nil;
    }
}
-(AFURLSessionManager *)manager
{
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 1. 创建会话管理者
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _manager;
}

-(NSURLSessionDataTask *)task
{
    if (!_task) {
        // 创建下载URL
        NSURL *url = [NSURL URLWithString:self.urlString];
        // 2.创建request请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // 设置HTTP请求头中的Range
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        __weak typeof(self) weakSelf = self;
        _task = [self.manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
            
        } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"downloadProgress = %@",downloadProgress.description);
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if(error){
                [self.callBackID run:CallBackObject.SUCCESS message:[error.userInfo objectForKey:@"NSLocalizedDescription"] data:@""];
                NSLog(@"error.userinfo = %@",[error.userInfo objectForKey:@"NSLocalizedDescription"]);
            }
            else{
                NSString *message = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                if(message.length == 0){
                    message = @"下载成功";
                }
                [self.callBackID run:CallBackObject.SUCCESS message:@"" data:message];
            }
        }];
        //设置数据任务并接收响应
        [self.manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
            
            // 获得下载文件的总长度：请求下载的文件长度 + 当前已经下载的文件长度
            weakSelf.fileLength = response.expectedContentLength;
            // 沙盒文件路径
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DownLoads/test.zip"];
            
            NSLog(@"File downloaded to: %@",path);
            // 创建一个空的文件到沙盒中
            NSFileManager *manager = [NSFileManager defaultManager];

            if (![manager fileExistsAtPath:path]) {
                // 如果没有下载文件的话，就创建一个文件。如果有下载文件的话，则不用重新创建(不然会覆盖掉之前的文件)
                [manager createFileAtPath:path contents:nil attributes:nil];
            }

            // 创建文件句柄
            weakSelf.fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
            
            // 允许处理服务器的响应，才会继续接收服务器返回的数据
            return NSURLSessionResponseAllow;
        }];
        //接收数据
        [self.manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
            
            // 指定数据的写入位置 -- 文件内容的最后面
            [weakSelf.fileHandle seekToEndOfFile];

            // 向沙盒写入数据
            [weakSelf.fileHandle writeData:data];

            // 拼接文件总长度
            weakSelf.currentLength += data.length;
            
            NSInteger progress = weakSelf.currentLength/weakSelf.fileLength;

            NSString *string = [NSString stringWithFormat:@"当前下载进度:%.2ld%%",(long)progress];
            NSLog(@"currentLength = %ld",weakSelf.currentLength);
            NSLog(@"fileLength = %ld",weakSelf.fileLength);
        }];
    }
    return _task;
}

/**
 * 获取已下载的文件大小
 */
- (NSInteger)fileLengthForPath:(NSString *)path {
    NSInteger fileLength = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileLength = [fileDict fileSize];
        }
    }
    return fileLength;
}

@end
