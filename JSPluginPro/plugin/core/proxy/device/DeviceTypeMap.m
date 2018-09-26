//
//  DeviceTypeMap.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "DeviceTypeMap.h"
#import "PropertiesUtil.h"
#import "FileAccessor.h"
#import "FileMap.h"
@interface DeviceTypeMap()
/**
 * device type映射
 */
@property(strong) NSDictionary<NSString*,NSString*>*devTypeMap;

/**
 * 自定义device type映射
 */
@property(strong) FileMap* customDevTypeMap;
@end
@implementation DeviceTypeMap
-(id)init{
    if(self=[super init]){
        @try{
            //self.devTypeMap 是从资源中加载，不是从沙盒中
            self.devTypeMap= [PropertiesUtil load:@"devicetype_mapping" fileType:@"properties" encoding:NSUTF8StringEncoding];
        }
        @catch(NSException *e){
            FOXLog(@"error=%@",e);
            self.devTypeMap=[NSDictionary<NSString*,NSString*> new];
        }
        return self;
        
        // 获取device类型文件名称 configaration 解压开项目的文件夹，
        //customDevTypeMap从沙盒中加载，是用户扩展的，比如新添加的密码键盘
        NSString *deviceTypeFileName = @"configuration/deviceType_mapping.properties";
        //获取file accessor
        FileAccessor *fileAccessor = [FileAccessor getInstance];
        // 获取文件
        NSString* deviceTypeFile = [fileAccessor getFile:deviceTypeFileName];
        self.customDevTypeMap =  [[FileMap alloc] initWithPath:deviceTypeFile];
        int ii=0;
    }
    return self;
}
/**
 * 根据类型获取设备名称
 *
 * param type
 * return
 */
-(NSString*)get:(NSString*)type{
    NSString *devId=nil;
    @try {
        devId=[self.customDevTypeMap get:type];//先找自定义配置文件 configuration/deviceType_mapping.properties
    }@catch(NSException * e){
        FOXLog(@"error:%@",e);
    }
    //2.试图从device map中获取
    if(devId==nil){
        @try{
            devId=self.devTypeMap[type];//在找资源文件 //devicetype_mapping.properties
        }@catch(NSException * e){
            FOXLog(@"error:%@",e);
        }
    }
    return devId;
}
/**
 * 加入设备类型和设备名称的映射
 *
 * param type
 * param typeName
 */
-(void) put:(NSString*) type typeName:(NSString*) typeName {
    //加入到自定义配置文件configuration/deviceType_mapping.properties
    [self.customDevTypeMap put:type value:typeName];
    
}
/**
 * 批量加入设备和设备名称的映射
 *
 * @param map
 */
-(void)putAll:(NSDictionary<NSString*,NSString*>*)map{
    [self.customDevTypeMap putAll:map];
}
/**
 * 返回所有设备类型和设备名称的映射
 *
 * return
 */
-(NSDictionary<NSString*,NSString*>*)getAll{
    NSMutableDictionary<NSString*,NSString*>*resMap=[NSMutableDictionary<NSString*,NSString*> new ];
    [resMap setDictionary:self.devTypeMap];
    @try{
        NSDictionary<NSString*,NSString*>*map=[self.customDevTypeMap getAll];
        [resMap setDictionary:map];
    }
    @catch(NSException*e){
        FOXLog(@"error=%@",e);
    }
    return resMap;
}
///**
// * 以JSON格式返回所有设备类型和设备ID的映射
// *
// * @return
// */
//public JSONObject getAllAsJson() throws JSONException {
//    Map<String, String> map = this.getAll();
//    JSONObject json = new JSONObject();
//    for (String key : map.keySet()) {
//        String value = map.get(key);
//        json.put(key, value);
//    }
//    return json;
//}











@end
