//
//  IDeviceDelegate.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//
#import "ICallBackDelegate.h"
@protocol IDeviceDelegate<NSObject>
/**
 * 外设调用
 *
 * param type
 * param action
 * param param
 * param callback
 */
-(void)call:(NSString*) type action: (NSString*) action param: (NSString*) param  callback: (id<ICallBackDelegate>) callback;

 
@end

