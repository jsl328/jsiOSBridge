//
//  HttpRequester.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/21.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpURLClient.h"
#import "ICallBackDelegate.h"
@interface HttpRequester : NSObject
/**
 * HTTP请求形式(POST)
 */
+(NSString*) POST  ;

/**
 * HTTP请求形式(GET)
 */
+(NSString*) GET  ;

/**
 * 当前运行context path
 */
+(NSString*) INSTANT_CONTEXT_PATH  ;

/**
 * workspace context path
 */
+(NSString*) WORKSPACE_CONTEXT_PATH  ;

/**
 * configuration context path
 */
+(NSString*) CONFIGURATION_CONTEXT_PATH  ;

/**
 * base context
 */
+(NSString*) BASE_CONTEXT  ;

/**
 * 绝对路径
 */
+(NSString*) ABSOLUTE_PATH  ;

/**
 * 相对路径
 */
+(NSString*) RELATIVE_PATH ;

/**
 * 当前路径
 */
+(NSString*) CURRENT_PATH  ;

/**
 * 默认编码
 */
+(NSStringEncoding)encoding;

/**
 * 服务名
 */
+(NSString*) SERVICE_NAME ;

/**
 * 列分割符
 */
+(NSString*) ITEM_SPLITOR ;

/**
 * 行分割符
 */
+(NSString*) LINE_SPLITOR ;

+(NSString*) SERVICE_ROOT;


/**
 * 生成token id
 * @return
 */
+(long) generateTokenID;

/**
 * 获取host
 *
 * @param url
 * @return
 */
+ (NSString*) getHost:(NSURL*) url;

/**
 * 获取通行证
 *
 * @param ip
 * @return
 */
+( NSString*) getPassport:(NSString*) ip;

/**
 * 创建HTTP连接
 *
 * @param url
 * @param requestType
 * @param params
 * @param timeout
 * @return
 * @throws Exception
 */
+(HttpURLClient*) createHttpURLClient:(NSString*) url requestType:(NSString*)requestType params:(NSMutableDictionary<NSString*,NSString*>*)params timeout:(int)timeout;

/**
 * GET方式请求HTTP服务
 *
 * @param url
 * @param timeout
 * @return
 */
+(NSString*) get:(NSString*) url timeout: (int) timeout   ;


/**
 * POST方式请求HTTP服务
 *
 * @param url
 * @param params
 * @param data
 * @param encoding
 * @param timeout
 * @return
 */
+(NSString*) post:(NSString*) url params: (NSMutableDictionary<NSString*, NSString*>*) params data:(NSMutableDictionary<NSString*, NSString*>*) data encoding:(NSStringEncoding)encoding timeout:(int)timeout
;

/**
 * 远程文件是否存在
 *
 * @param address
 * @param path
 * @param baseContext
 * @param timeout
 * @return
 * @throws Exception
 */
+(BOOL) isRemoteFileExists:(NSString*) address path: (NSString*) path baseContext:(NSString*)baseContext timeout:(int)timeout;
/**
 * 删除远程文件
 *
 * @param address
 * @param path
 * @param baseContext
 * @param timeout
 * @return
 * @throws Exception
 */
+(BOOL) deleteRemoteFile:(NSString*) address path:(NSString*) path baseContext:(NSString*) baseContext timeout:(int)timeout;

/**
 * 列举远程文件夹
 *
 * @param address
 * @param path
 * @param baseContext
 * @param pathFormat
 * @param timeout
 * @return
 * @throws Exception
 */
+(NSArray<NSString*>*) listRemoteFile:(NSString*) address path: (NSString*) path baseContext:(NSString*)baseContext pathFormat:(NSString*)pathFormat timeout:(int)timeout;
/**
 * 获取远程文件的大小
 *
 * @param address
 * @param path
 * @param baseContext
 * @param timeout
 * @return
 * @throws Exception
 */
+(long)getRemoteFileSize:(NSString*) address path: (NSString*) path baseContext:(NSString*)baseContext   timeout:(int)timeout;

/**
 * 获取远程文件的MD5值
 *
 * @param address
 * @param path
 * @param baseContext
 * @return
 * @throws Exception
 */
+(NSString*) getRemoteFileStamp:(NSString*) address path: (NSString*) path baseContext:(NSString*)baseContext   timeout:(int)timeout ;

/**
 * 列举远程目录的MD5值
 *
 * @param address
 * @param path
 * @param baseContext
 * @param pathFormat
 * @param timeout
 * @return
 * @throws Exception
 */
+(NSArray<NSString*>*) listRemoteFileStamps:(NSString*) address path: (NSString*) path baseContext:(NSString*)baseContext pathFormat:(NSString*)pathFormat timeout:(int)timeout ;


/**
 * 直接下载文件
 *
 * @param downloadAddress (下载地址)
 * @param saveFile        (保存路径)
 * @param timeout         (超时限制)
 */
+(BOOL) directDownload:(NSString*) downloadAddress saveFile:(NSString*)saveFile timeout:(int)timeout
;

/**
 * 上传文件
 *
 * @param address    (上传地址)
 * @param savePath   (文件保存路径)
 * @param uploadFile (上传文件)
 * @param timeout    (超时限制)
 */
+(NSString*) directUpload:(NSString*) address savePath:(NSString*) savePath fileName:(NSString*)fileName uploadFile:(NSString*)uploadFile timeout:(int)timeout;



/**
 * 下载文件
 *
 * @param address     (下载地址)
 * @param path        (下载文件)
 * @param saveFile    (保存路径)
 * @param baseContext context(instant,workspace,configuration)
 * @param timeout     (超时限制)
 */
+(BOOL) download:(NSString*) address path:(NSString*) path  saveFile:(NSString*)saveFile baseContext:(NSString*)baseContext timeout:(int)timeout;
/**
 * 下载文件
 *
 * @param address     (下载地址)
 * @param path        (下载文件)
 * @param out         (输出流)
 * @param baseContext context(instant,workspace,configuration)
 * @param timeout     (超时限制)
 */
+(BOOL) download:(NSString*) address path: (NSString*) path baseContext:(NSString*)baseContext timeout:(int)timeout;
/**
 * 上传文件
 *
 * @param address     (上传地址)
 * @param savePath    (文件保存路径)
 * @param uploadFile  (上传文件)
 * @param baseContext context(instant,workspace,configuration)
 * @param timeout     (超时限制)
 */
+(BOOL) upload:(NSString*) address savePath:(NSString*) savePath fileName:(NSString*)fileName uploadFile:(NSString*)uploadFile baseContext:(NSString*)baseContext timeout:(int)timeout
;

/**
 * 上传文件
 *
 * @param address     (上传地址)
 * @param savePath    (文件保存路径)
 * @param in          (输入流)
 * @param baseContext context(instant,workspace,configuration)
 * @param timeout     (超时限制)
 */
+(BOOL) upload:(NSString*) address savePath: (NSString*) savePath fileName:(NSString*)fileName baseContext:(NSString*)baseContext timeout:(int)timeout;

/**
 * 批量下载文件
 *
 * @param address           (下载地址)
 * @param downloadDirectory (下载目录下)
 * @param downloadFilePaths (下载目录下指定需要下载的文件路径)
 * @param saveDir           (保存路径)
 * @param baseContext       context(instant,workspace,configuration)
 * @param checkValidity     (是否校验)
 */
+(BOOL) batchDownload:(NSString*) address downloadDirectory:(NSString*)downloadDirectory downloadFilePaths:(NSArray<NSString*>*)downloadFilePaths saveDir:(NSString*)saveDir baseContext:(NSString*)baseContext checkValidity:(BOOL)checkValidity timeout:(int)timeout;

/**
 * 获取临时文件
 *
 * @param path
 * @return
 */
+(NSString*)getTempFile:(NSString*) path;
/**
 * 获取ZIP文件
 *
 * @param path
 * @return
 */
+(NSString*) getZipFile:(NSString*) path ;

/**
 * 获取页面记录文件
 *
 * @param path
 * @return
 */
+(NSString*) getPageRecord:(NSString*) path ;

/**
 * 断点上传文件()
 *
 * @param address
 * @param uploadPath
 * @param fileName
 * @param uploadFile
 * @param baseContext
 * @param timeout
 * @param pageSize
 * @param callback
 * @return
 * @throws Exception
 */
+(BOOL) breakpointUpload:(NSString*) address uploadPath: (NSString*) uploadPath fileName:(NSString*)fileName uploadFile:(NSString*)uploadFile baseContext:(NSString*)baseContext timeout:(int)timeout pageSize:(int)pageSize callback:(id<ICallBackDelegate>)callback;




/**
 * 上传文件片段
 *
 * @param address
 * @param path
 * @param fileName
 * @param content
 * @param index
 * @param length
 * @param baseContext
 * @param timeout
 * @return
 * @throws Exception
 */
+(BOOL) uploadSegment:(NSString*) address path:(NSString*) path fileName:(NSString*)fileName content:(NSData*)content index:(long)index length:(long)length baseContext:(NSString*)baseContext timeout:(long)timeout ;

/**
 * 断点下载文件(和安卓一致)
 *
 * @param address     (下载地址)
 * @param path        (文件路径以程序的安装目录文起点路径)
 * @param saveFile    (保存目录)
 * @param baseContext context(instant,workspace,configuration)
 * @param timeout
 * @param pageSize    (页面大小KB)
 * @param callback
 */
+(BOOL) breakpointDownload:(NSString*) address path:(NSString*) path saveFile:(NSString*)saveFile baseContext:(NSString*)baseContext timeout:(int)timeout pageSize:(int)pageSize callback:(id<ICallBackDelegate>)callback;



/**
 * 下载文件片段
 *
 * @param address
 * @param path
 * @param saveFile
 * @param baseContext
 * @param timeout
 * @param index
 * @param length
 * @return
 * @throws Exception
 */
+(NSData*) downloadSegment:(NSString*) address path:(NSString*) path saveFile:(NSString*)saveFile baseContext:(NSString*)baseContext timeout:(int)timeout index:(long)index length:(long) length
;

/**
 * 请求服务
 * @param address
 * @param args
 * @param timeout
 * @return
 * @throws Exception
 */
+(NSString*) request:(NSString*) address args:(NSString*) args timeout:(int) timeout;

@end
