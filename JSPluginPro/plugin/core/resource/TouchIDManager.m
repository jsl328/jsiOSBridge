//
//  TouchIDManager.m
//  YXBuilder
//
//  Created by LiYuan on 2018/1/17.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "TouchIDManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation TouchIDManager

+ (void)OpenTouchIDWithDelegate:(id <ITouchIDDelegate>)delegate
{
    
    LAContext *lacontext = [[LAContext alloc]init];
    NSError *error = nil;
    lacontext.localizedFallbackTitle = @"";
    
    if ([delegate respondsToSelector:@selector(touchIDDidFinished:message:)]) {
        if([lacontext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error])
        {
            [lacontext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请验证已有的指纹" reply:^(BOOL success,NSError *error){//指纹不匹配
                if (success) {
                    // 成功
                    [delegate touchIDDidFinished:YES message:nil];
                } else {
                    
                    switch (error.code) {
                        case LAErrorUserCancel:
                        {// 用户取消
                            [delegate touchIDDidFinished:NO message:@"用户取消"];
                            break;
                        }
                            
                        case LAErrorUserFallback:
                        {// 输入密码
                            break;
                        }
                            
                        case LAErrorAuthenticationFailed:{
                            // 指纹校验失败
                            break;
                        }
                            
                        case LAErrorTouchIDLockout:{
                            NSError *error = nil;
                            if([lacontext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error])
                            {
                                [lacontext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"请验证已有的指纹" reply:^(BOOL success, NSError * _Nullable error) {
                                    if (success) {
                                        [self OpenTouchIDWithDelegate:delegate];
                                    } else {
                                        if (error.code == LAErrorUserCancel || LAErrorSystemCancel || LAErrorAppCancel) {
                                            // 用户取消 ???
                                                                        [delegate touchIDDidFinished:NO message:@"用户取消"];
                                        } else {
                                            
                                        }
                                        
                                    }
                                }];
                            }
                            break;
                            
                            
                        }
                            
                        case LAErrorSystemCancel:{// 应用进入后台时，授权失败 电话/点击后台 ???
                            [delegate touchIDDidFinished:NO message:@"应用进入后台"];
                            
                            break;
                            
                        }
                            
                        case LAErrorAppCancel:{// 在验证中被其他app中断 ???
                            [delegate touchIDDidFinished:NO message:@"被其他app中断"];
                            break;
                            
                        }
                            
                        default:
                        {//LAErrorInvalidContext LAContext对象被释放掉了
                            
                            break;
                        }
                    }
                    
                }
            }];
            
            
        } else {
            
            switch (error.code) {
                    
                case LAErrorTouchIDNotAvailable:
                {
                    //                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户设备不支持TouchID" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
                    //                    [alert show];
                    //
                    //
                    //                });
                    
                    [delegate touchIDDidFinished:NO message:@"用户设备不支持TouchID"];
                    break;
                }
                    
                case LAErrorTouchIDNotEnrolled:
                {// 没有打开指纹使用
                    //                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户未设置TouchID" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
                    //                    [alert show];
                    //
                    //
                    //                });
                    
                    [delegate touchIDDidFinished:NO message:@"用户未设置TouchID"];
                    break;
                }
                    
                case LAErrorPasscodeNotSet:
                {
                    //                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户未设置TouchID" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
                    //                    [alert show];
                    //
                    //
                    //                });
                    
                    [delegate touchIDDidFinished:NO message:@"用户未设置TouchID"];
                    break;
                }
                    
                case LAErrorTouchIDLockout:{
                    
                    //                NSError *error = nil;
                    //                if([weakSelf.lacontext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error])
                    //                {
                    //                    [weakSelf.lacontext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"请验证已有的指纹" reply:^(BOOL success, NSError * _Nullable error) {
                    //                        if (success) {
                    //                            [self OpenTouchID];
                    //                        } else {
                    //                            if (error.code == LAErrorUserCancel) {
                    //                                // 用户取消
                    //                            } else {
                    //
                    //                            }
                    //
                    //                        }
                    //                    }];
                    //                }
                    
                    [delegate touchIDDidFinished:NO message:@"用户输错5次TouchID"];
                    break;
                }
                    
                default:
                {//LAErrorInvalidContext LAContext对象被释放掉了
                    
                    [delegate touchIDDidFinished:NO message:@"TouchID不可用"];
                    
                    break;
                }
            }
        }
    }
    
}

@end
