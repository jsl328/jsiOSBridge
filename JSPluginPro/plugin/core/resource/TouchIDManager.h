//
//  TouchIDManager.h
//  YXBuilder
//
//  Created by LiYuan on 2018/1/17.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ITouchIDDelegate<NSObject>

-(void)touchIDDidFinished:(BOOL)isSuc message:(NSString *)message;

@end

@interface TouchIDManager : NSObject

+ (void)OpenTouchIDWithDelegate:(id <ITouchIDDelegate>)delegate;

@end
