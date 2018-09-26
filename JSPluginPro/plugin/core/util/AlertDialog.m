//
//  AlertDialog.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/21.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "AlertDialog.h"
#import <UIKit/UIKit.h>
#import "Platform.h"
@implementation AlertDialog
static dispatch_semaphore_t sema;
+(int)show:(NSString*)title message:(NSString*)message buttonTexts:(NSArray<NSString*>*)buttonTexts
buttonValues:(NSArray*)buttonValues{
  
    //获取平台对象
   // Platform *platform = [Platform getInstance];
    sema = dispatch_semaphore_create(0);
    //结果篮子
    __block  int basket = -1;
    NSMutableArray *actionArr=[NSMutableArray new];
    
    for (int i = 0; i < buttonTexts.count; i++) {
        
            
        [actionArr addObject:[UIAlertAction actionWithTitle:buttonTexts[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                basket=[(buttonValues[i]) intValue];
            
                dispatch_semaphore_signal(sema);
         }]];
            
      
    }
    
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    for(id action in actionArr)
    {
         [alter addAction:action];
    }
    
   //获取UI Executor
    id<UIEventExecutorDelegate> uiEventExecutor = [[Platform getInstance]  uiEventExecutor];
    
    if ([uiEventExecutor isUIThread]) {
        [[Platform getInstance].rootViewController presentViewController:alter animated:YES completion:^{
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Platform getInstance].rootViewController presentViewController:alter animated:YES completion:^{
                
            }];
        });
        
    }
    
    if (basket == -1) {
        
         dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    return basket;
    
   
    
    
    return 0;
}
@end
