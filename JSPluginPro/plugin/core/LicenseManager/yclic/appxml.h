//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+ �ļ����ƣ�appxml.h                                                        +
//+ �ļ����ݣ�Ӧ�ÿ��� XML ����ͨ�û���������                                 +
//+ �ļ����ߣ�����                                                            +
//+ �����޶���2013.12.12                                                      +
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef	APPXML_H
#define	APPXML_H

#ifdef	__cplusplus
extern	"C"	{
#endif	// def	__cplusplus

//==============================================================================
// �����������Ͷ���
typedef	struct	_XMLDOC *	XMLDOC;		// ��׼�ĵ�����
typedef	struct	_XMLNODE *	XMLNODE;	// ��׼�ڵ�����
typedef	void
	(*XMLERR)(				// ��׼������ص���������
		const char *	Format,			// ������Ϣ��ʽ
		...					// ������Ϣ����
	);

//==============================================================================
// �����ӿں�������
extern	XMLDOC
	appXmlNew(			// �����µĿ��ĵ�����
		const char *	Encode,		// �ַ������루NULL��ʾ���ԣ�
		XMLERR		Callback	// ������ص�����
	);	// �����½��ĵ�����NULL��ʾʧ�ܡ�

extern	void
	appXmlFree(			// �ͷ��ĵ�����
		XMLDOC		Doc		// ���ͷŵ��ĵ�����
	);

extern	int
	appXmlParse(			// �����ı����ĵ�����
		XMLDOC		Doc,		// �ĵ�����
		const char *	Buffer,		// �ı�����
		int		Size		// �ı����ȣ�-1��ʾ���м��㣩
	);	// ����0��ʾ�ɹ���-1��ʾʧ��

extern	int
	appXmlForm(			// ���ĵ�������װ�ı�
		XMLDOC		Doc,		// �ĵ�����
		int		Mode,		// ����ģʽ��0��ʾ������
		char *		Buffer,		// �ı����������
		int		Size		// �������ֽ���
	);	// ������װ���ı����ȣ�-1��ʾʧ��

extern	int
	appXmlLoad(			// �����ļ����ĵ�����
		XMLDOC		Doc,		// �ĵ�����
		const char *	File		// �ļ�����
	);	// ����0��ʾ�ɹ���-1��ʾʧ��

extern	int
	appXmlSave(			// ���ĵ�������װ�ļ�
		XMLDOC		Doc,		// �ĵ�����
		int		Mode,		// ����ģʽ��0��ʾ������
		const char *	File		// �ļ�����
	);	// ����0��ʾ�ɹ���-1��ʾʧ��

extern	XMLDOC
	appXmlDoc(			// ��ȡ�ڵ������ĵ�����
		XMLNODE		Node		// �ڵ����
	);	// �����ĵ�����

extern	XMLNODE
	appXmlSetup(			// �����ڵ��������
		XMLDOC		Doc		// �ĵ�����
	);	// ���ؽڵ㹤������NULL��ʾʧ��

extern	void
	appXmlReset(			// �ͷŽڵ��������
		XMLNODE		Node		// ���ͷŽڵ����
	);

extern	void
	appXmlCopy(			// ���ƽڵ����
		XMLNODE		Target,		// Ŀ��ڵ����
		XMLNODE		Source		// Դ�ڵ����
	);

extern	int
	appXmlGetRoot(			// ��鲢��ȡ�ĵ�����ĸ��ڵ����
		XMLDOC		Doc,		// �ĵ�����
		const char *	Name,		// ���ڵ�����NULL��ʾ���Լ�飩
		XMLNODE		Root		// ���ڵ����NULL��ʾ�����أ�
	);	// ����0��ʾ�ɹ���1��ʾû�и��ڵ㣬-1��ʾ��Ч�ĸ��ڵ�

extern	int
	appXmlSetRoot(			// �����ĵ�����ĸ��ڵ����
		XMLDOC		Doc,		// �ĵ�����
		const char *	Name,		// ���ڵ���
		XMLNODE		Root		// ���ڵ����
	);	// ����0��ʾ�ɹ���-1��ʾʧ��

extern	int
	appXmlGetChild(			// ����ָ�������ָ�����Ƶ��ӽڵ����
		XMLNODE		Node,		// �ڵ����
		const char *	Name,		// �ӽڵ�����NULL��ʾ�������ƣ�
		XMLNODE		Child		// �ӽڵ����NULL��ʾ�����أ�
	);	// ����0��ʾ�ɹ���1��ʾδ�ҵ���-1��ʾʧ��

extern	int
	appXmlSetChild(			// ����ָ�������ָ�����Ƶ��ӽڵ����
		XMLNODE		Node,		// �ڵ����
		const char *	Name,		// �ӽڵ�����NULL��ʾ�����ƣ�
		XMLNODE		Child		// �ӽڵ����NULL��ʾ�����أ�
	);	// ����0��ʾ�ɹ���-1��ʾʧ��

extern	int
	appXmlUnsetChild(		// ɾ��ָ�������ָ�����ӽڵ����
		XMLNODE		Node,		// �ڵ����
		const char *	Name		// �ӽڵ�����NULL��ʾȫ����
	);	// ����0��ʾ�ɹ���-1��ʾʧ��

extern	int
	appXmlFindNext(			// ����ָ���ڵ��ָ�����Ƶ���һ�ڵ����
		XMLNODE		Node,		// ���սڵ����
		const char *	Name,		// �����ҽڵ�����NULL��ʾ���⣩
		XMLNODE		Next		// �νڵ����NULL��ʾ�����أ�
	);	// ����0��ʾ�ɹ���1��ʾδ�ҵ���-1��ʾʧ��

extern	int
	appXmlGetName(			// ��ȡ�ڵ���
		XMLNODE		Node,		// �ڵ����
		char *		Name,		// �ڵ���������
		int		Size		// �������ֽ���
	);	// ���ؽڵ������ȣ�-1��ʾʧ��

extern	int
	appXmlSetName(			// ���ýڵ���
		XMLNODE		Node,		// �ڵ����
		const char *	Name		// �ڵ���
	);	// ����0��ʾ�ɹ���-1��ʾʧ��

extern	int
	appXmlUnsetName(		// ɾ���ڵ���
		XMLNODE		Node		// �ڵ����
	);	// ����0��ʾ�ɹ���-1��ʾʧ��

extern	int
	appXmlCheckName(		// ���ڵ���
		XMLNODE		Node,		// �ڵ����
		const char *	Name		// �ڵ���
	);	// ����0��ʾ��ȣ�1��ʾ����ȣ�-1��ʾʧ��

extern	int
	appXmlGetValue(			// ��ȡ�ڵ�ֵ
		XMLNODE		Node,		// �ڵ����
		char *		Value,		// �ڵ�ֵ������
		int		Size		// �������ֽ���
	);	// ���ؽڵ�ֵ���ȣ�-1��ʾʧ��

extern	int
	appXmlSetValue(			// ���ýڵ�ֵ
		XMLNODE		Node,		// �ڵ����
		const char *	Value		// �ڵ�ֵ
	);	// ����0��ʾ�ɹ���-1��ʾʧ��

extern	int
	appXmlUnsetValue(		// ɾ���ڵ�ֵ
		XMLNODE		Node		// �ڵ����
	);	// ����0��ʾ�ɹ���-1��ʾʧ��

extern	int
	appXmlCheckValue(		// ���ڵ�ֵ
		XMLNODE		Node,		// �ڵ����
		const char *	Value		// �ڵ�ֵ
	);	// ����0��ʾ��ȣ�1��ʾ����ȣ�-1��ʾʧ��

extern	int
	appXmlGetAttr(			// ��ȡָ���ڵ��ָ������ֵ
		XMLNODE		Node,		// �ڵ����
		const char *	Name,		// ������
		char *		Value,		// ����ֵ������
		int		Size		// �������ֽ���
	);	// ��������ֵ���ȣ�-1��ʾʧ��

extern	int
	appXmlSetAttr(			// ����ָ���ڵ��ָ������ֵ
		XMLNODE		Node,		// �ڵ����
		const char *	Name,		// ������
		const char *	Value		// ����ֵ
	);	// ����0��ʾ�ɹ���-1��ʾʧ��

extern	int
	appXmlUnsetAttr(		// ɾ��ָ���ڵ��ָ������
		XMLNODE		Node,		// �ڵ����
		const char *	Name		// ��������NULL��ʾȫ����
	);	// ����0��ʾ�ɹ���-1��ʾʧ��

extern	int
	appXmlCheckAttr(		// ���ָ���ڵ��ָ������ֵ
		XMLNODE		Node,		// �ڵ����
		const char *	Name,		// ������
		const char *	Value		// ����ֵ
	);	// ����0��ʾ��ȣ�1��ʾ����ȣ�-1��ʾʧ��

extern	const char *
	appXmlName(			// ��ȡ�ڵ�ԭʼ����
		XMLNODE		Node		// �ڵ����
	);	// ���ؽڵ�ԭʼ����

extern	const char *
	appXmlText(			// ��ȡ�ڵ�ԭʼ����
		XMLNODE		Node		// �ڵ����
	);	// ���ؽڵ�ԭʼ����

extern	const char *
	appXmlAttr(			// ��ȡ�ڵ�ԭʼ����
		XMLNODE		Node,		// �ڵ����
		const char *	Name		// ��������
	);	// ���ؽڵ�ԭʼ����

#ifdef	__cplusplus
}
#endif	// def	__cplusplus

#endif	// ndef	APPXML_H

