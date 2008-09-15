#include <slang.h>
#include <stdlib.h>
#include <string.h>

#include "newt.h"
#include "newt_pr.h"

struct button {
    char * text;
    int compact;
};

static void buttonDrawIt(newtComponent co, int active, int pushed);
static void buttonDrawText(newtComponent co, int active, int pushed);

static void buttonDraw(newtComponent c);
static void buttonDestroy(newtComponent co);
static struct eventResult buttonEvent(newtComponent c,
				      struct event ev);
static void buttonPlace(newtComponent co, int newLeft, int newTop);

static struct componentOps buttonOps = {
    buttonDraw,
    buttonEvent,
    buttonDestroy,
    buttonPlace,
    newtDefaultMappedHandler,
} ;

static newtComponent createButton(int left, int row, const char * text, int compact) {
    newtComponent co;
    struct button * bu;

    co = malloc(sizeof(*co));
    bu = malloc(sizeof(struct button));
    co->data = bu;

    bu->text = strdup(text);
    bu->compact = compact;
    co->ops = &buttonOps;

    if (bu->compact) {
	co->height = 1;
	co->width = strlen(text) + 3;
    } else {
	co->height = 4;
	co->width = strlen(text) + 5;
    }

    co->top = row;
    co->left = left;
    co->takesFocus = 1;
    co->isMapped = 0;

    newtGotorc(co->top, co->left);

    return co;
}

newtComponent newtCompactButton(int left, int row, const char * text) {
    return createButton(left, row, text, 1);
}

newtComponent newtButton(int left, int row, const char * text) {
    return createButton(left, row, text, 0);
}

static void buttonDestroy(newtComponent co) {
    struct button * bu = co->data;

    free(bu->text);
    free(bu);
    free(co);
}

static void buttonPlace(newtComponent co, int newLeft, int newTop) {
    co->top = newTop;
    co->left = newLeft;

    newtGotorc(co->top, co->left);
}

static void buttonDraw(newtComponent co) {
    buttonDrawIt(co, 0, 0);
}

static void buttonDrawIt(newtComponent co, int active, int pushed) {
    struct button * bu = co->data;

    if (!co->isMapped) return;

    SLsmg_set_color(NEWT_COLORSET_BUTTON);

    if (bu->compact) {
	if (active) 
	    SLsmg_set_color(NEWT_COLORSET_COMPACTBUTTON);
	else
	    SLsmg_set_color(NEWT_COLORSET_BUTTON);
	newtGotorc(co->top+ pushed, co->left + 1 + pushed);
	SLsmg_write_char('<');
	SLsmg_write_string(bu->text);
	SLsmg_write_char('>');
    } else {
	if (pushed) {
	    SLsmg_set_color(NEWT_COLORSET_BUTTON);
	    newtDrawBox(co->left + 1, co->top + 1, co->width - 1, 3, 0);

	    SLsmg_set_color(NEWT_COLORSET_WINDOW);
	    newtClearBox(co->left, co->top, co->width, 1);
	    newtClearBox(co->left, co->top, 1, co->height);
	} else {
	    newtDrawBox(co->left, co->top, co->width - 1, 3, 1);
	}

	buttonDrawText(co, active, pushed);
    }
}

static void buttonDrawText(newtComponent co, int active, int pushed) {
    struct button * bu = co->data;

    if (pushed) pushed = 1;

    if (active)
	SLsmg_set_color(NEWT_COLORSET_ACTBUTTON);
    else
	SLsmg_set_color(NEWT_COLORSET_BUTTON);

    newtGotorc(co->top + 1 + pushed, co->left + 1 + pushed);
    SLsmg_write_char(' ');
    SLsmg_write_string(bu->text);
    SLsmg_write_char(' ');
}

static struct eventResult buttonEvent(newtComponent co,
				      struct event ev) {
    struct eventResult er;
    struct button * bu = co->data;

    if (ev.when == EV_NORMAL) {
	switch (ev.event) {
	  case EV_FOCUS:
	    buttonDrawIt(co, 1, 0);
	    er.result = ER_SWALLOWED;
	    break;

	  case EV_UNFOCUS:
	    buttonDrawIt(co, 0, 0);
	    er.result = ER_SWALLOWED;
	    break;

	  case EV_KEYPRESS:
	    if (ev.u.key == ' ' || ev.u.key == '\r') {
		if (!bu->compact) {
		    /* look pushed */
		    buttonDrawIt(co, 1, 1);
		    newtRefresh();
		    newtDelay(150000);
		    buttonDrawIt(co, 1, 0);
		    newtRefresh();
		    newtDelay(150000);
		}

		er.result = ER_EXITFORM;
	    } else 
		er.result = ER_IGNORED;
	    break;
	}
    } else 
	er.result = ER_IGNORED;

    return er;
}
