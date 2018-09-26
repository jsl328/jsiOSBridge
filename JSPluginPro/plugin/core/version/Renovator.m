//
//  Renovator.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "Renovator.h"
#import "IUpdateTaskDelegate.h"
#import "ConfigPreference.h"
#import "Address.h"
#import "AddressManager.h"
#import "FoxFileManager.h"
#import "UpdateTaskParser.h"
#import "UpdateTask.h"
#import "SubProgressMonitor.h"
//#import "ApkUpdateTask.h"
#import "HttpRequester.h"
#import "FileAccessor.h"
@interface Renovator(){
    
}
/**
 * 远程版本文件路径（增量更新）
 */
@property(copy)NSString *remoteVersionPath;
/**
 * 本地版本文件路径（增量更新）
 */
@property(copy)NSString *localVersionPath;
    /**
     * 远程版本文件路径（企业更新）
     */
@property(copy)NSString *remoteEnterPriseVersionPath;
    
/**
 * 更新列表
 */
@property(strong) NSArray<id<IUpdateTaskDelegate>>*updateTasks;


/*
 * appStore 下载地址
 */
@property(copy) NSString *appstoreDownLoadPath;
@end
@implementation Renovator
static Renovator *_instance;

-(id)init{
    if(self=[super init]){
        // 获取配置
        ConfigPreference *pref = [ConfigPreference getInstance];
        // 获取版本文件路径
        self.remoteVersionPath =  [pref getString:@"version" key:@"remoteVersionFile" defaultValue:@"update/resource/android/version.ini"];
        
        self.localVersionPath=[pref getString:@"version" key:@"localVersionFile" defaultValue:@"version/version.ini"];
        
        self.remoteEnterPriseVersionPath= [pref get:@"version" key:@"remoteEnterPriseVersionFile" defaultValue:@"update/resource/ios/enterpriseversion.ini"];
        
       
    }
    return self;
}

+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


-(NSString*)getLocalVersion{
    NSString* localVersion = @"";
    // 获取文件访问器
    FileAccessor* fileAccessor = [FileAccessor getInstance];
    // 获取本地版本文件
    NSString* localVersionFile = [fileAccessor getFile:self.localVersionPath];
   
    //判断文件是否存在
    if ([FoxFileManager isExistsAtPath:localVersionFile]) {
            // 获取本地版本
        localVersion =[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:localVersionFile] encoding:NSUTF8StringEncoding];
        localVersion=[localVersion stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        localVersion=[localVersion stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
    }
    return localVersion;
}
/**
 * 检查并更新
 *
 * param httpAddress
 * param updateTaskNames
 * param monitor
 * return
 */
-(UpdateStatus*) checkAndUpdate:(NSString*) httpAddress updateTaskNames:(NSArray<NSString*>*)updateTaskNames monitor: (id<IProgressMonitorDelegate>) monitor {
    //更新任务列表
    NSMutableArray<id<IUpdateTaskDelegate>>* updateTaskList = [NSMutableArray<id<IUpdateTaskDelegate>> new ];
    // 获取任务数量
    int size = (int)updateTaskNames.count;
    for (int i = 0; i < size; i++) {
        //获取更新任务名称
        NSString* name = updateTaskNames[i];
        // 获取更新任务
        id<IUpdateTaskDelegate> updateTask = [self findUpdateTask:name];
        //加入队列
        [updateTaskList addObject: updateTask];
    }
    //如果没指定地址，设置默认地址
    if (httpAddress == nil) {
        // 获取更新地址
        Address *address = [AddressManager geVersionAddress];
        // 获取HTTP地址
        httpAddress = [address httpAddress];
    }
    //执行检查并更新任务
   UpdateStatus *updateStatus = [self doCheckAndUpdate:httpAddress updateTaskList:updateTaskList monitor:monitor];
    return updateStatus;
}

/**
 * 执行检查并更新
 *
 * param updateTaskList
 * param monitor
 * return
 */
-(UpdateStatus*) doCheckAndUpdate:(NSString*) address updateTaskList: (NSArray<id<IUpdateTaskDelegate>>*) updateTaskList monitor: (id<IProgressMonitorDelegate>) monitor {
    
    // 获取任务数量
    int size = (int)updateTaskList.count;
    if(size==0){
      return  [[UpdateStatus alloc] initWithCode:UpdateStatus.NOT_NEED_UPDATE message:@""];
    }
    // 获取任务量
    int itemTaskSize = 100 / size;
    if (itemTaskSize == 0) {
        itemTaskSize = 1;
    }
    
    for (int i = 0; i < size; i++) {
        // 定义子monitor
        SubProgressMonitor *subMonitor =  [[SubProgressMonitor alloc] initMonitor:monitor subWork: itemTaskSize ];
        id<IUpdateTaskDelegate> updateTask = updateTaskList[i];
        // 设置下载地址
        [updateTask setAddress:address];
        // 执行更新操作
        UpdateStatus *updateStatus = [updateTask run:subMonitor];//monitor总量为40
        
        int code = [updateStatus getCode];
        if (code == UpdateStatus.SUCCESS_AND_RESTART) {
            // 完成任务
            [subMonitor done];
            return updateStatus;
        } else if (code == UpdateStatus.SUCCESS_AND_EXIT) {
            // 完成任务
            [subMonitor done];
            return updateStatus;
        } else if (code == UpdateStatus.UPDATE_FAIL_AND_EXIT) {
            // 完成任务
            [subMonitor done];
            return updateStatus;
        } else if (updateTask.necessary) {//必须要有的文件
            if (code == UpdateStatus.NOT_CONNECT) {
                // 回退任务
                [subMonitor rollback];
                return updateStatus;
            } else if (code == UpdateStatus.UPDATE_FAIL) {
                // 回退任务
                [subMonitor rollback];
                return updateStatus;
            } else if (code == UpdateStatus.DELETE_FAIL) {
                // 回退任务
                [subMonitor rollback ];
                return updateStatus;
            }
        }
        // 完成任务
        [subMonitor done];
    }
    [monitor done];
    // 返回成功结果
    UpdateStatus *updateStatus =   [[UpdateStatus alloc] initWithCode:UpdateStatus.SUCCESS message:@""];
   
    return updateStatus;
}


/**
 * 查找更新任务
 *
 * param name
 * return
 */
-(id<IUpdateTaskDelegate>) findUpdateTask:(NSString*) name {
    NSArray<id<IUpdateTaskDelegate>>* updateTasks = [self getUpdateTasks];
    //更新任务
    id<IUpdateTaskDelegate> updateTask = nil;
    //查找更新任务
    for (int i = 0, size = (int)updateTasks.count; i < size; i++) {
        //获取更新任务
        id<IUpdateTaskDelegate> curUpdateTask = updateTasks[i];
        if ([name isEqualToString:curUpdateTask.requestPath]) {
            updateTask = curUpdateTask;
            break;
        }
    }
    return updateTask;
}



/**
 * 获取更新任务名称列表
 *
 * return
 */
-(NSArray<NSString*>*) getUpdateTaskNames {
    NSArray<id<IUpdateTaskDelegate>>* updateTasks =[self getUpdateTasks];
    //任务名称列表
    NSMutableArray<NSString*> *names = [NSMutableArray<NSString*> new ];
    for (int i = 0, size = (int)updateTasks.count; i < size; i++) {
        //获取更新任务
        id<IUpdateTaskDelegate> task = updateTasks[i];
        //获取请求路径
        NSString *requestPath = [task requestPath];
        //加入列表
        [names addObject:requestPath];
    }
    return names;
   
}

/**
 * 获取 update Tasks
 *
 * return
 */
 -(NSArray<id<IUpdateTaskDelegate>>*) getUpdateTasks {
   
        if (self.updateTasks == nil) {
            
            //获取更新任务
            NSString* defaultUpdateTasks = @"[update/resource/ios/configuration/client.properties,configuration/client.properties,true]";
            // 获取配置
            ConfigPreference *pref = [ConfigPreference getInstance];
            
            NSString *s = [pref getString:@"version" key:@"updateTasks" defaultValue:defaultUpdateTasks];
            
            
            //解析更新列表
            self.updateTasks = [UpdateTaskParser parseUpdateTask:s class:[UpdateTask class]];
            
        }
    
    return self.updateTasks;
}

/**
 * 记录版本
 *
 * @param remoteVersion
 * @return
 */
-(BOOL) recordVersion:(NSString*) remoteVersion{
    if (remoteVersion == nil) {
        return false;
    }
    // 获取文件访问器
    FileAccessor *fileAccessor = [FileAccessor getInstance];
    // 获取本地版本文件
    NSString* localVersionFile = [fileAccessor getFile:self.localVersionPath];
    
     return  [remoteVersion writeToFile:localVersionFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}
    /**
     * 获取服务端版本号
     *
     * return
     */
-(NSString*) getRemoteVersion{
  return  [self getRemoteVersion:self.localVersionPath remoteVersionPath:self.remoteVersionPath];
}
    

    -(NSString*) getRemoteVersion:(NSString*)localVersionPath remoteVersionPath:(NSString*)remoteVersionPath{
    // 获取版本地址列表
    NSArray<Address*> *versionAddressList = [AddressManager
                                             getVersionAddressList];
    
    // 如果为下载地址列表为空，不进行更新
    if (versionAddressList == nil || versionAddressList.count == 0) {
        NSString *msg = @"下载地址列表为空";
        FOXLog(@"%@",msg);
        return nil;
    }
    FileAccessor* fileAccessor = [FileAccessor getInstance];
    // 获取临时文件路径
   
     NSString *tmpFilePath=  [NSString stringWithFormat:@"%@_tmp",localVersionPath];
    // 获取临时文件全路径
    NSString * tmpFile = [fileAccessor getFile:tmpFilePath];
    
    //检查结果队列
    NSMutableArray<id> *list =  [NSMutableArray<id> new ];
    //HTTP地址
    NSString *httpAddress =nil;
    
    int curIndex = [AddressManager getVersionAddressIndex];
    int endIndex = curIndex;
    do {
        // 获取更新地址
        Address* address = [AddressManager geVersionAddress];
        // 设置HTTP地址
        NSString *s = [address httpAddress];
        
        // 判断HTTP地址是否为空
        if (s == nil) {
            // 修改版本服务器地址索引
            curIndex = [AddressManager nextVersionAddressIndex];
            continue;
        }

        @try {
            // 判断远程文件是否存在
            BOOL exists =[HttpRequester isRemoteFileExists:s path:remoteVersionPath baseContext:HttpRequester.INSTANT_CONTEXT_PATH timeout:-1];
            
            if (exists) {
                //记录地址
                httpAddress = s;
                break;
            } else {
                [list addObject:@(curIndex)];
                // 修改版本服务器地址索引
                curIndex = [AddressManager nextVersionAddressIndex];
            }
        } @catch (NSException *e) {
            //打印日志
            FOXLog(@"error=%@",e);
            //加入异常
            [list addObject:e];
            // 修改版本服务器地址索引
            curIndex = [AddressManager nextVersionAddressIndex];
        }
    } while (curIndex != endIndex);
    
    if (httpAddress != nil) {
      
       
            // 下载服务器版本文件
 
        
    BOOL res  = [HttpRequester download:httpAddress path:remoteVersionPath saveFile:tmpFile baseContext:[HttpRequester INSTANT_CONTEXT_PATH]  timeout:-1];
        
        
        
        if (res) {
                 
                //获取输入流
                NSData *data= [fileAccessor openFileData:tmpFile];
                  if(data){
                   // 获取远程版本
                      NSString* remoteVersion=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                   return remoteVersion;
                  }
                  else{
                      FOXLog(@"%@",@"文件不存在");
                      return nil;
                   }
             
             } else {
                FOXLog(@"%@",@"无法下载文件");
                return nil;
            }
       
    } else {
        int size = (int)list.count;
        //代表没配置适合的http地址，返回空
        if (size == 0) {
            NSString *msg = @"下载地址列表配置错误";
            FOXLog(@"%@",msg);
            return nil;
        }
        
        int selectedIndex = -1;
        
        for (int i = 0; i < size; i++) {
            //获取对象
            id obj = list[i];
            //获取对象class
            
            if ([obj isKindOfClass:[NSNumber class]]) {
                selectedIndex = [obj intValue];
                break;
            }
        }
        
        //设置选中的index
        if (selectedIndex != -1) {
            [AddressManager setVersionAddressIndex:selectedIndex];
            return nil;
        } else {
            NSString* msg = @"下载地址连接失败";
            FOXLog(@"%@",msg);
            return nil;
        }
    }
    
    
    return nil;
}
-(BOOL)enterpriseCheck{
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    //
   NSString * newVersion=[self getRemoteVersion:@"version/enterpriseversionTMP.ini" remoteVersionPath:self.remoteEnterPriseVersionPath];
    currentVersion = [currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (currentVersion.length==2) {
        currentVersion  = [currentVersion stringByAppendingString:@"0"];
    }else if (currentVersion.length==1){
        currentVersion  = [currentVersion stringByAppendingString:@"00"];
    }
    newVersion = [newVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (newVersion.length==2) {
        newVersion  = [newVersion stringByAppendingString:@"0"];
    }else if (newVersion.length==1){
        newVersion  = [newVersion stringByAppendingString:@"00"];
    }
    if([currentVersion floatValue] < [newVersion floatValue])//需要更新
    {
        return YES;
    }
    else{
        return NO;
    }
    return NO;
}
/*appstore版本检测*/
-(BOOL)appStoreCheck{
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    __block NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    
   
   __block BOOL isDownLoad=NO;
    ConfigPreference *pref = [ConfigPreference getInstance];
    NSString* appId =[pref getString:@"version" key:@"appId" defaultValue:@""];
    FOXLog(@"【1】当前为APPID检测，您设置的APPID为:%@  当前版本号为:%@",appId,currentVersion);
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",appId]]];
    NSURLSession *session = [NSURLSession sharedSession];
    FOXLog(@"【2】开始检测...");
    __weak typeof (self) weakSelf=  self;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
     NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          
         if (error) {
            FOXLog(@"【3】检测失败，原因：\n%@",error);
            isDownLoad=NO;
            dispatch_semaphore_signal(semaphore);   //发送信号
             
        }
        else{
        NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if ([appInfoDic[@"resultCount"] integerValue] == 0) {
            NSLog(@"检测出未上架的APP或者查询不到");
            isDownLoad=NO;
            dispatch_semaphore_signal(semaphore);   //发送信号
            
        }
        else{
       FOXLog(@"【3】苹果服务器返回的检测结果：\n appId = %@ \n bundleId = %@ \n 开发账号名字 = %@ \n 商店版本号 = %@ \n 应用名称 = %@ \n 打开连接 = %@",appInfoDic[@"results"][0][@"artistId"],appInfoDic[@"results"][0][@"bundleId"],appInfoDic[@"results"][0][@"artistName"],appInfoDic[@"results"][0][@"version"],appInfoDic[@"results"][0][@"trackName"],appInfoDic[@"results"][0][@"trackViewUrl"]);
      
            NSString *appStoreVersion = appInfoDic[@"results"][0][@"version"];
        currentVersion = [currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
        if (currentVersion.length==2) {
            currentVersion  = [currentVersion stringByAppendingString:@"0"];
        }else if (currentVersion.length==1){
            currentVersion  = [currentVersion stringByAppendingString:@"00"];
        }
        appStoreVersion = [appStoreVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
        if (appStoreVersion.length==2) {
            appStoreVersion  = [appStoreVersion stringByAppendingString:@"0"];
        }else if (appStoreVersion.length==1){
            appStoreVersion  = [appStoreVersion stringByAppendingString:@"00"];
        }
        if([currentVersion floatValue] < [appStoreVersion floatValue])
        {
            NSLog(@"【4】判断结果：当前版本号%@ < 商店版本号%@ 需要更新",[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],appInfoDic[@"results"][0][@"version"]);
            
             isDownLoad=YES;
             weakSelf.appstoreDownLoadPath=appInfoDic[@"results"][0][@"trackViewUrl"];
             dispatch_semaphore_signal(semaphore);   //发送信号
            
        }else{
            isDownLoad=NO;
            NSLog(@"【4】判断结果：当前版本号%@ > 商店版本号%@ 不需要更新",[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],appInfoDic[@"results"][0][@"version"]);
            dispatch_semaphore_signal(semaphore);   //发送信号
        }
            
        }
             
    }
        
        
    }];
    
    [task resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    return isDownLoad;
    
  
}
-(void)doDownloadFromEnterprise:(NSString*)url Monitor: (id<IProgressMonitorDelegate>) monitor{
    if(url&&url.length>0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
         [monitor done];
    }
}

-(void)doDownloadFromAppStoreWithMonitor: (id<IProgressMonitorDelegate>) monitor{
    NSString *fff=self.appstoreDownLoadPath;
    if(self.appstoreDownLoadPath&&self.appstoreDownLoadPath.length>0){
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appstoreDownLoadPath] options:@{} completionHandler:^(BOOL success) {
             dispatch_semaphore_signal(semaphore);   //发送信号
        }];
         dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
         [monitor done];
    }
}
































@end
