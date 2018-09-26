//
//  FoxEventPushMessage.m
//  YXBuilder
//
//  Created by BruceXu on 2018/1/9.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "FoxEventPushMessage.h"
@interface EventPushMessage(){
  NSString *  _messageType;
    NSString *_messageData;
}
@end
@implementation EventPushMessage
-(id)init{
    if(self=[super initWithType:PUSHMESSAGE]){
        
    }
    return self;
}
-(NSString*)getMessageType{
    return _messageType;
}
-(void)setMessageType:(NSString*)messageType{
    _messageType=messageType;
}
-(id)getMessage{
    return _messageData;
}
-(void)setMessage:(id)data{
    _messageData=data;
}
-(NSDictionary*)toDescriptionDic{
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_messageData options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *dicstr=@"";
//    if (! jsonData) {
//       dicstr=@"{}";
//    } else {
//        dicstr= [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
    return @{@"messagetype":_messageType,@"messagedata":_messageData};
}
@end
