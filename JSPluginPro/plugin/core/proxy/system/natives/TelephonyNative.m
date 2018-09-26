//
//  TelephonyNative.m
//  YXBuilder
//
//  Created by guoxd on 2017/12/12.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "TelephonyNative.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "LJContactManager.h"
#import "CallBackObject.h"
#import "AppDelegate.h"

extern NSString *CTSettingCopyMyPhoneNumber(void);

@interface TelephonyNative ()

@property (strong, nonatomic) JSManagedValue *callback;

@property (strong, nonatomic) UIWebView *phoneCallWebView;

@property (nonatomic,strong) CallBackObject *callBackID;

@end
@implementation TelephonyNative

//回调接口
-(void)call:(NSString*) action param: (NSString*) param  callback: (id<ICallBackDelegate>) callback{
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    self.callBackID = callback;
    if (param.length>0) {
        dictionary = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    }
    if ([action isEqualToString:@"getNumber"]) {
        [self getNumber:dictionary];
    }
    if ([action isEqualToString:@"getIMSI"]) {
        [self getIMSI:dictionary];
    }
    if ([action isEqualToString:@"shutdown"]) {
        [self stopApp:dictionary];
    }
    if ([action isEqualToString:@"getUUID"]) {
        [self getUUID:dictionary];
    }
    if ([action isEqualToString:@"callPhone"]) {
        [self callPhone:dictionary];
    }
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
    
    self.callback = [JSManagedValue managedValueWithValue:callBackValue andOwner:self];
}

- (void)stopApp:(NSDictionary *)params {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = app.window;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.1f animations:^{
            window.alpha = 1.0;
            window.frame = CGRectMake(0, 0, 0, 0);
        } completion:^(BOOL finished) {
            exit(0);
        }];
    });
}

- (void)getIMSI:(NSDictionary *)params {
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];
    
    NSString *imsi = [NSString stringWithFormat:@"%@%@", mcc, mnc];
    NSLog(@"mcc = %@,mnc = %@",mcc,mnc);
    if ((mcc.length>0) && (mnc.length>0)) {
        [self.callBackID run:CallBackObject.SUCCESS message:@"" data:imsi];
    }
    else{
        [self.callBackID run:CallBackObject.ERROR message:@"获取IMSI失败" data:@""];
    }
    
//    NSArray *arr = [YXArray yxStringWithStatus:JSCallbackStatusOK withMessage:nil withResult:imsi];
//    JSValue *Callback = [[self.callback value] callWithArguments:arr];
}

- (void)getNumber:(NSDictionary *)params {
//    [[LJContactManager sharedInstance] selectContactAtController:[self.class rootViewController] complection:^(NSString *name, NSString *phone) {
//
//    }];
    [[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"];
    NSString *iphoneNum = CTSettingCopyMyPhoneNumber();
    if (iphoneNum.length>0) {
        [self.callBackID run:CallBackObject.SUCCESS message:@"" data:iphoneNum];
    }
    else{
        [self.callBackID run:CallBackObject.ERROR message:@"获取本机号码失败" data:@""];
    }
}

- (void)callPhone:(NSDictionary *)params {
    NSString *phoneNum = [params objectForKey:@"number"];
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNum]];
    if ( !self.phoneCallWebView ) {
        self.phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [self.phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
}

-(void)getUUID:(NSDictionary *)dictionary{
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    if (identifierForVendor.length>0) {
        [self.callBackID run:CallBackObject.SUCCESS message:@"" data:identifierForVendor];
    }
    else{
        [self.callBackID run:CallBackObject.ERROR message:@"获取UUID失败" data:@""];
    }
}

@end

