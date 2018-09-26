//
//  CrashHelper.h
//  CatchCrash
//
//  Created by qiuqiujun on 15/5/12.
//  Copyright (c) 2015年 com.Apress. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^ crashUpdateComplete)();
typedef void (^ crashUpdateFail)(NSError *error);

static inline CGFloat ScreenWidth() {
    return [UIScreen mainScreen].bounds.size.width;
}

@interface CrashHelper : NSObject

@property (copy, nonatomic) NSString *filename;
@property(strong) NSURLSession *session;
void uncaughtExceptionHandler(NSException *exception);
+(void)updateAsynToServerComplete:(crashUpdateComplete)complete fail:(crashUpdateFail)fail;
+(NSString*)getCrashLog;
+(void)deleteCrashLog;
+(BOOL)carshLogNumber;
+(BOOL)createCrashLog:(NSString*)content fileName:(NSString *)fileName;
@end

