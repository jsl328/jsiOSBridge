//
//  HttpURLClient.m
//  SimpleNetworkStreams
//
//  Created by BruceXu on 2018/4/17.
//

#import "HttpURLClient.h"
#import "FormEntry.h"

#import "Trigger.h"
#import "FormEntry.h"
@interface HttpURLClient(){
    NSURL *url__;
    NSMutableData *mulData;
}

/**
 * URL
 */
@property(copy)NSString *url;

/**
 * host
 */
@property(copy)NSString * host;





/**
 * 请求头
 */
@property(strong)NSMutableDictionary<NSString*, NSString*> *requestHeaders;

/**
 * 响应头
 */
@property(strong)NSMutableDictionary<NSString*, NSString*> * responseHeaders ;


/**
 * path
 */
@property(copy) NSString * path ;//= @"/";
/**
 * port
 */
@property int port;// = 80;

/**
 * protocol
 */
@property(copy) NSString *protocol;// = @"http";

/**
 * 连接超时(毫秒)
 */
@property int timeout ;//= 1000*60*5;

/**
 * 默认编码
 */
@property(copy) NSString* encoding ;//= @"UTF-8";
/**
 * 是否为SSL连接
 */
@property BOOL sslConnection ;//= NO;
/**
 * 请求方法
 */
@property(copy) NSString* requestMethod;// = @"GET";
/**
 * 响应编码
 */
@property(copy) NSString* responseContentEncoding ;//= @"UTF-8";
/**
 * 设置请求内容长度
 */
@property int requestContentLength ;//= -1;
/**
 * 是否发生HTTP头
 */
@property BOOL isSendHeader ;//= NO;
/**
 * 种子
 */
@property(assign) long seed ;//= 0;

@property(assign) int callbackTime ;//= 2;
/**
 * 响应码
 */
@property int responseCode;
@end
@implementation HttpURLClient

/**
 * HTTP请求内容形式(上传文件方式)
 */
static NSString* MULTIPATR_FORM = @"multipart/form-data";
/**
 * HTTP请求内容形式(普通表单)
 */
static NSString* APPLICATION_FORM = @"application/x-wwww-form-urlencoded";
/**
 * 网络缓存大小
 */
static int NET_BUFFER_SIZE = 4096;

/**
 * 默认超时时间
 */
static int DEFAULT_TIMEOUT = 500;

-(id)init{
    if(self=[super init]){
        self.timeout = DEFAULT_TIMEOUT;
        self.encoding = @"UTF-8";
        
        self.path = @"/";
        self.port = 80;
        
        self.protocol = @"http";
        
        self.timeout = 1000*60*5;
        self.sslConnection = NO;
        self.requestMethod = @"GET";
        self.responseContentEncoding = @"UTF-8";
        self.requestContentLength = -1;
        self.isSendHeader = NO;
        self.seed = 0;
        _callbackTime=0;
        mulData=[NSMutableData new];
        
        _requestHeaders=[NSMutableDictionary<NSString*, NSString*> new];
        _responseHeaders=[NSMutableDictionary<NSString*, NSString*> new];
      
    }
    return self;
}
-(id)init:(NSString*)url_{
    self=[self init];
    self.url=url_;
    
    if(_url&&_url.length){
        
    url__=[NSURL URLWithString:url_];
        
        
    // 设置host
    NSString* host = [url__ host];
    if (host != nil) {
        self.host = [host lowercaseString];
    }
    
    // 设置path
    NSString* path = url__.path;
    if (path != nil) {
        self.path = path;
    }
    
    // 设置port
    int port = [url__.port intValue];
    if (port != -1) {
        self.port = port;
    }
    
    // 设置protocol
    NSString* protocol = url__.scheme;
    if (protocol != nil) {
        self.protocol = protocol;
    }
}
    return self;
}

/**
 * 判断是否为SSL连接
 *
 * return
 */
-(BOOL) isSSLConnection {
    return self.sslConnection;
}
/**
 * 设置请求方法
 *
 * param requestMethod
 */
-(void) setrequestMethod:(NSString*) requestMethod {
    self.requestMethod = requestMethod;
}

/**
 * 获取请求方法
 *
 * return
 */
-(NSString*) getRequestMethod {
    return self.requestMethod;
}

/**
 * 获取响应码
 *
 * return
 */
-(int) getResponseCode {
    return self.responseCode;
}

/**
 * 设置请求头属性
 *
 * param key
 * param value
 */
-(void) setRequestProperty:(NSString*) key value: (NSString*) value {
    [self.requestHeaders setObject:value forKey:key];
}

/**
 * 获取请求头属性
 *
 * param key
 * return
 */
-(NSString*) getRequestProperty:(NSString*) key {
    NSString* value =self.requestHeaders[key];
    return value;
}

/**
 * 设置响应头属性
 *
 * param key
 * param value
 */
-( void) setResponseProperty:(NSString*) key value: (NSString*) value{
    [self.responseHeaders setObject:value forKey:key];
}

/**
 * 获取响应头属性
 *
 * param key
 * return
 */
-(NSString*) getResponseProperty:(NSString*) key {
    NSString* value = self.responseHeaders[key];
    return value;
}

/**
 * 获取响应内容编码
 *
 * return
 */
-(NSString*) getresponseContentEncoding {
    return self.responseContentEncoding;
}

/**
 * 设置请求内容长度
 *
 * param requestContentLength
 */
-(void) setrequestContentLength:(int) requestContentLength {
    self.requestContentLength = requestContentLength;
}

 





-(NSData*)read{
    NSMutableData *byteOut=[NSMutableData new];
    // 响应action
    NSString* responseAction = @"";
    // 定义触发器
    Trigger* headerSplitorTrigger = [[Trigger alloc] init:Trigger.HEADER_SPLITOR];
    
    // 分割索引
    int splitIndex = -1;
    // 内容长度
    long contentLength = -1;
    // 内容传输方式
    NSString* transferEncoding = nil;
    // 判断响应头是否解析
    BOOL parseHeader = NO;
    
    int len = -1;
    Byte *buffer = (Byte*)malloc(sizeof(Byte)*NET_BUFFER_SIZE);
    
   
    //Byte *dataByte = (Byte *)[data bytes];
    int totalLength=(int)(mulData.length);
    int curIndex=0;
    int singleLength=NET_BUFFER_SIZE;
    int curMaxLength=mulData.length;
    while (totalLength>0) {
       totalLength-=singleLength;
        if(totalLength<=0){
            totalLength=0;
            curMaxLength=mulData.length;
        }
        else{
            curMaxLength=singleLength;
        }
       NSData*subData=[mulData subdataWithRange:NSMakeRange(curIndex, curMaxLength)];
        curIndex+=singleLength;
        // 试图查找响应头的分割索引
        if (splitIndex == -1) {
            // 查找报文头分割符
            int index = [headerSplitorTrigger trigger:subData offset:0 length:len];//0-len之间找出第一个\r\n\r\n的索引,这个下面就是内容体
            
            if (index != -1) {
                // 记录报文头分割索引
                splitIndex = (int)(index + byteOut.length);//index加上之前byteout的字节数为 最终的\r\n的索引
            }
        }
        //写入数据
        [byteOut appendData:subData];
       
        if (splitIndex != -1) {//找到了分隔符
            if (!parseHeader) {
                // 获取头内容
                //0 到 splitIndex+1 之间 是头部内容,就是消息头的全部东西
              NSData *dd= [subData subdataWithRange:NSMakeRange(0, splitIndex + 1)];
               NSString *s= [[NSString alloc] initWithData:dd encoding:NSUTF8StringEncoding];
                
                NSArray* ss = [s componentsSeparatedByString:@"\r\n"];
                // 保存响应action
                responseAction = ss[0];
                for (int j = 1; j < ss.count; j++) {
                    NSString *st=ss[j];
                    st = [st stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if (st.length == 0) {
                        continue;
                    }
                    NSArray *stArr= [st componentsSeparatedByString:@":"];
                    if(stArr.count<2){
                        continue;
                    }
                    NSString* propKey = [stArr[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSString* propValue = [stArr[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    // 保存内容长度
                    
                    if ([[@"Content-Length" lowercaseString] isEqualToString:[propKey lowercaseString]]) {
                        // 获取内容长度
                        contentLength = [propValue longLongValue];
                    } else if ([[@"Transfer-Encoding" lowercaseString] isEqualToString:[propKey lowercaseString]])
                        {
                        // 获取传输编码
                        transferEncoding = propValue;
                    } else if ([[@"Content-Type" lowercaseString] isEqualToString:[propKey lowercaseString]]){
                        NSString* str = [propValue uppercaseString];
                        
                        if ([str containsString:@"UTF-8"]) {
                            _responseContentEncoding = @"UTF-8";
                        } else if ([str containsString:@"GBK"]) {
                            _responseContentEncoding = @"GBK";
                        } else if ([str containsString:@"GB2312"]) {
                            _responseContentEncoding = @"GB2312";
                        } else if ([str containsString:@"GB18030"]) {
                            _responseContentEncoding = @"GB18030";
                        } else if ([str containsString:@"ISO-8859-1"]) {
                            _responseContentEncoding = @"ISO-8859-1";
                        } else {
                            _responseContentEncoding = @"GBK";
                        }
                    }
                    // 加入响应头
                    [_responseHeaders setObject:propValue forKey:propKey];
                   
                }
                // 获取响应码
                _responseCode = [self parseResponseCode:responseAction];
                // 标志头已经解析
                parseHeader = YES;//消息头找出，跳出循环
                // 跳出循环
                break;
                
            }
        }
    }
    
    free(buffer);
    
    // 如果头解析错误，返回错误码
    if (!parseHeader) {
        _responseCode = 400;
        return [NSData new];
    }
   NSData * data=[byteOut copy];//目前所读取的全部byte
    len=(int)byteOut.length;
    totalLength=(int)(mulData.length);
    int currentLength=len;
    // 清空旧数据
    byteOut =[NSMutableData new];
    //开始解析内容体
    int index = splitIndex + 1;
    [byteOut appendData:[data subdataWithRange:NSMakeRange(index, len-index)]];
    /*
     返回的数据是分块的
     [Chunk大小][回车][Chunk数据体][回车][Chunk大小][回车][Chunk数据体][回车][0][回车]
     
     注意chunk-size是以十六进制的ASCII码表示的，比如86AE（实际的十六进制应该是：38366165），计算成长度应该是：34478，表示从回车之后有连续的34478字节的数据。
     
     */
    if ([[@"chunked" lowercaseString] isEqualToString:[transferEncoding lowercaseString]]) {
        NSMutableData *dataOut=[NSMutableData new];
        // 定义part size分割符
        Trigger *trigger = [[Trigger alloc] init:Trigger.SPLITOR];//\r\n
        // 开始索引
        int startIndex = 0;
        // 结束索引
        int endIndex = -1;
        // 偏移量
        int offset = 0;
        // part size
        int partSize = -1;
        
        // 是否需要从流中读取更多的数据
        BOOL readMore = false;
        do {
            // 数据不够的时候，才继续从输入流中读取数据
            if (offset >= byteOut.length || readMore) {
                int lenght=currentLength;
                // 已经到了结尾，跳出循环
                if(lenght>=totalLength){
                     break;
                 }
                int leftLength=totalLength-lenght;
                len = singleLength;
                if(leftLength<len){
                    len=leftLength;
                }
                int cIndex=lenght;
                NSData *tData= [mulData subdataWithRange:NSMakeRange(cIndex, len)];
                [byteOut appendData:tData];
                //当前已经读取的byte的长度
                currentLength=(int)byteOut.length;
                // 重置read more标志
                readMore = false;
            }
            //两个回车之间是当前chunk的大小
            // 试图获取开始索引
            if (startIndex == -1) {
                int pos = [trigger trigger:byteOut offset:offset length:-1];
                if (pos != -1) {
                    startIndex = pos + 1;
                    offset = startIndex;
                    // 重置trigger
                    [trigger reset];
                } else {
                    // 获取不到足够的数据，继续从流中读取数据
                    readMore = true;
                    continue;
                }
            }
            // 试图获取结束索引
            if (endIndex == -1) {
                int pos = [trigger trigger:byteOut offset:offset length:-1];//获取到offset为起点的第一个\r\n的索引,也就是\n的索引
               
                if (pos != -1) {
                    endIndex = pos;
                    offset = pos + 1;
                    // 重置trigger
                    [trigger reset];
                } else {
                    // 获取不到足够的数据，继续从流中读取数据
                    readMore = true;
                    continue;
                }
            }
            //如果格式错误抛出异常
            if(startIndex<0 || startIndex>=endIndex){
                NSMutableString* sb=[NSMutableString new];
                [sb appendString:@"chunked format error["];
                [sb appendString:@"startIndex:"];
                [sb appendString:[NSString stringWithFormat:@"%d",startIndex]];
                [sb appendString:@",endIndex:"];
                [sb appendString:[NSString stringWithFormat:@"%d",endIndex]];
                [sb appendString:@"]"];
                NSLog(@"%@",[sb copy]);
                return nil;
            }
            // 试图获取part size
            if (partSize == -1 ) {
                int size = endIndex - startIndex - 1;
             
                 NSData *tData=[byteOut subdataWithRange:NSMakeRange(startIndex,size)];
                 NSString *s =[[NSString alloc] initWithData:tData encoding:NSUTF8StringEncoding];//s为16进制的书
                //输出16进制数在十进制下的数,得到chunk的大小
                partSize=  [[self numberHexString:s] intValue];
                
            }
            
           if(partSize==0){//最后一块
                break;
            }
           else if (partSize > 0 && byteOut.length >= offset + partSize) {
                // 写入数据
                //吧当前块写入 dataOut
               [dataOut appendData:[byteOut subdataWithRange:NSMakeRange(offset,partSize)]];
                // 更新偏移量
                offset += partSize;
                // 重置索引
                  startIndex = -1;
                  endIndex = -1;
                  partSize = -1;
            } else{
                // 获取不到足够的数据，继续从流中读取数据
                readMore=true;
            }
        }while (true);
        
        return  [dataOut copy];
    }
    else{
        
    }
    return nil;
}

-(NSURLRequest*) getRequestToHttpServer:(NSArray<FormEntry*>*) formEntrys
{
    NSMutableData *output=[NSMutableData new];
    // 内容长度
    long contentLength = 0;
    // 上送数据
    NSMutableArray<NSData*>*uploadDatas=[NSMutableArray<NSData*> new ];
    
    // 创建boundary
    NSString* boundary = @"-----------------109o0hfp5m7y324";
    // 创建end line
    NSMutableString* endSb = [NSMutableString new];
    [endSb appendString:@"--"];
    [endSb appendString:boundary];
    [endSb appendString:@"--\r\n"];
    NSString *endline = [endSb copy];
    NSData *endLineBytes = [endline dataUsingEncoding:NSUTF8StringEncoding];
    
    for (int i = 0; i < formEntrys.count; i++) {
        // 获取内容类型
        NSString *contentType = formEntrys[i].contentType;
        if ([@"application/octet-stream" isEqualToString:contentType]) {
            NSMutableString* sb =[NSMutableString new];
            [sb appendString:@"--"];
            [sb appendString:boundary];
            [sb appendString:@"\r\n"];
            [sb appendString:@"Content-Disposition: form-data;name=\""];
            [sb appendString:formEntrys[i].parameterName];
            [sb appendString:@"\";filename=\""];
            [sb appendString:formEntrys[i].fileName];
            [sb appendString:@"\"\r\n"];
            [sb appendString:@"Content-Type: "];
            [sb appendString:contentType];
            [sb appendString:@"\r\n\r\n"];
            NSData* bytes = [[sb copy] dataUsingEncoding:NSUTF8StringEncoding];
            // 保存数据
            [uploadDatas addObject:bytes];
            // 头长度
            contentLength += bytes.length;
            // 内容长度
            NSString* file = formEntrys[i].file;
            if (file != nil) {
                // 获取文件长度
                // contentLength += file.length();
            } else {
                // 获取数据
                NSData* datas = formEntrys[i].data;
                if (datas != nil) {
                    // 获取数据长度
                    contentLength += datas.length;
                }
            }
            // 换行符长度
            contentLength += 2;
        } else {
            NSMutableString* sb =[NSMutableString new];
            [sb appendString:@"--"];
            [sb appendString:boundary];
            [sb appendString:@"\r\n"];
            [sb appendString:@"Content-Disposition: form-data;name=\""];
            [sb appendString:formEntrys[i].parameterName];
            [sb appendString:@"\"\r\n"];
            [sb appendString:@"Content-Type: "];
            [sb appendString:contentType];
            [sb appendString:@"\r\n\r\n"];
            [sb appendString:formEntrys[i].text];
            [sb appendString:@"\r\n"];
            NSData* bytes = [[sb copy] dataUsingEncoding:NSUTF8StringEncoding];
            // 保存数据
            [uploadDatas addObject:bytes];
            // 长度
            contentLength += bytes.length;
        }
    }
    // 计算end line长度
    contentLength += endLineBytes.length;
    
    // 设置HTTP内容长度头
    [self setRequestProperty:@"Cdontent-Length" value:[NSString stringWithFormat:@"%ld",contentLength]];
    
    // 设置内容类型
    [self setRequestProperty:@"Content-Type" value:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary]];
 
    NSURL *url=[NSURL URLWithString:self.url];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"POST";
//    [request setValue:@"139.199.79.118:9191" forHTTPHeaderField:@"Host"];
//    [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
//    [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"Fox" forHTTPHeaderField:@"User-Agent"];
//    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
//    [request setValue:@"zh-CN,zh;q=0.8,en;q=0.6" forHTTPHeaderField:@"Accept-Language"];
//    [request setValue:@"multipart/form-data; boundary=-----------------109o0hfp5m7y324" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"127.0.0.1" forHTTPHeaderField:@"Phe-Client-IP"];
//    [request setValue:@"803" forHTTPHeaderField:@"Content-Length"];
    
    for(NSString *key in _requestHeaders){
        NSLog(@"key=%@,value=%@",key,_requestHeaders[key]);
        [request setValue:_requestHeaders[key] forHTTPHeaderField:key];
    }
    
    // 创建段落结尾
    NSData* segmentEndLineBytes = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    for (int i = 0; i < formEntrys.count; i++) {
        // 获取内容类型
        NSString* contentType = formEntrys[i].contentType ;
        if ([@"application/octet-stream" isEqualToString:contentType]) {
          
            // 写入头信息
            [output appendData:uploadDatas[i]];
            // 获取文件
            NSString* file = formEntrys[i].file;
            if (file != nil) {
               
                
            } else {
                // 获取数据
                NSData* content = formEntrys[i].data ;
                if (content == nil) {
                    Byte b=0;
                    content= [[NSData alloc] initWithBytes:&b length:1];
                    
                }
                [output appendData:content];
                
            }
            // 写入段落结尾
            [output appendData:segmentEndLineBytes];
            
        } else {
            // 写入数据
            [output appendData:uploadDatas[i]];
            
        }
    }
    // 写入内容结尾
    [output appendData:endLineBytes];
    
    request.HTTPBody=output;
    
    return request;
   
}












/**
 * 创建boundary
 *
 * return
 */
-(NSString*) createBounary{
   return @"-----------------109o0hfp5m7y324";
}



/**
 * 解析返回头代码
 *
 * param responseAction
 * return
 */
-(int) parseResponseCode:(NSString*) responseAction {
    @try {
       NSArray* arr= [responseAction componentsSeparatedByString:@" "];
        if(arr.count<3){
            return 400;
        }
        int code = [arr[1] intValue];
        return code;
    } @catch (NSException* e) {
        
        return 400;
    }

}

/**
 * 编码请求头
 *
 * param requestMethod
 * param path
 * param query
 * param requestHeaders
 * param encoding
 * return
 * @throws Exception
 */
-(Byte*) encodeRequestHeader:(NSString*) requestMethod path: (NSString*) path query:
(NSString*) query requestHeaders: (NSMutableDictionary<NSString*, NSString*>* )requestHeaders encoding: (NSString*) encoding length:(int *)length
 {
    NSMutableString* sb = [NSMutableString new];
    [sb appendString:requestMethod];
    [sb appendString:@" "];
    BOOL flag = true;
    if (path != nil && path.length > 0) {
        [sb appendString:path];
        flag = true;
    }
    if (query != nil && query.length > 0) {
        [sb appendString:@"?"];
        [sb appendString:query];
        flag = true;
    }

    if (flag) {
        [sb appendString:@" "];
    }

    [sb appendString:@"HTTP/1.1\r\n"];

    if (_requestContentLength != -1) {
        NSString* s = [NSString stringWithFormat:@"%d",-1];
        [requestHeaders setObject:s forKey:@"Content-Length"];
    }

    for (NSString* key in requestHeaders.allKeys) {
        // 获取属性值
        NSString* value = requestHeaders[key];
        [sb appendString:key];
        [sb appendString:@": "];
        [sb appendString:value];
        [sb appendString:@"\r\n"];
    }
    [sb appendString:@"\r\n"];
    NSData *data=[sb dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes= (Byte*)[data bytes];
    *length=(int)data.length;
     return bytes;
}

- (NSNumber *) numberHexString:(NSString *)aHexString
{
    // 为空,直接返回.
    if (nil == aHexString)
    {
        return nil;
    }
    NSScanner * scanner = [NSScanner scannerWithString:aHexString];
    unsigned long long longlongValue;
    [scanner scanHexLongLong:&longlongValue];
    //将整数转换为NSNumber,存储到数组中,并返回.
    NSNumber * hexNumber = [NSNumber numberWithLongLong:longlongValue];
    return hexNumber;
}
















@end
