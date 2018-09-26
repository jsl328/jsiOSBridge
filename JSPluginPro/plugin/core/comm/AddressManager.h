//
//  AddressManager.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
@interface AddressManager : NSObject
+(NSString*)getConnectPolicy;
+(NSString*)getCommonAddressString;
+(NSArray<Address*>*)commAddressList;

/**
 * 获取当前地址
 *
 * return
 */
+(Address*) getCommAddress ;

/**
 * 改变地址索引
 */
+(int) nextCommAddressIndex ;
/**
 * 获取当前地址索引
 *
 *  return
 */
+(int) getCommAddressIndex;
/**
 * 获取当前地址索引
 *
 * return
 */
+(void) setCommAddressIndex:(int) commIndex_;

/**
 * 设置版本地址列表
 *
 * @param addressList
 */
+(void) setVersionAddressList:(NSArray<Address*>*) addressList;

/**
 * 获取地址列表
 *
 * return
 */
+(NSArray<Address*>*) getVersionAddressList ;
/**
 * 获取版本当前地址
 *
 * return
 */
+(Address*) geVersionAddress ;

/**
 * 改变版本地址索引
 */
+(int) nextVersionAddressIndex ;

/**
 * 获取当前地址索引
 *
 * return
 */
+(int) getVersionAddressIndex ;
/**
 * 设置当前version地址索引
 *
 * return
 */
+(void) setVersionAddressIndex:(int) versionIndex;

@end
