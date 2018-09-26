//
//  sms.h
//  JSPluginPro
//
//  Created by jsl on 2018/9/18.
//  Copyright © 2018年 ccb. All rights reserved.
//

#import "YXPlugin.h"
#import "IDeviceDelegate.h"
#import "CallBackObject.h"
@interface sms : YXPlugin<IDeviceDelegate>
-(void)smsData:(NSString *)data;
@end
