//
//  UpdateTask.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/21.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUpdateTaskDelegate.h"





@interface UpdateTask : NSObject<IUpdateTaskDelegate>
/**
 * 地址
 */
@property(copy) NSString* address;

/**
 * 请求路径
 */
@property(copy) NSString *requestPath;
/**
 * 保存路径
 */
@property(copy) NSString * saveFile;

/**
 * 是否更新后重启
 */
@property(assign) BOOL updatedRestart;//false

/**
 * 必须更新成功
 */
@property(assign) BOOL necessary ;//yes


/**
 * 超时时间
 */
@property(assign) int timeout ;// GlobalConstant.TIMEOUT * 3;

/**
 * 批量下载单元大小
 */
@property(assign) long downloadUnitSize ;//= -1;
/**
 * 批量下载单元数量
 */
@property(assign) int downloadUnitCount;// = -1;

/**
 * 大文件大小
 */
@property(assign) long largeFileSize; //= 1024 * 1024 * 5;



@end
