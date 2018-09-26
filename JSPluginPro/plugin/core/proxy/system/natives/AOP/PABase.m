//
//  PABase.m
//  YXBuilder
//
//  Created by LiYuan on 2018/1/9.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "PABase.h"
#import "PVConst.h"
#import "Aspects.h"
#import "YXPlugin.h"
@implementation PABase

+ (NSDictionary *)statisticsPABase {
    
    return @{
             @"FileProxy" : @{
              tracked_events : @[
                      @{
                          event_impression: file_open_file,
                          event_selector: @"openFile:callback:",
                          event_handler_block: ^( id<AspectInfo> aspects ) {
                              FOXLog(@"%@ %@ %@", aspects.instance, file_open_file, aspects.arguments);
                          }
                          }
                      ]
              },
             @"StatisticsNative" : @{
                     tracked_events : @[
                             @{
                                 event_impression: native_event_trig,
                                 event_selector: @"callEventTrig:callback:",
                                 event_handler_block: ^( id<AspectInfo> aspects ) {
                                     FOXLog(@"%@ %@ %@", aspects.instance, native_event_trig, aspects.arguments);
                                 }
                                 }
                             ]
                     }
      };
}

@end
