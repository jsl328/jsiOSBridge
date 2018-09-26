//
//  WebViewController.h
//  XHLaunchAdExample
//
//  Created by xiaohui on 16/9/8.
//  Copyright © 2016年 qiantou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (nonatomic, copy) NSString *URLString;

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;

@property (copy, nonatomic) NSString *titleString;
@property (copy, nonatomic) NSString *waterString;
@property (assign, nonatomic) BOOL isWPS;

@end
