//
//  AlertDialog.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/21.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertDialog : NSObject
+(int)show:(NSString*)title message:(NSString*)message buttonTexts:(NSArray<NSString*>*)buttonTexts
buttonValues:(NSArray*)buttonValues;
@end
