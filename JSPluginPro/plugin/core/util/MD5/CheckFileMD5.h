//
//  CheckFileMD5.h
//  dlns
//
//  Created by 王保仲 on 14-9-18.
//
//

#import <Foundation/Foundation.h>

@interface CheckFileMD5 : NSObject

+(NSString*)getFileMD5WithPath:(NSString*)path;
+(NSString*) md5:(NSString*) str;
@end
