#include	<string.h>
#include	<stdlib.h>
#include	<locale.h>
#include	<langinfo.h>
#include	<iconv.h>
#include	"pugixml.hpp"
#include	"appxml.h"

#define	NAME_DECLARE	"xml"
#define	NAME_VERSION	"version"
#define	NAME_ENCODING	"encoding"
#define	VALUE_VERSION	"1.0"

#define	SAVE_OPT(x)	"\t", ( x == 0 ? format_raw : format_indent ), \
			encoding_auto

using namespace	pugi;

typedef	struct	_XMLDOC	{
	XMLERR		Err;
	xml_document	*Doc;
	iconv_t		D2L;
	iconv_t		L2D;
}	_XMLDOC;

typedef	struct	_XMLNODE	{
	XMLDOC		Doc;
	xml_node	*Node;
}	_XMLNODE;

static	void	ErrorProc( XMLDOC Doc, xml_parse_result *Result )
{
	if ( Doc->Err == NULL )
		return;
	(*Doc->Err)( "%d: %s", Result->offset, Result->description() );
}

static	int	SetCnv( XMLDOC Doc, const char *Encode )
{
	const char	*p;

	if ( Encode == NULL ) {
		Doc->D2L = (iconv_t) -1;
		Doc->L2D = (iconv_t) -1;
		return 0;
	}
	setlocale( LC_ALL, "" );
	p = nl_langinfo( CODESET );
	if ( ( Doc->D2L = iconv_open( p, Encode ) ) == (iconv_t) -1 )
		goto _L0;
	if ( ( Doc->L2D = iconv_open( Encode, p ) ) == (iconv_t) -1 )
		goto _L1;
	return 0;
//_L2:
//	iconv_close( Doc->L2D );
_L1:
	iconv_close( Doc->D2L );
_L0:
	return -1;
}

static	void	ResetCnv( XMLDOC Doc )
{
	if ( Doc->D2L != (iconv_t) -1 )
		iconv_close( Doc->D2L );
	if ( Doc->L2D != (iconv_t) -1 )
		iconv_close( Doc->L2D );
}

static	int	CnvStr( iconv_t Cnv, const char *Str, char *Buf, int Size )
{
	char	*p, *q;
	size_t	i, o;
	int	r;

	if ( Cnv == (iconv_t) -1 ) {
		if ( ( r = strlen( Str ) ) >= Size )
			return -1;
		strcpy( Buf, Str );
	}
	else {
		p = (char *) Str;
		i = ( strlen( Str ) + 1 ) * sizeof( char );
		q = Buf;
		o = Size * sizeof( char );
		if ( iconv( Cnv, &p, &i, &q, &o ) < 0 )
			return -1;
		r = ( q - Buf ) - 1;
	}
	return r;
}

static	int	SetPI( xml_document *Doc, const char *Encode )
{
	xml_node	n;
	xml_attribute	a;

	if ( Encode == NULL )
		return 0;
	n = Doc->child( NAME_DECLARE );
	if ( n.empty() ) {
		n = Doc->prepend_child( node_declaration );
		if ( n.empty() )
			return -1;
		if ( !n.set_name( NAME_DECLARE ) )
			return -1;
	}
	a = n.attribute( NAME_VERSION );
	if ( a.empty() ) {
		a = n.append_attribute( NAME_VERSION );
		if ( a.empty() )
			return -1;
	}
	if ( !a.set_value( VALUE_VERSION ) )
		return -1;
	a = n.attribute( NAME_ENCODING );
	if ( a.empty() ) {
		a = n.append_attribute( NAME_ENCODING );
		if ( a.empty() )
			return -1;
	}
	if ( !a.set_value( Encode ) )
		return -1;
	return 0;
}

static	const char *	GetDocEnc( xml_document *Doc )
{
	xml_node	n;
	xml_attribute	a;

	n = Doc->child( NAME_DECLARE );
	if ( n.empty() )
		return NULL;
	a = n.attribute( NAME_ENCODING );
	if ( a.empty() )
		return NULL;
	return a.value();
}

XMLDOC	appXmlNew( const char *Encode, XMLERR Callback )
{
	XMLDOC	d;

	if ( ( d = (XMLDOC) malloc( sizeof( *d ) ) ) == NULL )
		goto _L0;
	if ( ( d->Doc = new xml_document() ) == NULL )
		goto _L1;
	if ( SetCnv( d, Encode ) < 0 )
		goto _L2;
	if ( SetPI( d->Doc, Encode ) < 0 )
		goto _L3;
	d->Err = Callback;
	return d;
_L3:
	ResetCnv( d );
_L2:
	delete d->Doc;
_L1:
	free( d );
_L0:
	return NULL;
}

void	appXmlFree( XMLDOC Doc )
{
	ResetCnv( Doc );
	delete Doc->Doc;
	free( Doc );
}

int	appXmlParse( XMLDOC Doc, const char *Buffer, int Size )
{
	xml_parse_result	r;

	r = Doc->Doc->load_buffer( Buffer, Size, parse_declaration,
			encoding_auto );
	if ( !r )
		ErrorProc( Doc, &r );
	else if ( SetCnv( Doc, GetDocEnc( Doc->Doc ) ) == 0 )
		return 0;
	return -1;
}

struct	xml_memory_writer:	pugi::xml_writer
{
	char *	Buffer;
	size_t	BufSize;
	size_t	BufUsed;

	xml_memory_writer( char *Buffer, size_t Size ):
			Buffer(Buffer), BufSize(Size), BufUsed(0)
	{
	}

	size_t	UsedSize( void ) const
	{
		return ( BufUsed < BufSize ? BufUsed : BufSize );
	}

	virtual	void	write( const void *Data, size_t Size )
	{
		size_t	Work;

		if ( BufUsed < BufSize ) {
			Work = ( BufSize - BufUsed < Size ? BufSize - BufUsed
					: Size );
			memcpy( Buffer + BufUsed, Data, Work );
		}
		BufUsed += Size;
	}
};

int	appXmlForm( XMLDOC Doc, int Mode, char *Buffer, int Size )
{
	xml_memory_writer	w( Buffer, Size - 1 );
	int	s;

	Doc->Doc->save( w, SAVE_OPT( Mode ) );
	if ( ( s = w.UsedSize() ) >= Size )
		return -1;
	Buffer[s] = 0;
	return s;
}

int	appXmlLoad( XMLDOC Doc, const char *File )
{
	xml_parse_result	r;

	r = Doc->Doc->load_file( File, parse_declaration, encoding_auto );
	if ( !r )
		ErrorProc( Doc, &r );
	else if ( SetCnv( Doc, GetDocEnc( Doc->Doc ) ) == 0 )
		return 0;
	return -1;
}

int	appXmlSave( XMLDOC Doc, int Mode, const char *File )
{
	if ( !Doc->Doc->save_file( File, SAVE_OPT( Mode ) ) )
		return -1;
	return 0;
}

XMLDOC	appXmlDoc( XMLNODE Node )
{
	return Node->Doc;
}

XMLNODE	appXmlSetup( XMLDOC Doc )
{
	XMLNODE	n;

	if ( ( n = (XMLNODE) malloc( sizeof( *n ) ) ) == NULL )
		goto _L0;
	if ( ( n->Node = new xml_node() ) == NULL )
		goto _L1;
	n->Doc = Doc;
	return n;
//_L2:
//	delete n->Node;
_L1:
	free( n );
_L0:
	return NULL;
}

void	appXmlReset( XMLNODE Node )
{
	delete Node->Node;
	free( Node );
}

void	appXmlCopy( XMLNODE Target, XMLNODE Source )
{
	Target->Doc = Source->Doc;
	memcpy( Target->Node, Source->Node, sizeof( xml_node ) );
}

static	int	CloneNode( xml_node * Source, XMLNODE Target )
{
	if ( Target != NULL )
		memcpy( Target->Node, Source, sizeof( xml_node ) );
	return 0;
}

static	char *	CnvL2D( iconv_t Cnv, const char *Loc )
{
	char	*v;
	int	s;

	s = ( strlen( Loc ) + 1 ) * 2;
	if ( ( v = (char *) malloc( s * sizeof( char ) ) ) == NULL )
		goto _L0;
	if ( CnvStr( Cnv, Loc, v, s ) < 0 )
		goto _L1;
	return v;
_L1:
	free( v );
_L0:
	return NULL;
}

static	int	CompL2D( iconv_t Cnv, const char *Std, const char *Loc )
{
	char	*v;
	int	r = -1;

	if ( ( v = CnvL2D( Cnv, Loc ) ) == NULL )
		goto _L0;
	r = ( strcmp( Std, v ) == 0 ? 0 : 1 );
	free( v );
_L0:
	return r;
}

int	appXmlGetRoot( XMLDOC Doc, const char *Name, XMLNODE Root )
{
	xml_node	n;

	n = Doc->Doc->document_element();
	if ( n.empty() )
		return 1;
	if ( Name != NULL && CompL2D( Doc->L2D, n.name(), Name ) != 0 )
		return -1;
	return CloneNode( &n, Root );
}

int	appXmlSetRoot( XMLDOC Doc, const char *Name, XMLNODE Root )
{
	xml_node	n;
	char	*v;
	int	r = -1;

	if ( Name == NULL )
		v = NULL;
	else if ( ( v = CnvL2D( Doc->L2D, Name ) ) == NULL )
		goto _L0;
	n = Doc->Doc->document_element();
	if ( n.empty() ) {
		n = Doc->Doc->append_child( v );
		if ( n.empty() )
			goto _L1;
	}
	else {
		if ( !n.set_name( v ) )
			goto _L1;
	}
	r = CloneNode( &n, Root );
_L1:
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

int	appXmlGetChild( XMLNODE Node, const char *Name, XMLNODE Child )
{
	xml_node	n;
	char	*v;
	int	r = -1;

	if ( Name == NULL )
		v = NULL;
	else if ( ( v = CnvL2D( Node->Doc->L2D, Name ) ) == NULL )
		goto _L0;
	if ( v == NULL )
		n = Node->Node->first_child();
	else
		n = Node->Node->child( v );
	if ( n.empty() )
		r = 1;
	else
		r = CloneNode( &n, Child );
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

int	appXmlSetChild( XMLNODE Node, const char *Name, XMLNODE Child )
{
	xml_node	n;
	char	*v;
	int	r = -1;

	if ( Name == NULL )
		v = NULL;
	else if ( ( v = CnvL2D( Node->Doc->L2D, Name ) ) == NULL )
		goto _L0;
	if ( v == NULL )
		n = Node->Node->append_child();
	else
		n = Node->Node->append_child( v );
	if ( !n.empty() )
		r = CloneNode( &n, Child );
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

int	appXmlUnsetChild( XMLNODE Node, const char *Name )
{
	xml_node	n;
	char	*v;
	int	r = -1;

	if ( Name == NULL ) {
		for ( n = Node->Node->first_child(); !n.empty();
				n = Node->Node->first_child() )
			if ( !Node->Node->remove_child( n ) )
				return -1;
		return 0;
	}
	if ( ( v = CnvL2D( Node->Doc->L2D, Name ) ) == NULL )
		goto _L0;
	if ( Node->Node->remove_child( Name ) )
		r = 0;
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

int	appXmlFindNext( XMLNODE Node, const char *Name, XMLNODE Next )
{
	xml_node	n;
	char	*v;
	int	r = -1;

	if ( Name == NULL )
		v = NULL;
	else if ( ( v = CnvL2D( Node->Doc->L2D, Name ) ) == NULL )
		goto _L0;
	if ( v == NULL )
		n = Node->Node->next_sibling();
	else
		n = Node->Node->next_sibling( v );
	if ( n.empty() )
		r = 1;
	else
		r = CloneNode( &n, Next );
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

int	appXmlGetName( XMLNODE Node, char *Name, int Size )
{
	return CnvStr( Node->Doc->D2L, Node->Node->name(), Name, Size );
}

int	appXmlSetName( XMLNODE Node, const char *Name )
{
	char	*v;
	int	r = -1;

	if ( ( v = CnvL2D( Node->Doc->L2D, Name ) ) == NULL )
		goto _L0;
	if ( Node->Node->set_name( v ) )
		r = 0;
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

int	appXmlUnsetName( XMLNODE Node )
{
	if ( Node->Node->set_name( NULL ) )
		return 0;
	return -1;
}

int	appXmlCheckName( XMLNODE Node, const char *Name )
{
	char	*v;
	int	r = -1;

	if ( ( v = CnvL2D( Node->Doc->L2D, Name ) ) == NULL )
		goto _L0;
	if ( strcmp( Node->Node->name(), v ) == 0 )
		r = 0;
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

int	appXmlGetValue( XMLNODE Node, char *Value, int Size )
{
	xml_node	n;

	n = Node->Node->first_child();
	if ( n.type() != node_pcdata )
		return -1;
	return CnvStr( Node->Doc->D2L, n.value(), Value, Size );
}

int	appXmlSetValue( XMLNODE Node, const char *Value )
{
	xml_node	n;
	char	*v;
	int	r = -1;

	if ( ( v = CnvL2D( Node->Doc->L2D, Value ) ) == NULL )
		goto _L0;
	n = Node->Node->first_child();
	if ( n.empty() ) {
		n = Node->Node->append_child( node_pcdata );
		if ( n.empty() )
			goto _L1;
	}
	else {
		if ( n.type() != node_pcdata )
			goto _L1;
	}
	if ( n.set_value( v ) )
		r = 0;
_L1:
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

int	appXmlUnsetValue( XMLNODE Node )
{
	xml_node	n;

	for ( n = Node->Node->first_child(); n.type() != node_pcdata;
			n = n.next_sibling() )
		;
	if ( n.type() != node_pcdata )
		return 0;
	return ( Node->Node->remove_child( n ) ? 0 : -1 );
}

int	appXmlCheckValue( XMLNODE Node, const char *Value )
{
	xml_node	n;
	char	*v;
	int	r = -1;

	if ( ( v = CnvL2D( Node->Doc->L2D, Value ) ) == NULL )
		goto _L0;
	n = Node->Node->first_child();
	if ( n.type() == node_pcdata && strcmp( n.value(), v ) == 0 )
		r = 0;
	else
		r = 1;
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

int	appXmlGetAttr( XMLNODE Node, const char *Name, char *Value, int Size )
{
	xml_attribute	a;
	char	*v;
	int	r = -1;

	if ( Name == NULL )
		v = NULL;
	else if ( ( v = CnvL2D( Node->Doc->L2D, Name ) ) == NULL )
		goto _L0;
	a = Node->Node->attribute( v );
	r = CnvStr( Node->Doc->D2L, a.value(), Value, Size );
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

int	appXmlSetAttr( XMLNODE Node, const char *Name, const char *Value )
{
	xml_attribute	a;
	char	*v, *p;
	int	r = -1;

	if ( Name == NULL )
		v = NULL;
	else if ( ( v = CnvL2D( Node->Doc->L2D, Name ) ) == NULL )
		goto _L0;
	a = Node->Node->attribute( v );
	if ( a.empty() )
		a = Node->Node->append_attribute( v );
	if ( a.empty() )
		goto _L1;
	if ( Value == NULL )
		p = NULL;
	else if ( ( p = CnvL2D( Node->Doc->L2D, Value ) ) == NULL )
		goto _L1;
	if ( a.set_value( p ) )
		r = 0;
	if ( p != NULL )
		free( p );
_L1:
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

int	appXmlUnsetAttr( XMLNODE Node, const char *Name )
{
	xml_attribute	a;
	char	*v;
	int	r = -1;

	if ( Name == NULL ) {
		for ( a = Node->Node->first_attribute(); !a.empty();
				a = Node->Node->first_attribute() )
			if ( !Node->Node->remove_attribute( a ) )
				return -1;
		return 0;
	}
	if ( ( v = CnvL2D( Node->Doc->L2D, Name ) ) == NULL )
		goto _L0;
	if ( Node->Node->remove_attribute( v ) )
		r = 0;
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

int	appXmlCheckAttr( XMLNODE Node, const char *Name, const char *Value )
{
	xml_attribute	a;
	char	*v, *p;
	int	r = -1;

	if ( Name == NULL )
		v = NULL;
	else if ( ( v = CnvL2D( Node->Doc->L2D, Name ) ) == NULL )
		goto _L0;
	a = Node->Node->attribute( v );
	if ( ( p = CnvL2D( Node->Doc->L2D, Value ) ) == NULL )
		goto _L1;
	if ( strcmp( a.value(), p ) == 0 )
		r = 0;
	else
		r = 1;
	free( p );
_L1:
	if ( v != NULL )
		free( v );
_L0:
	return r;
}

const char *	appXmlName( XMLNODE Node )
{
	return Node->Node->name();
}

const char *	appXmlText( XMLNODE Node )
{
	xml_node	n;

	n = Node->Node->first_child();
	if ( n.type() != node_pcdata )
		return NULL;
	return n.value();
}

const char *	appXmlAttr( XMLNODE Node, const char *Name )
{
	char	*v;
	const char	*p;

	if ( ( v = CnvL2D( Node->Doc->L2D, Name ) ) == NULL )
		return NULL;
	p = Node->Node->attribute( v ).value();
	free( v );
	return p;
}
