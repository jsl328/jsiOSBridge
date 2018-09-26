//
//  TouchIDSecurity.m
//  YXBuilder
//
//  Created by LiYuan on 2018/1/17.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "TouchIDSecurity.h"
#import "TouchIDManager.h"
#import "ISecurityDelegate.h"

@interface TouchIDSecurity() <ITouchIDDelegate, ISecurityDelegate> {
    id<ICallBackDelegate> _callback;
}

@end

@implementation TouchIDSecurity

- (void)call:(NSString*)action params:(NSDictionary*)params callback:(id<ICallBackDelegate>)callback {
    _callback = callback;
    [TouchIDManager OpenTouchIDWithDelegate:self];
   
}

- (void)touchIDDidFinished:(BOOL)isSuc message:(NSString *)message {
    if(message==nil)message=@"";
    [_callback run:!isSuc message:message data:@{}];
}

@end
