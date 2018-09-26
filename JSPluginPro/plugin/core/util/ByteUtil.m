//
//  ByteUtil.m
//  SocketClient
//
//  Created by BruceXu on 2018/4/10.
//  Copyright © 2018年 Edward. All rights reserved.
//

#import "ByteUtil.h"

@implementation ByteUtil
/**
 *
 *
 * @param intVal
 * @return
 */
+(Byte*) int2byteArray:(int) intVal len:(NSUInteger*)len {
    Byte *res=  (Byte *)malloc( sizeof(Byte )*4);
    res[0] = (Byte) (intVal >> 24 & 0xFF);
    res[1] = (Byte) (intVal >> 16 & 0xFF);
    res[2] = (Byte) (intVal >> 8 & 0xFF);
    res[3] = (Byte) (intVal & 0xFF);
    *len=4;
    return res;
}
/**
 * 长整型转化为byte数组
 *
 * @param logVal
 * @return
 */
+(Byte*) long2byteArray:(long) logVal len:(NSUInteger*)len {
     Byte *res=  (Byte *)malloc( sizeof(Byte )*8);
    res[0] = (Byte)(logVal >> 56 & 0xFF);
    res[1] = (Byte)(logVal >> 48 & 0xFF);
    res[2] = (Byte)(logVal >> 40 & 0xFF);
    res[3] = (Byte)(logVal >> 32 & 0xFF);
    res[4] = (Byte)(logVal >> 24 & 0xFF);
    res[5] = (Byte)(logVal >> 16 & 0xFF);
    res[6] = (Byte)(logVal >> 8 & 0xFF);
    res[7] = (Byte)(logVal & 0xFF);
    *len=8;
    return res;
}

/**
 * byte*转int
 *
 * @param buffer
 * @param offset
 * @return
 */
+(int) byteArray2Int:(Byte*) buffer offset:(int) offset {
    int n = 0;
    n |= (buffer[offset] << 24) & 0xFF000000;
    n |= (buffer[offset + 1] << 16) & 0xFF0000;
    n |= (buffer[offset + 2] << 8) & 0xFF00;
    n |= buffer[offset + 3] & 0xFF;
    return n;
}
+(long) byteArray2Long:(Byte*) buffer offset:(int) offset{
    
    long n = 0;
    
    long m=0;
    m=buffer[offset];
    m&=0xFF;
    m<<=56;
    n|=m;
    
    m=buffer[offset+1];
    m&=0xFF;
    m<<=48;
    n|=m;
    
    m=buffer[offset+2];
    m&=0xFF;
    m<<=40;
    n|=m;
    
    m=buffer[offset+3];
    m&=0xFF;
    m<<=32;
    n|=m;
    
    m=buffer[offset+4];
    m&=0xFF;
    m<<=24;
    n|=m;
    
    m=buffer[offset+5];
    m&=0xFF;
    m<<=16;
    n|=m;
    
    m=buffer[offset+6];
    m&=0xFF;
    m<<=8;
    n|=m;
    
    m=buffer[offset+7];
    m&=0xFF;
    n|=m;
    
    return n;
}

/**
 * bytes to NSDictionary
 *
 * @param bytes
 * @return
 */
+(NSMutableDictionary<NSString*, NSString*>*) bytes2Map:(Byte*) bytes len:(NSUInteger)length {
    
    NSMutableDictionary<NSString*, NSString*>* map = [self bytes2Map:bytes totalLength:(int)length offset:0 length:(int)length];
    return map;
}
/**
 * bytes to dictionary
 *
 * @param bytes
 * @param offset
 * @param length
 * @return
 */
+(NSMutableDictionary<NSString*, NSString*>*) bytes2Map:(Byte*) bytes totalLength:(int)totalLength offset: (int) offset length:(int)length
 {
    
    if (offset == -1) {
        offset = 0;
    }
    int limit = 0;
    if (length == -1) {
        limit = totalLength;
    } else {
        limit = offset + length;
    }
    
    //
    NSMutableDictionary<NSString*, NSString*>* params = [NSMutableDictionary<NSString*, NSString*> new];
    
    while (offset < limit) {
        
        int len = [ByteUtil byteArray2Int:bytes offset:offset];
        offset += 4;
        //securityPolicy
        NSString* key = [ByteUtil bytes2Str:bytes offset:offset len: len];
        //
        offset += len;
        len = [ByteUtil byteArray2Int:bytes offset:offset];
        offset += 4;
        NSString* value =  [ByteUtil bytes2Str:bytes offset:offset len: len];
        offset += len;
        //
        [params setObject:value forKey:key];
        
    }
    return params;
}
/**
 * byte* 转string
 *
 * @param bytes
 * @param offset
 * @param len
 * @return
 */
+(NSString*) bytes2Str:(Byte*) bytes offset:(int) offset len: (int) len {
    if (bytes == nil) {
        return nil;
    }
    Byte *by=(Byte*)malloc(sizeof(Byte)*len);
    for (NSInteger i = offset; i < offset+len; i++){
        
        by[i-offset] = bytes[i];
        
    }
   
    NSData *data= [NSData dataWithBytes:by length:len];
    free(by);
    NSString *tempStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return tempStr;
}
@end
