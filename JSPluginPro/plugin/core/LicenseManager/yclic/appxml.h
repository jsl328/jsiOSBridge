//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+ 文件名称：appxml.h                                                        +
//+ 文件内容：应用开发 XML 操作通用基础函数库                                 +
//+ 文件作者：何轼                                                            +
//+ 最终修订：2013.12.12                                                      +
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef	APPXML_H
#define	APPXML_H

#ifdef	__cplusplus
extern	"C"	{
#endif	// def	__cplusplus

//==============================================================================
// 公共数据类型定义
typedef	struct	_XMLDOC *	XMLDOC;		// 标准文档类型
typedef	struct	_XMLNODE *	XMLNODE;	// 标准节点类型
typedef	void
	(*XMLERR)(				// 标准错误处理回调函数类型
		const char *	Format,			// 错误信息格式
		...					// 错误信息参数
	);

//==============================================================================
// 公共接口函数定义
extern	XMLDOC
	appXmlNew(			// 建立新的空文档对象
		const char *	Encode,		// 字符集编码（NULL表示忽略）
		XMLERR		Callback	// 错误处理回调函数
	);	// 返回新建文档对象，NULL表示失败。

extern	void
	appXmlFree(			// 释放文档对象
		XMLDOC		Doc		// 待释放的文档对象
	);

extern	int
	appXmlParse(			// 解析文本到文档对象
		XMLDOC		Doc,		// 文档对象
		const char *	Buffer,		// 文本内容
		int		Size		// 文本长度（-1表示自行计算）
	);	// 返回0表示成功，-1表示失败

extern	int
	appXmlForm(			// 从文档对象组装文本
		XMLDOC		Doc,		// 文档对象
		int		Mode,		// 紧缩模式（0表示紧缩）
		char *		Buffer,		// 文本输出缓冲区
		int		Size		// 缓冲区字节数
	);	// 返回组装的文本长度，-1表示失败

extern	int
	appXmlLoad(			// 解析文件到文档对象
		XMLDOC		Doc,		// 文档对象
		const char *	File		// 文件名称
	);	// 返回0表示成功，-1表示失败

extern	int
	appXmlSave(			// 用文档对象组装文件
		XMLDOC		Doc,		// 文档对象
		int		Mode,		// 紧缩模式（0表示紧缩）
		const char *	File		// 文件名称
	);	// 返回0表示成功，-1表示失败

extern	XMLDOC
	appXmlDoc(			// 获取节点所属文档对象
		XMLNODE		Node		// 节点对象
	);	// 返回文档对象

extern	XMLNODE
	appXmlSetup(			// 创建节点对象工作区
		XMLDOC		Doc		// 文档对象
	);	// 返回节点工作区，NULL表示失败

extern	void
	appXmlReset(			// 释放节点对象工作区
		XMLNODE		Node		// 待释放节点对象
	);

extern	void
	appXmlCopy(			// 复制节点对象
		XMLNODE		Target,		// 目标节点对象
		XMLNODE		Source		// 源节点对象
	);

extern	int
	appXmlGetRoot(			// 检查并获取文档对象的根节点对象
		XMLDOC		Doc,		// 文档对象
		const char *	Name,		// 根节点名（NULL表示忽略检查）
		XMLNODE		Root		// 根节点对象（NULL表示不返回）
	);	// 返回0表示成功，1表示没有根节点，-1表示无效的根节点

extern	int
	appXmlSetRoot(			// 建立文档对象的根节点对象
		XMLDOC		Doc,		// 文档对象
		const char *	Name,		// 根节点名
		XMLNODE		Root		// 根节点对象
	);	// 返回0表示成功，-1表示失败

extern	int
	appXmlGetChild(			// 查找指定对象的指定名称的子节点对象
		XMLNODE		Node,		// 节点对象
		const char *	Name,		// 子节点名（NULL表示忽略名称）
		XMLNODE		Child		// 子节点对象（NULL表示不返回）
	);	// 返回0表示成功，1表示未找到，-1表示失败

extern	int
	appXmlSetChild(			// 建立指定对象的指定名称的子节点对象
		XMLNODE		Node,		// 节点对象
		const char *	Name,		// 子节点名（NULL表示无名称）
		XMLNODE		Child		// 子节点对象（NULL表示不返回）
	);	// 返回0表示成功，-1表示失败

extern	int
	appXmlUnsetChild(		// 删除指定对象的指定的子节点对象
		XMLNODE		Node,		// 节点对象
		const char *	Name		// 子节点名（NULL表示全部）
	);	// 返回0表示成功，-1表示失败

extern	int
	appXmlFindNext(			// 查找指定节点的指定名称的下一节点对象
		XMLNODE		Node,		// 参照节点对象
		const char *	Name,		// 待查找节点名（NULL表示任意）
		XMLNODE		Next		// 次节点对象（NULL表示不返回）
	);	// 返回0表示成功，1表示未找到，-1表示失败

extern	int
	appXmlGetName(			// 获取节点名
		XMLNODE		Node,		// 节点对象
		char *		Name,		// 节点名缓冲区
		int		Size		// 缓冲区字节数
	);	// 返回节点名长度，-1表示失败

extern	int
	appXmlSetName(			// 设置节点名
		XMLNODE		Node,		// 节点对象
		const char *	Name		// 节点名
	);	// 返回0表示成功，-1表示失败

extern	int
	appXmlUnsetName(		// 删除节点名
		XMLNODE		Node		// 节点对象
	);	// 返回0表示成功，-1表示失败

extern	int
	appXmlCheckName(		// 检查节点名
		XMLNODE		Node,		// 节点对象
		const char *	Name		// 节点名
	);	// 返回0表示相等，1表示不相等，-1表示失败

extern	int
	appXmlGetValue(			// 获取节点值
		XMLNODE		Node,		// 节点对象
		char *		Value,		// 节点值缓冲区
		int		Size		// 缓冲区字节数
	);	// 返回节点值长度，-1表示失败

extern	int
	appXmlSetValue(			// 设置节点值
		XMLNODE		Node,		// 节点对象
		const char *	Value		// 节点值
	);	// 返回0表示成功，-1表示失败

extern	int
	appXmlUnsetValue(		// 删除节点值
		XMLNODE		Node		// 节点对象
	);	// 返回0表示成功，-1表示失败

extern	int
	appXmlCheckValue(		// 检查节点值
		XMLNODE		Node,		// 节点对象
		const char *	Value		// 节点值
	);	// 返回0表示相等，1表示不相等，-1表示失败

extern	int
	appXmlGetAttr(			// 获取指定节点的指定属性值
		XMLNODE		Node,		// 节点对象
		const char *	Name,		// 属性名
		char *		Value,		// 属性值缓冲区
		int		Size		// 缓冲区字节数
	);	// 返回属性值长度，-1表示失败

extern	int
	appXmlSetAttr(			// 设置指定节点的指定属性值
		XMLNODE		Node,		// 节点对象
		const char *	Name,		// 属性名
		const char *	Value		// 属性值
	);	// 返回0表示成功，-1表示失败

extern	int
	appXmlUnsetAttr(		// 删除指定节点的指定属性
		XMLNODE		Node,		// 节点对象
		const char *	Name		// 属性名（NULL表示全部）
	);	// 返回0表示成功，-1表示失败

extern	int
	appXmlCheckAttr(		// 检查指定节点的指定属性值
		XMLNODE		Node,		// 节点对象
		const char *	Name,		// 属性名
		const char *	Value		// 属性值
	);	// 返回0表示相等，1表示不相等，-1表示失败

extern	const char *
	appXmlName(			// 获取节点原始名称
		XMLNODE		Node		// 节点对象
	);	// 返回节点原始名称

extern	const char *
	appXmlText(			// 获取节点原始正文
		XMLNODE		Node		// 节点对象
	);	// 返回节点原始正文

extern	const char *
	appXmlAttr(			// 获取节点原始属性
		XMLNODE		Node,		// 节点对象
		const char *	Name		// 属性名称
	);	// 返回节点原始属性

#ifdef	__cplusplus
}
#endif	// def	__cplusplus

#endif	// ndef	APPXML_H

