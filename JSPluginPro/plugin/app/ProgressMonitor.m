//
//  ProgressMonitor.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "ProgressMonitor.h"
#import "RootViewController.h"
#import "YXPlugin.h"
@interface ProgressMonitor(){
    /**
     * 标志是否取消
     */
    BOOL _isCanceled;
}
/**
 * 任务名称
 */
@property(copy)NSString *name;
@property(weak)id rootViewController;
/**
 * 工作量
 */
@property(assign)int work;



@end
@implementation ProgressMonitor
 
-(id)initWithRootViewController:(id)rootViewController_{
    self=[self init];
    self.rootViewController=rootViewController_;
    
    return self;
}


/**
 * 设置任务名称
 *
 * param name
 */
-(void) setTaskName:(NSString*) name {
    self.name = name;
    [self worked:0];
}

/**
 * 设置任务完成量
 *
 * param work
 */
-(void)worked:(int) work {
    self.work += work;
    int fff=self.work;
    FOXLog(@"<<<<<<<<<<<<<<fff=%d",fff);
    
    if (self.work >= 100) {
        self.work = 100;
    }
    // 更新状态
    RootViewController *root=(RootViewController *)self.rootViewController;
    [root setBootStatus:self.name finishRate:self.work];
   
    
}
/**
 * 判断任务是否取消
 *
 * return
 */
-(BOOL) isCanceled{
    return _isCanceled;
}

/**
 * 设置任务取消
 *
 * param value
 */
-(void)setCanceled:(BOOL) value{
    _isCanceled=value;
}


/**
 * 完成任务
 */
-(void) done {
    // 更新状态
    [self.rootViewController finishBoot];
    
}


/**
 * 回退任务
 */
-(void) rollback {
    int n = -1 * self.work;
    [self worked:n];
}

/**
 * 设置子任务完成量<br>
 * 只允许内部调用
 *
 * param name
 * param work
 */
-(void) workSubTask:(NSString*) name work: (int) work {
   self.work += work;
    if (self.work >= 100) {
        self.work = 100;
    }
    FOXLog(@"=========进度：%d",self.work);
    // 更新状态
    RootViewController *root=(RootViewController *)self.rootViewController;
    [root setBootStatus:name finishRate:self.work];
}

/**
 * 完成子任务 <br>
 * 只允许内部调用
 */
-(void) doneSubTask:(NSString*) name {
    // 更新状态
    RootViewController *root=(RootViewController *)self.rootViewController;
    [root setBootStatus:name finishRate:self.work];
   
}
@end
