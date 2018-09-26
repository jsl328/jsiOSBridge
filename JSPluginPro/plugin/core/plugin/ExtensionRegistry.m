//
//  ExtensionRegistry.m
//  YXBuilder
//
//  Created by BruceXu on 2017/12/12.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "ExtensionRegistry.h"
#import "IExtensionPointDelegate.h"
#import "IExtensionDelegate.h"
#import "IConfigElementDelegate.h"
#import "StackForNSObject.h"
#import "FileAccessor.h"
#import "Platform.h"
/**
 * stack node
 */
@interface StackNode:NSObject
@property(copy)NSString *name;
@property(strong) id obj;
@end
@implementation StackNode
@end
/**
 * 扩展点
 */
@interface ExtensionPoint:NSObject<IExtensionPointDelegate>
/**
 * 扩展配置队列
 */
@property(strong) NSMutableArray<IExtensionDelegate>*children;
-(NSArray<id<IExtensionDelegate>>*)getExtensions;
-(void)addExtension:(id<IExtensionDelegate>)extension;
@end
@implementation ExtensionPoint
-(id)init{
    if(self=[super init]){
        self.children=[NSMutableArray<IExtensionDelegate> new];
    }
    return self;
}
/**
 * 获取所有的扩展集合
 *
 *
 */
-(NSArray<id<IExtensionDelegate>>*)getExtensions{
    return [self.children copy];
}

/**
 * 加入配置元素
 *
 * param extension
 */
-(void)addExtension:(id<IExtensionDelegate>)extension{
    [self.children addObject:extension];
}
@end






@interface Extension:NSObject<IExtensionDelegate>
/**
 * 属性集合
 */
@property(strong) NSMutableDictionary<NSString*,NSString*>*attributes;
/**
 * 扩展配置队列
 */
@property(strong) NSMutableArray<id<IConfigElementDelegate>>*children;
-(void) addConfigElement:(id<IConfigElementDelegate>)configElement;
-(NSArray<id<IConfigElementDelegate>> *)getConfigElements;
-(NSString *)getAttribute:(NSString *)key;
-(void)setAttribute:(NSString *)key value:(NSString *)value;
@end
@implementation Extension
-(id)init{
    if(self=[super init]){
        self.attributes=[NSMutableDictionary new];
        self.children=[NSMutableArray new];
    }
    return self;
}
/**
 * 获取所有的配置元素集合
 *
 * return
 */
-(NSArray<id<IConfigElementDelegate>> *)getConfigElements{
    return [self.children copy];
}
/**
 * 加入配置元素
 *
 * param configElement
 */
-(void) addConfigElement:(id<IConfigElementDelegate>)configElement{
    [self.children addObject:configElement];
}
/**
 * 获取扩展点属性
 *
 * param key
 * return
 */
-(NSString *)getAttribute:(NSString *)key{
    NSString *value=[self.attributes objectForKey:key];
    return value;
}
/**
 * 设置属性值
 *
 * param key
 * param value
 */
-(void)setAttribute:(NSString *)key value:(NSString *)value{
    [self.attributes setObject:value forKey:key];
}


@end













@interface ConfigElement:NSObject<IConfigElementDelegate>
/**
 * 名称
 */
@property(copy) NSString* name;
/**
 * text
 */
@property(copy) NSString* text;

/**
 * 属性集合
 */
@property(strong) NSMutableDictionary<NSString*,NSString*>*attributes;
/**
 * 孩子集合
 */
@property(strong) NSMutableDictionary<NSString*,NSArray<id<IConfigElementDelegate>>*>     *  childrenMap;

-(NSString *)getName;

-(void)setName:(NSString *)name_;
-(NSString*) getText ;
-(void) setText:(NSString*) text_;
-(NSArray<id<IConfigElementDelegate>>*)getChildren:(NSString*)name;
-(void) addChildren:(NSString*)name configElement:(id<IConfigElementDelegate>)configElement;

-(NSString *)getAttribute:(NSString *)key;
-(void)setAttribute:(NSString *)key Value:(NSString*)value;
@end
@implementation ConfigElement
@synthesize  name=_name,text=_text;
-(id)init{
    if(self=[super init]){
        self.attributes=[NSMutableDictionary new];
        self.childrenMap=[NSMutableDictionary new];
    }
    return self;
}
-(NSString *)getAttribute:(NSString *)key{
    return [self.attributes objectForKey:key];
}
-(void)setAttribute:(NSString *)key Value:(NSString*)value{
    [self.attributes setObject:value forKey:key];
}
/**
 * 获取扩展点配置名称
 *
 *
 */
-(NSString *)name{
    return _name;
}
-(NSString *)getName{
    return _name;
}
/**
 * 设置扩展点配置名称
 *
 *
 */
-(void)setName:(NSString *)name_{
    _name=name_;
}
/**
 * 获取扩展点的文本
 *
 *
 */
-(NSString*) text {
    return _text;
}
-(NSString*) getText {
    return _text;
}
/**
 * 设置扩展点的文本
 *
 *
 */
-(void) setText:(NSString*) text_ {
    _text = text_;
}
/**
 * 获取指定名称的扩展点配置列表
 *
 *
 *
 */
-(NSArray<id<IConfigElementDelegate>>*)getChildren:(NSString*)name{
    return [self.childrenMap[name] copy];
}
/**
 * 加入扩展点配置列表
 *
 *
 *
 */
-(void) addChildren:(NSString*)name configElement:(id<IConfigElementDelegate>)configElement{
    NSArray<id<IConfigElementDelegate>> *list=[self.childrenMap objectForKey:name];
    if(list==nil){
        list=[NSMutableArray new];
        [self.childrenMap setObject:list forKey:name];
        
    }
    [((NSMutableArray*)list) addObject:configElement];
}
@end

@interface ExtensionRegistry()<NSXMLParserDelegate>{
    /**
     * 扩展点注册表
     */
    NSMutableDictionary<NSString*, id<IExtensionPointDelegate>>* extensionPointMap ;
    id root;
    StackForNSObject *stack;
    
    
}

@end
@implementation ExtensionRegistry
///**
// * 日志
// */
//private static Logger logger = LoggerFactory.getLogger(ExtensionRegistry.class);

-(id)init{
    if(self=[super init]){
        
    }
    return self;
}
 -(id)initWithRoot:(id)root_{
    
    self=[self init];
    root=root_;
    extensionPointMap=[NSMutableDictionary new];
    
    //加载配置
    [self loadMap:extensionPointMap];
    
    return self;
}



/**
 * 获取扩展点集合
 * param pointName
 *
 */
-(id<IExtensionPointDelegate>) getExtensionPoint:(NSString*) pointName{
    //获取扩展点
    id<IExtensionPointDelegate> extensionPoint=extensionPointMap[pointName];
    return extensionPoint;
}

/**
 * 加载扩展点配置
 */
-(void) loadMap: (NSDictionary<NSString*, id<IExtensionPointDelegate>> *)extensionPointMap {
    @try {
        
       //获取xml资源文件列表
        NSArray *fullPath1=  [[FileAccessor getInstance] allFilesPathAtFPath:[NSBundle mainBundle].bundlePath withType:@"xml"];
        NSArray * srcFileNames1=[[FileAccessor getInstance] allFilesNameAtFPath:[NSBundle mainBundle].bundlePath withType:@"xml"] ;

        NSArray *srcFileNames2=   [[FileAccessor getInstance] loadAllXMLNameFromCustomBundle];
        NSArray *fullPath2=[[FileAccessor getInstance] loadAllXMLPathFromCustomBundle];
       
        NSMutableArray*fullPath= [NSMutableArray new];
        [fullPath addObjectsFromArray:fullPath1];
        [fullPath addObjectsFromArray:fullPath2];
        NSMutableArray*srcFileNames= [NSMutableArray new];
        [srcFileNames addObjectsFromArray:srcFileNames1];
        [srcFileNames addObjectsFromArray:srcFileNames2];
        
        for (int i = 0; i < srcFileNames.count; i++) {
            //判断文件名格式是否合法
            if (!([srcFileNames[i] hasPrefix:@"plugin"] && [srcFileNames[i] hasSuffix:@".xml"])) {
                
                NSString *error=[NSString stringWithFormat:@"文件名[%@]格式错误",srcFileNames[i]];
                FOXLog(@"%@",error);
                continue;
            }
            if([srcFileNames[i] isEqualToString:@"plugins-app.xml"]){
                int ii=0;
            }
            NSData *xmlData = [NSData dataWithContentsOfFile:fullPath[i]];
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
            parser.delegate = self;
            [parser parse];
            
        }
    } @catch (NSException * e)   {
       FOXLog(@"Exception: %@", e);
    }
}
//当扫描到文档的开始时调用（开始解析）
- (void)parserDidStartDocument:(NSXMLParser *)parser {
      stack=[StackForNSObject new];
}

//当扫描到元素的开始时调用
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSString *tagName=elementName;
    //一些全局设置
    if ([tagName isEqualToString:@"preference"]) {
       [Platform getInstance].settings[attributeDict[@"name"] ] = attributeDict[@"value"];
    }
    else if([@"plugin" isEqualToString:tagName]){
        
    }
    else if([@"extension" isEqualToString:tagName]){
        Extension *extension=[Extension new];
        NSString *name=@"";
        for(NSString * key in attributeDict){
            NSString *value=attributeDict[key];
            if([@"point" isEqualToString:[key lowercaseString] ]){
                name=value;
            }
            [extension setAttribute:key value:value];
        }
        //定义节点
        StackNode *node=[StackNode new];
        node.name=name;
        node.obj=extension;
        //加入堆栈
        [stack push:node];
    }
    else{ //不是名字为plugin和extension的节点 proxy native
         ConfigElement *configElement =  [ConfigElement new];
         [configElement setName:tagName];
        for(NSString * key in attributeDict){
            NSString *value=attributeDict[key];
            [configElement setAttribute:key Value:value];
        }
        //定义节点
        StackNode *node=[StackNode new];
        node.name=tagName;
        node.obj=configElement;
        //加入堆栈
        [stack push:node];
    }
    
}
//解析完一个节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName{
    NSString *tagName=elementName;
    if([@"plugin" isEqualToString:tagName]){
        
    }
    else if([@"extension" isEqualToString:tagName]){
         // 移除栈顶对象
        StackNode *node=[stack popTopElement];
         // 获取扩展
         Extension *extension = (Extension*) node.obj;//extension point="fox.proxy">
        /*解释：  获取扩展点
         extensionPointMap .name=fox.proxy或者fox.native,value为一个数组，里面是
          【<extension point="fox.proxy">,<extension point="fox.proxy">】
         */
        ExtensionPoint* extensionPoint = (ExtensionPoint*) extensionPointMap[node.name];
        if (extensionPoint == nil) {
            extensionPoint =  [ExtensionPoint new];//相当于一个数组
            [extensionPointMap setObject:extensionPoint forKey:node.name];
        }
        [extensionPoint addExtension:extension];
        
    }
    else{
        
        if(![stack isEmpty]){
            // 移除栈顶对象
            StackNode * node = [stack popTopElement];
            StackNode *parent= [stack TopElement];
            if ([parent.obj isKindOfClass:[ Extension class]]) {
                Extension* extension = (Extension*) parent.obj;
                ConfigElement* configElement = (ConfigElement*) node.obj;
                [extension addConfigElement:configElement];
            } else if ([parent.obj isKindOfClass:[ConfigElement class]]) {
                ConfigElement* parentElement = (ConfigElement*) parent.obj;
                ConfigElement* subElement = (ConfigElement*) node.obj;
                [ parentElement   addChildren:node.name configElement:subElement];
            }
        }
    }
}
//获取节点内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if(![stack isEmpty]){
        //查看栈顶对象而不移除它
        StackNode* node =  [stack TopElement];
        if ([node.obj isKindOfClass: [ConfigElement class]]) {
            ConfigElement *subElement = (ConfigElement*) node.obj;
            NSString* text=string;
            [subElement setText:text];
        }
    }
}



//当扫描到文档的结束时调用（解析完毕）
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    stack=nil;
}



 




@end














