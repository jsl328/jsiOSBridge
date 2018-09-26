//
//  LocationNative.h
//  YXBuilder
//
//  Created by guoxd on 2017/12/12.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXPlugin.h"
#import "INativeDelegate.h"
#import <CoreLocation/CoreLocation.h>
@interface LocationNative : YXPlugin<INativeDelegate,CLLocationManagerDelegate>

@end
