//
//  DownLoadAndUploadFile.m
//  core
//
//  Created by guoxd on 2018/2/7.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import "DownLoadAndUploadFile.h"
#import "CallBackObject.h"
@interface DownLoadAndUploadFile()
@property (nonatomic,strong) CallBackObject *callback;
@end
@implementation DownLoadAndUploadFile
-(void)call:(NSString *)type action:(NSString *)action param:(NSString *)param callback:(id<ICallBackDelegate>)callback
{
    self.callback = callback;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    if ([type isEqualToString:@"downloadupload"]) {
        //普通下载
        if ([action isEqualToString:@"download"]) {
            DownLoadClass *download = [[DownLoadClass alloc]init];
            download.delegate = self;
            [download startdownloadFile: dictionary];
        }
        //大文件下载
        if([action isEqualToString:@"breakpointdownload"]){
            BreakPointDownLoadClass *breakpointDownload = [[BreakPointDownLoadClass alloc]init];
            breakpointDownload.ProgressDelegate = self;
            /*
             参数一：请求地址
             参数二：文件保存地址
             */
            [breakpointDownload breakpointdownload:[dictionary objectForKey:@"url"] savePath:@"snip.qq.com/resources/Snip_V2.0_5771.dmg" finish:^(NSError *error, NSString *savepath) {
                if (error) {
                    NSString *message = [error.userInfo objectForKey:@"NSLocalizedDescription"];
                    [callback run:CallBackObject.ERROR message:message data:@""];
                }
                else{
                    [callback run:CallBackObject.SUCCESS message:@"" data:savepath];
                }
            }];
        }
        //文件上传
        if ([action isEqualToString:@"upload"]) {
            UploadClass *upload = [[UploadClass alloc]init];
            [upload uploader:dictionary finish:^(id result, NSError *error) {
                if (result) {
                    NSLog(@"result = %@",result);
                }
                else{
                    NSLog(@"error = %@",error);
                }
                if (error) {
                    NSString *message = [error.userInfo objectForKey:@"NSLocalizedDescription"];
                    [callback run:CallBackObject.ERROR message:message data:@""];
                }
                else{
                    [callback run:CallBackObject.SUCCESS message:@"" data:result];
                }
            }];
        }
    }
}

-(void)resultOfDownLoadClass:(NSString *)resultString andError:(NSError *)error
{
    if (error) {
        NSDictionary *dictionary = error.userInfo;
        NSString *errorString = [dictionary objectForKey:@"NSLocalizedDescription"];
        [self.callback run:CallBackObject.ERROR message:errorString data:@""];
    }
    else{
        [self.callback run:CallBackObject.SUCCESS message:@"" data:resultString];
    }
}

-(void)getProgress:(double)progress{
    NSLog(@"progress = %f",progress);
}



@end
