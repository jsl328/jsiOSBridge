//
//  pluginSSLNetWorking.m
//  HBuilder-Hello
//
//  Created by guoxd on 2016/11/1.
//  Copyright © 2016年 guoxd. All rights reserved.
//

#import "pluginSSLNetWorking.h"
#import "AFNetworking.h"
#import "CallBackObject.h"
static NSString *pfxDataString = nil;
static NSString *pfxPassWordString = nil;
@interface pluginSSLNetWorking()
//pfx的数据
//@property (nonatomic,strong) NSString *pfxData;
//网络请求地址
@property (nonatomic,strong) NSString *urlString;
//data数据中setting字符串
@property (nonatomic,strong) NSDictionary *dataDic;
//证书验证类型（0---不验证证书  1---单向验证  2---双向验证）
@property (nonatomic,assign) int modeType;

@property (nonatomic,strong) CallBackObject *callBackID;

@property (nonatomic,strong) AFHTTPSessionManager *manager;
//是否需要验证域名
@property (nonatomic,assign) BOOL isValidatesDomainName;

@property (nonatomic,strong) NSString *certificateName;

@end
@implementation pluginSSLNetWorking
-(void)call:(NSString *)type action:(NSString *)action param:(NSString *)param callback:(id<ICallBackDelegate>)callback
{
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    self.callBackID = callback;
    //ssl网络请求
    if ([action isEqualToString:@"sslNetWorking"]) {
        [self netWorkingSSLRequest:dictionary];
    }
    //取消ssl请求
    else if ([action isEqualToString:@"cancelNetWorking"]){
        [self cancelSSLRequest];
    }
}

#pragma mark --SSL网络请求
-(void)netWorkingSSLRequest:(NSDictionary *)paramsDic
{
    //请求的url
    self.urlString = [paramsDic objectForKey:@"url"];
    //是否验证证书
    self.modeType = [[paramsDic objectForKey:@"modetype"]intValue];
    //setting字符串
    self.dataDic = [paramsDic objectForKey:@"setting"];
    if (self.modeType != 0) {
        //证书名
        self.certificateName = [paramsDic objectForKey:@"certificatename"];
        //是否需要验证域名
        self.isValidatesDomainName = [[paramsDic objectForKey:@"domainname"]boolValue];
    }
    // 1.获得请求管理者
    _manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:self.urlString]];
    //如果modetype不为0，则需要对securityPolicy初始化
    if(self.modeType != 0){
        //securityPolicy初始化
        _manager.securityPolicy = [self AFSecurityPolicyObjectCreate];
    }
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    if ([self.dataDic valueForKey:@"timeout"] != nil) {
        _manager.requestSerializer.timeoutInterval = [[self.dataDic valueForKey:@"timeout"]intValue];
    }
    
    if ([self.dataDic objectForKey:@"headers"]) {
        //设置请求头
        NSDictionary *hearderDic = [self.dataDic objectForKey:@"headers"];
        NSArray *array = [hearderDic allKeys];
        for(NSString *keyString in array){
            [_manager.requestSerializer setValue:[hearderDic objectForKey:keyString] forHTTPHeaderField:keyString];
        }
    }
    
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 3.申明返回的结果是text/html/json类型
    _manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain",@"text/html", nil];
    
    //关闭缓存避免干扰测试r
    _manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    //设置管理的会话无效回调方法
    [_manager setSessionDidBecomeInvalidBlock:^(NSURLSession * _Nonnull session, NSError * _Nonnull error) {
        NSLog(@"setSessionDidBecomeInvalidBlock");
    }];
    __weak typeof(self)weakSelf = self;
    if (self.modeType == 2) {
        //设置需要身份验证回调方法
        [_manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession*session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing*_credential) {
            NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            __autoreleasing NSURLCredential *credential =nil;
            if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                if([weakSelf.manager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                    if(credential) {
                        disposition = NSURLSessionAuthChallengeUseCredential;
                    } else {
                        disposition =NSURLSessionAuthChallengePerformDefaultHandling;
                    }
                } else {
                    disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                }
            } else {
                // client authentication
                SecIdentityRef identity = NULL;
                SecTrustRef trust = NULL;
//                NSString *p12 = [[NSBundle mainBundle] pathForResource:@"clent"ofType:@"pfx"];
//                NSFileManager *fileManager =[NSFileManager defaultManager];

                if(!pfxDataString)
                {
                    NSLog(@"client.p12:not exist");
                }
                else
                {
                    NSData *PKCS12Data = [[NSData alloc]initWithBase64EncodedString:pfxDataString options:0];
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

    if ([[self.dataDic objectForKey:@"type"]isEqualToString:@"POST"]) {
        NSDictionary *paramDic = [NSDictionary dictionary];
        if ([self.dataDic objectForKey:@"data"]) {
            paramDic = [self.dataDic objectForKey:@"data"];
        }
        else{
            paramDic = nil;
        }
        NSData *data = [NSJSONSerialization dataWithJSONObject:paramDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //发送post请求
        [_manager POST:self.urlString parameters:string progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *string = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            [self.callBackID run:CallBackObject.SUCCESS message:@"" data:string];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error = %@",error);
            NSString *string = [[NSString alloc]init];
            if (-1001 == error.code) {
                string = @"SocketTimeoutException";
            }
            else if(-1004 == error.code)
            {
                string = @"ConnectException";
            }
            else{
                string = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            }
            [self.callBackID run:CallBackObject.ERROR message:string data:nil];
            
        }];
    }
    else
    {
        //拼接url参数
        NSString *urlStr = [self matchingParameters:self.dataDic andURL:self.urlString];
        if (urlStr) {
            [_manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSString *message = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                
                [self.callBackID run:CallBackObject.SUCCESS message:@"" data:message];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"error = %@",error);
                NSString *string = [[NSString alloc]init];
                if (-1001 == error.code) {
                    string = @"SocketTimeoutException";
                }
                else if(-1004 == error.code)
                {
                    string = @"ConnectException";
                }
                else{
                    string = [error.userInfo objectForKey:@"NSLocalizedDescription"];
                }
                [self.callBackID run:CallBackObject.ERROR message:string data:@""];
            }];
        }
        
    }
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

#pragma mark --取消请求
-(void)cancelSSLRequest
{
    [_manager.operationQueue cancelAllOperations];
}

@end
