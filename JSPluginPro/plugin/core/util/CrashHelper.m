//
//  CrashHelper.m
//  CatchCrash
//
//  Created by qiuqiujun on 15/5/12.
//  Copyright (c) 2015年 com.Apress. All rights reserved.
//

#import "CrashHelper.h"
#import "LogManager.h"

#define CRASHLOG [LogManager getIntance].crashAbsolutePath
#define UPDATECRASHLOGURL (@"http://127.0.0.1:9999/")

@implementation CrashHelper

//异步上传
+(void)updateAsynToServerComplete:(crashUpdateComplete)complete fail:(crashUpdateFail)fail{
    
    //找到崩溃日志
    if([[NSFileManager defaultManager] fileExistsAtPath:CRASHLOG]){
        
        NSMutableArray * arr=[NSMutableArray new];
        NSString *newfileName=@"";
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:CRASHLOG];
        for (NSString *fileName in enumerator) {
            [arr addObject:fileName];
        }
        if(arr.count>0){
            //升序数组排序：
            NSArray *resultArray = [arr sortedArrayUsingComparator:^(id string1,id string2){
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
                NSDate *date1 = [dateFormatter dateFromString:string1];
                NSDate *date2 = [dateFormatter dateFromString:string2];
                return  [date1 compare:date2];
                
            }];
            
            newfileName=[resultArray lastObject];
            newfileName=[CRASHLOG stringByAppendingPathComponent:newfileName];
            //
            NSString *urlStr = UPDATECRASHLOGURL;
           
            
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
            request.HTTPMethod = @"PUT";
            
            NSURLSession *session = [NSURLSession sharedSession];
            
            //NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"111.jpg"], 0.75);
            NSData *fileData = [NSData dataWithContentsOfFile:newfileName];
            
            
            NSURLSessionUploadTask *upload = [session uploadTaskWithRequest:request fromData:fileData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (error != nil) {
                    
                    NSLog(@"ERROR -> %@", error.localizedDescription);
                    NSLog(@"上传文件失败");
                    fail(error);
                    
                } else {
                    NSLog(@"上传文件成功");
                    //清空所有异常文件
                    NSString *filePath =CRASHLOG;
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                     complete();
                    
                    
                }
            }];
            [upload resume];
        }
    }
    
    
    
    //同步上传
    //+(void)updateSynToServer{
    //
    //    //找到崩溃日志
    //      if([[NSFileManager defaultManager] fileExistsAtPath:CRASHLOG]){
    //
    //        NSMutableArray * arr=[NSMutableArray new];
    //        NSString *newfileName=@"";
    //        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:CRASHLOG];
    //        for (NSString *fileName in enumerator) {
    //           [arr addObject:fileName];
    //        }
    //        if(arr.count>0){
    //        //升序数组排序：
    //        NSArray *resultArray = [arr sortedArrayUsingComparator:^(id string1,id string2){
    //
    //            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //            [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    //            NSDate *date1 = [dateFormatter dateFromString:string1];
    //            NSDate *date2 = [dateFormatter dateFromString:string2];
    //            return  [date1 compare:date2];
    //
    //       }];
    //
    //            newfileName=[resultArray lastObject];
    //            newfileName=[CRASHLOG stringByAppendingPathComponent:newfileName];
    //
    //            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    //
    //            NSString *urlStr = @"http://127.0.0.1:9999/";
    //
    //            NSURL *url = [NSURL URLWithString:urlStr];
    //
    //
    //            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
    //
    //            request.HTTPMethod = @"PUT";
    //
    //
    //            NSURLSession *session = [NSURLSession sharedSession];
    //
    //            //NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"111.jpg"], 0.75);
    //             NSData *fileData = [NSData dataWithContentsOfFile:newfileName];
    //
    //
    //            NSURLSessionUploadTask *upload = [session uploadTaskWithRequest:request fromData:fileData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    //
    //                if (error != nil) {
    //
    //                    NSLog(@"ERROR -> %@", error.localizedDescription);
    //                    NSLog(@"上传文件失败");
    //
    //                } else {
    //                    NSLog(@"上传文件成功");
    //                    //清空所有异常文件
    //                    NSString *filePath =CRASHLOG;
    //                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    //                }
    //                // [NSThread sleepForTimeInterval:5];
    //                dispatch_semaphore_signal(semaphore);   //发送信号
    //
    //            }];
    //            [upload resume];
    //
    //
    //            dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
    //  }
    //
    //
    //}
    
}
+ (BOOL)createCrashLog:(NSString*)content fileName:(NSString *)fileName{
    NSString *filePath =CRASHLOG;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){// 先清除其余crashLog
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:filePath];
        for (NSString *fileName in enumerator) {
            [[NSFileManager defaultManager] removeItemAtPath:[filePath stringByAppendingPathComponent:fileName] error:nil];
        }
        
    } else{// 创建一个文件夹
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString *filename = [NSString stringWithFormat:@"%@/%@.log", filePath, fileName];
    
    NSLog(@"path=%@",filename);
    
    BOOL iswriten= [content writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return iswriten;
    
    

}

//返回崩溃日志的路径
+(NSString*)getCrashLog{
    //找到崩溃日志
//    NSString *newfileName=@"";
//    if([[NSFileManager defaultManager] fileExistsAtPath:CRASHLOG]){
//        
//        NSMutableArray * arr=[NSMutableArray new];
//        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:CRASHLOG];
//        for (NSString *fileName in enumerator) {
//            [arr addObject:fileName];
//        }
//        if(arr.count>0){
//            //升序数组排序：
//            NSArray *resultArray = [arr sortedArrayUsingComparator:^(id string1,id string2){
//                
//                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
//                NSDate *date1 = [dateFormatter dateFromString:string1];
//                NSDate *date2 = [dateFormatter dateFromString:string2];
//                return  [date1 compare:date2];
//                
//            }];
//            
//            newfileName=[resultArray lastObject];
//            newfileName=[CRASHLOG stringByAppendingPathComponent:newfileName];
//        }
//    }
//    return newfileName;
    NSString * content= [[NSUserDefaults standardUserDefaults] objectForKey:@"BENGKUIRIZHI"];
    if(content==nil)content=@"";
    return content;
    
}

//删除崩溃日志
+(void)deleteCrashLog{
    //清空所有异常文件
//    NSString *filePath =CRASHLOG;
//    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];    

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BENGKUIRIZHI"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)carshLogNumber{
    if([[NSFileManager defaultManager] fileExistsAtPath:CRASHLOG]){
        
        NSMutableArray * arr=[NSMutableArray new];
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:CRASHLOG];
        for (NSString *fileName in enumerator) {
            [arr addObject:fileName];
        }
        if(arr.count>0){
            return false;
        }else{
            return true;
        }
    }else{
       return true;
    }
}


@end
