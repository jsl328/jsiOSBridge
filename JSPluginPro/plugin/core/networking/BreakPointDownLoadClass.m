//
//  BreakPointDownLoadClass.m
//  core
//
//  Created by guoxd on 2018/1/29.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import "BreakPointDownLoadClass.h"
#import "AFNetworking.h"
#import "FoxFileManager.h"
@interface BreakPointDownLoadClass()
@property (nonatomic,assign) NSInteger currentLength;
@property (nonatomic,assign) NSInteger fileLength;
@property (nonatomic,strong) AFURLSessionManager *manager;
@property (nonatomic,strong) NSURLSessionDataTask *task;
@property (nonatomic,strong) NSString *urlString;
@property (nonatomic,strong) NSFileHandle *fileHandle;
@property (nonatomic,strong) NSString *fileSavePath;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) NSString *certificateName;
@property (nonatomic,assign) BOOL isDomainname;
@property (nonatomic,assign) int modeType;
@property (nonatomic, copy) void(^callBackBlock)(NSError*,NSString*);
@end
@implementation BreakPointDownLoadClass
-(void)breakpointdownload:(NSString*)url savePath:(NSString*)savePath finish:(void (^)(NSError*error,NSString*savepath))block
{
    self.urlString = url;
    self.fileSavePath = savePath;
    self.callBackBlock  =block;
    //文件保存路径
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DownLoads"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [[self.fileSavePath componentsSeparatedByString:@"/"]lastObject];
    self.filePath = [path stringByAppendingPathComponent:fileName];
    NSInteger currentLength = [self fileLengthForPath:self.filePath];
    //开始下载/继续下载
    if (currentLength > 0) {
        self.currentLength = currentLength;
    }
    [self.task resume];
    NSLog(@"self.task = %p",self.task);
}

-(AFURLSessionManager *)manager
{
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 1. 创建会话管理者
        _manager = [[AFHTTPSessionManager manager] initWithBaseURL:[NSURL URLWithString:self.urlString] sessionConfiguration:configuration];
        if (self.modeType != 0) {
            _manager.securityPolicy = [self AFSecurityPolicyObjectCreate];
        }
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
        __weak typeof (self) weakSelf=self;
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _task = [self.manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
            
        } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"downloadProgress = %@",downloadProgress.description);
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if(error){
                NSString *errorInfo =[error.userInfo objectForKey:@"NSLocalizedDescription"];
                NSLog(@"errorInfo = %@",errorInfo);
                weakSelf.callBackBlock(error, nil);
            }
            else{
                
                NSString *message = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                
                if(message.length == 0){
                    message = @"下载成功";
                }
                NSLog(@"message = %@",message);
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *saveparent= [FoxFileManager directoryAtPath:self.fileSavePath];
                
                if(![fileManager fileExistsAtPath:saveparent])
                {
                    [fileManager createDirectoryAtPath:saveparent withIntermediateDirectories:YES attributes:nil error:nil];
                }
                NSError *error;
                BOOL isSuccess = [fileManager copyItemAtPath:_filePath toPath:_fileSavePath error:&error];
                
                NSLog(@"isSuccess = %d",isSuccess);
                if(isSuccess){
                   [fileManager removeItemAtPath:self.filePath error:nil];
                }
                weakSelf.callBackBlock(nil, self.fileSavePath);
            }
        }];
        //设置数据任务并接收响应
        [self.manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
            
            // 获得下载文件的总长度：请求下载的文件长度 + 当前已经下载的文件长度
            weakSelf.fileLength = response.expectedContentLength + self.currentLength;
            // 沙盒文件路径
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"DownLoads/%@",[[weakSelf.fileSavePath componentsSeparatedByString:@"/"] lastObject]]];
            
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
            double progress = weakSelf.currentLength/(double)weakSelf.fileLength;
            [weakSelf.ProgressDelegate getProgress:progress];
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



//#pragma mark --AFSecurityPolicy对象的创建
-(AFSecurityPolicy *)AFSecurityPolicyObjectCreate
{
    //导入证书
    NSString *certFilePath = [[NSBundle mainBundle] pathForResource:self.certificateName ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:certFilePath];
    
    NSSet *certSet = [NSSet setWithObject:certData];
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:certSet];
    //是否允许无效证书
    policy.allowInvalidCertificates = YES;
    //是否需要验证域名
    policy.validatesDomainName = NO;
    
    return policy;
}

+(BOOL)extractIdentity:(SecIdentityRef*)outIdentity andTrust:(SecTrustRef *)outTrust fromPKCS12Data:(NSData *)inPKCS12Data {
    OSStatus securityError = errSecSuccess;
    //client certificate password
    NSDictionary*optionsDictionary = [NSDictionary dictionaryWithObject:@"yusyscom"
                                                                 forKey:(__bridge id)kSecImportExportPassphrase];
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import((__bridge CFDataRef)inPKCS12Data,(__bridge CFDictionaryRef)optionsDictionary,&items);
    
    if(securityError == 0) {
        CFDictionaryRef myIdentityAndTrust =CFArrayGetValueAtIndex(items,0);
        const void*tempIdentity =NULL;
        tempIdentity= CFDictionaryGetValue (myIdentityAndTrust,kSecImportItemIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void*tempTrust =NULL;
        tempTrust = CFDictionaryGetValue(myIdentityAndTrust,kSecImportItemTrust);
        *outTrust = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failed with error code %d",(int)securityError);
        return NO;
    }
    return YES;
}


@end
