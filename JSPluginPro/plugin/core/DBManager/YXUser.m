//
//  YXActions.m
//  YXIMSDK
//
//  Created by BruceXu on 2017/9/7.
//  Copyright © 2017年 BruceXu. All rights reserved.
//

#import "YXUser.h"

@implementation YXUser
@synthesize brhNo=_brhNo;
@synthesize userLevel=_userLevel;

 -(void)setBrhNo:(NSString *)brhNo{
    
    _brhNo=brhNo;
 }
-(NSString*)brhNo{
    return _brhNo;
}
-(void)setUserLevel:(NSInteger)userLevel{
    
    _userLevel=userLevel;
}
-(NSInteger)userLevel{
    return _userLevel;
}
@end
