//
//  HttpClient.m
//  core
//
//  Created by BruceXu on 2018/4/19.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import "HttpClient.h"
#import "IHttpClientDelegate.h"
#import "FileAccessor.h"
#import "HttpRequester.h"
#import "CallBackObject.h"
#import "FoxFileManager.h"
#import "MD5Util.h"
#import "ZipArchive.h"
#import "GZIPutil.h"
@interface HttpClient()<IHttpClientDelegate>{
    dispatch_queue_t queue;
}
@end
@implementation HttpClient
-(id)init{
    if(self=[super init]){
        queue =  dispatch_queue_create("HttpClientQueeu", NULL);
    }
    return self;
}
/**
 * 直接上传文件
 * param uploadAddress
 * param savePath
 * param fileName
 * param uploadFilePath
 * param timeout
 * param callback
 */

-(void) directUpload: (NSString*) uploadAddress savePath:(NSString*) savePath  fileName: (NSString*) fileName uploadFilePath: (NSString*) uploadFilePath  timeout: (NSString*) timeout  callback:(NSString*) callback {
    // 获取文件访问器
    FileAccessor *fileAccessor = [FileAccessor getInstance];
    // 获取文件
    NSString* uploadFile = [fileAccessor getFile:uploadFilePath];
    
    CallBackObject *fn = [[CallBackObject alloc] initWithCallback:callback];
    // __weak typeof (self) weakSelf=self;
    dispatch_async(queue, ^{
        int t = [timeout intValue];
        //标志是否上传文件夹
        BOOL isUploadDir=false;
        NSString *file=@"";
        BOOL isDirectory=[FoxFileManager isDirectoryAtPath:uploadFile];
        if(isDirectory){
            file= [self getZipFile:uploadFile];
            //压suo
            [GZIPutil doZipAtPath:uploadFile to:file];
            //标志为目录上传
            isUploadDir=true;
        }else{
            file=uploadFile;
        }
        NSString* res=[HttpRequester directUpload:uploadAddress savePath:savePath fileName:fileName uploadFile:file timeout:t];
        
        if(res){
            [fn runCode:CallBackObject.SUCCESS message:@"" data:res];
        }
        [FoxFileManager removeItemAtPath:file];
        
    });
    
    
}
/**
 * 上传文件
 *
 * param address
 * param remoteSavePath
 * param remoteFileName
 * param uploadFilePath
 * param timeout
 * param callback
 */

-(void) upload:(NSString*) address remoteSavePath:(NSString*) remoteSavePath  remoteFileName:(NSString*)remoteFileName
uploadFilePath:(NSString*)uploadFilePath  timeout:(NSString*) timeout callback:(NSString*) callback {
     CallBackObject *callbackfn = [[CallBackObject alloc] initWithCallback:callback];
    
    // 获取文件访问器
    FileAccessor *fileAccessor = [FileAccessor getInstance];
    // 获取文件
    NSString* uploadFile = [fileAccessor getFile:uploadFilePath];
    
    if (![FoxFileManager isExistsAtPath:uploadFile] ) {
        NSMutableString* sb = [NSMutableString new];
        [sb appendString:@"file["];
        [sb appendString:uploadFile];
        [sb appendString:@"]no exist"];
     
        //执行回调
        [callbackfn runCode:CallBackObject.ERROR message:[sb copy] data:@""];
      
    }
    dispatch_async(queue, ^{
        //转换时间
        int t = [timeout intValue];
        //标志是否上传文件夹
        BOOL isUploadDir=false;
        //记录待上传文件
        NSString *file=nil;
        if([FoxFileManager isDirectoryAtPath:uploadFile]){
            
            file= [self getZipFile:uploadFile];
            //压suo
            [GZIPutil doZipAtPath:uploadFile to:file];
            //标志为目录上传
            isUploadDir=true;
        }else{
            file=uploadFile;
        }
       
        //获取文件名
        NSString* fileName = remoteFileName;
        if (fileName == nil || fileName.length == 0) {
            fileName = [FoxFileManager fileNameAtPath:file suffix:YES];
        }
        // 上传文件
        BOOL res=  [HttpRequester upload:address savePath:remoteSavePath  fileName: fileName uploadFile:file baseContext:HttpRequester.INSTANT_CONTEXT_PATH timeout:t];
        
        if (res) {
            //执行回调函数
            [callbackfn runCode:CallBackObject.SUCCESS message:@"" data:@"success"];
            
        } else {
            //执行回调函数
             [callbackfn runCode:CallBackObject.ERROR message:@"fail" data:@""];
        }
        
        
    });
}
/**
 * 断点上传文件
 *
 * param remoteSavePath
 * param remoteFileName
 * param uploadFilePath
 * param timeout
 * param pageSize
 * param callback
 * return
 */

-(void) breakpointUpload:(NSString*) address  remoteSavePath:(NSString*) remoteSavePath remoteFileName: (NSString*) remoteFileName  uploadFilePath:(NSString*) uploadFilePath timeout:(NSString*)
timeout pageSize:(NSString*) pageSize callback:(NSString*) callback {
    
   CallBackObject *callbackOb = [[CallBackObject alloc] initWithCallback:callback];
    
    CallBackObject *fn = [[CallBackObject alloc] initWithRunBlock:^(int code, NSString* message, id data){
        [callbackOb runCode:code message:message data:data];
    }];
    
    // 获取文件访问器
    FileAccessor *fileAccessor = [FileAccessor getInstance];
    // 获取文件
    NSString* uploadFile = [fileAccessor getFile:uploadFilePath];
    
    if (![FoxFileManager isExistsAtPath:uploadFile] ) {
        NSMutableString* sb = [NSMutableString new];
        [sb appendString:@"file["];
        [sb appendString:uploadFile];
        [sb appendString:@"]no exist"];
        
        //执行回调
        [callbackOb runCode:CallBackObject.ERROR message:[sb copy] data:@""];
        
    }
    
    dispatch_async(queue, ^{
        //转换时间
        int t = [timeout intValue];
        //装换page大小
        int pSize = [pageSize intValue];
        
        BOOL res= [HttpRequester breakpointUpload: address uploadPath: remoteSavePath fileName:remoteFileName uploadFile:uploadFile baseContext:HttpRequester.INSTANT_CONTEXT_PATH timeout:t pageSize:pSize callback:fn];
        
         if (!res) {
            //执行回调函数
           [fn runCode:CallBackObject.ERROR message:@"fail" data:@""];
        
        }
        
        
    });
   
}
/**
 * 下载文件
 *
 * param address
 * param remotePath
 * param savePath
 * param timeout
 * param callback
 */

-(void) download: (NSString*) address remotePath:(NSString*) remotePath :(NSString*) savePath timeout: (NSString*) timeout  callback: (NSString*) callback {
    // 获取文件访问器
    FileAccessor *fileAccessor = [FileAccessor getInstance];
    // 获取文件
    NSString* saveFile = [fileAccessor getFile:savePath];
     CallBackObject *fn = [[CallBackObject alloc] initWithCallback:callback];
    dispatch_async(queue, ^{
        //标志是否需要下载
        BOOL needDownload = YES;
        //如果文件已经存在，先判断MD5是否一致，如果一致不再重复下载
        
        if ([FoxFileManager isExistsAtPath:saveFile]) {
            //获取远端MD5
            NSString* remoteMD5=[HttpRequester getRemoteFileStamp:address path:remotePath baseContext:HttpRequester.INSTANT_CONTEXT_PATH timeout:[timeout intValue]];
            
             //本地MD5
             NSString *localMD5 = nil;
             //获取本地MD5
            localMD5= [MD5Util digestMD5:saveFile];
              //如果MD5一致，不重新下载
            if (localMD5 != nil && [[localMD5 lowercaseString] isEqualToString:[remoteMD5 lowercaseString]]) {
                needDownload = false;
            }
        }
        //下载结果
        BOOL res = false;
        //判断是否需要重新下载
        if (needDownload) {
             // 下载文件
            res =[HttpRequester download:address path:remotePath saveFile:saveFile baseContext:HttpRequester.INSTANT_CONTEXT_PATH timeout:[timeout intValue]];
            
        } else {
            res = true;
        }
        
        NSString* path = saveFile;
        if (res) {
            //执行回调函数
             [fn runCode:CallBackObject.SUCCESS message:@"" data:path];
           
        } else {
            //执行回调函数
            [fn runCode:CallBackObject.ERROR message:@"下载文件失败" data:saveFile];
        }

    });
}
/**
 * 直接下载文件
 *
 * param downloadAddress
 * param savePath
 * param timeout
 * param callback
 */

-(void) directDownload: (NSString*) downloadAddress savePath: (NSString*) savePath timeout: (NSString*) timeout callback:(NSString*) callback{
    

    // 获取文件访问器
   FileAccessor *fileAccessor = [FileAccessor getInstance];
    // 获取文件
    NSString* saveFile = [fileAccessor getFile:savePath];

    CallBackObject *fn = [[CallBackObject alloc] initWithCallback:callback];
   // __weak typeof (self) weakSelf=self;
    dispatch_async(queue, ^{
       
     BOOL result= [HttpRequester  directDownload: downloadAddress saveFile:saveFile timeout:[timeout intValue]];
      
        if(result){
            [fn runCode:CallBackObject.SUCCESS message:@"" data:saveFile];
        }
        else{
            [fn runCode:CallBackObject.ERROR message:@"下载文件失败" data:saveFile];
        }
        
    });
    
}

/**
 * 断点下载
 *
 * param address
 * param remotePath
 * param savePath
 * param timeout
 * param pageSize
 * param callback
 */

-(void) breakpointDownload: (NSString*) address remotePath: (NSString*) remotePath  savePath: (NSString*) savePath timeout: (NSString*) timeout pageSize: (NSString*) pageSize callback: (NSString*) callback {
    // 获取文件访问器
    FileAccessor *fileAccessor = [FileAccessor getInstance];
    // 获取文件
    NSString* saveFile = [fileAccessor getFile:savePath];
    CallBackObject *callbackOb = [[CallBackObject alloc] initWithCallback:callback];
  
    CallBackObject *fn = [[CallBackObject alloc] initWithRunBlock:^(int code, NSString* message, id data){
        [callbackOb runCode:code message:message data:data];
    }];
    
    dispatch_async(queue, ^{
        //下载超时
        int t = [timeout intValue];
        //下载片段大小
        int pSize = [pageSize intValue];
        //标志是否需要下载
       BOOL needDownload = YES;
        if ([FoxFileManager isExistsAtPath:saveFile]) {
       // if(1==1){
            //获取远端MD5
            NSString* remoteMD5=[HttpRequester getRemoteFileStamp:address path:remotePath baseContext:HttpRequester.INSTANT_CONTEXT_PATH timeout:[timeout intValue]];
            
            //本地MD5
            NSString *localMD5 = nil;
            //获取本地MD5
            localMD5= [MD5Util digestMD5:saveFile];
            //如果MD5一致，不重新下载
            if (localMD5 != nil && [[localMD5 lowercaseString] isEqualToString:[remoteMD5 lowercaseString]]) {
                needDownload = false;
            }
        }
        //下载结果
        BOOL res = false;
        //判断是否需要下载
        if (needDownload) {
            // 下载文件
            
         res =  [HttpRequester breakpointDownload:address path:remotePath saveFile:saveFile baseContext:HttpRequester.INSTANT_CONTEXT_PATH timeout:t pageSize:pSize callback:fn];
            
        } else {
            res = true;
        }
        
        if (!res) {
            //执行回调函数
            [callbackOb runCode:CallBackObject.ERROR message:@"fail" data:@""];
           
        }
        
    });
    
}
/**
 * 获取ZIP文件
 *
 * param path
 * return
 */
-(NSString*)getZipFile:(NSString*) path {
   return [NSString stringWithFormat:@"%@.zip",path ];
}
@end
