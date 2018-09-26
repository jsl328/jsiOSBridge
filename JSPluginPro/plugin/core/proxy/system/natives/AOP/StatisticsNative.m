//
//  StatisticsNative.m
//  YXBuilder
//
//  Created by LiYuan on 2018/1/16.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "StatisticsNative.h"

@implementation StatisticsNative

-(void)call:(NSString*) action param: (NSString*) param  callback: (id<ICallBackDelegate>) callback{
    if([action isEqualToString:@"callEventStart"]){
        [self callEventStart:param callback:callback];
    }
    else if([action isEqualToString:@"callEventEnd"]){
        [self callEventEnd:param callback:callback];
    }
    else if([action isEqualToString:@"callEventTrig"]){
        [self callEventTrig:param callback:callback];
    }
}

-(void)callEventStart:(NSString*)param callback: (id<ICallBackDelegate>)callback{
    
    [callback run:0 message:@"" data:@{}];
}

-(void)callEventEnd:(NSString*)param callback: (id<ICallBackDelegate>) callback{
    
    [callback run:0 message:@"" data:@{}];
}

-(void)callEventTrig:(NSString*)param callback: (id<ICallBackDelegate>) callback{
    
    [callback run:0 message:@"" data:@{}];
}

@end
