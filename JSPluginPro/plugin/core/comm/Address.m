//
//  Address.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "Address.h"
#import "StringUtil.h"
@interface Address(){
    
}

@end
@implementation Address
-(id)initWithSocketAddress:(NSString*)sAddress httpAddress:(NSString*)hAddress{
    if(self=[super init]){
        _socketAddress=sAddress;
        _httpAddress=hAddress;
    }
    return self;
}
/**
 * 是否为SSL socket
 * return
 */
-(BOOL)isSSLSocket {
    BOOL isSSL = self.socketAddress != nil
    && [self.socketAddress hasPrefix:@"sslsocket"];
    return isSSL;
}

/**
 * 是否为SSL HTTP
 * return
 */
-(BOOL) isSSLHttp {
    BOOL isSSL = self.httpAddress != nil
    && [self.httpAddress hasPrefix:@"https"];
    return isSSL;
}


/**
 * 转化为字符串
 */
-(NSString*) toString {
    BOOL flag = false;
    NSMutableString *sb=[NSMutableString new];
    [sb appendString:@"["];
    // 加入socket地址
    if (_socketAddress != nil && _socketAddress.length == 0) {
        [sb appendString:_socketAddress];
        flag = true;
    }
    // 加入HTTP地址
    if (_httpAddress != nil && _httpAddress.length == 0) {
        if (flag) {
            [sb appendString:@","];
        }
         [sb appendString:_httpAddress];
    }
   [sb appendString:@"]"];
    return  [sb copy];
}

/**
 * 解析
 *
 * return param
 * return
 */
+(Address*) parse:(NSString*) param {
    // 参数为空
    if (param == nil) {
        return nil;
    }
    // 参数长度为0
    param = [param stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int len = (int)param.length;
    if (len == 0) {
        return nil;
    }
    // 截取[]
    if ([param characterAtIndex:0 ]== '[' && [param characterAtIndex:(len - 1)] == ']') {
        
         param = [[param stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""];
       
      }
    
    // 定义地址
    Address *address = [Address new];
    NSArray* ss =  [param componentsSeparatedByString:@","];
    // 设置值
    if (ss.count == 2) {
        [address setProperty:ss[0]];
         [address setProperty:ss[1]];
    } else {
         [address setProperty:ss[0]];
    }
    return address;
}

/**
 * 设置属性
 *
 * return param
 */
-(void) setProperty:(NSString*) param {
    if ([param hasPrefix:@"socket://"]) {
         _socketAddress = param;
    } else if ([param hasPrefix:@"sslsocket://"]) {
         _socketAddress = param;
    } else if ([param hasPrefix:@"http://"]) {
        _httpAddress = param;
    } else if ([param hasPrefix:@"https://"]) {
        _httpAddress = param;
    } else {
        // 优先设置socket地址
        if (_socketAddress == nil) {
            _socketAddress=[NSString stringWithFormat:@"socket://%@",param];
            
        }
   
        // 是否为数字
        BOOL isNum = [StringUtil isNumber:param];
        if (isNum) {
            int start =(int)[_socketAddress rangeOfString:@"//"].location+2;
            int end=(int)[_socketAddress rangeOfString:@":"].location;
            NSString* s = [[_socketAddress substringFromIndex:start] substringToIndex:end];
            _httpAddress=[NSString stringWithFormat:@"http://%@:%@",s,param ];
         
        } else {
           _httpAddress=[NSString stringWithFormat:@"http://%@",param];
        }
        
    }
}















@end
