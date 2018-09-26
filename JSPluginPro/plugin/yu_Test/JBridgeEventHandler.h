//
//  JSEventHandler.h
//  JSPluginPro
//
//  Created by jsl on 2018/9/17.
//  Copyright © 2018年 ccb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallBackObject.h"
#import "IDeviceDelegate.h"

@interface JBridgeEventHandler : NSObject
+ (instancetype)shareInstance;
- (void)interfaceDeviceClass:(id<IDeviceDelegate>)device withAction:(NSString *)action params:(id)params callback:(CallBackObject*)callback;
@end
