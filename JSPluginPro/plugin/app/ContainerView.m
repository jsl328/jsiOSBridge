//
//  ContainerView.m
//  YXBuilder
//
//  Created by LiYuan on 2018/1/5.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "ContainerView.h"
#import "BrowSerWebView.h"
#import "YXPlugin.h"
@implementation ContainerView

- (instancetype)initWithRoot:(UIViewController*)rootVC fullScreen:(BOOL)fullScreen statusColor:(UIColor *)color {
    if(self = [super init]){
        self.frame = [[UIScreen mainScreen] bounds];
        
        CGRect viewFrame = CGRectZero;
        if (fullScreen) {
            viewFrame = [[UIScreen mainScreen] bounds];
        } else {
            UIView *statueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
            statueView.backgroundColor = color;
            [self addSubview:statueView];
            viewFrame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - 20);
        }
        BrowSerWebView *webView = [[BrowSerWebView alloc] initWithRoot:rootVC frame:viewFrame];
        [self addSubview:webView];
        
    }
    return self;
}

@end
