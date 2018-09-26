//
//  FoxCoreNativeDelegate.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/19.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
@protocol FoxCoreNativeDelegate <JSExport>

JSExportAs (call, - (void)callWithAction:(NSString *)action params:(NSString *)params callback:(NSString *)callback);
@end
