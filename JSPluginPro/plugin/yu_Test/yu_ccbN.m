//
//  yu_ccbN.m
//  my_ccb
//
//  Created by jsl on 2018/9/9.
//  Copyright © 2018年 jsl. All rights reserved.
//

#import "yu_ccbN.h"

#import "CallBackObject.h"

@interface yu_ccbN()
@property (strong, nonatomic) JSManagedValue *javaValue;
@property(nonatomic,strong)CallBackObject *callback;
@end

@implementation yu_ccbN
-(void)call:(NSString *)action param:(NSString *)param callback:(id<ICallBackDelegate>)callback
{
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    self.callback = callback;
    if (param.length>0) {
        dictionary = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    }
    if ([action isEqualToString:@"yuN"]) {
        [self getNumber:@"yuN"];
    }
}
-(void)getNumber:(NSString*)yuN
{
    [self.callback run:CallBackObject.SUCCESS message:@"ok" data:@(100)];
}

- (void)setCallbackValue:(NSString *)callback {
    
    NSArray *funcArr = [callback componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@".[]"]];
    JSValue *callBackValue = nil;
    if (funcArr.count > 2) {
        callBackValue = [JSContext currentContext][[funcArr objectAtIndex:1]];
        for (int i = 2; i < funcArr.count - 1; i++) {
            callBackValue = [callBackValue valueForProperty:[funcArr objectAtIndex:i]];
        }
    }
    self.javaValue = [JSManagedValue managedValueWithValue:callBackValue andOwner:self];
}
@end
