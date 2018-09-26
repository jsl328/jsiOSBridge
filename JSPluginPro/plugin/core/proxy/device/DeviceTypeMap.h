//
//  DeviceTypeMap.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//
/**
 * Device 类型映射
 *  
 */

#import <Foundation/Foundation.h>
#import "FileMap.h"
@interface DeviceTypeMap : NSObject
/**
 * 根据类型获取设备名称
 *
 * param type
 * return
 */
-(NSString*)get:(NSString*)type;
/**
 * 加入设备类型和设备名称的映射
 *
 * param type
 * param typeName
 */
-(void) put:(NSString*) type typeName:(NSString*) typeName;
/**
 * 批量加入设备和设备名称的映射
 *
 * param map
 */
-(void)putAll:(NSDictionary<NSString*,NSString*>*)map;
/**
 * 返回所有设备类型和设备名称的映射
 *
 * return
 */
-(NSDictionary<NSString*,NSString*>*)getAll;
@end
