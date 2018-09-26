//
//  LicenseManager.m
//  YXBuilder
//
//  Created by LiYuan on 2018/1/12.
//  Copyright © 2018年 YUSYS. All rights reserved.
//

#import "LicenseManager.h"
#import <UIKit/UIKit.h>
#include    <stdio.h>
#include    "yclic.h"

#define    BUF_SIZE    1024

@interface LicenseManager()

@end

@implementation LicenseManager

+ (BOOL)licenseCheck {
   
    return YES;
  //  NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"YTEC-0000000585-1-0000000401" ofType:@"lic"];
    
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"core.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *resourcePath = [bundle pathForResource:@"YTEC-0000000585-1-0000000401" ofType:@"lic"];
    
    char *file = (char*)[resourcePath UTF8String];
    int    r = 0;
    char    b[BUF_SIZE];
    YCLIC_T    l;
    
    //    /* Check arguments */
    //    if ( argc != 2 ) {
    //        fprintf( stderr, "Usage: %s <LicenseFile>\n", argv[0] );
    //        return 1;
    //    }
    
    /* Allocate license handle */
    if ( ( l = ycLicNew() ) == NULL ) {
        fprintf( stderr, "Failed to allocate license handle.\n" );
        goto _L0;
    }
    /* Open and load license file */
    int a = ycLicOpen( l, file );
    if ( ycLicOpen( l, file ) != YCLICRC_TRUE ) {
        fprintf( stderr, "Error on open license file: %s\n", ycLicGetErrMsg( l ) );
        goto _L1;
    }
    /* Get the build time of license */
    if ( ycLicGetBuildTime( l, b, BUF_SIZE ) != YCLICRC_TRUE ) {
        fprintf( stderr, "Error on get license build time: %s\n", ycLicGetErrMsg( l ) );
        goto _L2;
    }
    /* Print out build time value */
    printf( "build-time=[%s]\n", b );
    /* Add / Replace the 1st extend information */
    if ( ycLicPutExtendInfo( l, 1, "ExtendedInformationValue" ) == YCLICRC_ERROR ) {
        fprintf( stderr, "Error on put extend information: %s\n", ycLicGetErrMsg( l ) );
        goto _L2;
    }
_L3:
    r = 1;
_L2:
    /* Save and close license file */
    if ( ycLicClose( l, file ) == YCLICRC_ERROR ) {
        //        fprintf( stderr, "%s\n", ycLicGetErrMsg( Lic ) );
        goto _L1;
    }
_L1:
    /* Free license handle */
    ycLicFree( l );
_L0:
    return r;
    
//    NSString *returnResult = [licenseList checkJsonStringOfProjectLicense:@"yuxinlicense"];
//
//    NSLog(@"returnResult == %@",returnResult);
//
//    if ([returnResult isEqualToString:@"检验成功"]) {
//        return YES;
//    }
//    else{
//
//        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"验签没有通过" message:@"验签没有通过" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        alertView.tag = 1004;
//        [alertView show];
//        return NO;
//    }
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    if (1004 == alertView.tag){
//        UIWindow *window = [UIApplication sharedApplication].delegate.window;
//
//        [UIView animateWithDuration:1.0f animations:^{
//            window.alpha = 0;
//            window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
//        } completion:^(BOOL finished) {
//            exit(0);
//        }];
//    }
//}

@end
