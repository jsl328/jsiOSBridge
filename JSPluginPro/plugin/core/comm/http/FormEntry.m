//
//  FormEntry.m
//  SimpleNetworkStreams
//
//  Created by BruceXu on 2018/4/17.
//

#import "FormEntry.h"
@interface FormEntry()
{
    
}


@end
@implementation FormEntry
-(id)init{
    if(self=[super init]){
        _contentType = @"application/octet-stream";
    }
    return self;
}
/**
 * 构造函数
 *
 * @param parameterName
 * @param fileName
 * @param data
 * @param contentType
 */
-(id)init:(NSString*)parameterName fileName:(NSString*)fileName data:(NSData*)data contentType:(NSString*)contentType{
    if(self=[self init]){
    _parameterName=parameterName;
    _fileName=fileName;
    _data=data;
        _contentType=contentType;
        
    }
    return self;
}

/**
 * 构造函数
 *
 * @param parameterName
 * @param fileName
 * @param file
 * @param contentType
 */
-(id)init:(NSString*)parameterName fileName:(NSString*)fileName file:(NSString*)file contentType:(NSString*)contentType{
     if(self=[self init]){
    _parameterName=parameterName;
    _file=file;
    _fileName=file;
    _contentType=contentType;
     }
    return self;
}

-(id)init:(NSString*)parameterName text:(NSString*)text contentType:(NSString*)contentType{
    if(self=[self init]){
    _parameterName=parameterName;
    _text=text;
    _contentType=contentType;
        
    }
    return self;
}









@end
