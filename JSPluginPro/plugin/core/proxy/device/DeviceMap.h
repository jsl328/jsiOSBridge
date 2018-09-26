//
//  DeviceMap.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceMap : NSObject
/**
 * 根据类型获取设备ID
 *
 * param type
 * return
 */
-(NSString*) get:(NSString*) type;
/**
 * 加入设备类型和设备ID的映射
 *
 * param type
 * param deviceId
 */
-(void) put:(NSString*) type deviceId: (NSString*) deviceId ;

/**
 * 批量加入设备和设备ID的映射
 *
 * param map
 */
-(void) putAll:(NSDictionary<NSString*, NSString*>*) map ;
/**
 * 返回所有设备类型和设备ID的映射
 *
 * @return
 */
-(NSDictionary<NSString*, NSString*>*) getAll ;
@end
