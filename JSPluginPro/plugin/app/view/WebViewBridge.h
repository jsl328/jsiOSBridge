//
//  WebViewBridge.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/18.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWebViewBridgeDelegate.h"
#import <UIKit/UIKit.h>
@interface WebViewBridge : NSObject<IWebViewBridgeDelegate,UIWebViewDelegate>
-(void) executeJs:(NSString*) method params: (NSArray*) params;
-(id)initWithWebView:(UIWebView*)webView_ ;
@end
