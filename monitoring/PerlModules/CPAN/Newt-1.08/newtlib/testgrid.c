#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>

#include "newt.h"

int main(void) {
    newtComponent b1, b2, b3, b4;
    newtComponent answer, f, t;
    newtGrid grid, subgrid;
    char * flowedText;
    int textWidth, textHeight, rc;
    char * menuContents[] = { "One", "Two", "Three", "Four", "Five", NULL };
    char * entries[10];
    struct newtWinEntry autoEntries[] = {
	{ "An entry", entries + 0, 0 },
	{ "Another entry", entries + 1, 0 },
	{ "Third entry", entries + 2, 0 },
	{ "Fourth entry", entries + 3, 0 },
	{ NULL, NULL, 0 } };

    memset(entries, 0, sizeof(entries));

    newtInit();
    newtCls();

    b1 = newtCheckbox(-1, -1, "An pretty long checkbox for testing", ' ', NULL, NULL);
    b2 = newtButton(-1, -1, "Another Button");
    b3 = newtButton(-1, -1, "But, but");
    b4 = newtButton(-1, -1, "But what?");

    f = newtForm(NULL, NULL, 0);

    grid = newtCreateGrid(2, 2);
    newtGridSetField(grid, 0, 0, NEWT_GRID_COMPONENT, b1, 0, 0, 0, 0, 
			NEWT_ANCHOR_RIGHT, 0);
    newtGridSetField(grid, 0, 1, NEWT_GRID_COMPONENT, b2, 0, 0, 0, 0, 0, 0);
    newtGridSetField(grid, 1, 0, NEWT_GRID_COMPONENT, b3, 0, 0, 0, 0, 0, 0);
    newtGridSetField(grid, 1, 1, NEWT_GRID_COMPONENT, b4, 0, 0, 0, 0, 0, 0);


    newtFormAddComponents(f, b1, b2, b3, b4, NULL);

    newtGridWrappedWindow(grid, "first window");

    answer = newtRunForm(f);
	
    newtFormDestroy(f);

    newtPopWindow();

    flowedText = newtReflowText("This is a quite a bit of text. It is 40 "
			  	"columns long, so some wrapping should be "
			  	"done. Did you know that the quick, brown "
			  	"fox jumped over the lazy dog?\n\n"
				"In other news, it's pretty important that we "
				"can properly force a line break.",
				40, 5, 5, &textWidth, &textHeight);
    t = newtTextbox(-1, -1, textWidth, textHeight, NEWT_FLAG_WRAP);
    newtTextboxSetText(t, flowedText);
    free(flowedText);

    
    b1 = newtButton(-1, -1, "Okay");
    b2 = newtButton(-1, -1, "Cancel");

    grid = newtCreateGrid(1, 2);
    subgrid = newtCreateGrid(2, 1);

    newtGridSetField(subgrid, 0, 0, NEWT_GRID_COMPONENT, b1, 0, 0, 0, 0, 0, 0);
    newtGridSetField(subgrid, 1, 0, NEWT_GRID_COMPONENT, b2, 0, 0, 0, 0, 0, 0);

    newtGridSetField(grid, 0, 0, NEWT_GRID_COMPONENT, t, 0, 0, 0, 1, 0, 0);
    newtGridSetField(grid, 0, 1, NEWT_GRID_SUBGRID, subgrid, 0, 0, 0, 0, 0,
			NEWT_GRID_FLAG_GROWX);
    newtGridWrappedWindow(grid, "another example");

    f = newtForm(NULL, NULL, 0);
    newtFormAddComponents(f, b1, t, b2, NULL);
    answer = newtRunForm(f);

    newtPopWindow();

    newtWinMessage("Simple", "Ok", "This is a simple message window");
    newtWinChoice("Simple", "Ok", "Cancel", "This is a simple choice window");

    textWidth = 0;
    rc = newtWinMenu("Test Menu", "This is a sample invovation of the "
		     "newtWinMenu() call. It may or may not have a scrollbar, "
		     "depending on the need for one.", 50, 5, 5, 3, 
		     menuContents, &textWidth, "Ok", "Cancel", NULL);

    rc = newtWinEntries("Text newtWinEntries()", "This is a sample invovation of "
		     "newtWinEntries() call. It lets you get a lot of input "
		     "quite easily.", 50, 5, 5, 20, autoEntries, "Ok", 
		     "Cancel", NULL);

    newtFinished();

    printf("rc = 0x%x item = %d\n", rc, textWidth);

    return 0;
}
