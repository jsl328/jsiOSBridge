//
//  PVBase.h
//  YXBuilder
//
//  Created by LiYuan on 2018/1/9.
//  Copyright © 2018年 YUSYS. All rights reserved.
//
#import <Foundation/Foundation.h>


#ifndef PVConst_h
#define PVConst_h

static NSString *const  page_impression      =       @"page_impression";
static NSString *const  tracked_events       =       @"tracked_events";
static NSString *const  event_impression     =       @"event_impression";
static NSString *const  event_selector       =       @"event_selector";
static NSString *const  event_handler_block  =       @"event_handler_block";


static NSString *const  file_open_file             = @"file_open_file";//打开文件
static NSString *const  native_event_trig          = @"native_event_trig";//自定义事件埋点
static NSString *const  device_open_camera         = @"device_open_camera";//打开相机

#endif /* PVConst_h */
