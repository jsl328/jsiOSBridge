//
//  WebViewController.m
//  XHLaunchAdExample
//
//  Created by xiaohui on 16/9/8.
//  Copyright © 2016年 qiantou. All rights reserved.
//

#import "WebViewController.h"
#import "UIImage+WaterMark.h"
#import "UIImage+Rotate.h"
#import "NSString+helper.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface WebViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic)UITextView *textView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupWebView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)setupWebView{

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    textView.editable = NO;
    [self.view addSubview:textView];
    self.textView = textView;
    
    if (self.titleString.length > 0) {
        self.titleLabel.text = self.titleString;
    } else {
        self.titleLabel.text = @"详情";
    }
    
    NSString *lastName = [[self.URLString lastPathComponent] lowercaseString];
    lastName = [[lastName componentsSeparatedByString:@"."] lastObject];
    BOOL isTxt = [lastName isEqualToString:@"txt"];
    
    NSData *data = [NSData dataWithContentsOfFile:self.URLString];;
    
    //4.2.1、如果是txt文档，用textView加载
    if (isTxt) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (!body) {//如果为UTF8格式的则body不为空
                
                body = [[NSString alloc] initWithData:data encoding:0x80000632];//如果不是 则进行GBK编码再解码一次
            }
            if (!body) {
                
                body = [[NSString alloc] initWithData:data encoding:0x80000631];//不行用GB18030编码再解码一次
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.myWebView.hidden = YES;
                textView.hidden = NO;
                textView.text = body;
            });
            
//        NSString* responseStr = [NSString stringWithFormat:
//                                 @"<HTML>"
//                                 "<head>"
//                                 "<title>Text View</title>"
//                                 "</head>"
//                                 "<BODY>"
//                                 "<pre>"
//                                 "%@"
//                                 "/pre>"
//                                 "</BODY>"
//                                 "</HTML>",
//                                 body];
//        
//        if (body) {
//            [self.myWebView loadHTMLString:responseStr baseURL:nil];
//        }

            
//        NSData* Data = [NSData dataWithContentsOfFile:qs];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDir = [paths objectAtIndex:0] ;   //根据自己的具体情况设置，我的html文件在document目录，链接也是在这个目录上开始 data中有一些链接是图片，css都是外部文件，然后这些文件需要到一个目录上去找。
//        NSURL *baseUrl = [NSURL fileURLWithPath:documentsDir];
//
//        [self.myWebView loadData:Data MIMEType:@"text/html" textEncodingName:@"GBK" baseURL:baseUrl];
        });
    }else{//4.2.2、如果是office文档，用WebView加载
        
        textView.hidden = YES;
        self.myWebView.hidden = NO;
        self.myWebView.scalesPageToFit = YES;//自动对页面进行缩放以适应屏幕
        self.myWebView.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;//自动检测网页上的电话号码，单击可以拨打
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                //解析office文档
                NSString *MIMEType = [NSString string];
                if ([lastName isEqualToString:@"doc"] || [lastName isEqualToString:@"wps"] || [lastName isEqualToString:@"dot"]) {
                    MIMEType = @"application/msword";
                } else if ([lastName isEqualToString:@"docx"]) {
                    MIMEType = @"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                } else if ([lastName isEqualToString:@"xls"] || [lastName isEqualToString:@"et"] || [lastName isEqualToString:@"xlt"] || [lastName isEqualToString:@"xla"]) {
                    MIMEType = @"application/vnd.ms-excel";
                } else if ([lastName isEqualToString:@"xlsx"]) {
                    MIMEType = @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                } else if ([lastName isEqualToString:@"ppt"] || [lastName isEqualToString:@"dps"] || [lastName isEqualToString:@"pot"] || [lastName isEqualToString:@"pps"] || [lastName isEqualToString:@"ppa"]) {
                    MIMEType = @"application/vnd.ms-powerpoint";
                } else if ([lastName isEqualToString:@"pptx"]) {
                    MIMEType = @"application/vnd.openxmlformats-officedocument.presentationml.presentation";
                } else if ([lastName isEqualToString:@"pdf"]) {
                    MIMEType = @"application/pdf";
                }
                NSString *douRoot = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                NSURL *baseUrl = [NSURL URLWithString:[douRoot stringByAppendingPathComponent:@"TestOffice"]];
                [self.myWebView loadData:data MIMEType:MIMEType textEncodingName:@"UTF-8" baseURL:baseUrl];
            });
        });
        
//        if ([self.URLString includeChinese]) {
//            self.URLString = [self.URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        }
//
//        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.URLString]];// NSURL需要将中文改为UTF-8
//        [self.myWebView loadRequest:request];
    }
    
    if (self.isWPS) {
        [self createBackgroudWithIsTxt:isTxt];
    }
}

- (void)createBackgroudWithIsTxt:(BOOL)isTxt
{
    UIView *waterView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    waterView.userInteractionEnabled = NO;
    waterView.opaque = NO;
    
    UIImage * image = [self imageFromColor:[UIColor clearColor] andSize:CGSizeMake(129, 86)];
    UIImage *resultImage = [image imageWaterMarkWithString:@"fox" point:CGPointMake(0, 10) attribute:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    UIImage * bg = [resultImage imageRotatedByRadians:-M_PI/6];
    image = [image imageWaterMarkWithImage:bg imagePoint:CGPointMake(0, -10) alpha:1];
    waterView.backgroundColor = [UIColor colorWithPatternImage:image];
    
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:waterView];
    
    //6、防止复制：拦截webview长按功能
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:nil];
    longPress.minimumPressDuration = 0.1;
    if (isTxt) {
        [self.textView addGestureRecognizer:longPress];
    } else {
        [self.myWebView addGestureRecognizer:longPress];
    }
    
    //清除cookie
    [self cleanCacheAndCookie];
}

- (UIImage *)imageFromColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (IBAction)closeAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

/**清除缓存和cookie*/
- (void)cleanCacheAndCookie{
    
    //清除cookies
    
    NSHTTPCookie *cookie;
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (cookie in [storage cookies]){
        
        [storage deleteCookie:cookie];
        
    }
    
    //清除UIWebView的缓存
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSURLCache * cache = [NSURLCache sharedURLCache];
    
    [cache removeAllCachedResponses];
    
    [cache setDiskCapacity:0];
    
    [cache setMemoryCapacity:0];
    
}

- (NSUInteger) supportedInterfaceOrientations
{
    //Because your app is only landscape, your view controller for the view in your
    // popover needs to support only landscape
    return UIInterfaceOrientationMaskPortrait;
}

@end
