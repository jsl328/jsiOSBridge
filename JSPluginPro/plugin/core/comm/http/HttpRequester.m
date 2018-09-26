//
//  HttpRequester.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/21.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "HttpRequester.h"
#import "HttpURLClient.h"
#import "GlobalConstant.h"
#import "pluginSSLNetWorking.h"
#import "FoxFileManager.h"
#import "YXPlugin.h"
#import "ZipArchive.h"
#import "BreakPointDownLoadClass.h"
#import "CallBackObject.h"
#import "AFNetworking.h"
#import "MD5Util.h"
#import "CallBackObject.h"
#import "ByteUtil.h"
#import "GZIPutil.h"
#import "HttpURLClient.h"
#define FF FoxFileManager
@interface HttpRequester()<NSURLSessionDelegate>

@end
/**
 * HTTP请求器
 *
 *
 */
@implementation HttpRequester

    /**
     * HTTP请求形式(POST)
     */
+(NSString*) POST { return  @"POST";};

    /**
     * HTTP请求形式(GET)
     */
+(NSString*) GET { return  @"GET";};

    /**
     * 当前运行context path
     */
+(NSString*) INSTANT_CONTEXT_PATH {return @"instant";};

    /**
     * workspace context path
     */
+(NSString*) WORKSPACE_CONTEXT_PATH {return @"workspace";};

    /**
     * configuration context path
     */
+(NSString*) CONFIGURATION_CONTEXT_PATH  { return @"configuration";};

    /**
     * base context
     */
+(NSString*) BASE_CONTEXT {return @"baseContext";};

    /**
     * 绝对路径
     */
+(NSString*) ABSOLUTE_PATH {return @"absolute";};

    /**
     * 相对路径
     */
+(NSString*) RELATIVE_PATH {return @"relative";};

    /**
     * 当前路径
     */
+(NSString*) CURRENT_PATH {return @"current";};

    /**
     * 默认编码
     */
+(NSStringEncoding)encoding{ return GlobalConstant.ENCODING;}

    /**
     * 服务名
     */
+(NSString*) SERVICE_NAME {
   // return @"ydptHtpsvr1/htpsvrcontroller";
    return @"services/fileService";
};


/**
 * 服务根目录
 */
+(NSString*) SERVICE_ROOT { return @"ydptHtpsvr1";};

    /**
     * 列分割符
     */
+(NSString*) ITEM_SPLITOR { return @"\t";}

    /**
     * 行分割符
     */
+(NSString*) LINE_SPLITOR { return @"\n";}

    /**
     * 客户端最近IP
     */
    static NSString* lastIP;

    /**
     * 最近通行证
     */
    static NSString* lastPassport;

    /**
     * token resister
     */
static NSMutableDictionary<NSString*,NSNumber*>* tokenRegister; //=new HashMap<String,Long>();

    /**
     * token seed
     */
  //  private static AtomicLong tokenSeed=new AtomicLong(0);

    /**
     * session ID
     */
     static NSString* sessionID;

    /**
     * 生成token id
     * return
     */
     +(long) generateTokenID{
        //return tokenSeed.getAndAdd(1);
         return 0;
    }

    /**
     * 获取host
     *
     * param url
     * return
     */
+ (NSString*) getHost:(NSURL*) url {
    return nil;
}

    /**
     * 获取通行证
     *
     * param ip
     * return
     */
+( NSString*) getPassport:(NSString*) ip{
     return @"";
}

/**
 * 获取临时文件
 *
 * param path
 * return
 */
+(NSString*)getTempFile:(NSString*) path {
    NSMutableString* sb = [NSMutableString new];
    [sb appendString:path];
    [sb appendString:@".tmp"];
    return [sb copy];
    
}

/**
 * 获取ZIP文件
 *
 * param path
 * return
 */
+(NSString*) getZipFile:(NSString*) path {
    NSMutableString* sb = [NSMutableString new];
    [sb appendString:path];
    [sb appendString:@".zip"];
    return [sb copy];
}

/**
 * 获取页面记录文件
 *
 * param path
 * return
 */
+(NSString*) getPageRecord:(NSString*) path {
    
    NSMutableString* sb = [NSMutableString new];
    [sb appendString:path];
    [sb appendString:@".pagerecord"];
    return [sb copy];
}

/**
     * 远程文件是否存在
     *
     * param address
     * param path
     * param baseContext
     * param timeout
     * return
     * @throws Exception
     */
+(BOOL) isRemoteFileExists:(NSString*) address path: (NSString*) path baseContext:(NSString*)baseContext timeout:(int)timeout{
   
    
    NSMutableString *sb=[NSMutableString new];
    [sb appendString:address];
    [sb appendString:@"/"];
    [sb appendString:HttpRequester.SERVICE_NAME];
    
    NSString *urlStr=[sb copy];
    urlStr= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"POST";
    NSString *body=[NSString stringWithFormat:@"app=fileExists&path=%@&baseContext=%@",path,baseContext];
     //5,设置请求体
    request.HTTPBody=[body dataUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    __block BOOL isExist=NO;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[[NSOperationQueue alloc]init]];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if (!error) {
            
            NSString *res= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             isExist= [res isEqualToString:@"true"];
            
            }else{
            isExist=NO;
        }
        dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    return isExist;
    
    
    
    
//    //暂时这么写吧 老版本备份
//    if([path characterAtIndex:0]!='/'){
//        path=[NSString stringWithFormat:@"/%@",path ];
//    }
//    NSMutableString *sb=[NSMutableString new];
//    [sb appendString:address];
//    [sb appendString:@"/"];
//    [sb appendString:HttpRequester.SERVICE_NAME];
//    [sb appendString:@"?"];
//    [sb appendFormat:@"%@=%@",@"app",@"fileExists"];
//    [sb appendString:@"&"];
//    [sb appendFormat:@"%@=%@",@"path",path];
//    [sb appendString:@"&"];
//    [sb appendFormat:@"%@=%@",@"baseContext",baseContext];
//
//    NSString *urlStr=[sb copy];
//   urlStr= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
//    __block BOOL isExist=NO;
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[[NSOperationQueue alloc]init]];
//
//    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//
//
//        if (!error) {
//             NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            if(dict){
//              isExist= [[dict objectForKey:@"data"] intValue];
//            }
//        }else{
//            isExist=NO;
//        }
//        dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
//    }];
//    [task resume];
//    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
//    return isExist;




}

/**
     * 删除远程文件
     *
     * param address
     * param path
     * param baseContext
     * param timeout
     * return
     * @throws Exception
     */
+(BOOL) deleteRemoteFile:(NSString*) address path:(NSString*) path baseContext:(NSString*) baseContext timeout:(int)timeout{

//        // 拼装地址
//        StringBuilder sb = new StringBuilder();
//        sb.append(address);
//        sb.append("/");
//        sb.append(SERVICE_NAME);
//        // 请求URL;
//        String url = sb.toString();
//        // 参数
//        Map<String, String> param = new HashMap<String, String>();
//        // 请求数据
//        Map<String, String> data = new HashMap<String, String>();
//        data.put("app", "removeFile");
//        data.put("path", path);
//        data.put("baseContext", baseContext);
//        // 发起post请求
//        String res = post(url, param, data, encoding, timeout);
//        // 返回结果
//        return "true".equalsIgnoreCase(res);
    return YES;
    }

    /**
     * 列举远程文件夹
     *
     * param address
     * param path
     * param baseContext
     * param pathFormat
     * param timeout
     * return
     * @throws Exception
     */
+(NSArray<NSString*>*) listRemoteFile:(NSString*) address path: (NSString*) path baseContext:(NSString*)baseContext pathFormat:(NSString*)pathFormat timeout:(int)timeout{
    
//        // 拼装地址
//        StringBuilder sb = new StringBuilder();
//        sb.append(address);
//        sb.append("/");
//        sb.append(SERVICE_NAME);
//        // 请求URL;
//        String url = sb.toString();
//        // 参数
//        Map<String, String> param = new HashMap<String, String>();
//        // 请求数据
//        Map<String, String> data = new HashMap<String, String>();
//        data.put("app", "list");
//        data.put("path", path);
//        data.put("baseContext", baseContext);
//        data.put("pathFormat", pathFormat);
//        // 发起post请求
//        String res = post(url, param, data, encoding, timeout);
//        // 分割结果
//        String[] items = StringUtil.split(res, LINE_SPLITOR);
//        // 返回结果
//        return items;
    return nil;
    }

    /**
     * 获取远程文件的大小
     *
     * param address
     * param path
     * param baseContext
     * param timeout
     * return
     * @throws Exception
     */
+(long)getRemoteFileSize:(NSString*) address path: (NSString*) path baseContext:(NSString*)baseContext   timeout:(int)timeout{
    
    
    
    //暂时这么写吧
    NSMutableString *sb=[NSMutableString new];
    [sb appendString:address];
    [sb appendString:@"/"];
    [sb appendString:HttpRequester.SERVICE_NAME];
    NSString *urlStr=[sb copy];
    urlStr= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"POST";
    NSString *body=[NSString stringWithFormat:@"app=getSize&path=%@&baseContext=%@",path,baseContext];
    //5,设置请求体
    request.HTTPBody=[body dataUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    __block  long fileSize=0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[[NSOperationQueue alloc]init]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if (!error) {
            NSString *res= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            fileSize= [res longLongValue];
        }else{
            
        }
        dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    
    return fileSize;
    
    
    

}

    /**
     * 获取远程文件的MD5值
     *
     * param address
     * param path
     * param baseContext
     * return
     * @throws Exception
     */
+(NSString*) getRemoteFileStamp:(NSString*) address path: (NSString*) path baseContext:(NSString*)baseContext   timeout:(int)timeout {
    
    
    
    //暂时这么写吧
    NSMutableString *sb=[NSMutableString new];
    [sb appendString:address];
    [sb appendString:@"/"];
    [sb appendString:HttpRequester.SERVICE_NAME];
   
    
    NSString *urlStr=[sb copy];
    urlStr= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"POST";
    NSString *body=[NSString stringWithFormat:@"app=getStamp&path=%@&baseContext=%@",path,baseContext];
    //5,设置请求体
    request.HTTPBody=[body dataUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    __block NSString* md5=0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[[NSOperationQueue alloc]init]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if (!error) {
            NSString *res= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            md5=res;
        }else{
            
        }
        dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    
    return md5;
    
    
    
    
    

}

    /**
     * 列举远程目录的MD5值
     *
     * param address
     * param path
     * param baseContext
     * param pathFormat
     * param timeout
     * return
     * throws Exception
     */
+(NSArray<NSString*>*) listRemoteFileStamps:(NSString*) address path: (NSString*) path baseContext:(NSString*)baseContext pathFormat:(NSString*)pathFormat timeout:(int)timeout {
  
    //暂时这么写吧
    NSMutableString *sb=[NSMutableString new];
    [sb appendString:address];
    [sb appendString:@"/"];
    [sb appendString:HttpRequester.SERVICE_NAME];
    
    
    NSString *urlStr=[sb copy];
    urlStr= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"POST";
    NSString *body=[NSString stringWithFormat:@"app=listStamp&path=%@&baseContext=%@&pathFormat=%@",path,baseContext,@"relative"];
    //5,设置请求体
    request.HTTPBody=[body dataUsingEncoding:NSUTF8StringEncoding];
    
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    __block  NSArray *items=nil;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[[NSOperationQueue alloc]init]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if (!error) {
             NSString *res= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             items=[res componentsSeparatedByString:HttpRequester.LINE_SPLITOR];
              
        }else{
            
        }
        dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    
    NSMutableArray *mulItems=[NSMutableArray arrayWithArray:items];
    if([[mulItems lastObject] isEqualToString:@""]){
        [mulItems removeLastObject];
    }
    return [mulItems copy];
    
}


/************************下载系列****************************/

    /**
     * 直接下载文件（不拼凑接口地址，就是不一定是自己的服务）
     *
     * param downloadAddress (下载地址)
     *  param savepath             (保存地址)
     * param timeout         (超时限制)
     */
+(BOOL) directDownloadInternal:(NSString*) downloadAddress savePath:(NSString*)savePath timeout:(int)timeout
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    // 1. 创建url
    NSString *urlStr =[NSString stringWithFormat:@"%@", downloadAddress];
     urlStr= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *Url = [NSURL URLWithString:urlStr];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:Url];
    
    // 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    __block BOOL isResult;
    NSURLSessionDownloadTask *downLoadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            // 下载成功
            // 注意 location是下载后的临时保存路径, 需要将它移动到需要保存的位置
            NSError *saveError;
            NSString *path=  [FoxFileManager directoryAtPath:savePath];
            if(![FoxFileManager isExistsAtPath:path]){
                [FoxFileManager createDirectoryAtPath:path];
            }
            NSURL *saveURL = [NSURL fileURLWithPath:savePath];
            
            [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveURL error:&saveError];
            //NSString *ff=location.path;
            //[[NSFileManager defaultManager] moveItemAtPath:location.path toPath:savePath error:&saveError];
            if (!saveError) {
                isResult=YES;
            } else {
                NSLog(@"error is %@", saveError.localizedDescription);
                 isResult=NO;
            }
        } else {
                 isResult=NO;
        }
         dispatch_semaphore_signal(semaphore);
    }];
    // 恢复线程, 启动任务
    [downLoadTask resume];

    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    return  isResult;
}

    /**
     * 直接下载文件
     *
     * param downloadAddress (下载地址)
     * param saveFile        (保存路径)
     * param timeout         (超时限制)
     */
+(BOOL) directDownload:(NSString*) downloadAddress saveFile:(NSString*)saveFile timeout:(int)timeout
{
       NSString *parent= [FoxFileManager directoryAtPath:downloadAddress];
    if([FoxFileManager isExistsAtPath:parent]==NO ){
        [FoxFileManager createDirectoryAtPath:parent];
    }
    
   return  [self  directDownloadInternal:downloadAddress savePath:saveFile timeout:timeout];
}
/**
 * 下载文件（从自己服务端下载）
 *
 * param address     (下载地址)
 * param path        (下载文件)
 * param saveFile    (保存路径)
 * param baseContext context(instant,workspace,configuration)
 * param timeout     (超时限制)
 */
+(BOOL) download:(NSString*) address path:(NSString*) path  saveFile:(NSString*)saveFile baseContext:(NSString*)baseContext timeout:(int)timeout{
    
    NSString *dirPath=  [FoxFileManager directoryAtPath:path];
    if(![FoxFileManager isExistsAtPath:dirPath]){
        [FoxFileManager createDirectoryAtPath:dirPath];
    }
    BOOL result=YES;
    result= [self downloadInternal:address path:path saveFile:saveFile baseContext:baseContext timeout:timeout];
    
    return result;
}

/**
 * 下载文件（从自己服务端下载）
 *
 * param address     (下载地址)
 * param path        (下载文件)
 * param baseContext context(instant,workspace,configuration)
 * param timeout     (超时限制)
 */
+(BOOL) downloadInternal:(NSString*) address path: (NSString*) path saveFile:(NSString*)saveFile baseContext:(NSString*)baseContext timeout:(int)timeout{
    
  
    NSMutableString *sb=[NSMutableString new];
    [sb appendString:address];
    [sb appendString:@"/"];
    [sb appendString:HttpRequester.SERVICE_NAME];
    
    
    NSString *urlStr=[sb copy];
    urlStr= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"POST";
    NSString *body=[NSString stringWithFormat:@"app=downloadFile&path=%@&baseContext=%@&checkValidity=%@",path,baseContext,@"true"];
    //5,设置请求体
    request.HTTPBody=[body dataUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    __block BOOL isResult=NO;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[[NSOperationQueue alloc]init]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        __block NSString *message=message;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        NSInteger resCode=httpResponse.statusCode;
        NSDictionary *headerDic=httpResponse.allHeaderFields;
        if(resCode!=200)
        {
            // 拼装异常消息
            NSMutableString *errorSb = [NSMutableString new];
            [errorSb appendString:@"resCode:"];
            [errorSb appendString: [NSString stringWithFormat:@"%ld", resCode]];
            [errorSb appendString: @" ,resMsg:"];
            [errorSb appendString:[NSString stringWithFormat:@"%@",error ]];
            NSString* errorMsg = [errorSb copy];
            message= errorMsg;
        }
        // 获取远程MD5
        NSString * remoteMD5 = headerDic[@"fileMD5"];
        // 计算内容MD5
        NSString* localMD5 = [MD5Util digestDataMD5:data];
        if (![localMD5 isEqualToString:remoteMD5]) {
            NSMutableString * errorSb = [NSMutableString new];
            [errorSb appendString:@"下载文件失败,文件["];
            [errorSb appendString:path];
            [errorSb appendString:@"]检验失败,remoteMD5:"];
            [errorSb appendString:remoteMD5];
            [errorSb appendString:@",localMD5:"];
            [errorSb appendString:localMD5];
            NSString *errorMsg = [errorSb copy];
            FOXLog(@"%@",errorMsg);
            isResult=NO;
        }
        
        NSString *contentEncoding =[httpResponse allHeaderFields][@"Content-Encoding"];
        
        // 如果对内容进行了压suo，则解压
        if (contentEncoding
            && [contentEncoding containsString:@"gzip"]) {
            data=[GZIPutil unzip:data];
        }
        if (!error) {
            [FoxFileManager createFileAtPath:saveFile];
            //写入文件
            [FoxFileManager writeFileAtPath:saveFile content:data];
            isResult=YES;
            
        }else{
            isResult=NO;
        }
        
        
        dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
    }];
    
    [task resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    return isResult;
    
}
/**
 * 批量下载文件（从自己服务端下载）
 *
 * param address           (下载地址)
 * param downloadDirectory (下载目录下)
 * param downloadFilePaths (下载目录下指定需要下载的文件路径)
 * param saveDir           (保存路径)
 * param baseContext       context(instant,workspace,configuration)
 * param checkValidity     (是否校验)
 */

+(BOOL) batchDownload:(NSString*) address downloadDirectory:(NSString*)downloadDirectory downloadFilePaths:(NSArray<NSString*>*)downloadFilePaths saveDir:(NSString*)saveDir baseContext:(NSString*)baseContext checkValidity:(BOOL)checkValidity timeout:(int)timeout{
    
    NSString *path=downloadDirectory;
   
    NSMutableString *pathSb=[NSMutableString new];
    for (int i = 0; i < downloadFilePaths.count; i++) {
        NSString *downPath=downloadFilePaths[i];
        downPath= [downPath stringByReplacingOccurrencesOfString:downloadDirectory withString:@""];
        downPath=[downPath stringByReplacingOccurrencesOfString:@"//" withString:@""];
        [pathSb appendString:downPath];
        if (i < downloadFilePaths.count - 1) {
            [pathSb appendString:HttpRequester.LINE_SPLITOR];
        }
    }
    NSString* includeFiles = [pathSb copy];
    includeFiles=[NSString stringWithFormat:@"[%@]",includeFiles ];
    //暂时这么写吧
    NSMutableString *sb=[NSMutableString new];
    [sb appendString:address];
    [sb appendString:@"/"];
    [sb appendString:HttpRequester.SERVICE_NAME];
    
    
    NSString * finalurlStr=[sb copy];
    finalurlStr= [finalurlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:finalurlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"POST";
    NSString *body=[NSString stringWithFormat:@"app=downloadFiles&path=%@&baseContext=%@&checkValidity=%@&includeFiles=%@",path,baseContext,@"true",includeFiles];
    
    request.HTTPBody=[body dataUsingEncoding:NSUTF8StringEncoding];
    NSString *tempFile= [self getTempFile:saveDir];
    NSString *parentDir= [FoxFileManager directoryAtPath:tempFile];
    if(![FoxFileManager isExistsAtPath:parentDir]){
        [FoxFileManager createDirectoryAtPath:parentDir];
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    __block BOOL isResult=NO;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[[NSOperationQueue alloc]init]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            __block NSString *message=message;
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            NSInteger resCode=httpResponse.statusCode;
            NSDictionary *headerDic=httpResponse.allHeaderFields;
            if(resCode!=200)
            {
                // 拼装异常消息
                NSMutableString *errorSb = [NSMutableString new];
                [errorSb appendString:@"resCode:"];
                [errorSb appendString: [NSString stringWithFormat:@"%ld", resCode]];
                [errorSb appendString: @" ,resMsg:"];
                [errorSb appendString:[NSString stringWithFormat:@"%@",error ]];
                NSString* errorMsg = [errorSb copy];
                message= errorMsg;
            }
            // 获取远程MD5
            NSString * remoteMD5 = headerDic[@"fileMD5"];
            // 计算内容MD5
            NSString* localMD5 = [MD5Util digestDataMD5:data];
            if (![localMD5 isEqualToString:remoteMD5]) {
                NSMutableString * errorSb = [NSMutableString new];
                [errorSb appendString:@"下载文件失败,文件["];
                [errorSb appendString:path];
                [errorSb appendString:@"]检验失败,remoteMD5:"];
                [errorSb appendString:remoteMD5];
                [errorSb appendString:@",localMD5:"];
                [errorSb appendString:localMD5];
                NSString *errorMsg = [errorSb copy];
                FOXLog(@"%@",errorMsg);
                isResult=NO;
            }
            
            if(data){
                [data writeToFile:tempFile atomically:YES];
                // 解压文件
                ZipArchive *unzip = [[ZipArchive alloc] init];
                if ([unzip UnzipOpenFile:tempFile]) {
                    
                    if(![FoxFileManager isExistsAtPath:saveDir]){
                        [FoxFileManager createDirectoryAtPath:saveDir];
                    }
                    BOOL success=   [unzip UnzipFileTo:saveDir  overWrite:YES];
                    FOXLog(@"解压结果:%@",success?@"成功":@"失败");
                    [unzip UnzipCloseFile];
                    
                }
                // 删除文件
                [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
                isResult=YES;
            }
            else{
                isResult=NO;
            }
            
            
        } else {
            FOXLog(@"error is %@", error.localizedDescription);
            isResult=NO;
        }
        
        dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
    }];
    
    [task resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    return isResult;
    
}
/**
 * 断点下载文件【和安卓一致】（从自己服务端下载）
 *
 * param address     (下载地址)
 * param path        (文件路径以程序的安装目录文起点路径)
 * param saveFile    (保存目录)
 * param baseContext context(instant,workspace,configuration)
 * param timeout
 * param callback
 */

+(BOOL) breakpointDownload:(NSString*) address path:(NSString*) path saveFile:(NSString*)saveFile baseContext:(NSString*)baseContext timeout:(int)timeout pageSize:(int)pageSize callback:(id<ICallBackDelegate>)callback{
    
    // 获取文件大小
    long remoteTotalSize =  [self getRemoteFileSize:address path:path baseContext:baseContext timeout:timeout];
    if (remoteTotalSize == -1) {
        FOXLog(@"%@",@"获取文件大小失败");
        return NO;
    }
    
    if (remoteTotalSize == 0) {
        // 通知下载完成情况
        if (callback != nil) {
            
            NSDictionary *data=@{@"index":@"0",@"totalCount":@"0"};
            [callback run:CallBackObject.SUCCESS message:@"" data:data];
        }
        return YES;
    }
    // 创建父亲目录
    NSString * parent = [FoxFileManager directoryAtPath:saveFile];
    if (![FoxFileManager isExistsAtPath:parent]) {
        [FoxFileManager createDirectoryAtPath:parent];
    }
    // 获取save file的路径
    NSString *saveFilePath = saveFile;
    // 获取页面记录文件
    NSString* pageRecordFile = [self getPageRecord:saveFilePath];
    //NSFileHandle
    // 定义页面记录文件访问器
    NSFileHandle* pageRecFileAccessor=nil;
    //=
    // 定义文件访问器
    NSFileHandle* tempFileAccessor =nil;
    //
    
    // page数量
    int pageCount = 0;
    // 总大小
    long totalSize = 0;
    
    NSData* marks = nil;
    BOOL reDownload = true;
    
    if ([FoxFileManager isExistsAtPath:pageRecordFile]) {//如果文件记录存在
        // 创建页面记录文件访问器
        pageRecFileAccessor = [NSFileHandle fileHandleForUpdatingAtPath:pageRecordFile];
        [pageRecFileAccessor seekToFileOffset:0];
        // 获取total size
        
        NSData *bytes=[pageRecFileAccessor readDataOfLength:8];
        totalSize = [ByteUtil byteArray2Long:(Byte*)bytes.bytes offset:0];
        
        if (remoteTotalSize == totalSize) {
            // 获取page size
            bytes= [pageRecFileAccessor readDataOfLength:4];
            pageSize =[ByteUtil byteArray2Int:(Byte*)bytes.bytes offset:0];
            pageCount = (int) (totalSize / pageSize);
            if (totalSize % pageSize > 0) {
                pageCount += 1;
            }
            
            // 获取下载完成标志
            marks = [pageRecFileAccessor readDataOfLength:pageCount];
            // 标志已经不用重新加载
            reDownload = false;
            
        } else {
            FOXLog(@"%@",@"服务器文件已经修改，重新下载");
            reDownload = true;
        }
    }
    if (reDownload) {
        // 获取文件大小
        totalSize = remoteTotalSize;
        
        // 如果page size为-1 默认5M
        if (pageSize == -1||pageSize == 0) {
            pageSize = 1024 * 1024 * 5;
        } else {
            // 把KB转换为B
            pageSize *= 1024;
        }
        
        pageCount = (int) (totalSize / pageSize);
        if (totalSize % pageSize > 0) {
            pageCount += 1;
        }
        //生成临时文件
        NSString *parentDir=  [FoxFileManager directoryAtPath:pageRecordFile];
        if(![FF isExistsAtPath:parentDir]){
            [FF createDirectoryAtPath:parentDir];
        }
        [FF createFileAtPath:pageRecordFile overwrite:YES];
        // 创建页面记录文件访问器
        pageRecFileAccessor = [NSFileHandle fileHandleForUpdatingAtPath:pageRecordFile];
        [pageRecFileAccessor seekToFileOffset:0];
        // 写入total size
        NSUInteger length;
        Byte* bytes = [ByteUtil long2byteArray:totalSize len:&length];
        NSData *data= [[NSData alloc] initWithBytes:bytes length:length];
        free(bytes);
        [pageRecFileAccessor writeData:data];
        
        // 写入page size
        bytes = [ByteUtil int2byteArray:pageSize len:&length];
        data= [[NSData alloc] initWithBytes:bytes length:length];
        free(bytes);
        // 写入下载是否完成标志
        Byte *bb=(Byte*)malloc(pageCount*sizeof(Byte));
        for(int i=0;i<pageCount;i++){
            bb[i]=0;
        }
        marks = [[NSData alloc] initWithBytes:bb length:8];
        [pageRecFileAccessor writeData:marks];
        free(bb);
    }
    @try {
        // 下载结果
        BOOL result = false;
        // 获取临时文件
        NSString* tempFile = [self getTempFile:saveFilePath];
        if(![FF isExistsAtPath:tempFile]){
            [FF createFileAtPath:tempFile];
        }
        
        // 创建临时文件访问器
        tempFileAccessor =[NSFileHandle fileHandleForUpdatingAtPath:tempFile];
        // 记录成功个数
        int successCount = 0;
        int i = 0;
        for (long index = 0; index < totalSize; index += pageSize, i++) {
            // 如果已经完成那么不再读取
            Byte * bMarks= (Byte*)[marks bytes];
            if (bMarks[i] == 1) {
                successCount++;
                continue;
            }
            // 定义
            long segmentSize = pageSize;
            // 修正segment size
            long remaining = totalSize - index;
            if (remaining < pageSize) {
                segmentSize = remaining;
            }
            // 获取内容
            NSData *content=[self downloadSegment:address path:path saveFile:saveFile baseContext:baseContext timeout:timeout index:index length:segmentSize];
            
            // 定位位置
            [tempFileAccessor seekToFileOffset:index];
            // 写入内容
            [tempFileAccessor writeData:content];
            
            // 定义标志位置
            [pageRecFileAccessor seekToFileOffset:i+12];
            // 写入成功标志
            bMarks[i] = 1;
            Byte tmpByte=1;
            NSData *tmpData=[[NSData alloc] initWithBytes:&tmpByte length:1];
            [pageRecFileAccessor writeData:tmpData];
            
            successCount++;
            
            // 判断是否成功下载
            if (successCount == pageCount) {
                // 关闭页面记录文件访问器
                [pageRecFileAccessor closeFile];
                pageRecFileAccessor = nil;
                
                // 关闭临时文件访问器
                [tempFileAccessor closeFile];
                tempFileAccessor = nil;
                // 删除页面下载情况记录文件
                result=[FoxFileManager removeItemAtPath:pageRecordFile];
                if (result) {
                    if([FoxFileManager isExistsAtPath:saveFilePath]){
                        [FoxFileManager removeItemAtPath:saveFilePath];
                    }
                    
                    [FoxFileManager moveItemAtPath:tempFile toPath:saveFilePath overwrite:YES];
                    
                }
            }
            
            // 通知下载完成情况
            if (callback != nil) {
                
                NSDictionary *data=@{@"index":@(successCount),@"totalCount":@(pageCount)};
                // 执行回调
                [callback run:CallBackObject.SUCCESS message:@"" data:data];
                
                
            }
        }
        
        if(tempFileAccessor){
            [tempFileAccessor closeFile];
            tempFileAccessor=nil;
        }
        if(pageRecFileAccessor){
            [pageRecFileAccessor closeFile];
            pageRecFileAccessor=nil;
        }
        
        return result;
    } @catch (NSException* e) {
        FOXLog(@"%@",e.description);
        if(tempFileAccessor){
            [tempFileAccessor closeFile];
            tempFileAccessor=nil;
        }
        if(pageRecFileAccessor){
            [pageRecFileAccessor closeFile];
            pageRecFileAccessor=nil;
        }
        
        if (callback != nil) {
            // 执行回调
            [callback run:CallBackObject.ERROR message:e.description data:@""];
            return NO;
        }
       
    }
    
    
    
}

/**
 * 下载文件片段（从自己服务端下载）
 *
 * param address
 * param path
 * param saveFile
 * param baseContext
 * param timeout
 * param index
 * param length
 * return
 * throws Exception
 */
+(NSData*) downloadSegment:(NSString*) address path:(NSString*) path saveFile:(NSString*)saveFile baseContext:(NSString*)baseContext timeout:(int)timeout index:(long)index length:(long) length
{
    // 判断范围是否合法
    if (index < 0 || length <= 0) {
        return nil;
    }
    NSMutableString *sb=[NSMutableString new];
    [sb appendString:address];
    [sb appendString:@"/"];
    [sb appendString:HttpRequester.SERVICE_NAME];
    
    
    NSString *urlStr=[sb copy];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"POST";
    NSString *body=[NSString   stringWithFormat:@"app=pagingDownloadFile&path=%@&baseContext=%@&checkValidity=true&index=%ld&length=%ld",path,baseContext,index,length];
    //5,设置请求体
    request.HTTPBody=[body dataUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    __block NSData *outData=nil;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[[NSOperationQueue alloc]init]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __block NSString *message=@"";
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        NSInteger resCode=httpResponse.statusCode;
        NSDictionary *headerDic=httpResponse.allHeaderFields;
        if (!error) {
            if(resCode!=200)
            {
                // 拼装异常消息
                NSMutableString *errorSb = [NSMutableString new];
                [errorSb appendString:@"resCode:"];
                [errorSb appendString: [NSString stringWithFormat:@"%ld", resCode]];
                [errorSb appendString: @" ,resMsg:"];
                [errorSb appendString:[NSString stringWithFormat:@"%@",error ]];
                NSString* errorMsg = [errorSb copy];
                message= nil;
                FOXLog(@"%@",errorMsg);
                outData=nil;
            }
            
            
            // 获取远程MD5
            NSString * remoteMD5 = headerDic[@"fileMD5"];
            // 计算内容MD5
            NSString* localMD5 = [MD5Util digestDataMD5:data];
            if (![localMD5 isEqualToString:remoteMD5]) {
                NSMutableString * errorSb = [NSMutableString new];
                [errorSb appendString:@"下载文件失败,文件["];
                [errorSb appendString:path];
                [errorSb appendString:@"]检验失败,remoteMD5:"];
                [errorSb appendString:remoteMD5];
                [errorSb appendString:@",localMD5:"];
                [errorSb appendString:localMD5];
                NSString *errorMsg = [errorSb copy];
                FOXLog(@"%@",errorMsg);
                outData=nil;
            }
            
            NSString *contentEncoding =[httpResponse allHeaderFields][@"Content-Encoding"];
            
            // 如果对内容进行了压suo，则解压
            if (contentEncoding
                && [contentEncoding containsString:@"gzip"]) {
                // 解压suo
                data= [GZIPutil unzip:data];
            }
            outData= data;
        }
        else{
            
            FOXLog(@"%@",error);
            outData= nil;
           
        }
         dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
        
        
    }];
    
    [task resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待60秒
    return outData;
}


/************************文件上传系列******************************/

    /**
     * 上传文件
     *
     * param address    (上传地址)
     * param savePath   (文件保存路径)
     * param uploadFile (上传文件)
     * param timeout    (超时限制)
     */
+(NSString*) directUpload:(NSString*) address savePath:(NSString*) savePath fileName:(NSString*)fileName uploadFile:(NSString*)uploadFile timeout:(int)timeout{
    //标志是否上传文件夹
    BOOL isUploadDir=false;
    
    //记录待上传文件
    NSString * file=nil;
    if(![FoxFileManager isExistsAtPath:uploadFile] ){
        return @"上传文件不存在";
    }
    
    if([FoxFileManager isDirectoryAtPath:uploadFile] ){
        file= [self getZipFile:uploadFile];
        //压suo
        [GZIPutil doZipAtPath:uploadFile to:file];
        //标志为目录上传
        isUploadDir=true;
    }else{
        file=uploadFile;
    }
    //获取文件名
    if(!fileName||fileName.length==0){
        fileName= [FoxFileManager fileNameAtPath:file suffix:YES];
    }
    NSString * result= [self directUploadInternal:address savePath:savePath fileName:fileName uploadFile:file timeout:timeout];
    [FoxFileManager removeItemAtPath:file];
    
    return result;
}

    /**
     * 上传文件不一定从自己服务器上传
     *
     * param address  (上传地址)
     * param savePath (文件保存路径)
     * param
     * param timeout  (超时限制)
     */
+(NSString*) directUploadInternal:(NSString*) address  savePath:(NSString*) savePath fileName:
(NSString*) fileName uploadFile:(NSString*)uploadFile timeout:(int) timeout  {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    // 请求URL;
    NSString *urlStr = address;
    urlStr=[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
   
     HttpURLClient *client=[[HttpURLClient alloc] init:urlStr];
    
    // 请求数据
    NSMutableArray<FormEntry*>*formEntrys=[NSMutableArray<FormEntry*> new];
    
    FormEntry* formEntrys0 = [[FormEntry alloc] init:@"app" text:@"uploadFile" contentType:@"text/plain"];
    
    FormEntry*formEntrys1 =[[FormEntry alloc] init:@"savePath" text:savePath contentType:@"text/plain"];
    
    FormEntry*formEntrys2 =[[FormEntry alloc] init:@"fileName" text:fileName contentType:@"text/plain"];
    [formEntrys addObject:formEntrys0];
    [formEntrys addObject:formEntrys1];
    [formEntrys addObject:formEntrys2];
    NSData *content= [NSData dataWithContentsOfFile:uploadFile];
    
    FormEntry*  formEntrys3 = [[FormEntry alloc] init:@"file" fileName:fileName data:content contentType:@"application/octet-stream"];
    
    [formEntrys addObject:formEntrys3];
    [client setrequestMethod:@"POST"];
    NSURL* tempURL=[NSURL URLWithString:address];
    if(!tempURL){
        return @"address 地址不正确";
    }
    NSString *host =tempURL.host;
    //约定俗称的请求头
    [client setRequestProperty:@"Host" value:host];
    [client setRequestProperty:@"Connection" value: @"keep-alive"];
    [client setRequestProperty:@"Accept" value:
     @"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"];
    [client setRequestProperty:@"User-Agent" value:@"Fox"];
    [client setRequestProperty:@"Accept-Encoding" value: @"gzip"];
    [client setRequestProperty:@"Connection" value:@"keep-alive"];
    [client setRequestProperty:@"Accept-Language" value:@"zh-CN,zh;q=0.8,en;q=0.6"];
    [client setRequestProperty:@"Content-Type" value:
     @"application/x-wwww-form-urlencoded"];
    // 客户端IP
    NSString *clientIP=nil;
    // 获取客户端IP
    clientIP =@"127.0.0.1";
    // 设置客户端IP
    [client setRequestProperty:@"Phe-Client-IP" value:clientIP];
    
    
    NSURLRequest *request= [client getRequestToHttpServer:formEntrys];
    
    __block NSString *message=@"";
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[[NSOperationQueue alloc]init]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if([data isKindOfClass:[NSDictionary class]]){
            int i=0;
        }
        else{
           
            int ii=0;
        }
        
        if (error) {
            message=[NSString stringWithFormat:@"error is %@",error.localizedDescription ];
            FOXLog(@"error is %@",error.localizedDescription);
        }
        else{
           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            NSInteger resCode=httpResponse.statusCode;
          if(resCode!=200)
          {
              // 拼装异常消息
              NSMutableString *errorSb = [NSMutableString new];
              [errorSb appendString:@"resCode:"];
              [errorSb appendString: [NSString stringWithFormat:@"%ld", resCode]];
             [errorSb appendString: @" ,resMsg:"];
             [errorSb appendString:[NSString stringWithFormat:@"%@",error ]];
              if(data){
                  [errorSb appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
              }
              NSString* errorMsg = [errorSb copy];
              message= errorMsg;
          }
          NSString *contentEncoding =[httpResponse allHeaderFields][@"Content-Encoding"];
           
            // 如果对内容进行了压suo，则解压
              if (contentEncoding
                && [contentEncoding containsString:@"gzip"]) {
                // 解压suo
                {
                    data= [GZIPutil unzip:data];
                }
            
                message=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         }
         dispatch_semaphore_signal(semaphore);
        }
        
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    return message;

}





    /**
     * 上传文件（从自己服务器上传）
     *
     * param address     (上传地址)
     * param savePath    (文件保存路径)
     * param uploadFile  (上传文件)
     * param baseContext context(instant,workspace,configuration)
     * param timeout     (超时限制)
     */
+(BOOL) upload:(NSString*) address savePath:(NSString*) savePath fileName:(NSString*)fileName uploadFile:(NSString*)uploadFile baseContext:(NSString*)baseContext timeout:(int)timeout
{
    //标志是否上传文件夹
    BOOL isUploadDir=false;
    //记录待上传文件
    NSString * file=nil;
    if([FoxFileManager isDirectoryAtPath:uploadFile]){
        file= [self getZipFile:uploadFile];
        //压suo
        [GZIPutil doZipAtPath:uploadFile to:file];
        //标志为目录上传
        isUploadDir=true;
    }else{
        file=uploadFile;
    }
    // 文件不存在，不作处理
    if (file == nil || ![FoxFileManager isFileAtPath:uploadFile] ) {
        return NO;
    }
    // 获取文件名称
    if (fileName == nil || fileName.length == 0) {
        fileName = [FoxFileManager fileNameAtPath:uploadFile suffix:YES];
    }
    
     BOOL result= [self uploadInternal:address savePath:savePath fileName:fileName uploadFile:file baseContext:baseContext timeout:timeout];
   
        if(isUploadDir){
            [FoxFileManager removeItemAtPath:file];
        }
        return result;
  
}

    /**
     * 上传文件（从自己服务器上传）
     *
     * param address     (上传地址)
     * param savePath    (文件保存路径)
     * param         (输入流)
     * param baseContext context(instant,workspace,configuration)
     * param timeout     (超时限制)
     */
+(BOOL) uploadInternal:(NSString*) address savePath: (NSString*) savePath fileName:(NSString*)fileName uploadFile:(NSString*)uploadFile baseContext:(NSString*)baseContext timeout:(int)timeout{
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    // 请求URL;
    
    NSMutableString *sb=[NSMutableString new];
    [sb appendString:address];
    [sb appendString:@"/"];
    [sb appendString:HttpRequester.SERVICE_NAME];
    
    NSString *urlStr = [sb copy];
    urlStr=[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
  
    HttpURLClient *client=[[HttpURLClient alloc] init:urlStr];
    // 请求数据
    NSMutableArray<FormEntry*>*formEntrys=[NSMutableArray<FormEntry*> new];
    
    FormEntry* formEntrys0 = [[FormEntry alloc] init:@"app" text:@"uploadFile" contentType:@"text/plain"];
    
    FormEntry*formEntrys1 =[[FormEntry alloc] init:@"savePath" text: savePath contentType:@"text/plain"];
    
    FormEntry*formEntrys2 =[[FormEntry alloc] init:@"fileName" text:fileName contentType:@"text/plain"];
    
    FormEntry*formEntrys3 =[[FormEntry alloc] init:@"baseContext" text:baseContext contentType:@"text/plain"];
    
    FormEntry*formEntrys4 =[[FormEntry alloc] init:@"checkValidity" text:@"true" contentType:@"text/plain"];
    
    [formEntrys addObject:formEntrys0];
    [formEntrys addObject:formEntrys1];
    [formEntrys addObject:formEntrys2];
    [formEntrys addObject:formEntrys3];
    [formEntrys addObject:formEntrys4];
    
    NSData *content=[NSData dataWithContentsOfFile:uploadFile];
    
    FormEntry*  formEntrys5 = [[FormEntry alloc] init:@"file" fileName:fileName data:content contentType:@"application/octet-stream"];
    
    [formEntrys addObject:formEntrys5];
    
    [client setrequestMethod:@"POST"];
    
    
    NSString *host =address;
    //约定俗称的请求头
    [client setRequestProperty:@"Host" value:host];
    [client setRequestProperty:@"Connection" value: @"keep-alive"];
    [client setRequestProperty:@"Accept" value:
     @"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"];
    [client setRequestProperty:@"User-Agent" value:@"Fox"];
    [client setRequestProperty:@"Accept-Encoding" value: @"gzip"];
    [client setRequestProperty:@"Connection" value:@"keep-alive"];
    [client setRequestProperty:@"Accept-Language" value:@"zh-CN,zh;q=0.8,en;q=0.6"];
    [client setRequestProperty:@"Content-Type" value:
     @"application/x-wwww-form-urlencoded"];
    
    // 客户端IP
    NSString *clientIP=nil;
    // 获取客户端IP
    clientIP =@"127.0.0.1";
    // 设置客户端IP
    [client setRequestProperty:@"Phe-Client-IP" value:clientIP];
    
    
   NSURLRequest *request= [client getRequestToHttpServer:formEntrys];
   __block NSString *message=@"";
   NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[[NSOperationQueue alloc]init]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            message=[NSString stringWithFormat:@"error is %@",error.localizedDescription ];
            FOXLog(@"error is %@",error.localizedDescription);
        }
        else{
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            NSInteger resCode=httpResponse.statusCode;
            if(resCode!=200)
            {
                // 拼装异常消息
                NSMutableString *errorSb = [NSMutableString new];
                [errorSb appendString:@"resCode:"];
                [errorSb appendString: [NSString stringWithFormat:@"%ld", resCode]];
                [errorSb appendString: @" ,resMsg:"];
                message= [errorSb copy];
            }
            NSString *contentEncoding =[httpResponse allHeaderFields][@"Content-Encoding"];
            
           
            if (contentEncoding
                && [contentEncoding containsString:@"gzip"]) {
                // 解压suo
                 data= [GZIPutil unzip:data];
            }
            //暂时这么写，responseObject 是什么
            message= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
          dispatch_semaphore_signal(semaphore);
        
     }];
    [task resume];
 
    
  
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
    
    
    return ([message isEqualToString:@"true"]);
    
}





    /**
     * 断点上传文件
     *
     * param address
     * param uploadPath
     * param fileName
     * param uploadFile
     * param baseContext
     * param timeout
     * param pageSize
     * param callback
     * return
     * @throws Exception
     */
+(BOOL) breakpointUpload:(NSString*) address uploadPath: (NSString*) uploadPath fileName:(NSString*)fileName uploadFile:(NSString*)uploadFile baseContext:(NSString*)baseContext timeout:(int)timeout pageSize:(int)pageSize callback:(id<ICallBackDelegate>)callback{
    
    //标志是否上传文件夹
    BOOL isUploadDir=false;
    
    //记录待上传文件
    NSString * file=nil;
  
    if([FoxFileManager isDirectoryAtPath:uploadFile] ){
        file= [self getZipFile:uploadFile];
        //压suo
        [GZIPutil doZipAtPath:uploadFile to:file];
        //标志为目录上传
        isUploadDir=true;
    }else{
        file=uploadFile;
    }
    
    //test zip
   // file =[[NSBundle mainBundle] pathForResource:@"test" ofType:@"zip"];
    
    if(![FoxFileManager isExistsAtPath:uploadFile] ){
        FOXLog(@"文件%@不存在",uploadFile);
        return NO;
    }
    //获取文件名
    if(!fileName||fileName.length==0){
        fileName= [FoxFileManager fileNameAtPath:file suffix:YES];
    }
    
    // 获取文件大小
    long totalSize = [[FoxFileManager sizeOfFileAtPath:file] longValue];
    // 获取页面记录文件
    NSString* pageRecordFile = [self getPageRecord:file];

    // 定义页面记录文件访问器
    NSFileHandle* pageRecFileAccessor=nil;
    //=
    // 定义文件上传访问器
    NSFileHandle* uploadFileAccessor =nil;

    // page数量
    int pageCount = 0;
    // 上传文件情况标志
    NSData* marks = nil;
    // 判断文件是否
    BOOL isNew = true;
    if ( [FF isExistsAtPath:pageRecordFile]) {
        // 创建页面记录文件访问器
        pageRecFileAccessor = [NSFileHandle fileHandleForUpdatingAtPath:pageRecordFile];
        [pageRecFileAccessor seekToFileOffset:0];
        // 获取total size
        NSData *bytes=[pageRecFileAccessor readDataOfLength:8];
        
        long size = [ByteUtil byteArray2Long:(Byte*)bytes.bytes offset:0];
        
        if (size == totalSize) {
            // 获取page size
        bytes=[pageRecFileAccessor readDataOfLength:4];//记录目前保存的大小
        pageSize = [ByteUtil byteArray2Int:(Byte*)bytes.bytes offset:0];
            
            pageCount = (int) (totalSize / pageSize);
            if (totalSize % pageSize > 0) {
                pageCount += 1;
            }
            
            //上传完成的标志
            marks = [pageRecFileAccessor readDataOfLength:pageCount];
           
            // 标志已经不用重新上传
            isNew = false;
            
        } else {
            FOXLog(@"%@",@"服务器文件已经修改，重新上传");
            // 标志需要重新上传
            isNew = true;
        }
    }
    if (isNew) {
        // 如果page size为-1 默认5M
        if (pageSize == -1||pageSize==0) {
            pageSize = 1024 * 1024 * 5;//单位字节
        } else {
            // 把KB转换为B
            pageSize *= 1024;
        }
        
        pageCount = (int) (totalSize / pageSize);
        if (totalSize % pageSize > 0) {
            pageCount += 1;
        }
        
        if(![FF isExistsAtPath:pageRecordFile]){
            NSString *_parnet=[FF directoryAtPath:pageRecordFile];
            if(![FF isExistsAtPath:_parnet]){
                [FF createDirectoryAtPath:_parnet];
            }
            [FF createFileAtPath:pageRecordFile];
        }
        
        // 创建页面记录文件访问器
        pageRecFileAccessor = [NSFileHandle fileHandleForUpdatingAtPath:pageRecordFile];
        [pageRecFileAccessor seekToFileOffset:0];
        // 写入total size
        NSUInteger length;
        Byte* bytes = [ByteUtil long2byteArray:totalSize len:&length];
        NSData *data= [[NSData alloc] initWithBytes:bytes length:length];
        free(bytes);
        [pageRecFileAccessor writeData:data];
        
        // 写入page size
        bytes = [ByteUtil int2byteArray:pageSize len:&length];
        data= [[NSData alloc] initWithBytes:bytes length:length];
        free(bytes);
        // 写入上传是否完成标志
        //写入是否上传完成标志，marks是个数组，有pageCount个标志位，下载完一个标志一个
        Byte *bb=(Byte*)malloc(pageCount*sizeof(Byte));
        for(int i=0;i<pageCount;i++){
            bb[i]=0;
        }
        marks = [[NSData alloc] initWithBytes:bb length:8];
        [pageRecFileAccessor writeData:marks];
        free(bb);
    }
        @try {
            // 上传结果
            BOOL result = false;
            
            
          
            
            
            
             // 创建上传文件访问器
            uploadFileAccessor = [NSFileHandle fileHandleForUpdatingAtPath:file];
            // 记录成功个数
            int successCount = 0;
            int i = 0;
            for (long index = 0; index < totalSize; index += pageSize, i++) {
                // 如果已经完成那么不再读取
                Byte * bMarks= (Byte*)[marks bytes];
                if (bMarks[i] == 1) {//标志为1，表示成功
                    successCount++;
                    continue;
                }
                // 定义
                long segmentSize = pageSize;//每片大小位pageSize
                // 修正segment size
                long remaining = totalSize - index;
                if (remaining < pageSize) {
                    segmentSize = remaining;
                }
                
             // 读取内容
               NSData *content = [uploadFileAccessor readDataOfLength:segmentSize];
                 // 上传文件片段
                [self uploadSegment:address path:uploadPath fileName:fileName content:content index:index length:segmentSize baseContext:baseContext timeout:timeout];
                
                 // 定义标志位置
                [pageRecFileAccessor seekToFileOffset:(i+12)];//前面有一个记录8位和4位的字节，所以加12
                // 写入成功标志
                bMarks[i] = 1;
                Byte tmpByte=1;
                NSData *tmpData=[[NSData alloc] initWithBytes:&tmpByte length:1];
                [pageRecFileAccessor writeData:tmpData];
                
                successCount++;
                
                // 判断是否成功下载
                if (successCount == pageCount) {
                    // 关闭页面记录文件访问器
                    [pageRecFileAccessor closeFile];
                    pageRecFileAccessor=nil;
                    
                    // 关闭临时文件访问器
                    [uploadFileAccessor closeFile];
                    uploadFileAccessor=nil;
                  
                    // 删除页面下载情况记录文件
                     result = [FF removeItemAtPath:pageRecordFile];
                }
                
                // 通知下载完成情况
                if (callback != nil) {
                    NSDictionary *data=@{@"index":@(successCount),@"totalCount":@(pageCount)};
                    
                        // 执行回调
                    [callback run:CallBackObject.SUCCESS message:@"" data:data];
                }
            }
            
            // 关闭文件流
            if(pageRecFileAccessor){
                [pageRecFileAccessor closeFile];
                pageRecFileAccessor=nil;
            }
            // 关闭文件流
            if (uploadFileAccessor) {
                [uploadFileAccessor closeFile];
                uploadFileAccessor=nil;
            }
            
            
            if(isUploadDir){
                [FF removeItemAtPath:file];
            }
            return result;
        } @catch (NSException* e) {
            FOXLog(@"%@",e);
            // 错误回调
            if (callback !=nil) {
                [callback run:CallBackObject.ERROR message:e.description data:@""];
                
            }
            // 关闭文件流
            if(pageRecFileAccessor){
                [pageRecFileAccessor closeFile];
                pageRecFileAccessor=nil;
            }
            // 关闭文件流
            if (uploadFileAccessor) {
                [uploadFileAccessor closeFile];
                uploadFileAccessor=nil;
            }
            
            return NO;
        }
    
        
    
}

    /**
     * 上传文件片段
     *
     * param address
     * param path
     * param fileName
     * param content
     * param index
     * param length
     * param baseContext
     * param timeout
     * return
     * @throws Exception
     */
+(BOOL) uploadSegment:(NSString*) address path:(NSString*) path fileName:(NSString*)fileName content:(NSData*)content index:(long)index length:(long)length baseContext:(NSString*)baseContext timeout:(long)timeout {
    
    // 判断范围是否合法
    if (index < 0 || length <= 0) {
        return false;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
   
   
    
    NSMutableString *sb=[NSMutableString new];
    [sb appendString:address];
    [sb appendString:@"/"];
    [sb appendString:HttpRequester.SERVICE_NAME];
    
    NSString *urlStr = [sb copy];
    [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
   
    
    HttpURLClient *client=[[HttpURLClient alloc] init:urlStr];
    
    
    // 请求数据
    NSMutableArray<FormEntry*>*formEntrys=[NSMutableArray<FormEntry*> new];
    
    FormEntry* formEntrys0 = [[FormEntry alloc] init:@"app" text:@"pagingUploadFile" contentType:@"text/plain"];
    
    FormEntry*formEntrys1 =[[FormEntry alloc] init:@"savePath" text:path contentType:@"text/plain"];
    
    FormEntry*formEntrys2 =[[FormEntry alloc] init:@"fileName" text:fileName contentType:@"text/plain"];
    
    FormEntry*formEntrys3 =[[FormEntry alloc] init:@"baseContext" text:baseContext contentType:@"text/plain"];
    
    FormEntry*formEntrys4 =[[FormEntry alloc] init:@"checkValidity" text:@"true" contentType:@"text/plain"];
    FormEntry*formEntrys5 =[[FormEntry alloc] init:@"index" text:[NSString stringWithFormat:@"%ld",index] contentType:@"text/plain"];
    FormEntry*formEntrys6 =[[FormEntry alloc] init:@"length" text:[NSString stringWithFormat:@"%ld",length] contentType:@"text/plain"];
    
    [formEntrys addObject:formEntrys0];
    [formEntrys addObject:formEntrys1];
    [formEntrys addObject:formEntrys2];
    [formEntrys addObject:formEntrys3];
    [formEntrys addObject:formEntrys4];
    [formEntrys addObject:formEntrys5];
    [formEntrys addObject:formEntrys6];
    
    
     FormEntry*  formEntrys7 = [[FormEntry alloc] init:@"file" fileName:fileName data:content contentType:@"application/octet-stream"];
    
    [formEntrys addObject:formEntrys7];
    
    [client setrequestMethod:@"POST"];
    
    NSString *host =address;
    //约定俗称的请求头
    [client setRequestProperty:@"Host" value:host];
    [client setRequestProperty:@"Connection" value: @"keep-alive"];
    [client setRequestProperty:@"Accept" value:
     @"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"];
    [client setRequestProperty:@"User-Agent" value:@"Fox"];
    [client setRequestProperty:@"Accept-Encoding" value: @"gzip"];
    [client setRequestProperty:@"Connection" value:@"keep-alive"];
    [client setRequestProperty:@"Accept-Language" value:@"zh-CN,zh;q=0.8,en;q=0.6"];
    [client setRequestProperty:@"Content-Type" value:
     @"application/x-wwww-form-urlencoded"];
    // 客户端IP
    NSString *clientIP=nil;
    // 获取客户端IP
    clientIP =@"127.0.0.1";
    // 设置客户端IP
    [client setRequestProperty:@"Phe-Client-IP" value:clientIP];
    
    
     NSURLRequest *request= [client getRequestToHttpServer:formEntrys];
    
    __block NSString *message=@"";
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[[NSOperationQueue alloc]init]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            message=[NSString stringWithFormat:@"error is %@",error.localizedDescription ];
            FOXLog(@"error is %@",error.localizedDescription);
        }
        else{
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            NSInteger resCode=httpResponse.statusCode;
            if(resCode!=200)
            {
                // 拼装异常消息
                NSMutableString *errorSb = [NSMutableString new];
                [errorSb appendString:@"resCode:"];
                [errorSb appendString: [NSString stringWithFormat:@"%ld", resCode]];
                [errorSb appendString: @" ,resMsg:"];
                message= [errorSb copy];
            }
            NSString *contentEncoding =[httpResponse allHeaderFields][@"Content-Encoding"];
            
            
            if (contentEncoding
                && [contentEncoding containsString:@"gzip"]) {
                // 解压suo
                data= [GZIPutil unzip:data];
            }
           
            message= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        dispatch_semaphore_signal(semaphore);
        
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
    
    return ([message isEqualToString:@"true"]);
   
}





@end
