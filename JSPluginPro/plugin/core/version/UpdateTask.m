//
//  UpdateTask.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/21.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "UpdateTask.h"
#import "FoxFileManager.h"
#import "MD5Util.h"
#import "HttpRequester.h"
#import "GlobalConstant.h"
#import "YXPlugin.h"
/**
 * Node
 */
@interface Node:NSObject
@property(copy) NSString*md5;
@property(assign) long size;
@property(assign) BOOL singleFile;
@end
@implementation Node
@end


@interface UpdateTask(){
    
}


@end
@implementation UpdateTask


/**
 * 构造函数
 */
-(id)init{
    if(self=[super init]){
        self.updatedRestart=false;
        
        self.necessary=YES;
        
        
        self.timeout = GlobalConstant.TIMEOUT * 3;
        
        self.downloadUnitSize = -1;
        self.downloadUnitCount= -1;
        
         self.largeFileSize= 1024 * 1024 * 5;

    }
    return self;
}
/**
 * 构造函数
 *
 * param address
 * param requestPath
 * param saveFile
 * param timeout
 * param downloadUnitCount
 * param downloadUnitSize
 * param largeFileSize
 */

-(id)intWithAddress:(NSString*)address requestPath:(NSString*)requestPath saveFile:(NSString*)saveFile timeout:(int)timeout downloadUnitCount:(int)downloadUnitCount
   downloadUnitSize:(long)downloadUnitSize largeFileSize:(long)largeFileSize{
    if([self init]){
        self.address = address;
        self.requestPath = requestPath;
        self.saveFile = saveFile;
        self.timeout = timeout;
        self.downloadUnitCount = downloadUnitCount;
        self.downloadUnitSize = downloadUnitSize;
        self.largeFileSize = largeFileSize;
    }
    return self;
}

/**
 * 遍历服务器资源文件夹,缓存资源文件MD5值
 *
 * return
 */
-(NSMutableDictionary<NSString*, NSString*> *)loadLocalCache {
    // 记录开始时间
    long s = [[NSDate date] timeIntervalSince1970];
   
    
#ifdef DEBUG
     FOXLog(@"%@",[NSString stringWithFormat:@"遍历资源保存目录:%@",self.saveFile]);
#endif
    
    // 刷新数据
    NSMutableDictionary<NSString*, NSString*>* stampCache = [ NSMutableDictionary<NSString*, NSString*> new ];
   
    [self  refreshFileList:_saveFile root:self.saveFile stampCache:stampCache];
    
    // 记录结束时间
    #ifdef DEBUG
        long t = [[NSDate date] timeIntervalSince1970] - s;
        FOXLog(@"%@",[NSString stringWithFormat:@"资源遍历耗时:%ld毫秒",t]);
    #endif
    return stampCache;
}

/**
 * 递归遍历目录计算MD5
 *
 * param file
 * param root
 * param stampCache
 */
-(void) refreshFileList:(NSString*) file root:(NSString*) root stampCache:(NSMutableDictionary<NSString*,NSString*>*)stampCache
   {
    if ([FoxFileManager isFileAtPath:file] && file.length > 0) {
        // 获取文件名
        NSString *name = [self getFileName:file root:root];
        // 计算MD5
        NSString* md5 = @"";
        @try {
            md5 = [MD5Util digestMD5:file];
        } @catch (NSException *e) {
            md5 = @"";
            NSString *error= [NSString stringWithFormat:@"文件[%@]计算MD4码出错",name];
            FOXLog(@"%@",error);
        }
        // 保存包客户端缓存中
        [stampCache setObject:md5 forKey:name];
    } else if ([FoxFileManager isDirectoryAtPath:file]) {
        NSArray *files= [FoxFileManager listFilesInDirectoryAtPath:file deep:NO];
        
        if (files == nil) {
            return;
        }
        for (int i = 0; i < files.count; i++) {
            // 进入下级目录遍历。
            NSString *f= [file stringByAppendingPathComponent:files[i]];
            [self  refreshFileList:f root:root stampCache:stampCache];
        }
    }
    
}

/**
 * 获取文件名称
 *
 * param file
 * param root
 * return
 */
-(NSString*) getFileName:(NSString*) file root:(NSString*)root{
   
        NSString *name = nil;
        
        if ([file isEqualToString:root]) {
            name =  [FoxFileManager fileNameAtPath:file suffix:YES];
            return name;
        } else {
            name = file;
            int len = (int)root.length;
            // 去掉父亲目录
            name = [name substringFromIndex:(len+1)];
            // 替换为标准的文件分割符
           name= [name stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            
        }
        return name;
    
    return @"";
}

/**
 * 运行
 *
 * return
 */
-(UpdateStatus*) run:(id<IProgressMonitorDelegate>) monitor {
    // report monitor
    [monitor setTaskName:@"资源更新检查"];
   
#ifdef DEBUG
    FOXLog(@"%@",[NSString stringWithFormat:@"检查资源,是否需要更新 path:%@",self.requestPath]);
#endif
    //stamp信息
    NSArray<NSString*>* lines = nil;
    @try {
    
//       lines =   [HttpRequester  listRemoteFileStamps:_address path:_requestPath baseContext:HttpRequester.INSTANT_CONTEXT_PATH pathFormat:HttpRequester.RELATIVE_PATH timeout:-1];
    } @catch (NSException* e) {
        FOXLog(@"%@",e);
        // report monitor
        [monitor setTaskName:@"网络异常,无法获取资源信息"];
        [monitor worked:20];
 
       UpdateStatus* status=  [[UpdateStatus alloc] initWithCode:UpdateStatus.NOT_CONNECT message:e.reason ];
        return status;
    }
    /********************************test 模拟接口数据*********************************/
  //  lines=@[@"update/aaa.txt\t1000232323\tDESEEFFEFE",@"update/bbb.txt\t1000232323\tDESfdsEEFFEFE",@"update/ccc.txt\t1000232323\tDESfffEEFFEFE"];
    
    // 判断是否需要更新
    if (lines == nil || lines.count == 0) {
        NSString * message=[NSString stringWithFormat:@"@服务器没有更新资源:%@",self.requestPath];
        FOXLog(@"%@",message);
       
        // report monitor
        [monitor setTaskName:@"检查资源完成，不需要更新"];
        [monitor done];
        // 返回操作情况
        UpdateStatus* status=  [[UpdateStatus alloc] initWithCode:UpdateStatus.NOT_NEED_UPDATE message:message ];
        return status;
    }
    
    //获取请求路径长度 //update/resource/android/configuration/client.properties
    int requestPathLen =(int) _requestPath.length;
    //服务端资源stamp
    NSMutableDictionary<NSString*, Node*>* serverResourceStamps =[ NSMutableDictionary<NSString*, Node*> new ];
    for (int i = 0; i < lines.count; i++) {
        
        NSArray<NSString*>* ss = [lines[i] componentsSeparatedByString:HttpRequester.ITEM_SPLITOR];
        //获取路径
        NSString* path = ss[0];
         /*服务端bug临时处理开始*/
        //svr1\www\workspace\www\aaa.txt
        //1\\www\\workspace\\www\\
        
//        if([path containsString:@"www"]){
//          path=[path componentsSeparatedByString:@"www"][1];
//        }
//         path=[path stringByReplacingOccurrencesOfString:@"\\www" withString:@""];
//         path=[path stringByReplacingOccurrencesOfString:@"\\ydptHtpsvr1" withString:@""];
//         path=[path stringByReplacingOccurrencesOfString:@"www" withString:@""];
//         path=[path stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
         if([path characterAtIndex:0]=='/'){
            path=[path substringFromIndex:1];
         }
        /*服务端bug临时处理结束*/
        
        //获取文件MD5
        NSString* md5 = ss[2];
        //获取文件大小
        NSString* s = ss[1];
        long size =  [s longLongValue];
        //定义节点
        Node *node =  [Node new];
        node.md5 = md5;
        node.size = size;
        
       
        
        
        // 如果requestPath和资源长度一致，代表下载的是文件
        if (path.length == requestPathLen) {
            node.singleFile = true;
        } else {
            node.singleFile = false;
        }
        //加入记录
        [serverResourceStamps setObject:node forKey:path];
    }
#ifdef DEBUG
    FOXLog(@"%@",[NSString stringWithFormat:@"获得服务器缓存:%d条,缓存内容:%@",(int)serverResourceStamps.count,serverResourceStamps]);
#endif
    
   
    // 加载本地资源缓存
    NSMutableDictionary<NSString*, NSString*>* clientResourceStamps =[self loadLocalCache];
    
#ifdef DEBUG
    FOXLog(@"%@",[NSString stringWithFormat:@"获得本地缓存:%d条,缓存内容:%@",(int)clientResourceStamps.count,clientResourceStamps]);
#endif
    
    
    
    int parentPathLen = requestPathLen + 1;
    // 3、比较客户端服务器第三方资源MD5
    NSMutableArray<NSString*>* needDownloadSet =  [NSMutableArray<NSString*> new ];
    for (NSString* path in [serverResourceStamps allKeys]) {
        // 获取服务端md5
        Node* serverNode = serverResourceStamps[path];
        
        NSString* key = nil;
        if (serverNode.singleFile) {//得到 aaa.txt
           key= [path componentsSeparatedByString:@"/"].lastObject;
        
        } else { //得道 aaa.txt //parentPathLen文件夹
         
           key= [path substringFromIndex:parentPathLen];
            if([key characterAtIndex:0]=='/'){
                key=[key substringFromIndex:1];
            }
        }
        // 获取客户端md5
        NSString *clientMd5 =clientResourceStamps[key];
        [clientResourceStamps removeObjectForKey:key];
        
        if (clientMd5 == nil) {
            // 加入需要下载集合
            [needDownloadSet addObject:path];
 
            FOXLog(@"%@",[NSString stringWithFormat:@"文件[%@]本地不存在,加入下载列表",path]);
 
            
         } else if (!([clientMd5 isEqualToString:serverNode.md5])) {
            // 加入需要下载集合
            [needDownloadSet addObject:path];
 
             FOXLog(@"%@",[NSString stringWithFormat:@"MD5比较不一致,文件[%@]本地MD5[%@],服务端MD5[%@]",path,clientMd5,serverNode.md5]);
 
             
         }
    }
    
    // 保存删除列表
    NSMutableArray<NSString*>* removeFileList = [NSMutableArray<NSString*> new ];
    [removeFileList addObjectsFromArray:clientResourceStamps.allKeys];
   
    
    // report monitor
    int downloadSize = (int)needDownloadSet.count;
    NSString* tipMsg =[NSString stringWithFormat:@"检查资源完成，需要更新资源个数 size:%d",downloadSize];
    FOXLog(@"%@",tipMsg);
   
    
    [monitor setTaskName:tipMsg];
    [monitor worked:20];//检测完md5 完成 20
    
    //下载单元大小
    long unitSize = 0;
    //下载单元数量
    int unitCount = 0;
    //下载定义
    NSMutableArray<NSString*>* downloadFileUnit =  [NSMutableArray<NSString*> new];
    
    // 计算下载任务量
    int downloadTaskSize = 70; //分了3快 第一块20（监测md5） 第二70 第三 10
    if (downloadSize > 0) {
        downloadTaskSize = 70 / downloadSize;
        if (downloadTaskSize == 0) {
            downloadTaskSize = 1;
        }
    }
    //记录当前下载的索引
    int downloadIndex = 0;
    
    
   
    for(int i=0;i<needDownloadSet.count;i++) {
        NSString *path=needDownloadSet[i];
        //获取Node
        Node* node = serverResourceStamps[path];
        //remote path
        NSString  *remotePath = path;
        
        //判断是否属于大文件
        if (node.size >= self.largeFileSize) {
            NSString* file = self.saveFile;//保存路径
            if (!node.singleFile) {
                
                NSString* localPath = [path substringFromIndex:parentPathLen];
                file = [_saveFile stringByAppendingPathComponent:localPath];//确定新的保存路径
            }
            
            @try {
                //更新下载索引
                downloadIndex++;
                NSString *message =[NSString stringWithFormat:@"正在下载文件(%d/%d)",downloadIndex,downloadSize];
                
                [monitor setTaskName:message];
                FOXLog(@"%@",message);
                
                //断点续传
              BOOL res =  [HttpRequester breakpointDownload:_address path:remotePath saveFile:file baseContext:HttpRequester.INSTANT_CONTEXT_PATH timeout:self.timeout pageSize:-1 callback:nil];
                
                
                if (!res) {
                   
                 
                     NSString *message =[NSString stringWithFormat:@"文件下载失败:%@",remotePath];
                     FOXLog(@"%@",message);
                    // 返回操作情况
                    
                    UpdateStatus* status=  [[UpdateStatus alloc] initWithCode:UpdateStatus.UPDATE_FAIL message:@"下载失败" ];
                    return status;
                    
                    
                }
            } @catch (NSException * e) {
                
                NSString* errorMsg=[NSString stringWithFormat:@"文件下载失败:%@",remotePath];
                FOXLog(@"%@",errorMsg);
                
                UpdateStatus* status=  [[UpdateStatus alloc] initWithCode:UpdateStatus.UPDATE_FAIL message:e.reason ];
                return status;
            }
            
            //增加进度
            [monitor worked:downloadTaskSize];
            
        } else {
            //加入下载单元
            [downloadFileUnit addObject:remotePath];
            unitSize += node.size;
            unitCount += 1;
            
            //判断是否需要启动下载
            if (unitCount >= self.downloadUnitCount || unitSize >= self.downloadUnitSize || (i==needDownloadSet.count-1)) {
                //更新下载索引
                downloadIndex += unitCount;
                
               NSString *infoSb=  [NSString stringWithFormat:@"更新文件(%d/%d",downloadIndex,downloadSize ];
                
                [monitor setTaskName:infoSb];
                FOXLog(@"%@",infoSb);
                
                //如果数量大于1才启用批量下载
                if (unitCount > 1) {
                    
                 NSMutableArray<NSString*>*downloadFilePaths=[NSMutableArray<NSString*> new];
                    [downloadFilePaths addObjectsFromArray:downloadFileUnit];
                    @try {
                        NSArray *unitPathArr=[_saveFile componentsSeparatedByString:@"/"];
                        NSMutableString *sbtemp=[NSMutableString new];
                        //_saveFile 的父目录
                        for(int i=0; i<unitPathArr.count-1;i++){
                            NSString *p=unitPathArr[i];
                            [sbtemp appendString:p];
                            [sbtemp appendString:@"/"];
                        }
                        //解压目录
                        NSString* unzipDir = [sbtemp copy];
                       //批量下载
                        [HttpRequester batchDownload:_address downloadDirectory:_requestPath downloadFilePaths:downloadFilePaths saveDir:unzipDir baseContext:HttpRequester.INSTANT_CONTEXT_PATH checkValidity:true timeout:_timeout];
                        
                       
                        
                    } @catch (NSException *e) {
                        FOXLog(@"%@",e);
                        // 返回操作情况
                        UpdateStatus* status=  [[UpdateStatus alloc] initWithCode:UpdateStatus.UPDATE_FAIL message:e.reason ];
                        return status;
                    }
                }
                else {
                    NSString * file = _saveFile;
                    if (!node.singleFile) {
                        NSString* localPath = [path substringFromIndex:parentPathLen];
                        file = [_saveFile stringByAppendingPathComponent:localPath];
                    }
                    @try {
                        
                       
                        BOOL res= [HttpRequester download:_address path:remotePath saveFile:file baseContext:HttpRequester.INSTANT_CONTEXT_PATH timeout:_timeout];
                        
                        if (!res) {
                           
                            
                            NSString *errorMsg=[NSString stringWithFormat:@"文件下载失败:%@",remotePath];
                            FOXLog(@"%@",errorMsg);
                            
                            // 返回操作情况
                            UpdateStatus* status=  [[UpdateStatus alloc] initWithCode:UpdateStatus.UPDATE_FAIL message:@"下载失败" ];
                            return status;
                            
                        }
                    } @catch (NSException * e) {
                        NSString *errorMsg=[NSString stringWithFormat:@"文件下载失败:%@",remotePath];
                        FOXLog(@"%@",errorMsg);
                        
                        // 返回操作情况
                        UpdateStatus* status=  [[UpdateStatus alloc] initWithCode:UpdateStatus.UPDATE_FAIL message:e.reason ];
                        return status;
                        
                    }
                    //增加进度
                    [monitor worked:downloadTaskSize * unitCount];
                }
                //重置
                [downloadFileUnit removeAllObjects];
                unitSize = 0;
                unitCount = 0;
            }
        }
    }
    
    // 记录删除格式
    int count = 0;
    // 获取删除文件个数
    int deleteSize = (int)removeFileList.count;
    
    
    NSString* msg = [NSString stringWithFormat:@"检查资源[%@]中的多余文件，需要删除个数:%d",_requestPath,deleteSize ];
    [monitor setTaskName:msg];
   
    FOXLog(@"%@",msg);
 
    // 删除多余文件
    for (int i = 0; i < deleteSize; i++) {
        NSString *path = removeFileList[i];
        NSString* file =  [_saveFile stringByAppendingPathComponent:path];
        BOOL res = [FoxFileManager removeItemAtPath:file];
        if (res) {
            count++;
        }
    }
    
    msg = [NSString stringWithFormat:@"删除多余文件完成,删除文件个数:%d", count];
    [monitor setTaskName:msg];
    [monitor worked:10];//删除文件，完成任务的最后10%
#ifdef DEBUG
    FOXLog(@"%@",msg);
#endif
    
    // 返回结果
    if (count != deleteSize) {
        
        // 返回操作情况
        UpdateStatus* status=  [[UpdateStatus alloc] initWithCode:UpdateStatus.DELETE_FAIL message:msg ];
        return status;
    
    
    } else {
        UpdateStatus *status = nil;
        if (self.updatedRestart&& downloadSize > 0) {
            
        status=  [[UpdateStatus alloc] initWithCode:UpdateStatus.SUCCESS_AND_RESTART message:msg ];
        } else {
             status=  [[UpdateStatus alloc] initWithCode:UpdateStatus.SUCCESS message:msg ];
        }
        return status;
    }
    
}

@end











