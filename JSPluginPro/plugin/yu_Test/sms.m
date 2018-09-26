//
//  sms.m
//  JSPluginPro
//
//  Created by jsl on 2018/9/18.
//  Copyright © 2018年 ccb. All rights reserved.
//

#import "sms.h"
#import "CallBackObject.h"

@interface sms()
@property(nonatomic,strong) CallBackObject *handle;
@end
@implementation sms
-(void)call:(NSString *)type action:(NSString *)action param:(NSString *)param callback:(id<ICallBackDelegate>)callback
{
    self.handle = callback;
//    NSDictionary *sd  =@{@"code":@"100",@"msg":@"ok",@"data":@(100)};
    //[self.handle runCallback:self.handle.callback data:sd];
    NSString *data =@"qwerioqruoiqweroiuewiu";
    [self.handle runCode:[CallBackObject SUCCESS] message:@"ok" callbackld:self.handle.callback data:data];
}
-(void)smsData:(NSString *)data{
    
}
@end
