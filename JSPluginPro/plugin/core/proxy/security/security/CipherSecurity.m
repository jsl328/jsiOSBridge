//
//  CipherSecurity.m
//  YXBuilder
//
//  Created by LiYuan on 2018/1/18.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "CipherSecurity.h"
#import "ISecurityDelegate.h"
#import "NSString+EncryptDecrypt.h"
#import "CallBackObject.h"
#import "DES3Util.h"

@interface CipherSecurity() <ISecurityDelegate> {
    id<ICallBackDelegate> _callback;
}

@end

@implementation CipherSecurity

- (void)call:(NSString*)action params:(NSDictionary*)params callback:(id<ICallBackDelegate>)callback {
    _callback = callback;
    
    if ([@"MD5Encrypt" isEqualToString:action]) {
        [self MD5Encrypt:params callback:callback];
    } else if ([@"DES3Encrypt" isEqualToString:action]) {
        [self DES3Encrypt:params callback:callback];
    } else if ([@"DES3Decrypt" isEqualToString:action]) {
        [self DES3Decrypt:params callback:callback];
    } else if ([@"AESEncrypt" isEqualToString:action]) {
        [self AESEncrypt:params callback:callback];
    } else if ([@"AESDecrypt" isEqualToString:action]) {
        [self AESDecrypt:params callback:callback];
    } else if ([@"RSAEncrypt" isEqualToString:action]) {
        [self RSAEncrypt:params callback:callback];
    } else if ([@"RSADecrypt" isEqualToString:action]) {
//        [self RSADecrypt:params callback:callback];
    }
}

- (void)MD5Encrypt:(NSDictionary*)params callback:(id<ICallBackDelegate>)callback {
    
    [_callback run:CallBackObject.SUCCESS message:@"" data:[[params objectForKey:@"plaintext"] md5EncryptUpper]];
    
}

- (void)DES3Encrypt:(NSDictionary*)params callback:(id<ICallBackDelegate>)callback {
    
    [DES3Util encrypt:[params objectForKey:@"plaintext"] key:[params objectForKey:@"key"]];
    
    [_callback run:CallBackObject.SUCCESS message:@"" data:[DES3Util encrypt:[params objectForKey:@"plaintext"] key:[params objectForKey:@"key"]]];
}

- (void)DES3Decrypt:(NSDictionary*)params callback:(id<ICallBackDelegate>)callback {
    
    [_callback run:CallBackObject.SUCCESS message:@"" data:[DES3Util decrypt:[params objectForKey:@"ciphertext"] key:[params objectForKey:@"key"]]];
}

- (void)AESEncrypt:(NSDictionary*)params callback:(id<ICallBackDelegate>)callback {
    [_callback run:CallBackObject.SUCCESS message:@"" data:[[params objectForKey:@"plaintext"] AESEncryptWithKeyString:[params objectForKey:@"key"]]];
}

- (void)AESDecrypt:(NSDictionary*)params callback:(id<ICallBackDelegate>)callback {
    [_callback run:CallBackObject.SUCCESS message:@"" data:[[params objectForKey:@"ciphertext"] AESDecryptWithKeyString:[params objectForKey:@"key"] iv:@"01234567"]];
}

- (void)RSAEncrypt:(NSDictionary*)params callback:(id<ICallBackDelegate>)callback {
    [_callback run:CallBackObject.SUCCESS message:@"" data:[[params objectForKey:@"plaintext"] RSAEencryptWithKey_e:[params objectForKey:@"key_e"] andKey_n:[params objectForKey:@"key_n"]]];
}

//- (void)RSADecrypt:(NSDictionary*)params callback:(id<ICallBackDelegate>)callback {
//    [_callback run:CallBackObject.SUCCESS message:@"" data:[[params objectForKey:@"ciphertext"] md5EncryptUpper]];
//}

@end
