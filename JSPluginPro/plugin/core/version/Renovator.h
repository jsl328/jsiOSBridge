//
//  Renovator.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpdateStatus.h"
#import "IProgressMonitorDelegate.h"
@interface Renovator : NSObject
+ (instancetype)getInstance;
//获取增量更新远程版本
-(NSString*) getRemoteVersion;
//获取增量更新本地版本
-(NSString*)getLocalVersion;
 
-(UpdateStatus*) checkAndUpdate:(NSString*) httpAddress updateTaskNames:(NSArray<NSString*>*)updateTaskNames monitor: (id<IProgressMonitorDelegate>) monitor;
/**
 * 获取更新任务名称列表
 *
 * @return
 */
-(NSArray<NSString*>*) getUpdateTaskNames ;
-(BOOL) recordVersion:(NSString*) remoteVersion;

-(BOOL)appStoreCheck;
    -(BOOL)enterpriseCheck;
-(void)doDownloadFromAppStoreWithMonitor: (id<IProgressMonitorDelegate>) monitor;
-(void)doDownloadFromEnterprise:(NSString*)url Monitor: (id<IProgressMonitorDelegate>) monitor;
@end
