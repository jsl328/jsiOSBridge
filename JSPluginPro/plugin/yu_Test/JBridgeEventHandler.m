//
//  JSEventHandler.m
//  JSPluginPro
//
//  Created by jsl on 2018/9/17.
//  Copyright © 2018年 ccb. All rights reserved.
//

#import "JBridgeEventHandler.h"
#import "IDeviceDelegate.h"
#import "CallBackObject.h"
//#import "NSObject+performSelector.h"

@implementation JBridgeEventHandler
static JBridgeEventHandler * _handler= nil;
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handler =[JBridgeEventHandler new];
    });
    return _handler;
}

//class runtime selector
- (void)interfaceDeviceClass:(id<IDeviceDelegate>)device withAction:(NSString *)action params:(id)params callback:(CallBackObject*)callBack
{
    NSString *methodName=nil;
    if (params) {
        //拼接方法
        methodName = [NSString stringWithFormat:@"%@",action];
        if (callBack) {
            SEL selector =NSSelectorFromString(methodName);
            NSArray *paramArray =@[params,callBack];
            if ([device respondsToSelector:selector]) {
                [self yuClass:device performSelector:selector withObjects:paramArray];
            }
        }else{
            SEL selector =NSSelectorFromString(methodName);
            NSArray *paramArray =@[params];
            if ([device respondsToSelector:selector]) {
                [self yuClass:device performSelector:selector withObjects:paramArray];
            }
        }
    }else{
        if (callBack) {
            methodName = [NSString stringWithFormat:@"%@:",methodName];
            SEL selector =NSSelectorFromString(methodName);
            NSArray *paramArray =@[callBack];
            if ([device respondsToSelector:selector]) {
                [self yuClass:device performSelector:selector withObjects:paramArray];
            }
        }else{
            SEL selector =NSSelectorFromString(methodName);
            if ([device respondsToSelector:selector]) {
                [self yuClass:device performSelector:selector withObjects:nil];
            }
        }
    }
}

//获取方法的签名
- (id)yuClass:(id<IDeviceDelegate>)className performSelector:(SEL)aSelector withObjects:(NSArray *)objects{
    
    //1、创建签名对象
    NSMethodSignature *signature =[[className class] instanceMethodSignatureForSelector:aSelector];
    //2、判断传入的方法是否存在
    if (!signature) {
        //传入的方法不存在 就抛异常
        NSString*info = [NSString stringWithFormat:@"-[%@ %@]:unrecognized selector sent to instance",[className class],NSStringFromSelector(aSelector)];
        @throw [[NSException alloc] initWithName:@"方法没有" reason:info userInfo:nil];
        return nil;
    }
    //3、创建NSInvocation对象
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    //4、保存方法所属的对象
    [invocation setTarget:className]; // index 0
    [invocation setSelector:aSelector];// index 1
    
    //5、设置参数
    NSInteger arguments = signature.numberOfArguments -2;
    NSUInteger objectsCount = objects.count;
    NSInteger count = MIN(arguments, objectsCount);
    //分发参数
    [self setInv:invocation andArgs:objects argsCount:count];
    
    //6、调用NSinvocation对象
    [invocation invoke];
    
    //7、获取返回值
    id res = nil;
    if (signature.methodReturnLength ==0) return nil;
    //getReturnValue获取返回值
    [invocation getReturnValue:&res];
    return res;
}

- (void)setInv:(NSInvocation *)inv andArgs:(NSArray *)args argsCount:(NSUInteger)count{
    for (int i = 0; i<count; i++) {
        NSObject*obj = args[i];
        //处理参数是NULL类型的情况
        if ([obj isKindOfClass:[NSNull class]]) {
            obj = nil;
        }
        [inv setArgument:&obj atIndex:i+2];
    }
}

#pragma mark - 传递一个值的block
- (void)performSelectorWithTheBlock:(void(^)(int value))block {
    // 获取block
//    NSMethodSignature *signature = aspect_blockMethodSignature(block,NULL);
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
//    [invocation setTarget:block];
//    // 此处待考虑
//    int a=2;
//    [invocation setArgument:&a atIndex:1];
//    [invocation invoke];
}

- (nullable id)performSelectorWithTheArgs:(SEL)sel, ...{
    NSMethodSignature * sig = [self methodSignatureForSelector:sel];
    if (!sig) { [self doesNotRecognizeSelector:sel]; return nil; }
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    if (!inv) { [self doesNotRecognizeSelector:sel]; return nil; }
    // 设置消息接收者
    [inv setTarget:self];   // index = 0
    // 设置调用的方法
    [inv setSelector:sel];  // index = 1
    // 获取参数
    va_list args;
    va_start(args, sel);
    [self setInv:inv sigT:sig andArgs:args];
    va_end(args);
    [inv invoke];
    // 获取返回值
    id res = nil;
    if (sig.methodReturnLength ==0) return nil;
    //getReturnValue获取返回值
    [inv getReturnValue:&res];
    return res;
}

- (void)setInv:(NSInvocation *)inv sigT:(NSMethodSignature*)sig andArgs:(va_list)args{
    NSUInteger count = [sig numberOfArguments];
    for (int index = 2; index < count; index++) {
        id tmpStr = va_arg(args, id);
        if([tmpStr isKindOfClass:[NSNull class]]) tmpStr = nil;
        [inv setArgument:&tmpStr atIndex:index];
    }
}

@end
