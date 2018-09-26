//
//  WebViewBridge.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/18.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "WebViewBridge.h"
#import "JSONHelper.h"
#import "Platform.h"
#import "YXPlugin.h"
@interface WebViewBridge(){
    
}
@property(weak) UIWebView *webView;
@property(assign)BOOL debug;
@end
@implementation WebViewBridge
-(id)initWithWebView:(UIWebView*)webView_ {
    if(self=[super init]){
        self.webView=webView_;
        self.debug=YES;
    }
    return self;
}
/**
 * 调用JS
 *
 * @param method
 * @param params
 */
-(void) executeJs:(NSString*) method params: (NSArray*) params {
    //为空方法，不进行处理
    if ([self isNullMethod:method]) {
        FOXLog(@"%@",@"忽略空方法回调");
        return;
    }
    
    //获取platform
    Platform* platform = [Platform getInstance];
    if([NSThread currentThread]==[NSThread mainThread]){
        int ii=0;
    }
    else {
        int bbb=0;
    }
    //获取platform
    //获取UI事件执行器
    id<UIEventExecutorDelegate> uiExecutor = [platform uiEventExecutor];
    if([uiExecutor isUIThread]){
        [self execute:method params:params];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self execute:method params:params];
        });
    }
    //暂时放在主线成中
}

-(void) executeFromNativeCode:(int)code msg:(NSString *)msg callbackld:(NSString*) callBackld params: (id) data{
    //为空方法，不进行处理//获取platform
    Platform* platform = [Platform getInstance];
    //获取platform
    //获取UI事件执行器
    //暂时放在主线成中
    id<UIEventExecutorDelegate> uiExecutor = [platform uiEventExecutor];
    NSDictionary *dict=@{@"code":@(code),@"msg":msg,@"callbackId":callBackld,@"data":data};
    if([uiExecutor isUIThread]){
        NSString *retJson =[self convertToJsonData:dict];
        NSString *js = [NSString stringWithFormat:@"javascript:JSBO.handleMessageFromNative('%@');",retJson];
        [_webView stringByEvaluatingJavaScriptFromString:js];
    }else{
        __weak typeof (self) weakSelf=self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *retJson =[self convertToJsonData:dict];
            NSString *js = [NSString stringWithFormat:@"javascript:JSBO.handleMessageFromNative('%@');",retJson];
            [weakSelf.webView stringByEvaluatingJavaScriptFromString:js];
        });
    }
}

/**
 * 执行js
 *
 * param method
 * param params
 */
-(void) execute:(NSString*) method params: (NSArray*) params {
    
    NSMutableString *sb=[NSMutableString new];
    [sb appendString:method];
    [sb appendString:@"("];
    if (params == nil || params.count == 0) {
        [sb appendString:@")"];
    } else {
        for (int i = 0; i < params.count; i++) {
            if (params[i] ==nil) {
                [sb appendString:(params[i])];
            } else if ([params[i] isKindOfClass: [NSString class]]) {
                NSString *s = [self format:(NSString*) params[i]];
                [sb appendString:@"'"];
                [sb appendString:s];
                [sb appendString:@"'"];
            }
           
            else if ([params[i] isKindOfClass:[NSNumber class]]) {
                [sb appendString:@"'"];
                [sb appendString:[NSString stringWithFormat:@"%@",params[i]]];
                [sb appendString:@"'"];
            }
            else if([params[i] isKindOfClass:[NSDictionary class]]||[params[i] isKindOfClass:[NSArray class]]){
                NSString *jsonStr = [JSONHelper toJSONString:params[i]];
                jsonStr = [self format:jsonStr];
                jsonStr=[jsonStr stringByReplacingOccurrencesOfString:@"\r"withString:@""];
                jsonStr= [jsonStr stringByReplacingOccurrencesOfString:@"\n"withString:@""];
               // jsonStr= [jsonStr stringByReplacingOccurrencesOfString:@"\""withString:@"'"];
                [sb appendString:@"'"];
                [sb appendString:[NSString stringWithFormat:@"%@",jsonStr]];
                [sb appendString:@"'"];
 
            }
            else {
                [sb appendString:[NSString stringWithFormat:@"%@",(params[i])]];
            }
            if (i < params.count - 1) {
                [sb appendString:@","];
            }
        }
         [sb appendString:@")"];
        
    }
    NSString *js = [sb copy];
    //打印日志
    #ifdef DEBUG
    NSMutableString * logSb =  [NSMutableString new];
    if (self.debug) {
        [logSb appendString:@"回调JS:"];
        [logSb appendString:js];
    } else {
        [logSb appendString:@"回调JS:"];
        [logSb appendString:method];
    }
  #endif
    
    id<UIEventExecutorDelegate> uiExecutor = [[Platform getInstance] uiEventExecutor];
    if([uiExecutor isUIThread]){//延迟0.3秒，防止线程锁死
        NSMutableString *sbAppend=[NSMutableString new];
        [sbAppend appendString:@"setTimeout(function(){"];
        [sbAppend appendString:js];
        [sbAppend appendString:@"},300)"];
        js=[sbAppend copy];
    }
    [_webView stringByEvaluatingJavaScriptFromString:js];
}
/**
 * 判断是为空方法
 *
 * param method
 * return
 */
-(BOOL) isNullMethod:(NSString* )method {
    //是否为空值
    if (method == nil) {
        return true;
    }
    
    //去掉前后空格
    method = [method stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //小写转换
    method = [method lowercaseString];
    
    if (method.length == 0) {
        return true;
    }
    if ([method isEqualToString:@"undefined"]) {
        return true;
    }
    return false;
}


/**
 * 格式化
 *
 * param src
 * return
 */
-(NSString*) format:(NSString*) src {
    if(src==nil||src.length==0) return src;
        int offset = 0;
    unsigned int index = -1;
    do {
       // index = (int)[[src substringFromIndex:offset] rangeOfString:@"'"].location;
      
       NSRange range=  [src rangeOfString:@"'"];
        if(range.location==NSNotFound){
            return src;
        }
        index=(int)range.location;
        if (index != -1) {
            int preIndex = index - 1;
            if (preIndex >= 0) {
                char c = [src characterAtIndex:preIndex];
                if (c != '\\') {
                    NSString* preStr = [src substringToIndex:index];
                    NSString* postStr = [src substringFromIndex:index];
                    
                    // 拼装字符串
                    NSMutableString *sb=[NSMutableString new];
                    [sb appendString:preStr];
                    [sb  appendString:@"\\"];
                    [sb appendString:postStr];
                    src =  [sb copy];
                    // 修改offset
                    offset = index + 2;
                } else {
                    offset = index + 1;
                }
                
            }
        }
    } while (index != -1 && offset < src.length);
    return src;
}
// 字典转json字符串方法
-(NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}
@end
