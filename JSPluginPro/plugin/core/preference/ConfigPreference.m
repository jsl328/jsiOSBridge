//
//  ConfigPreference.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/16.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "ConfigPreference.h"
#import "FileAccessor.h"
#import "FoxFileManager.h"
@interface ConfigPreference()


/**
 * 配置属性集合
 */
@property(strong)NSMutableDictionary<NSString*,NSMutableDictionary<NSString*,id>*>*configProperties;
/**
 * 自定义配置属性集合
 */
@property(strong)NSMutableDictionary
<NSString*,NSMutableDictionary<NSString*,id>*>*customConfigProperties;
/**
 * 配置文件
 */
@property(copy) NSString* configFile;

/**
 * 配置文件
 */
@property(copy) NSString*customConfigFile;
@end

@implementation ConfigPreference
static ConfigPreference *_instance;
+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
-(id)init{
    if(self=[super init]){
        // 获取配置文件列表
        self.configFile = @"configuration/client.properties";
        // 获取custom配置文件列表
        self.customConfigFile = @"configuration/client_custom.properties";
        
        self.configProperties=[NSMutableDictionary<NSString*,NSMutableDictionary<NSString*,id>*> new];
        
        self.customConfigProperties=[NSMutableDictionary<NSString*,NSMutableDictionary<NSString*,id>*> new];
        // 加载配置
        [self load];
    }
    return self;
}
-(void)load{
    FileAccessor *fileAccessor=[FileAccessor  getInstance];
     // 加载配置文件
    NSString *file=[fileAccessor getFile:self.configFile];
     // 加载自定义配置文件
    file=[fileAccessor getFile:self.configFile];
    [self loadConfigFile:file configMap:self.configProperties];
    
    file=[fileAccessor getFile:self.customConfigFile];
    [self loadConfigFile:file configMap:self.customConfigProperties];
}


/**
 * 加载配置文件
 *
 * param file
 * param configMap
 */

-(void)loadConfigFile:(NSString*)file configMap:(NSMutableDictionary<NSString*,NSMutableDictionary<NSString*,id>*>*)configMap{
    //启动开始时间
    long s= [[NSDate date] timeIntervalSince1970];
    NSString*fileName=[FoxFileManager fileNameAtPath:file suffix:YES];
#ifdef DEBUG
    NSString *logtxt=[NSString stringWithFormat:@"开始加载配置文件[%@]",fileName];
    FOXLog(@"%@",logtxt);
 #endif
    
    // 获取文件访问器
   // FileAccessor *fileAccessor = [FileAccessor getInstance];
    @try{
    if(![FoxFileManager isExistsAtPath:file]){
        NSString *logtxt=[NSString stringWithFormat:@"配置文件[%@]不存在",fileName];
        FOXLog(@"%@",logtxt);
        return;
    }
      
        //通过流打开一个文件
        char szTest[1000] = {0};
        FILE *fp = fopen([file cStringUsingEncoding:NSUTF8StringEncoding], "r");
        
        
        while(!feof(fp))
        {
            memset(szTest, 0, sizeof(szTest));
            fgets(szTest, sizeof(szTest) - 1, fp); // 包含了\n
            printf("%s", szTest);
            NSString * lineText= [[NSString alloc] initWithCString:szTest
                                                          encoding:NSUTF8StringEncoding];
            //空格忽略
            if([lineText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length==0){
                continue;
            }
            //#忽略
            if([lineText characterAtIndex:0]=='#'){
                continue;
            }
            if([lineText characterAtIndex:0]=='\r'){
                continue;
            }
            if([lineText characterAtIndex:0]=='\n'){
                continue;
            }
            //前半部分
            NSString *prePart  =[lineText componentsSeparatedByString:@"="][0] ;
            //获取后部分
            NSRange range = [lineText rangeOfString:@"="];
            NSString *postPart= [lineText substringFromIndex:range.location+1];
            
//            NSString *postPart=[lineText componentsSeparatedByString:@"="][1] ;
            postPart=[postPart stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            postPart=[postPart stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            int index;
            index=(int)[prePart rangeOfString:@"/"].location;
            NSString *mark=[[prePart substringToIndex:index] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *key=[[prePart substringFromIndex:index+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *value = [postPart stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            
            // 获取子配置MAP
            NSMutableDictionary<NSString*, id>* subConfigMap = configMap[mark];
            if (subConfigMap == nil) {
                subConfigMap = [NSMutableDictionary<NSString*, id> new ];
                // 加入配置MAP
                [configMap setObject:subConfigMap forKey:mark];
            }
            // 加入配置
            [subConfigMap setObject:value forKey:key];
            }
        
            fclose(fp);
        
    }
    @catch(NSException *e){
        NSString *logtxt=[NSString stringWithFormat:@"解析配置文件[%@]失败",fileName];
        FOXLog(@"%@",logtxt);
    }
    @finally{
        
    }
    //记录结束时间
#ifdef DEBUG
     long t =  [[NSDate date] timeIntervalSince1970];
     logtxt=[NSString stringWithFormat:@"完成加载配置文件[%@]，耗时%ld毫秒",fileName,(t-s)];
     FOXLog(@"%@",logtxt);
#endif
}


/**
 * 保存配置文件
 *
 * param file
 * param configMap
 */
-(void) saveConfigFile:(NSString*) file configMap:(NSMutableDictionary<NSString*,NSMutableDictionary<NSString*,id>*>*)configMap
 {
      NSString*fileName=[FoxFileManager fileNameAtPath:file suffix:YES];
    // 记录开始时间
     #ifdef DEBUG
       long s = [[NSDate date] timeIntervalSince1970];
       NSString *  logtxt=[NSString stringWithFormat:@"开始保存配置文件[%@]",fileName];
       FOXLog(@"%@",logtxt);
     
     #endif
    
    if (configMap == nil) {
        FOXLog(@"配置数据为空");
        return;
    }
    
//    //StringBuilder content = new StringBuilder();
//    for (NSString *mark in configMap.allKeys) {
//        // 获取子配置MAP
//        NSMutableDictionary<NSString*, id>* subConfigMap = configMap[mark];
//        for (NSString* key in subConfigMap.allKeys) {
//            // 获取数据
//            id obj = subConfigMap[key];
//            @try {
//                // 获取value
//                String value = ObjectCovert.objectToStr(obj);
//                // 拼装数据
//                content.append(mark);
//                content.append("/");
//                content.append(key);
//                content.append(" = ");
//                content.append(value);
//                content.append("\r\n");
//            } @catch (NSException *e) {
//                FOXLog(@"%@",e);
//            }
//        }
//    }
//
//    OutputStream out = null;
//    try {
//        // 获取字节数据
//        byte[] bytes = content.toString().getBytes(this.encoding);
//        out = new BufferedOutputStream(new FileOutputStream(file));
//        out.write(bytes);
//        out.flush();
//    } catch (Exception e) {
//        logger.error(e.getMessage(), e);
//    } finally {
//        if (out != null) {
//            try {
//                out.close();
//            } catch (Exception e) {
//                logger.error(e.getMessage(), e);
//            }
//        }
//    }
//
    // 记录结束时间
    long t =[[NSDate date] timeIntervalSince1970];
    #ifdef DEBUG
       logtxt=[NSString stringWithFormat:@"完成保存配置文件[%@]，耗时%ld毫秒",fileName,(t-s)];
       FOXLog(@"%@",logtxt);
     #endif
    
}

-(void) put:(NSString*) mark key: (NSString*) key value: (id)value {
   
        // 获取mark对应的properties
        NSMutableDictionary<NSString*, id>* subConfigProperties = self.customConfigProperties
        [mark];
        if (subConfigProperties == nil) {
            // 创建子properties
            subConfigProperties = [NSMutableDictionary<NSString*, id> new ];
            // 加入配置MAP
            [self.customConfigProperties setObject:subConfigProperties forKey:mark];
        }
        // 加入配置
        [subConfigProperties setObject:value forKey:key];
    
    
}

-(void) putBoolean:(NSString*) mark key: (NSString*) key value:(BOOL) value {
    [self put:mark key:key value: [NSNumber numberWithBool:value] ];
}

-(void)putDouble:(NSString*) mark key: (NSString*) key value:(double) value {
    [self put:mark key:key value:[NSNumber numberWithDouble:value] ];
}

/**
 * Associates the specified float object with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @param value
 */
-(void)putFloat:(NSString*) mark key: (NSString*) key value:(float) value {
    [self put:mark key:key value:[NSNumber numberWithFloat:value] ];
}

/**
 * Associates the specified Integer object with the specified mark and key
 * in this node.
 *
 * @param mark
 * @param key
 * @param value
 */
-(void)putInt:(NSString*) mark key: (NSString*) key value:(int) value {
    [self put:mark key:key value:[NSNumber numberWithInt:value] ];
}

/**
 * Associates the specified long object with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @param value
 */
-(void)putLong:(NSString*) mark key: (NSString*) key value:(long) value  {
    [self put:mark key:key value:[NSNumber numberWithLong:value] ];
}

/**
 * Associates the specified string object with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @param value
 */
-(void)putString:(NSString*) mark key: (NSString*) key value:(NSString*) value  {
    [self put:mark key:key value:  value];
}

/**
 * Returns the value associated with the specified mark and key in this
 * node.
 *
 * @param mark
 * @param key
 * @param defaultValue
 * @return
 */
-(id) get:(NSString*) mark key:(NSString*) key defaultValue:(id)defaultValue {
    id value = nil;
   
        // 获取mark对应的properties
        NSDictionary<NSString*, id>* subConfigPropertis =  [self.customConfigProperties objectForKey:mark];
    
        if (subConfigPropertis != nil) {
            // 获取对应的value
            value = subConfigPropertis[key];
        }

        if (value == nil) {
            // 获取mark对应的properties
            subConfigPropertis = self.configProperties[mark];
            if (subConfigPropertis != nil) {
                // 获取对应的value
                value = subConfigPropertis[key];
            }
        }

        if (value == nil) {
          value = defaultValue;
     }
    return value;
    
       
    
}

/**
 * Returns the Boolean object associated with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @param defaultValue
 * @return
 */
-(BOOL)getBoolean:(NSString*) mark key:(NSString*) key  defaultValue:(BOOL) defaultValue{
    // 获取value
       NSNumber * value = [self get: mark key:key defaultValue:@(defaultValue)];
    
       BOOL res;
       res=  [value boolValue];
       return res;
}

/**
 * Returns the double object associated with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @return
 */
-(double) getDouble:(NSString*) mark key:(NSString*) key  defaultValue:(double) defaultValue {
    // 获取value
    NSNumber  * value = [self get: mark key:key defaultValue:@(defaultValue)];
    
   double res;
    res=  [value doubleValue];
    return res;
   
}

/**
 * Returns the float object associated with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @param defaultValue
 * @return
 */
-(float) getFloat:(NSString*) mark key:(NSString*) key  defaultValue:(float) defaultValue {
    // 获取value
    NSNumber  * value = [self get: mark key:key defaultValue:@(defaultValue)];
    
   float res;
    res=  [value floatValue];
    return res;
}

/**
 * Returns the Integer object associated with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @param defaultValue
 * @return
 */
-(int) getInt:(NSString*) mark key:(NSString*) key  defaultValue:(int) defaultValue {
    // 获取value
    
    NSNumber * value = [self get: mark key:key defaultValue:@(defaultValue)];
    
    int res;
    res=  [value intValue];
    return res;
}

/**
 * Returns the long object associated with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @return
 */
-(long)getLong:(NSString*) mark key:(NSString*) key  defaultValue:(long) defaultValue {
    // 获取value
    NSNumber * value = [self get: mark key:key defaultValue:@(defaultValue)];
    
    long res;
    res=  [value longValue];
    return res;
}

/**
 * Returns the string object associated with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @return
 */
-(NSString*) getString:(NSString*) mark key:(NSString*) key  defaultValue:(NSString*) defaultValue {
    // 获取value
     NSString* value = [self get: mark key:key defaultValue:defaultValue];
    //去除换行和空格
    value= [value stringByReplacingOccurrencesOfString:@"\r"withString:@""];
    value= [value stringByReplacingOccurrencesOfString:@"\n"withString:@""];
    return value;
}

/**
 * 刷新数据
 */
-(void) refresh{
    // 重新加载数据
    [self load];
}

/*** 把数据写到文件中数据
 */
-(void) flush {
    //获取file accessor
    FileAccessor* fileAccessor=[FileAccessor getInstance];
    
        NSString* file = [fileAccessor getFile:self.customConfigFile];
        // 写入文件
    [self saveConfigFile:file configMap:self.customConfigProperties];
    
}











@end
