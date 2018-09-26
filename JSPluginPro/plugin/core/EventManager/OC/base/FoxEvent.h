//
//  FoxEvent.h
//  YXBuilder
//
//  Created by BruceXu on 2018/1/7.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FoxEventObject.h"

typedef NS_ENUM(NSInteger, Type)
{
    CUSTOM,
    PUSHMESSAGE
};



@interface Event :EventObject
-(id)initWithType:(Type)type;

-(Type) getType;

-(EventObject*) getCurrentTarget;

-(void) setCurrentTarget:(EventObject* )target;

-(NSDictionary*)toDescriptionDic;



@end
