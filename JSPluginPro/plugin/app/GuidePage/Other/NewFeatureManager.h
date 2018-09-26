//
//  NewFeatureManager.h
//  GuidePageDemo
//
//  Created by LiYuan on 2018/1/12.
//  Copyright © 2018年 俱哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewFeatureDelegate <NSObject>

- (void)newFeatureDidLoadFinished;

@end

@interface NewFeatureManager : NSObject

+ (void)shareManagerWithDelegate:(id<NewFeatureDelegate>)delegate picStrArr:(NSArray *)picStrArr;


@end
