//
//  FormEntry.h
//  SimpleNetworkStreams
//
//  Created by BruceXu on 2018/4/17.
//

#import <Foundation/Foundation.h>

@interface FormEntry : NSObject
/**
 * 上传文本
 */
@property(copy) NSString* text;

/**
 * 上传数据
 */
@property(copy) NSData* data;

/**
 * 上传文件
 */
@property(copy)NSString* file;

/**
 * 文件名称
 */
@property(copy)NSString* fileName;

/**
 * 请求参数名称
 */
@property(copy)NSString *parameterName;
/**
 * 内容类型
 */
@property(copy)NSString* contentType;
-(id)init:(NSString*)parameterName fileName:(NSString*)fileName data:(NSData*)data contentType:(NSString*)contentType;

/**
 * 构造函数
 *
 * @param parameterName
 * @param fileName
 * @param file
 * @param contentType
 */
-(id)init:(NSString*)parameterName fileName:(NSString*)fileName file:(NSString*)file contentType:(NSString*)contentType;

-(id)init:(NSString*)parameterName text:(NSString*)text contentType:(NSString*)contentType;

@end
