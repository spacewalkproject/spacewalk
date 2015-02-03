/*

 Copyright (c) 2004 Conectiva, Inc.

 Written by Gustavo Niemeyer <niemeyer@conectiva.com>

 This file is part of Smart Package Manager.

 Smart Package Manager is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License as published
 by the Free Software Foundation; either version 2 of the License, or (at
 your option) any later version.

 Smart Package Manager is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Smart Package Manager; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/

#include <Python.h>
#include <structmember.h>

#include <assert.h>
#include <string.h>
#include <stdlib.h>

static int ORDER[256];

static void
_buildORDER(void)
{
    int c;
    for (c = 0; c != 256; c++) {
        if (c == '~')
            ORDER[c] = -1;
        else if (isdigit(c))
            ORDER[c] = 0;
        else if (isalpha(c))
            ORDER[c] = c;
        else
            ORDER[c] = c+256;
    }
}


static int
vercmppart(const char *a, const char *b)
{
    char *str1, *str2;
    char *one, *two;

    if ((!a || !*a) && (!b || !*b))
        return 0;

    if (!a || !*a) {
        if (*b == '~')
            return 1;
        return -1;
    }
    if (!b || !*b) {
        if (*a == '~')
            return -1;
        return 1;
    }

    if (!strcmp(a, b)) return 0;

    str1 = alloca(strlen(a) + 1);
    str2 = alloca(strlen(b) + 1);

    strcpy(str1, a);
    strcpy(str2, b);

    one = str1;
    two = str2;

    while (*one && *two) {
        int first_diff = 0;
        while (*one && *two && (!isdigit(*one) || !isdigit(*two))) {
            int vc = ORDER[(int)*one];
            int rc = ORDER[(int)*two];
            if (vc > rc)
                return 1;
            if (vc < rc)
                return -1;
            one += 1;
            two += 1;
        }
        while (*one == '0') one++;
        while (*two == '0') two++;
        while (*one && *two && isdigit(*one) && isdigit(*two)) {
            if (!first_diff)
                first_diff = (*one - *two);
            one += 1;
            two += 1;
        }
        if (*one && isdigit(*one))
            return 1;
        if (*two && isdigit(*two))
            return -1;
        if (first_diff > 0)
            return 1;
        if (first_diff < 0)
            return -1;
    }
    
    if (!*one && !*two)
        return 0;

    if (!*one) {
        if (*two == '~')
            return 1;
        return -1;
    }
    if (!*two) {
        if (*one == '~')
            return -1;
        return 1;
    }

    return 1;
}

static int
vercmpparts(const char *e1, const char *v1, const char *r1,
            const char *e2, const char *v2, const char *r2)
{
    int rc;
    rc = vercmppart(e1, e2);
    if (!rc) {
        rc = vercmppart(v1, v2);
        if (!rc)
            rc = vercmppart(r1, r2);
    }
    return rc;
}

static void
splitversion(char *buf, char **e, char **v, char **r)
{
    char *s = strrchr(buf, '-');
    if (s) {
        *s++ = '\0';
        *r = s;
    } else {
        *r = NULL;
    }
    s = buf;
    while (isdigit(*s)) s++;
    if (*s == ':') {
        *e = buf;
        *s++ = '\0';
        *v = s;
        if (**e == '\0') *e = "0";
    } else {
        *e = "0";
        *v = buf;
    }
}

static int
vercmp(const char *s1, const char *s2)
{
    char *e1, *v1, *r1, *e2, *v2, *r2;
    char b1[64];
    char b2[64];
    strncpy(b1, s1, sizeof(b1)-1);
    strncpy(b2, s2, sizeof(b2)-1);
    b1[sizeof(b1)-1] = '\0';
    b2[sizeof(b1)-1] = '\0';
    splitversion(b1, &e1, &v1, &r1);
    splitversion(b2, &e2, &v2, &r2);
    return vercmpparts(e1, v1, r1, e2, v2, r2);
}

static void
parserelation(char *buf, char **n, char **r, char **v)
{
    *r = *v = NULL;
    while (*buf == ' ') buf++;
    *n = buf;
    while (*buf && *buf != ' ' && *buf != '(') buf++;
    if (buf == *n) {
        n = NULL;
        return;
    }
    if (!*buf) return;
    if (*buf == '(') {
        *buf++ = '\0';
    } else {
        *buf++ = '\0';
        while (*buf && *buf != '(') buf++;
    }
    if (!*buf) return;
    while (*buf && *buf != '<' && *buf != '=' && *buf != '>') buf++;
    if (!*buf) return;
    switch (*buf) {
        case '<':
            if (*(buf+1) == '<')
                *r = "<";
            else
                *r = "<=";
            break;
        case '>':
            if (*(buf+1) == '>')
                *r = ">";
            else
                *r = ">=";
            break;
        case '=':
            *r = "=";
            break;
    }
    while (*buf == ' ' || *buf == '<' || *buf == '=' || *buf == '>') buf++;
    *v = buf;
    while (*buf && *buf != ' ' && *buf != ')') buf++;
    *buf = '\0';
    if (!*v) *r = *v = NULL;
}

static PyObject *
cdebver_splitrelease(PyObject *self, PyObject *version)
{
    PyObject *ret, *ver, *rel;
    const char *str, *p;
    int size;
    if (!PyString_Check(version)) {
        PyErr_SetString(PyExc_TypeError, "version string expected");
        return NULL;
    }
    str = PyString_AS_STRING(version);
    size = PyString_GET_SIZE(version);
    p = str+size;
    while (p != str && *p != '-') p--;
    if (p == str) {
        Py_INCREF(version);
        Py_INCREF(Py_None);
        ver = version;
        rel = Py_None;
    } else {
        ver = PyString_FromStringAndSize(str, p-str);
        if (!ver) return NULL;
        rel = PyString_FromStringAndSize(p+1, str+size-p-1);
        if (!rel) return NULL;
    }
    ret = PyTuple_New(2);
    if (!ret) return NULL;
    PyTuple_SET_ITEM(ret, 0, ver);
    PyTuple_SET_ITEM(ret, 1, rel);
    return ret;
}


static PyObject *
cdebver_parserelation(PyObject *self, PyObject *version)
{
    PyObject *ret, *on, *or, *ov;
    char buf[64];
    char *n, *r, *v;

    if (!PyString_Check(version)) {
        PyErr_SetString(PyExc_TypeError, "version string expected");
        return NULL;
    }

    strncpy(buf, PyString_AS_STRING(version), sizeof(buf)-1);
    buf[sizeof(buf)-1] = '\0';

    parserelation(buf, &n, &r, &v);

    on = or = ov = NULL;

    if (!n) n = "";
    on = PyString_FromString(n);
    if (!on) goto error;

    if (r) {
        or = PyString_FromString(r);
        if (!or) goto error;
    } else {
        Py_INCREF(Py_None);
        or = Py_None;
    }
    if (v) {
        ov = PyString_FromString(v);
        if (!ov) goto error;
    } else {
        Py_INCREF(Py_None);
        ov = Py_None;
    }

    ret = PyTuple_New(3);
    if (!ret) goto error;
    PyTuple_SET_ITEM(ret, 0, on);
    PyTuple_SET_ITEM(ret, 1, or);
    PyTuple_SET_ITEM(ret, 2, ov);

    return ret;

error:
    Py_XDECREF(on);
    Py_XDECREF(or);
    Py_XDECREF(ov);
    return NULL;
}

static PyObject *
cdebver_parserelations(PyObject *self, PyObject *version)
{
    PyObject *ret, *tup, *lst, *on, *or, *ov;
    char buf[8192];
    char *n, *r, *v;
    char *lastpos, *pos;
    int groupsize, resetgroup;

    if (!PyString_Check(version)) {
        PyErr_SetString(PyExc_TypeError, "version string expected");
        return NULL;
    }

    strncpy(buf, PyString_AS_STRING(version), sizeof(buf)-1);
    buf[sizeof(buf)-1] = '\0';

    pos = buf;

    ret = PyList_New(0);
    if (!ret) return NULL;

    resetgroup = 0;
    groupsize = 0;
    for (;;) {

        if (resetgroup)
            groupsize = 0;

        lastpos = pos;
        while (*pos && *pos != ',' && *pos != '|') pos++;
        if (pos == lastpos) break;

        resetgroup = !(*pos == '|');
        groupsize += 1;
        if (*pos) *pos++ = '\0';

        parserelation(lastpos, &n, &r, &v);
        if (!n) {

            if (groupsize)
                groupsize -= 1;

        } else {

            on = or = ov = tup = NULL;

            on = PyString_FromString(n);
            if (!on) goto error;

            if (r) {
                or = PyString_FromString(r);
                if (!or) goto error;
            } else {
                Py_INCREF(Py_None);
                or = Py_None;
            }

            if (v) {
                ov = PyString_FromString(v);
                if (!ov) goto error;
            } else {
                Py_INCREF(Py_None);
                ov = Py_None;
            }

            tup = PyTuple_New(3);
            if (!tup) goto error;
            PyTuple_SET_ITEM(tup, 0, on);
            PyTuple_SET_ITEM(tup, 1, or);
            PyTuple_SET_ITEM(tup, 2, ov);

            if (groupsize < 2) {
                PyList_Append(ret, tup);
                Py_DECREF(tup);
            } else if (groupsize == 2) {
                PyObject *lasttup = PyList_GET_ITEM(ret,
                                                    PyList_GET_SIZE(ret)-1);
                lst = PyList_New(2);
                PyList_SET_ITEM(lst, 0, lasttup);
                PyList_SET_ITEM(lst, 1, tup);
                PyList_SET_ITEM(ret, PyList_GET_SIZE(ret)-1, lst);
            } else {
                PyObject *lst = PyList_GET_ITEM(ret, PyList_GET_SIZE(ret)-1);
                PyList_Append(lst, tup);
                Py_DECREF(tup);
            }
        }
    }

    return ret;

error:
    Py_XDECREF(on);
    Py_XDECREF(ov);
    Py_XDECREF(or);
    Py_XDECREF(tup);
    Py_XDECREF(ret);
    return NULL;
}

static PyObject *
cdebver_checkdep(PyObject *self, PyObject *args)
{
    const char *v1, *rel, *v2;
    PyObject *ret;
    int rc;
    if (!PyArg_ParseTuple(args, "sss", &v1, &rel, &v2))
        return NULL;
    rc = vercmp(v1, v2);
    if (rc == 0)
        ret = (strchr(rel, '=') != NULL) ? Py_True : Py_False;
    else if (rc < 0)
        ret = (rel[0] == '<') ? Py_True : Py_False;
    else
        ret = (rel[0] == '>') ? Py_True : Py_False;
    Py_INCREF(ret);
    return ret;
}

static PyObject *
cdebver_vercmp(PyObject *self, PyObject *args)
{
    const char *v1, *v2;
    if (!PyArg_ParseTuple(args, "ss", &v1, &v2))
        return NULL;
    return PyInt_FromLong(vercmp(v1, v2));
}

static PyObject *
cdebver_vercmpparts(PyObject *self, PyObject *args)
{
    const char *e1, *v1, *r1, *e2, *v2, *r2;
    if (!PyArg_ParseTuple(args, "ssssss", &e1, &v1, &r1, &e2, &v2, &r2))
        return NULL;
    return PyInt_FromLong(vercmpparts(e1, v1, r1, e2, v2, r2));
}

static PyObject *
cdebver_vercmppart(PyObject *self, PyObject *args)
{
    const char *a, *b;
    if (!PyArg_ParseTuple(args, "ss", &a, &b))
        return NULL;
    return PyInt_FromLong(vercmppart(a, b));
}

static PyMethodDef cdebver_methods[] = {
    {"splitrelease", (PyCFunction)cdebver_splitrelease, METH_O, NULL},
    {"parserelation", (PyCFunction)cdebver_parserelation, METH_O, NULL},
    {"parserelations", (PyCFunction)cdebver_parserelations, METH_O, NULL},
    {"checkdep", (PyCFunction)cdebver_checkdep, METH_VARARGS, NULL},
    {"vercmp", (PyCFunction)cdebver_vercmp, METH_VARARGS, NULL},
    {"vercmpparts", (PyCFunction)cdebver_vercmpparts, METH_VARARGS, NULL},
    {"vercmppart", (PyCFunction)cdebver_vercmppart, METH_VARARGS, NULL},
    {NULL, NULL}
};

DL_EXPORT(void)
initcdebver(void)
{
    PyObject *m;
    m = Py_InitModule3("cdebver", cdebver_methods, "");
    _buildORDER();
}
