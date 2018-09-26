//
//  FileProxy.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/14.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "FileProxy.h"
#import "FoxFileCoreDelegate.h"
#import "FileAccessor.h"
#import "WebViewController.h"
#import "CallBackObject.h"

@interface FileProxy ()<FoxFileCoreDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    CallBackObject *photoCallBack;
}
@property(strong) UIImagePickerController *controller ;
@end

@implementation FileProxy

- (void)openFile:(NSString *)path title:(NSString*)titile water:(NSString*)water  callback:(NSString *)callback {
    CallBackObject *fn = [[CallBackObject alloc] initWithCallback:callback];
    
    if (![[FileAccessor getInstance] exists:path]) {
        [fn runCode:[CallBackObject ERROR] message:@"路径不存在" data:@""];
    } else if (![[FileAccessor getInstance] isFile:path]) {
        [fn runCode:[CallBackObject ERROR] message:@"路径不是文件" data:@""];
    } else {
        //获取files Dir
        NSString *filesDir = [[FileAccessor getInstance] getFile:path];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 打开文件
            WebViewController *DocCon = [[WebViewController alloc] init];
            DocCon.URLString = filesDir;
            DocCon.titleString = titile;
            DocCon.waterString=water;
            DocCon.isWPS = YES;
            [[self.class rootViewController] presentViewController:DocCon animated:YES completion:^{
                [fn runCode:[CallBackObject SUCCESS] message:@"" data:@""];
            }];
        });
    }
    
}


- (NSString *)getAbsolutePath:(NSString *)path {
    return [[FileAccessor getInstance] getFile:path];
}

- (void)getContentAsString:(NSString *)path encoding:(NSString *)encoding  callback:(NSString *)callback {
    CallBackObject *fn = [[CallBackObject alloc] initWithCallback:callback];
    NSString *data= [[FileAccessor getInstance] getContentAsString:path encoding:NSUTF8StringEncoding];
    if (data) {
        [fn runCode:[CallBackObject SUCCESS] message:@"" data:@{@"content":data}];
    }
    else{
        [fn runCode:[CallBackObject SUCCESS] message:@"" data:@""];
    }
}

- (void)getContentAsBase64:(NSString *)path callback:(NSString *)callback {
    
    CallBackObject *fn = [[CallBackObject alloc] initWithCallback:callback];
    NSString *data=[[FileAccessor getInstance] getContentAsBase64:path];
    if(data){
        [fn runCode:[CallBackObject SUCCESS] message:@"" data:@{@"content":data}];
    }
    else{
        [fn runCode:[CallBackObject ERROR] message:@"获取base64失败！" data:@""];
    }
}

- (NSInteger)length:(NSString *)path {
    return [[FileAccessor getInstance] length:path];
}

- (BOOL)exists:(NSString *)path {
    return [[FileAccessor getInstance] exists:path];
}

- (BOOL)isDirectory:(NSString *)path {
    return [[FileAccessor getInstance] isDirectory:path];
}

- (BOOL)isFile:(NSString *)path {
    return [[FileAccessor getInstance] isFile:path];
}

- (void)deletePath:(NSString *)path callback:(NSString *)callback {
    CallBackObject *fn = [[CallBackObject alloc] initWithCallback:callback];
    if ([[FileAccessor getInstance] delete:path]) {
        [fn runCode:[CallBackObject SUCCESS] message:@"" data:@""];
    } else {
        [fn runCode:[CallBackObject ERROR] message:@"路径不存在或者删除失败" data:@""];
    }
}

- (void)list:(NSString *)path callback:(NSString *)callback {
    CallBackObject *fn = [[CallBackObject alloc] initWithCallback:callback];
    
    [fn runCode:[CallBackObject SUCCESS] message:@"" data:[[FileAccessor getInstance] list:path]];
}

- (void)copySrcPath:(NSString *)srcPath destPath:(NSString *)destPath  callback:(NSString *)callback {
    CallBackObject *fn = [[CallBackObject alloc] initWithCallback:callback];
    if ([[FileAccessor getInstance] copy:srcPath destPath:destPath]) {
        [fn runCode:[CallBackObject SUCCESS] message:@"" data:@""];
    } else {
        [fn runCode:[CallBackObject ERROR] message:@"SRC路径不存在或者拷贝失败" data:@""];
    }
}

- (void)moveSrcPath:(NSString *)srcPath destPath:(NSString *)destPath  callback:(NSString *)callback {
    CallBackObject *fn = [[CallBackObject alloc] initWithCallback:callback];
    if ([[FileAccessor getInstance] move:srcPath destPath:destPath]) {
        [fn runCode:[CallBackObject SUCCESS] message:@"" data:@""];
    } else {
        [fn runCode:[CallBackObject ERROR] message:@"SRC路径不存在或者拷贝失败" data:@""];
    }
}

- (void)choose:(NSString *)path reqData:(NSString *)reqData  callback:(NSString *)callback {

    
    
    self.controller = [[UIImagePickerController alloc]init];
    self.controller.delegate = self;
    self.controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self.rootViewController presentViewController:self.controller animated:YES completion:nil];
    
    
     photoCallBack = [[CallBackObject alloc] initWithCallback:callback];
  


}



#pragma mark =====UIImagePickerControllerDelegate=====
// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        FOXLog(@"Image was saved successfully.");
    } else {
        FOXLog(@"An error happened while saving the image.");
    }
}
// 当得到照片或者视频后，调用该方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //当image从相机中获取的时候存入相册中
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
    UIImageWriteToSavedPhotosAlbum(image,self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
    }
    if (image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        NSString *fileName=[NSUUID UUID].UUIDString;
        fileName=[NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [imageData writeToFile:fileName atomically:YES];
    
        [photoCallBack runCode:CallBackObject.SUCCESS message:@"" data:fileName];
    }
    else{
        [photoCallBack runCode:CallBackObject.ERROR message:@"图片获取失败" data:@""];
    }
    
    [picker  dismissViewControllerAnimated:YES completion:nil];
}
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error) {
        FOXLog(@"Picker save failure.");
    }else{
        FOXLog(@"Picker save successfully.");
    }
}
// 当用户取消时，调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    FOXLog(@"click cancel button");
    [picker  dismissViewControllerAnimated:YES completion:nil];
}




- (void)setContentAsString {
    
}

- (void)setContentAsBase64 {
    
}

- (void)encryptFile {
    
}

- (void)decryptFile {
    
}

@end
