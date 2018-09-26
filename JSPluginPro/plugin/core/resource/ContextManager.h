//
//  ContextManager.h
//  YXBuilder
//
//  Created by LiYuan on 2017/12/26.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "YXPlugin.h"

@interface ContextManager : YXPlugin

+ (JSContext *)getContext;
+(void)registerGlobalJSBridgeMethod;
@end
