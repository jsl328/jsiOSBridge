/*****************************************************************************
 * �����׳Ϲ�˾�����Ʒ���֤���������ͷ�ļ�
 * ���������׳ϿƼ����޹�˾��Ȩ����(C) 2012-2013
 *****************************************************************************/

#ifndef	YCLIC_H
#define	YCLIC_H

#ifdef	__cplusplus
extern	"C"	{
#endif

#define	YCLICRC_TRUE	1	/* ����ֵ���棬�����ɹ� */
#define	YCLICRC_FALSE	0	/* ����ֵ���٣�����ʧ�� */
#define	YCLICRC_ERROR	-1	/* ����ֵ���������� */

typedef	struct	_YCLIC_T *	YCLIC_T;	/* ���֤��� */

extern	YCLIC_T				/* �������֤��� */
	ycLicNew(
		void				/* �޲��� */
	);	/* �������֤�����NULL ��ʾ����ʧ�� */

extern	void				/* �ͷ����֤��� */
	ycLicFree(
		YCLIC_T         LicHandle	/* ���֤��� */
	);	/* �޷���ֵ */

extern	int				/* �����֤�ļ� */
	ycLicOpen(
		YCLIC_T         LicHandle,	/* ���֤��� */
		const char *    LicFile         /* ���֤�ļ�ȫ·���� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ�ļ������ڻ�Ƿ���-1 ��ʾʧ�� */

extern	int				/* �ر����֤�ļ� */
	ycLicClose(
		YCLIC_T         LicHandle,	/* ���֤��� */
		const char *    LicFile         /* ���֤�ļ�ȫ·���� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾû�б��棬-1 ��ʾʧ�� */

extern	const char *
	ycLicGetErrMsg(			/* ��ȡ��ǰ������Ϣ */
		YCLIC_T		LicHandle	/* ���֤��� */
	);	/* ������Ϣ��NULL ��ʾ�� */

extern	int
	ycLicIsExpired(			/* ������֤�Ƿ���� */
		YCLIC_T		LicHandle	/* ���֤��� */
	);	/* ���� 0 ��ʾδ���ڣ�1 ��ʾ�ѹ��ڣ�-1 ��ʾʧ�� */

extern	int
	ycLicIsEarlier(			/* ������֤�Ƿ����� */
		YCLIC_T		LicHandle	/* ���֤��� */
	);	/* ���� 0 ��ʾδ���ã�1 ��ʾ�����ã�-1 ��ʾʧ�� */

extern	int
	ycLicGetBuildTime(		/* ��ȡ���֤����ʱ�� */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetLicenseCode(		/* ��ȡ���֤��� */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetLicenseType(		/* ��ȡ���֤���� */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetProductCode(		/* ��ȡ��Ʒ��� */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetProductNameZh(		/* ��ȡ��Ʒ�������� */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetProductNameEn(		/* ��ȡ��ƷӢ������ */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetVersionMajor(		/* ��ȡ��Ʒ���汾�� */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetVersionSub(		/* ��ȡ��Ʒ�Ӱ汾�� */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetVersionPublish(		/* ��ȡ��Ʒ������ */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetCompileDate(		/* ��ȡ��Ʒ�������� */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetCustomerName(		/* ��ȡʹ�ÿͻ����� */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetContractCode(		/* ��ȡ���ۺ�ͬ�� */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetStartTime(		/* ��ȡ���֤��Ч��ʼ���� */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetEndTime(		/* ��ȡ���֤��Ч��ֹ���� */
		YCLIC_T		LicHandle,	/* ���֤��� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicGetExtendInfo(		/* ��ȡ���֤��չ��Ϣ */
		YCLIC_T		LicHandle,	/* ���֤��� */
		int		Number,		/* ��չ��Ϣ�� */
		char *		Buffer,		/* ��������� */
		int		Length		/* ���������� */
	);	/* ���� 1 ��ʾ�ɹ���0 ��ʾ���������㣬-1 ��ʾʧ�� */

extern	int
	ycLicPutExtendInfo(		/* ������֤��չ��Ϣ */
		YCLIC_T		LicHandle,	/* ���֤��� */
		int		Number,		/* ��չ��Ϣ�� */
		const char *	Value		/* ��չ��Ϣֵ */
	);	/* ���� 1 ��ʾ��ӳɹ���0 ��ʾ�滻�ɹ���-1 ��ʾʧ�� */

#ifdef	__cplusplus
}
#endif

#endif
