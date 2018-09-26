//
//  PrisonBreakCheck.m
//  ProductLib
//
//  Created by 王保仲 on 15/1/5.
//  Copyright (c) 2015年 王保仲. All rights reserved.
//

#import "PrisonBreakCheck.h"
#import <sys/stat.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

@implementation PrisonBreakCheck

+ (BOOL)checkPrisonBreak
{
    
    BOOL jailbroken = NO;
    
    NSString *cydiaPath = @"/Applications/Cydia.app";
    
    NSString *aptPath = @"/private/var/lib/apt/";
    
    NSString *applications = @"/User/Applications/";
    
    NSString *Mobile = @"/Library/MobileSubstrate/MobileSubstrate.dylib";
    
    NSString *bash = @"/bin/bash";
    
    NSString *sshd =@"/usr/sbin/sshd";
    
    NSString *sd = @"/etc/apt";
    
    if([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        
        jailbroken = YES;
        
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        
        jailbroken = YES;
        
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:applications]){
        
        jailbroken = YES;
        
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:Mobile]){
        
        jailbroken = YES;
        
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:bash]){
        
        jailbroken = YES;
        
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:sshd]){
        
        jailbroken = YES;
        
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:sd]){
        
        jailbroken = YES;
       
    }
    
    //使用stat系列函数检测Cydia等工具
    struct stat stat_info;
    
    if (0 == stat("/Applications/Cydia.app", &stat_info)) {
        
        jailbroken = YES;
        
    }
    
    //你可以看看stat是不是出自系统库，有没有被攻击者换掉：如果结果不是 /usr/lib/system/libsystem_kernel.dylib 的话，那就100%被攻击了。
    
    //如果 libsystem_kernel.dylib 都是被攻击者替换掉的……
    
    int ret;
    
    Dl_info dylib_info;
    
    int (*func_stat)(const char *, struct stat *) = stat;
    
    if ((ret = dladdr(func_stat, &dylib_info))) {
        
        NSString *str = [NSString stringWithFormat:@"%s",dylib_info.dli_fname];
        
        if (![str isEqualToString:@"/usr/lib/system/libsystem_kernel.dylib"]) {
            
            jailbroken = YES;
            
        }
        
    }
    
    //通常情况下，会包含越狱机的输出结果会包含字符串： Library/MobileSubstrate/MobileSubstrate.dylib 。
    
    uint32_t count = _dyld_image_count();
    
    for (uint32_t i = 0 ; i < count; ++i) {
        
        NSString *name = [[NSString alloc]initWithUTF8String:_dyld_get_image_name(i)];
        
        if ([name containsString:@"Library/MobileSubstrate/MobileSubstrate.dylib"]) {
            
            jailbroken = YES;
            
        }
        
    }
    
    //未越狱设备返回结果是null，越狱设备就各有各的精彩了，尤其是老一点的iOS版本越狱环境。
    
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    
    if(env){
        
        jailbroken = YES;
        
    }
    
    return jailbroken;
}

@end
