//
//  uploadNetworking.m
//  YXBuilder
//
//  Created by guoxd on 2018/1/11.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "uploadNetworking.h"
#import "AFNetworking.h"
#import "CallBackObject.h"
@interface uploadNetworking()
@property (nonatomic,strong) CallBackObject *callBackID;
@property (nonatomic,strong) AFURLSessionManager *manager;
//网络请求地址
@property (nonatomic,strong) NSString *urlString;
//.cer证书
@property (nonatomic,strong) NSString *pfxDataString;
//上传的文件
@property (nonatomic,strong) NSString *uploadFilePath;
//上传进度
@property (nonatomic,assign) double completed;
//是否需要验证证书
@property (nonatomic,assign) BOOL isValidatesCer;
@end
@implementation uploadNetworking

-(void)call:(NSString *)action param:(NSString *)param callback:(id<ICallBackDelegate>)callback
{
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    self.urlString = [dictionary objectForKey:@"url"];
    self.isValidatesCer = [[dictionary objectForKey:@"domainname"]boolValue];
    NSDictionary *settingDic = [dictionary objectForKey:@"setting"];
    self.uploadFilePath = [dictionary objectForKey:@"filepath"];
    self.callBackID = callback;
    [self uploader:settingDic];
}

-(void)uploader:(NSDictionary *)dictionary
{
    NSDictionary *paramDic = [NSDictionary dictionary];
    if ([dictionary objectForKey:@"data"]) {
        paramDic = [dictionary objectForKey:@"data"];
    }
    else{
        paramDic = nil;
    }
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]multipartFormRequestWithMethod:@"POST" URLString:self.urlString parameters:paramDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString *fileName = [[self.uploadFilePath componentsSeparatedByString:@"/"]lastObject];
        NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:self.uploadFilePath];
        [formData appendPartWithFileData:fileData name:@"wenjian" fileName:@"shangchuandewenjian.upld"  mimeType:@"application/octet-stream"];
    } error:nil];
    [request addValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *task = [_manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress = %lld",uploadProgress.completedUnitCount);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"responseObject = %@",responseObject);
        NSLog(@"error = %@",error.userInfo);
        if (error) {
            [self.callBackID run:CallBackObject.ERROR message:[error.userInfo objectForKey:@""] data:@"NSLocalizedDescription"];
        }
        else{
            [self.callBackID run:CallBackObject.SUCCESS message:@"" data:responseObject];
        }
    }];
    [task resume];
}

@end
