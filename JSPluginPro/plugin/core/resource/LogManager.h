//
//  LogManager.h
//  YXBuilder
//
//  Created by LiYuan on 2017/12/29.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 REALTIME只在“集成测试”设备的DEBUG模式下有效，其它情况下的REALTIME会改为使用BATCH策略。
 */
typedef enum {
    REALTIME = 0,       //实时发送              (只在“集成测试”设备的DEBUG模式下有效)
    BATCH = 1,          //启动发送
    SEND_INTERVAL = 6,  //最小间隔发送           ([90-86400]s, default 90s)
} ReportPolicy;

@interface LogManager : NSObject

@property (copy, nonatomic) NSString *printAbsolutePath;

@property (copy, nonatomic) NSString *crashAbsolutePath;

+ (instancetype)getIntance;

- (void)startLogWithCache:(BOOL)isCache;

/** 设置是否对日志信息进行加密, 默认NO(不加密).
 @param value 设置为YES, SDK 会将日志信息做加密处理
 */
- (void)setEncryptEnabled:(BOOL)value;

/** 当reportPolicy == SEND_INTERVAL 时设定log发送间隔
 @param second 单位为秒,最小90秒,最大86400秒(24hour).
 */
- (void)setLogPolicy:(ReportPolicy)policy SendInterval:(double)second;

@end
