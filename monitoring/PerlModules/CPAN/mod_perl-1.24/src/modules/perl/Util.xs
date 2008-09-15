#include "mod_perl.h"
#include "util_date.h"

#define TIME_NOW time(NULL)
#define DEFAULT_TIME_FORMAT "%a, %d %b %Y %H:%M:%S %Z"

#define parsedate ap_parseHTTPdate
#define util_pool() perl_get_util_pool()

static SV *size_string(size_t size)
{
    SV *sv = newSVpv("    -", 5);
    if (size == (size_t)-1) {
	/**/
    }
    else if (!size) {
	sv_setpv(sv, "   0k");
    }
    else if (size < 1024) {
	sv_setpv(sv, "   1k");
    }
    else if (size < 1048576) {
	sv_setpvf(sv, "%4dk", (size + 512) / 1024);
    }
    else if (size < 103809024) {
	sv_setpvf(sv, "%4.1fM", size / 1048576.0);
    }
    else {
	sv_setpvf(sv, "%4dM", (size + 524288) / 1048576);
    }

    return sv;
}

static SV *my_escape_html(char *s)
{
    int i, j;
    SV *x;

    /* first, count the number of extra characters */
    for (i = 0, j = 0; s[i] != '\0'; i++)
	if (s[i] == '<' || s[i] == '>')
	    j += 3;
	else if (s[i] == '&')
	    j += 4;
        else if (s[i] == '"')
	    j += 5;

    if (j == 0)
	return newSVpv(s,i);
    x = newSV(i + j + 1);

    for (i = 0, j = 0; s[i] != '\0'; i++, j++)
	if (s[i] == '<') {
	    memcpy(&SvPVX(x)[j], "&lt;", 4);
	    j += 3;
	}
	else if (s[i] == '>') {
	    memcpy(&SvPVX(x)[j], "&gt;", 4);
	    j += 3;
	}
	else if (s[i] == '&') {
	    memcpy(&SvPVX(x)[j], "&amp;", 5);
	    j += 4;
	}
	else if (s[i] == '"') {
	    memcpy(&SvPVX(x)[j], "&quot;", 6);
	    j += 5;
	}
	else
	    SvPVX(x)[j] = s[i];

    SvPVX(x)[j] = '\0';
    SvCUR_set(x, j);
    SvPOK_on(x);
    return x;
}

#define validate_password(passwd, hash) \
(ap_validate_password(passwd, hash) == NULL)

MODULE = Apache::Util		PACKAGE = Apache::Util

PROTOTYPES: DISABLE

BOOT:
    items = items; /*avoid warning*/

SV *
size_string(size)
    size_t size

char *
escape_uri(segment)
    const char *segment

    CODE:
    RETVAL = ap_os_escape_path(util_pool(), segment, TRUE);

    OUTPUT:
    RETVAL

SV *
escape_html(s)
    char *s

    CODE:
    RETVAL = my_escape_html(s);

    OUTPUT:
    RETVAL

char *
ht_time(t=TIME_NOW, fmt=DEFAULT_TIME_FORMAT, gmt=TRUE)
    time_t t
    const char *fmt
    int gmt

    CODE:
    RETVAL = ap_ht_time(util_pool(), t, fmt, gmt);

    OUTPUT:
    RETVAL

time_t
parsedate(date)
    const char *date

int
validate_password(passwd, hash)
    const char *passwd
    const char *hash

