//
//  IConfigElement.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/12.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

//#ifndef IConfigElement_h
//#define IConfigElement_h
#import <Foundation/Foundation.h>
@protocol IConfigElementDelegate<NSObject>

/**
 * 获取扩展点配置名称
 *
 *
 */
 -(NSString*) getName;

/**
 * 获取扩展点属性
 *
 *  param key
 *  return
 */
-(NSString*) getAttribute:(NSString*) key;

/**
 * 获取扩展点的文本
 *
 *  return
 */
-(NSString*) getText;

/**
 * 获取指定名称的扩展点配置
 *
 *  param name
 *  return
 */
-(NSArray<id<IConfigElementDelegate>>*) getChildren:(NSString*) name;


@end


//#endif /* IConfigElement_h */
