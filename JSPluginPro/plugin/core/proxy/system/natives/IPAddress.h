//
//  IPAddress.h
//  core
//
//  Created by guoxd on 2018/3/13.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#ifndef IPAddress_h
#define IPAddress_h

#include <stdio.h>

#endif /* IPAddress_h */
#define MAXADDRS    32

extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];

// Function prototypes

void InitAddresses();
void FreeAddresses();
void GetIPAddresses();
void GetHWAddresses();
