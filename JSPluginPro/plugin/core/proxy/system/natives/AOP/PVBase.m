//
//  PVBase.m
//  YXBuilder
//
//  Created by LiYuan on 2018/1/9.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "PVBase.h"
#import "PVConst.h"
#import "Aspects.h"
#import "YXPlugin.h"
@implementation PVBase

+ (NSDictionary *)statisticsPVBase {
    return @{
             @"UIViewController" : @{
                     page_impression: @"page imp - main page",
                     tracked_events : @[
                         @{
                             event_impression: @"viewWillAppear",
                             event_selector: @"viewWillAppear:",
                             event_handler_block: ^( id<AspectInfo> aspects ) {
                                 FOXLog(@"%@ viewWillAppear", aspects.instance);
                             }
                             },
                         @{
                             event_impression: @"viewDidDisappear",
                             event_selector: @"viewDidDisappear:",
                             event_handler_block: ^( id<AspectInfo> aspects ) {
                                 FOXLog(@"%@ viewDidDisappear %@", aspects.instance, aspects.arguments);
                             }
                             }
                         ]
                     },
             
             @"StatisticsNative" : @{
                     page_impression: @"page imp - html page",
                     tracked_events : @[
                             @{
                                 event_impression: @"viewWillAppear",
                                 event_selector: @"callEventStart:callback:",
                                 event_handler_block: ^( id<AspectInfo> aspects ) {
                                     FOXLog(@"%@ viewWillAppear %@", aspects.instance, aspects.arguments);
                                 }
                                 },
                             @{
                                 event_impression: @"viewDidDisappear",
                                 event_selector: @"callEventEnd:callback:",
                                 event_handler_block: ^( id<AspectInfo> aspects ) {
                                     FOXLog(@"%@ viewDidDisappear %@", aspects.instance, aspects.arguments);
                                 }
                                 }
                             ]
                     }
             };
}

@end
