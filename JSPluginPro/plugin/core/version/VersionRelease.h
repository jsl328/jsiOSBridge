//
//  VersionRelease.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/16.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Status.h"
#import "IProgressMonitorDelegate.h"
@interface VersionRelease : NSObject
+ (instancetype)getInstance;
-(Status*)release:(id<IProgressMonitorDelegate>)monitor;
-(BOOL)recover;
@end
