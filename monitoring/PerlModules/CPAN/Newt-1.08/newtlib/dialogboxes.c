/* simple dialog boxes, used by both whiptail and tcl dialog bindings */

#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#include "dialogboxes.h"
#include "newt.h"
#include "popt.h"

/* globals -- ick */
int buttonHeight = 1;
newtComponent (*makeButton)(int left, int right, const char * text) = 
		newtCompactButton;

static void addButtons(int height, int width, newtComponent form, 
		       newtComponent * okay, newtComponent * cancel, 
		       int flags) {
    if (flags & FLAG_NOCANCEL) {
	*okay = makeButton((width - 8) / 2, height - buttonHeight - 1, "Ok");
	*cancel = NULL;
	newtFormAddComponent(form, *okay);
    } else {
	*okay = makeButton((width - 18) / 3, height - buttonHeight - 1, "Ok");
	*cancel = makeButton(((width - 18) / 3) * 2 + 9, 
				height - buttonHeight - 1, "Cancel");
	newtFormAddComponents(form, *okay, *cancel, NULL);
    }
}

static newtComponent textbox(int maxHeight, int width, char * text, int flags, 
			     int * height) {
    newtComponent tb;
    int sFlag = (flags & FLAG_SCROLL_TEXT) ? NEWT_FLAG_SCROLL : 0;
    int i;
    char * buf, * src, * dst;

    dst = buf = alloca(strlen(text) + 1);
    src = text; 
    while (*src) {
	if (*src == '\\' && *(src + 1) == 'n') {
	    src += 2;
	    *dst++ = '\n';
	} else
	    *dst++ = *src++;
    }
    *dst++ = '\0';

    tb = newtTextbox(1, 0, width, maxHeight, NEWT_FLAG_WRAP | sFlag);
    newtTextboxSetText(tb, buf);

    i = newtTextboxGetNumLines(tb);
    if (i < maxHeight) {
	newtTextboxSetHeight(tb, i);
	maxHeight = i;
    }

    *height = maxHeight;

    return tb;
}

int gauge(char * text, int height, int width, poptContext optCon, int fd, 
		int flags) {
    newtComponent form, scale, tb;
    int top;
    char * arg, * end;
    int val;
    FILE * f = fdopen(fd, "r");
    char buf[3000];
    char buf3[50];
    int i;

    setlinebuf(f);

    if (!(arg = poptGetArg(optCon))) return DLG_ERROR;
    val = strtoul(arg, &end, 10);
    if (*end) return DLG_ERROR;

    tb = textbox(height - 3, width - 2, text, flags, &top);

    form = newtForm(NULL, NULL, 0);

    scale = newtScale(2, height - 2, width - 4, 100);
    newtScaleSet(scale, val);

    newtFormAddComponents(form, tb, scale, NULL);

    newtDrawForm(form);
    newtRefresh();

    while (fgets(buf, sizeof(buf) - 1, f)) {
	buf[strlen(buf) - 1] = '\0';

	if (!strcmp(buf, "XXX")) {
	    fgets(buf3, sizeof(buf3) - 1, f);
	    buf3[strlen(buf3) - 1] = '\0';
	    arg = buf3;

	    i = 0;
	    while (fgets(buf + i, sizeof(buf) - 1 - i, f)) {
		buf[strlen(buf) - 1] = '\0';
		if (!strcmp(buf + i, "XXX")) {
		    *(buf + i) = '\0';
		    break;
		}
		i = strlen(buf);
	    }

	    newtTextboxSetText(tb, buf);
 	} else {
	    arg = buf;
	}

	val = strtoul(buf, &end, 10);
	if (!*end) {
	    newtScaleSet(scale, val);
	    newtDrawForm(form);
	    newtRefresh();
	}
    }

    return DLG_OKAY;
}

int inputBox(char * text, int height, int width, poptContext optCon, 
		int flags, char ** result) {
    newtComponent form, entry, okay, cancel, answer, tb;
    char * val;
    int rc = DLG_OKAY;
    int top;

    val = poptGetArg(optCon);
    tb = textbox(height - 3 - buttonHeight, width - 2,
			text, flags, &top);

    form = newtForm(NULL, NULL, 0);
    entry = newtEntry(1, top + 1, val, width - 2, &val, 
			NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);

    newtFormAddComponents(form, tb, entry, NULL);

    addButtons(height, width, form, &okay, &cancel, flags);

    answer = newtRunForm(form);
    if (answer == cancel)
	rc = DLG_CANCEL;

    *result = val;

    return rc;
}

int listBox(char * text, int height, int width, poptContext optCon,
		int flags, char ** result) {
    newtComponent form, okay, tb, answer, listBox;
    newtComponent cancel = NULL;
    char * arg, * end;
    int listHeight;
    int numItems = 0;
    int allocedItems = 5;
    int i, top;
    int rc = DLG_OKAY;
    char buf[80], format[20];
    int maxTagWidth = 0;
    int maxTextWidth = 0;
    int scrollFlag;
    struct {
	char * text;
	char * tag;
    } * itemInfo = malloc(allocedItems * sizeof(*itemInfo));

    if (!(arg = poptGetArg(optCon))) return DLG_ERROR;
    listHeight = strtoul(arg, &end, 10);
    if (*end) return DLG_ERROR;

    while ((arg = poptGetArg(optCon))) {
	if (allocedItems == numItems) {
	    allocedItems += 5;
	    itemInfo = realloc(itemInfo, sizeof(*itemInfo) * allocedItems);
	}

	itemInfo[numItems].tag = arg;
	if (!(arg = poptGetArg(optCon))) return DLG_ERROR;

	if (!(flags & FLAG_NOITEM)) {
	    itemInfo[numItems].text = arg;
	} else
	    itemInfo[numItems].text = "";

	if (strlen(itemInfo[numItems].text) > (unsigned int)maxTextWidth)
	    maxTextWidth = strlen(itemInfo[numItems].text);
	if (strlen(itemInfo[numItems].tag) > (unsigned int)maxTagWidth)
	    maxTagWidth = strlen(itemInfo[numItems].tag);

	numItems++;
    }

    form = newtForm(NULL, NULL, 0);

    tb = textbox(height - 4 - buttonHeight - listHeight, width - 2,
			text, flags, &top);

    if (listHeight >= numItems) {
	scrollFlag = 0;
	i = 0;
    } else {
	scrollFlag = NEWT_FLAG_SCROLL;
	i = 2;
    }

    listBox = newtListbox(3 + ((width - 10 - maxTagWidth - maxTextWidth - i) 
					/ 2),
			  top + 1, listHeight, 
			    NEWT_FLAG_RETURNEXIT | scrollFlag);

    sprintf(format, "%%-%ds  %%s", maxTagWidth);
    for (i = 0; i < numItems; i++) {
	sprintf(buf, format, itemInfo[i].tag, itemInfo[i].text);
	newtListboxAddEntry(listBox, buf, (void *) i);
    }

    newtFormAddComponents(form, tb, listBox, NULL);

    addButtons(height, width, form, &okay, &cancel, flags);

    answer = newtRunForm(form);
    if (answer == cancel)
	rc = DLG_CANCEL;

    i = (int) newtListboxGetCurrent(listBox);
    *result = itemInfo[i].tag;

    return rc;
}

int checkList(char * text, int height, int width, poptContext optCon,
		int useRadio, int flags, char *** selections) {
    newtComponent form, okay, tb, subform, answer;
    newtComponent sb = NULL, cancel = NULL;
    char * arg, * end;
    int listHeight;
    int numBoxes = 0;
    int allocedBoxes = 5;
    int i;
    int numSelected;
    int rc = DLG_OKAY;
    char buf[80], format[20];
    int maxWidth = 0;
    int top;
    struct {
	char * text;
	char * tag;
	newtComponent comp;
    } * cbInfo = malloc(allocedBoxes * sizeof(*cbInfo));
    char * cbStates = malloc(allocedBoxes * sizeof(cbStates));

    if (!(arg = poptGetArg(optCon))) return DLG_ERROR;
    listHeight = strtoul(arg, &end, 10);
    if (*end) return DLG_ERROR;

    while ((arg = poptGetArg(optCon))) {
	if (allocedBoxes == numBoxes) {
	    allocedBoxes += 5;
	    cbInfo = realloc(cbInfo, sizeof(*cbInfo) * allocedBoxes);
	    cbStates = realloc(cbStates, sizeof(*cbStates) * allocedBoxes);
	}

	cbInfo[numBoxes].tag = arg;
	if (!(arg = poptGetArg(optCon))) return DLG_ERROR;

	if (!(flags & FLAG_NOITEM)) {
	    cbInfo[numBoxes].text = arg;
	    if (!(arg = poptGetArg(optCon))) return DLG_ERROR;
	} else
	    cbInfo[numBoxes].text = "";

	if (!strcmp(arg, "1") || !strcasecmp(arg, "on") || 
		!strcasecmp(arg, "yes"))
	    cbStates[numBoxes] = '*';
	else
	    cbStates[numBoxes] = ' ';

	if (strlen(cbInfo[numBoxes].tag) > (unsigned int)maxWidth)
	    maxWidth = strlen(cbInfo[numBoxes].tag);

	numBoxes++;
    }

    form = newtForm(NULL, NULL, 0);

    tb = textbox(height - 3 - buttonHeight - listHeight, width - 2,
			text, flags, &top);

    if (listHeight < numBoxes) { 
	sb = newtVerticalScrollbar(width - 4, 
				   top + 1,
				   listHeight, NEWT_COLORSET_CHECKBOX,
				   NEWT_COLORSET_ACTCHECKBOX);
	newtFormAddComponent(form, sb);
    }
    subform = newtForm(sb, NULL, 0);
    newtFormSetBackground(subform, NEWT_COLORSET_CHECKBOX);

    sprintf(format, "%%-%ds  %%s", maxWidth);
    for (i = 0; i < numBoxes; i++) {
	sprintf(buf, format, cbInfo[i].tag, cbInfo[i].text);

	if (useRadio)
	    cbInfo[i].comp = newtRadiobutton(4, top + 1 + i, buf,
					cbStates[i] != ' ', 
					i ? cbInfo[i - 1].comp : NULL);
	else
	    cbInfo[i].comp = newtCheckbox(4, top + 1 + i, buf,
			      cbStates[i], NULL, cbStates + i);

	newtFormAddComponent(subform, cbInfo[i].comp);
    }

    newtFormSetHeight(subform, listHeight);
    newtFormSetWidth(subform, width - 10);

    newtFormAddComponents(form, tb, subform, NULL);

    addButtons(height, width, form, &okay, &cancel, flags);

    answer = newtRunForm(form);
    if (answer == cancel)
	rc = DLG_CANCEL;

    if (useRadio) {
	answer = newtRadioGetCurrent(cbInfo[0].comp);
	for (i = 0; i < numBoxes; i++) 
	    if (cbInfo[i].comp == answer) {
		*selections = malloc(sizeof(char *) * 2);
		(*selections)[0] = cbInfo[i].tag;
		(*selections)[1] = NULL;
		break;
	    }
    } else {
	numSelected = 0;
	for (i = 0; i < numBoxes; i++) {
	    if (cbStates[i] != ' ') numSelected++;
	}

	*selections = malloc(sizeof(char *) * (numSelected + 1));

	numSelected = 0;
	for (i = 0; i < numBoxes; i++) {
	    if (cbStates[i] != ' ') 
		(*selections)[numSelected++] = cbInfo[i].tag;
	}

	(*selections)[numSelected] = NULL;
    }

    return rc;
}

int messageBox(char * text, int height, int width, int type, int flags) {
    newtComponent form, yes, tb, answer;
    newtComponent no = NULL;
    int tFlag = (flags & FLAG_SCROLL_TEXT) ? NEWT_FLAG_SCROLL : 0;

    form = newtForm(NULL, NULL, 0);

    tb = newtTextbox(1, 1, width - 2, height - 3 - buttonHeight, 
			NEWT_FLAG_WRAP | tFlag);
    newtTextboxSetText(tb, text);

    newtFormAddComponent(form, tb);

    switch ( type ) {
    case MSGBOX_INFO:
	break;
    case MSGBOX_MSG:
	yes = makeButton((width - 8) / 2, height - 1 - buttonHeight, "Ok");
	newtFormAddComponent(form, yes);
	break;
    default:
	yes = makeButton((width - 16) / 3, height - 1 - buttonHeight, "Yes");
	no = makeButton(((width - 16) / 3) * 2 + 9, height - 1 - buttonHeight, 
			"No");
	newtFormAddComponents(form, yes, no, NULL);

	if (flags & FLAG_DEFAULT_NO)
	    newtFormSetCurrent(form, no);
    }

    if ( type != MSGBOX_INFO ) {
	newtRunForm(form);

	answer = newtFormGetCurrent(form);

	if (answer == no)
	    return DLG_CANCEL;
    }
    else {
	newtDrawForm(form);
	newtRefresh();
    }
	


    return DLG_OKAY;
}

void useFullButtons(int state) {
    if (state) {
	buttonHeight = 3;
	makeButton = newtButton;
   } else {
	buttonHeight = 1;
	makeButton = newtCompactButton;
   }
}
