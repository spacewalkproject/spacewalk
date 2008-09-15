
/*
   $Id: dbdimp.c,v 1.1.1.1 2001-01-12 20:41:07 dparker Exp $

   Copyright (c) 1997,1998,1999,2000 Edmund Mergl
   Portions Copyright (c) 1994,1995,1996,1997 Tim Bunce

   You may distribute under the terms of either the GNU General Public
   License or the Artistic License, as specified in the Perl README file.

*/


/* 
   hard-coded OIDs:   (here we need the postgresql types)
                    pg_sql_type()  1042 (bpchar), 1043 (varchar)
                    ddb_st_fetch() 1042 (bpchar),   16 (bool)
                    ddb_preparse() 1043 (varchar)
                    pgtype_bind_ok()
*/

#include "Pg.h"

/* XXX DBI should provide a better version of this */
#define IS_DBI_HANDLE(h)  (SvROK(h) && SvTYPE(SvRV(h)) == SVt_PVHV && SvRMAGICAL(SvRV(h)) && (SvMAGIC(SvRV(h)))->mg_type == 'P')

DBISTATE_DECLARE;


static void dbd_preparse  (imp_sth_t *imp_sth, char *statement);


void
dbd_init (dbistate)
    dbistate_t *dbistate;
{
    DBIS = dbistate;
}


int
dbd_discon_all (drh, imp_drh)
    SV *drh;
    imp_drh_t *imp_drh;
{
    dTHR;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_discon_all\n"); }

    /* The disconnect_all concept is flawed and needs more work */
    if (!dirty && !SvTRUE(perl_get_sv("DBI::PERL_ENDING",0))) {
	sv_setiv(DBIc_ERR(imp_drh), (IV)1);
	sv_setpv(DBIc_ERRSTR(imp_drh),
		(char*)"disconnect_all not implemented");
	DBIh_EVENT2(drh, ERROR_event,
		DBIc_ERR(imp_drh), DBIc_ERRSTR(imp_drh));
	return FALSE;
    }
    if (perl_destruct_level) {
        perl_destruct_level = 0;
    }
    return FALSE;
}


/* Database specific error handling. */

void
pg_error (h, error_num, error_msg)
    SV *h;
    int error_num;
    char *error_msg;
{
    D_imp_xxh(h);

    sv_setiv(DBIc_ERR(imp_xxh), (IV)error_num);		/* set err early */
    sv_setpv(DBIc_ERRSTR(imp_xxh), (char*)error_msg);
    DBIh_EVENT2(h, ERROR_event, DBIc_ERR(imp_xxh), DBIc_ERRSTR(imp_xxh));
    if (dbis->debug >= 2) { fprintf(DBILOGFP, "%s error %d recorded: %s\n", error_msg, error_num, SvPV(DBIc_ERRSTR(imp_xxh),na)); }
}

static int
pgtype_bind_ok (dbtype)
    int dbtype;
{
    /* basically we support types that can be returned as strings */
    switch(dbtype) {
    case   16:	/* bool		*/
    case   18:	/* char		*/
    case   20:	/* int8		*/
    case   21:	/* int2		*/
    case   23:	/* int4		*/
    case   25:	/* text		*/
    case   26:	/* oid		*/
    case  700:	/* float4	*/
    case  701:	/* float8	*/
    case  702:	/* abstime	*/
    case  703:	/* reltime	*/
    case  704:	/* tinterval	*/
    case 1042:	/* bpchar	*/
    case 1043:	/* varchar	*/
    case 1082:	/* date		*/
    case 1083:	/* time		*/
    case 1184:	/* datetime	*/
    case 1186:	/* timespan	*/
    case 1296:	/* timestamp	*/
        return 1;
    }
    return 0;
}


/* ================================================================== */

int
pg_db_login (dbh, imp_dbh, dbname, uid, pwd)
    SV *dbh;
    imp_dbh_t *imp_dbh;
    char *dbname;
    char *uid;
    char *pwd;
{
    dTHR;

    char *conn_str;
    char *src;
    char *dest;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "pg_db_login\n"); }

    /* build connect string */
    /* DBD-Pg syntax: 'dbname=dbname;host=host;port=port' */
    /* pgsql  syntax: 'dbname=dbname host=host port=port user=uid password=pwd' */

    conn_str = (char *)malloc(strlen(dbname) + strlen(uid) + strlen(pwd) + 16 + 1);
    if (! conn_str) {
        return 0;
    }

    src  = dbname;
    dest = conn_str;
    while (*src) {
        if (*src != ';') {
            *dest++ = *src++;
            continue;
        }
        *dest++ = ' ';
        src++;
    }
    *dest = '\0';

    if (strlen(uid)) {
        strcat(conn_str, " user=");
        strcat(conn_str, uid);
    }
    if (strlen(uid) && strlen(pwd)) {
        strcat(conn_str, " password=");
        strcat(conn_str, pwd);
    }

    if (dbis->debug >= 2) { fprintf(DBILOGFP, "pg_db_login: conn_str = >%s<\n", conn_str); }

    /* make a connection to the database */
    imp_dbh->conn = PQconnectdb(conn_str);
    free(conn_str);

    /* check to see that the backend connection was successfully made */
    if (PQstatus(imp_dbh->conn) != CONNECTION_OK) {
        pg_error(dbh, PQstatus(imp_dbh->conn), PQerrorMessage(imp_dbh->conn));
        PQfinish(imp_dbh->conn);
        return 0;
    }

    imp_dbh->init_commit = 1;			/* initialize AutoCommit */
    imp_dbh->pg_auto_escape = 1;		/* initialize pg_auto_escape */

    DBIc_IMPSET_on(imp_dbh);			/* imp_dbh set up now */
    DBIc_ACTIVE_on(imp_dbh);			/* call disconnect before freeing */
    return 1;
}


int
dbd_db_ping (dbh)
    SV *dbh;
{
    char id;
    D_imp_dbh(dbh);
    PGresult* result;
    ExecStatusType status;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_db_ping\n"); }

    result = PQexec(imp_dbh->conn, " ");
    status = result ? PQresultStatus(result) : -1;

    if (PGRES_EMPTY_QUERY != status) {
        return 0;
    }

    return 1;
}


int
dbd_db_commit (dbh, imp_dbh)
    SV *dbh;
    imp_dbh_t *imp_dbh;
{
    PGresult* result = 0;
    ExecStatusType status;
    int retval = 1;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_db_commit\n"); }

    /* no commit if AutoCommit = on */
    if (DBIc_has(imp_dbh, DBIcf_AutoCommit) != FALSE) {
        return 0;
    }

    /* execute commit */
    result = PQexec(imp_dbh->conn, "commit");
    status = result ? PQresultStatus(result) : -1;
    PQclear(result);

    /* check result */
    if (status != PGRES_COMMAND_OK) {
        pg_error(dbh, status, "commit failed\n");
        return 0;
    }

    /* start new transaction if AutoCommit = off */
    if (DBIc_has(imp_dbh, DBIcf_AutoCommit) == FALSE) {
        result = PQexec(imp_dbh->conn, "begin");
        status = result ? PQresultStatus(result) : -1;
        PQclear(result);
        if (status != PGRES_COMMAND_OK) {
            pg_error(dbh, status, "begin failed\n");
            return 0;
        }
    }

    return retval;
}


int
dbd_db_rollback (dbh, imp_dbh)
    SV *dbh;
    imp_dbh_t *imp_dbh;
{
    PGresult* result = 0;
    ExecStatusType status;
    int retval = 1;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_db_rollback\n"); }

    /* no rollback if AutoCommit = on */
    if (DBIc_has(imp_dbh, DBIcf_AutoCommit) != FALSE) {
        return 0;
    }

    /* execute rollback */
    result = PQexec(imp_dbh->conn, "rollback");
    status = result ? PQresultStatus(result) : -1;
    PQclear(result);

    /* check result */
    if (status != PGRES_COMMAND_OK) {
        pg_error(dbh, status, "rollback failed\n");
        return 0;
    }

    /* start new transaction if AutoCommit = off */
    if (DBIc_has(imp_dbh, DBIcf_AutoCommit) == FALSE) {
        result = PQexec(imp_dbh->conn, "begin");
        status = result ? PQresultStatus(result) : -1;
        PQclear(result);
        if (status != PGRES_COMMAND_OK) {
            pg_error(dbh, status, "begin failed\n");
            return 0;
        }
    }

    return retval;
}


int
dbd_db_disconnect (dbh, imp_dbh)
    SV *dbh;
    imp_dbh_t *imp_dbh;
{
    dTHR;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_db_disconnect\n"); }

    /* We assume that disconnect will always work	*/
    /* since most errors imply already disconnected.	*/
    DBIc_ACTIVE_off(imp_dbh);

    /* rollback if AutoCommit = off */
    if (DBIc_has(imp_dbh, DBIcf_AutoCommit) == FALSE) {
        PGresult* result = 0;
        ExecStatusType status;
        result = PQexec(imp_dbh->conn, "rollback");
        status = result ? PQresultStatus(result) : -1;
        PQclear(result);
        if (status != PGRES_COMMAND_OK) {
            pg_error(dbh, status, "rollback failed\n");
            return 0;
        }
        if (dbis->debug >= 2) { fprintf(DBILOGFP, "dbd_db_disconnect: AutoCommit=off -> rollback\n"); }
    }

    PQfinish(imp_dbh->conn);

    /* We don't free imp_dbh since a reference still exists	*/
    /* The DESTROY method is the only one to 'free' memory.	*/
    /* Note that statement objects may still exists for this dbh!	*/
    return 1;
}


void
dbd_db_destroy (dbh, imp_dbh)
    SV *dbh;
    imp_dbh_t *imp_dbh;
{
    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_db_destroy\n"); }

    if (DBIc_ACTIVE(imp_dbh)) {
        dbd_db_disconnect(dbh, imp_dbh);
    }

    /* Nothing in imp_dbh to be freed	*/
    DBIc_IMPSET_off(imp_dbh);
}


int
dbd_db_STORE_attrib (dbh, imp_dbh, keysv, valuesv)
    SV *dbh;
    imp_dbh_t *imp_dbh;
    SV *keysv;
    SV *valuesv;
{
    STRLEN kl;
    char *key = SvPV(keysv,kl);
    int newval = SvTRUE(valuesv);

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_db_STORE\n"); }

    if (kl==10 && strEQ(key, "AutoCommit")) {
        int oldval = DBIc_has(imp_dbh, DBIcf_AutoCommit);
        DBIc_set(imp_dbh, DBIcf_AutoCommit, newval);
        if (oldval == FALSE && newval != FALSE && imp_dbh->init_commit) {
            /* do nothing, fall through */
            if (dbis->debug >= 2) { fprintf(DBILOGFP, "dbd_db_STORE: initialize AutoCommit to on\n"); }
        } else if (oldval == FALSE && newval != FALSE) {
            /* commit any outstanding changes */
            PGresult* result = 0;
            ExecStatusType status;
            result = PQexec(imp_dbh->conn, "commit");
            status = result ? PQresultStatus(result) : -1;
            PQclear(result);
            if (status != PGRES_COMMAND_OK) {
                pg_error(dbh, status, "commit failed\n");
                return 0;
            }
            if (dbis->debug >= 2) { fprintf(DBILOGFP, "dbd_db_STORE: switch AutoCommit to on: commit\n"); }
        } else if ((oldval != FALSE && newval == FALSE) || (oldval == FALSE && newval == FALSE && imp_dbh->init_commit)) {
            /* start new transaction */
            PGresult* result = 0;
            ExecStatusType status;
            result = PQexec(imp_dbh->conn, "begin");
            status = result ? PQresultStatus(result) : -1;
            PQclear(result);
            if (status != PGRES_COMMAND_OK) {
                pg_error(dbh, status, "begin failed\n");
                return 0;
            }
            if (dbis->debug >= 2) { fprintf(DBILOGFP, "dbd_db_STORE: switch AutoCommit to off: begin\n"); }
        }
        /* only needed once */
        imp_dbh->init_commit = 0;
        return 1;
    } else if (kl==14 && strEQ(key, "pg_auto_escape")) {
        imp_dbh->pg_auto_escape = newval;
    } else {
        return 0;
    }
}


SV *
dbd_db_FETCH_attrib (dbh, imp_dbh, keysv)
    SV *dbh;
    imp_dbh_t *imp_dbh;
    SV *keysv;
{
    STRLEN kl;
    char *key = SvPV(keysv,kl);
    SV *retsv = Nullsv;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_db_FETCH\n"); }

    if (kl==10 && strEQ(key, "AutoCommit")) {
        retsv = boolSV(DBIc_has(imp_dbh, DBIcf_AutoCommit));
    } else if (kl==14 && strEQ(key, "pg_auto_escape")) {
        retsv = newSViv((IV)imp_dbh->pg_auto_escape);
    } else if (kl==11 && strEQ(key, "pg_INV_READ")) {
        retsv = newSViv((IV)INV_READ);
    } else if (kl==12 && strEQ(key, "pg_INV_WRITE")) {
        retsv = newSViv((IV)INV_WRITE);
    }

    if (!retsv) {
	return Nullsv;
    }
    if (retsv == &sv_yes || retsv == &sv_no) {
        return retsv; /* no need to mortalize yes or no */
    }
    return sv_2mortal(retsv);
}


/* driver specific functins */


int
pg_db_lo_open (dbh, lobjId, mode)
    SV *dbh;
    unsigned int lobjId;
    int mode;
{
    D_imp_dbh(dbh);
    return lo_open(imp_dbh->conn, lobjId, mode);
}


int
pg_db_lo_close (dbh, fd)
    SV *dbh;
    int fd;
{
    D_imp_dbh(dbh);
    return lo_close(imp_dbh->conn, fd);
}


int
pg_db_lo_read (dbh, fd, buf, len)
    SV *dbh;
    int fd;
    char *buf;
    int len;
{
    D_imp_dbh(dbh);
    return lo_read(imp_dbh->conn, fd, buf, len);
}


int
pg_db_lo_write (dbh, fd, buf, len)
    SV *dbh;
    int fd;
    char *buf;
    int len;
{
    D_imp_dbh(dbh);
    return lo_write(imp_dbh->conn, fd, buf, len);
}


int
pg_db_lo_lseek (dbh, fd, offset, whence)
    SV *dbh;
    int fd;
    int offset;
    int whence;
{
    D_imp_dbh(dbh);
    return lo_lseek(imp_dbh->conn, fd, offset, whence);
}


unsigned int
pg_db_lo_creat (dbh, mode)
    SV *dbh;
    int mode;
{
    D_imp_dbh(dbh);
    return lo_creat(imp_dbh->conn, mode);
}


int
pg_db_lo_tell (dbh, fd)
    SV *dbh;
    int fd;
{
    D_imp_dbh(dbh);
    return lo_tell(imp_dbh->conn, fd);
}


int
pg_db_lo_unlink (dbh, lobjId)
    SV *dbh;
    unsigned int lobjId;
{
    D_imp_dbh(dbh);
    return lo_unlink(imp_dbh->conn, lobjId);
}


unsigned int
pg_db_lo_import (dbh, filename)
    SV *dbh;
    char *filename;
{
    D_imp_dbh(dbh);
    return lo_import(imp_dbh->conn, filename);
}


int
pg_db_lo_export (dbh, lobjId, filename)
    SV *dbh;
    unsigned int lobjId;
    char *filename;
{
    D_imp_dbh(dbh);
    return lo_export(imp_dbh->conn, lobjId, filename);
}


int
pg_db_putline (dbh, buffer)
    SV *dbh;
    char *buffer;
{
    D_imp_dbh(dbh);
    return PQputline(imp_dbh->conn, buffer);
}


int
pg_db_getline (dbh, buffer, length)
    SV *dbh;
    char *buffer;
    int length;
{
    D_imp_dbh(dbh);
    return PQgetline(imp_dbh->conn, buffer, length);
}


int
pg_db_endcopy (dbh)
    SV *dbh;
{
    D_imp_dbh(dbh);
    return PQendcopy(imp_dbh->conn);
}


/* ================================================================== */


int
dbd_st_prepare (sth, imp_sth, statement, attribs)
    SV *sth;
    imp_sth_t *imp_sth;
    char *statement;
    SV *attribs;
{
    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_st_prepare: statement = >%s<\n", statement); }

    /* scan statement for '?', ':1' and/or ':foo' style placeholders */
    dbd_preparse(imp_sth, statement);

    /* initialize new statement handle */
    imp_sth->result    = 0;
    imp_sth->cur_tuple = 0;

    DBIc_IMPSET_on(imp_sth);
    return 1;
}


static void
dbd_preparse (imp_sth, statement)
    imp_sth_t *imp_sth;
    char *statement;
{
    bool in_literal = FALSE;
    char in_comment = '\0';
    char *src, *start, *dest;
    phs_t phs_tpl;
    SV *phs_sv;
    int idx=0;
    char *style="", *laststyle=Nullch;
    STRLEN namelen;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_st_preparse: statement = >%s<\n", statement); }

    /* allocate room for copy of statement with spare capacity	*/
    /* for editing '?' or ':1' into ':p1'.			*/
    imp_sth->statement = (char*)safemalloc(strlen(statement) * 3 + 1);

    /* initialise phs ready to be cloned per placeholder	*/
    memset(&phs_tpl, 0, sizeof(phs_tpl));
    phs_tpl.ftype = 1043;	/* VARCHAR */

    src  = statement;
    dest = imp_sth->statement;
    while(*src) {

	if (in_comment) {
	    /* SQL-style and C++-style */ 
	    if ((in_comment == '-' || in_comment == '/') && *src == '\n') {
		in_comment = '\0';
	    }
            /* C-style */
	    else if (in_comment == '*' && *src == '*' && *(src+1) == '/') {
		*dest++ = *src++; /* avoids asterisk-slash-asterisk issues */
		in_comment = '\0';
	    }
	    *dest++ = *src++;
	    continue;
	}

	if (in_literal) {
	    /* check if literal ends but keep quotes in literal */
	    if (*src == in_literal && *(src-1) != '\\') {
	        in_literal = 0;
            }
	    *dest++ = *src++;
	    continue;
	}

	/* Look for comments: SQL-style or C++-style or C-style	*/
	if ((*src == '-' && *(src+1) == '-') ||
            (*src == '/' && *(src+1) == '/') ||
	    (*src == '/' && *(src+1) == '*'))
	{
	    in_comment = *(src+1);
	    /* We know *src & the next char are to be copied, so do */
	    /* it. In the case of C-style comments, it happens to */
	    /* help us avoid slash-asterisk-slash oddities. */
	    *dest++ = *src++;
	    *dest++ = *src++;
	    continue;
	}

        /* check if no placeholders */
        if (*src != ':' && *src != '?') {
	    if (*src == '\'' || *src == '"') {
		in_literal = *src;
	    }
	    *dest++ = *src++;
	    continue;
	}

        /* check for cast operator */
        if (*src == ':' && (*(src-1) == ':' || *(src+1) == ':')) {
	    *dest++ = *src++;
	    continue;
	}

	/* only here for : or ? outside of a comment or literal	and no cast */

        start = dest;			/* save name inc colon	*/ 
        *dest++ = *src++;
        if (*start == '?') {		/* X/Open standard	*/
            sprintf(start,":p%d", ++idx); /* '?' -> ':p1' (etc)	*/
            dest = start+strlen(start);
            style = "?";

        } else if (isDIGIT(*src)) {	/* ':1'		*/
            idx = atoi(src);
            *dest++ = 'p';		/* ':1'->':p1'	*/
            if (idx <= 0) {
                croak("Placeholder :%d invalid, placeholders must be >= 1", idx);
            }
            while(isDIGIT(*src)) {
                *dest++ = *src++;
            }
            style = ":1";

        } else if (isALNUM(*src)) {	/* ':foo'	*/
            while(isALNUM(*src)) {	/* includes '_'	*/
                *dest++ = *src++;
            }
            style = ":foo";
        } else {			/* perhaps ':=' PL/SQL construct */
            continue;
        }
        *dest = '\0';			/* handy for debugging	*/
        namelen = (dest-start);
        if (laststyle && style != laststyle) {
            croak("Can't mix placeholder styles (%s/%s)",style,laststyle);
        }
        laststyle = style;
        if (imp_sth->all_params_hv == NULL) {
            imp_sth->all_params_hv = newHV();
        }
        phs_tpl.sv = &sv_undef;
        phs_sv = newSVpv((char*)&phs_tpl, sizeof(phs_tpl)+namelen+1);
        hv_store(imp_sth->all_params_hv, start, namelen, phs_sv, 0);
        strcpy( ((phs_t*)(void*)SvPVX(phs_sv))->name, start);
    }
    *dest = '\0';
    if (imp_sth->all_params_hv) {
        DBIc_NUM_PARAMS(imp_sth) = (int)HvKEYS(imp_sth->all_params_hv);
        if (dbis->debug >= 2) { fprintf(DBILOGFP, "    dbd_preparse scanned %d distinct placeholders\n", (int)DBIc_NUM_PARAMS(imp_sth)); }
    }
}


static int
pg_sql_type (imp_sth, name, sql_type)
    imp_sth_t *imp_sth;
    char *name;
    int sql_type;
{
    switch (sql_type) {
        case SQL_CHAR:
            return 1042;	/* bpchar */
        case SQL_NUMERIC:
            return 700;		/* float4 */
        case SQL_DECIMAL:
            return 700;		/* float4 */
        case SQL_INTEGER:
            return 23;		/* int4	*/
        case SQL_SMALLINT:
            return 21;		/* int2	*/
        case SQL_FLOAT:
            return 700;		/* float4 */
        case SQL_REAL:
            return 701;		/* float8 */
        case SQL_DOUBLE:
            return 20;		/* int8 */
        case SQL_VARCHAR:
            return 1043;	/* varchar */
        default:
            if (DBIc_WARN(imp_sth) && imp_sth && name) {
                warn("SQL type %d for '%s' is not fully supported, bound as VARCHAR instead");
            }
            return pg_sql_type(imp_sth, name, SQL_VARCHAR);
    }
}


static int
dbd_rebind_ph (sth, imp_sth, phs)
    SV *sth;
    imp_sth_t *imp_sth;
    phs_t *phs;
{
    STRLEN value_len;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_st_rebind\n"); }

    /* convert to a string ASAP */
    if (!SvPOK(phs->sv) && SvOK(phs->sv)) {
	sv_2pv(phs->sv, &na);
    }

    if (dbis->debug >= 2) {
	char *val = neatsvpv(phs->sv,0);
 	fprintf(DBILOGFP, "       bind %s <== %.1000s (", phs->name, val);
 	if (SvOK(phs->sv)) {
 	     fprintf(DBILOGFP, "size %ld/%ld/%ld, ", (long)SvCUR(phs->sv),(long)SvLEN(phs->sv),phs->maxlen);
	} else {
            fprintf(DBILOGFP, "NULL, ");
        }
 	fprintf(DBILOGFP, "ptype %d, otype %d%s)\n", (int)SvTYPE(phs->sv), phs->ftype, (phs->is_inout) ? ", inout" : "");
    }

    /* At the moment we always do sv_setsv() and rebind.        */
    /* Later we may optimise this so that more often we can     */
    /* just copy the value & length over and not rebind.        */

    if (phs->is_inout) {        /* XXX */
        if (SvREADONLY(phs->sv)) {
            croak(no_modify);
        }
        /* phs->sv _is_ the real live variable, it may 'mutate' later   */
        /* pre-upgrade high to reduce risk of SvPVX realloc/move        */
        (void)SvUPGRADE(phs->sv, SVt_PVNV);
        /* ensure room for result, 28 is magic number (see sv_2pv)      */
        SvGROW(phs->sv, (phs->maxlen < 28) ? 28 : phs->maxlen+1);
    }
    else {
        /* phs->sv is copy of real variable, upgrade to at least string */
        (void)SvUPGRADE(phs->sv, SVt_PV);
    }

    /* At this point phs->sv must be at least a PV with a valid buffer, */
    /* even if it's undef (null)                                        */
    /* Here we set phs->progv, phs->indp, and value_len.                */
    if (SvOK(phs->sv)) {
        phs->progv = SvPV(phs->sv, value_len);
        phs->indp  = 0;
    }
    else {        /* it's null but point to buffer in case it's an out var */
        phs->progv = SvPVX(phs->sv);
        phs->indp  = -1;
        value_len  = 0;
    }
    phs->sv_type = SvTYPE(phs->sv);        /* part of mutation check    */
    phs->maxlen  = SvLEN(phs->sv)-1;       /* avail buffer space        */
    if (phs->maxlen < 0) {                 /* can happen with nulls     */
	phs->maxlen = 0;
    }

    phs->alen = value_len + phs->alen_incnull;

    imp_sth->all_params_len += SvOK(phs->sv) ? phs->alen : 4; /* NULL */

    if (dbis->debug >= 3) {
	fprintf(DBILOGFP, "       bind %s <== '%.*s' (size %ld/%ld, otype %d, indp %d)\n",
 	    phs->name,
	    (int)(phs->alen>SvIV(DBIS->neatsvpvlen) ? SvIV(DBIS->neatsvpvlen) : phs->alen),
	    (phs->progv) ? phs->progv : "",
 	    (long)phs->alen, (long)phs->maxlen, phs->ftype, phs->indp);
    }

    return 1;
}


int
dbd_bind_ph (sth, imp_sth, ph_namesv, newvalue, sql_type, attribs, is_inout, maxlen)
    SV *sth;
    imp_sth_t *imp_sth;
    SV *ph_namesv;
    SV *newvalue;
    IV sql_type;
    SV *attribs;
    int is_inout;
    IV maxlen;
{
    SV **phs_svp;
    STRLEN name_len;
    char *name;
    char namebuf[30];
    phs_t *phs;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_bind_ph\n"); }

    /* check if placeholder was passed as a number        */

    if (SvGMAGICAL(ph_namesv)) { /* eg if from tainted expression */
	mg_get(ph_namesv);
    }
    if (!SvNIOKp(ph_namesv)) {
	name = SvPV(ph_namesv, name_len);
    }
    if (SvNIOKp(ph_namesv) || (name && isDIGIT(name[0]))) {
	sprintf(namebuf, ":p%d", (int)SvIV(ph_namesv));
	name = namebuf;
	name_len = strlen(name);
    }
    assert(name != Nullch);

    if (SvTYPE(newvalue) > SVt_PVLV) { /* hook for later array logic	*/
	croak("Can't bind a non-scalar value (%s)", neatsvpv(newvalue,0));
    }
    if (SvROK(newvalue) && !IS_DBI_HANDLE(newvalue)) {
	/* dbi handle allowed for cursor variables */
	croak("Can't bind a reference (%s)", neatsvpv(newvalue,0));
    }
    if (SvTYPE(newvalue) == SVt_PVLV && is_inout) {	/* may allow later */
        croak("Can't bind ``lvalue'' mode scalar as inout parameter (currently)");
    }

   if (dbis->debug >= 2) {
        fprintf(DBILOGFP, "         bind %s <== %s (type %ld", name, neatsvpv(newvalue,0), (long)sql_type);
        if (is_inout) {
            fprintf(DBILOGFP, ", inout 0x%lx, maxlen %ld", (long)newvalue, (long)maxlen);
        }
        if (attribs) {
            fprintf(DBILOGFP, ", attribs: %s", neatsvpv(attribs,0));
        }
        fprintf(DBILOGFP, ")\n");
    }

    phs_svp = hv_fetch(imp_sth->all_params_hv, name, name_len, 0);
    if (phs_svp == NULL) {
        croak("Can't bind unknown placeholder '%s' (%s)", name, neatsvpv(ph_namesv,0));
    }
    phs = (phs_t*)(void*)SvPVX(*phs_svp);	/* placeholder struct	*/

    if (phs->sv == &sv_undef) { /* first bind for this placeholder	*/
        phs->ftype    = 1043;		 /* our default type VARCHAR	*/
        phs->is_inout = is_inout;
        if (is_inout) {
	    /* phs->sv assigned in the code below */
            ++imp_sth->has_inout_params;
	    /* build array of phs's so we can deal with out vars fast	*/
            if (!imp_sth->out_params_av) {
                imp_sth->out_params_av = newAV();
            }
            av_push(imp_sth->out_params_av, SvREFCNT_inc(*phs_svp));
        } 

        if (attribs) {	/* only look for pg_type on first bind of var	*/
            SV **svp;
	    /* Setup / Clear attributes as defined by attribs.		*/
	    /* XXX If attribs is EMPTY then reset attribs to default?	*/
            if ( (svp = hv_fetch((HV*)SvRV(attribs), "pg_type", 7,  0)) != NULL) {
                int pg_type = SvIV(*svp);
                if (!pgtype_bind_ok(pg_type)) {
                    croak("Can't bind %s, pg_type %d not supported by DBD::Pg", phs->name, pg_type);
                }
                if (sql_type) {
                    croak("Can't specify both TYPE (%d) and pg_type (%d) for %s", sql_type, pg_type, phs->name);
                }
                phs->ftype = pg_type;
            }
        }
        if (sql_type) {
            phs->ftype = pg_sql_type(imp_sth, phs->name, sql_type);
        }
    }   /* was first bind for this placeholder  */

        /* check later rebinds for any changes */
    else if (is_inout || phs->is_inout) {
        croak("Can't rebind or change param %s in/out mode after first bind (%d => %d)", phs->name, phs->is_inout , is_inout);
    }
    else if (sql_type && phs->ftype != pg_sql_type(imp_sth, phs->name, sql_type)) {
        croak("Can't change TYPE of param %s to %d after initial bind", phs->name, sql_type);
    }

    phs->maxlen = maxlen;		/* 0 if not inout		*/

    if (!is_inout) {	/* normal bind to take a (new) copy of current value	*/
        if (phs->sv == &sv_undef) {     /* (first time bind) */
            phs->sv = newSV(0);
        }
        sv_setsv(phs->sv, newvalue);
    } else if (newvalue != phs->sv) {
        if (phs->sv) {
            SvREFCNT_dec(phs->sv);
        }
        phs->sv = SvREFCNT_inc(newvalue);	/* point to live var	*/
    }

    return dbd_rebind_ph(sth, imp_sth, phs);
}


int
dbd_st_execute (sth, imp_sth)   /* <= -2:error, >=0:ok row count, (-1=unknown count) */
    SV *sth;
    imp_sth_t *imp_sth;
{
    dTHR;

    D_imp_dbh_from_sth;
    ExecStatusType status = -1;
    char *cmdStatus;
    char *cmdTuples;
    char *statement;
    int ret = -2;
    int num_fields;
    int i;
    int len;
    bool in_literal = FALSE;
    char in_comment = '\0';
    char *src;
    char *dest;
    char *val;
    char namebuf[30];
    phs_t *phs;
    SV **svp;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_st_execute\n"); }

    /*
    here we get the statement from the statement handle where
    it has been stored when creating a blank sth during prepare
    svp = hv_fetch((HV *)SvRV(sth), "Statement", 9, FALSE);
    statement = SvPV(*svp, na);
    */

    statement = imp_sth->statement;
    if (! statement) {
        /* are we prepared ? */
        pg_error(sth, -1, "statement not prepared\n");
        return -2;
    }

    /* do we have input parameters ? */
    if ((int)DBIc_NUM_PARAMS(imp_sth) > 0) {
        /* we have to allocate some additional memory for possible escaping quotes and backslashes */
        /* Worst case is all character must be escaped and must be quoted */
        int max_len = imp_sth->all_params_len * 2 + DBIc_NUM_PARAMS(imp_sth) * 2 + 1;
        statement = (char*)safemalloc(strlen(imp_sth->statement) + max_len );
        dest = statement;
        src  = imp_sth->statement;
        /* scan statement for ':p1' style placeholders */
        while(*src) {

            if (in_comment) {
	        /* SQL-style and C++-style */ 
	        if ((in_comment == '-' || in_comment == '/') && *src == '\n') {
		    in_comment = '\0';
	        }
                /* C-style */
	        else if (in_comment == '*' && *src == '*' && *(src+1) == '/') {
		    *dest++ = *src++; /* avoids asterisk-slash-asterisk issues */
		    in_comment = '\0';
	        }
	        *dest++ = *src++;
	        continue;
	    }

	    if (in_literal) {
	        /* check if literal ends but keep quotes in literal */
	        if (*src == in_literal && *(src-1) != '\\') {
	            in_literal = 0;
                }
	        *dest++ = *src++;
	        continue;
	    }

	    /* Look for comments: SQL-style or C++-style or C-style	*/
	    if ((*src == '-' && *(src+1) == '-') ||
                (*src == '/' && *(src+1) == '/') ||
	        (*src == '/' && *(src+1) == '*'))
	    {
	        in_comment = *(src+1);
	        /* We know *src & the next char are to be copied, so do */
	        /* it. In the case of C-style comments, it happens to */
	        /* help us avoid slash-asterisk-slash oddities. */
	        *dest++ = *src++;
	        *dest++ = *src++;
	        continue;
	    }

            /* check if no placeholders */
            if (*src != ':' && *src != '?') {
	        if (*src == '\'' || *src == '"') {
		    in_literal = *src;
	        }
	        *dest++ = *src++;
	        continue;
	    }

            /* check for cast operator */
            if (*src == ':' && (*(src-1) == ':' || *(src+1) == ':')) {
	        *dest++ = *src++;
	        continue;
	    }


            i = 0;
            namebuf[i++] = *src++; /* ':' */
            namebuf[i++] = *src++; /* 'p' */

            while (isDIGIT(*src) && i < (sizeof(namebuf)-1) ) {
                namebuf[i++] = *src++;
            }
            if ( i == (sizeof(namebuf) - 1)) {
                pg_error(sth, -1, "namebuf buffer overrun\n");
                return -2;
            }
            namebuf[i] = '\0';
            svp = hv_fetch(imp_sth->all_params_hv, namebuf, i, 0);
            if (svp == NULL) {
                pg_error(sth, -1, "parameter unknown\n");
                return -2;
            }
            /* get attribute */
            phs = (phs_t*)(void*)SvPVX(*svp);
            /* replace undef with NULL */
            if(!SvOK(phs->sv)) {
                val = "NULL";
                len = 4;
            } else {
                val = SvPV(phs->sv, len);
            }
            /* quote string attribute */
            if(!SvNIOK(phs->sv) && SvOK(phs->sv) && phs->ftype > 1000) { /* avoid quoting NULL, tpf: bind_param as numeric  */
	        *dest++ = '\''; 
            }
            while (len--) {
                if (imp_dbh->pg_auto_escape) {
		    /* escape quote */
                    if (*val == '\'') {
                        *dest++ = '\'';
                    }
	            /* escape backslash except for octal presentation */
                    if (*val == '\\' && !(isdigit(*(val+1)) && isdigit(*(val+2)) && isdigit(*(val+3))) ) {
                        *dest++ = '\\';
                    }
                }
                /* copy attribute to statement */
                *dest++ = *val++;
            }
            /* quote string attribute */
            if(!SvNIOK(phs->sv) && SvOK(phs->sv) && phs->ftype > 1000) { /* avoid quoting NULL,  tpf: bind_param as numeric */
                *dest++ = '\''; 
            }
        }
        *dest = '\0';
    }

    if (dbis->debug >= 2) { fprintf(DBILOGFP, "dbd_st_execute: statement = >%s<\n", statement); }

    /* clear old result (if any) */
    if (imp_sth->result) {
        PQclear(imp_sth->result);
    }

    /* execute statement */
    imp_sth->result = PQexec(imp_dbh->conn, statement);

    /* free statement string in case of input parameters */
    if ((int)DBIc_NUM_PARAMS(imp_sth) > 0) {
        Safefree(statement);
    }

    /* check status */
    status    = imp_sth->result ? PQresultStatus(imp_sth->result)      : -1;
    cmdStatus = imp_sth->result ? (char *)PQcmdStatus(imp_sth->result) : "";
    cmdTuples = imp_sth->result ? (char *)PQcmdTuples(imp_sth->result) : "";

    if (PGRES_TUPLES_OK == status) {
        /* select statement */
        num_fields = PQnfields(imp_sth->result);
        imp_sth->cur_tuple = 0;
        DBIc_NUM_FIELDS(imp_sth) = num_fields;
        DBIc_ACTIVE_on(imp_sth);
        ret = PQntuples(imp_sth->result);
    } else if (PGRES_COMMAND_OK == status) {
        /* non-select statement */
        if (! strncmp(cmdStatus, "DELETE", 6) || ! strncmp(cmdStatus, "INSERT", 6) || ! strncmp(cmdStatus, "UPDATE", 6)) {
            ret = atoi(cmdTuples);
        } else {
            ret = -1;
        }
    } else if (PGRES_COPY_OUT == status || PGRES_COPY_IN == status) {
      /* Copy Out/In data transfer in progress */
        ret = -1;
    } else {
        pg_error(sth, status, PQerrorMessage(imp_dbh->conn));
        ret = -2;
    }

    /* store the number of affected rows */
    imp_sth->rows = ret;

    return ret;
}


AV *
dbd_st_fetch (sth, imp_sth)
    SV *sth;
    imp_sth_t *imp_sth;
{
    int num_fields;
    int i;
    AV *av;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_st_fetch\n"); }

    /* Check that execute() was executed sucessfully */
    if ( !DBIc_ACTIVE(imp_sth) ) {
        pg_error(sth, 1, "no statement executing\n");
        return Nullav;
    }

    if ( imp_sth->cur_tuple == PQntuples(imp_sth->result) ) {
        imp_sth->cur_tuple = 0;
        return Nullav; /* we reached the last tuple */
    }

    av = DBIS->get_fbav(imp_sth);
    num_fields = AvFILL(av)+1;

    for(i = 0; i < num_fields; ++i) {

        SV *sv  = AvARRAY(av)[i];
        if (PQgetisnull(imp_sth->result, imp_sth->cur_tuple, i)) {
            sv_setsv(sv, &sv_undef);
        } else {
            char *val = (char*)PQgetvalue(imp_sth->result, imp_sth->cur_tuple, i);
            int  type = PQftype(imp_sth->result, i); /* hopefully these hard coded values will not change */
            if (16 == type) {
               *val = (*val == 'f') ? '0' : '1'; /* bool: translate postgres into perl */
            }
            if (1042 == type && DBIc_has(imp_sth,DBIcf_ChopBlanks)) {
                int len   = strlen(val);
                char *str = val;
                while((len > 0) && (str[len-1] == ' ')) {
                    len--;
                }
                val[len] = '\0';
            }
            sv_setpv(sv, val);
        }
    }

    imp_sth->cur_tuple += 1;

    return av;
}


int
dbd_st_blob_read (sth, imp_sth, lobjId, offset, len, destrv, destoffset)
    SV *sth;
    imp_sth_t *imp_sth;
    int lobjId;
    long offset;
    long len;
    SV *destrv;
    long destoffset;
{
    D_imp_dbh_from_sth;
    int ret, lobj_fd, nbytes, nread;
    PGresult* result;
    ExecStatusType status;
    SV *bufsv;
    char *tmp;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_st_blob_read\n"); }
    /* safety check */
    if (lobjId <= 0) {
        pg_error(sth, -1, "dbd_st_blob_read: lobjId <= 0");
        return 0;
    }
    if (offset < 0) {
        pg_error(sth, -1, "dbd_st_blob_read: offset < 0");
        return 0;
    }
    if (len < 0) {
        pg_error(sth, -1, "dbd_st_blob_read: len < 0");
        return 0;
    }
    if (! SvROK(destrv)) {
        pg_error(sth, -1, "dbd_st_blob_read: destrv not a reference");
        return 0;
    }
    if (destoffset < 0) {
        pg_error(sth, -1, "dbd_st_blob_read: destoffset < 0");
        return 0;
    }

    /* dereference destination and ensure it's writable string */
    bufsv = SvRV(destrv);
    if (! destoffset) {
        sv_setpvn(bufsv, "", 0);
    }

    /* execute begin
    result = PQexec(imp_dbh->conn, "begin");
    status = result ? PQresultStatus(result) : -1;
    PQclear(result);
    if (status != PGRES_COMMAND_OK) {
        pg_error(sth, status, PQerrorMessage(imp_dbh->conn));
        return 0;
    }
    */

    /* open large object */
    lobj_fd = lo_open(imp_dbh->conn, lobjId, INV_READ);
    if (lobj_fd < 0) {
        pg_error(sth, -1, PQerrorMessage(imp_dbh->conn));
        return 0;
    }

    /* seek on large object */
    if (offset > 0) {
        ret = lo_lseek(imp_dbh->conn, lobj_fd, offset, SEEK_SET);
        if (ret < 0) {
            pg_error(sth, -1, PQerrorMessage(imp_dbh->conn));
            return 0;
        }
    }

    /* read from large object */
    nread = 0;
    SvGROW(bufsv, destoffset + nread + BUFSIZ + 1);
    tmp = (SvPVX(bufsv)) + destoffset + nread;
    while ((nbytes = lo_read(imp_dbh->conn, lobj_fd, tmp, BUFSIZ)) > 0) {
        nread += nbytes;
        tmp = (SvPVX(bufsv)) + destoffset + nread;
        /* break if user wants only a specified chunk */
        if (len > 0 && nread > len) {
            nread = len;
            break;
        }
        SvGROW(bufsv, destoffset + nread + BUFSIZ + 1);
    }

    /* terminate string */
    SvCUR_set(bufsv, destoffset + nread);
    *SvEND(bufsv) = '\0';

    /* close large object */
    ret = lo_close(imp_dbh->conn, lobj_fd);
    if (ret < 0) {
        pg_error(sth, -1, PQerrorMessage(imp_dbh->conn));
        return 0;
    }

    /* execute end 
    result = PQexec(imp_dbh->conn, "end");
    status = result ? PQresultStatus(result) : -1;
    PQclear(result);
    if (status != PGRES_COMMAND_OK) {
        pg_error(sth, status, PQerrorMessage(imp_dbh->conn));
        return 0;
    }
    */

    return nread;
}


int
dbd_st_rows (sth, imp_sth)
    SV *sth;
    imp_sth_t *imp_sth;
{
    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_st_rows\n"); }

    return imp_sth->rows;
}


int
dbd_st_finish (sth, imp_sth)
    SV *sth;
    imp_sth_t *imp_sth;
{
    dTHR;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_st_finish\n"); }

    if (DBIc_ACTIVE(imp_sth) && imp_sth->result) {
        PQclear(imp_sth->result);
        imp_sth->result = 0;
        imp_sth->rows   = 0;
    }

    DBIc_ACTIVE_off(imp_sth);
    return 1;
}


void
dbd_st_destroy (sth, imp_sth)
    SV *sth;
    imp_sth_t *imp_sth;
{
    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_st_destroy\n"); }

    /* Free off contents of imp_sth */

    Safefree(imp_sth->statement);
    if (imp_sth->result) {
        PQclear(imp_sth->result);
        imp_sth->result = 0;
    }

    if (imp_sth->out_params_av)
	sv_free((SV*)imp_sth->out_params_av);

    if (imp_sth->all_params_hv) {
        HV *hv = imp_sth->all_params_hv;
        SV *sv;
        char *key;
        I32 retlen;
        hv_iterinit(hv);
        while( (sv = hv_iternextsv(hv, &key, &retlen)) != NULL ) {
            if (sv != &sv_undef) {
                phs_t *phs_tpl = (phs_t*)(void*)SvPVX(sv);
                sv_free(phs_tpl->sv);
            }
        }
        sv_free((SV*)imp_sth->all_params_hv);
    }

    DBIc_IMPSET_off(imp_sth); /* let DBI know we've done it */
}


int
dbd_st_STORE_attrib (sth, imp_sth, keysv, valuesv)
    SV *sth;
    imp_sth_t *imp_sth;
    SV *keysv;
    SV *valuesv;
{
    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_st_STORE\n"); }

    return FALSE;
}


SV *
dbd_st_FETCH_attrib (sth, imp_sth, keysv)
    SV *sth;
    imp_sth_t *imp_sth;
    SV *keysv;
{
    STRLEN kl;
    char *key = SvPV(keysv,kl);
    int i;
    SV *retsv = Nullsv;

    if (dbis->debug >= 1) { fprintf(DBILOGFP, "dbd_st_FETCH\n"); }

    if (! imp_sth->result) {
        return Nullsv;
    }

    i = DBIc_NUM_FIELDS(imp_sth);

    if (kl == 4 && strEQ(key, "NAME")) {
        AV *av = newAV();
        retsv = newRV(sv_2mortal((SV*)av));
	while(--i >= 0) {
            av_store(av, i, newSVpv(PQfname(imp_sth->result, i),0));
        }
    } else if ( kl== 4 && strEQ(key, "TYPE")) {
        AV *av = newAV();
        retsv = newRV(sv_2mortal((SV*)av));
	while(--i >= 0) {
            av_store(av, i, newSViv(PQftype(imp_sth->result, i)));
        }
    } else if (kl==9 && strEQ(key, "PRECISION")) {
        AV *av = newAV();
        retsv = newRV(sv_2mortal((SV*)av));
	while(--i >= 0) {
            av_store(av, i, &sv_undef);
        }
    } else if (kl==5 && strEQ(key, "SCALE")) {
        AV *av = newAV();
        retsv = newRV(sv_2mortal((SV*)av));
	while(--i >= 0) {
            av_store(av, i, &sv_undef);
        }
    } else if (kl==8 && strEQ(key, "NULLABLE")) {
        AV *av = newAV();
        retsv = newRV(sv_2mortal((SV*)av));
	while(--i >= 0) {
            av_store(av, i, newSViv(2));
        }
    } else if (kl==10 && strEQ(key, "CursorName")) {
        retsv = &sv_undef;
    } else if (kl==7 && strEQ(key, "pg_size")) {
        AV *av = newAV();
        retsv = newRV(sv_2mortal((SV*)av));
	while(--i >= 0) {
            av_store(av, i, newSViv(PQfsize(imp_sth->result, i)));
        }
    } else if (kl==7 && strEQ(key, "pg_type")) {
        AV *av = newAV();
        char *type_nam;
        retsv = newRV(sv_2mortal((SV*)av));
	while(--i >= 0) {
            switch (PQftype(imp_sth->result, i)) {
            case 16:
                type_nam = "bool";
                break;
            case 17:
                type_nam = "bytea";
                break;
            case 18:
                type_nam = "char";
                break;
            case 19:
                type_nam = "name";
                break;
            case 20:
                type_nam = "int8";
                break;
            case 21:
                type_nam = "int2";
                break;
            case 22:
                type_nam = "int28";
                break;
            case 23:
                type_nam = "int4";
                break;
            case 24:
                type_nam = "regproc";
                break;
            case 25:
                type_nam = "text";
                break;
            case 26:
                type_nam = "oid";
                break;
            case 27:
                type_nam = "tid";
                break;
            case 28:
                type_nam = "xid";
                break;
            case 29:
                type_nam = "cid";
                break;
            case 30:
                type_nam = "oid8";
                break;
            case 32:
                type_nam = "SET";
                break;
            case 210:
                type_nam = "smgr";
                break;
            case 600:
                type_nam = "point";
                break;
            case 601:
                type_nam = "lseg";
                break;
            case 602:
                type_nam = "path";
                break;
            case 603:
                type_nam = "box";
                break;
            case 604:
                type_nam = "polygon";
                break;
            case 605:
                type_nam = "filename";
                break;
            case 628:
                type_nam = "line";
                break;
            case 629:
                type_nam = "_line";
                break;
            case 700:
                type_nam = "float4";
                break;
            case 701:
                type_nam = "float8";
                break;
            case 702:
                type_nam = "abstime";
                break;
            case 703:
                type_nam = "reltime";
                break;
            case 704:
                type_nam = "tinterval";
                break;
            case 705:
                type_nam = "unknown";
                break;
            case 718:
                type_nam = "circle";
                break;
            case 719:
                type_nam = "_circle";
                break;
            case 790:
                type_nam = "money";
                break;
            case 791:
                type_nam = "_money";
                break;
            case 810:
                type_nam = "oidint2";
                break;
            case 910:
                type_nam = "oidint4";
                break;
            case 911:
                type_nam = "oidname";
                break;
            case 1000:
                type_nam = "_bool";
                break;
            case 1001:
                type_nam = "_bytea";
                break;
            case 1002:
                type_nam = "_char";
                break;
            case 1003:
                type_nam = "_name";
                break;
            case 1005:
                type_nam = "_int2";
                break;
            case 1006:
                type_nam = "_int28";
                break;
            case 1007:
                type_nam = "_int4";
                break;
            case 1008:
                type_nam = "_regproc";
                break;
            case 1009:
                type_nam = "_text";
                break;
            case 1028:
                type_nam = "_oid";
                break;
            case 1010:
                type_nam = "_tid";
                break;
            case 1011:
                type_nam = "_xid";
                break;
            case 1012:
                type_nam = "_cid";
                break;
            case 1013:
                type_nam = "_oid8";
                break;
            case 1014:
                type_nam = "_lock";
                break;
            case 1015:
                type_nam = "_stub";
                break;
            case 1016:
                type_nam = "_ref";
                break;
            case 1017:
                type_nam = "_point";
                break;
            case 1018:
                type_nam = "_lseg";
                break;
            case 1019:
                type_nam = "_path";
                break;
            case 1020:
                type_nam = "_box";
                break;
            case 1021:
                type_nam = "_float4";
                break;
            case 1022:
                type_nam = "_float8";
                break;
            case 1023:
                type_nam = "_abstime";
                break;
            case 1024:
                type_nam = "_reltime";
                break;
            case 1025:
                type_nam = "_tinterval";
                break;
            case 1026:
                type_nam = "_filename";
                break;
            case 1027:
                type_nam = "_polygon";
                break;
            case 1033:
                type_nam = "aclitem";
                break;
            case 1034:
                type_nam = "_aclitem";
                break;
            case 1042:
                type_nam = "bpchar";
                break;
            case 1043:
                type_nam = "varchar";
                break;
            case 1082:
                type_nam = "date";
                break;
            case 1083:
                type_nam = "time";
                break;
            case 1182:
                type_nam = "_date";
                break;
            case 1183:
                type_nam = "_time";
                break;
            case 1184:
                type_nam = "datetime";
                break;
            case 1185:
                type_nam = "_datetime";
                break;
            case 1186:
                type_nam = "timespan";
                break;
            case 1187:
                type_nam = "_timespan";
                break;
            case 1296:
                type_nam = "timestamp";
                break;
            }
            av_store(av, i, newSVpv(type_nam, 0));
        }
    } else if (kl==13 && strEQ(key, "pg_oid_status")) {
        retsv = newSVpv((char *)PQoidStatus(imp_sth->result), 0);
    } else if (kl==13 && strEQ(key, "pg_cmd_status")) {
        retsv = newSVpv((char *)PQcmdStatus(imp_sth->result), 0);
    } else {
        return Nullsv;
    }

    return sv_2mortal(retsv);
}


/* end of dbdimp.c */
