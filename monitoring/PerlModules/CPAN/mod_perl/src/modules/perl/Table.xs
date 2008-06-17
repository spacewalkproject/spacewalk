#include "mod_perl.h"

typedef struct {
    SV *cv;
    table *only;
} TableDo;

#define table_pool(t) ((array_header *)(t))->pool

static int Apache_table_do(TableDo *td, const char *key, const char *val)
{
    int count=0, rv=1;
    dSP;

    if(td->only && !table_get(td->only, key))
       return 1;

    ENTER;SAVETMPS;
    PUSHMARK(sp);
    XPUSHs(sv_2mortal(newSVpv((char *)key,0)));
    XPUSHs(sv_2mortal(newSVpv((char *)val,0)));
    PUTBACK;
    count = perl_call_sv(td->cv, G_SCALAR);
    SPAGAIN;
    if(count == 1)
	rv = POPi;
    PUTBACK;
    FREETMPS;LEAVE;
    return rv;
}

typedef void (
#ifdef WIN32
      _stdcall 
#endif
      *TABFUNC) (table *, const char *, const char *);

static void table_modify(TiedTable *self, const char *key, SV *sv, 
			 TABFUNC tabfunc)
{
    dTHR;
    const char *val;

    if(!self->utable) return;

    if(SvROK(sv) && (SvTYPE(SvRV(sv)) == SVt_PVAV)) {
	I32 i;
	AV *av = (AV*)SvRV(sv);
	for(i=0; i<=AvFILL(av); i++) {
	    val = (const char *)SvPV(*av_fetch(av, i, FALSE),na);
            (*tabfunc)(self->utable, key, val);
	}
    }
    else {
        val = (const char *)SvPV(sv,na);
	(*tabfunc)(self->utable, key, val);
    }

}

static void
#ifdef WIN32
_stdcall 
#endif
table_delete(table *tab, const char *key, const char *val)
{
    table_unset(tab, val);
}

static Apache__Table ApacheTable_new(table *utable)
{
    Apache__Table RETVAL = (Apache__Table)safemalloc(sizeof(TiedTable));
    RETVAL->utable = utable;
    RETVAL->ix = 0;
    RETVAL->elts = NULL;
    RETVAL->arr = NULL;
    return RETVAL;
}

MODULE = Apache::Table		PACKAGE = Apache::Table

PROTOTYPES: DISABLE

BOOT:
    items = items; /*avoid warning*/ 

Apache::Table
TIEHASH(pclass, table)
    SV *pclass
    Apache::table table

    CODE:
    if(!pclass) XSRETURN_UNDEF;
    RETVAL = ApacheTable_new(table);

    OUTPUT:
    RETVAL

void
new(pclass, r, nalloc=10)
    SV *pclass
    Apache r
    int nalloc

    CODE:
    if(!pclass) XSRETURN_UNDEF;
    ST(0) = mod_perl_tie_table(make_table(r->pool, nalloc));

void
DESTROY(self)
    SV *self

    PREINIT:
    Apache__Table tab;

    CODE:
    tab = (Apache__Table)hvrv2table(self);
    if(SvROK(self) && SvTYPE(SvRV(self)) == SVt_PVHV) 
        safefree(tab);

void
FETCH(self, key)
    Apache::Table self
    const char *key

    ALIAS:
    get = 1

    PPCODE:
    ix = ix; /*avoid warning*/
    if(!self->utable) XSRETURN_UNDEF;
    if(GIMME == G_SCALAR) {
	const char *val = table_get(self->utable, key);
	if (val) XPUSHs(sv_2mortal(newSVpv((char*)val,0)));
	else XSRETURN_UNDEF;
    }
    else {
	int i;
	array_header *arr  = table_elts(self->utable);
	table_entry *elts = (table_entry *)arr->elts;
	for (i = 0; i < arr->nelts; ++i) {
	    if (!elts[i].key || strcasecmp(elts[i].key, key)) continue;
	    XPUSHs(sv_2mortal(newSVpv(elts[i].val,0)));
	}
    }

bool
EXISTS(self, key)
    Apache::Table self
    const char *key

    CODE:
    if(!self->utable) XSRETURN_UNDEF;
    RETVAL = table_get(self->utable, key) ? TRUE : FALSE;

    OUTPUT:
    RETVAL

const char*
DELETE(self, sv)
    Apache::Table self
    SV *sv

    ALIAS:
    unset = 1

    PREINIT:
    I32 gimme = GIMME_V;

    CODE:
    ix = ix;
    if(!self->utable) XSRETURN_UNDEF;
    RETVAL = NULL;
    if((ix == 0) && (gimme != G_VOID)) {
        STRLEN n_a;
        RETVAL = table_get(self->utable, SvPV(sv,n_a));
    }

    table_modify(self, NULL, sv, (TABFUNC)table_delete);
    if(!RETVAL) XSRETURN_UNDEF;

    OUTPUT:
    RETVAL

void
STORE(self, key, val)
    Apache::Table self
    const char *key
    const char *val

    ALIAS:
    set = 1

    CODE:
    ix = ix; /*avoid warning*/
    if(!self->utable) XSRETURN_UNDEF;
    table_set(self->utable, key, val);

void
CLEAR(self)
    Apache::Table self

    ALIAS:
    clear = 1

    CODE:
    ix = ix; /*avoid warning*/
    if(!self->utable) XSRETURN_UNDEF;
    clear_table(self->utable);

const char *
NEXTKEY(self, lastkey=Nullsv)
    Apache::Table self
    SV *lastkey

    CODE:
    if(self->ix >= self->arr->nelts) XSRETURN_UNDEF;
    RETVAL = self->elts[self->ix++].key;

    OUTPUT:
    RETVAL

const char *
FIRSTKEY(self)
    Apache::Table self

    CODE:
    if(!self->utable) XSRETURN_UNDEF;
    self->arr = table_elts(self->utable);
    if(!self->arr->nelts) XSRETURN_UNDEF;
    self->elts = (table_entry *)self->arr->elts;
    self->ix = 0;
    RETVAL = self->elts[self->ix++].key;

    OUTPUT:
    RETVAL

void
add(self, key, sv)
    Apache::Table self
    const char *key
    SV *sv;

    CODE:
    table_modify(self, key, sv, (TABFUNC)table_add);

void
merge(self, key, sv)
    Apache::Table self
    const char *key
    SV *sv

    CODE:
    table_modify(self, key, sv, (TABFUNC)table_merge);

void
do(self, cv, ...)
    Apache::Table self
    SV *cv

    PREINIT:
    TableDo td;
    td.only = (table *)NULL;

    CODE:
    if(items > 2) {
	int i;
	STRLEN len;
        td.only = make_table(table_pool(self->utable), items-2);
	for(i=2; ; i++) {
	    char *key = SvPV(ST(i),len);
	    table_set(td.only, key, "1");
	    if(i == (items - 1)) break; 
	}
    }
    td.cv = cv;

    table_do((int (*) (void *, const char *, const char *)) Apache_table_do,
	    (void *) &td, self->utable, NULL);
