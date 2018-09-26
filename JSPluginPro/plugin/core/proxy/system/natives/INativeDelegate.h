//
//  INative.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICallBackDelegate.h"
@protocol INativeDelegate<NSObject>
/**
 * 外设调用
 * param action
 * param param
 * param callback
 */
-(void)call:(NSString*) action param: (NSString*) param  callback: (id<ICallBackDelegate>) callback;

@end
