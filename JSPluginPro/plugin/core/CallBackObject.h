//
//  CallBackObject.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/18.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICallBackDelegate.h"
@interface CallBackObject:NSObject<ICallBackDelegate//,NSSecureCoding
>
@property(nonatomic, copy) NSString *callback;
+(int) SUCCESS;
+(int) CANCEL;
+(int) ERROR;
-(id)initWithRunBlock:(void(^)(int code, NSString* message, id data))callbackBlock;
- (instancetype)initWithCallback:(NSString *)callback;
- (void)runCode:(int)code message:(NSString*)message data:(id)data;
- (void)runCode:(int)code message:(NSString*)message callbackld:(NSString *)callld data:(id)data;
@end
