//
//  uploadNetworking.m
//  YXBuilder
//
//  Created by guoxd on 2018/1/11.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "UploadClass.h"
#import "AFNetworking.h"
#import "CallBackObject.h"
static NSString *pfxDataString = nil;
static NSString *pfxPassWordString = nil;
@interface UploadClass()

@property (nonatomic,strong) CallBackObject *callBackID;

@property (nonatomic,strong) AFURLSessionManager *manager;
//网络请求地址
@property (nonatomic,strong) NSString *urlString;
//.pfx证书
@property (nonatomic,strong) NSString *pfxDataString;
//上传的文件地址
@property (nonatomic,strong) NSString *uploadFilePath;
//上传进度
@property (nonatomic,assign) double completed;
//是否需要验证证书
@property (nonatomic,assign) int modeType;
//cer文件名
@property (nonatomic,strong) NSString *certificateName;
//是否需要验证域名
@property (nonatomic,assign) BOOL isDomainname;

@property (nonatomic, copy) void(^callbackBlock)(NSString*,NSError*);

@end

@implementation UploadClass

-(void)uploader:(NSDictionary *)dictionary finish:(void(^)(NSString *result,NSError *error))resultBlock
{
    self.urlString = [dictionary objectForKey:@"url"];
    self.modeType = [[dictionary objectForKey:@"modetype"]intValue];
    if (self.modeType != 0) {
        self.isDomainname = [[dictionary objectForKey:@"domainname"]boolValue];
        self.certificateName = [dictionary objectForKey:@"certificatename"];
    }
    NSDictionary *settingDic = [dictionary objectForKey:@"setting"];
    self.uploadFilePath = [dictionary objectForKey:@"filepath"];
    self.callbackBlock = resultBlock;

    NSDictionary *paramDic = [NSDictionary dictionary];
    if ([settingDic objectForKey:@"data"]) {
        paramDic = [settingDic objectForKey:@"data"];
    }
    else{
        paramDic = nil;
    }
    NSString *string = [self matchingParameters:settingDic andURL:self.urlString];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]multipartFormRequestWithMethod:@"POST" URLString:string parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:self.uploadFilePath];
        [formData appendPartWithFileData:fileData name:@"wenjian" fileName:[paramDic objectForKey:@"filename"]  mimeType:@"application/octet-stream"];
    } error:nil];
    
    _manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:self.urlString] sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    if (self.modeType !=0 ) {
        _manager.securityPolicy = [self AFSecurityPolicyObjectCreate];
    }
    if(self.modeType == 2){
        [self setCertificateValidate];
    }
    NSURLSessionUploadTask *task = [_manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress = %f",uploadProgress.completedUnitCount/(double)uploadProgress.totalUnitCount);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            self.callbackBlock(nil,error);
        }
        else{
            self.callbackBlock(responseObject,error);
        }
    }];
    [task resume];
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

-(void)setCertificateValidate{
    __weak typeof(self)weakSelf = self;
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

+(BOOL)extractIdentity:(SecIdentityRef*)outIdentity andTrust:(SecTrustRef *)outTrust fromPKCS12Data:(NSData *)inPKCS12Data {
    OSStatus securityError = errSecSuccess;
    //client certificate password
    NSDictionary*optionsDictionary = [NSDictionary dictionaryWithObject:pfxPassWordString
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
