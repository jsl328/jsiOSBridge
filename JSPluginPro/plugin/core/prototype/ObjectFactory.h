//
//  ObjectFactory.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/18.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectFactory : NSObject
+ (instancetype)getInstance;
-(id)get:(NSString*) className Scope:(NSString*) scope;
@end
