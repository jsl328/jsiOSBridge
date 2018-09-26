//
//  IDeviceDelegate.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//
#import "ICallBackDelegate.h"
@protocol ISecurityDelegate<NSObject>
/**
 * 安全接口调用
 *
 * param action
 * param param
 * param callback
 */
- (void)call:(NSString*)action params:(NSDictionary*)params callback:(id<ICallBackDelegate>)callback;

@end

