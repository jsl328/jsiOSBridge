#include	<stdio.h>
#include	<langinfo.h>
#include	<iconv.h>
#include	<string.h>
#include	<stdlib.h>
#include	<time.h>
#include	<sys/time.h>
#include	<sys/types.h>
#include	"_yclic.h"

#define	XMLCHARSET	"UTF-8"
#define	MD5CHARSET	"GBK"
#define	XMLNODE_ROOT	"license"
#define	XMLNODE_ATTR	"element"
#define	XMLNODE_DATA	"content"
#define	XMLATTR_NAME	"name"
#define	XMLATTR_BUILD	"build-time"
#define	XMLATTR_VALID	"validate-code"
#define	XMLFLD_LICCODE	"license_code"
#define	XMLFLD_LICTYPE	"license_type"
#define	XMLFLD_PRODCODE	"product_code"
#define	XMLFLD_PRODNMZH	"product_name_zh-cn"
#define	XMLFLD_PRODNMEN	"product_name_en-us"
#define	XMLFLD_VERMAJOR	"version_major"
#define	XMLFLD_VERSUB	"version_sub"
#define	XMLFLD_VERPUB	"version_publish"
#define	XMLFLD_COMPILE	"compile_date"
#define	XMLFLD_CUSTOMER	"customer_name"
#define	XMLFLD_CONTRACT	"contract_code"
#define	XMLFLD_LICSTART	"license_start_time"
#define	XMLFLD_LICEND	"license_end_time"
#define	XMLFLD_EXTEND	"expend_info"

#define LEN_MSG		1024		/* 错误信息长度 */
#define LEN_MD5		33		/* MD5 长度 */
#define	LEN_BUF		4096		/* 内容缓冲区长度 */
#define	LEN_KEY		32		/* 关键字缓冲区长度 */
#define	LEN_DATE	11		/* 日期值长度 */

typedef char    LICMSG[LEN_MSG];	/*许可证信息变量*/
typedef char    MD5TXT[LEN_MD5];	/*MD5内容变量*/
typedef	char	MD5BUF[LEN_BUF];	/*MD5缓冲区变量*/
typedef	char	KEYBUF[LEN_KEY];	/*关键字变量*/
typedef	char	DATEVAL[LEN_DATE];	/*日期值变量*/

typedef	struct	_YCLIC_T{	/*许可证主结构*/
	XMLDOC	doc;			/*文档对象*/
	XMLNODE	root;			/*根节点*/
	iconv_t	cnv;			/*转码变量*/
	int	changed;		/*许可证有改动为1，反之为0*/
	LICMSG	msg;			/*返回消息*/
}	_YCLIC_T;

/*
检查许可证是否加载成功
返回 0 表示成功，-1 表示失败
*/
static	int
check_doc(YCLIC_T Lic)
{
	if ( Lic->doc == NULL ) {
		strcpy( Lic->msg, "没有许可证信息" );
		return -1;
	}
	return 0;
}

/*
建立节点工作区
返回节点表示成功，NULL 表示失败
*/
static	XMLNODE
set_node(YCLIC_T Lic)
{
	XMLNODE	Node;

	if ( ( Node = appXmlSetup( Lic->doc ) ) == NULL )
		strcpy( Lic->msg, "节点工作区建立失败" );
	return Node;
}

/*
将节点内容组合成字符串
返回 -1 表示失败
*/
static	int
get_content(YCLIC_T Lic, XMLNODE Work, XMLNODE Temp, const char *Name,
		MD5BUF Buf, int Pos)
{
	const char	*t;
	int	r, s, l;

	s = Pos;
	for ( r = appXmlGetChild( Lic->root, Name, Work ); r == 0;
			r = appXmlFindNext( Temp, Name, Work ) ) {
		t = appXmlAttr( Work, XMLATTR_NAME );
		if ( ( l = strlen( t ) ) >= LEN_BUF - s ) {
			strcpy( Lic->msg, "内容缓冲区不足" );
			return -1;
		}
		strcpy( Buf + s, t );
		s += l;
		t = appXmlText( Work );
		if ( t != NULL ) {
			if ( ( l = strlen( t ) ) >= LEN_BUF - s ) {
				strcpy( Lic->msg, "内容缓冲区不足" );
				return -1;
			}
			strcpy( Buf + s, t );
			s += l;
		}
		appXmlCopy( Temp, Work );
	}
	return s;
}

/*
获取用于转换成MD5的字符串
返回 -1 表示失败
*/
static	int
get_md5_content(YCLIC_T Lic, MD5BUF Buf)
{
	XMLNODE	Work, Temp;
	int	r = -1;

	if ( ( Work = set_node( Lic ) ) == NULL )
		goto _L0;
	if ( ( Temp = set_node( Lic ) ) == NULL )
		goto _L1;
	if ( ( r = get_content( Lic, Work, Temp, XMLNODE_ATTR, Buf, 0 ) ) < 0 )
		goto _L2;
	if ( ( r = get_content( Lic, Work, Temp, XMLNODE_DATA, Buf, r ) ) < 0 )
		goto _L2;
	if ( r == 0 )
		Buf[0] = '\0';
_L2:
	appXmlReset( Temp );
_L1:
	appXmlReset( Work );
_L0:
	return r;
}

/*
生成MD5码
返回 0 表示成功，-1 表示失败
*/
static	int
make_md5(YCLIC_T Lic, MD5TXT Md5 )
{
	MD5BUF	Raw, Txt;
	char	*p, *q;
	size_t	i, o;
	int	r;

	if ( ( r = get_md5_content( Lic, Raw ) ) < 0 )
		return -1;
	p = Raw;
	i = r * sizeof( char );
	q = Txt;
	o = sizeof( Txt );
	if ( ( r = iconv( Lic->cnv, &p, &i, &q, &o ) ) < 0 ) {
		strcpy( Lic->msg, "校验转码失败" );
		return -1;
	}
	md5( Txt, ( sizeof( Txt ) - o ) / sizeof( char ), Md5 );
	return 0;
}

/*
日期转换
返回 -1 表示失败
*/
static	time_t
make_date(YCLIC_T Lic, struct tm *Time)
{
	time_t	t;

	Time->tm_hour = 0;
	Time->tm_min = 0;
	Time->tm_sec = 0;
	if ( ( t = mktime( Time ) ) == -1 )
		strcpy( Lic->msg, "无效的日期值" );
	return t;
}

/*
验证许可证中的日期
返回 -1 表示日期无效
*/
static	time_t
cnv_date(YCLIC_T Lic, const DATEVAL Date)
{
	int	y, m, d;
	struct	tm	v;
	time_t	t;

	if ( sscanf( Date, "%d-%d-%d", &y, &m, &d ) != 3 ) {
		strcpy( Lic->msg, "无效的日期格式" );
		return -1;
	}
	v.tm_year = y - 1900;
	v.tm_mon = m - 1;
	v.tm_mday = d;
	return make_date( Lic, &v );
}

/*
获取本地日期
返回 -1 表示失败
*/
static	time_t
get_date(YCLIC_T Lic)
{
	time_t	t;
	struct	tm	*v;

	if ( ( t = time( NULL ) ) == -1 ) {
		strcpy( Lic->msg, "获取当前日期失败" );
		return -1;
	}
	if ( ( v = localtime( &t ) ) == NULL ) {
		strcpy( Lic->msg, "转换当前日期失败" );
		return -1;
	}
	return make_date( Lic, v );
}

/*
检查属性元素
返回 -1 表示失败
*/
static	int
check_field(YCLIC_T Lic, XMLNODE Node, const char *Key)
{
	int	r;

	if ( ( r = appXmlCheckAttr( Node, XMLATTR_NAME, Key ) ) < 0 )
		strcpy( Lic->msg, "检查属性元素失败" );
	return r;
}

/*
获取指定的属性元素
返回 -1 表示失败
*/
static	int
get_field(YCLIC_T Lic, const char *Key, char *Buf, int Len)
{
	int	r, s, t;
	XMLNODE	Work, Temp;

	if ( check_doc( Lic ) < 0 )
		return YCLICRC_ERROR;
	r = YCLICRC_ERROR;
	if ( ( Work = set_node( Lic ) ) == NULL )
		goto _L0;
	if ( ( Temp = set_node( Lic ) ) == NULL )
		goto _L1;
	for ( s = appXmlGetChild( Lic->root, XMLNODE_ATTR, Work ); s == 0;
			s = appXmlFindNext( Temp, XMLNODE_ATTR, Work ) ) {
		if ( ( t = check_field( Lic, Work, Key ) ) < 0 )
			break;
		else if ( t == 0 ) {
			if ( appXmlGetValue( Work, Buf, Len ) < 0 )
				r = YCLICRC_FALSE;
			else
				r = YCLICRC_TRUE;
			break;
		}
		appXmlCopy( Temp, Work );
	}
	if ( s != 0 ) {
		strcpy( Lic->msg, "未找到指定的属性元素" );
		goto _L2;
	}
	Lic->msg[0] = '\0';
_L2:
	appXmlReset( Temp );
_L1:
	appXmlReset( Work );
_L0:
	return r;
}

/*
修改/添加属性元素值
返回 -1 表示失败，0 表示替换成功，1 表示添加成功
*/
static	int
put_field(YCLIC_T Lic, const char *Key, const char *Val)
{
	int	r, s, t;
	XMLNODE	Work, Temp;

	if ( check_doc( Lic ) < 0 )
		return YCLICRC_ERROR;
	r = YCLICRC_ERROR;
	if ( ( Work = set_node( Lic ) ) == NULL )
		goto _L0;
	if ( ( Temp = set_node( Lic ) ) == NULL )
		goto _L1;
	for ( s = appXmlGetChild( Lic->root, XMLNODE_ATTR, Work ); s == 0;
			s = appXmlFindNext( Temp, XMLNODE_ATTR, Work ) ) {
		if ( ( t = check_field( Lic, Work, Key ) ) < 0 )
			break;
		else if ( t == 0 ) {
			if ( appXmlSetValue( Work, Val ) < 0 )
				strcpy( Lic->msg, "修改属性元素值失败" );
			else
				r = YCLICRC_FALSE;
			break;
		}
		appXmlCopy( Temp, Work );
	}
	if ( s != 0 ) {
		if ( appXmlSetChild( Lic->root, XMLNODE_ATTR, Work ) < 0 ) {
			strcpy( Lic->msg, "添加属性元素失败" );
			goto _L2;
		}
		if ( appXmlSetAttr( Work, XMLATTR_NAME, Key ) < 0 ) {
			strcpy( Lic->msg, "设置属性元素名失败" );
			goto _L2;
		}
		if ( appXmlSetValue( Work, Val ) < 0 ) {
			strcpy( Lic->msg, "设置属性元素值失败" );
			goto _L2;
		}
		r = YCLICRC_TRUE;
	}
	if ( r != YCLICRC_ERROR )
		Lic->msg[0] = '\0';
_L2:
	appXmlReset( Temp );
_L1:
	appXmlReset( Work );
_L0:
	return r;
}

static	int
set_extend_key(KEYBUF Buf, int Num)
{
	if ( Num <= 0 )
		return -1;
	snprintf( Buf, sizeof( KEYBUF ), "%s%d", XMLFLD_EXTEND, Num );
	return 0;
}

/*
申请许可证句柄
返回 许可证句柄 表示成功，NULL 表示申请失败
*/
YCLIC_T
ycLicNew(void)
{
	YCLIC_T Lic;

	if ( ( Lic = (YCLIC_T) malloc( sizeof(_YCLIC_T) ) ) != NULL ) {
		if ( ( Lic->cnv = iconv_open( MD5CHARSET, XMLCHARSET ) )
				!= (iconv_t) -1 ) {
			Lic->doc = NULL;
			return Lic;
/*			iconv_close( Lic->cnv );
*/
		}
		free( Lic );
	}
	return NULL;
}

/*
释放许可证句柄
无返回值
*/
void
ycLicFree(YCLIC_T Lic)
{
	if ( Lic->doc == NULL ) {
		iconv_close( Lic->cnv );
		free( Lic );
	}
}

/*
打开许可证文件
返回 1 表示成功，0 表示文件不存在或非法，-1 表示失败
*/
int
ycLicOpen(YCLIC_T Lic, const char * LicFile)
{
	int	r, s;
	MD5TXT	Md5Dat, Md5Tmp;

	r = YCLICRC_ERROR;
	if ( ( Lic->doc = appXmlNew( NULL, NULL ) ) == NULL ) {
		strcpy( Lic->msg, "建立新文档对象失败" );
		goto _L0;
	}
	if ( ( appXmlLoad( Lic->doc, LicFile ) ) < 0 ) {
		strcpy( Lic->msg, "解析许可证文件失败" );
		goto _L1;
	}
	if ( ( Lic->root = set_node( Lic ) ) == NULL )
		goto _L1;
	if ( appXmlGetRoot( Lic->doc, XMLNODE_ROOT, Lic->root ) < 0 ) {
		strcpy( Lic->msg, "获取根节点失败" );
		goto _L2;
	}
	if ( appXmlGetAttr( Lic->root, XMLATTR_VALID, Md5Dat,
			sizeof( Md5Dat ) ) < 0 ) {
		strcpy( Lic->msg, "获取校验码失败" );
		goto _L2;
	}
	if ( make_md5( Lic, Md5Tmp ) < 0 )
		goto _L2;
	r = YCLICRC_FALSE;
	if ( strcmp( Md5Dat, Md5Tmp ) != 0 ) {
		strcpy( Lic->msg, "许可证校验错误" );
		goto _L2;
	}
	if ( ( s = ycLicIsExpired( Lic ) ) == YCLICRC_ERROR ) {
		r = s;
		goto _L2;
	}
	else if ( s == YCLICRC_TRUE ) {
		strcpy( Lic->msg, "许可证已过期" );
		goto _L2;
	}
	if ( ( s = ycLicIsEarlier( Lic ) ) == YCLICRC_ERROR ) {
		r = s;
		goto _L2;
	}
	else if ( s == YCLICRC_TRUE ) {
		strcpy( Lic->msg, "许可证未启用" );
		goto _L2;
	}
	Lic->changed = YCLICRC_FALSE;
	Lic->msg[0] = '\0';
	return YCLICRC_TRUE;
_L2:
	appXmlReset( Lic->root );
_L1:
	appXmlFree( Lic->doc );
	Lic->doc = NULL;
_L0:
	return r;
}

/*
关闭许可证文件
返回 1 表示成功，0 表示没有保存，-1 表示失败
*/
int
ycLicClose(YCLIC_T Lic, const char * LicFile)
{
	int	r;
	MD5TXT	Md5Txt;

	if ( check_doc( Lic ) < 0 )
		return YCLICRC_ERROR;
	if ( Lic->changed == YCLICRC_FALSE || LicFile == NULL ) {
		r = YCLICRC_FALSE;
		goto _L0;
	}
	if ( make_md5( Lic, Md5Txt ) < 0 )
		return YCLICRC_ERROR;
	if ( appXmlSetAttr( Lic->root, XMLATTR_VALID, Md5Txt ) < 0 ) {
		strcpy( Lic->msg, "设置校验码失败" );
		return YCLICRC_ERROR;
	}
	if ( appXmlSave( Lic->doc, 0, LicFile ) < 0 ) {
		strcpy( Lic->msg, "更新许可证文件失败" );
		return YCLICRC_ERROR;
	}
	r = YCLICRC_TRUE;
_L0:
	appXmlReset( Lic->root );
	appXmlFree( Lic->doc );
	Lic->doc = NULL;
	return r;
}

/*
获取当前错误信息
返回错误信息，NULL 表示无
*/
const char *
ycLicGetErrMsg(YCLIC_T Lic)
{
	return Lic->msg;
}

/*
检查许可证是否过期
返回 0 表示未过期，1 表示已过期，-1 表示失败
*/
int
ycLicIsExpired(YCLIC_T Lic)
{
	DATEVAL	Date;
	time_t	t, v;

	if ( ycLicGetEndTime( Lic, Date, LEN_DATE ) != YCLICRC_TRUE )
		return YCLICRC_ERROR;
	if ( ( v = cnv_date( Lic, Date ) ) == -1 )
		return YCLICRC_ERROR;
	if ( ( t = get_date( Lic ) ) == -1 )
		return YCLICRC_ERROR;
	if ( t > v )
		return YCLICRC_TRUE;
	Lic->msg[0] = '\0';
	return YCLICRC_FALSE;
}

/*
检查许可证是否启用
返回 0 表示未启用，1 表示已启用，-1 表示失败
*/
int
ycLicIsEarlier(YCLIC_T Lic)
{
	DATEVAL	Date;
	time_t	t, v;

	if ( ycLicGetStartTime( Lic, Date, LEN_DATE ) != YCLICRC_TRUE )
		return YCLICRC_ERROR;
	if ( ( v = cnv_date( Lic, Date ) ) == -1 )
		return YCLICRC_ERROR;
	if ( ( t = get_date( Lic ) ) == -1 )
		return YCLICRC_ERROR;
	if ( t < v )
		return YCLICRC_TRUE;
	Lic->msg[0] = '\0';
	return YCLICRC_FALSE;
}

/*
获取许可证创建时间
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetBuildTime(YCLIC_T Lic, char *Buffer, int Length)
{
	if ( check_doc( Lic ) < 0 )
		return YCLICRC_ERROR;
	if ( appXmlGetAttr( Lic->root, XMLATTR_BUILD, Buffer, Length ) < 0 ) {
		strcpy( Lic->msg, "获取创建时间失败" );
		return YCLICRC_ERROR;
	}
	return YCLICRC_TRUE;
}

/*
获取许可证编号
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetLicenseCode(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_LICCODE, Buffer, Length );
}

/*
获取许可证类型
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetLicenseType(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_LICTYPE, Buffer, Length );
}

/*
获取产品编号
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetProductCode(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_PRODCODE, Buffer, Length );
}

/*
获取产品中文名称
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetProductNameZh(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_PRODNMZH, Buffer, Length );
}

/*
获取产品英文名称
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetProductNameEn(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_PRODNMEN, Buffer, Length );
}

/*
获取产品主版本号
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetVersionMajor(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_VERMAJOR, Buffer, Length );
}

/*
获取产品子版本号
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetVersionSub(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_VERSUB, Buffer, Length );
}

/*
获取产品发布号
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetVersionPublish(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_VERPUB, Buffer, Length );
}

/*
获取产品编译日期
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetCompileDate(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_COMPILE, Buffer, Length );
}

/*
获取使用客户名称
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetCustomerName(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_CUSTOMER, Buffer, Length );
}

/*
获取销售合同号
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetContractCode(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_CONTRACT, Buffer, Length );
}

/*
获取许可证有效起始日期
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetStartTime(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_LICSTART, Buffer, Length );
}

/*
获取许可证有效终止日期
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetEndTime(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_LICEND, Buffer, Length );
}

/*
获取许可证扩展信息
返回 1 表示成功，0 表示缓冲区不足，-1 表示失败
*/
int
ycLicGetExtendInfo(YCLIC_T Lic, int Number, char *Buffer, int Length)
{
	KEYBUF	k;

	if ( set_extend_key( k, Number ) < 0 )
		return YCLICRC_ERROR;
	return get_field( Lic, k, Buffer, Length );
}

/*
添加许可证扩展信息
返回 1 表示添加成功，0 表示替换成功，-1 表示失败
*/
int
ycLicPutExtendInfo(YCLIC_T Lic, int Number, const char *Value)
{
	KEYBUF	k;
	int	r;

	if ( set_extend_key( k, Number ) < 0 )
		return YCLICRC_ERROR;
	if ( ( r = put_field( Lic, k, Value ) ) != YCLICRC_ERROR )
		Lic->changed = YCLICRC_TRUE;
	return r;
}
