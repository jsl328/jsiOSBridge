//
//  FoxCoreDelegate.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/19.
//  Copyright © 2017年 YUSYS. All rights reserved.
//
#import <JavaScriptCore/JavaScriptCore.h>
@protocol FoxCoreDelegate <JSExport>

JSExportAs (call, - (void)callWithType:(NSString *)type action:(NSString *)action params:(NSString *)params callback:(NSString *)callback);

@end
