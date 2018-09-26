//
//  Mutex.m
//  YXBuilder
//
//  Created by BruceXu on 2018/1/15.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "Mutex.h"
/**
 * 互斥控制
 */

@interface Mutex(){
    /**
     * 状态
     */
    BOOL _authorization;//false
    /**
     * 最大锁定次数
     */
    int _maxLockTime ;//= -1;
    
    /**
     * 锁定次数
     */
     int _lockTime;

}
@end
@implementation Mutex

-(id)init{
    if(self=[super init]){
        _authorization=NO;
        _lockTime = _maxLockTime =-1;
    }
    return self;
}

-(id)init:(int)maxLockTime{
    if(self=[super init]){
        _authorization=NO;
        _lockTime = _maxLockTime =maxLockTime;
    }
    return self;
}




/**
 * 尝试获取授权
 *
 * return
 */
 -(BOOL)obtain {
    //判断是否已经授权
    if (!_authorization) {
        //设置授权授予
        _authorization = true;
        //返回授权通过
        return true;
    }
    
    //判断是否有锁定次数限制
    if (_maxLockTime != -1) {
        if (_lockTime <= 0) {
            _lockTime = _maxLockTime;
            return true;
        }
        _lockTime--;
    }
    
    //返回授权不通过
    return false;
}

/**
 * 释放授权
 */
-(void)doRelease {
    //设置释放授权
    _authorization = false;
    //重置lock次数
    if (_maxLockTime != -1) {
        _lockTime = _maxLockTime;
    }
}
@end
