//
//  NewFeatureManager.m
//  GuidePageDemo
//
//  Created by LiYuan on 2018/1/12.
//  Copyright © 2018年 俱哥. All rights reserved.
//

#import "NewFeatureManager.h"
#import <UIKit/UIKit.h>
#import "ZJNewFeatureController.h"
#import "Aspects.h"

#define APPID [[[[NSBundle mainBundle] bundleIdentifier] componentsSeparatedByString:@"."] lastObject]

#define manifestDic [NSJSONSerialization JSONObjectWithData:[[NSData alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/configuration/launchImage.json", [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Pandora/%@", APPID]]]] options:NSJSONReadingMutableLeaves error:nil]

@interface NewFeatureManager () {
    id<NewFeatureDelegate> _delegate;
    NSMutableArray *_picStrArr;
    UIWindow *_window;
}

@end

@implementation NewFeatureManager

+ (void)shareManagerWithDelegate:(id<NewFeatureDelegate>)delegate picStrArr:(NSArray *)picStrArr {
    static NewFeatureManager *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[NewFeatureManager alloc] init];
        [instance getDelegate:delegate picStrArr:picStrArr];
        
        [instance setupNewFeature];
    });
}

- (void)getDelegate:(id<NewFeatureDelegate>)delegate picStrArr:(NSArray *)picStrArr {
    _delegate = delegate;
    _picStrArr = [NSMutableArray arrayWithArray:picStrArr];
}

- (void)setupNewFeature {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:[NSString stringWithFormat:@"ISNEWFEATURE%@", [manifestDic objectForKey:@"guide_version"]]]) return;
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    for (int i = 0; i < _picStrArr.count; i++) {
        if ([[_picStrArr objectAtIndex:i] isEqualToString:@""]) {
            [_picStrArr removeObjectAtIndex:i];
        }
    }
    if (_picStrArr.count == 0) return;
    ZJNewFeatureController *fearure = [[ZJNewFeatureController alloc] initWithArray:_picStrArr];
    fearure.view.backgroundColor = [UIColor clearColor];
    
    // 捕获ZJNewFeatureCell的start方法
    Class class = NSClassFromString(@"ZJNewFeatureCell");
    SEL selector = NSSelectorFromString(@"start");
    [class aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock: ^( id<AspectInfo> aspects ) {
        // 记录是否已经走过新特性
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:[NSString stringWithFormat:@"ISNEWFEATURE%@", [manifestDic objectForKey:@"guide_version"]]];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        // 新特性Window移除
        [UIView transitionWithView:window duration:0.8 options:UIViewAnimationOptionTransitionNone animations:^{
            window.alpha = 0;
        } completion:^(BOOL finished) {
            [self remove];
        }];
    }  error:NULL];
    
    window.rootViewController = fearure;
    window.windowLevel = UIWindowLevelStatusBar + 1;
    window.alpha = 1;
    window.hidden = NO;
    _window = window;
}

- (void)remove {
    _window.hidden = YES;
    _window.rootViewController = nil;
    _window = nil;
    
    if (_delegate && [_delegate respondsToSelector:@selector(newFeatureDidLoadFinished)]) {
        [_delegate newFeatureDidLoadFinished];
    }
}

@end
