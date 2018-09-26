//
//  downloadNetworking.m
//  YXBuilder
//
//  Created by guoxd on 2018/1/11.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "downloadNetworking.h"
#import "AFNetworking.h"
#import "CallBackObject.h"
@interface downloadNetworking()
@property (nonatomic,strong) CallBackObject *callBackID;
@property (nonatomic,strong) AFHTTPSessionManager *manager;
@property (nonatomic,strong) NSString *action;
@property (nonatomic,strong) NSString *urlString;
@property (nonatomic,strong) NSString *pfxDataString;
@property (nonatomic,strong) NSArray *uploaderArray;
@property (nonatomic,assign) double completed;
@property (nonatomic,strong) NSURLSessionTask *task;
//是否需要验证证书
@property (nonatomic,assign) BOOL isValidatesCer;
@end
@implementation downloadNetworking

-(void)call:(NSString *)action param:(NSString *)param callback:(id<ICallBackDelegate>)callback
{
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    self.urlString = [dictionary objectForKey:@"url"];
    self.isValidatesCer = [[dictionary objectForKey:@"domainname"]boolValue];
    NSDictionary *settingDic = [dictionary objectForKey:@"setting"];
    self.callBackID = callback;
    [self downloader:settingDic];
}

-(void)downloader:(NSDictionary *)dictionary
{
    _manager = [AFHTTPSessionManager manager];
    if(self.isValidatesCer){
        _manager.securityPolicy = [self AFSecurityPolicyObjectCreate];
    }
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    if ([dictionary valueForKey:@"timeout"] != nil) {
        _manager.requestSerializer.timeoutInterval = [[dictionary valueForKey:@"timeout"]intValue];
    }
    if ([dictionary objectForKey:@"headers"]) {
        //设置请求头
        NSDictionary *hearderDic = [dictionary objectForKey:@"headers"];
        NSArray *array = [hearderDic allKeys];
        for(NSString *keyString in array){
            [_manager.requestSerializer setValue:[hearderDic objectForKey:keyString] forHTTPHeaderField:keyString];
        }
    }
    //        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 3.申明返回的结果是text/html/json类型
    _manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain",@"text/html",@"text/xml",@"image/*", nil];
    
    //关闭缓存避免干扰测试r
    _manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    //设置管理的会话无效回调方法
    [_manager setSessionDidBecomeInvalidBlock:^(NSURLSession * _Nonnull session, NSError * _Nonnull error) {
        NSLog(@"setSessionDidBecomeInvalidBlock");
    }];
    
    //设置需要身份验证回调方法
    __weak typeof(self)weakSelf = self;
    if(self.isValidatesCer){
        [_manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession*session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing*_credential) {
            NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            __autoreleasing NSURLCredential *credential =nil;
            if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                if([weakSelf.manager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                    if(credential) {
                        disposition = NSURLSessionAuthChallengeUseCredential;
                    } else {
                        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                    }
                } else {
                    disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                }
            } else {
                // client authentication
                SecIdentityRef identity = NULL;
                SecTrustRef trust = NULL;
                //NSString *p12 = [[NSBundle mainBundle] pathForResource:@"clent"ofType:@"pfx"];
                //NSFileManager *fileManager =[NSFileManager defaultManager];
                if(!weakSelf.pfxDataString)
                {
                    NSLog(@"client.p12:not exist");
                }
                else
                {
                    NSData *PKCS12Data = [[NSData alloc] initWithBase64EncodedString:weakSelf.pfxDataString options:0];
                    if ([[weakSelf class] extractIdentity:&identity andTrust:&trust fromPKCS12Data:PKCS12Data])
                    {
                        SecCertificateRef certificate = NULL;
                        SecIdentityCopyCertificate(identity, &certificate);
                        const void*certs[] = {certificate};
                        CFArrayRef certArray =CFArrayCreate(kCFAllocatorDefault, certs,1,NULL);
                        credential =[NSURLCredential credentialWithIdentity:identity certificates:(__bridge  NSArray*)certArray persistence:NSURLCredentialPersistencePermanent];
                        disposition =NSURLSessionAuthChallengeUseCredential;
                    }
                }
            }
            *_credential = credential;
            return disposition;
        }];
    }
    
//    NSDictionary *paramDic = [NSDictionary dictionary];
//    if ([dictionary objectForKey:@"data"]) {
//        paramDic = [dictionary objectForKey:@"data"];
//    }
//    else{
//        paramDic = nil;
//    }
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    _task = [_manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //文件下载进度
        weakSelf.completed = downloadProgress.fractionCompleted;
        NSLog(@"completed = %f",weakSelf.completed);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [libraryPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //下载完成   filePath：下载完成后文件的保存地址
        NSLog(@"filePath = %@",[filePath path]);
        [weakSelf.callBackID run:CallBackObject.SUCCESS message:@"" data:[filePath path]];
    }];
    [_task resume];
}

-(void)startdownloadFile
{
    [_task resume];
}
-(void)stopdownloadFile
{
    [_task suspend];
}

//#pragma mark --AFSecurityPolicy对象的创建
-(AFSecurityPolicy *)AFSecurityPolicyObjectCreate
{
    //导入证书
    NSString *certFilePath = [[NSBundle mainBundle] pathForResource:@"rootca" ofType:@"cer"];
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
    NSDictionary*optionsDictionary = [NSDictionary dictionaryWithObject:@"123456"
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

//#pragma mark -GET请求拼接参数
-(NSString *)matchingParameters:(NSDictionary *)dic andURL:(NSString *)urlStr
{
    if ([dic objectForKey:@"data"]) {
        NSDictionary *dataDic = [dic objectForKey:@"data"];
        BOOL isFrist = YES;
        if (dataDic) {
            NSArray *keyArray = ((NSDictionary *)[dic objectForKey:@"data"]).allKeys;
            NSString *pathString = [[NSString alloc]init];
            for (NSString *keyStr in keyArray) {
                if (isFrist) {
                    isFrist = NO;
                    pathString = [pathString stringByAppendingString:[NSString stringWithFormat:@"%@=%@",keyStr,[dataDic objectForKey:keyStr]]];
                }
                else{
                    pathString = [pathString stringByAppendingString:[NSString stringWithFormat: @"&%@=%@",keyStr,[dataDic objectForKey:keyStr]]];
                }
            }
            return [[NSString stringWithFormat:@"%@?%@",urlStr,pathString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return [NSString stringWithFormat:@"%@",urlStr];
}
@end
