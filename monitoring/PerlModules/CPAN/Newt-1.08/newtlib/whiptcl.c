#include <string.h>
#include <stdlib.h>

#include "dialogboxes.h"
#include "newt.h"
#include "popt.h"
#include "tcl.h"

enum mode { MODE_NONE, MODE_MSGBOX, MODE_YESNO, MODE_CHECKLIST, MODE_INPUTBOX,
	    MODE_RADIOLIST, MODE_MENU };

#define OPT_MSGBOX 		1000
#define OPT_CHECKLIST 		1001
#define OPT_YESNO 		1002
#define OPT_INPUTBOX 		1003
#define OPT_MENU	 	1005
#define OPT_RADIOLIST	 	1006

static char * setBacktext(ClientData data, Tcl_Interp * interp, 
			  char * name1, char * name2, int flags);
static char * setHelptext(ClientData data, Tcl_Interp * interp,
			  char * name1, char * name2, int flags);
static char * setFullButtons(ClientData data, Tcl_Interp * interp, 
			     char * name1, char * name2, int flags);

static int wtFinish(ClientData clientData, Tcl_Interp * interp, int argc,
                  char ** argv) {
    newtFinished();

    return TCL_OK;
}

static int wtInit(ClientData clientData, Tcl_Interp * interp, int argc,
                  char ** argv) {
    newtInit();
    newtCls();

    newtPushHelpLine("");

    Tcl_TraceVar(interp, "whiptcl_backtext", 
		 TCL_TRACE_WRITES | TCL_GLOBAL_ONLY, setBacktext, NULL);
    Tcl_TraceVar(interp, "whiptcl_helpline", 
		 TCL_TRACE_WRITES | TCL_TRACE_UNSETS | TCL_GLOBAL_ONLY, 
		 setHelptext, NULL);
    Tcl_TraceVar(interp, "whiptcl_fullbuttons", 
		 TCL_TRACE_WRITES | TCL_TRACE_UNSETS | TCL_GLOBAL_ONLY, 
		 setFullButtons, NULL);

    Tcl_SetVar(interp, "whiptcl_helpline", "", TCL_GLOBAL_ONLY);
    Tcl_SetVar(interp, "whiptcl_fullbuttons", "1", TCL_GLOBAL_ONLY);

    return TCL_OK;
}

static int wtCmd(ClientData clientData, Tcl_Interp * interp, int argc,
                  char ** argv) {
    enum mode mode = MODE_NONE;
    poptContext optCon;
    int arg;
    char * optArg;
    char * text;
    char * nextArg;
    char * end;
    int height;
    int width;
    int noCancel = 0;
    int noItem = 0;
    int scrollText = 0;
    int rc = 0;
    int flags = 0;
    int defaultNo = 0;
    char * result;
    char ** selections, ** next;
    char * title = NULL;
    struct poptOption optionsTable[] = {
	    { "checklist", '\0', 0, 0, OPT_CHECKLIST },
	    { "defaultno", '\0', 0, &defaultNo, 0 },
	    { "inputbox", '\0', 0, 0, OPT_INPUTBOX },
	    { "menu", '\0', 0, 0, OPT_MENU },
	    { "msgbox", '\0', 0, 0, OPT_MSGBOX },
	    { "nocancel", '\0', 0, &noCancel, 0 },
	    { "noitem", '\0', 0, &noItem, 0 },
	    { "radiolist", '\0', 0, 0, OPT_RADIOLIST },
	    { "scrolltext", '\0', 0, &scrollText, 0 },
	    { "title", '\0', POPT_ARG_STRING, &title, 0 },
	    { "yesno", '\0', 0, 0, OPT_YESNO },
	    { 0, 0, 0, 0, 0 } 
    };
    
    optCon = poptGetContext("whiptcl", argc, argv, optionsTable, 0);

    while ((arg = poptGetNextOpt(optCon)) > 0) {
	optArg = poptGetOptArg(optCon);

	switch (arg) {
	  case OPT_MENU:
	    if (mode != MODE_NONE) rc = -1;
	    mode = MODE_MENU;
	    break;

	  case OPT_MSGBOX:
	    if (mode != MODE_NONE) rc = -1;
	    mode = MODE_MSGBOX;
	    break;

	  case OPT_RADIOLIST:
	    if (mode != MODE_NONE) rc = -1;
	    mode = MODE_RADIOLIST;
	    break;

	  case OPT_CHECKLIST:
	    if (mode != MODE_NONE) rc = -1;
	    mode = MODE_CHECKLIST;
	    break;

	  case OPT_YESNO:
	    if (mode != MODE_NONE) rc = -1;
	    mode = MODE_YESNO;
	    break;

	  case OPT_INPUTBOX:
	    if (mode != MODE_NONE) rc = -1;
	    mode = MODE_INPUTBOX;
	    break;
	}
    }
    
    if (arg < -1) {
	/* this could buffer oveflow, bug we're not setuid so I don't care */
	interp->result = malloc(200);
	interp->freeProc = TCL_DYNAMIC;
	sprintf(interp->result, "%s: %s\n", 
		poptBadOption(optCon, POPT_BADOPTION_NOALIAS), 
		poptStrerror(arg));

	return TCL_ERROR;
    }

    if (mode == MODE_NONE) {
	interp->result = "no dialog mode was specified";
	return TCL_ERROR;
    } else if (rc) {
	interp->result = "multiple modes were specified";
	return TCL_ERROR;
    }

    if (!(text = poptGetArg(optCon))) {
	interp->result = "missing text parameter";
	return TCL_ERROR;
    }

    if (!(nextArg = poptGetArg(optCon))) {
	interp->result = "height missing";
	return TCL_ERROR;
    }
    height = strtoul(nextArg, &end, 10);
    if (*end) {
	interp->result = "height is not a number";
	return TCL_ERROR;
    }

    if (!(nextArg = poptGetArg(optCon))) {
	interp->result = "width missing";
	return TCL_ERROR;
    }
    width = strtoul(nextArg, &end, 10);
    if (*end) {
	interp->result = "width is not a number";
	return TCL_ERROR;
    }

    width -= 2;
    height -= 2;
    newtOpenWindow((80 - width) / 2, (24 - height) / 2, width, height, title);

    if (noCancel) flags |= FLAG_NOCANCEL;
    if (noItem) flags |= FLAG_NOITEM;
    if (scrollText) flags |= FLAG_SCROLL_TEXT;
    if (defaultNo) flags |= FLAG_DEFAULT_NO;

    switch (mode) {
      case MODE_MSGBOX:
	rc = messageBox(text, height, width, MSGBOX_MSG, flags);
	break;

      case MODE_YESNO:
	rc = messageBox(text, height, width, MSGBOX_YESNO, flags);
	if (rc == DLG_OKAY)
	    interp->result = "yes";
	else 
	    interp->result = "no";
	if (rc == DLG_ERROR) rc = 0;
	break;

      case MODE_INPUTBOX:
	rc = inputBox(text, height, width, optCon, flags, &result);
	if (!rc) {
	    interp->result = strdup(result);
	    interp->freeProc = TCL_DYNAMIC;
	}
	break;

      case MODE_MENU:
	rc = listBox(text, height, width, optCon, flags, &result);
	if (!rc) {
	    interp->result = strdup(result);
	    interp->freeProc = TCL_DYNAMIC;
	}
	break;

      case MODE_RADIOLIST:
	rc = checkList(text, height, width, optCon, 1, flags, &selections);
	if (!rc) {
	    interp->result = strdup(selections[0]);
	    interp->freeProc = TCL_DYNAMIC;
	}
	break;

      case MODE_CHECKLIST:
	rc = checkList(text, height, width, optCon, 0, flags, &selections);

	if (!rc) {
	    for (next = selections; *next; next++) 
		Tcl_AppendElement(interp, *next);

	    free(selections);
	}
	break;

      case MODE_NONE:
	/* this can't happen */
    }

    newtPopWindow();

    if (rc == DLG_ERROR) {
	interp->result = "bad paramter for whiptcl dialog box";
	return TCL_ERROR;
    } 

    Tcl_SetVar(interp, "whiptcl_canceled", (rc == DLG_CANCEL) ? "1" : "0",
		0);

    return TCL_OK;
}

static char * setBacktext(ClientData data, Tcl_Interp * interp, 
			  char * name1, char * name2, int flags) {
    static char blankLine[81] = "                                        "
                         "                                        ";

    newtDrawRootText(0, 0, blankLine);
    newtDrawRootText(0, 0, Tcl_GetVar(interp, "whiptcl_backtext",
		                      TCL_GLOBAL_ONLY));

    return NULL;
}

static char * setHelptext(ClientData data, Tcl_Interp * interp, 
			  char * name1, char * name2, int flags) {
    char * text = Tcl_GetVar(interp, "whiptcl_helpline", TCL_GLOBAL_ONLY);

    if (!text)
	text = "";
    else if (!strlen(text))
	text = NULL;

    newtPopHelpLine();
    newtPushHelpLine(text);

    return NULL;
}

static char * setFullButtons(ClientData data, Tcl_Interp * interp, 
			     char * name1, char * name2, int flags) {
    char * val = Tcl_GetVar(interp, "whiptcl_fullbuttons", TCL_GLOBAL_ONLY);
    int rc;
    int state;
    
    if ((rc = Tcl_ExprBoolean(interp, val, &state))) {
	Tcl_FreeResult(interp);
	return "whiptcl_fullbuttons may only contain a boolean value";
    }

    useFullButtons(state);

    return NULL;
}

int Whiptcl_Init(Tcl_Interp * interp) {
    Tcl_CreateCommand(interp, "whiptcl_finish", wtFinish, NULL, NULL);
    Tcl_CreateCommand(interp, "whiptcl_init", wtInit, NULL, NULL);
    Tcl_CreateCommand(interp, "whiptcl_cmd", wtCmd, NULL, NULL);

    return TCL_OK;
}
