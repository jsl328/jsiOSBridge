//
//  DeviceMap.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "DeviceMap.h"
#import "FileMap.h"
#import "FileAccessor.h"
#import "FileMap.h"
@interface DeviceMap()
/**
 * 设备映射
 */
@property(strong)FileMap *devMap;
/**
 * 自定义设备映射
 */
@property(strong)FileMap* customDevMap;


@end
@implementation DeviceMap
-(id)init{
    if(self=[super init]){
        
        [self loadFile];
    }
    return self;
}
-(void)loadFile{
    FileAccessor *fileAccessor=[FileAccessor getInstance];
    
    // 获取device mapping文件名称
    NSString* deviceMappingFileName = @"configuration/device_mapping.properties";
    // 获取文件
    NSString * deviceMappingFile = [fileAccessor getFile:deviceMappingFileName];
    //创建device mapping
    self.devMap = [[FileMap alloc] initWithPath:deviceMappingFile];
 
    // 获取custom device mapping文件名称
    NSString* deviceMappingCustomFileName = @"configuration/device_mapping_custom.properties";
    // 获取文件
    NSString * customDeviceMappingFile = [fileAccessor getFile:deviceMappingCustomFileName];
    //创建custom device mapping
    self.customDevMap =  [[FileMap alloc] initWithPath:customDeviceMappingFile];
    
    
}

/**
 * 根据类型获取设备ID
 *
 * param type
 * return
 */
-(NSString*) get:(NSString*) type {
    //1.试图从custom device map中获取
    NSString* devId=nil;
    
    devId=[self.customDevMap get:type];
   
    //2.试图从device map中获取
    if(devId==nil){
        devId=[self.devMap get:type];
    }
    return devId;
}
/**
 * 加入设备类型和设备ID的映射
 *
 * param type
 * param deviceId
 */
-(void) put:(NSString*) type deviceId: (NSString*) deviceId {
    
    [self.customDevMap put:type value:deviceId];
    
}

/**
 * 批量加入设备和设备ID的映射
 *
 * param map
 */
-(void) putAll:(NSDictionary<NSString*, NSString*>*) map {
    [self.customDevMap putAll:map];
}

/**
 * 返回所有设备类型和设备ID的映射
 *
 * @return
 */
-(NSDictionary<NSString*, NSString*>*) getAll {
    //1.从device map中获取
    NSMutableDictionary<NSString*,NSString*>* resMap= [NSMutableDictionary<NSString*,NSString*> new ];
    
    NSDictionary<NSString*,NSString*>* map= [self.devMap  getAll];
    if(map)
    [resMap addEntriesFromDictionary:map];
    
    //2.从custom device map中获取
    
        map=[self.customDevMap getAll];
       if(map)
         [resMap addEntriesFromDictionary:map];
    
    return [resMap copy];
}


///**
// * 以JSON格式返回所有设备类型和设备ID的映射
// *
// * @return
// */
//public JSONObject getAllAsJson() throws JSONException{
//    Map<String,String> map=this.getAll();
//    JSONObject json=new JSONObject();
//    for(String key:map.keySet()){
//        String value=map.get(key);
//        json.put(key,value);
//    }
//    return json;
//}







@end
