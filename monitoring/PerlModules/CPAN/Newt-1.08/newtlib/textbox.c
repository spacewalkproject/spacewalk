#include <ctype.h>
#include <slang.h>
#include <stdlib.h>
#include <string.h>

#include "newt.h"
#include "newt_pr.h"

struct textbox {
    char ** lines;
    int numLines;
    int linesAlloced;
    int doWrap;
    newtComponent sb;
    int topLine;
    int textWidth;
};

static char * expandTabs(const char * text);
static void textboxDraw(newtComponent co);
static void addLine(newtComponent co, const char * s, int len);
static void doReflow(const char * text, char ** resultPtr, int width, 
		     int * badness, int * heightPtr);
static struct eventResult textboxEvent(newtComponent c,
				      struct event ev);
static void textboxDestroy(newtComponent co);
static void textboxPlace(newtComponent co, int newLeft, int newTop);
static void textboxMapped(newtComponent co, int isMapped);

static struct componentOps textboxOps = {
    textboxDraw,
    textboxEvent,
    textboxDestroy,
    textboxPlace,
    textboxMapped,
} ;

static void textboxMapped(newtComponent co, int isMapped) {
    struct textbox * tb = co->data;

    co->isMapped = isMapped;
    if (tb->sb)
	tb->sb->ops->mapped(tb->sb, isMapped);
}

static void textboxPlace(newtComponent co, int newLeft, int newTop) {
    struct textbox * tb = co->data;

    co->top = newTop;
    co->left = newLeft;

    if (tb->sb)
	tb->sb->ops->place(tb->sb, co->left + co->width - 1, co->top);
}

void newtTextboxSetHeight(newtComponent co, int height) {
    co->height = height;
}

int newtTextboxGetNumLines(newtComponent co) {
    struct textbox * tb = co->data;

    return (tb->numLines);
}

newtComponent newtTextboxReflowed(int left, int top, char * text, int width,
				  int flexDown, int flexUp, int flags) {
    newtComponent co;
    char * reflowedText;
    int actWidth, actHeight;

    reflowedText = newtReflowText(text, width, flexDown, flexUp,
				  &actWidth, &actHeight);
    
    co = newtTextbox(left, top, actWidth, actHeight, NEWT_FLAG_WRAP);
    newtTextboxSetText(co, reflowedText);
    free(reflowedText);

    return co;
}

newtComponent newtTextbox(int left, int top, int width, int height, int flags) {
    newtComponent co;
    struct textbox * tb;

    co = malloc(sizeof(*co));
    tb = malloc(sizeof(*tb));
    co->data = tb;

    co->ops = &textboxOps;

    co->height = height;
    co->top = top;
    co->left = left;
    co->takesFocus = 0;
    co->width = width;

    tb->doWrap = flags & NEWT_FLAG_WRAP;
    tb->numLines = 0;
    tb->linesAlloced = 0;
    tb->lines = NULL;
    tb->topLine = 0;
    tb->textWidth = width;

    if (flags & NEWT_FLAG_SCROLL) {
	co->width += 2;
	tb->sb = newtVerticalScrollbar(co->left + co->width - 1, co->top, 
			   co->height, COLORSET_TEXTBOX, COLORSET_TEXTBOX);
    } else {
	tb->sb = NULL;
    }

    return co;
}

static char * expandTabs(const char * text) {
    int bufAlloced = strlen(text) + 40;
    char * buf, * dest;
    const char * src;
    int bufUsed = 0;
    int i;

    buf = malloc(bufAlloced + 1);
    for (src = text, dest = buf; *src; src++) {
	if ((bufUsed + 10) > bufAlloced) {
	    bufAlloced += strlen(text) / 2;
	    buf = realloc(buf, bufAlloced + 1);
	    dest = buf + bufUsed;
	}
	if (*src == '\t') {
	    i = 8 - (bufUsed & 8);
	    memset(dest, ' ', i);
	    dest += i, bufUsed += i;
	} else {
	    *dest++ = *src;
	    bufUsed++;
	}
    }

    *dest = '\0';
    return buf;
}

static void doReflow(const char * text, char ** resultPtr, int width, 
		     int * badness, int * heightPtr) {
    char * result = NULL;
    const char * chptr, * end;
    int howbad = 0;
    int height = 0;

    if (resultPtr) {
	/* XXX I think this will work */
	result = malloc(strlen(text) + (strlen(text) / width) + 2);
	*result = '\0';
    }
    
    while (*text) {
	end = strchr(text, '\n');
	if (!end)
	    end = text + strlen(text);

	while (*text && text <= end) {
	    if (end - text < width) {
		if (result) {
		    strncat(result, text, end - text);
		    strcat(result, "\n");
		    height++;
		}

		if (end - text < (width / 2))
		    howbad += ((width / 2) - (end - text)) / 2;
		text = end;
		if (*text) text++;
	    } else {
		chptr = text + width - 1;
		while (chptr > text && !isspace(*chptr)) chptr--;
		while (chptr > text && isspace(*chptr)) chptr--;
		chptr++;
		
		if (chptr-text == 1 && !isspace(*chptr))
		  chptr = text + width - 1;

		if (chptr > text)
		    howbad += width - (chptr - text) + 1;
		if (result) {
		    strncat(result, text, chptr - text);
		    strcat(result, "\n");
		    height++;
		}

		if (isspace(*chptr))
		    text = chptr + 1;
		else
		  text = chptr;
		while (isspace(*text)) text++;
	    }
	}
    }

    if (badness) *badness = howbad;
    if (resultPtr) *resultPtr = result;
    if (heightPtr) *heightPtr = height;
}

char * newtReflowText(char * text, int width, int flexDown, int flexUp,
		      int * actualWidth, int * actualHeight) {
    int min, max;
    int i;
    char * result;
    int minbad, minbadwidth, howbad;
    char * expandedText;

    expandedText = expandTabs(text);

    if (flexDown || flexUp) {
	min = width - flexDown;
	max = width + flexUp;

	minbad = -1;
	minbadwidth = width;

	for (i = min; i <= max; i++) {
	    doReflow(expandedText, NULL, i, &howbad, NULL);

	    if (minbad == -1 || howbad < minbad) {
		minbad = howbad;
		minbadwidth = i;
	    }
 	}

	width = minbadwidth;
    }

    doReflow(expandedText, &result, width, NULL, actualHeight);
    free(expandedText);
    if (actualWidth) *actualWidth = width;
    return result;
}

void newtTextboxSetText(newtComponent co, const char * text) {
    const char * start, * end;
    struct textbox * tb = co->data;
    char * reflowed, * expanded;
    int badness, height;

    if (tb->lines) {
	free(tb->lines);
	tb->linesAlloced = tb->numLines = 0;
    }

    expanded = expandTabs(text);

    if (tb->doWrap) {
	doReflow(expanded, &reflowed, tb->textWidth, &badness, &height);
	free(expanded);
	expanded = reflowed;
    }

    for (start = expanded; *start; start++)
	if (*start == '\n') tb->linesAlloced++;

    /* This ++ leaves room for an ending line w/o a \n */
    tb->linesAlloced++;
    tb->lines = malloc(sizeof(char *) * tb->linesAlloced);

    start = expanded;
    while ((end = strchr(start, '\n'))) {
	addLine(co, start, end - start);
	start = end + 1;
    }

    if (*start)
	addLine(co, start, strlen(start));

    free(expanded);
}

/* This assumes the buffer is allocated properly! */
static void addLine(newtComponent co, const char * s, int len) {
    struct textbox * tb = co->data;

    if (len > tb->textWidth) len = tb->textWidth;

    tb->lines[tb->numLines] = malloc(tb->textWidth + 1);
    memset(tb->lines[tb->numLines], ' ', tb->textWidth); 
    memcpy(tb->lines[tb->numLines], s, len);
    tb->lines[tb->numLines++][tb->textWidth] = '\0';
}

static void textboxDraw(newtComponent c) {
    int i;
    struct textbox * tb = c->data;
    int size;

    if (tb->sb) {
	size = tb->numLines - c->height;
	newtScrollbarSet(tb->sb, tb->topLine, size ? size : 0);
	tb->sb->ops->draw(tb->sb);
    }

    SLsmg_set_color(NEWT_COLORSET_TEXTBOX);
   
    for (i = 0; (i + tb->topLine) < tb->numLines && i < c->height; i++) {
	newtGotorc(c->top + i, c->left);
	SLsmg_write_string(tb->lines[i + tb->topLine]);
    }
}

static struct eventResult textboxEvent(newtComponent co, 
				      struct event ev) {
    struct textbox * tb = co->data;
    struct eventResult er;

    er.result = ER_IGNORED;

    if (ev.when == EV_EARLY && ev.event == EV_KEYPRESS && tb->sb) {
	switch (ev.u.key) {
	  case NEWT_KEY_UP:
	    if (tb->topLine) tb->topLine--;
	    textboxDraw(co);
	    er.result = ER_SWALLOWED;
	    break;

	  case NEWT_KEY_DOWN:
	    if (tb->topLine < (tb->numLines - co->height)) tb->topLine++;
	    textboxDraw(co);
	    er.result = ER_SWALLOWED;
	    break;

	  case NEWT_KEY_PGDN:
	    tb->topLine += co->height;
	    if (tb->topLine > (tb->numLines - co->height)) {
		tb->topLine = tb->numLines - co->height;
		if (tb->topLine < 0) tb->topLine = 0;
	    }
	    textboxDraw(co);
	    er.result = ER_SWALLOWED;
	    break;

	  case NEWT_KEY_PGUP:
	    tb->topLine -= co->height;
	    if (tb->topLine < 0) tb->topLine = 0;
	    textboxDraw(co);
	    er.result = ER_SWALLOWED;
	    break;
	}
    }

    return er;
}

static void textboxDestroy(newtComponent co) {
    int i;
    struct textbox * tb = co->data;

    for (i = 0; i < tb->numLines; i++) 
	free(tb->lines[i]);
    free(tb->lines);
    free(tb);
    free(co);
}
