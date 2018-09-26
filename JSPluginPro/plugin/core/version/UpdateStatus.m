//
//  UpdateStatus.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "UpdateStatus.h"
@interface UpdateStatus(){
    
}
/**
 * code
 */
@property(assign) int code;

/**
 * message
 */
@property(copy) NSString* message;

@end
@implementation UpdateStatus

-(id)initWithCode:(int)code_ message:(NSString*)message_{
    if(self=[super init]){
        _code=code_;
        _message=message_;
    }
    return self;
}
-(int)getCode{
    return _code;
}
-(NSString*)getMessage{
    return _message;
}
/**
 *  成功
 */
+(int) SUCCESS{
    return 0;
}

/**
 *  无法连接
 */
+(int) NOT_CONNECT{
    return 1;
}

/**
 * 不需要更新
 */
+(int) NOT_NEED_UPDATE{
    return 2;
}

/**
 * 更新错误
 */
+ (int) UPDATE_FAIL{
    return 3;
}

/**
 * 更新错误并提示
 */
+(int) UPDATE_FAIL_AND_TIP{
    return 4;
}

/**
 * 更新错误并退出
 */
+(int) UPDATE_FAIL_AND_EXIT{
    return 5;
}

/**
 * 删除错误
 */
+(int) DELETE_FAIL{
    return 6;
}

/**
 *  成功并需要重启
 */
+(int) SUCCESS_AND_RESTART{
    return 7;
}

/**
 *  成功并需要退出
 */
+(int) SUCCESS_AND_EXIT{
    return 8;
}

/**
 *  忽略更新
 */
+(int) IGNORE{
    return 9;
}


@end
