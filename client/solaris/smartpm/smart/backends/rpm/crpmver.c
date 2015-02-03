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

/* Ripped from rpm. */
static int
vercmppart(const char *a, const char *b)
{
    char oldch1, oldch2;
    char *str1, *str2;
    char *one, *two;
    int rc;
    int isnum;

    if (!strcmp(a, b)) return 0;

    str1 = alloca(strlen(a) + 1);
    str2 = alloca(strlen(b) + 1);

    strcpy(str1, a);
    strcpy(str2, b);

    one = str1;
    two = str2;

    while (*one && *two) {
        while (*one && !isalnum(*one)) one++;
        while (*two && !isalnum(*two)) two++;

        str1 = one;
        str2 = two;

        if (isdigit(*str1)) {
            while (*str1 && isdigit(*str1)) str1++;
            while (*str2 && isdigit(*str2)) str2++;
            isnum = 1;
        } else {
            while (*str1 && isalpha(*str1)) str1++;
            while (*str2 && isalpha(*str2)) str2++;
            isnum = 0;
        }

        oldch1 = *str1;
        *str1 = '\0';
        oldch2 = *str2;
        *str2 = '\0';

        if (one == str1) return -1;
        if (two == str2) return (isnum ? 1 : -1);

        if (isnum) {
            while (*one == '0') one++;
            while (*two == '0') two++;

            if (strlen(one) > strlen(two)) return 1;
            if (strlen(two) > strlen(one)) return -1;
        }

        rc = strcmp(one, two);
        if (rc) return (rc < 1 ? -1 : 1);

        *str1 = oldch1;
        one = str1;
        *str2 = oldch2;
        two = str2;
    }

    if ((!*one) && (!*two)) return 0;

    if (!*one) return -1; else return 1;
}

static int
vercmpparts(const char *e1, const char *v1, const char *r1,
            const char *e2, const char *v2, const char *r2)
{
    int e1i = 0;
    int e2i = 0;
    int rc;
    if (e1 && *e1) 
        e1i = atoi(e1);
    if (e2 && *e2) 
        e2i = atoi(e2);
    if (e1i > e2i) return 1;
    if (e1i < e2i) return -1;
    rc = vercmppart(v1, v2);
    if (rc)
        return rc;
    else if (!r1 || !r2)
        return 0;
    return vercmppart(r1, r2);
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

static PyObject *
crpmver_splitarch(PyObject *self, PyObject *version)
{
    PyObject *ret, *ver, *arch;
    const char *str, *p;
    int size;
    if (!PyString_Check(version)) {
        PyErr_SetString(PyExc_TypeError, "version string expected");
        return NULL;
    }
    str = PyString_AS_STRING(version);
    size = PyString_GET_SIZE(version);
    p = str+size;
    for (; p != str; p--) {
        if (*p == '@') {
            const char *s = p;
            while (s != str && *s != '-') s--;
            if (s == str) break;
            ret = PyTuple_New(2);
            ver = PyString_FromStringAndSize(str, p-str);
            if (!ver) return NULL;
            arch = PyString_FromStringAndSize(p+1, str+size-p-1);
            if (!arch) return NULL;
            PyTuple_SET_ITEM(ret, 0, ver);
            PyTuple_SET_ITEM(ret, 1, arch);
            return ret;
        } else if (*p == '-') {
            break;
        }
    }
    ret = PyTuple_New(2);
    if (!ret) return NULL;
    Py_INCREF(version);
    Py_INCREF(Py_None);
    PyTuple_SET_ITEM(ret, 0, version);
    PyTuple_SET_ITEM(ret, 1, Py_None);
    return ret;
}

static PyObject *
crpmver_splitrelease(PyObject *self, PyObject *version)
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
crpmver_checkdep(PyObject *self, PyObject *args)
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
crpmver_vercmp(PyObject *self, PyObject *args)
{
    const char *v1, *v2;
    if (!PyArg_ParseTuple(args, "ss", &v1, &v2))
        return NULL;
    return PyInt_FromLong(vercmp(v1, v2));
}

static PyObject *
crpmver_vercmpparts(PyObject *self, PyObject *args)
{
    const char *e1, *v1, *r1, *e2, *v2, *r2;
    if (!PyArg_ParseTuple(args, "ssssss", &e1, &v1, &r1, &e2, &v2, &r2))
        return NULL;
    return PyInt_FromLong(vercmpparts(e1, v1, r1, e2, v2, r2));
}

static PyObject *
crpmver_vercmppart(PyObject *self, PyObject *args)
{
    const char *a, *b;
    if (!PyArg_ParseTuple(args, "ss", &a, &b))
        return NULL;
    return PyInt_FromLong(vercmppart(a, b));
}

static PyMethodDef crpmver_methods[] = {
    {"splitarch", (PyCFunction)crpmver_splitarch, METH_O, NULL},
    {"splitrelease", (PyCFunction)crpmver_splitrelease, METH_O, NULL},
    {"checkdep", (PyCFunction)crpmver_checkdep, METH_VARARGS, NULL},
    {"vercmp", (PyCFunction)crpmver_vercmp, METH_VARARGS, NULL},
    {"vercmpparts", (PyCFunction)crpmver_vercmpparts, METH_VARARGS, NULL},
    {"vercmppart", (PyCFunction)crpmver_vercmppart, METH_VARARGS, NULL},
    {NULL, NULL}
};

DL_EXPORT(void)
initcrpmver(void)
{
    PyObject *m;
    m = Py_InitModule3("crpmver", crpmver_methods, "");
}
