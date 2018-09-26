//
//  LocationDevice.h
//  core
//
//  Created by guoxd on 2018/2/27.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import "YXPlugin.h"
#import <CoreLocation/CoreLocation.h>
#import "IDeviceDelegate.h"
#import <MapKit/MapKit.h>
@interface LocationDevice : YXPlugin<IDeviceDelegate,CLLocationManagerDelegate>

@end
