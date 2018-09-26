//
//  ExtensionRegistry.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/12.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IExtensionPointDelegate.h"
@interface ExtensionRegistry : NSObject
-(id)initWithRoot:(id)root;
-(id<IExtensionPointDelegate>) getExtensionPoint:(NSString*)pointName;
@end
