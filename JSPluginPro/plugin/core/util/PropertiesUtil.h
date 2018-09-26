//
//  PropertiesUtil.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertiesUtil : NSObject
+ (NSDictionary<NSString*,NSString*>*) load:(NSString*)fileName fileType:(NSString*)fileType encoding:(NSStringEncoding)encoding;
@end

