//
//  yu_ccbM.m
//  my_ccb
//
//  Created by jsl on 2018/9/6.
//  Copyright © 2018年 jsl. All rights reserved.
//

#import "yu_ccbM.h"
#import "CallBackObject.h"

@interface yu_ccbM()
@property(nonatomic,strong) CallBackObject *handle;
@end

@implementation yu_ccbM
-(void)call:(NSString *)type action:(NSString *)action param:(NSString *)param callback:(id<ICallBackDelegate>)callback
{
    NSLog(@"1230");
    self.handle = callback;
    
    //[callback run:CallBackObject.SUCCESS message:@"1230" data:@"ss"];
}

-(void)yuM:(NSString *)yuM
{
//    [self.handle runCallback:self.handle.callback data:@(100)];
    //[self.callback runCode:100 message:@"" data:nil];
}
-(void)yux:(NSString *)yux{
    
}
-(void)yuMuti:(NSString *)yuMuti withParms:(NSString *)params withCallback:(CallBackObject *)callback{
    
}
@end
