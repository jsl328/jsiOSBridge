//
//  JSONHelper.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/19.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONHelper : NSObject
+(NSString*)toJSONString:(id)object
;
+ (NSDictionary *)jsonToDictionary:(NSString *)jsonString
;
@end
