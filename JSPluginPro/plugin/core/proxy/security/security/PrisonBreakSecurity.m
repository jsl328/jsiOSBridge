//
//  PrisonBreakSecurity.m
//  YXBuilder
//
//  Created by LiYuan on 2018/1/17.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "PrisonBreakSecurity.h"
#import "ISecurityDelegate.h"
#import "PrisonBreakCheck.h"
#import "ICallBackDelegate.h"
#import "CallBackObject.h"
@interface PrisonBreakSecurity() <ISecurityDelegate>
@end

@implementation PrisonBreakSecurity

- (void)call:(NSString*)action params: (NSDictionary*)params callback:(id<ICallBackDelegate>)callback {
    BOOL isbreak= [PrisonBreakCheck checkPrisonBreak];
    int result=isbreak;
    
    [callback run:CallBackObject.SUCCESS message:@"" data:@(result)];
}

@end
