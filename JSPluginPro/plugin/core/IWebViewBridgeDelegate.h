//
//  IWebViewBridgeDelegate.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/18.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

 @protocol IWebViewBridgeDelegate <NSObject>
-(void) executeJs:(NSString*) method params: (NSArray*) params;
-(void) executeFromNativeCode:(int)code msg:(NSString *)msg callbackld:(NSString*) callBackld params: (id) data;
 @end
