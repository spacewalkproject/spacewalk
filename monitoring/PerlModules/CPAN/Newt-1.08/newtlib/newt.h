#ifndef H_NEWT
#define H_NEWT

#ifdef __cplusplus
extern "C" {
#endif

#include <stdarg.h>

#define NEWT_COLORSET_ROOT 		2
#define NEWT_COLORSET_BORDER 		3
#define NEWT_COLORSET_WINDOW		4
#define NEWT_COLORSET_SHADOW		5
#define NEWT_COLORSET_TITLE		6
#define NEWT_COLORSET_BUTTON		7
#define NEWT_COLORSET_ACTBUTTON		8
#define NEWT_COLORSET_CHECKBOX		9
#define NEWT_COLORSET_ACTCHECKBOX	10
#define NEWT_COLORSET_ENTRY		11
#define NEWT_COLORSET_LABEL		12
#define NEWT_COLORSET_LISTBOX		13
#define NEWT_COLORSET_ACTLISTBOX	14
#define NEWT_COLORSET_TEXTBOX		15
#define NEWT_COLORSET_ACTTEXTBOX	16
#define NEWT_COLORSET_HELPLINE		17
#define NEWT_COLORSET_ROOTTEXT		18
#define NEWT_COLORSET_EMPTYSCALE	19
#define NEWT_COLORSET_FULLSCALE		20
#define NEWT_COLORSET_DISENTRY		21
#define NEWT_COLORSET_COMPACTBUTTON	22
#define NEWT_COLORSET_ACTSELLISTBOX	23
#define NEWT_COLORSET_SELLISTBOX	24

struct newtColors {
    char * rootFg, * rootBg;
    char * borderFg, * borderBg;
    char * windowFg, * windowBg;
    char * shadowFg, * shadowBg;
    char * titleFg, * titleBg;
    char * buttonFg, * buttonBg;
    char * actButtonFg, * actButtonBg;
    char * checkboxFg, * checkboxBg;
    char * actCheckboxFg, * actCheckboxBg;
    char * entryFg, * entryBg;
    char * labelFg, * labelBg;
    char * listboxFg, * listboxBg;
    char * actListboxFg, * actListboxBg;
    char * textboxFg, * textboxBg;
    char * actTextboxFg, * actTextboxBg;
    char * helpLineFg, * helpLineBg;
    char * rootTextFg, * rootTextBg;
    char * emptyScale, * fullScale;
    char * disabledEntryFg, * disabledEntryBg;
    char * compactButtonFg, * compactButtonBg;
    char * actSelListboxFg, * actSelListboxBg;
    char * selListboxFg, * selListboxBg;
};

enum newtFlagsSense { NEWT_FLAGS_SET, NEWT_FLAGS_RESET, NEWT_FLAGS_TOGGLE };

#define NEWT_FLAG_RETURNEXIT 	(1 << 0)
#define NEWT_FLAG_HIDDEN 	(1 << 1)
#define NEWT_FLAG_SCROLL 	(1 << 2)
#define NEWT_FLAG_DISABLED 	(1 << 3)
/* OBSOLETE #define NEWT_FLAG_NOSCROLL 	(1 << 4)	for listboxes */
#define NEWT_FLAG_BORDER	(1 << 5)
#define NEWT_FLAG_WRAP		(1 << 6)
#define NEWT_FLAG_NOF12		(1 << 7)
#define NEWT_FLAG_MULTIPLE      (1 << 8)
#define NEWT_FLAG_SELECTED	(1 << 9)

#define NEWT_FD_READ		(1 << 0)
#define NEWT_FD_WRITE		(1 << 1)

/* Backwards compatibility */
#define NEWT_LISTBOX_RETURNEXIT NEWT_FLAG_RETURNEXIT
#define NEWT_ENTRY_SCROLL	NEWT_FLAG_SCROLL
#define NEWT_ENTRY_HIDDEN	NEWT_FLAG_HIDDEN
#define NEWT_ENTRY_RETURNEXIT	NEWT_FLAG_RETURNEXIT
#define NEWT_ENTRY_DISABLED	NEWT_FLAG_DISABLED

#define NEWT_TEXTBOX_WRAP	NEWT_FLAG_WRAP
#define NEWT_TEXTBOX_SCROLL	NEWT_FLAG_SCROLL
#define NEWT_FORM_NOF12		NEWT_FLAG_NOF12

#define newtListboxAddEntry	newtListboxAppendEntry


typedef struct newtComponent_struct * newtComponent;

extern const struct newtColors newtDefaultColorPalette;

typedef void (*newtCallback)(newtComponent, void *);
typedef void (*newtSuspendCallback)(void);

int newtInit(void);
int newtFinished(void);
void newtCls(void);
void newtResizeScreen(int redraw);
void newtWaitForKey(void);
void newtClearKeyBuffer(void);
void newtDelay(int usecs);
/* top, left are *not* counting the border */
int newtOpenWindow(int left, int top, int width, int height, 
			  const char * title);
int newtCenteredWindow(int width, int height, const char * title);
void newtPopWindow(void);
void newtSetColors(struct newtColors colors);
void newtRefresh(void);
void newtSuspend(void);
void newtSetSuspendCallback(newtSuspendCallback cb);
void newtResume(void);
void newtPushHelpLine(const char * text);
void newtRedrawHelpLine(void);
void newtPopHelpLine(void);
void newtDrawRootText(int col, int row, const char * text);
void newtBell(void);

/* Components */

newtComponent newtCompactButton(int left, int top, const char * text);
newtComponent newtButton(int left, int top, const char * text);
newtComponent newtCheckbox(int left, int top, const char * text, char defValue,
			   const char * seq, char * result);
char newtCheckboxGetValue(newtComponent co);
void newtCheckboxSetValue(newtComponent co, char value);
newtComponent newtRadiobutton(int left, int top, const char * text, int isDefault,
			      newtComponent prevButton);
newtComponent newtRadioGetCurrent(newtComponent setMember);
newtComponent newtListitem(int left, int top, const char * text, int isDefault,
			      newtComponent prevItem, const void * data, int flags);
void newtListitemSet(newtComponent co, const char * text);
void * newtListitemGetData(newtComponent co);
void newtGetScreenSize(int * cols, int * rows);

newtComponent newtLabel(int left, int top, const char * text);
void newtLabelSetText(newtComponent co, const char * text);
newtComponent newtVerticalScrollbar(int left, int top, int height,
				    int normalColorset, int thumbColorset);
void newtScrollbarSet(newtComponent co, int where, int total);

newtComponent newtListbox(int left, int top, int height, int flags);
void * newtListboxGetCurrent(newtComponent co);
void newtListboxSetCurrent(newtComponent co, int num);
void newtListboxSetCurrentByKey(newtComponent co, void * key);
void newtListboxSetEntry(newtComponent co, int num, const char * text);
void newtListboxSetWidth(newtComponent co, int width);
void newtListboxSetData(newtComponent co, int num, void * data);
int newtListboxAppendEntry(newtComponent co, const char * text, 
			   const void * data);
/* Send the key to insert after, or NULL to insert at the top */
int newtListboxInsertEntry(newtComponent co, const char * text, const void * data, void * key);
int newtListboxDeleteEntry(newtComponent co, void * data);
void newtListboxClear(newtComponent co); /* removes all entries from listbox */
void newtListboxGetEntry(newtComponent co, int num, char **text, void **data);
/* Returns an array of data pointers from items, last element is NULL */
void **newtListboxGetSelection(newtComponent co, int *numitems);
void newtListboxClearSelection(newtComponent co);
void newtListboxSelectItem(newtComponent co, const void * key,
	enum newtFlagsSense sense);

    
newtComponent newtTextboxReflowed(int left, int top, char * text, int width,
				  int flexDown, int flexUp, int flags);
newtComponent newtTextbox(int left, int top, int width, int height, int flags);
void newtTextboxSetText(newtComponent co, const char * text);
void newtTextboxSetHeight(newtComponent co, int height);
int newtTextboxGetNumLines(newtComponent co);
char * newtReflowText(char * text, int width, int flexDown, int flexUp,
		      int * actualWidth, int * actualHeight);

struct newtExitStruct {
    enum { NEWT_EXIT_HOTKEY, NEWT_EXIT_COMPONENT, NEWT_EXIT_FDREADY } reason;
    union {
	int key;
	newtComponent co;
    } u;
} ;

newtComponent newtForm(newtComponent vertBar, const char * help, int flags);
void newtFormWatchFd(newtComponent form, int fd, int fdFlags);
void newtFormSetSize(newtComponent co);
newtComponent newtFormGetCurrent(newtComponent co);
void newtFormSetBackground(newtComponent co, int color);
void newtFormSetCurrent(newtComponent co, newtComponent subco);
void newtFormAddComponent(newtComponent form, newtComponent co);
void newtFormAddComponents(newtComponent form, ...);
void newtFormSetHeight(newtComponent co, int height);
void newtFormSetWidth(newtComponent co, int width);
newtComponent newtRunForm(newtComponent form);		/* obsolete */
void newtFormRun(newtComponent co, struct newtExitStruct * es);
void newtDrawForm(newtComponent form);
void newtFormAddHotKey(newtComponent co, int key);

typedef int (*newtEntryFilter)(newtComponent entry, void * data, int ch,
			       int cursor);
newtComponent newtEntry(int left, int top, const char * initialValue, int width,
			char ** resultPtr, int flags);
void newtEntrySet(newtComponent co, const char * value, int cursorAtEnd);
void newtEntrySetFilter(newtComponent co, newtEntryFilter filter, void * data);
char * newtEntryGetValue(newtComponent co);

newtComponent newtScale(int left, int top, int width, long long fullValue);
void newtScaleSet(newtComponent co, unsigned long long amount);

void newtComponentAddCallback(newtComponent co, newtCallback f, void * data);
void newtComponentTakesFocus(newtComponent co, int val);

/* this also destroys all of the components (including other forms) on the 
   form */
void newtFormDestroy(newtComponent form);	

/* Key codes */

#define NEWT_KEY_TAB			'\t'
#define NEWT_KEY_ENTER			'\r'
#define NEWT_KEY_SUSPEND		'\032'			/* ctrl - z*/
#define NEWT_KEY_RETURN			NEWT_KEY_ENTER

#define NEWT_KEY_EXTRA_BASE		0x8000
#define NEWT_KEY_UP			NEWT_KEY_EXTRA_BASE + 1
#define NEWT_KEY_DOWN			NEWT_KEY_EXTRA_BASE + 2
#define NEWT_KEY_LEFT			NEWT_KEY_EXTRA_BASE + 4
#define NEWT_KEY_RIGHT			NEWT_KEY_EXTRA_BASE + 5
#define NEWT_KEY_BKSPC			NEWT_KEY_EXTRA_BASE + 6
#define NEWT_KEY_DELETE			NEWT_KEY_EXTRA_BASE + 7
#define NEWT_KEY_HOME			NEWT_KEY_EXTRA_BASE + 8
#define NEWT_KEY_END			NEWT_KEY_EXTRA_BASE + 9
#define NEWT_KEY_UNTAB			NEWT_KEY_EXTRA_BASE + 10
#define NEWT_KEY_PGUP			NEWT_KEY_EXTRA_BASE + 11
#define NEWT_KEY_PGDN			NEWT_KEY_EXTRA_BASE + 12

#define NEWT_KEY_F1			NEWT_KEY_EXTRA_BASE + 101
#define NEWT_KEY_F2			NEWT_KEY_EXTRA_BASE + 102
#define NEWT_KEY_F3			NEWT_KEY_EXTRA_BASE + 103
#define NEWT_KEY_F4			NEWT_KEY_EXTRA_BASE + 104
#define NEWT_KEY_F5			NEWT_KEY_EXTRA_BASE + 105
#define NEWT_KEY_F6			NEWT_KEY_EXTRA_BASE + 106
#define NEWT_KEY_F7			NEWT_KEY_EXTRA_BASE + 107
#define NEWT_KEY_F8			NEWT_KEY_EXTRA_BASE + 108
#define NEWT_KEY_F9			NEWT_KEY_EXTRA_BASE + 109
#define NEWT_KEY_F10			NEWT_KEY_EXTRA_BASE + 110
#define NEWT_KEY_F11			NEWT_KEY_EXTRA_BASE + 111
#define NEWT_KEY_F12			NEWT_KEY_EXTRA_BASE + 112

/* not really a key, but newtGetKey returns it */
#define NEWT_KEY_RESIZE			NEWT_KEY_EXTRA_BASE + 113

#define NEWT_ANCHOR_LEFT		(1 << 0)
#define NEWT_ANCHOR_RIGHT		(1 << 1)
#define NEWT_ANCHOR_TOP			(1 << 2)
#define NEWT_ANCHOR_BOTTOM		(1 << 3)

#define NEWT_GRID_FLAG_GROWX		(1 << 0)
#define NEWT_GRID_FLAG_GROWY		(1 << 1)

typedef struct grid_s * newtGrid;
enum newtGridElement { NEWT_GRID_EMPTY = 0,
		       NEWT_GRID_COMPONENT, NEWT_GRID_SUBGRID };

newtGrid newtCreateGrid(int cols, int rows);
/* TYPE, what, TYPE, what, ..., NULL */
newtGrid newtGridVStacked(enum newtGridElement type, void * what, ...);
newtGrid newtGridVCloseStacked(enum newtGridElement type, void * what, ...);
newtGrid newtGridHStacked(enum newtGridElement type1, void * what1, ...);
newtGrid newtGridHCloseStacked(enum newtGridElement type1, void * what1, ...);
newtGrid newtGridBasicWindow(newtComponent text, newtGrid middle,
			     newtGrid buttons);
newtGrid newtGridSimpleWindow(newtComponent text, newtComponent middle,
			     newtGrid buttons);
void newtGridSetField(newtGrid grid, int col, int row, 
		      enum newtGridElement type, void * val, int padLeft,
		      int padTop, int padRight, int padBottom, int anchor,
		      int flags);
void newtGridPlace(newtGrid grid, int left, int top);
void newtGridFree(newtGrid grid, int recurse);
void newtGridGetSize(newtGrid grid, int * width, int * height);
void newtGridWrappedWindow(newtGrid grid, char * title);
void newtGridWrappedWindowAt(newtGrid grid, char * title, int left, int top);
void newtGridAddComponentsToForm(newtGrid grid, newtComponent form, 
				 int recurse);

/* convienve */
newtGrid newtButtonBarv(char * button1, newtComponent * b1comp, va_list args);
newtGrid newtButtonBar(char * button1, newtComponent * b1comp, ...);

/* automatically centered and shrink wrapped */
void newtWinMessage(char * title, char * buttonText, char * text, ...);
void newtWinMessagev(char * title, char * buttonText, char * text, 
		     va_list argv);

/* having separate calls for these two seems silly, but having two separate
   variable length-arg lists seems like a bad idea as well */

/* Returns 0 if F12 was pressed, 1 for button1, 2 for button2 */
int newtWinChoice(char * title, char * button1, char * button2, 
		   char * text, ...);
/* Returns 0 if F12 was pressed, 1 for button1, 2 for button2, 
   3 for button3 */
int newtWinTernary(char * title, char * button1, char * button2, 
		   char * button3, char * message, ...);

/* Returns the button number pressed, 0 on F12 */
int newtWinMenu(char * title, char * text, int suggestedWidth, int flexDown, 
		int flexUp, int maxListHeight, char ** items, int * listItem,
		char * button1, ...);

struct newtWinEntry {
    char * text;
    char ** value;		/* may be initialized to set default */
    int flags;
};

/* Returns the button number pressed, 0 on F12. The final values are
   dynamically allocated, and need to be freed. */
int newtWinEntries(char * title, char * text, int suggestedWidth, int flexDown, 
		   int flexUp, int dataWidth, 
		   struct newtWinEntry * items, char * button1, ...);

#ifdef __cplusplus
} /* End of extern "C" { */
#endif

#endif /* H_NEWT */
