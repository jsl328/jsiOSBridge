/*****************************************************************************
 * 宇信易诚公司软件产品许可证检验软件包头文件
 * 北京宇信易诚科技有限公司版权所有(C) 2012-2013
 *****************************************************************************/

#ifndef	YCLIC_H
#define	YCLIC_H

#ifdef	__cplusplus
extern	"C"	{
#endif

#define	YCLICRC_TRUE	1	/* 返回值：真，操作成功 */
#define	YCLICRC_FALSE	0	/* 返回值：假，操作失败 */
#define	YCLICRC_ERROR	-1	/* 返回值：操作出错 */

typedef	struct	_YCLIC_T *	YCLIC_T;	/* 许可证句柄 */

extern	YCLIC_T				/* 申请许可证句柄 */
	ycLicNew(
		void				/* 无参数 */
	);	/* 返回许可证句柄，NULL 表示申请失败 */

extern	void				/* 释放许可证句柄 */
	ycLicFree(
		YCLIC_T         LicHandle	/* 许可证句柄 */
	);	/* 无返回值 */

extern	int				/* 打开许可证文件 */
	ycLicOpen(
		YCLIC_T         LicHandle,	/* 许可证句柄 */
		const char *    LicFile         /* 许可证文件全路径名 */
	);	/* 返回 1 表示成功，0 表示文件不存在或非法，-1 表示失败 */

extern	int				/* 关闭许可证文件 */
	ycLicClose(
		YCLIC_T         LicHandle,	/* 许可证句柄 */
		const char *    LicFile         /* 许可证文件全路径名 */
	);	/* 返回 1 表示成功，0 表示没有保存，-1 表示失败 */

extern	const char *
	ycLicGetErrMsg(			/* 获取当前错误信息 */
		YCLIC_T		LicHandle	/* 许可证句柄 */
	);	/* 错误信息，NULL 表示无 */

extern	int
	ycLicIsExpired(			/* 检查许可证是否过期 */
		YCLIC_T		LicHandle	/* 许可证句柄 */
	);	/* 返回 0 表示未过期，1 表示已过期，-1 表示失败 */

extern	int
	ycLicIsEarlier(			/* 检查许可证是否启用 */
		YCLIC_T		LicHandle	/* 许可证句柄 */
	);	/* 返回 0 表示未启用，1 表示已启用，-1 表示失败 */

extern	int
	ycLicGetBuildTime(		/* 获取许可证创建时间 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetLicenseCode(		/* 获取许可证编号 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetLicenseType(		/* 获取许可证类型 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetProductCode(		/* 获取产品编号 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetProductNameZh(		/* 获取产品中文名称 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetProductNameEn(		/* 获取产品英文名称 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetVersionMajor(		/* 获取产品主版本号 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetVersionSub(		/* 获取产品子版本号 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetVersionPublish(		/* 获取产品发布号 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetCompileDate(		/* 获取产品编译日期 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetCustomerName(		/* 获取使用客户名称 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetContractCode(		/* 获取销售合同号 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetStartTime(		/* 获取许可证有效起始日期 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetEndTime(		/* 获取许可证有效终止日期 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicGetExtendInfo(		/* 获取许可证扩展信息 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		int		Number,		/* 扩展信息号 */
		char *		Buffer,		/* 输出缓冲区 */
		int		Length		/* 缓冲区长度 */
	);	/* 返回 1 表示成功，0 表示缓冲区不足，-1 表示失败 */

extern	int
	ycLicPutExtendInfo(		/* 添加许可证扩展信息 */
		YCLIC_T		LicHandle,	/* 许可证句柄 */
		int		Number,		/* 扩展信息号 */
		const char *	Value		/* 扩展信息值 */
	);	/* 返回 1 表示添加成功，0 表示替换成功，-1 表示失败 */

#ifdef	__cplusplus
}
#endif

#endif
