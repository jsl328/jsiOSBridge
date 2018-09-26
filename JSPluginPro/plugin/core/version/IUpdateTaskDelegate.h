//
//  IUpdateTaskDelegate.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//
#import "IProgressMonitorDelegate.h"
#import "UpdateStatus.h"
@protocol IUpdateTaskDelegate<NSObject>
/**
 * 获取地址
 *
 * @return
 */
-(NSString*) address;

/**
 * 设置地址
 *
 * @param address
 */
-(void)setAddress:(NSString*) address;

/**
 * 获取请求路径
 *
 * @return
 */
-(NSString*) requestPath;

/**
 * 设置请求路径
 *
 * @param requestPath
 */
-(void) setRequestPath:(NSString*) requestPath;

/**
 * 获取保存路径
 *
 * @return
 */
-(NSString*) saveFile;

/**
 * 设置保存路径
 *
 * @param saveFile
 */
-(void)setSaveFile:(NSString*) saveFile;


/**
 * 获取超时时间
 *
 * @return
 */
-(int) timeout;

/**
 * 设置超时时间
 *
 * @param timeout
 */
-(void) setTimeout:(int) timeout;

/**
 * 是否更新后重启
 *
 * @return
 */
-(BOOL) updatedRestart;

/**
 * 设置更新后重启
 *
 * @param updatedRestart
 */
-(void) setUpdatedRestart:(BOOL) updatedRestart;

/**
 * 是否需要更新成功
 *
 * @return
 */
-(BOOL) necessary;

/**
 * 设置是否需要更新成功
 *
 * @param necessary
 */
-(void) setNecessary:(BOOL)  necessary;

/**
 * 设置下载的单元大小
 *
 * @param downloadUnitSize
 */
-(void)  setDownloadUnitSize:(long) downloadUnitSize;

/**
 * 获取下载的单元大小
 *
 * @return
 */
-(long) downloadUnitSize;

/**
 * 设置下载的单元数量
 *
 * @param downloadUnitCount
 */
-(void) setDownloadUnitCount:(int) downloadUnitCount;

/**
 * 获取下载的单元数量
 *
 * @return
 */
-(int) downloadUnitCount;

/**
 * 设置大文件大小
 *
 * @param largeFileSize
 */
-(void) setLargeFileSize:(long) largeFileSize;

/**
 * 获取大文件大小
 */
-(long) largeFileSize;

/**
 * 运行
 *
 * @return
 */
-(UpdateStatus*) run:(id<IProgressMonitorDelegate>) monitor;
@end

