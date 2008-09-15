#include <slang.h>
#include <stdarg.h>
#include <stdlib.h>
#include <sys/select.h>

#include "newt.h"
#include "newt_pr.h"

/****************************************************************************
    These forms handle vertical scrolling of components with a height of 1 
   
    Horizontal scrolling won't work, and scrolling large widgets will fail
    miserably. It shouldn't be too hard to fix either of those if anyone
    cares to. I only use scrolling for listboxes and text boxes though so
    I didn't bother.
*****************************************************************************/

struct element {
    int top, left;		/* Actual, not virtual. These are translated */
    newtComponent co;		/* into actual through vertOffset */
};

struct fdInfo {
    int fd;
    int flags;
};

struct form {
    int numCompsAlloced;
    struct element * elements;
    int numComps;
    int currComp;
    int fixedHeight;
    int flags;
    int vertOffset;
    newtComponent vertBar, exitComp;
    const char * help;
    int numRows;
    int * hotKeys;
    int numHotKeys;
    int background;
    int beenSet;
    int numFds;
    struct fdInfo * fds;
    int maxFd;
};

static void gotoComponent(struct form * form, int newComp);
static struct eventResult formEvent(newtComponent co, struct event ev);
static struct eventResult sendEvent(newtComponent comp, struct event ev);
static void formPlace(newtComponent co, int left, int top);

/* this isn't static as grid.c tests against it to find forms */
struct componentOps formOps = {
    newtDrawForm,
    formEvent,
    newtFormDestroy,
    formPlace,
    newtDefaultMappedHandler,
} ;

static inline int componentFits(newtComponent co, int compNum) {
    struct form * form = co->data;
    struct element * el = form->elements + compNum;

    if ((co->top + form->vertOffset) > el->top) return 0;
    if ((co->top + form->vertOffset + co->height) <
	    (el->top + el->co->height)) return 0;

    return 1;
}

newtComponent newtForm(newtComponent vertBar, const char * help, int flags) {
    newtComponent co;
    struct form * form;

    co = malloc(sizeof(*co));
    form = malloc(sizeof(*form));
    co->data = form;
    co->width = 0;
    co->height = 0;
    co->top = -1;
    co->left = -1;
    co->isMapped = 0;

    co->takesFocus = 0;			/* we may have 0 components */
    co->ops = &formOps;

    form->help = help;
    form->flags = flags;
    form->numCompsAlloced = 5;
    form->numComps = 0;
    form->currComp = -1;
    form->vertOffset = 0;
    form->fixedHeight = 0;
    form->numRows = 0;
    form->numFds = 0;
    form->maxFd = 0;
    form->fds = NULL;
    form->beenSet = 0;
    form->elements = malloc(sizeof(*(form->elements)) * form->numCompsAlloced);

    form->background = COLORSET_WINDOW;
    form->hotKeys = malloc(sizeof(int));
    form->numHotKeys = 0;
    if (!(form->flags & NEWT_FLAG_NOF12)) {
	newtFormAddHotKey(co, NEWT_KEY_F12);
    }

    if (vertBar)
	form->vertBar = vertBar;
    else
	form->vertBar = NULL; 

    return co;
}

newtComponent newtFormGetCurrent(newtComponent co) {
    struct form * form = co->data;

    return form->elements[form->currComp].co;
}

void newtFormSetCurrent(newtComponent co, newtComponent subco) {
    struct form * form = co->data;
    int i, new;

    for (i = 0; i < form->numComps; i++) {
	 if (form->elements[i].co == subco) break;
    }

    if (form->elements[i].co != subco) return;
    new = i;

    if (co->isMapped && !componentFits(co, new)) {
	gotoComponent(form, -1);
	form->vertOffset = form->elements[new].top - co->top - 1;
	if (form->vertOffset > (form->numRows - co->height))
	    form->vertOffset = form->numRows - co->height;
    }

    gotoComponent(form, new);
}

void newtFormSetHeight(newtComponent co, int height) {
    struct form * form = co->data;

    form->fixedHeight = 1;
    co->height = height;
}

void newtFormSetWidth(newtComponent co, int width) {
    co->width = width;
}

void newtFormAddComponent(newtComponent co, newtComponent newco) {
    struct form * form = co->data;

    co->takesFocus = 1;

    if (form->numCompsAlloced == form->numComps) {
	form->numCompsAlloced += 5;
	form->elements = realloc(form->elements, 
			    sizeof(*(form->elements)) * form->numCompsAlloced);
    }

    /* we grab real values for these a bit later */
    form->elements[form->numComps].left = -2;
    form->elements[form->numComps].top = -2;
    form->elements[form->numComps].co = newco;

    if (newco->takesFocus && form->currComp == -1)
	form->currComp = form->numComps;

    form->numComps++;
}

void newtFormAddComponents(newtComponent co, ...) {
    va_list ap;
    newtComponent subco;

    va_start(ap, co);

    while ((subco = va_arg(ap, newtComponent)))
	newtFormAddComponent(co, subco);
 
    va_end(ap);
}

static void formPlace(newtComponent co, int left, int top) {
    struct form * form = co->data;
    int vertDelta, horizDelta;
    struct element * el;
    int i;

    newtFormSetSize(co);

    vertDelta = top - co->top;
    horizDelta = left - co->left;
    co->top = top;
    co->left = left;

    for (i = 0, el = form->elements; i < form->numComps; i++, el++) {
	el->co->top += vertDelta;
	el->top += vertDelta;
	el->co->left += horizDelta;
	el->left += horizDelta;
    }
}

void newtDrawForm(newtComponent co) {
    struct form * form = co->data;
    struct element * el;
    int i;

    newtFormSetSize(co);

    SLsmg_set_color(form->background);
    newtClearBox(co->left, co->top, co->width, co->height);
    for (i = 0, el = form->elements; i < form->numComps; i++, el++) {
	/* the scrollbar *always* fits somewhere */
	if (el->co == form->vertBar) {
	    el->co->ops->mapped(el->co, 1);
	    el->co->ops->draw(el->co);
	} else {
	    /* only draw it if it'll fit on the screen vertically */
	    if (componentFits(co, i)) {
		el->co->top = el->top - form->vertOffset;
		el->co->ops->mapped(el->co, 1);
		el->co->ops->draw(el->co);
	    } else {
		el->co->ops->mapped(el->co, 0);
	    }
	}
    }

    if (form->vertBar)
	newtScrollbarSet(form->vertBar, form->vertOffset, 
			 form->numRows - co->height);
}

static struct eventResult formEvent(newtComponent co, struct event ev) {
    struct form * form = co->data;
    newtComponent subco = form->elements[form->currComp].co;
    int new, wrap = 0;
    struct eventResult er;
    int dir = 0, page = 0;
    int i, num;

    er.result = ER_IGNORED;
    if (!form->numComps) return er;

    subco = form->elements[form->currComp].co;

    switch (ev.when) {
      case EV_EARLY:
	if (ev.event == EV_KEYPRESS) {
	    if (ev.u.key == NEWT_KEY_TAB) {
		er.result = ER_SWALLOWED;
		dir = 1;
		wrap = 1;
	    } else if (ev.u.key == NEWT_KEY_UNTAB) {
		er.result = ER_SWALLOWED;
		dir = -1;
		wrap = 1;
	    }
	}

	if (form->numComps) {
	    i = form->currComp;
	    num = 0;
	    while (er.result == ER_IGNORED && num != form->numComps ) {
		er = form->elements[i].co->ops->event(form->elements[i].co, ev);

		num++;
		i++;
		if (i == form->numComps) i = 0;
	    }
	}

	break;
	
      case EV_NORMAL:
	er = subco->ops->event(subco, ev);
	switch (er.result) {
	  case ER_NEXTCOMP:
	    er.result = ER_SWALLOWED;
	    dir = 1;
	    break;

	  case ER_EXITFORM:
	    form->exitComp = subco;
	    break;

	  default:
	    break;
	}
	break;

      case EV_LATE:
	er = subco->ops->event(subco, ev);
	
	if (er.result == ER_IGNORED) {
	    switch (ev.u.key) {
	      case NEWT_KEY_UP:
	      case NEWT_KEY_LEFT:
	      case NEWT_KEY_BKSPC:
		er.result = ER_SWALLOWED;
		dir = -1;
		break;

	      case NEWT_KEY_DOWN:
	      case NEWT_KEY_RIGHT:
		er.result = ER_SWALLOWED;
		dir = 1;
		break;

	     case NEWT_KEY_PGUP:
		er.result = ER_SWALLOWED;
		dir = -1;
		page = 1;
		break;
		
	     case NEWT_KEY_PGDN:
		er.result = ER_SWALLOWED;
		dir = 1;
		page = 1;
		break;
	    }
	}
    }

    if (dir) {
	new = form->currComp;

	if (page) {
	    new += dir * co->height;
	    if (new < 0)
		new = 0;
	    else if (new >= form->numComps)
		new = (form->numComps - 1);

	    while (!form->elements[new].co->takesFocus)
		new = new - dir;
	} else {
	    do {
		new += dir;

		if (wrap) {
		    if (new < 0)
			new = form->numComps - 1;
		    else if (new >= form->numComps)
			new = 0;
		} else if (new < 0 || new >= form->numComps) 
		    return er;
	    } while (!form->elements[new].co->takesFocus);
	}

	/* make sure this component is visible */
	if (!componentFits(co, new)) {
	    gotoComponent(form, -1);

	    if (dir < 0) {
		/* make the new component the first one */
		form->vertOffset = form->elements[new].top - co->top;
	    } else {
		/* make the new component the last one */
		form->vertOffset = (form->elements[new].top + 
					form->elements[new].co->height) -
				    (co->top + co->height);
	    }

	    if (form->vertOffset < 0) form->vertOffset = 0;
	    if (form->vertOffset > (form->numRows - co->height))
		form->vertOffset = form->numRows - co->height;

	    newtDrawForm(co);
	}

	gotoComponent(form, new);
	er.result = ER_SWALLOWED;
    }

    return er;
}

/* this also destroys all of the components on the form */
void newtFormDestroy(newtComponent co) {
    newtComponent subco;
    struct form * form = co->data;
    int i;

    /* first, destroy all of the components */
    for (i = 0; i < form->numComps; i++) {
	subco = form->elements[i].co;
	if (subco->ops->destroy) {
	    subco->ops->destroy(subco);
	} else {
	    if (subco->data) free(subco->data);
	    free(subco);
	}	
    }

    free(form->elements);
    free(form);
    free(co);
}

newtComponent newtRunForm(newtComponent co) {
    struct newtExitStruct es;

    newtFormRun(co, &es);
    if (es.reason == NEWT_EXIT_HOTKEY) {
	if (es.u.key == NEWT_KEY_F12) {
	    es.reason = NEWT_EXIT_COMPONENT;
	    es.u.co = co;
	} else {
	    return NULL;
	}
    }

    return es.u.co;
}

void newtFormAddHotKey(newtComponent co, int key) {
    struct form * form = co->data;

    form->numHotKeys++;
    form->hotKeys = realloc(form->hotKeys, sizeof(int) * form->numHotKeys);
    form->hotKeys[form->numHotKeys - 1] = key;
}

void newtFormSetSize(newtComponent co) {
    struct form * form = co->data;
    int delta, i;
    struct element * el;

    if (form->beenSet) return;

    form->beenSet = 1;

    if (!form->numComps) return;

    co->width = 0;
    if (!form->fixedHeight) co->height = 0;

    co->top = form->elements[0].co->top;
    co->left = form->elements[0].co->left;
    for (i = 0, el = form->elements; i < form->numComps; i++, el++) {
	if (el->co->ops == &formOps)
	    newtFormSetSize(el->co);

 	el->left = el->co->left;
 	el->top = el->co->top;

	if (co->left > el->co->left) {
	    delta = co->left - el->co->left;
	    co->left -= delta;
	    co->width += delta;
	}

	if (co->top > el->co->top) {
	    delta = co->top - el->co->top;
	    co->top -= delta;
	    if (!form->fixedHeight)
		co->height += delta;
	}

	if ((co->left + co->width) < (el->co->left + el->co->width)) 
	    co->width = (el->co->left + el->co->width) - co->left;

	if (!form->fixedHeight) {
	    if ((co->top + co->height) < (el->co->top + el->co->height)) 
		co->height = (el->co->top + el->co->height) - co->top;
	}

	if ((el->co->top + el->co->height - co->top) > form->numRows) {
	    form->numRows = el->co->top + el->co->height - co->top;
	}
    }
}

void newtFormRun(newtComponent co, struct newtExitStruct * es) {
    struct form * form = co->data;
    struct event ev;
    struct eventResult er;
    int key, i;
    int done = 0;
    fd_set readSet, writeSet;

    newtFormSetSize(co);
    /* draw all of the components */
    newtDrawForm(co);

    if (form->currComp == -1) {
	gotoComponent(form, 0);
    } else
	gotoComponent(form, form->currComp);
  
    while (!done) {
	newtRefresh();

	FD_ZERO(&readSet);
	FD_ZERO(&writeSet);
	FD_SET(0, &readSet);
	for (i = 0; i < form->numFds; i++) {
	    if (form->fds[i].flags & NEWT_FD_READ)
		FD_SET(form->fds[i].fd, &readSet);
	    if (form->fds[i].flags & NEWT_FD_WRITE)
		FD_SET(form->fds[i].fd, &writeSet);
	}

	i = select(form->maxFd + 1, &readSet, &writeSet, NULL, NULL);
	if (i < 0) continue;	/* ?? What should we do here? */

	if (FD_ISSET(0, &readSet)) {
	    key = newtGetKey(); 

	    if (key == NEWT_KEY_RESIZE) {
		/* newtResizeScreen(1); */
		continue;
	    }

	    for (i = 0; i < form->numHotKeys; i++) {
		if (form->hotKeys[i] == key) {
		    es->reason = NEWT_EXIT_HOTKEY;
		    es->u.key = key;
		    done = 1;
		    break;
		}
	    }

	    if (!done) {
		ev.event = EV_KEYPRESS;
		ev.u.key = key;

		er = sendEvent(co, ev);
	 
		if (er.result == ER_EXITFORM) {
		    done = 1;
		    es->reason = NEWT_EXIT_COMPONENT;
		    es->u.co = form->exitComp;
		} 
	    }
	} else {
	    es->reason = NEWT_EXIT_FDREADY;
	    done = 1;
	}
    } 

    newtRefresh();
}

static struct eventResult sendEvent(newtComponent co, struct event ev) {
    struct eventResult er;

    ev.when = EV_EARLY;
    er = co->ops->event(co, ev);

    if (er.result == ER_IGNORED) {
	ev.when = EV_NORMAL;
	er = co->ops->event(co, ev);
    }

    if (er.result == ER_IGNORED) {
	ev.when = EV_LATE;
	er = co->ops->event(co, ev);
    }

    return er;
}

static void gotoComponent(struct form * form, int newComp) {
    struct event ev;

    if (form->currComp != -1) {
	ev.event = EV_UNFOCUS;
	sendEvent(form->elements[form->currComp].co, ev);
    }

    form->currComp = newComp;
    
    if (form->currComp != -1) {
	ev.event = EV_FOCUS;
	ev.when = EV_NORMAL;
	sendEvent(form->elements[form->currComp].co, ev);
    }
}

void newtComponentAddCallback(newtComponent co, newtCallback f, void * data) {
    co->callback = f;
    co->callbackData = data;
}

void newtComponentTakesFocus(newtComponent co, int val) {
    co->takesFocus = val;
}

void newtFormSetBackground(newtComponent co, int color) {
    struct form * form = co->data;

    form->background = color;
}

void newtFormWatchFd(newtComponent co, int fd, int fdFlags) {
    struct form * form = co->data;

    form->fds = realloc(form->fds, (form->numFds + 1) * sizeof(*form->fds));
    form->fds[form->numFds].fd = fd;
    form->fds[form->numFds++].flags = fdFlags;
    if (form->maxFd < fd) form->maxFd = fd;
}
