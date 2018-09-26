//
//  downloadNetworking.m
//  YXBuilder
//
//  Created by guoxd on 2018/1/11.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "DownloadFile.h"
#import "CallBackObject.h"
@interface DownloadFile()
@property (nonatomic,strong) CallBackObject *callBackID;
@property (nonatomic,strong) DownLoadClass *downloadClass;
@end
@implementation DownloadFile

-(void)call:(NSString *)action param:(NSString *)param callback:(id<ICallBackDelegate>)callback
{
    NSLog(@"action = %@",action);
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    self.downloadClass = [[DownLoadClass alloc]init];
    self.downloadClass.delegate = self;
    self.callBackID = callback;
    [self.downloadClass startdownloadFile:dictionary];
    [self.downloadClass stopdownloadFile];
}

-(void)resultOfDownLoadClass:(NSString *)resultString
{
    if(resultString.length >0)
    {
        NSLog(@"resultString = %@",resultString);
        [self.callBackID run:CallBackObject.SUCCESS message:@"" data:resultString];
    }
}

@end
