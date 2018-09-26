//
//  IExtension.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/12.
//  Copyright © 2017年 YUSYS. All rights reserved.
//


#import <Foundation/Foundation.h>
//#ifndef IExtension_h
//#define IExtension_h
//@class IConfigElementDelegate
#import "IConfigElementDelegate.h"
@protocol IExtensionDelegate<NSObject>
/**
 * 获取所有的配置元素集合
 *
 * return
 */
-(NSArray<id<IConfigElementDelegate>> *)getConfigElements;

/**
 * 获取扩展点属性
 *
 * param key
 * return
 */
-(NSString*) getAttribute:(NSString*) key;
@end
//#endif

