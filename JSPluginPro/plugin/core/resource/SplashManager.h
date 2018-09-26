//
//  SplashManager.h
//  YXBuilder
//
//  Created by LiYuan on 2018/1/4.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^finishBlock)(BOOL isFinish);

typedef NS_ENUM(NSInteger , ShowADType) {
    /** 图片（default） */
    ShowADTypePic = 0,
    /** Html样式 */
    ShowADTypeHtml = 1
};

@interface SplashManager : NSObject

/** 停留时间(default 3 ,单位:秒) */
@property(nonatomic,assign)NSInteger duration;
/** 显示广告类型 */
@property(nonatomic,assign)ShowADType adType;
/** AD的URL(不设置的话显示本地Launch图片) */
@property(nonatomic,copy)NSString *adUrl;
/** 点击广告跳转页面的URL */
@property(nonatomic,copy)NSString *openUrlStr;

+ (SplashManager *)shareManager;

- (void)splashFinished:(finishBlock)finish;

@end
