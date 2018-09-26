//
//  uploadNetworking.h
//  YXBuilder
//
//  Created by guoxd on 2018/1/11.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface UploadClass : NSObject
-(void)uploader:(NSDictionary *)dictionary finish:(void(^)(NSString *result,NSError *error))resultBlock;
@end
