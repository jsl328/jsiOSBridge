//
//  UIEventExecutorDelegate.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/21.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

@protocol UIEventExecutorDelegate <NSObject>

/**
 * 判断是否为UI线程
 * @return
 */
-(BOOL) isUIThread;

/**
 * 执行UI事件
 * @param runnable
 */
-(void) run;
@end

