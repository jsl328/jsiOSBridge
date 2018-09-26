//
//  DownLoadClass.m
//  core
//
//  Created by guoxd on 2018/1/24.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import "DownLoadClass.h"
#import "AFNetworking.h"
@interface DownLoadClass()
@property (nonatomic,strong) AFHTTPSessionManager *manager;

@property (nonatomic,strong) NSString *urlString;

@property (nonatomic,strong) NSString *pfxDataString;

@property (nonatomic,strong) NSArray *uploaderArray;

@property (nonatomic,assign) double completed;

@property (nonatomic,strong) NSURLSessionTask *task;
//验证证书
@property (nonatomic,assign) int modetype;
//证书名
@property (nonatomic,strong) NSString *certificateName;

@property (nonatomic,assign) BOOL Domainname;
@end
@implementation DownLoadClass
-(NSURLSessionTask *)downloader:(NSDictionary *)dictionary
{
    self.urlString = [dictionary objectForKey:@"url"];
    self.modetype = [[dictionary objectForKey:@"modetype"]intValue];
    if (self.modetype != 0) {
        self.certificateName = [dictionary objectForKey:@"certificatename"];
        self.Domainname = [[dictionary objectForKey:@"domainname"]boolValue];
    }
    NSDictionary *settingDic = [dictionary objectForKey:@"setting"];
    _manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:self.urlString]];
    if(self.modetype != 0){
        _manager.securityPolicy = [self AFSecurityPolicyObjectCreate];
    }
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    if ([settingDic valueForKey:@"timeout"] != nil) {
        _manager.requestSerializer.timeoutInterval = [[dictionary valueForKey:@"timeout"]intValue];
    }
    if ([settingDic objectForKey:@"headers"]) {
        //设置请求头
        NSDictionary *hearderDic = [dictionary objectForKey:@"headers"];
        NSArray *array = [hearderDic allKeys];
        for(NSString *keyString in array){
            [_manager.requestSerializer setValue:[hearderDic objectForKey:keyString] forHTTPHeaderField:keyString];
        }
    }
    
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
    if(self.modetype == 2){
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
    
    self.urlString = [self matchingParameters:settingDic andURL:self.urlString];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];

    self.task = [_manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //文件下载进度
        weakSelf.completed = downloadProgress.fractionCompleted;
        NSLog(@"completed = %f",weakSelf.completed);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [libraryPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            [self.delegate resultOfDownLoadClass:nil andError:error];
        }
        else{
        //下载完成   filePath：下载完成后文件的保存地址
            [self.delegate resultOfDownLoadClass:[filePath path] andError:error];
        }
    }];
    return self.task;
}

-(void)startdownloadFile:(NSDictionary *)dictionary
{
    if(!self.task){
        self.task = [self downloader:dictionary];
    }
    [self.task resume];
}
-(void)stopdownloadFile
{
    [_task suspend];
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
