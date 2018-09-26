//
//  FileMap.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileMap : NSObject
-(id)initWithPath:(NSString *)path;

-(NSString*) get:(NSString*) key;
-(void) put:(NSString*) key value:(NSString*) value;
-(void) putAll:(NSDictionary<NSString*, NSString*>*)map;
-(NSDictionary<NSString*,NSString*>*) getAll;
@end
