//
//  NetworkNative.m
//  YXBuilder
//
//  Created by guoxd on 2017/12/12.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "NetworkNative.h"
#import "CallBackObject.h"
#import "Reachability.h"
#import "AFNetworkReachabilityManager.h"
#include "IPAddress.h"
#import "sys/utsname.h"
#import <AdSupport/AdSupport.h>

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#define MAXADDRS    32
@implementation NetworkNative
/*
 网络判断
 */
-(id)init{
    if(self=[super init]){
        
    }
    return self;
}
-(void)call:(NSString*) action param: (NSString*) param  callback: (id<ICallBackDelegate>) callback{
   
    NSLog(@"action = %@",action);
    if ([action isEqualToString:@"getLocalIP"]) {
        
        NSDictionary *dic = [self getIPAddress];
        if (dic) {
             [callback run:CallBackObject.SUCCESS message:@"" data:dic];
        }
        else{
             [callback run:CallBackObject.ERROR message:@"获取ip失败" data:@""];
        }
    }
    else if([action isEqualToString:@"checkWifi"]){
        [NetworkNative ysy_hasNetwork:^(NSString *string) {
            NSString *netstring = [[NSString alloc]init];
            if ([string isEqualToString:@"WWAN"]) {
                netstring = @"手机自带网络";
            }
            else if ([string isEqualToString:@"WiFi"]){
                netstring = @"WiFi网络";
            }
            else if ([string isEqualToString:@"NO"]){
                netstring = @"没有网络";
            }
            else{
                netstring = @"未知网络";
            }
            [callback run:CallBackObject.SUCCESS message:@"" data:netstring];
        }];
    }
    else if ([action isEqualToString:@"getLocalMac"]){
        NSString *macStr = [self getMacAddress];
        if (macStr.length>0) {
            [callback run:CallBackObject.SUCCESS message:@"" data:macStr];
        }
        else{
            [callback run:CallBackObject.ERROR message:@"获取MAC地址失败" data:@""];
        }
    }
}
- (NSDictionary *)getIPAddress
{
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    int i;
//    NSString *deviceIP = nil;
    for (i=0; i<MAXADDRS; ++i)
    {
        static unsigned long localHost = 0x7F000001;            // 127.0.0.1
        unsigned long theAddr;
        
        theAddr = ip_addrs[i];
        
        if (theAddr == 0) break;
        if (theAddr == localHost) continue;
        
        NSLog(@"Name: %s MAC: %s IP: %s\n", if_names[i], hw_addrs[i], ip_names[i]);
        NSString *name = [NSString stringWithFormat:@"%s",if_names[i]];
        if ([name isEqualToString:@"lo0"]) {
            NSDictionary *dic = @{
                                  @"MAC":[NSString stringWithFormat:@"%s",hw_addrs[i]],
                                  @"IP":[NSString stringWithFormat:@"%s",ip_names[i]]
                                  };
            [dictionary setObject:dic forKey:name];
        }
        if([name isEqualToString:@"en0"]){
            NSDictionary *dic = @{
                                  @"MAC":[NSString stringWithFormat:@"%s",hw_addrs[i]],
                                  @"IP":[NSString stringWithFormat:@"%s",ip_names[i]]
                                  };
            [dictionary setObject:dic forKey:name];
        }
        if([name isEqualToString:@"pdp_ip0"]){
            NSDictionary *dic = @{
                                  @"MAC":[NSString stringWithFormat:@"%s",hw_addrs[i]],
                                  @"IP":[NSString stringWithFormat:@"%s",ip_names[i]]
                                  };
            [dictionary setObject:dic forKey:name];
        }
    }
    return dictionary;
}


+ (void)ysy_hasNetwork:(void(^)(NSString *string))hasNet
{
    //创建网络监听对象
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    //开始监听
    [manager startMonitoring];
    //监听改变
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                hasNet(@"Unknown");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                hasNet(@"NO");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                hasNet(@"WWAN");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                hasNet(@"WiFi");
                break;
        }
    }];
    //结束监听
    [manager stopMonitoring];
}


- (NSString *)getMacAddress {
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    
    // MAC地址带冒号
     NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr,*(ptr+1), *(ptr+2),*(ptr+3), *(ptr+4), *(ptr+5)];
    
    // MAC地址不带冒号
////    NSString *outstring = [NSString
//                           stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];
    
    free(buf);
    
    return [outstring uppercaseString];
}
@end
 
