//
//  ZJNewFeatureCell.h
//  GuidePageDemo
//
//  Created by zhengju on 16/11/7.
//  Copyright © 2016年 俱哥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJNewFeatureCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;

// 判断是否是最后一页
- (void)setIndexPath:(NSIndexPath *)indexPath count:(NSInteger)count;

@end
