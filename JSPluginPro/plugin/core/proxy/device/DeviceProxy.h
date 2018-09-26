//
//  DeviceProxy.h
//  YXBuilder
//
//  Created by LiYuan on 2017/12/11.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "YXPlugin.h"
#import "IproxyDelegate.h"
@interface DeviceProxy : YXPlugin<IproxyDelegate>
+(NSString*)DEVICE_POINT;
@end
