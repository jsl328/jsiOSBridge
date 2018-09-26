//
//  PropertiesUtil.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/15.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "PropertiesUtil.h"
#include <stdio.h>
/**
 * properties 工具
 */
@implementation PropertiesUtil

+ (NSDictionary<NSString*,NSString*>*) load:(NSString*)fileName fileType:(NSString*)fileType encoding:(NSStringEncoding)encoding{
    
    NSMutableDictionary<NSString*,NSString*>*configMap=[ NSMutableDictionary<NSString*,NSString*> new];
    
   //NSString *filePath=[[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
    
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"core.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *filePath = [bundle pathForResource:fileName ofType:fileType];
    
    //通过流打开一个文件
    
    char szTest[1000] = {0};
    
    
    FILE *fp = fopen([filePath cStringUsingEncoding:encoding], "r");
    if(NULL == fp)
    {
        printf("打开文件失败\n");
        
    }
    
    while(!feof(fp))
    {
        memset(szTest, 0, sizeof(szTest));
        fgets(szTest, sizeof(szTest) - 1, fp); // 包含了\n
        printf("%s", szTest);
        NSString * lineText= [[NSString alloc] initWithCString:szTest
                                                      encoding:encoding];
        //空格忽略
        if([lineText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length==0){
            continue;
            }
        //#忽略
        if([lineText characterAtIndex:0]=='#'){
            continue;
        }
        NSString *key  =[lineText componentsSeparatedByString:@"="][0] ;
        NSString *value=[lineText componentsSeparatedByString:@"="][1] ;
        value=[value stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        value=[value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        key=[key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //value=[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [configMap setObject:value forKey:key];
    }
    
    fclose(fp);
    return [configMap copy];
}

@end
