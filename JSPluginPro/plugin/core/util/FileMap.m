//
//  FileMap.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "FileMap.h"
#import "FileCache.h"
@interface FileMap(){
    FileCache *cache;
    NSString *encoding;
    NSDictionary<NSString*,NSString*>*map;
    
}
@end
@implementation FileMap
-(id)initWithPath:(NSString *)path {
    if([self init]){
        cache=[[FileCache alloc] initWithPath:path];
       
    }
    return self;
    
    
}



/**
 * 加载文件
 *
 * return
 */
-(NSDictionary<NSString*, NSString*>* )load{
    if (![cache exists]) {
        return [[NSDictionary<NSString*, NSString*> new ] copy];
    }
    //判断文件是否被修改
    BOOL flag = (map==nil) || [cache isModified];
    if (flag) {
        //读取文件
        NSData* data = [cache read];
        
        // 定义配置MAP
        NSMutableDictionary<NSString*, NSString*>* configMap =   [NSMutableDictionary<NSString*, NSString*> new ];
        NSString *dataFile=  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSArray *dataarr = [dataFile componentsSeparatedByString:@"\n"];
        for (NSString *line in dataarr) {
            NSString *newLine;
            newLine= [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if(newLine.length==0){
                continue;
            }
           char c= [newLine characterAtIndex:0];
            if(c=='#' ) continue;
            if(c=='\r') continue;
            if(c=='\n') continue;
            
            NSArray *lineArray= [newLine componentsSeparatedByString:@"="];
            if(lineArray.count>1){
                NSString *value=lineArray[lineArray.count-1];
               int index= (int)[newLine rangeOfString:[NSString stringWithFormat:@"=%@",value ]].location;
                NSString *key= [newLine substringToIndex:index];
                key= [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                key= [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                key=[key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                value= [value stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                value= [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                value=[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                [configMap setObject:value forKey:key];
                
            }
        }
        
        map = configMap;
    }
    return  [map copy];
}

/**
 * 保存文件
 *
 *
 */
-(void) save:(NSDictionary<NSString*, NSString*>*) newMap   {
       map = newMap;
       NSMutableString * sb=[NSMutableString new];
       for (NSString* key in map.allKeys) {
            NSString *value = map[key];
            [sb appendString:[NSString stringWithFormat:@"%@ = %@\r\n",key,value ]];
       }
    
       NSData *data=   [sb dataUsingEncoding:NSUTF8StringEncoding];
       [cache write:data];
    
}

///**
// * 获取值
// *
// * @param key
// * @return
// * @throws Exception
// */
-(NSString*) get:(NSString* )key   {
    NSDictionary<NSString*, NSString*> *map = [self load];
    NSString *value = map[key];
    return value;
  
}
//
//
/**
 * 获取所有值
 *
 * @return map
 *
 */
-(NSDictionary<NSString*,NSString*>*) getAll{
    
    NSDictionary<NSString*, NSString*> *map = [self load];
   
    return  [map copy];
    
}

/**
 * 加入值
 *
 * param key
 * param value
 */
-(void) put:(NSString*) key value:(NSString*) value {
    NSDictionary<NSString*, NSString*> *map = [self load];
    
    NSMutableDictionary *tmpDic=[[NSMutableDictionary alloc] initWithDictionary:map];
    [tmpDic setObject:value forKey:key];
   
    [self save:tmpDic];
    
}
//
/**
 * 批量加入值
 *
 * param newMap
 *
 */
-(void) putAll:(NSDictionary<NSString*, NSString*>*)map_  {
    NSDictionary<NSString*, NSString*> *map = [self load];
    
    NSMutableDictionary *tempMap=[[NSMutableDictionary alloc] initWithDictionary:map];
    [tempMap addEntriesFromDictionary:map_];
    [self save:[tempMap copy]];
    
   
    
}


/**
 * 移除值
 *
 * param key
 * return
 *
 */
-(NSString*) remove:(NSString*) key{
    NSDictionary<NSString*, NSString*>* map = [self load];
    NSMutableDictionary *tempMap=[[NSMutableDictionary alloc] initWithDictionary:map];
    BOOL isExists= [tempMap.allKeys containsObject:key];
    NSString *value=nil;
    if(isExists){
        value=[tempMap[key] copy];
        [tempMap removeObjectForKey:key];
        [self save:tempMap];
    }
    return value;
}

/**
 * 清空
 *
 *
 */
 -(void)clear {
     NSDictionary<NSString*, NSString*>* map = [self load];
     map=@{};
     [self save:map];
}

/**
 * 判断key是否存在
 *
 * @throws IOException
 */
-(BOOL) containsKey:(NSString*) key  {
    NSDictionary<NSString*, NSString*>* map = [self load];
    return [map.allKeys containsObject:key];
}

/**
 * 判断value是否存在
 *
 * @throws IOException
 */
-(BOOL) containsValue:(NSString*) value  {
    NSDictionary<NSString*, NSString*>* map = [self load];
   return [map.allValues containsObject:value];
    
}

/**
 * 获取key集合
 *
 * @throws IOException
 */
 -(NSArray<NSString*>*) keySet {
    NSDictionary<NSString*, NSString*>* map =  [self load];
     return [map.allKeys copy];
}
//
///**
// * 转换为JSON格式
// *
// * @return
// * @throws IOException
// * @throws JSONException
// */
//public synchronized JSONObject toJson() throws IOException, JSONException {
//    Map<String, String> map = this.load();
//    JSONObject json = new JSONObject();
//    for (String key : map.keySet()) {
//        String value = map.get(key);
//        json.put(key, value);
//    }
//    return json;}










@end
