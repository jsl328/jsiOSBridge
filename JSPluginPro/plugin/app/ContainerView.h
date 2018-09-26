//
//  ContainerView.h
//  YXBuilder
//
//  Created by LiYuan on 2018/1/5.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerView : UIView

- (instancetype)initWithRoot:(UIViewController*)rootVC fullScreen:(BOOL)fullScreen statusColor:(UIColor *)color;

@end
