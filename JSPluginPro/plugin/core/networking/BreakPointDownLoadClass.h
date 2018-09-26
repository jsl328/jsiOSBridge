//
//  BreakPointDownLoadClass.h
//  core
//
//  Created by guoxd on 2018/1/29.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol BreakPointDownLoadDelegate<NSObject>
-(void)getProgress:(double)progress;
@end
@interface BreakPointDownLoadClass : NSObject
@property (nonatomic,weak) __weak  id<BreakPointDownLoadDelegate> ProgressDelegate;
-(void)breakpointdownload:(NSString*)url savePath:(NSString*)savePath finish:(void (^)(NSError*error,NSString*savepath))block;
@end
