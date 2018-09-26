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

#define LEN_MSG		1024		/* ������Ϣ���� */
#define LEN_MD5		33		/* MD5 ���� */
#define	LEN_BUF		4096		/* ���ݻ��������� */
#define	LEN_KEY		32		/* �ؼ��ֻ��������� */
#define	LEN_DATE	11		/* ����ֵ���� */

typedef char    LICMSG[LEN_MSG];	/*���֤��Ϣ����*/
typedef char    MD5TXT[LEN_MD5];	/*MD5���ݱ���*/
typedef	char	MD5BUF[LEN_BUF];	/*MD5����������*/
typedef	char	KEYBUF[LEN_KEY];	/*�ؼ��ֱ���*/
typedef	char	DATEVAL[LEN_DATE];	/*����ֵ����*/

typedef	struct	_YCLIC_T{	/*���֤���ṹ*/
	XMLDOC	doc;			/*�ĵ�����*/
	XMLNODE	root;			/*���ڵ�*/
	iconv_t	cnv;			/*ת�����*/
	int	changed;		/*���֤�иĶ�Ϊ1����֮Ϊ0*/
	LICMSG	msg;			/*������Ϣ*/
}	_YCLIC_T;

/*
������֤�Ƿ���سɹ�
���� 0 ��ʾ�ɹ���-1 ��ʾʧ��
*/
static	int
check_doc(YCLIC_T Lic)
{
	if ( Lic->doc == NULL ) {
		strcpy( Lic->msg, "û�����֤��Ϣ" );
		return -1;
	}
	return 0;
}

/*
�����ڵ㹤����
���ؽڵ��ʾ�ɹ���NULL ��ʾʧ��
*/
static	XMLNODE
set_node(YCLIC_T Lic)
{
	XMLNODE	Node;

	if ( ( Node = appXmlSetup( Lic->doc ) ) == NULL )
		strcpy( Lic->msg, "�ڵ㹤��������ʧ��" );
	return Node;
}

/*
���ڵ�������ϳ��ַ���
���� -1 ��ʾʧ��
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
			strcpy( Lic->msg, "���ݻ���������" );
			return -1;
		}
		strcpy( Buf + s, t );
		s += l;
		t = appXmlText( Work );
		if ( t != NULL ) {
			if ( ( l = strlen( t ) ) >= LEN_BUF - s ) {
				strcpy( Lic->msg, "���ݻ���������" );
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
��ȡ����ת����MD5���ַ���
���� -1 ��ʾʧ��
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
����MD5��
���� 0 ��ʾ�ɹ���-1 ��ʾʧ��
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
		strcpy( Lic->msg, "У��ת��ʧ��" );
		return -1;
	}
	md5( Txt, ( sizeof( Txt ) - o ) / sizeof( char ), Md5 );
	return 0;
}

/*
����ת��
���� -1 ��ʾʧ��
*/
static	time_t
make_date(YCLIC_T Lic, struct tm *Time)
{
	time_t	t;

	Time->tm_hour = 0;
	Time->tm_min = 0;
	Time->tm_sec = 0;
	if ( ( t = mktime( Time ) ) == -1 )
		strcpy( Lic->msg, "��Ч������ֵ" );
	return t;
}

/*
��֤���֤�е�����
���� -1 ��ʾ������Ч
*/
static	time_t
cnv_date(YCLIC_T Lic, const DATEVAL Date)
{
	int	y, m, d;
	struct	tm	v;
	time_t	t;

	if ( sscanf( Date, "%d-%d-%d", &y, &m, &d ) != 3 ) {
		strcpy( Lic->msg, "��Ч�����ڸ�ʽ" );
		return -1;
	}
	v.tm_year = y - 1900;
	v.tm_mon = m - 1;
	v.tm_mday = d;
	return make_date( Lic, &v );
}

/*
��ȡ��������
���� -1 ��ʾʧ��
*/
static	time_t
get_date(YCLIC_T Lic)
{
	time_t	t;
	struct	tm	*v;

	if ( ( t = time( NULL ) ) == -1 ) {
		strcpy( Lic->msg, "��ȡ��ǰ����ʧ��" );
		return -1;
	}
	if ( ( v = localtime( &t ) ) == NULL ) {
		strcpy( Lic->msg, "ת����ǰ����ʧ��" );
		return -1;
	}
	return make_date( Lic, v );
}

/*
�������Ԫ��
���� -1 ��ʾʧ��
*/
static	int
check_field(YCLIC_T Lic, XMLNODE Node, const char *Key)
{
	int	r;

	if ( ( r = appXmlCheckAttr( Node, XMLATTR_NAME, Key ) ) < 0 )
		strcpy( Lic->msg, "�������Ԫ��ʧ��" );
	return r;
}

/*
��ȡָ��������Ԫ��
���� -1 ��ʾʧ��
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
		strcpy( Lic->msg, "δ�ҵ�ָ��������Ԫ��" );
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
�޸�/�������Ԫ��ֵ
���� -1 ��ʾʧ�ܣ�0 ��ʾ�滻�ɹ���1 ��ʾ��ӳɹ�
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
				strcpy( Lic->msg, "�޸�����Ԫ��ֵʧ��" );
			else
				r = YCLICRC_FALSE;
			break;
		}
		appXmlCopy( Temp, Work );
	}
	if ( s != 0 ) {
		if ( appXmlSetChild( Lic->root, XMLNODE_ATTR, Work ) < 0 ) {
			strcpy( Lic->msg, "�������Ԫ��ʧ��" );
			goto _L2;
		}
		if ( appXmlSetAttr( Work, XMLATTR_NAME, Key ) < 0 ) {
			strcpy( Lic->msg, "��������Ԫ����ʧ��" );
			goto _L2;
		}
		if ( appXmlSetValue( Work, Val ) < 0 ) {
			strcpy( Lic->msg, "��������Ԫ��ֵʧ��" );
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
�������֤���
���� ���֤��� ��ʾ�ɹ���NULL ��ʾ����ʧ��
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
�ͷ����֤���
�޷���ֵ
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
�����֤�ļ�
���� 1 ��ʾ�ɹ���0 ��ʾ�ļ������ڻ�Ƿ���-1 ��ʾʧ��
*/
int
ycLicOpen(YCLIC_T Lic, const char * LicFile)
{
	int	r, s;
	MD5TXT	Md5Dat, Md5Tmp;

	r = YCLICRC_ERROR;
	if ( ( Lic->doc = appXmlNew( NULL, NULL ) ) == NULL ) {
		strcpy( Lic->msg, "�������ĵ�����ʧ��" );
		goto _L0;
	}
	if ( ( appXmlLoad( Lic->doc, LicFile ) ) < 0 ) {
		strcpy( Lic->msg, "�������֤�ļ�ʧ��" );
		goto _L1;
	}
	if ( ( Lic->root = set_node( Lic ) ) == NULL )
		goto _L1;
	if ( appXmlGetRoot( Lic->doc, XMLNODE_ROOT, Lic->root ) < 0 ) {
		strcpy( Lic->msg, "��ȡ���ڵ�ʧ��" );
		goto _L2;
	}
	if ( appXmlGetAttr( Lic->root, XMLATTR_VALID, Md5Dat,
			sizeof( Md5Dat ) ) < 0 ) {
		strcpy( Lic->msg, "��ȡУ����ʧ��" );
		goto _L2;
	}
	if ( make_md5( Lic, Md5Tmp ) < 0 )
		goto _L2;
	r = YCLICRC_FALSE;
	if ( strcmp( Md5Dat, Md5Tmp ) != 0 ) {
		strcpy( Lic->msg, "���֤У�����" );
		goto _L2;
	}
	if ( ( s = ycLicIsExpired( Lic ) ) == YCLICRC_ERROR ) {
		r = s;
		goto _L2;
	}
	else if ( s == YCLICRC_TRUE ) {
		strcpy( Lic->msg, "���֤�ѹ���" );
		goto _L2;
	}
	if ( ( s = ycLicIsEarlier( Lic ) ) == YCLICRC_ERROR ) {
		r = s;
		goto _L2;
	}
	else if ( s == YCLICRC_TRUE ) {
		strcpy( Lic->msg, "���֤δ����" );
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
�ر����֤�ļ�
���� 1 ��ʾ�ɹ���0 ��ʾû�б��棬-1 ��ʾʧ��
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
		strcpy( Lic->msg, "����У����ʧ��" );
		return YCLICRC_ERROR;
	}
	if ( appXmlSave( Lic->doc, 0, LicFile ) < 0 ) {
		strcpy( Lic->msg, "�������֤�ļ�ʧ��" );
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
��ȡ��ǰ������Ϣ
���ش�����Ϣ��NULL ��ʾ��
*/
const char *
ycLicGetErrMsg(YCLIC_T Lic)
{
	return Lic->msg;
}

/*
������֤�Ƿ����
���� 0 ��ʾδ���ڣ�1 ��ʾ�ѹ��ڣ�-1 ��ʾʧ��
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
������֤�Ƿ�����
���� 0 ��ʾδ���ã�1 ��ʾ�����ã�-1 ��ʾʧ��
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
��ȡ���֤����ʱ��
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetBuildTime(YCLIC_T Lic, char *Buffer, int Length)
{
	if ( check_doc( Lic ) < 0 )
		return YCLICRC_ERROR;
	if ( appXmlGetAttr( Lic->root, XMLATTR_BUILD, Buffer, Length ) < 0 ) {
		strcpy( Lic->msg, "��ȡ����ʱ��ʧ��" );
		return YCLICRC_ERROR;
	}
	return YCLICRC_TRUE;
}

/*
��ȡ���֤���
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetLicenseCode(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_LICCODE, Buffer, Length );
}

/*
��ȡ���֤����
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetLicenseType(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_LICTYPE, Buffer, Length );
}

/*
��ȡ��Ʒ���
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetProductCode(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_PRODCODE, Buffer, Length );
}

/*
��ȡ��Ʒ��������
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetProductNameZh(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_PRODNMZH, Buffer, Length );
}

/*
��ȡ��ƷӢ������
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetProductNameEn(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_PRODNMEN, Buffer, Length );
}

/*
��ȡ��Ʒ���汾��
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetVersionMajor(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_VERMAJOR, Buffer, Length );
}

/*
��ȡ��Ʒ�Ӱ汾��
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetVersionSub(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_VERSUB, Buffer, Length );
}

/*
��ȡ��Ʒ������
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetVersionPublish(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_VERPUB, Buffer, Length );
}

/*
��ȡ��Ʒ��������
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetCompileDate(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_COMPILE, Buffer, Length );
}

/*
��ȡʹ�ÿͻ�����
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetCustomerName(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_CUSTOMER, Buffer, Length );
}

/*
��ȡ���ۺ�ͬ��
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetContractCode(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_CONTRACT, Buffer, Length );
}

/*
��ȡ���֤��Ч��ʼ����
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetStartTime(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_LICSTART, Buffer, Length );
}

/*
��ȡ���֤��Ч��ֹ����
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
*/
int
ycLicGetEndTime(YCLIC_T Lic, char *Buffer, int Length)
{
	return get_field( Lic, XMLFLD_LICEND, Buffer, Length );
}

/*
��ȡ���֤��չ��Ϣ
���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ��
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
������֤��չ��Ϣ
���� 1 ��ʾ��ӳɹ���0 ��ʾ�滻�ɹ���-1 ��ʾʧ��
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
