//
//  AddressManager.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "AddressManager.h"
#import "Address.h"
#import "ConfigPreference.h"
/**
 * 地址管理器
 *
 *
 */
@interface AddressManager(){
    
}

@end
@implementation AddressManager
/**
 * 通信地址列表
 */
static NSArray<Address*>* _commAddressList;
/**
 * 通信地址索引
 */
static int _commIndex;
/**
 * 版本地址列表
 */
static NSArray<Address*>* _versionAddressList;
/**
 * 版本地址索引
 */
static int _versionIndex;
+(NSString*)getConnectPolicy{
    ConfigPreference *pref=[ConfigPreference getInstance];
    NSString *connectPolicy =[pref getString:@"communication" key:@"connectPolicy" defaultValue:@"random"] ;
    return connectPolicy;
}
+(NSString*)getCommonAddressString{
    ConfigPreference *pref=[ConfigPreference getInstance];
    NSString *s = [pref getString:@"communication" key:@"address" defaultValue:nil] ;
    return s;
}

+(NSArray<Address*>*)commAddressList{
    if(_commAddressList==nil){
        ConfigPreference *pref=[ConfigPreference getInstance];
        // 获取服务器地址
        NSString *s = [pref getString:@"communication" key:@"address" defaultValue:nil] ;
        if (s == nil) {
            return nil;
        }
        // 获取资源下载地址列表
        NSArray * addressArray =   [s componentsSeparatedByString:@";"];
        
        // 获取连接策略
        NSString *connectPolicy =[pref getString:@"communication" key:@"connectPolicy" defaultValue:@"random"] ;
       
        // 定义地址列表
        NSMutableArray<Address*>* list =  [NSMutableArray<Address*> new ];
        // 加入list
        for (int i = 0; i < addressArray.count; i++) {
            Address *address = [Address parse:(addressArray[i])];
            [list addObject:address];
        }
        if (list.count > 1 && [@"random" isEqualToString:connectPolicy.lowercaseString]) {
            list = [self getRandomArrFrome:list];
        }
        
        _commAddressList = list;
        _commIndex = 0;
    }
    return _commAddressList;
}
+(void)setCommAddressList:(NSArray<Address*>*)addressList{
    _commAddressList=addressList;
    _commIndex=0;
}


/**
 * 获取当前地址
 *
 * return
 */
+(Address*) getCommAddress {
    // 获取地址列表
    NSArray<Address*> *list =[self commAddressList];
    Address *address = list[_commIndex];
    return address;
}

/**
 * 改变地址索引
 */
+(int) nextCommAddressIndex {
   // 获取地址列表
        NSArray<Address*> *list = [self commAddressList];
        int size =(int) list.count;
        _commIndex = (_commIndex + 1) % size;
    
    return _commIndex;
}
/**
 * 获取当前地址索引
 *
 *  return
 */
+(int) getCommAddressIndex{
    return _commIndex;
}

/**
 * 获取当前地址索引
 *
 * return
 */
+(void) setCommAddressIndex:(int) commIndex_ {
    
     _commIndex = commIndex_;
    
}

/**
 * 设置版本地址列表
 *
 * @param addressList
 */
+(void) setVersionAddressList:(NSArray<Address*>*) addressList{
    
        _versionAddressList = addressList;
        _versionIndex = 0;
    
}

/**
 * 获取地址列表
 *
 * return
 */
+(NSArray<Address*>*) getVersionAddressList {
    // 如果列表为空，初始化列表
    
    
            // 初始化地址
            if (_versionAddressList == nil) {
                // 获取配置
                ConfigPreference *pref = [ConfigPreference getInstance];
                // 获取服务器地址
                NSString *s=[pref getString:@"version" key:@"address" defaultValue:nil];
                if (s != nil) {
                    // 获取资源下载地址列表
                    NSArray* addressArray = [s componentsSeparatedByString:@";"];
                    // 获取连接策略
                    NSString *connectPolicy=[pref getString:@"version" key:@"connectPolicy" defaultValue:@"random"];
                    
                    // 定义地址列表
                    NSMutableArray<Address*>*list=[NSMutableArray new];
                    // 加入list
                    for (int i = 0; i < addressArray.count; i++) {
                        Address *address = [Address parse:(addressArray[i])];
                        [list addObject:address];
                    }
                    if (list.count > 1 && [@"random" isEqualToString:connectPolicy.lowercaseString]) {
                        list = [self getRandomArrFrome:list];
                    }
                    
                    _versionAddressList = list;
                    _versionIndex = 0;
                }
            }
        
        
        //判断版本地址是否初始化成功
        if (_versionAddressList == nil) {
            //从通信地址中获取版本地址
            _versionAddressList =[self commAddressList];
            _versionIndex = 0;
        }
        
    
    return _versionAddressList;
}

/**
 * 获取版本当前地址
 *
 * return
 */
+(Address*) geVersionAddress {
    // 获取地址列表
    NSArray<Address*>* list =[self getVersionAddressList];
    Address *address = list[_versionIndex];
    return address;
}

/**
 * 改变版本地址索引
 */
 +(int) nextVersionAddressIndex {
    
        // 获取地址列表
        NSArray<Address*> *list =[self getVersionAddressList];
        int size = (int)list.count;
        _versionIndex = (_versionIndex + 1) % size;
    
       return _versionIndex;
}

/**
 * 获取当前地址索引
 *
 * return
 */
+(int) getVersionAddressIndex {
    return _versionIndex;
}

/**
 * 设置当前version地址索引
 *
 * return
 */
+(void) setVersionAddressIndex:(int) versionIndex{
    
        _versionIndex = versionIndex;
    
}



+(NSMutableArray*)getRandomArrFrome:(NSArray*)arr
{
    NSMutableArray *newArr = [NSMutableArray new];
    while (newArr.count != arr.count) {
        //生成随机数
        int x =arc4random() % arr.count;
        id obj = arr[x];
        if (![newArr containsObject:obj]) {
            [newArr addObject:obj];
        }
    }
    return newArr;
}
@end
