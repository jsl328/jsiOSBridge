//
//  yu_ccbM.h
//  my_ccb
//
//  Created by jsl on 2018/9/6.
//  Copyright © 2018年 jsl. All rights reserved.
//

#import "YXPlugin.h"
#import "IDeviceDelegate.h"
#import "CallBackObject.h"
@interface yu_ccbM : YXPlugin<IDeviceDelegate>
-(void)yuM:(NSString *)yuM;
-(void)yux:(NSString *)yux;
-(void)yuMuti:(NSString *)yuMuti withParms:(NSString *)params withCallback:(CallBackObject *)callback;
@end
