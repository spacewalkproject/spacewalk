#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#include "newtlib/newt.h"

static int
entryfilter_cb(co, cv, ch, cursor)
newtComponent co;
void *cv;
int ch;
int cursor;
{
	dSP ;
	int res = 0;

	ENTER ;
	SAVETMPS ;
	
	PUSHMARK(SP) ;
	XPUSHs(sv_2mortal(newSVpvf("%c", ch)));
	XPUSHs(sv_2mortal(newSViv(cursor)));
	PUTBACK ;

	perl_call_sv((SV *)cv, G_SCALAR);

	SPAGAIN;
	
	res = POPi;
	PUTBACK ;
	FREETMPS ;
	LEAVE ;
	
	return(res);
}

static void
component_cb(co, cv)
newtComponent co;
void *cv;
{
	dSP ;
	
	PUSHMARK(SP) ;
	perl_call_sv((SV *)cv, G_DISCARD | G_NOARGS);

}

static SV *perl_suspend_cb = NULL;

static void
suspend_cb()
{
	dSP ;
	
	PUSHMARK(SP) ;
	if(perl_suspend_cb)
		perl_call_sv(perl_suspend_cb, G_DISCARD | G_NOARGS);	
}

static int
not_here(s)
char *s;
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

static double
constant(name, arg)
char *name;
int arg;
{
    errno = 0;
    switch (*name) {
    case 'A':
	break;
    case 'B':
	break;
    case 'C':
	break;
    case 'D':
	break;
    case 'E':
	break;
    case 'F':
	break;
    case 'G':
	break;
    case 'H':
	if (strEQ(name, "H_NEWT"))
#ifdef H_NEWT
	    return H_NEWT;
#else
	    goto not_there;
#endif
	break;
    case 'I':
	break;
    case 'J':
	break;
    case 'K':
	break;
    case 'L':
	break;
    case 'M':
	break;
    case 'N':
	if (strEQ(name, "NEWT_ANCHOR_BOTTOM"))
#ifdef NEWT_ANCHOR_BOTTOM
	    return NEWT_ANCHOR_BOTTOM;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_ANCHOR_LEFT"))
#ifdef NEWT_ANCHOR_LEFT
	    return NEWT_ANCHOR_LEFT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_ANCHOR_RIGHT"))
#ifdef NEWT_ANCHOR_RIGHT
	    return NEWT_ANCHOR_RIGHT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_ANCHOR_TOP"))
#ifdef NEWT_ANCHOR_TOP
	    return NEWT_ANCHOR_TOP;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_ACTBUTTON"))
#ifdef NEWT_COLORSET_ACTBUTTON
	    return NEWT_COLORSET_ACTBUTTON;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_ACTCHECKBOX"))
#ifdef NEWT_COLORSET_ACTCHECKBOX
	    return NEWT_COLORSET_ACTCHECKBOX;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_ACTLISTBOX"))
#ifdef NEWT_COLORSET_ACTLISTBOX
	    return NEWT_COLORSET_ACTLISTBOX;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_ACTSELLISTBOX"))
#ifdef NEWT_COLORSET_ACTSELLISTBOX
	    return NEWT_COLORSET_ACTSELLISTBOX;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_ACTTEXTBOX"))
#ifdef NEWT_COLORSET_ACTTEXTBOX
	    return NEWT_COLORSET_ACTTEXTBOX;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_BORDER"))
#ifdef NEWT_COLORSET_BORDER
	    return NEWT_COLORSET_BORDER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_BUTTON"))
#ifdef NEWT_COLORSET_BUTTON
	    return NEWT_COLORSET_BUTTON;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_CHECKBOX"))
#ifdef NEWT_COLORSET_CHECKBOX
	    return NEWT_COLORSET_CHECKBOX;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_COMPACTBUTTON"))
#ifdef NEWT_COLORSET_COMPACTBUTTON
	    return NEWT_COLORSET_COMPACTBUTTON;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_DISENTRY"))
#ifdef NEWT_COLORSET_DISENTRY
	    return NEWT_COLORSET_DISENTRY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_EMPTYSCALE"))
#ifdef NEWT_COLORSET_EMPTYSCALE
	    return NEWT_COLORSET_EMPTYSCALE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_ENTRY"))
#ifdef NEWT_COLORSET_ENTRY
	    return NEWT_COLORSET_ENTRY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_FULLSCALE"))
#ifdef NEWT_COLORSET_FULLSCALE
	    return NEWT_COLORSET_FULLSCALE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_HELPLINE"))
#ifdef NEWT_COLORSET_HELPLINE
	    return NEWT_COLORSET_HELPLINE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_LABEL"))
#ifdef NEWT_COLORSET_LABEL
	    return NEWT_COLORSET_LABEL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_LISTBOX"))
#ifdef NEWT_COLORSET_LISTBOX
	    return NEWT_COLORSET_LISTBOX;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_ROOT"))
#ifdef NEWT_COLORSET_ROOT
	    return NEWT_COLORSET_ROOT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_ROOTTEXT"))
#ifdef NEWT_COLORSET_ROOTTEXT
	    return NEWT_COLORSET_ROOTTEXT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_SELLISTBOX"))
#ifdef NEWT_COLORSET_SELLISTBOX
	    return NEWT_COLORSET_SELLISTBOX;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_SHADOW"))
#ifdef NEWT_COLORSET_SHADOW
	    return NEWT_COLORSET_SHADOW;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_TEXTBOX"))
#ifdef NEWT_COLORSET_TEXTBOX
	    return NEWT_COLORSET_TEXTBOX;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_TITLE"))
#ifdef NEWT_COLORSET_TITLE
	    return NEWT_COLORSET_TITLE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_COLORSET_WINDOW"))
#ifdef NEWT_COLORSET_WINDOW
	    return NEWT_COLORSET_WINDOW;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_ENTRY_DISABLED"))
#ifdef NEWT_ENTRY_DISABLED
	    return NEWT_ENTRY_DISABLED;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_ENTRY_HIDDEN"))
#ifdef NEWT_ENTRY_HIDDEN
	    return NEWT_ENTRY_HIDDEN;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_ENTRY_RETURNEXIT"))
#ifdef NEWT_ENTRY_RETURNEXIT
	    return NEWT_ENTRY_RETURNEXIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_ENTRY_SCROLL"))
#ifdef NEWT_ENTRY_SCROLL
	    return NEWT_ENTRY_SCROLL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_FD_READ"))
#ifdef NEWT_FD_READ
	    return NEWT_FD_READ;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_FD_WRITE"))
#ifdef NEWT_FD_WRITE
	    return NEWT_FD_WRITE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_FLAG_BORDER"))
#ifdef NEWT_FLAG_BORDER
	    return NEWT_FLAG_BORDER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_FLAG_DISABLED"))
#ifdef NEWT_FLAG_DISABLED
	    return NEWT_FLAG_DISABLED;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_FLAG_HIDDEN"))
#ifdef NEWT_FLAG_HIDDEN
	    return NEWT_FLAG_HIDDEN;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_FLAG_MULTIPLE"))
#ifdef NEWT_FLAG_MULTIPLE
	    return NEWT_FLAG_MULTIPLE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_FLAG_NOF12"))
#ifdef NEWT_FLAG_NOF12
	    return NEWT_FLAG_NOF12;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_FLAG_RETURNEXIT"))
#ifdef NEWT_FLAG_RETURNEXIT
	    return NEWT_FLAG_RETURNEXIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_FLAG_SCROLL"))
#ifdef NEWT_FLAG_SCROLL
	    return NEWT_FLAG_SCROLL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_FLAG_SELECTED"))
#ifdef NEWT_FLAG_SELECTED
	    return NEWT_FLAG_SELECTED;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_FLAG_WRAP"))
#ifdef NEWT_FLAG_WRAP
	    return NEWT_FLAG_WRAP;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_FORM_NOF12"))
#ifdef NEWT_FORM_NOF12
	    return NEWT_FORM_NOF12;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_GRID_FLAG_GROWX"))
#ifdef NEWT_GRID_FLAG_GROWX
	    return NEWT_GRID_FLAG_GROWX;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_GRID_FLAG_GROWY"))
#ifdef NEWT_GRID_FLAG_GROWY
	    return NEWT_GRID_FLAG_GROWY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_BKSPC"))
#ifdef NEWT_KEY_BKSPC
	    return NEWT_KEY_BKSPC;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_DELETE"))
#ifdef NEWT_KEY_DELETE
	    return NEWT_KEY_DELETE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_DOWN"))
#ifdef NEWT_KEY_DOWN
	    return NEWT_KEY_DOWN;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_END"))
#ifdef NEWT_KEY_END
	    return NEWT_KEY_END;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_ENTER"))
#ifdef NEWT_KEY_ENTER
	    return NEWT_KEY_ENTER;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_EXTRA_BASE"))
#ifdef NEWT_KEY_EXTRA_BASE
	    return NEWT_KEY_EXTRA_BASE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_F1"))
#ifdef NEWT_KEY_F1
	    return NEWT_KEY_F1;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_F10"))
#ifdef NEWT_KEY_F10
	    return NEWT_KEY_F10;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_F11"))
#ifdef NEWT_KEY_F11
	    return NEWT_KEY_F11;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_F12"))
#ifdef NEWT_KEY_F12
	    return NEWT_KEY_F12;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_F2"))
#ifdef NEWT_KEY_F2
	    return NEWT_KEY_F2;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_F3"))
#ifdef NEWT_KEY_F3
	    return NEWT_KEY_F3;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_F4"))
#ifdef NEWT_KEY_F4
	    return NEWT_KEY_F4;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_F5"))
#ifdef NEWT_KEY_F5
	    return NEWT_KEY_F5;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_F6"))
#ifdef NEWT_KEY_F6
	    return NEWT_KEY_F6;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_F7"))
#ifdef NEWT_KEY_F7
	    return NEWT_KEY_F7;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_F8"))
#ifdef NEWT_KEY_F8
	    return NEWT_KEY_F8;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_F9"))
#ifdef NEWT_KEY_F9
	    return NEWT_KEY_F9;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_HOME"))
#ifdef NEWT_KEY_HOME
	    return NEWT_KEY_HOME;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_LEFT"))
#ifdef NEWT_KEY_LEFT
	    return NEWT_KEY_LEFT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_PGDN"))
#ifdef NEWT_KEY_PGDN
	    return NEWT_KEY_PGDN;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_PGUP"))
#ifdef NEWT_KEY_PGUP
	    return NEWT_KEY_PGUP;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_RESIZE"))
#ifdef NEWT_KEY_RESIZE
	    return NEWT_KEY_RESIZE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_RETURN"))
#ifdef NEWT_KEY_RETURN
	    return NEWT_KEY_RETURN;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_RIGHT"))
#ifdef NEWT_KEY_RIGHT
	    return NEWT_KEY_RIGHT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_SUSPEND"))
#ifdef NEWT_KEY_SUSPEND
	    return NEWT_KEY_SUSPEND;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_TAB"))
#ifdef NEWT_KEY_TAB
	    return NEWT_KEY_TAB;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_UNTAB"))
#ifdef NEWT_KEY_UNTAB
	    return NEWT_KEY_UNTAB;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_KEY_UP"))
#ifdef NEWT_KEY_UP
	    return NEWT_KEY_UP;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_LISTBOX_RETURNEXIT"))
#ifdef NEWT_LISTBOX_RETURNEXIT
	    return NEWT_LISTBOX_RETURNEXIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_TEXTBOX_SCROLL"))
#ifdef NEWT_TEXTBOX_SCROLL
	    return NEWT_TEXTBOX_SCROLL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "NEWT_TEXTBOX_WRAP"))
#ifdef NEWT_TEXTBOX_WRAP
	    return NEWT_TEXTBOX_WRAP;
#else
	    goto not_there;
#endif
	break;
    case 'O':
	break;
    case 'P':
	break;
    case 'Q':
	break;
    case 'R':
	break;
    case 'S':
	break;
    case 'T':
	break;
    case 'U':
	break;
    case 'V':
	break;
    case 'W':
	break;
    case 'X':
	break;
    case 'Y':
	break;
    case 'Z':
	break;
    case 'a':
	break;
    case 'b':
	break;
    case 'c':
	break;
    case 'd':
	break;
    case 'e':
	break;
    case 'f':
	break;
    case 'g':
	break;
    case 'h':
	break;
    case 'i':
	break;
    case 'j':
	break;
    case 'k':
	break;
    case 'l':
	break;
    case 'm':
	break;
    case 'n':
	break;
    case 'o':
	break;
    case 'p':
	break;
    case 'q':
	break;
    case 'r':
	break;
    case 's':
	break;
    case 't':
	break;
    case 'u':
	break;
    case 'v':
	break;
    case 'w':
	break;
    case 'x':
	break;
    case 'y':
	break;
    case 'z':
	break;
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}


MODULE = Newt		PACKAGE = Newt		PREFIX = newt


double
constant(name,arg)
	char *		name
	int		arg


void
va_end(arg0)
	__gnuc_va_list	arg0

int
newtInit()

int
newtFinished()

void
newtCls()

void
newtResizeScreen(redraw)
	int	redraw

void
newtWaitForKey()

void
newtClearKeyBuffer()

void
newtDelay(usecs)
	int	usecs

int
newtOpenWindow(left, top, width, height, title)
	int	left
	int	top
	int	width
	int	height
	 char *	title

int
newtCenteredWindow(width, height, title)
	int	width
	int	height
	 char *	title

void
newtPopWindow()

void
newtRefresh()

void
newtSuspend()

void
newtSetSuspendCallback(cv)
	SV *cv;
	CODE:
		perl_suspend_cb = newSVsv(cv);
		newtSetSuspendCallback(suspend_cb);

void
newtResume()

void
newtPushHelpLine(text = NULL)
	 char *	text

void
newtRedrawHelpLine()

void
newtPopHelpLine()

void
newtDrawRootText(col, row, text)
	int	col
	int	row
	 char *	text

void
newtBell()

void
newtGetScreenSize()
	PREINIT:
		int cols;
		int rows;
	PPCODE:
		newtGetScreenSize( &cols, &rows );
		XPUSHs(sv_2mortal(newSViv(cols)));
		XPUSHs(sv_2mortal(newSViv(rows)));

void
newtReflowText(width, flexDown, flexUp, text)
	int	width
	int	flexDown
	int	flexUp
	char *	text
	PREINIT:
		char *result;
		int actualWidth;
		int actualHeight;
	PPCODE:
		result = newtReflowText(text, width, flexDown, flexUp, &actualWidth, &actualHeight);
		XPUSHs(sv_2mortal(newSVpv(result, PL_na)));
		XPUSHs(sv_2mortal(newSViv(actualWidth)));
		XPUSHs(sv_2mortal(newSViv(actualHeight)));

MODULE = Newt		PACKAGE = Newt

newtComponent
newtCompactButton(left, top, text)
	int	left
	int	top
	 char *	text

newtComponent
newtButton(left, top, text)
	int	left
	int	top
	 char *	text

newtComponent
newtCheckbox(left, top, text, defValue, seq, result = NULL)
	int	left
	int	top
	 char *	text
	char	defValue
	 char *	seq
	char *	result

char
newtCheckboxGetValue(co)
	newtComponent	co

void
newtCheckboxSetValue(co, value)
	newtComponent	co
	char	value

newtComponent
newtRadiobutton(left, top, text, isDefault, prevButton = NULL)
	int	left
	int	top
	 char *	text
	int	isDefault
	newtComponent	prevButton

newtComponent
newtRadioGetCurrent(setMember)
	newtComponent	setMember

void
newtGetScreenSize(cols, rows)
	int *	cols
	int *	rows

newtComponent
newtLabel(left, top, text)
	int	left
	int	top
	 char *	text

void
newtLabelSetText(co, text)
	newtComponent	co
	 char *	text

newtComponent
newtVerticalScrollbar(left, top, height, normalColorset, thumbColorset)
	int	left
	int	top
	int	height
	int	normalColorset
	int	thumbColorset

void
newtScrollbarSet(co, where, total)
	newtComponent	co
	int	where
	int	total

newtComponent
newtListbox(left, top, height, flags)
	int	left
	int	top
	int	height
	int	flags

long
newtListboxGetCurrent(co)
	newtComponent	co
	CODE:
		RETVAL = (long) newtListboxGetCurrent(co);
	OUTPUT:
		RETVAL

void
newtListboxSetCurrent(co, num)
	newtComponent	co
	int	num

void
newtListboxSetCurrentByKey(co, key)
	newtComponent	co
	char *	key

void
newtListboxSetEntry(co, num, text)
	newtComponent	co
	int	num
	char *	text

void
newtListboxSetWidth(co, width)
	newtComponent	co
	int	width

void
newtListboxSetData(co, num, data)
	newtComponent	co
	int	num
	void *	data

int
newtListboxAppendEntry(co, text, data)
	newtComponent	co
	char *	text
	SV *	data
	
int
newtListboxInsertEntry(co, text, data, key)
	newtComponent	co
	char *	text
	SV *	data
	SV *	key

int
newtListboxDeleteEntry(co, data)
	newtComponent	co
	SV *	data


void
newtListboxClear(co)
	newtComponent	co

void
newtListboxGetEntry(co, num, text, data)
	newtComponent	co
	int	num
	char **	text
	void **	data

void
newtListboxGetSelection(co)
	newtComponent	co
	PREINIT:
		int i;
		int numitems = 0;
		void **array;
	PPCODE:
		array = newtListboxGetSelection(co, &numitems);
		for(i = 0; i < numitems; i++) {
			XPUSHs(sv_2mortal(newSVsv((SV *)array[i])));
		}

void
newtListboxClearSelection(co)
	newtComponent	co

void
newtListboxSelectItem(co, key, sense)
	newtComponent	co
	void *	key
	int	sense

newtComponent
newtTextboxReflowed(left, top, text, width, flexDown, flexUp, flags)
	int	left
	int	top
	char *	text
	int	width
	int	flexDown
	int	flexUp
	int	flags

newtComponent
newtTextbox(left, top, width, height, flags)
	int	left
	int	top
	int	width
	int	height
	int	flags

void
newtTextboxSetText(co, text)
	newtComponent	co
	 char *	text

void
newtTextboxSetHeight(co, height)
	newtComponent	co
	int	height

int
newtTextboxGetNumLines(co)
	newtComponent	co

newtComponent
newtForm(vertBar = NULL, help = NULL, flags = 0)
	newtComponent	vertBar
	 char *	help
	int	flags

void
newtFormWatchFd(form, fd, fdFlags)
	newtComponent	form
	int	fd
	int	fdFlags

void
newtFormSetSize(co)
	newtComponent	co

newtComponent
newtFormGetCurrent(co)
	newtComponent	co

void
newtFormSetBackground(co, color)
	newtComponent	co
	int	color

void
newtFormSetCurrent(co, subco)
	newtComponent	co
	newtComponent	subco

void
newtFormAddComponent(form, co)
	newtComponent	form
	newtComponent	co

void
newtFormAddComponents(form, ...)
	newtComponent	form

void
newtFormSetHeight(co, height)
	newtComponent	co
	int	height

void
newtFormSetWidth(co, width)
	newtComponent	co
	int	width

newtComponent
newtRunForm(form)
	newtComponent	form
	CODE:
		RETVAL = newtRunForm(form);
	OUTPUT:
		RETVAL

void
newtFormRun(co)
	newtComponent	co
	PREINIT:
		struct newtExitStruct es;
		SV sv;
	PPCODE:
		newtFormRun(co, &es);
		XPUSHs(sv_2mortal(newSViv(es.reason)));
		if(es.reason == NEWT_EXIT_COMPONENT) {
			XPUSHs(sv_2mortal(sv_setref_pv(newSViv(0), 
						       "newtComponent",
						       (void*)es.u.co)));
		} else {
			XPUSHs(sv_2mortal(newSViv(es.u.key)));
		}
	
void
newtDrawForm(form)
	newtComponent	form

void
newtFormAddHotKey(co, key)
	newtComponent	co
	int	key

newtComponent
newtEntry(left, top, initialValue, width, flags)
	int	left
	int	top
	char *	initialValue
	int	width
	int	flags
	CODE:
		RETVAL = newtEntry(left, top, initialValue, width, NULL, flags);
	OUTPUT:
		RETVAL

void
newtEntrySet(co, value, cursorAtEnd)
	newtComponent	co
	char *	value
	int	cursorAtEnd

void
newtEntrySetFilter(co, cv)
	newtComponent	co
	SV *cv
	CODE:
		newtEntrySetFilter(co, entryfilter_cb, (void *)newSVsv(cv));

char *
newtEntryGetValue(co)
	newtComponent	co

newtComponent
newtScale(left, top, width, fullValue)
	int	left
	int	top
	int	width
	long	fullValue

void
newtScaleSet(co, amount)
	newtComponent	co
	long	amount

void
newtComponentTakesFocus(co, val)
	newtComponent	co
	int	val

void
newtComponentAddCallback(co, cb)
	newtComponent co
	SV *cb
	CODE:
		newtComponentAddCallback(co, component_cb, (void *)newSVsv(cb));

void
newtFormDestroy(form)
	newtComponent	form

newtGrid
newtCreateGrid(cols, rows)
	int	cols
	int	rows

newtGrid
newtGridVStacked(type, what, ...)
	enum newtGridElement	type
	void *	what

newtGrid
newtGridVCloseStacked(type, what, ...)
	enum newtGridElement	type
	void *	what

newtGrid
newtGridHStacked(type1, what1, ...)
	enum newtGridElement	type1
	void *	what1

newtGrid
newtGridHCloseStacked(type1, what1, ...)
	enum newtGridElement	type1
	void *	what1

newtGrid
newtGridBasicWindow(text, middle, buttons)
	newtComponent	text
	newtGrid	middle
	newtGrid	buttons

newtGrid
newtGridSimpleWindow(text, middle, buttons)
	newtComponent	text
	newtComponent	middle
	newtGrid	buttons

void
newtGridSetField(grid, col, row, type, val, padLeft, padTop, padRight, padBottom, anchor, flags)
	newtGrid	grid
	int		col
	int		row
	int		type
	SV		*val
	int		padLeft
	int		padTop
	int		padRight
	int		padBottom
	int		anchor
	int		flags
	CODE:
		newtGridSetField(grid, col, row, type, (void *)SvIV((SV*)SvRV(val)), padLeft, padTop, padRight, padBottom, anchor, flags);

void
newtGridPlace(grid, left, top)
	newtGrid	grid
	int	left
	int	top

void
newtGridFree(grid, recurse)
	newtGrid	grid
	int	recurse

void
newtGridGetSize(grid, width, height)
	newtGrid	grid
	int *	width
	int *	height

void
newtGridWrappedWindow(grid, title)
	newtGrid	grid
	char *	title

void
newtGridWrappedWindowAt(grid, title, left, top)
	newtGrid	grid
	char *	title
	int	left
	int	top

void
newtGridAddComponentsToForm(grid, form, recurse)
	newtGrid	grid
	newtComponent	form
	int	recurse

newtGrid
newtButtonBarv(button1, b1comp, args)
	char *	button1
	newtComponent *	b1comp
	va_list	args

newtGrid
newtButtonBar(button1, b1comp, ...)
	char *	button1
	newtComponent *	b1comp

void
newtWinMessage(title, buttonText, text, ...)
	char *	title
	char *	buttonText
	char *	text

void
newtWinMessagev(title, buttonText, text, argv)
	char *	title
	char *	buttonText
	char *	text
	va_list	argv

int
newtWinChoice(title, button1, button2, text, ...)
	char *	title
	char *	button1
	char *	button2
	char *	text

int
newtWinTernary(title, button1, button2, button3, message, ...)
	char *	title
	char *	button1
	char *	button2
	char *	button3
	char *	message

int
newtWinMenu(title, text, suggestedWidth, flexDown, flexUp, maxListHeight, items, listItem, button1, ...)
	char *	title
	char *	text
	int	suggestedWidth
	int	flexDown
	int	flexUp
	int	maxListHeight
	char **	items
	int *	listItem
	char *	button1

int
newtWinEntries(title, text, suggestedWidth, flexDown, flexUp, dataWidth, items, button1, ...)
	char *	title
	char *	text
	int	suggestedWidth
	int	flexDown
	int	flexUp
	int	dataWidth
	struct newtWinEntry *	items
	char *	button1
