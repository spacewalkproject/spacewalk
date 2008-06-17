#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "errno.h"
#include "newt.h"

static void * newtvwindow(char * title, char * button1, char * button2, 
		       char * button3, char * message, va_list args) {
    newtComponent b1, b2 = NULL, b3 = NULL, t, f, answer;
    char * buf = NULL;
    int size = 0;
    int i = 0;
    int scroll = 0;
    int width, height;
    char * flowedText;
    newtGrid grid, buttonGrid;

    do {
	size += 1000;
	if (buf) free(buf);
	buf = malloc(size);
	i = vsnprintf(buf, size, message, args);
    } while (i == size || i == -1);

    flowedText = newtReflowText(buf, 35, 5, 5, &width, &height);
    if (height > 6) {
	free(flowedText);
	flowedText = newtReflowText(buf, 60, 5, 5, &width, &height);
    }
    free(buf);

    if (height > 12) {
	height = 12;
	scroll = NEWT_FLAG_SCROLL;
    }
    t = newtTextbox(-1, -1, width, height, NEWT_TEXTBOX_WRAP | scroll);
    newtTextboxSetText(t, flowedText);
    free(flowedText);

    if (button3) {
	buttonGrid = newtButtonBar(button1, &b1, button2, &b2, 
				   button3, &b3, NULL);
    } else if (button2) {
	buttonGrid = newtButtonBar(button1, &b1, button2, &b2, NULL);
    } else {
	buttonGrid = newtButtonBar(button1, &b1, NULL);
    }

    newtGridSetField(buttonGrid, 0, 0, NEWT_GRID_COMPONENT, b1, 
		     0, 0, button2 ? 1 : 0, 0, 0, 0);

    grid = newtCreateGrid(1, 2);
    newtGridSetField(grid, 0, 0, NEWT_GRID_COMPONENT, t, 0, 0, 0, 0, 0, 0);
    newtGridSetField(grid, 0, 1, NEWT_GRID_SUBGRID, buttonGrid, 
		     0, 1, 0, 0, 0, NEWT_GRID_FLAG_GROWX);
    newtGridWrappedWindow(grid, title);

    f = newtForm(NULL, NULL, 0);
    newtFormAddComponents(f, t, b1, NULL);

    if (button2)
	newtFormAddComponent(f, b2);
    if (button3)
	newtFormAddComponent(f, b3);

    answer = newtRunForm(f);
    newtGridFree(grid, 1);
 
    newtFormDestroy(f);
    newtPopWindow();

    if (answer == f)
	return NULL;
    else if (answer == b1)
	return button1;
    else if (answer == b2)
	return button2;

    return button3;
}

int newtWinChoice(char * title, char * button1, char * button2, 
		   char * message, ...) {
    va_list args;
    void * rc;

    va_start(args, message);
    rc = newtvwindow(title, button1, button2, NULL, message, args);
    va_end(args);

    if (rc == button1)
	return 1;
    else if (rc == button2)
	return 2;

    return 0;
}

void newtWinMessage(char * title, char * buttonText, char * text, ...) {
    va_list args;

    va_start(args, text);
    newtvwindow(title, buttonText, NULL, NULL, text, args);
    va_end(args);
}

void newtWinMessagev(char * title, char * buttonText, char * text, 
		     va_list argv) {
    newtvwindow(title, buttonText, NULL, NULL, text, argv);
}

int newtWinTernary(char * title, char * button1, char * button2, 
		   char * button3, char * message, ...) {
    va_list args;
    void * rc;

    va_start(args, message);
    rc = newtvwindow(title, button1, button2, button3, message, args);
    va_end(args);

    if (rc == button1)
	return 1;
    else if (rc == button2)
	return 2;
    else if (rc == button3)
	return 3;

    return 0;
}

/* only supports up to 50 buttons -- shucks! */
int newtWinMenu(char * title, char * text, int suggestedWidth, int flexDown, 
		int flexUp, int maxListHeight, char ** items, int * listItem,
		char * button1, ...) {
    newtComponent textbox, listbox, result, form;
    va_list args;
    newtComponent buttons[50];
    newtGrid grid, buttonBar;
    int numButtons;
    int i, rc;
    int needScroll;
    char * buttonName;

    textbox = newtTextboxReflowed(-1, -1, text, suggestedWidth, flexDown,
			          flexUp, 0);

    for (i = 0; items[i]; i++) ;
    if (i < maxListHeight) maxListHeight = i;
    needScroll = i > maxListHeight;

    listbox = newtListbox(-1, -1, maxListHeight, 
		  (needScroll ? NEWT_FLAG_SCROLL : 0) | NEWT_FLAG_RETURNEXIT);
    for (i = 0; items[i]; i++) {
	newtListboxAddEntry(listbox, items[i], (void *) i);
    }

    newtListboxSetCurrent(listbox, *listItem);

    buttonName = button1, numButtons = 0;
    va_start(args, button1);
    while (buttonName) {
	buttons[numButtons] = newtButton(-1, -1, buttonName);
	numButtons++;
	buttonName = va_arg(args, char *);
    }

    va_end(button1);

    buttonBar = newtCreateGrid(numButtons, 1);
    for (i = 0; i < numButtons; i++) {
	newtGridSetField(buttonBar, i, 0, NEWT_GRID_COMPONENT, 
			 buttons[i],
			 i ? 1 : 0, 0, 0, 0, 0, 0);
    }

    grid = newtGridSimpleWindow(textbox, listbox, buttonBar);
    newtGridWrappedWindow(grid, title);

    form = newtForm(NULL, 0, 0);
    newtGridAddComponentsToForm(grid, form, 1);
    newtGridFree(grid, 1);

    result = newtRunForm(form);

    *listItem = ((long) newtListboxGetCurrent(listbox));

    for (rc = 0; result != buttons[rc] && rc < numButtons; rc++);
    if (rc == numButtons) 
	rc = 0; /* F12 or return-on-exit (which are the same for us) */
    else 
	rc++;

    newtFormDestroy(form);
    newtPopWindow();

    return rc;
}

/* only supports up to 50 buttons and entries -- shucks! */
int newtWinEntries(char * title, char * text, int suggestedWidth, int flexDown, 
		   int flexUp, int dataWidth, 
		   struct newtWinEntry * items, char * button1, ...) {
    newtComponent buttons[50], result, form, textw;
    newtGrid grid, buttonBar, subgrid;
    int numItems;
    int rc, i;
    int numButtons;
    char * buttonName;
    va_list args;

    textw = newtTextboxReflowed(-1, -1, text, suggestedWidth, flexDown,
			        flexUp, 0);

    for (numItems = 0; items[numItems].text; numItems++); 

    buttonName = button1, numButtons = 0;
    va_start(args, button1);
    while (buttonName) {
	buttons[numButtons] = newtButton(-1, -1, buttonName);
	numButtons++;
	buttonName = va_arg(args, char *);
    }

    va_end(button1);

    buttonBar = newtCreateGrid(numButtons, 1);
    for (i = 0; i < numButtons; i++) {
	newtGridSetField(buttonBar, i, 0, NEWT_GRID_COMPONENT, 
			 buttons[i],
			 i ? 1 : 0, 0, 0, 0, 0, 0);
    }

    subgrid = newtCreateGrid(2, numItems);
    for (i = 0; i < numItems; i++) {
	newtGridSetField(subgrid, 0, i, NEWT_GRID_COMPONENT,
		         newtLabel(-1, -1, items[i].text),
		         0, 0, 0, 0, NEWT_ANCHOR_LEFT, 0);
	newtGridSetField(subgrid, 1, i, NEWT_GRID_COMPONENT,
		         newtEntry(-1, -1, items[i].value ? 
				    *items[i].value : NULL, dataWidth,
				    items[i].value, items[i].flags),
		         1, 0, 0, 0, 0, 0);
    }

    grid = newtCreateGrid(1, 3);
    form = newtForm(NULL, 0, 0);
    newtGridSetField(grid, 0, 0, NEWT_GRID_COMPONENT, textw, 
		     0, 0, 0, 0, NEWT_ANCHOR_LEFT, 0);
    newtGridSetField(grid, 0, 1, NEWT_GRID_SUBGRID, subgrid, 
		     0, 1, 0, 0, 0, 0);
    newtGridSetField(grid, 0, 2, NEWT_GRID_SUBGRID, buttonBar, 
		     0, 1, 0, 0, 0, NEWT_GRID_FLAG_GROWX);
    newtGridAddComponentsToForm(grid, form, 1);
    newtGridWrappedWindow(grid, title);
    newtGridFree(grid, 1);

    result = newtRunForm(form);

    for (rc = 0; rc < numItems; rc++)
	*items[rc].value = strdup(*items[rc].value);

    for (rc = 0; result != buttons[rc] && rc < numButtons; rc++);
    if (rc == numButtons) 
	rc = 0; /* F12 */
    else 
	rc++;

    newtFormDestroy(form);
    newtPopWindow();

    return rc;
}
