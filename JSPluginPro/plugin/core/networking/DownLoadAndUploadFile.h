//
//  DownLoadAndUploadFile.h
//  core
//
//  Created by guoxd on 2018/2/7.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import "YXPlugin.h"
#import "IDeviceDelegate.h"
#import "DownLoadClass.h"
#import "BreakPointDownLoadClass.h"
#import "UploadClass.h"
@interface DownLoadAndUploadFile : YXPlugin<IDeviceDelegate,DownLoadClassDelegate,BreakPointDownLoadDelegate>

@end
