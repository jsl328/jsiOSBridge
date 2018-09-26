//
//  FoxEventCustom.h
//  YXBuilder
//
//  Created by BruceXu on 2018/1/7.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "FoxEvent.h"

@interface EventCustom : Event

-(id)initWithName:(NSString*)eventName;
-(void) setUserData:(id) data;
-(id) getUserData;
-(NSString*) getEventName;
-(NSDictionary*)toDescriptionDic;
@end
