#include <stdarg.h>

#include "newt.h"

/* if they try and pack more then 50 buttons, screw 'em */
newtGrid newtButtonBarv(char * button1, newtComponent * b1comp, va_list args) {
    newtGrid grid;
    struct buttonInfo {
	char * name;
	newtComponent * compPtr;
    } buttons[50];
    int num;
    int i;

    buttons[0].name = button1, buttons[0].compPtr = b1comp, num = 1;
    while (1) {
	buttons[num].name = va_arg(args, char *);
	if (!buttons[num].name) break;
	buttons[num].compPtr = va_arg(args, newtComponent *);
	num++;
    }

    grid = newtCreateGrid(num, 1);

    for (i = 0; i < num; i++) {
	*buttons[i].compPtr = newtButton(-1, -1, buttons[i].name);
	newtGridSetField(grid, i, 0, NEWT_GRID_COMPONENT, 
			 *buttons[i].compPtr,
			 num ? 1 : 0, 0, 0, 0, 0, 0);
    }

    return grid;
}

newtGrid newtButtonBar(char * button1, newtComponent * b1comp, ...) {
    va_list args;
    newtGrid grid;

    va_start(args, b1comp);

    grid = newtButtonBarv(button1, b1comp, args);

    va_end(args);
 
    return grid;
}
