//
//  Trigger.m
//  IOSNetWorkDemo
//
//  Created by BruceXu on 2018/4/17.
//  Copyright © 2018年 孙伟伟. All rights reserved.
//

#import "Trigger.h"
@interface Trigger(){
 
    
   
}

@property(strong)NSData* key;

@property  int index;






@end
@implementation Trigger

/**
 * HTTP协议头分割符
 */
+(NSData*) HEADER_SPLITOR {
    Byte byte[]={13, 10, 13, 10};
   return  [NSData dataWithBytes:byte length:4];
    
};

/**
 * 分割符
 */
+(NSData*) SPLITOR {
    Byte byte[]={13, 10};
    return  [NSData dataWithBytes:byte length:2];
};

-(id)init{
    if(self=[super init]){
        _index=0;
   }
    return self;
}
/**
 * 构造函数
 *
 * @param key
 */
-(id)init:(NSData*) key_ {
    if(self=[super init]){
        self.key = [key_ copy];
        self.index=0;
        
    }
    return self;
}
/**
 * 获取key
 * @return
 */
-(NSData*) getKey{
    return self.key;
}

/**
 * 获取key的长度
 * @return
 */
-(int) getKeyLength{
    return (int)self.key.length;
}

/**
 * 重置
 */
-(void) reset{
    _index=0;
}

/**
 * 触发
 *
 * @param data
 * @return
 */
-(int) trigger:(NSData*) data {
    
    int pos=(int)[self trigger:data offset:0 length:(int)data.length];
    return pos;
}

/**
 * 触发
 *
 * @param data
 * @param offset
 * @param length
 * @return
 */
-(int) trigger:(NSData*) data offset:(int) offset length: (int) length {
    //设置长度
    if(length==-1){
        length=(int)data.length;
    }
    
    //设置初始位置
    int i = offset;
    int cursor = _index;
    Byte *bKey=(Byte*)[_key bytes];
    Byte *bData=(Byte*)[data bytes];
    for (; i < length && cursor < _key.length; i++, cursor++) {
        // 是否匹配]
        
        if (bKey[cursor]  != bData[i]) {//13 10
            cursor = 0;
            continue;
        }
        else{
            
        }
    }
    
    // 查找到匹配记录
    if (cursor == _key.length) {
        // 返回匹配的索引
        int n = (i - 1);
        return n;
    } else if (cursor > 0 && i == data.length) {
        // 续点查找
        _index = cursor;
    } else {
        _index = 0;
    }
    return -1;
}











@end
