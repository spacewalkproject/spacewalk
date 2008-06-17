#include <slang.h>
#include <stdlib.h>
#include <string.h>

#include "newt.h"
#include "newt_pr.h"

struct scale {
    long long fullValue;
    int charsSet;
};

static void scaleDraw(newtComponent co);

static struct componentOps scaleOps = {
    scaleDraw,
    newtDefaultEventHandler,
    NULL,
    newtDefaultPlaceHandler,
    newtDefaultMappedHandler,
} ;

newtComponent newtScale(int left, int top, int width, long long fullValue) {
    newtComponent co;
    struct scale * sc;

    co = malloc(sizeof(*co));
    sc = malloc(sizeof(struct scale));
    co->data = sc;

    co->ops = &scaleOps;

    co->height = 1;
    co->width = width;
    co->top = top;
    co->left = left;
    co->takesFocus = 0;

    sc->fullValue = fullValue;
    sc->charsSet = 0;

    return co;
}

void newtScaleSet(newtComponent co, unsigned long long amount) {
    struct scale * sc = co->data;
    int newCharsSet;

    newCharsSet = (amount * co->width) / sc->fullValue;
    
    if (newCharsSet != sc->charsSet) {
	sc->charsSet = newCharsSet;
	scaleDraw(co);
    }
}

static void scaleDraw(newtComponent co) {
    struct scale * sc = co->data;
    int i;

    if (co->top == -1) return;

    newtGotorc(co->top, co->left);

    SLsmg_set_color(NEWT_COLORSET_FULLSCALE);
    for (i = 0; i < sc->charsSet; i++)
	SLsmg_write_string(" ");

    SLsmg_set_color(NEWT_COLORSET_EMPTYSCALE);
    for (i = 0; i < (co->width - sc->charsSet); i++)
	SLsmg_write_string(" ");
}
