//
//  ZJNewFeatureCell.m
//  GuidePageDemo
//
//  Created by zhengju on 16/11/7.
//  Copyright © 2016年 俱哥. All rights reserved.
//

#import "ZJNewFeatureCell.h"
#import "YXPlugin.h"
#import "FileAccessor.h"

@interface ZJNewFeatureCell ()

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UIButton *startButton;

@end

@implementation ZJNewFeatureCell

- (UIButton *)startButton
{
    if (_startButton == nil) {
        UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [startBtn setBackgroundColor:[UIColor clearColor]];
        
        NSString *filePath = [[FileAccessor getInstance] constructAbsolutePath:@"doc/start.png"];
        [startBtn setBackgroundImage:[UIImage imageWithContentsOfFile:filePath] forState:UIControlStateNormal];
        
        [startBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:startBtn];
        
        
        _startButton = startBtn;
        
    }
    return _startButton;
}

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        
        UIImageView *imageV = [[UIImageView alloc] init];
        
        _imageView = imageV;
        
        // 注意:一定要加在contentView上
        [self.contentView addSubview:imageV];
        
    }
    return _imageView;
}

// 布局子控件的frame
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    self.startButton.frame = CGRectMake(0, 0, 142, 51);
    self.startButton.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT - 90);
    
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    self.imageView.image = image;
    
    self.imageView.backgroundColor = [UIColor clearColor];
}

// 判断当前cell是否是最后一页
- (void)setIndexPath:(NSIndexPath *)indexPath count:(NSInteger)count
{
    if (indexPath.row == count - 1) { // 最后一页,显示分享和开始按钮
        
        self.startButton.hidden = NO;
        
    }else{ // 非最后一页，隐藏分享和开始按钮
        
        self.startButton.hidden = YES;
    }
}

// 点击开始的时候调用
- (void)start
{

}
@end
