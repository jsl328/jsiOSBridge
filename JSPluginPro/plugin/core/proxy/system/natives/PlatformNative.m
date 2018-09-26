//
//  PlatformNative.m
//  YXBuilder
//
//  Created by guoxd on 2017/12/12.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "PlatformNative.h"
#import "CallBackObject.h"
#import "AppDelegate.h"
@interface PlatformNative()
@property (nonatomic,strong) CallBackObject *callbackID;
@end
@implementation PlatformNative

-(void)call:(NSString*) action param: (NSString*) param  callback: (id<ICallBackDelegate>) callback{
    NSLog(@"action = %@",action);
    self.callbackID = callback;
    if ([action isEqualToString:@"getVersion"]) {
        [self getVersion];
    }
    else if ([action isEqualToString:@"getAppVersionName"]){
        [self getAppVersionName];
    }
    else if([action isEqualToString:@"getAppVersionCode"]){
        [self getAppVersionCode];
    }
//    else if ([action isEqualToString:@"shutdown"]){
//        [self shutdown];
//    }
}
//获取版本号
-(void)getVersion
{
   NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];//获取项目版本号
    if (version.length >0) {
        [self.callbackID run:CallBackObject.SUCCESS message:@"" data:version];
    }
    else{
        [self.callbackID run:CallBackObject.ERROR message:@"获取版本号失败" data:@""];
    }
}
//关闭平台
-(void)shutdown{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = app.window;

    [UIView animateWithDuration:1.0f animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}
//获得APP的code
-(void)getAppVersionCode{
    //获得build号:
   NSString *appCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if (appCode.length >0) {
        [self.callbackID run:CallBackObject.SUCCESS message:@"" data:appCode];
    }
    else{
        [self.callbackID run:CallBackObject.ERROR message:@"获取build号失败" data:@""];
    }
}
//获得APP名
-(void)getAppVersionName{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    if (app_Name.length >0) {
        [self.callbackID run:CallBackObject.SUCCESS message:@"" data:app_Name];
    }
    else{
        [self.callbackID run:CallBackObject.ERROR message:@"获取APP名失败" data:@""];
    }
}
@end
