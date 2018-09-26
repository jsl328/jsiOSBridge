//
//  BootManager.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Status;
#import "IProgressMonitorDelegate.h"
@interface BootManager : NSObject
+(NSString*)BOOT_POINT;
+(NSArray<Status*>*)load:(id)root monitor:(id<IProgressMonitorDelegate>)monitor;
+(NSArray<Status*>*)unload:(id)root monitor:(id<IProgressMonitorDelegate>)monitor;
+(void)checkAndConstructDependRelation:(NSString*)name relationMap:(NSDictionary<NSString*,NSArray<NSString*>*>*)relationMap checkedRelationSet:(NSMutableArray<NSArray<NSString*>*>*)checkedRelationSet loadRelationList:(NSMutableArray<NSString*>*)loadRelationList;
@end
