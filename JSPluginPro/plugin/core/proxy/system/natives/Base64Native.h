//
//  Base64Native.h
//  core
//
//  Created by BruceXu on 2018/1/31.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64Native : NSObject
+ (NSString *)base64EncodedString:(NSString*)str;
+ (NSString *)base64DecodedString:(NSString*)str;
@end
