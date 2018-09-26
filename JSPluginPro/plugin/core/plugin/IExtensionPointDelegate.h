//
//  IExtensionPoint.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/12.
//  Copyright © 2017年 YUSYS. All rights reserved.
//
 
#import <Foundation/Foundation.h>
//#ifndef IExtensionPointDelegate_h
//#define IExtensionPointDelegate_h
#import "IExtensionDelegate.h"
@protocol IExtensionPointDelegate<NSObject>
/**
 * 获取所有扩展
 *
 * @return
 */
-(NSArray<id<IExtensionDelegate>>*) getExtensions;
//#endif
@end
