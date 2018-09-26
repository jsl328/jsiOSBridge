//
//  Statistics.m
//  YXBuilder
//
//  Created by LiYuan on 2018/1/9.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "StatisticsManager.h"
#import "PVBase.h"
#import "PABase.h"
#import "Aspects.h"
#import "KeychainIDFA.h"
#import "YXPlugin.h"
@implementation StatisticsManager

+ (void)setupStatistics {
    
    [self setupBasicMessage];
    
    [self setupWithConfiguration:[PVBase statisticsPVBase]];
    
    [self setupWithConfiguration:[PABase statisticsPABase]];
    
}

+ (void)setupBasicMessage {
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *IDFA = [KeychainIDFA IDFA];
    
    FOXLog(@"launchTime version %@ IDFA %@", version, IDFA);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appTerminate) name:UIApplicationWillTerminateNotification object:nil];
    
}

+ (void)appTerminate {
    FOXLog(@"terminateTime");
}


+ (void)setupWithConfiguration:(NSDictionary *)configs{
    
    for (NSString *className in configs) {
        Class class = NSClassFromString(className);
        for (NSDictionary *event in configs[className][tracked_events]) {
            SEL selector = NSSelectorFromString(event[event_selector]);
            id block = event[event_handler_block];
            [class aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:block  error:NULL];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

@end
