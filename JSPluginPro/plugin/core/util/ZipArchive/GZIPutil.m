//
//  GZIPutil.m
//  core
//
//  Created by BruceXu on 2018/4/20.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import "GZIPutil.h"
#import "ZipArchive.h"
@implementation GZIPutil
/**
 *  根据路径将文件压缩为zip到指定路径
 *
 *  @param sourcePath 压缩文件夹路径
 *  @param destZipFile 存放路径（保存重命名）
 */
+(void) doZipAtPath:(NSString*)sourcePath to:(NSString*)destZipFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    ZipArchive * zipArchive = [ZipArchive new];
    [zipArchive CreateZipFile2:destZipFile];
    NSArray *subPaths = [fileManager subpathsAtPath:sourcePath];// 关键是subpathsAtPath方法
    for(NSString *subPath in subPaths){
        NSString *fullPath = [sourcePath stringByAppendingPathComponent:subPath];
        BOOL isDir;
        if([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir)// 只处理文件
        {
            [zipArchive addFileToZip:fullPath newname:subPath];
        }
    }
    [zipArchive CloseZipFile2];
}
- (NSData *)unzip:(NSData*)data
{
    if ([data length] == 0) return data;
    
    unsigned long full_length = [data length];
    unsigned long  half_length = [data length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = (uInt)[data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK)
        return nil;
    
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([decompressed length] - strm.total_out);
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END)
            done = YES;
        else if (status != Z_OK)
            break;
    }
    if (inflateEnd (&strm) != Z_OK)
        return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}
-(NSData *)zip:(NSData *)uncompressedData
{
    if ([uncompressedData length] == 0) return uncompressedData;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[uncompressedData bytes];
    strm.avail_in = (unsigned int)[uncompressedData length];
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (unsigned int)([compressed length] - strm.total_out);
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}
@end
