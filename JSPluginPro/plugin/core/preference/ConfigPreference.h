//
//  ConfigPreference.h
//  YXBuilder
//
//  Created by BruceXu on 2017/12/16.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigPreference : NSObject

+ (instancetype)getInstance;

-(void)loadConfigFile:(NSString*)file configMap:(NSMutableDictionary<NSString*,NSMutableDictionary<NSString*,id>*>*)configMap;

/**
 * 保存配置文件
 *
 * param file
 * param configMap
 */
-(void) saveConfigFile:(NSString*) file configMap:(NSMutableDictionary<NSString*,NSMutableDictionary<NSString*,id>*>*)configMap
;

-(void) put:(NSString*) mark key: (NSString*) key value: (id)value ;

-(void) putBoolean:(NSString*) mark key: (NSString*) key value:(BOOL) value ;
-(void)putDouble:(NSString*) mark key: (NSString*) key value:(double) value ;

/**
 * Associates the specified float object with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @param value
 */
-(void)putFloat:(NSString*) mark key: (NSString*) key value:(float) value ;

/**
 * Associates the specified Integer object with the specified mark and key
 * in this node.
 *
 * @param mark
 * @param key
 * @param value
 */
-(void)putInt:(NSString*) mark key: (NSString*) key value:(int) value ;

/**
 * Associates the specified long object with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @param value
 */
-(void)putLong:(NSString*) mark key: (NSString*) key value:(long) value ;

/**
 * Associates the specified string object with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @param value
 */
-(void)putString:(NSString*) mark key: (NSString*) key value:(NSString*) value ;

/**
 * Returns the value associated with the specified mark and key in this
 * node.
 *
 * @param mark
 * @param key
 * @param defaultValue
 * @return
 */
-(id) get:(NSString*) mark key:(NSString*) key defaultValue:(id)defaultValue ;
/**
 * Returns the Boolean object associated with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @param defaultValue
 * @return
 */
-(BOOL)getBoolean:(NSString*) mark key:(NSString*) key  defaultValue:(BOOL) defaultValue;

/**
 * Returns the double object associated with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @return
 */
-(double) getDouble:(NSString*) mark key:(NSString*) key  defaultValue:(double) defaultValue;

/**
 * Returns the float object associated with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @param defaultValue
 * @return
 */
-(float) getFloat:(NSString*) mark key:(NSString*) key  defaultValue:(float) defaultValue ;

/**
 * Returns the Integer object associated with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @param defaultValue
 * @return
 */
-(int) getInt:(NSString*) mark key:(NSString*) key  defaultValue:(int) defaultValue ;

/**
 * Returns the long object associated with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @return
 */
-(long)getLong:(NSString*) mark key:(NSString*) key  defaultValue:(long) defaultValue ;

/**
 * Returns the string object associated with the specified mark and key in
 * this node.
 *
 * @param mark
 * @param key
 * @return
 */
-(NSString*) getString:(NSString*) mark key:(NSString*) key  defaultValue:(NSString*) defaultValue ;
/**
 * 刷新数据
 */
-(void) refresh;
/*** 把数据写到文件中数据
 */
-(void) flush ;

@end
