//
//  pluginSSLNetWorking.h
//  HBuilder-Hello
//
//  Created by guoxd on 2016/11/1.
//  Copyright © 2016年 guoxd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXPlugin.h"
#import "IDeviceDelegate.h"
@interface pluginSSLNetWorking : YXPlugin<IDeviceDelegate>
-(void)netWorkingSSLRequest:(NSDictionary *)paramsDic;
@end
