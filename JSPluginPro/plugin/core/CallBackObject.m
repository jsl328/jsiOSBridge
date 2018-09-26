//
//  CallBackObject.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/18.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "CallBackObject.h"
#import "Platform.h"
#import <JavaScriptCore/JavaScriptCore.h>

typedef   void(^CallBackBlock)(int code, NSString* message, id data);
@interface CallBackObject()

@property(copy) CallBackBlock  runBlock;

@end
@implementation CallBackObject

+(int) SUCCESS{
    return 0;
}

+(int) CANCEL{
    return 1;
}

+(int) ERROR{
    return 2;
}

-(id)init{
    if(self=[super init]){
        
    }
    return self;
}

- (id)initWithRunBlock:(void(^)(int code, NSString* message, id data))callbackBlock{
    if(self=[super init]){
        self.runBlock = callbackBlock;
    }
    return self;
}

-(void) run:(int) code message: (NSString*) message data:(id) data {
    //id ddd=self.runBlock;
    self.runBlock(code,message,data);
}


- (instancetype)initWithCallback:(NSString *)callback {
    if(self = [super init]){
        self.callback = callback;
    }
    return self;
}

- (void)runCode:(int)code message:(NSString*)message data:(id)data {
    [[Platform getInstance].webViewBridge executeJs:self.callback params:@[@(code), message, data == nil ? @"" : data]];
}
- (void)runCode:(int)code message:(NSString*)message callbackld:(NSString *)callld data:(id)data{
    [[Platform getInstance].webViewBridge executeFromNativeCode:code msg:message callbackld:callld params:data];
}
@end
