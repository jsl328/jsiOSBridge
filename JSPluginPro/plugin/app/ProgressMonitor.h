//
//  ProgressMonitor.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IProgressMonitorDelegate.h"
@interface ProgressMonitor : NSObject<IProgressMonitorDelegate>
-(id)initWithRootViewController:(id)rootViewController;


/**
 * 设置任务名称
 *
 * param name
 */
-(void) setTaskName:(NSString*) name ;

/**
 * 设置任务完成量
 *
 * param work
 */
-(void)worked:(int) work ;
/**
 * 判断任务是否取消
 *
 * return
 */
-(BOOL) isCanceled;

/**
 * 设置任务取消
 *
 * param value
 */
-(void)setCanceled:(BOOL) value;


/**
 * 完成任务
 */
-(void) done ;

/**
 * 回退任务
 */
-(void) rollback ;

/**
 * 设置子任务完成量<br>
 * 只允许内部调用
 *
 * param name
 * param work
 */
-(void) workSubTask:(NSString*) name work: (int) work;
/**
 * 完成子任务 <br>
 * 只允许内部调用
 */
-(void) doneSubTask:(NSString*) name ;
@end
