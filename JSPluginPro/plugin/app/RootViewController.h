//
//  RootViewController.h
//  YXBuilder
//
//  Created by LiYuan on 2017/11/20.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController
-(void)setBootStatus:(const NSString *) status finishRate:(const int)finishRate;
-(void)finishBoot;
-(void)reBoot;
@end
