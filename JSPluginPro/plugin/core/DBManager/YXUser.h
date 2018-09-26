//
//  YXUser.h
//  IMSDK
//
//  Created by apple on 15/12/23.
//  Copyright © 2015年 ios. All rights reserved.
//

#import <Foundation/Foundation.h>

 /**
 联系人类
 */
@interface YXUser : NSObject

/**
 姓名
 */
@property (nonatomic,strong) NSString *userName;

/**
 编号
 */
@property (nonatomic,strong) NSString *userNo;

/**
 名称简写
 */
@property (nonatomic,strong) NSString *userNameShot;

/**
 性别。F-女；M-男；
 */
@property (nonatomic,strong) NSString *gender;

/**
 头像的存放路径
 */
@property (nonatomic,strong) NSString *userIcon;

/**
 所属机构编号
 */
@property (nonatomic,strong) NSString *brhNo;

/**
 公司编号
 */
@property (nonatomic,strong) NSString *firmNo;

/**
 saas服务的key值
 */
@property (nonatomic,strong) NSString *saasKey;

/**
 签名
 */
@property (nonatomic,strong) NSString *userNote;

/**
 手机
 */
@property (nonatomic,strong) NSString *mobile;

/**
 电话
 */
@property (nonatomic,strong) NSString *phoneNo;

/**
 短号
 */
@property (nonatomic,strong) NSString *shotNumber;

/**
 出生日期
 */
@property (nonatomic,strong) NSString *birthday;

/**
 状态（未激活|正常|禁用|删除，等）
 */
@property (nonatomic,strong) NSString *userStt;
@property (nonatomic,strong) NSString *remark;

/**
 用户等级
 */
@property (nonatomic,assign) NSInteger userLevel;

/**
 姓名全拼
 */
@property (nonatomic,strong) NSString *userNameFullPinyin;

/**
 姓名简拼
 */
@property (nonatomic,strong) NSString *userNameShotPinyin;

/**
 电子邮件
 */
@property (nonatomic,strong) NSString *email;

/**
 工号
 */
@property (nonatomic,strong) NSString *workNo;

/**
 是否好友/是否常用联系人；T-是；F-否；
 */
@property (nonatomic,strong) NSString *isFriend;

/**
 添加标签
 */
@property (nonatomic,strong) NSString *mark;

@end
