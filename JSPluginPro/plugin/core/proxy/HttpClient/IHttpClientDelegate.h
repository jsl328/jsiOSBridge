//
//  IHttpClientDelegate.h
//  core
//
//  Created by BruceXu on 2018/4/19.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#ifndef IHttpClientDelegate_h
#define IHttpClientDelegate_h
#import <JavaScriptCore/JavaScriptCore.h>
@protocol IHttpClientDelegate  <JSExport>

JSExportAs (upload,-(void) upload:(NSString*) address remoteSavePath:(NSString*) remoteSavePath  remoteFileName:(NSString*)remoteFileName
            uploadFilePath:(NSString*)uploadFilePath  timeout:(NSString*) timeout callback:(NSString*) callback);
JSExportAs (breakpointUpload,-(void) breakpointUpload:(NSString*) address  remoteSavePath:(NSString*) remoteSavePath remoteFileName: (NSString*) remoteFileName  uploadFilePath:(NSString*) uploadFilePath timeout:(NSString*)
            timeout pageSize:(NSString*) pageSize callback:(NSString*) callback);
JSExportAs (download,-(void) download: (NSString*) address remotePath:(NSString*) remotePath :(NSString*) savePath timeout: (NSString*) timeout  callback: (NSString*) callback );
JSExportAs (directDownload,-(void) directDownload: (NSString*) downloadAddress savePath: (NSString*) savePath timeout: (NSString*) timeout callback:(NSString*) callback);
JSExportAs (directUpload,-(void) directUpload: (NSString*) uploadAddress savePath:(NSString*) savePath  fileName: (NSString*) fileName uploadFilePath: (NSString*) uploadFilePath  timeout: (NSString*) timeout  callback:(NSString*) callback );
JSExportAs (breakpointDownload,-(void)breakpointDownload: (NSString*) address remotePath: (NSString*) remotePath  savePath: (NSString*) savePath timeout: (NSString*) timeout pageSize: (NSString*) pageSize callback: (NSString*) callback);
@end


#endif /* IHttpClientDelegate_h */
