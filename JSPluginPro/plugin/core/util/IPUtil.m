//
//  IPUtil.m
//  SocketClient
//
//  Created by BruceXu on 2018/4/10.
//  Copyright © 2018年 Edward. All rights reserved.
//

#import "IPUtil.h"
 

#include <ifaddrs.h>

#include <arpa/inet.h>

#include <net/if.h>



#define IOS_CELLULAR    @"pdp_ip0"

#define IOS_WIFI        @"en0"

#define IOS_VPN         @"utun0"

#define IP_ADDR_IPv4    @"ipv4"

#define IP_ADDR_IPv6    @"ipv6"


@implementation IPUtil
+(NSString*)getLocalIp{
    NSString *address = @"an error occurred when obtaining ip address";
    
    struct ifaddrs *interfaces = NULL;
    
    struct ifaddrs *temp_addr = NULL;
    
    int success = 0;
    
    
    
    success = getifaddrs(&interfaces);
    
    
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        
        while (temp_addr != NULL) {
            
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                
                // Check if interface is en0 which is the wifi connection on the iPhone
                
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    
                    // Get NSString from C String
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in  *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
            
        }
        
    }
    
    freeifaddrs(interfaces);
    return address;
}
@end
