//
//  Base64Native.m
//  core
//
//  Created by BruceXu on 2018/1/31.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import "Base64Native.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "Base64.h"
@protocol  Base64NativeCoreDelegate <JSExport>
+ (NSString *)base64EncodedString:(NSString*)str;
+ (NSString *)base64DecodedString:(NSString*)str;
@end

@interface Base64Native()<Base64NativeCoreDelegate>
@end
@implementation Base64Native
+ (NSString *)base64EncodedString:(NSString*)str{
    return  [str base64EncodedString];
}
+ (NSString *)base64DecodedString:(NSString*)str{
    return [str base64DecodedString];
}
@end
