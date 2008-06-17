#include <ctype.h>
#include <slang.h>
#include <stdlib.h>
#include <string.h>

#include "newt.h"
#include "newt_pr.h"

struct entry {
    int flags;
    char * buf;
    char ** resultPtr;
    int bufAlloced;
    int bufUsed;		/* amount of the buffer that's been used */
    int cursorPosition; 	/* cursor *in the string* on on screen */
    int firstChar;		/* first character position being shown */
    newtEntryFilter filter;
    void * filterData;
};

static void entryDraw(newtComponent co);
static void entryDestroy(newtComponent co);
static struct eventResult entryEvent(newtComponent co, 
			             struct event ev);

static struct eventResult entryHandleKey(newtComponent co, int key);

static struct componentOps entryOps = {
    entryDraw,
    entryEvent,
    entryDestroy,
    newtDefaultPlaceHandler,
    newtDefaultMappedHandler,
} ;

void newtEntrySet(newtComponent co, const char * value, int cursorAtEnd) {
    struct entry * en = co->data;

    if ((strlen(value) + 1) > (unsigned int)en->bufAlloced) {
	free(en->buf);
	en->bufAlloced = strlen(value) + 1;
	en->buf = malloc(en->bufAlloced);
	if (en->resultPtr) *en->resultPtr = en->buf;
    }
    memset(en->buf, 0, en->bufAlloced);		/* clear the buffer */
    strcpy(en->buf, value);
    en->bufUsed = strlen(value);
    en->firstChar = 0;
    if (cursorAtEnd)
	en->cursorPosition = en->bufUsed;
    else
	en->cursorPosition = 0;

    entryDraw(co);
} ;

newtComponent newtEntry(int left, int top, const char * initialValue, int width,
			char ** resultPtr, int flags) {
    newtComponent co;
    struct entry * en;

    co = malloc(sizeof(*co));
    en = malloc(sizeof(struct entry));
    co->data = en;

    co->top = top;
    co->left = left;
    co->height = 1;
    co->width = width;
    co->isMapped = 0;
    co->callback = NULL;

    co->ops = &entryOps;

    en->flags = flags;
    en->cursorPosition = 0;
    en->firstChar = 0;
    en->bufUsed = 0;
    en->bufAlloced = width + 1;
    en->filter = NULL;

    if (!(en->flags & NEWT_FLAG_DISABLED))
	co->takesFocus = 1;
    else
	co->takesFocus = 0;

    if (initialValue && strlen(initialValue) > (unsigned int)width) {
	en->bufAlloced = strlen(initialValue) + 1;
    }
    en->buf = malloc(en->bufAlloced);
    en->resultPtr = resultPtr;
    if (en->resultPtr) *en->resultPtr = en->buf;
  
    memset(en->buf, 0, en->bufAlloced);
    if (initialValue) {
	strcpy(en->buf, initialValue);
	en->bufUsed = strlen(initialValue);
	en->cursorPosition = en->bufUsed;
    } else {
	*en->buf = '\0';
	en->bufUsed = 0;
	en->cursorPosition = 0;
    }

    return co;
}

static void entryDraw(newtComponent co) {
    struct entry * en = co->data;
    int i;
    char * chptr;
    int len;

    if (!co->isMapped) return;

    if (en->flags & NEWT_FLAG_DISABLED) 
	SLsmg_set_color(NEWT_COLORSET_DISENTRY);
    else
	SLsmg_set_color(NEWT_COLORSET_ENTRY);
 
    if (en->flags & NEWT_FLAG_HIDDEN) {
	newtGotorc(co->top, co->left);
	for (i = 0; i < co->width; i++)
	    SLsmg_write_char('_');
	newtGotorc(co->top, co->left);

	return;
    }

    newtGotorc(co->top, co->left);

    if (en->cursorPosition < en->firstChar) {
	/* scroll to the left */
	en->firstChar = en->cursorPosition;
    } else if ((en->firstChar + co->width) <= en->cursorPosition) {
	/* scroll to the right */
	en->firstChar = en->cursorPosition - co->width + 1;
    }

    chptr = en->buf + en->firstChar;
    len = strlen(chptr);
 
    if (len <= co->width) {
	i = len;
	SLsmg_write_string(chptr);
	while (i < co->width) {
	    SLsmg_write_char('_');
	    i++;
	}
    } else {
	SLsmg_write_nstring(chptr, co->width);
    }

    if (en->flags & NEWT_FLAG_HIDDEN)
	newtGotorc(co->top, co->left);
    else
	newtGotorc(co->top, co->left + (en->cursorPosition - en->firstChar));
}

void newtEntrySetFlags(newtComponent co, int flags, enum newtFlagsSense sense) {
    struct entry * en = co->data;
    int row, col;

    en->flags = newtSetFlags(en->flags, flags, sense);

    if (!(en->flags & NEWT_FLAG_DISABLED))
	co->takesFocus = 1;
    else
	co->takesFocus = 0;

    newtGetrc(&row, &col);
    entryDraw(co);
    newtGotorc(row, col);
}

static void entryDestroy(newtComponent co) {
    struct entry * en = co->data;

    free(en->buf);
    free(en);
    free(co);
}

static struct eventResult entryEvent(newtComponent co, 
				     struct event ev) {
    struct entry * en = co->data;
    struct eventResult er;
    int ch;

    if (ev.when == EV_NORMAL) {
	switch (ev.event) {
	  case EV_FOCUS:
	    /*SLtt_set_cursor_visibility(0);*/
	    if (en->flags & NEWT_FLAG_HIDDEN)
		newtGotorc(co->top, co->left);
	    else
		newtGotorc(co->top, co->left + 
				(en->cursorPosition - en->firstChar));
	    er.result = ER_SWALLOWED;
	    break;

	  case EV_UNFOCUS:
	    /*SLtt_set_cursor_visibility(1);*/
	    newtGotorc(0, 0);
	    er.result = ER_SWALLOWED;
	    if (co->callback) co->callback(co, co->callbackData);
	    break;

	  case EV_KEYPRESS:
	    ch = ev.u.key;
	    if (en->filter)
		ch = en->filter(co, en->filterData, ch, en->cursorPosition);
	    if (ch) er = entryHandleKey(co, ch);
	    break;
	}
    } else
	er.result = ER_IGNORED;

    return er;
}

static struct eventResult entryHandleKey(newtComponent co, int key) {
    struct entry * en = co->data;
    struct eventResult er;
    char * chptr, * insPoint;

    er.result = ER_SWALLOWED;
    switch (key) {
      case '\r':				/* Return */
	if (en->flags & NEWT_FLAG_RETURNEXIT) {
	    er.result = ER_EXITFORM;
	} else {
	    er.result = ER_NEXTCOMP;
	}
	break;

      case '\001':				/* ^A */
      case NEWT_KEY_HOME:
	en->cursorPosition = 0;
	break;

      case '\005':				/* ^E */
      case NEWT_KEY_END:
	en->cursorPosition = en->bufUsed;
	break;

      case '\013':				/* ^K */
	en->bufUsed = en->cursorPosition;
	memset(en->buf + en->bufUsed, 0, en->bufAlloced - en->bufUsed);
	break;

      case '\002':				/* ^B */
      case NEWT_KEY_LEFT:
	if (en->cursorPosition)
	    en->cursorPosition--;
	break;

      case '\004':
      case NEWT_KEY_DELETE:
	chptr = en->buf + en->cursorPosition;
	if (*chptr) {
	    chptr++;
	    while (*chptr) {
		*(chptr - 1) = *chptr;
		chptr++;
	    }
	    *(chptr - 1) = '\0';
	    en->bufUsed--;
	}
	break;

      case NEWT_KEY_BKSPC:
	if (en->cursorPosition) {
	    /* if this isn't true, there's nothing to erase */
	    chptr = en->buf + en->cursorPosition;
	    en->bufUsed--;
	    en->cursorPosition--;
	    while (*chptr) {
		*(chptr - 1) = *chptr;
		chptr++;
	    }
	    *(chptr - 1) = '\0';
	}
	break;

      case '\006':				/* ^B */
      case NEWT_KEY_RIGHT:
	if (en->cursorPosition < en->bufUsed)
	    en->cursorPosition++;
	break;

      default:
	if ((key >= 0x20 && key <= 0x7e) || (key >= 0xa0 && key <= 0xff)) {
	    if (!(en->flags & NEWT_FLAG_SCROLL) && en->bufUsed == co->width) {
		SLtt_beep();
		break;
	    } 
	
	    if ((en->bufUsed + 1) == en->bufAlloced) {
		en->bufAlloced += 20;
		en->buf = realloc(en->buf, en->bufAlloced);
		if (en->resultPtr) *en->resultPtr = en->buf;
		memset(en->buf + en->bufUsed + 1, 0, 20);
	    }

	    if (en->cursorPosition == en->bufUsed) {
		en->bufUsed++;
	    } else {
		/* insert the new character */

		/* chptr is the last character in the string */
		chptr = (en->buf + en->bufUsed) - 1;
		if ((en->bufUsed + 1) == en->bufAlloced) {
		    /* this string fills the buffer, so clip it */
		    chptr--;
		} else 
		    en->bufUsed++;

		insPoint = en->buf + en->cursorPosition;

		while (chptr >= insPoint) {
		    *(chptr + 1) = *chptr;
		    chptr--;
		}

	    }
		
	    en->buf[en->cursorPosition++] = key;
	} else {
	    er.result = ER_IGNORED;
	}
    } 

    entryDraw(co);

    return er;
}

char * newtEntryGetValue(newtComponent co) {
    struct entry * en = co->data;

    return en->buf;
}

void newtEntrySetFilter(newtComponent co, newtEntryFilter filter, void * data) {
    struct entry * en = co->data;
    en->filter = filter;
    en->filterData = data;
}
