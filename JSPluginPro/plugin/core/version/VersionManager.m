//
//  VersionManager.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "VersionManager.h"
#import "IProgressMonitorDelegate.h"
#import "Status.h"
#import "SubProgressMonitor.h"
#import "VersionRelease.h"
#import "ConfigPreference.h"
#import "AddressManager.h"
#import "Address.h"
#import "Renovator.h"
#import "YXPlugin.h"
#import "AlertDialog.h"
@interface VersionManager()
@property(assign)BOOL started;
@property(copy)NSString *name;
/**
 * 远程版本文件路径
 */
@property(copy)NSString *remoteVersionPath;

/**
 * 本地版本文件路径
 */
@property(copy)NSString *localVersionPath;


@end
@implementation VersionManager
-(id)init{
    if(self=[super init]){
        self.name=@"版本管理模块";
    }
    return self;
}

-(Status*)start:(id)context monitor:(id<IProgressMonitorDelegate>)monitor{
    
    self.started=YES;
    // [NSThread sleepForTimeInterval:2];
    //版本解压20 包更新40  增量更新 40
    
    //模拟版本检测
    SubProgressMonitor* releaseSubMonitor =  [[SubProgressMonitor alloc] initMonitor:monitor subWork:20];
    //发布版本
    Status *status = [[VersionRelease getInstance] release:releaseSubMonitor];
    if(status.resultCode==Status.EXIT){
        
        NSArray* buttonTexts =@[@"确定"];
        NSArray*buttonValues =  @[@2];
        
        int action=[AlertDialog  show:@"存储空间几乎已满" message:@"您可以在“设置”中管理存储空间，否则应用可能无法正常运行" buttonTexts: buttonTexts
                             buttonValues: buttonValues];
        if(action==2){
             return status;
        }
    }
    
    // 获取配置
    ConfigPreference *pref = [ConfigPreference getInstance];
    BOOL updateEnabled = [pref getBoolean:@"version" key:@"updateEnabled" defaultValue:YES];
    //***********************test**************************/
    // updateEnabled=YES;
    NSString *fff=  NSHomeDirectory();
    
    if (!updateEnabled) {
        FOXLog(@"%@",@"自动更新功能已经关闭");
        // 返回成功结果
        Status *status = [[Status alloc] initWithCode:Status.SUCCESS] ;
        return status;
    }
    // 获取版本地址列表
    NSArray<Address*> *versionAddressList = [AddressManager
                                             getVersionAddressList];
    // 如果为下载地址列表为空，不进行更新
    if (versionAddressList == nil || versionAddressList.count == 0) {
        FOXLog(@"%@",@"下载地址列表为空，不进行更新");
        return  [[Status alloc] initWithCode:Status.SUCCESS];
        
    }
    //获取更新策略
    NSString* updatePolicy =  [pref getString:@"version" key:@"updatePolicy" defaultValue:@"options"];
    
    //更新方式
    NSString* updateType =  [pref getString:@"version" key:@"updateType" defaultValue:@"appstore"];
    //记录动作
    int action = -1;
    //获取更新实例
    Renovator *renovator = [Renovator getInstance];
    //远程版本号
    NSString* remoteVersion = nil;
    @try {
        //获取当前地址
        Address* address = [AddressManager geVersionAddress];
        //获取HTTP地址
        NSString *httpAddress = [address httpAddress];
        
        // 定义子monitor
        SubProgressMonitor *ipaSubMonitor =   [[SubProgressMonitor alloc] initMonitor:monitor subWork:40];
        
        int code = 1;
        //检查并更新ipa【全量更新】
        NSArray* buttonTexts = [updatePolicy isEqualToString:@"options"] ?@[@"忽略", @"更新"]: @[@"更新"];
        NSArray*buttonValues = [updatePolicy isEqualToString:@"options"] ? @[@1,@2] : @[@2];
         
        if([updateType isEqualToString:@"appstore"]){
            if([renovator appStoreCheck]){//appstore更新
                
                action=[AlertDialog  show:@"提示" message:@"检测到新版本,是否更新？" buttonTexts: buttonTexts
                             buttonValues: buttonValues];
                if(action==2){//更新
                    [renovator doDownloadFromAppStoreWithMonitor:ipaSubMonitor];
                    return  [[Status alloc] initWithCode:Status.EXIT];//应用退出
                }
            }
        }
        else if([updateType isEqualToString:@"enterprise"]){
 

            if([renovator enterpriseCheck]){//appstore更新
            NSString* downURL =  [pref getString:@"version" key:@"enterpriseURL" defaultValue:@""];
             
            if(downURL.length>0){//有企业下载地址
                action=[AlertDialog  show:@"提示" message:@"检测到新版本,是否更新？" buttonTexts: buttonTexts
                             buttonValues: buttonValues];
                if(action==2){//更新
                    //"itms-services://?action=download-manifest&url=https://www.xxxx.com/ipa/manifest.plist"
                    [renovator doDownloadFromEnterprise:downURL Monitor:ipaSubMonitor];
                    return  [[Status alloc] initWithCode:Status.EXIT];//应用退出
                }
            }
        }
            
        }
        //增量更新
        code=UpdateStatus.NOT_NEED_UPDATE;
        UpdateStatus *updateStatus =nil;
        //不需要更新或者是更新成功
        if(code==UpdateStatus.NOT_NEED_UPDATE || code== UpdateStatus.SUCCESS){

            //获取远程版本号
            //如果版本号一致，就不需要增量更新了
            remoteVersion = [renovator getRemoteVersion];//走http[测试通过]
            //获取版本号为NULL
            if (remoteVersion != nil) {
                //获取本地版本号
                NSString *localVersion = [renovator getLocalVersion];
                //判断本地版本号和远程版本号是否一致，如果一致不进行更新

                localVersion=[localVersion stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                remoteVersion=[remoteVersion stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if ([remoteVersion isEqualToString:localVersion]) {
                    FOXLog(@"%@",@"程版本号一致,不进行更新检查");
                    //忽略更新
                    return  [[Status alloc] initWithCode:Status.SUCCESS];
                }
            }

            // 定义子monitor
            SubProgressMonitor *subMonitor = [[SubProgressMonitor alloc] initMonitor:monitor subWork:40];
            //获取更新任务列表【增量更新】
            NSArray<NSString*>* updateTaskNames = [renovator getUpdateTaskNames];
            
            //增量更新
            //检查并更新
            updateStatus = [renovator checkAndUpdate:httpAddress updateTaskNames:updateTaskNames monitor:subMonitor];
            
        }
        
        //更新code值
         code=[updateStatus getCode];
        
        if (code == UpdateStatus.NOT_CONNECT) {
            
            NSArray* buttonTexts = [updatePolicy isEqualToString:@"options"] ? @[@"退出", @"忽略", @"重试"] :@[@"退出", @"重试"];
            NSArray*buttonValues = [updatePolicy isEqualToString:@"options"] ? @[@0, @1, @2] : @[@0, @2];
            
            action =  [AlertDialog  show:@"提示" message:@"更新失败，网络错误" buttonTexts:(NSArray<NSString*>*)buttonTexts
                            buttonValues:buttonValues];
            
         } else if (code == UpdateStatus.UPDATE_FAIL) {
            
            NSArray* buttonTexts = [updatePolicy isEqualToString:@"options"] ? @[@"退出", @"忽略", @"重试"] :@[@"退出", @"重试"];
            NSArray*buttonValues = [updatePolicy isEqualToString:@"options"] ? @[@0, @1, @2] : @[@0, @2];
            
            action =  [AlertDialog  show:@"提示" message:[NSString stringWithFormat:@"更新失败，%@",[updateStatus getMessage]] buttonTexts:(NSArray<NSString*>*)buttonTexts
                            buttonValues:buttonValues];
            
            
            
        } else if (code == UpdateStatus.UPDATE_FAIL_AND_EXIT) {
            //更新失败，退出
            action = 0;
        } else if (code == UpdateStatus.SUCCESS_AND_EXIT) {
            //更新成功，退出
            action = 0;
        } else if(code == UpdateStatus.SUCCESS){
            //记录版本号
            [renovator recordVersion:remoteVersion];
            action = 1;
        } else if(code == UpdateStatus.SUCCESS_AND_RESTART){
            //记录版本号
            [renovator recordVersion:remoteVersion];
            action = 2;
        }else if(code == UpdateStatus.NOT_NEED_UPDATE){
            //记录版本号
            [renovator recordVersion:remoteVersion];
            action = 1;
        }else{
            action = 1;
        }
        
        
    }
    @catch(NSException *ex){
        NSArray* buttonTexts = [updatePolicy isEqualToString:@"options"] ? @[@"退出", @"忽略", @"重试"] :@[@"退出", @"重试"];
        NSArray*buttonValues = [updatePolicy isEqualToString:@"options"] ? @[@0, @1, @2] : @[@0, @2];

        action =  [AlertDialog  show:@"提示" message:ex.reason buttonTexts:(NSArray<NSString*>*)buttonTexts
                        buttonValues:buttonValues];
    }
    if (action == 0) {
        //action=0，退出
        return  [[Status alloc] initWithCode:Status.EXIT];
        
    } else if (action == 1) {
        //action=1，忽略更新、更新成功、不需要更新
        return  [[Status alloc] initWithCode:Status.SUCCESS];
        
    } else if (action == 2) {
        //action=2，重新启动
        return  [[Status alloc] initWithCode:Status.RESTART];
        
    } else {
        return  [[Status alloc] initWithCode:Status.SUCCESS];
    }
    
    return  [[Status alloc] initWithCode:Status.SUCCESS] ;
    
}


-(Status*)stop:(id)context monitor:(id<IProgressMonitorDelegate>)monitor{
    self.started=false;
    return  [[Status alloc] initWithCode:Status.SUCCESS] ;
}
-(BOOL)isStarted{
    return YES;
}
@end

