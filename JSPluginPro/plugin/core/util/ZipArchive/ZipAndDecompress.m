//
//  ZipAndDecompress.m
//  core
//
//  Created by guoxd on 2018/1/23.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import "ZipAndDecompress.h"
#import "CallBackObject.h"
#import "ZipArchive.h"
#import "FileAccessor.h"
@interface ZipAndDecompress()
@property (nonatomic,strong) NSString *zipFilePath;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *filePath;
@end
@implementation ZipAndDecompress
-(void)call:(NSString *)type action:(NSString *)action param:(NSString *)param callback:(id<ICallBackDelegate>)callback
{
    NSLog(@"type = %@,action = %@,param = %@",type,action,param);
    NSDictionary *paramDic = [[NSDictionary alloc]init];
    if (param.length >0) {
        paramDic = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    }
    //压缩
    if([action isEqualToString:@"compress"]){
        BOOL isSuccess = [self compressFile:paramDic];
        if(isSuccess)
        {
            NSLog(@"压缩成功");
            if (self.zipFilePath.length >0) {
                [callback run:CallBackObject.SUCCESS message:@"" data:self.zipFilePath];
            }
            else{
                [callback run:CallBackObject.SUCCESS message:@"" data:@"压缩成功，保存地址为空！"];
            }
        }
        else{
            NSLog(@"压缩失败");
            [callback run:CallBackObject.ERROR message:@"压缩失败" data:@""];
        }
    }
    //解压
    else if ([action isEqualToString:@"decompress"]){
        BOOL isSuccess = [self decompressFile:paramDic];
        if(isSuccess)
        {
            NSLog(@"解压成功");
            [callback run:CallBackObject.SUCCESS message:@"" data:@"解压成功"];
        }
        else{
            NSLog(@"解压失败");
            [callback run:CallBackObject.ERROR message:@"解压失败" data:@""];
        }
    }
}

-(BOOL)compressFile:(NSDictionary *)paramDic
{
    if([paramDic objectForKey:@"path"]){
        NSString *filePath = [paramDic objectForKey:@"path"];
        self.fileName = [[filePath componentsSeparatedByString:@"/"]lastObject];
        NSString *path = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:@"/Pandora/"];
        path=[path stringByAppendingString:APPID];
        
        
        self.filePath = [path stringByAppendingPathComponent:filePath];
        NSString *appendPath = [[filePath stringByReplacingOccurrencesOfString:self.fileName withString:@""] stringByAppendingPathComponent:[NSString  stringWithFormat:@"/%@.zip",[[self.fileName componentsSeparatedByString:@"."]objectAtIndex:0]]];
        self.zipFilePath = [[FileAccessor getInstance] getFile:appendPath];
                             
//        self.zipFilePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",self.fileName] withString:@""] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.zip",[[self.fileName componentsSeparatedByString:@"."]objectAtIndex:0]]];
        
//        self.zipFilePath = [[self.filePath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",self.fileName] withString:@""] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.zip",[[self.fileName componentsSeparatedByString:@"."]objectAtIndex:0]]];
    }
    
    ZipArchive *ziparchive = [[ZipArchive alloc]init];
    if(self.zipFilePath.length>0){
        [ziparchive CreateZipFile2:self.zipFilePath];
        [ziparchive addFileToZip:self.filePath newname:self.fileName];
    }
    NSLog(@"fileName = %@,zipfilePath = %@",self.fileName,self.zipFilePath);
    if( ![ziparchive CloseZipFile2] )
    {
        self.zipFilePath = @"";
        return NO;
    }
    [ziparchive release];
    
    return YES;
}

-(BOOL)decompressFile:(NSDictionary *)paramDic
{
    BOOL isSuccess = NO;
    if([paramDic objectForKey:@"path"]){
        NSString *filePath = [paramDic objectForKey:@"path"];
        self.fileName = [[filePath componentsSeparatedByString:@"/"]lastObject];
        NSString *appendPath = [filePath stringByReplacingOccurrencesOfString:self.fileName withString:@""];
        self.zipFilePath = [[FileAccessor getInstance] getFile:filePath];
        NSString *unzipPath = [[FileAccessor getInstance] getFile:appendPath];
        ZipArchive *ziparchive = [[ZipArchive alloc]init];
        if([ziparchive UnzipOpenFile:self.zipFilePath]){
            isSuccess = [ziparchive UnzipFileTo:unzipPath overWrite:YES];
            [ziparchive release];
        }
    }
    return isSuccess;
}

@end
