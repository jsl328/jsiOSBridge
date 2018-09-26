//
//  FileAccessor.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "FileAccessor.h"
#import "Scope.h"
#import "FoxFileManager.h"
#import "Platform.h"
//#import "core.h"

#define APPID [[[[NSBundle mainBundle] bundleIdentifier] componentsSeparatedByString:@"."] lastObject]

@interface FileAccessor(){
    
}
@property(strong) NSMutableDictionary<NSString*,NSString*> *mineTypeMap;
@end
@implementation FileAccessor
static FileAccessor *_instance;


+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
/**
 * 获取local root path
 *
 * return
 */
-(NSString *)getLocalRoot{
    
    if(TESTLOAD){
    NSString *docDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Debug"];
    return docDir;
    }
    else {
    NSString *docDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Product"];
    return docDir;
    }
    
}
/**
 * 获取local cache root path
 *
 * return
 */
-(NSString *)getLocalCacheRoot {
    if(TESTLOAD){
    NSString *cachesDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Debug"];
        return cachesDir;
        
    }
    else{
    NSString *cachesDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
    stringByAppendingPathComponent:@"Product"];
    return cachesDir;
    }
    
}

/**
 * 获取default root path
 *
 * @return
 */

-(NSString *)getDefaultRoot {
    return [self getLocalRoot];
}

/**
 * 格式化路径
 *
 * @param path
 * @return
 */
-(NSString *)formatPath:(NSString*)path {
    //#TODO
    path= [path stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    // 去掉前面的‘/’
    while (path.length > 0 && [path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    // 去掉后面的‘/’
    while (path.length > 0 && [path hasSuffix:@"/"]) {
        int len = (int)path.length;
        path = [path substringToIndex:len-1];
    }
    return path;
}
/**
 * 构建全路径
 *
 * @param path
 * @return
 */
-(NSString *)constructAbsolutePath:(NSString*)path {
    if ([Scope.LocalScope match:path]) {
        //获取protocol
        NSString* protocol = Scope.LocalScope;
        //截取路径部分
        NSString* s = [path substringFromIndex:protocol.length];
        // 格式化路径
        s = [self formatPath:s];
        
        //获取files Dir
        NSString * absolutePath=[[self getLocalRoot] stringByAppendingPathComponent:s];
        return absolutePath;
    } else if ([Scope.LocalCacheScope match:path]) {
        //获取protocol
        NSString *protocol = Scope.LocalCacheScope;
        //截取路径部分
         NSString* s = [path substringFromIndex:protocol.length];
        // 格式化路径
        s = [self formatPath:s];
        
        //获取cache Dir
        NSString * absolutePath=[[self getLocalCacheRoot] stringByAppendingPathComponent:s];
        return absolutePath;
        
    } else if ([path hasPrefix:@"file:///"]) {
        //截取路径部分
        NSString *s = [path substringFromIndex:@"file:///".length];
        // 格式化路径
        s = [self formatPath:s];
        
        NSString* absolutePath =  [s stringByAppendingString:@"/"];
        return absolutePath;
    } else {
        int startIndex = (int)[path rangeOfString:@"/"].location;
        if (startIndex == 0) {
          
            NSArray *arr=  [path componentsSeparatedByString:@"/"];
            NSString *parentPath=arr[1];
          
            BOOL isDir=NO;
            [[NSFileManager defaultManager] fileExistsAtPath:parentPath isDirectory:&isDir];
            if(isDir)//是文件夹
            {
                return path;
            }
            else {
                NSString *s = [path  substringFromIndex:1];
                s = [self formatPath:s];
                //获取默认路径
                NSString *defaultRoot = [self getDefaultRoot];
                NSString* absolutePath =  [defaultRoot stringByAppendingPathComponent:s];
                return absolutePath;
            }
        } else {
            NSString *s = [self formatPath:path];
            //获取默认路径
            NSString *defaultRoot = [self getDefaultRoot];
            NSString* absolutePath =  [defaultRoot stringByAppendingPathComponent:s];
            return absolutePath;
        }
    }
}

/**
 * 创建此抽象路径名指定的目录，包括创建必需但不存在的父目录
 *
 * @param path
 * @return
 */
-(BOOL) mkdirs:(NSString*) path{
    return YES;
}
/**
 * 创建此抽象路径名指定的目录
 *
 * @param path
 * @return
 */
-(BOOL) mkdir:(NSString*) path{
    return YES;
}
/**
 * 创建文件
 *
 * @param path
 * @return
 * @throws IOException
 */
-(id)createNewFile:(NSString *)path{
    return nil;
}
/**
 * 判断文件或文件夹是否存在
 *
 * @param path
 * @return
 */

- (BOOL)exists:(NSString *)path {
    if(path==nil||path.length==0)
    {
        return NO;
    }
    NSString *file = [self getFile:path];
    
    return [FoxFileManager isExistsAtPath:file];
}

/**
 * 测试此抽象路径名表示的文件是否是一个目录
 *
 * @param path
 * @return
 */

- (BOOL)isDirectory:(NSString *)path {
    if(path==nil||path.length==0)
    {
        return NO;
    }
    NSString *file = [self getFile:path];
    
    return [FoxFileManager isDirectoryAtPath:file];
}
/**
 * 测试此抽象路径名表示的文件是否是一个文件
 *
 * @param path
 * @return
 */
- (BOOL)isFile:(NSString *)path {
    return ![self isDirectory:path];
}

/**
 * 获取文件路径
 *
 * @param path
 * @return
 */
-(NSString*)getFile:(NSString *)path {
    NSString* absolutePath = [self constructAbsolutePath:path];
    absolutePath = [absolutePath stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    absolutePath = [absolutePath stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return absolutePath;
}
 
/**
 * 获取文件
 *
 * param path
 * param scopes (if scope is NULL, the default will be Scope.LocalScope,Scope.LocalExtScope,Scope.LocalCacheScope,Scope.LocalExtCacheScope)
 * return
 */

-(id)getFile:(NSString*)path scopes:(NSArray<Scope*>*)scopes{
    return nil;
}
/**
 * 打开文件
 *
 * @param path
 * @return
 */
-(BOOL)openFile:(NSString*)path{
    return YES;
}
///**
// * 打开文件
// *
// * @param file
// * @return
// */
//-(BOOL)openFile:(id)file{
//    return YES;
//}
///**
// * 根据文件类型，获取Intent
// *
// * @param file
// * @param mimeType
// * @return
// */
//private Intent getIntentByMimeType(File file, String mimeType) {
//    Intent intent = new Intent("android.intent.action.VIEW");
//    intent.addCategory("android.intent.category.DEFAULT");
//    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//    Uri uri = Uri.fromFile(file);
//    intent.setDataAndType(uri, mimeType);
//    return intent;
//}

-(NSString*)getMIMEType:(NSArray<NSString*>*)suffixs{
    return @"";
}


/**
 * 获取mine type
 *
 * @param file
 * @return
 */
//private String getMIMEType(File file) {
//    // 获取文件路径
//    String name = file.getName();
//
//    int index = name.lastIndexOf(".");
//    if (index == -1 || index == (name.length() - 1)) {
//        return "*/*";
//    }
//    // 获取文件类型
//    String type = name.substring(index + 1);
//    //获取mime type
//    String mimeType = this.getMIMEType(new String[]{type});
//    return mimeType;
//
//}

/**
 * 打开文件
 *
 * @param file
 * @return
 */
-(NSData*) openFileData:(NSString *)file{
    if(![FoxFileManager isExistsAtPath:file]){
        FOXLog(@"file[%@]not exist",file);
        return nil;
    }
    return  [NSData dataWithContentsOfFile:file];
}
//
///**
// * 打开输出流
// *
// * @param file
// * @return
// */
//public OutputStream openOutputStream(File file) throws IOException {
//    File parent = file.getParentFile();
//    if (!parent.isDirectory()) {
//        parent.mkdirs();
//    }else{
//        this.deleteFile(file);
//    }
//
//    OutputStream out = new SecurityOutputStream(new BufferedOutputStream(new FileOutputStream(file)));
//    return out;
//}


///**
// * 打开输入流
// *
// * @param file
// * @return
// */
//public InputStream openRawInputStream(File file) throws IOException {
//    if (!file.exists()) {
//        StringBuilder sb = new StringBuilder();
//        sb.append("file[");
//        sb.append(file.getAbsolutePath());
//        sb.append("]not exist");
//        throw new IOException(sb.toString());
//    }
//    InputStream in = new BufferedInputStream(new FileInputStream(file));
//    return in;
//}
//
///**
// * 打开输出流
// *
// * @param file
// * @return
// */
//public OutputStream openRawOutputStream(File file) throws IOException {
//    File parent = file.getParentFile();
//    if (!parent.isDirectory()) {
//        parent.mkdirs();
//    }else{
//        this.deleteFile(file);
//    }
//
//    OutputStream out = new BufferedOutputStream(new FileOutputStream(file));
//    return out;
//}


/**
 * 以BASE64字符串返回内容
 *
 * @param path
 * @return
 * @throws Exception
 */
- (NSString*)getContentAsBase64:(NSString*)path {
    NSString *contentStr = [self getContentAsString:path encoding:NSUTF8StringEncoding];
    NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *stringBase64 = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    //去掉\r,\n
    stringBase64= [stringBase64 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    stringBase64= [stringBase64 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return stringBase64;
}

/**
 * 以字符串返回内容
 *
 * @param path
 * @param encoding
 * @return
 * @throws Exception
 */
- (NSString *)getContentAsString:(NSString*)path encoding:(NSStringEncoding) encoding
  {
      if(path==nil||path.length==0)
      {
          return nil;
      }
      NSString *file = [self getFile:path];
      if([FoxFileManager isExistsAtPath:file] && [FoxFileManager isFileAtPath:file]){
          NSString *content=[FoxFileManager getFileAtPath:file encoding:NSUTF8StringEncoding];
          //去掉\r,\n
          content= [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
          content= [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//          return @"fdsfdsfdsfsdf";
          return content;
      } else {
          return nil;
      }
  }
///**
// * 以字符串返回内容
// *
// * @param file
// * @param encoding
// * @return
// * @throws Exception
// */
//public String getContentAsString(File file, String encoding)
//throws IOException {
//    byte[] bytes = this.getContentAsBytes(file);
//    String s = new String(bytes, encoding);
//    return s;
//}

///**
// * 以字节数组返回内容
// *
// * @param path
// * @return
// * @throws Exception
// */
//public byte[] getContentAsBytes(String path) throws IOException {
//    File file = this.getFile(path);
//    return this.getContentAsBytes(file);
//}
//
///**
// * 以字节数组返回内容
// *
// * @param file
// * @return
// * @throws Exception
// */
//public byte[] getContentAsBytes(File file) throws IOException {
//    ByteArrayOutputStream byteOut = new ByteArrayOutputStream();
//    InputStream in = null;
//    try {
//        // 获取输入流
//        in = this.openInputStream(file);
//        byte[] buffer = new byte[1024];
//        int len = -1;
//        while ((len = in.read(buffer)) != -1) {
//            byteOut.write(buffer, 0, len);
//        }
//    } finally {
//        if (in != null) {
//            in.close();
//        }
//    }
//    byte[] bytes = byteOut.toByteArray();
//    return bytes;
//}
//
///**
// * 以字节数组返回内容
// *
// * @param file
// * @return
// * @throws Exception
// */
//public byte[] getRawContentAsBytes(File file) throws IOException {
//    ByteArrayOutputStream byteOut = new ByteArrayOutputStream();
//    InputStream in = null;
//    try {
//        // 获取输入流
//        in = this.openRawInputStream(file);
//        byte[] buffer = new byte[1024];
//        int len = -1;
//        while ((len = in.read(buffer)) != -1) {
//            byteOut.write(buffer, 0, len);
//        }
//    } finally {
//        if (in != null) {
//            in.close();
//        }
//    }
//    byte[] bytes = byteOut.toByteArray();
//    return bytes;
//}
//


/**
 * 设置内容
 *
 * @param path
 * @param content
 */
-(void)setContentAsBase64:(NSString*)path content:(NSString*)content{
    
}

/**
 * 设置内容
 *
 * @param path
 * @param content
 */
-(void)setContentAsString:(NSString*) path content: (NSString*) content encoding:( NSString*) encoding {
    
}
/**
 * 设置内容
 *
 * @param file
 * @param content
 */
//public void setContentAsString(File file, String content, String encoding) throws IOException {
//    byte[] bytes = content.getBytes(encoding);
//    this.setContentAsBytes(file, bytes);
//}

/**
 * 设置内容
 *
 * @param path
 * @param content
 */
//public void setContentAsBytes(String path, byte[] content) throws IOException {
//    File file = this.getFile(path);
//    this.setContentAsBytes(file, content);
//}
//
///**
// * 设置内容
// *
// * @param file
// * @param content
// */
//public void setContentAsBytes(File file, byte[] content) throws IOException {
//
//    //输出流
//    OutputStream out = null;
//    try {
//        out = this.openOutputStream(file);
//        out.write(content);
//        out.flush();
//    } finally {
//        //关闭输出流
//        if (out != null) {
//            try {
//                out.close();
//            } catch (Exception e) {
//                logger.error(e.getMessage(), e);
//            }
//        }
//    }
//
//}
//
///**
// * 设置内容
// *
// * @param file
// * @param content
// */
//public void setRawContentAsBytes(File file, byte[] content) throws IOException {
//    //输出流
//    OutputStream out = null;
//    try {
//        out = this.openRawOutputStream(file);
//        out.write(content);
//        out.flush();
//    } finally {
//        //关闭输出流
//        if (out != null) {
//            try {
//                out.close();
//            } catch (Exception e) {
//                logger.error(e.getMessage(), e);
//            }
//        }
//    }
//
//}

/**
 * 返回此抽象路径名表示的文件最后一次被修改的时间
 *
 * @return
 */
-(long) lastModified:(NSString*)path{
    return 0;
}
/**
 * 置由此抽象路径名所指定的文件或目录的最后一次修改时间
 *
 * @param path
 * @param time
 * @return
 */
-(BOOL)setLastModified:(NSString*) path time: (long) time {
    return YES;
}
/**
 * 返回由此抽象路径名表示的文件的长度。如果此路径名表示一个目录，则返回值是不确定的
 *
 * @return
 */
- (long)length:(NSString *)path {
    if(path==nil||path.length==0)
    {
        return 0;
    }
    NSString *file=[self getFile:path];
    if(![FoxFileManager isExistsAtPath:file]){
        return 0;
    } else {
        return [[FoxFileManager sizeOfItemAtPath:file] longValue];
    }
}
/**
 * 删除此抽象路径名表示的文件或目录
 *
 * @param path
 * @return
 */
-(BOOL)delete:(NSString*)path{
    if(path==nil||path.length==0)
    {
        return NO;
    }
    NSString *file=[self getFile:path];
    if(![FoxFileManager isExistsAtPath:file]){
        return NO;
    }
    BOOL res=[self deleteFile:file];
    return  res;
}
/**
 * 删除此抽象路径名表示的文件或目录
 *
 * @param file
 * @return
 */
-(BOOL)deleteFile:(NSString*) file {
    
   return  [FoxFileManager removeItemAtPath:file];
   
   
}

///**
// * 安全删除文件.
// * @param file
// * @return
// */
//public  boolean deleteFileSafely(File file) {
//    if (file != null) {
//        StringBuilder sb=new StringBuilder();
//        sb.append(file.getAbsolutePath());
//        sb.append(System.currentTimeMillis());
//        String path=sb.toString();
//        File tmp=new File(path);
//        file.renameTo(tmp);
//        return tmp.delete();
//    }
//    return false;
//}
//
///**
// * 返回一个抽象路径名数组，这些路径名表示此抽象路径名所表示目录中的文件
// *
// * @param path
// * @return
// */
//public File[] listFiles(String path) {
//    // 获取文件
//    File file = this.getFile(path);
//    // 如果文件不存在，则返回空的
//    if (!file.exists()) {
//        return null;
//    }
//    // 列举文件
//    File[] files = file.listFiles();
//    return files;
//}

- (BOOL)createDirectoryAtPath:(NSString *)path {
    if(path==nil||path.length==0)
    {
        return NO;
    }
    NSString *file = [self getFile:path];
    if([FoxFileManager isExistsAtPath:file]){
        return YES;
    }
    NSError *error;
    return [FoxFileManager createDirectoryAtPath:file error:&error];
}

- (BOOL)copy:(NSString*)srcPath destPath:(NSString*)destPath {
    if(srcPath==nil||srcPath.length==0)
    {
        return NO;
    }
    NSString *file = [self getFile:srcPath];
    NSString *destFile = [self getFile:destPath];
    if(![FoxFileManager isExistsAtPath:file]){
        return NO;
    }
    NSError *error;
    return [FoxFileManager copyItemAtPath:file toPath:destFile overwrite:YES error:&error];
}

///**
// * 拷贝文件
// *
// * @param srcFile
// * @param targetFile
// */
//public void copy(File srcFile, File targetFile) throws Exception {
//    // 拷贝文件
//    this.copy(srcFile, targetFile, -1L, -1L);
//}

//**
//* 拷贝文件
//*
//* @param srcFile
//* @param targetFile
//* @param offset
//* @param length
//*/
//public void copy(File srcFile, File targetFile, long offset, long length)
//throws Exception {
//    File parent = targetFile.getParentFile();
//    if (!parent.exists()) {
//        parent.mkdirs();
//    }else{
//        //删除目标文件
//        deleteFile(targetFile);
//    }
//
//    // 输入流
//    FileInputStream in = null;
//    // 输出流
//    FileOutputStream out = null;
//    // 源通道
//    FileChannel srcChannel = null;
//    // 目标通道
//    FileChannel targetChannel = null;
//    try {
//        in = new FileInputStream(srcFile);
//        out = new FileOutputStream(targetFile);
//        // 获取输入通道
//        srcChannel = in.getChannel();
//        // 获取输出通道
//        targetChannel = out.getChannel();
//        // 传送文件
//        if (offset == -1) {
//            offset = 0;
//        }
//        if (length == -1) {
//            length = srcFile.length();
//        }
//        srcChannel.transferTo(offset, length, targetChannel);
//    } finally {
//        if (srcChannel != null) {
//            try {
//                srcChannel.close();
//            } catch (Exception e) {
//                logger.error(e.getMessage(), e);
//            }
//        }
//
//        if (targetChannel != null) {
//            try {
//                targetChannel.close();
//            } catch (Exception e) {
//                logger.error(e.getMessage(), e);
//            }
//        }
//
//        if (in != null) {
//            try {
//                in.close();
//            } catch (Exception e) {
//                logger.error(e.getMessage(), e);
//            }
//        }
//
//        if (out != null) {
//            try {
//                out.close();
//            } catch (Exception e) {
//                logger.error(e.getMessage(), e);
//            }
//        }
//    }
//}

- (BOOL)move:(NSString*)srcPath destPath:(NSString*)destPath {
    
    if(srcPath==nil||srcPath.length==0)
    {
        return NO;
    }
    NSString *file = [self getFile:srcPath];
    NSString *destFile = [self getFile:destPath];
    if(![FoxFileManager isExistsAtPath:file]){
        return NO;
    }
    NSError *error;
    return [FoxFileManager moveItemAtPath:file toPath:destFile overwrite:YES error:&error];
}

- (NSArray *)list:(NSString*)path {
    NSMutableArray *listArr = [NSMutableArray array];
    if(path==nil||path.length==0)
    {
        NSArray *list=[FoxFileManager listFilesInDocumentDirectoryByDeep:NO];
        for (NSString *path in list) {
            
            if ([FoxFileManager isFileAtPath:path]) {
                [listArr addObject:path];
            }
        }
        return listArr;
    } else {
        NSString *file = [self getFile:path];
        if([FoxFileManager isExistsAtPath:file]){
            NSArray*list=[FoxFileManager listFilesInDirectoryAtPath:file deep:NO];
            for (NSString *path in list) {
                NSString *pathfull=[file stringByAppendingPathComponent:path];
                if ([FoxFileManager isFileAtPath:pathfull]) {
                    [listArr addObject:path];
                }
            }
            return listArr;
        } else {
            return nil;
        }
    }
}

///**
// * 选择文件
// *
// * @param path
// * @param suffixs
// * @param callback
// * @return
// */
//public void choose(String path, String[] suffixs, final ICallback callback) {
//    final Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
//    String mimeTypes = this.getMIMEType(suffixs);
//    intent.setType(mimeTypes);
//    intent.addCategory(Intent.CATEGORY_OPENABLE);
//
//    // 获取intent invoker
//    IntentInvoker intentInvoker = Platform.getInstance()
//    .getIntentInvoker();
//    //获取请求code
//    int requestCode = intentInvoker.getRequestCode();
//    //定义intent listener
//    IntentListener listener = new IntentListener() {
//
//        /**
//         * handle result
//         * @param requestCode
//         * @param resultCode
//         * @param data
//         */
//        public void handleResult(int requestCode, int resultCode, Intent data) {
//            if (resultCode == Activity.RESULT_OK) {
//                //得到uri，后面就是将uri转化成file的过程
//                Uri uri = data.getData();
//                //获取路径
//                String path = FileUtils.getPath(Platform.getInstance().getContext(), uri);
//
//                if (path != null) {
//                    //成功回调
//                    callback.run(ICallback.SUCCESS, "", path);
//                } else {
//                    //失败回调
//                    callback.run(ICallback.ERROR, "文件解析失败", "");
//                }
//
//            } else if (resultCode == Activity.RESULT_CANCELED) {
//                //取消操作
//                callback.run(ICallback.CANCEL, "取消选择", "");
//            }
//        }
//    };
//    try {
//        // 打开文件选择
//        intentInvoker.invoke(requestCode, intent, listener);
//    } catch (Exception e) {
//        logger.error(e.getMessage(), e);
//        callback.run(ICallback.ERROR, e.getMessage(), "");
//    }
//}

///**
// * 申请访问扩展存储空间权限
// *
// * @param callback
// */
//public void applyExtStoragePermission(final ICallback callback) {
//    //定义callback
//    PermissionCallback permissionCallback = new PermissionCallback() {
//        /**
//         * 申请通过
//         * @param permissions
//         */
//        public void onPermissionGranted(String[] permissions) {
//            //错误回调
//            callback.run(ICallback.SUCCESS, "", "success");
//        }
//
//        /**
//         * 申请拒绝
//         * @param permissions
//         */
//        public void onPermissionDeclined(String[] permissions) {
//            //错误回调
//            callback.run(ICallback.ERROR, "无权限访问存储", "fail");
//        }
//    };
//    //权限申请
//    PermissionHelper.requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE},
//                                        "APP需要赋予访问存储的权限，不开启将无法正常工作！",
//                                        permissionCallback);
//}
//
///**
// * 判断是否需要申请扩展存储空间的授权
// *
// * @param path
// * @return
// */
//public boolean needApplyExtStoragePermission(String path) {
//    //获取扩展空间的APP根目录
//    String localExtRoot = this.getLocalExtRoot();
//    if (path.startsWith(localExtRoot)) {
//        return false;
//    }
//
//    //获取扩展缓存空间的APP根目录
//    String localExtCacheRoot = this.getLocalExtRoot();
//    if (path.startsWith(localExtCacheRoot)) {
//        return false;
//    }
//    //获取扩展空间存储根路径
//    String extRootPath = Environment.getExternalStorageDirectory().getPath();
//    return path.startsWith(extRootPath);
//}
//
///**
// * 加密文件
// *
// * @param srcFile
// * @param targetFile
// * @return
// */
//public boolean encryptFile(File srcFile, File targetFile) throws IOException {
//    ByteArrayOutputStream byteOut = new ByteArrayOutputStream();
//    //定义输入流
//    BufferedInputStream in = null;
//    try {
//        //创建输入流
//        in = new BufferedInputStream(new FileInputStream(srcFile));
//        byte[] buffer = new byte[1024];
//        int len = -1;
//        while ((len = in.read(buffer)) != -1) {
//            byteOut.write(buffer, 0, len);
//        }
//    } finally {
//        if (in != null) {
//            in.close();
//        }
//    }
//
//    //定义输出流
//    BufferedOutputStream out = null;
//    try {
//        //获取安全管理器
//        SecurityManager securityManager = SecurityManager.getInstance();
//        //获取秘钥套件
//        ICipher cipher = securityManager.getCipher();
//        //待加密内容
//        byte[] bytes = byteOut.toByteArray();
//        //加密内容
//        byte[] encBytes = cipher.encrypt(bytes);
//        //创建输出流
//        out = new BufferedOutputStream(new FileOutputStream(targetFile));
//        out.write(encBytes);
//        out.flush();
//        return true;
//    } catch (Exception e) {
//        throw new IOException(e.getMessage(), e);
//    } finally {
//        if (out != null) {
//            out.close();
//        }
//    }
//}
//
///**
// * 解密文件
// *
// * @param srcFile
// * @param targetFile
// * @return
// */
//public boolean decryptFile(File srcFile, File targetFile) throws IOException {
//    ByteArrayOutputStream byteOut = new ByteArrayOutputStream();
//    //定义输入流
//    BufferedInputStream in = null;
//    try {
//        //创建输入流
//        in = new BufferedInputStream(new FileInputStream(srcFile));
//        byte[] buffer = new byte[1024];
//        int len = -1;
//        while ((len = in.read(buffer)) != -1) {
//            byteOut.write(buffer, 0, len);
//        }
//    } finally {
//        if (in != null) {
//            in.close();
//        }
//    }
//
//    //定义输出流
//    BufferedOutputStream out = null;
//    try {
//        //获取安全管理器
//        SecurityManager securityManager = SecurityManager.getInstance();
//        //获取秘钥套件
//        ICipher cipher = securityManager.getCipher();
//        //待解密内容
//        byte[] bytes = byteOut.toByteArray();
//        //j解密内容
//        byte[] decBytes = cipher.decrypt(bytes);
//        //创建输出流
//        out = new BufferedOutputStream(new FileOutputStream(targetFile));
//        out.write(decBytes);
//        out.flush();
//        return true;
//    } catch (Exception e) {
//        throw new IOException(e.getMessage(), e);
//    } finally {
//        if (out != null) {
//            out.close();
//        }
//    }
//}
- (NSArray*) allFilesPathAtFPath:(NSString*) dirString withType:(NSString *)type {
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    NSArray* tempArray = [fileMgr contentsOfDirectoryAtPath:dirString error:nil];
    
    for (NSString* fileName in tempArray) {
        
        if([fileName containsString:[NSString stringWithFormat:@".%@",type]]){
            BOOL flag = YES;
            
            NSString* fullPath = [dirString stringByAppendingPathComponent:fileName];
            
            if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag]) {
                
                if (!flag) {
                    
                    [array addObject:fullPath];
                    
                }
                
            }}
        
    }
    
  
    
    return array;
    
}
- (NSArray*) allFilesNameAtFPath:(NSString*) dirString withType:(NSString *)type {
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    NSArray* tempArray = [fileMgr contentsOfDirectoryAtPath:dirString error:nil];
    
    for (NSString* fileName in tempArray) {
        
        if([fileName containsString:[NSString stringWithFormat:@".%@",type]]){
            BOOL flag = YES;
            
            NSString* fullPath = [dirString stringByAppendingPathComponent:fileName];
            
            if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag]) {
                
                if (!flag) {
                    
                    [array addObject:fileName];
                    
                }
                
            }}
        
    }
    
    return array;
    
}
- (NSArray*) allDirectoryPathAtFPath:(NSString*) dirString withType:(NSString *)type {
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    NSArray* tempArray = [fileMgr contentsOfDirectoryAtPath:dirString error:nil];
    
    for (NSString* fileName in tempArray) {
        
        if([fileName containsString:[NSString stringWithFormat:@".%@",type]]){
            BOOL flag = NO;
            
            NSString* fullPath = [dirString stringByAppendingPathComponent:fileName];
            
            if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag]) {
                
                if (flag) {
                    
                    [array addObject:fullPath];
                    
                }
                
            }}
        
    }
    
    
    
    return array;
    
}
- (NSArray*) allDirectoryNameAtFPath:(NSString*) dirString withType:(NSString *)type {
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    NSArray* tempArray = [fileMgr contentsOfDirectoryAtPath:dirString error:nil];
    
    for (NSString* fileName in tempArray) {
        
        if([fileName containsString:[NSString stringWithFormat:@".%@",type]]){
            BOOL flag =NO;
            
            NSString* fullPath = [dirString stringByAppendingPathComponent:fileName];
            
            if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag]) {
                
                if (flag) {
                    
                    [array addObject:fileName];
                    
                }
                
            }}
        
    }
    
    return array;
    
}



-(NSArray*)loadAllXMLNameFromCustomBundle{
//    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@“core.bundle”];
//    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
//    NSString *filePath = [bundle pathForResource:fileName ofType:fileType];
   
    NSArray *bundleArr= [self allDirectoryNameAtFPath:[NSBundle mainBundle].bundlePath withType:@"bundle"];
    NSMutableArray *allXMlArray=[NSMutableArray new];
    for(int i=0;i<bundleArr.count;i++){
       NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:bundleArr[i]];
       NSArray*tempArry=[self allFilesNameAtFPath:bundlePath withType:@"xml"];
        if(tempArry&&tempArry.count){
            [allXMlArray addObjectsFromArray:tempArry];
        }
    }
    return  [allXMlArray copy];
    
    }
-(NSArray*)loadAllXMLPathFromCustomBundle{
    NSArray *bundleArr= [self allDirectoryNameAtFPath:[NSBundle mainBundle].bundlePath withType:@"bundle"];
    NSMutableArray *allXMlArray=[NSMutableArray new];
    for(int i=0;i<bundleArr.count;i++){
        NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:bundleArr[i]];
        NSArray*tempArry=[self allFilesPathAtFPath:bundlePath withType:@"xml"];
        if(tempArry&&tempArry.count){
            [allXMlArray addObjectsFromArray:tempArry];
        }
    }
    return  [allXMlArray copy];
    
}


@end
