//
//  SubProgressMonitor.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "SubProgressMonitor.h"
@interface SubProgressMonitor(){
    
    
}
/**
 * 父亲进程监控器
 */
@property(weak) id<IProgressMonitorDelegate>progressMonitor;
/**
 * 任务名称
 */
@property(copy) NSString *name;

/**
 * 比例
 */
@property(assign) double scale;

/**
 * sub work
 */
@property (assign)int subWork;

/**
 * total work
 */
@property(assign)int totalWork;

@end
@implementation SubProgressMonitor



/**
 * 构造函数
 *
 * param progressMonitor
 * param subWork
 */

-(id)initMonitor:(id<IProgressMonitorDelegate>)progressMonitor subWork:(int)subWork{
    self=[self init];
    self.progressMonitor=progressMonitor;
    
    self.scale=subWork/100;
   
    self.subWork=subWork;
    return self;
}



/**
 * 设置任务名称
 *
 * param name
 */
-(void) setTaskName:(NSString*) name {
    self.name = name;
    [self.progressMonitor setTaskName:name];
}

/**
 * 设置任务完成量
 *
 * param work
 */
-(void) worked:(int) work {
    //更新总任务量
    self.totalWork+=work;
    
    work = (int) (work * self.scale);
   [ self.progressMonitor workSubTask:self.name work:work];
    
}

/**
 * 完成任务
 */
-(void) done {
    
    [_progressMonitor workSubTask:self.name work:_subWork];
}

/**
 * 判断任务是否取消
 *
 * return
 */
-(BOOL) isCanceled {
    return [self.progressMonitor isCanceled];
}

/**
 * 设置任务取消
 *
 * param value
 */
-(void) setCanceled:(BOOL) value {
   [ self.progressMonitor setCanceled:value];
}

/**
 * 回退任务
 */
-(void) rollback{
    int n = -1 * self.totalWork;
    [self worked:n];
}

/**
 * 设置子任务完成量<br>
 * 只允许内部调用
 *
 * param name
 */
-(void) workSubTask:(NSString*) name work: (int) work {
    // do nothing
    int ii=0;
}

/**
 * 完成子任务 <br>
 * 只允许内部调用
 */
-(void) doneSubTask:(NSString*) name {
    // do nothing
}
@end
