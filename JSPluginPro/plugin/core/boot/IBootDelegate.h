//
//  IBootDelegate.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//
#import "IProgressMonitorDelegate.h"
@class Status;
@protocol IBootDelegate<NSObject>
-(Status*)start:(id)context monitor:(id<IProgressMonitorDelegate>)monitor;
-(Status*)stop:(id)context monitor:(id<IProgressMonitorDelegate>)monitor;
-(BOOL)isStarted;
@end
