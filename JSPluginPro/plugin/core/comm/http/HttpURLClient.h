//
//  HttpURLClient.h
//  SimpleNetworkStreams
//
//  Created by BruceXu on 2018/4/17.
//

#import <Foundation/Foundation.h>
#import "FormEntry.h"
@interface HttpURLClient : NSObject
-(id)init:(NSString*)url;

 
-(void) setrequestMethod:(NSString*) requestMethod;
-(void) setRequestProperty:(NSString*) key value: (NSString*) value ;
 
-(NSURLRequest*) getRequestToHttpServer:(NSArray<FormEntry*>*) formEntrys;
@end
