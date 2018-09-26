//
//  DownLoadClass.h
//  core
//
//  Created by guoxd on 2018/1/24.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DownLoadClassDelegate<NSObject>
-(void)resultOfDownLoadClass:(NSString *)resultString andError:(NSError *)error;
@end
@interface DownLoadClass : NSObject
@property (nonatomic,weak) __weak  id<DownLoadClassDelegate> delegate;
-(NSURLSessionTask *)downloader:(NSDictionary *)dictionary;
-(void)startdownloadFile:(NSDictionary *)dictionary;
-(void)stopdownloadFile;
@end
