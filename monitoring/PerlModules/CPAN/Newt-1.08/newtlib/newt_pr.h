#ifndef H_NEWT_PR
#define H_NEWT_PR

#define COLORSET_ROOT 		NEWT_COLORSET_ROOT 
#define COLORSET_BORDER 	NEWT_COLORSET_BORDER 
#define COLORSET_WINDOW		NEWT_COLORSET_WINDOW
#define COLORSET_SHADOW		NEWT_COLORSET_SHADOW
#define COLORSET_TITLE		NEWT_COLORSET_TITLE
#define COLORSET_BUTTON		NEWT_COLORSET_BUTTON
#define COLORSET_ACTBUTTON	NEWT_COLORSET_ACTBUTTON
#define COLORSET_CHECKBOX	NEWT_COLORSET_CHECKBOX
#define COLORSET_ACTCHECKBOX	NEWT_COLORSET_ACTCHECKBOX
#define COLORSET_ENTRY		NEWT_COLORSET_ENTRY
#define COLORSET_LABEL		NEWT_COLORSET_LABEL
#define COLORSET_LISTBOX	NEWT_COLORSET_LISTBOX
#define COLORSET_ACTLISTBOX	NEWT_COLORSET_ACTLISTBOX
#define COLORSET_TEXTBOX	NEWT_COLORSET_TEXTBOX
#define COLORSET_ACTTEXTBOX	NEWT_COLORSET_ACTTEXTBOX

int newtSetFlags(int oldFlags, int newFlags, enum newtFlagsSense sense);

void newtGotorc(int row, int col);
void newtGetrc(int * row, int * col);
void newtDrawBox(int left, int top, int width, int height, int shadow);
void newtClearBox(int left, int top, int width, int height);

int newtGetKey(void);

struct newtComponent_struct {
    /* common data */
    int height, width; 
    int top, left;
    int takesFocus;
    int isMapped;

    struct componentOps * ops;

    newtCallback callback;
    void * callbackData;

    void * data;
} ;

enum eventResultTypes { ER_IGNORED, ER_SWALLOWED, ER_EXITFORM, ER_SETFOCUS,
			ER_NEXTCOMP };
struct eventResult {
    enum eventResultTypes result;
    union {
	newtComponent focus;
    } u;
}; 

enum eventTypes { EV_FOCUS, EV_UNFOCUS, EV_KEYPRESS };
enum eventSequence { EV_EARLY, EV_NORMAL, EV_LATE };

struct event {
    enum eventTypes event;
    enum eventSequence when;
    union {
	int key;
    } u;
} ;

struct componentOps {
    void (* draw)(newtComponent c);
    struct eventResult (* event)(newtComponent c, struct event ev);
    void (* destroy)(newtComponent c);
    void (* place)(newtComponent c, int newLeft, int newTop);
    void (* mapped)(newtComponent c, int isMapped);
} ;

void newtDefaultPlaceHandler(newtComponent c, int newLeft, int newTop);
void newtDefaultMappedHandler(newtComponent c, int isMapped);
struct eventResult newtDefaultEventHandler(newtComponent c,
					   struct event ev);

#endif /* H_NEWT_PR */
