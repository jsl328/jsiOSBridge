//
//  ObjectFactory.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/18.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "ObjectFactory.h"

#import "ScopeEnum.h"
/**
 * 对象记录
 *
 
*/
@interface ObjectRecorder:NSObject
@property Class clazz;
@property(assign) id instance;
@end
@implementation ObjectRecorder

@end


@interface ObjectFactory(){
    
}
@property(strong) NSMutableDictionary<NSString*, ObjectRecorder*>* objectRegisge ;

@end
@implementation ObjectFactory
static ObjectFactory *_instance;

-(id)init{
    if(self=[super init]){
        self.objectRegisge=[NSMutableDictionary<NSString*, ObjectRecorder*> new];
    }
    return self;
}

+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

/**
 * 获取对象
 *
 * @param className
 * @param scope
 * @return
 * @throws Exception
 */
-(id)get:(NSString*) className Scope:(NSString*) scope{
    
    //加载类
    Class clazz = NSClassFromString(className);
    //获取对象
    id obj= [self getInternal:clazz Scope:scope];
    //返回对象
    return obj;
}


/**
 * 获取对象
 *
 * @param clazz
 * @param scope
 * @return
 * @throws Exception
 */
-(id) getInternal:(Class) clazz Scope:(NSString* )scope {
    // 判断对象范围
    if ([scope isEqualToString:ScopeEnum.singleton]) {
        // 获取类名
        NSString* clazzName = NSStringFromClass(clazz);
        // 定义对象
        id obj = nil;
         // 获取对象记录
        
            ObjectRecorder* rec = self.objectRegisge[clazzName];
            // 判断类是否已经修改或对象不存在
            if (rec == nil || rec.clazz != clazz) {
                // 定义记录
                rec =  [ObjectRecorder new];
                // 保存类型
                rec.clazz = clazz;
                // 实例化
                SEL sel = NSSelectorFromString(@"new");
                rec.instance= [(id)clazz performSelector:sel];
                
                // 记录对象
                [self.objectRegisge setObject:rec forKey:clazzName];
            }
            // 返回对象
            obj = rec.instance;
       
        return obj;
    } else {
        // 实例化
        SEL sel = NSSelectorFromString(@"new");
        id obj= [(id)clazz performSelector:sel];
        return obj;
    }
}
@end
