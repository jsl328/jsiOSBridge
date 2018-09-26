//
//  SimulatorManager.m
//  YXBuilder
//
//  Created by LiYuan on 2018/1/17.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "SimulatorManager.h"
#import <sys/utsname.h>

@implementation SimulatorManager

+ (BOOL)SimulatorCheck {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceModel isEqualToString:@"i386"])   return YES;
    if ([deviceModel isEqualToString:@"x86_64"]) return YES;
    
    return NO;
}

@end
