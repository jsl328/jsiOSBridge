//
//  Status.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/13.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "Status.h"
@interface Status()

@end
@implementation Status
 
-(id)initWithCode:(int)code{
    self=[self init];
    self.resultCode=code;
    return self;
}

-(id)initWithCode:(int)code message:(NSString*)message{
    self=[self init];
    self.resultCode=code;
    self.message=message;
    return self;
}
+(int)SUCCESS{
    return 0;
}
+(int)FAIL{
    return 1;
}
+(int)RESTART{
    return 3;
}
+(int)EXIT{
    return 4;
}



@end
