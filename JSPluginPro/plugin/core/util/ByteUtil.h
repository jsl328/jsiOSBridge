//
//  ByteUtil.h
//  SocketClient
//
//  Created by BruceXu on 2018/4/10.
//  Copyright © 2018年 Edward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ByteUtil : NSObject
+(Byte*) int2byteArray:(int) intVal len:(NSUInteger*)len;
+(int) byteArray2Int:(Byte*) buffer offset:(int) offset;
+(long) byteArray2Long:(Byte*) buffer offset:(int) offset;
+(Byte*) long2byteArray:(long) logVal len:(NSUInteger*)len ;
+(NSMutableDictionary<NSString*, NSString*>*) bytes2Map:(Byte*) bytes len:(NSUInteger)length;
+(NSString*) bytes2Str:(Byte*) bytes offset:(int) offset len: (int) len ;
@end
