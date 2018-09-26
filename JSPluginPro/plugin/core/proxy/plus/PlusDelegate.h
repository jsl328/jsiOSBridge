//
//  PlusDelegate.h
//  core
//
//  Created by guoxd on 2018/4/24.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICallBackDelegate.h"
@protocol PlusDelegate <NSObject>
/**
 * 外设调用
 * param action
 * param param
 * param callback
 */
-(void)call:(NSString*) action param: (NSString*) param  callback: (id<ICallBackDelegate>) callback;

@end
