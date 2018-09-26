//
//  HttpClient.h
//  core
//
//  Created by BruceXu on 2018/4/19.
//  Copyright © 2018年 BruceXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXPlugin.h"
@interface HttpClient :YXPlugin
-(void) upload:(NSString*) address remoteSavePath:(NSString*) remoteSavePath  remoteFileName:(NSString*)remoteFileName
uploadFilePath:(NSString*)uploadFilePath  timeout:(NSString*) timeout callback:(NSString*) callback;

-(void) breakpointUpload:(NSString*) address  remoteSavePath:(NSString*) remoteSavePath remoteFileName: (NSString*) remoteFileName  uploadFilePath:(NSString*) uploadFilePath timeout:(NSString*)
timeout pageSize:(NSString*) pageSize callback:(NSString*) callback ;


-(void) download: (NSString*) address remotePath:(NSString*) remotePath :(NSString*) savePath timeout: (NSString*) timeout  callback: (NSString*) callback ;


-(void) directDownload: (NSString*) downloadAddress savePath: (NSString*) savePath timeout: (NSString*) timeout callback:(NSString*) callback;
    
    
-(void) directUpload: (NSString*) uploadAddress savePath:(NSString*) savePath  fileName: (NSString*) fileName uploadFilePath: (NSString*) uploadFilePath  timeout: (NSString*) timeout  callback:(NSString*) callback ;


-(void) breakpointDownload: (NSString*) address remotePath: (NSString*) remotePath  savePath: (NSString*) savePath timeout: (NSString*) timeout pageSize: (NSString*) pageSize callback: (NSString*) callback ;
@end
