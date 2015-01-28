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

#include <string.h>

#ifndef Py_RETURN_NONE
#define Py_RETURN_NONE do {Py_INCREF(Py_None); return Py_None;} while (0)
#endif

#define CALLMETHOD(obj, ...) \
    do { \
        PyObject *res = \
            PyObject_CallMethod((PyObject *)(obj), __VA_ARGS__); \
        if (!res) return NULL; \
        Py_DECREF(res); \
    } while (0)

#define LIST_CLEAR(x) \
    PyList_SetSlice((x), 0, PyList_GET_SIZE(x), (PyObject *)NULL);

#define STR(obj) PyString_AS_STRING(obj)

staticforward PyTypeObject Package_Type;
staticforward PyTypeObject Provides_Type;
staticforward PyTypeObject Depends_Type;
staticforward PyTypeObject Loader_Type;
staticforward PyTypeObject Cache_Type;

static PyObject *StateVersionError;

typedef struct {
    PyObject_HEAD
    PyObject *name;
    PyObject *version;
    PyObject *provides;
    PyObject *requires;
    PyObject *upgrades;
    PyObject *conflicts;
    PyObject *installed;
    PyObject *essential;
    PyObject *priority;
    PyObject *loaders;
} PackageObject;

typedef struct {
    PyObject_HEAD
    PyObject *name;
    PyObject *version;
    PyObject *packages;
    PyObject *requiredby;
    PyObject *upgradedby;
    PyObject *conflictedby;
} ProvidesObject;

typedef struct {
    PyObject_HEAD
    PyObject *name;
    PyObject *relation;
    PyObject *version;
    PyObject *packages;
    PyObject *providedby;
} DependsObject;

typedef struct {
    PyObject_HEAD
    PyObject *_packages;
    PyObject *_channel;
    PyObject *_cache;
    PyObject *_installed;
} LoaderObject;

typedef struct {
    PyObject_HEAD
    PyObject *_loaders;
    PyObject *_packages;
    PyObject *_provides;
    PyObject *_requires;
    PyObject *_upgrades;
    PyObject *_conflicts;
    PyObject *_objmap;
} CacheObject;

/*
static PyObject *
getSysConf(void)
{
    static PyObject *sysconf = NULL;
    if (sysconf == NULL) {
        PyObject *module = PyImport_ImportModule("smart");
        if (module) {
            sysconf = PyObject_GetAttrString(module, "sysconf");
            Py_DECREF(module);
        }
    }
    return sysconf;
}
*/

static PyObject *
getPkgConf(void)
{
    static PyObject *pkgconf = NULL;
    if (pkgconf == NULL) {
        PyObject *module = PyImport_ImportModule("smart");
        if (module) {
            pkgconf = PyObject_GetAttrString(module, "pkgconf");
            Py_DECREF(module);
        }
    }
    return pkgconf;
}

static PyObject *
getIface(void)
{
    static PyObject *iface = NULL;
    if (iface == NULL) {
        PyObject *module = PyImport_ImportModule("smart");
        if (module) {
            iface = PyObject_GetAttrString(module, "iface");
            Py_DECREF(module);
        }
    }
    return iface;
}

static PyObject *
getGlobDistance(void)
{
    static PyObject *globdistance = NULL;
    if (globdistance == NULL) {
        PyObject *module = PyImport_ImportModule("smart.util.strtools");
        if (module) {
            globdistance = PyObject_GetAttrString(module, "globdistance");
            Py_DECREF(module);
        }
    }
    return globdistance;
}

static PyObject *
_(const char *str)
{
    static PyObject *_ = NULL;
    if (_ == NULL) {
        PyObject *module = PyImport_ImportModule("smart");
        if (module) {
            _ = PyObject_GetAttrString(module, "_");
            Py_DECREF(module);
            if (_ == NULL) {
                Py_INCREF(Py_None);
                return Py_None;
            }
        }
    }
    return PyObject_CallFunction(_, "s", str);
}

static int
Package_init(PackageObject *self, PyObject *args)
{
    if (!PyArg_ParseTuple(args, "O!O!", &PyString_Type, &self->name,
                          &PyString_Type, &self->version))
        return -1;
    Py_INCREF(self->name);
    Py_INCREF(self->version);
    self->provides = PyTuple_New(0);
    self->requires = PyTuple_New(0);
    self->upgrades = PyTuple_New(0);
    self->conflicts = PyTuple_New(0);
    Py_INCREF(Py_False);
    self->installed = Py_False;
    Py_INCREF(Py_False);
    self->essential = Py_False;
    self->priority = PyInt_FromLong(0);
    self->loaders = PyDict_New();
    return 0;
}

static void
Package_dealloc(PackageObject *self)
{
    Py_XDECREF(self->name);
    Py_XDECREF(self->version);
    Py_XDECREF(self->provides);
    Py_XDECREF(self->requires);
    Py_XDECREF(self->upgrades);
    Py_XDECREF(self->conflicts);
    Py_XDECREF(self->installed);
    Py_XDECREF(self->essential);
    Py_XDECREF(self->priority);
    Py_XDECREF(self->loaders);
    self->ob_type->tp_free((PyObject *)self);
}

static PyObject *
Package_str(PackageObject *self)
{
    if (!PyString_Check(self->name) || !PyString_Check(self->version)) {
        PyErr_SetString(PyExc_TypeError,
                        "Package name or version is not string");
        return NULL;
    }
    return PyString_FromFormat("%s-%s", STR(self->name), STR(self->version));
}

static PyObject *
Package_richcompare(PackageObject *self, PackageObject *other, int op)
{
    int rc = -1;
    if (op == Py_EQ) {
        return PyBool_FromLong(self == other);
    } else if (op != Py_LT) {
        Py_INCREF(Py_NotImplemented);
        return Py_NotImplemented;
    }
    if (PyObject_IsInstance((PyObject *)other, (PyObject *)&Package_Type)) {
        const char *self_name, *other_name;
        if (!PyString_Check(self->name) || !PyString_Check(other->name)) {
            PyErr_SetString(PyExc_TypeError,
                            "Package name is not string");
            return NULL;
        }
        self_name = STR(self->name);
        other_name = STR(other->name);
        rc = strcmp(self_name, other_name);
        if (rc == 0) {
            const char *self_version, *other_version;
            if (!PyString_Check(self->version) ||
                !PyString_Check(other->version)) {
                PyErr_SetString(PyExc_TypeError,
                                "Package version is not string");
                return NULL;
            }
            self_version = STR(self->version);
            other_version = STR(other->version);
            rc = strcmp(self_version, other_version);
        }
    }
    if (rc == -1) {
        Py_INCREF(Py_True);
        return Py_True;
    } else {
        Py_INCREF(Py_False);
        return Py_False;
    }
}

static PyObject *
Package_getInitArgs(PackageObject *self, PyObject *args)
{
    PyObject *ret = PyTuple_New(3);
    if (!ret) return NULL;
    PyTuple_SET_ITEM(ret, 0,
                     PyObject_GetAttrString((PyObject *)self, "__class__"));
    Py_INCREF(self->name);
    Py_INCREF(self->version);
    PyTuple_SET_ITEM(ret, 1, self->name);
    PyTuple_SET_ITEM(ret, 2, self->version);
    return ret;
}

static PyObject *
Package_equals(PackageObject *self, PackageObject *other)
{
    int i, j, ilen, jlen;
    PyObject *ret = Py_True;

    if (!PyObject_IsInstance((PyObject *)other, (PyObject *)&Package_Type)) {
        PyErr_SetString(PyExc_TypeError, "Package instance expected");
        return NULL;
    }

    if (strcmp(STR(self->name), STR(other->name)) != 0 ||
        strcmp(STR(self->version), STR(other->version)) != 0 ||
        PyList_GET_SIZE(self->upgrades) != PyList_GET_SIZE(other->upgrades) ||
        PyList_GET_SIZE(self->conflicts) != PyList_GET_SIZE(other->conflicts)) {
        ret = Py_False;
        goto exit;
    }

    ilen = PyList_GET_SIZE(self->upgrades);
    jlen = PyList_GET_SIZE(other->upgrades);
    for (i = 0; i != ilen; i++) {
        PyObject *item = PyList_GET_ITEM(self->upgrades, i);
        for (j = 0; j != jlen; j++)
            if (item == PyList_GET_ITEM(other->upgrades, j))
                break;
        if (j == jlen) {
            ret = Py_False;
            goto exit;
        }
    }

    ilen = PyList_GET_SIZE(self->conflicts);
    jlen = PyList_GET_SIZE(other->conflicts);
    for (i = 0; i != ilen; i++) {
        PyObject *item = PyList_GET_ITEM(self->conflicts, i);
        for (j = 0; j != jlen; j++)
            if (item == PyList_GET_ITEM(other->conflicts, j))
                break;
        if (j == jlen) {
            ret = Py_False;
            goto exit;
        }
    }

    ilen = 0;
    jlen = 0;
    for (i = 0; i != PyList_GET_SIZE(self->provides); i++) {
        PyObject *item = PyList_GET_ITEM(self->provides, i);
        if (!PyObject_IsInstance(item, (PyObject *)&Provides_Type)) {
            PyErr_SetString(PyExc_TypeError, "Provides instance expected");
            return NULL;
        }
        if (STR(((ProvidesObject *)item)->name)[0] != '/')
            ilen += 1;
    }
    for (j = 0; j != PyList_GET_SIZE(other->provides); j++) {
        PyObject *item = PyList_GET_ITEM(other->provides, j);
        if (!PyObject_IsInstance(item, (PyObject *)&Provides_Type)) {
            PyErr_SetString(PyExc_TypeError, "Provides instance expected");
            return NULL;
        }
        if (STR(((ProvidesObject *)item)->name)[0] != '/')
            jlen += 1;
    }
    if (ilen != jlen) {
        ret = Py_False;
        goto exit;
    }

    ilen = PyList_GET_SIZE(self->provides);
    jlen = PyList_GET_SIZE(other->provides);
    for (i = 0; i != ilen; i++) {
        PyObject *item = PyList_GET_ITEM(self->provides, i);
        if (STR(((ProvidesObject *)item)->name)[0] == '/') {
            for (j = 0; j != jlen; j++)
                if (item == PyList_GET_ITEM(other->provides, j))
                    break;
            if (j == jlen) {
                ret = Py_False;
                goto exit;
            }
        }
    }

    ilen = 0;
    jlen = 0;
    for (i = 0; i != PyList_GET_SIZE(self->requires); i++) {
        PyObject *item = PyList_GET_ITEM(self->requires, i);
        if (!PyObject_IsInstance(item, (PyObject *)&Depends_Type)) {
            PyErr_SetString(PyExc_TypeError, "Depends instance expected");
            return NULL;
        }
        if (STR(((DependsObject *)item)->name)[0] != '/')
            ilen += 1;
    }
    for (j = 0; j != PyList_GET_SIZE(other->requires); j++) {
        PyObject *item = PyList_GET_ITEM(other->requires, j);
        if (!PyObject_IsInstance(item, (PyObject *)&Depends_Type)) {
            PyErr_SetString(PyExc_TypeError, "Depends instance expected");
            return NULL;
        }
        if (STR(((DependsObject *)item)->name)[0] != '/')
            jlen += 1;
    }
    if (ilen != jlen) {
        ret = Py_False;
        goto exit;
    }

    ilen = PyList_GET_SIZE(self->requires);
    jlen = PyList_GET_SIZE(other->requires);
    for (i = 0; i != ilen; i++) {
        PyObject *item = PyList_GET_ITEM(self->requires, i);
        if (STR(((DependsObject *)item)->name)[0] != '/') {
            for (j = 0; j != jlen; j++)
                if (item == PyList_GET_ITEM(other->requires, j))
                    break;
            if (j == jlen) {
                ret = Py_False;
                goto exit;
            }
        }
    }

exit:
    Py_INCREF(ret);
    return ret;
}

static PyObject *
Package_coexists(PackageObject *self, PackageObject *other)
{
    PyObject *ret;

    if (!PyObject_IsInstance((PyObject *)other, (PyObject *)&Package_Type)) {
        PyErr_SetString(PyExc_TypeError, "Package instance expected");
        return NULL;
    }

    if (!PyString_Check(self->version) || !PyString_Check(other->version)) {
        PyErr_SetString(PyExc_TypeError, "Package version is not string");
        return NULL;
    }

    if (strcmp(STR(self->version), STR(other->version)) == 0)
        ret = Py_False;
    else
        ret = Py_True;

    Py_INCREF(ret);
    return ret;
}

static PyObject *
Package_matches(PackageObject *self, PyObject *args)
{
    Py_INCREF(Py_False);
    return Py_False;
}

static PyObject *
Package_search(PackageObject *self, PyObject *searcher)
{
    PyObject *globdistance = getGlobDistance();
    PyObject *tmp, *lst, *tup, *res;
    PyObject *ratio = NULL;
    int i;

    if (globdistance == NULL)
        return NULL;

    lst = PyObject_GetAttrString(searcher, "nameversion");
    if (lst == NULL || !PyList_Check(lst)) {
        PyErr_SetString(PyExc_TypeError, "Invalid nameversion attribute");
        return NULL;
    }
    for (i = 0; i != PyList_GET_SIZE(lst); i++) {
        tup = PyList_GET_ITEM(lst, i);
        if (PyTuple_GET_SIZE(tup) != 2) {
            PyErr_SetString(PyExc_ValueError, "Invalid nameversion tuple size");
            return NULL;
        }
        res = PyObject_CallFunction(globdistance, "OOO",
                                    PyTuple_GET_ITEM(tup, 0), self->name,
                                    PyTuple_GET_ITEM(tup, 1));
        if (res == NULL)
            return NULL;
        if (PyTuple_GET_SIZE(res) != 2 ||
            !PyFloat_Check(PyTuple_GET_ITEM(res, 1))) {
            PyErr_SetString(PyExc_ValueError, "Invalid globdistance "
                                              "answer size");
            return NULL;
        }
        if (ratio == NULL || PyFloat_AS_DOUBLE(PyTuple_GET_ITEM(res, 1)) >
                             PyFloat_AS_DOUBLE(ratio)) {
            Py_XDECREF(ratio);
            ratio = PyTuple_GET_ITEM(res, 1);
            Py_INCREF(ratio);
        }
        Py_DECREF(res);

        tmp = PyString_FromFormat("%s-%s", PyString_AS_STRING(self->name),
                                           PyString_AS_STRING(self->version));
        if (tmp == NULL)
            return NULL;
        res = PyObject_CallFunction(globdistance, "OOO",
                                    PyTuple_GET_ITEM(tup, 0), tmp,
                                    PyTuple_GET_ITEM(tup, 1));
        Py_DECREF(tmp);
        if (res == NULL)
            return NULL;
        if (PyTuple_GET_SIZE(res) != 2 ||
            !PyFloat_Check(PyTuple_GET_ITEM(res, 1))) {
            PyErr_SetString(PyExc_ValueError, "Invalid globdistance "
                                              "answer size");
            return NULL;
        }
        if (ratio == NULL || PyFloat_AS_DOUBLE(PyTuple_GET_ITEM(res, 1)) >
                             PyFloat_AS_DOUBLE(ratio)) {
            Py_XDECREF(ratio);
            ratio = PyTuple_GET_ITEM(res, 1);
            Py_INCREF(ratio);
        }
        Py_DECREF(res);
    }
    Py_DECREF(lst);

    if (ratio && PyFloat_AS_DOUBLE(ratio))
        CALLMETHOD(searcher, "addResult", "OO", self, ratio);
    Py_XDECREF(ratio);

    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *
Package_getPriority(PackageObject *self, PyObject *args)
{
    PyObject *sysconf = getPkgConf();
    PyObject *priority;
    PyObject *loaders;
    long lpriority = 0;
    int i;
    priority = PyObject_CallMethod(sysconf, "getPriority", "O", self);
    if (priority != Py_None)
        return priority;
    Py_DECREF(priority);
    loaders = PyDict_Keys(self->loaders);
    for (i = 0; i != PyList_GET_SIZE(loaders); i++) {
        PyObject *loader = PyList_GET_ITEM(loaders, i);
        PyObject *channel = PyObject_CallMethod(loader, "getChannel", NULL);
        priority = PyObject_CallMethod(channel, "getPriority", NULL);
        if (i == 0 || PyInt_AS_LONG(priority) > lpriority)
            lpriority = PyInt_AS_LONG(priority);
        Py_DECREF(priority);
        Py_DECREF(channel);
    }
    Py_DECREF(loaders);
    lpriority += PyInt_AS_LONG(self->priority);
    return PyInt_FromLong(lpriority);
}

static PyObject *
Package__getstate__(PackageObject *self, PyObject *args)
{
    PyObject *state = PyTuple_New(10);
    if (!state) return NULL;

    Py_INCREF(self->name);
    Py_INCREF(self->version);
    Py_INCREF(self->provides);
    Py_INCREF(self->requires);
    Py_INCREF(self->upgrades);
    Py_INCREF(self->conflicts);
    Py_INCREF(self->installed);
    Py_INCREF(self->essential);
    Py_INCREF(self->priority);
    Py_INCREF(self->loaders);

    PyTuple_SET_ITEM(state, 0, self->name);
    PyTuple_SET_ITEM(state, 1, self->version);
    PyTuple_SET_ITEM(state, 2, self->provides);
    PyTuple_SET_ITEM(state, 3, self->requires);
    PyTuple_SET_ITEM(state, 4, self->upgrades);
    PyTuple_SET_ITEM(state, 5, self->conflicts);
    PyTuple_SET_ITEM(state, 6, self->installed);
    PyTuple_SET_ITEM(state, 7, self->essential);
    PyTuple_SET_ITEM(state, 8, self->priority);
    PyTuple_SET_ITEM(state, 9, self->loaders);

    return state;
}

static PyObject *
Package__setstate__(PackageObject *self, PyObject *state)
{
    if (!PyTuple_Check(state) || PyTuple_GET_SIZE(state) != 10) {
        PyErr_SetString(StateVersionError, "");
        return NULL;
    }
    self->name = PyTuple_GET_ITEM(state, 0);
    self->version = PyTuple_GET_ITEM(state, 1);
    self->provides = PyTuple_GET_ITEM(state, 2);
    self->requires = PyTuple_GET_ITEM(state, 3);
    self->upgrades = PyTuple_GET_ITEM(state, 4);
    self->conflicts = PyTuple_GET_ITEM(state, 5);
    self->installed = PyTuple_GET_ITEM(state, 6);
    self->essential = PyTuple_GET_ITEM(state, 7);
    self->priority = PyTuple_GET_ITEM(state, 8);
    self->loaders = PyTuple_GET_ITEM(state, 9);

    Py_INCREF(self->name);
    Py_INCREF(self->version);
    Py_INCREF(self->provides);
    Py_INCREF(self->requires);
    Py_INCREF(self->upgrades);
    Py_INCREF(self->conflicts);
    Py_INCREF(self->installed);
    Py_INCREF(self->essential);
    Py_INCREF(self->priority);
    Py_INCREF(self->loaders);

    Py_INCREF(Py_None);
    return Py_None;
}

static PyMethodDef Package_methods[] = {
    {"getInitArgs", (PyCFunction)Package_getInitArgs, METH_NOARGS, NULL},
    {"equals", (PyCFunction)Package_equals, METH_O, NULL},
    {"coexists", (PyCFunction)Package_coexists, METH_O, NULL},
    {"matches", (PyCFunction)Package_matches, METH_VARARGS, NULL},
    {"search", (PyCFunction)Package_search, METH_O, NULL},
    {"getPriority", (PyCFunction)Package_getPriority, METH_NOARGS, NULL},
    {"__getstate__", (PyCFunction)Package__getstate__, METH_NOARGS, NULL},
    {"__setstate__", (PyCFunction)Package__setstate__, METH_O, NULL},
    {NULL, NULL}
};

#define OFF(x) offsetof(PackageObject, x)
static PyMemberDef Package_members[] = {
    {"name", T_OBJECT, OFF(name), 0, 0},
    {"version", T_OBJECT, OFF(version), 0, 0},
    {"provides", T_OBJECT, OFF(provides), 0, 0},
    {"requires", T_OBJECT, OFF(requires), 0, 0},
    {"upgrades", T_OBJECT, OFF(upgrades), 0, 0},
    {"conflicts", T_OBJECT, OFF(conflicts), 0, 0},
    {"installed", T_OBJECT, OFF(installed), 0, 0},
    {"essential", T_OBJECT, OFF(essential), 0, 0},
    {"priority", T_OBJECT, OFF(priority), 0, 0},
    {"loaders", T_OBJECT, OFF(loaders), 0, 0},
    {NULL}
};
#undef OFF

statichere PyTypeObject Package_Type = {
	PyObject_HEAD_INIT(NULL)
	0,			/*ob_size*/
	"smart.cache.Package",	/*tp_name*/
	sizeof(PackageObject), /*tp_basicsize*/
	0,			/*tp_itemsize*/
	(destructor)Package_dealloc, /*tp_dealloc*/
	0,			/*tp_print*/
	0,			/*tp_getattr*/
	0,			/*tp_setattr*/
	0,			/*tp_compare*/
	PyObject_Str, /*tp_repr*/
	0,			/*tp_as_number*/
	0,			/*tp_as_sequence*/
	0,			/*tp_as_mapping*/
	(hashfunc)_Py_HashPointer, /*tp_hash*/
    0,                      /*tp_call*/
    (reprfunc)Package_str,  /*tp_str*/
    PyObject_GenericGetAttr,/*tp_getattro*/
    PyObject_GenericSetAttr,/*tp_setattro*/
    0,                      /*tp_as_buffer*/
    Py_TPFLAGS_DEFAULT|Py_TPFLAGS_BASETYPE, /*tp_flags*/
    0,                      /*tp_doc*/
    0,                      /*tp_traverse*/
    0,                      /*tp_clear*/
    (richcmpfunc)Package_richcompare, /*tp_richcompare*/
    0,                      /*tp_weaklistoffset*/
    0,                      /*tp_iter*/
    0,                      /*tp_iternext*/
    Package_methods,        /*tp_methods*/
    Package_members,        /*tp_members*/
    0,                      /*tp_getset*/
    0,                      /*tp_base*/
    0,                      /*tp_dict*/
    0,                      /*tp_descr_get*/
    0,                      /*tp_descr_set*/
    0,                      /*tp_dictoffset*/
    (initproc)Package_init, /*tp_init*/
    PyType_GenericAlloc,    /*tp_alloc*/
    PyType_GenericNew,      /*tp_new*/
    _PyObject_Del,          /*tp_free*/
    0,                      /*tp_is_gc*/
};

static int
Provides_init(ProvidesObject *self, PyObject *args)
{
    if (!PyArg_ParseTuple(args, "O!O", &PyString_Type, &self->name,
                          &self->version))
        return -1;
    Py_INCREF(self->name);
    Py_INCREF(self->version);
    self->packages = PyList_New(0);
    self->requiredby = PyTuple_New(0);
    self->upgradedby = PyTuple_New(0);
    self->conflictedby = PyTuple_New(0);
    return 0;
}

static void
Provides_dealloc(ProvidesObject *self)
{
    Py_XDECREF(self->name);
    Py_XDECREF(self->version);
    Py_XDECREF(self->packages);
    Py_XDECREF(self->requiredby);
    Py_XDECREF(self->upgradedby);
    Py_XDECREF(self->conflictedby);
    self->ob_type->tp_free((PyObject *)self);
}

static PyObject *
Provides_getInitArgs(ProvidesObject *self, PyObject *args)
{
    PyObject *ret = PyTuple_New(3);
    if (!ret) return NULL;
    PyTuple_SET_ITEM(ret, 0,
                     PyObject_GetAttrString((PyObject *)self, "__class__"));
    Py_INCREF(self->name);
    Py_INCREF(self->version);
    PyTuple_SET_ITEM(ret, 1, self->name);
    PyTuple_SET_ITEM(ret, 2, self->version);
    return ret;
}

static PyObject *
Provides_search(PackageObject *self, PyObject *searcher)
{
    PyObject *globdistance = getGlobDistance();
    PyObject *tmp, *lst, *tup, *res;
    PyObject *ratio = NULL;
    int i;

    if (globdistance == NULL)
        return NULL;

    lst = PyObject_GetAttrString(searcher, "provides");
    if (lst == NULL || !PyList_Check(lst)) {
        PyErr_SetString(PyExc_TypeError, "Invalid provides attribute");
        return NULL;
    }
    for (i = 0; i != PyList_GET_SIZE(lst); i++) {
        tup = PyList_GET_ITEM(lst, i);
        if (PyTuple_GET_SIZE(tup) != 2) {
            PyErr_SetString(PyExc_ValueError, "Invalid provides tuple size");
            return NULL;
        }
        res = PyObject_CallFunction(globdistance, "OOO",
                                    PyTuple_GET_ITEM(tup, 0), self->name,
                                    PyTuple_GET_ITEM(tup, 1));
        if (res == NULL)
            return NULL;
        if (PyTuple_GET_SIZE(res) != 2 ||
            !PyFloat_Check(PyTuple_GET_ITEM(res, 1))) {
            PyErr_SetString(PyExc_ValueError, "Invalid globdistance "
                                              "answer size");
            return NULL;
        }
        if (ratio == NULL || PyFloat_AS_DOUBLE(PyTuple_GET_ITEM(res, 1)) >
                             PyFloat_AS_DOUBLE(ratio)) {
            Py_XDECREF(ratio);
            ratio = PyTuple_GET_ITEM(res, 1);
            Py_INCREF(ratio);
        }
        Py_DECREF(res);

        tmp = PyString_FromFormat("%s-%s", PyString_AS_STRING(self->name),
                                           PyString_AS_STRING(self->version));
        if (tmp == NULL)
            return NULL;
        res = PyObject_CallFunction(globdistance, "OOO",
                                    PyTuple_GET_ITEM(tup, 0), tmp,
                                    PyTuple_GET_ITEM(tup, 1));
        Py_DECREF(tmp);
        if (res == NULL)
            return NULL;
        if (PyTuple_GET_SIZE(res) != 2 ||
            !PyFloat_Check(PyTuple_GET_ITEM(res, 1))) {
            PyErr_SetString(PyExc_ValueError, "Invalid globdistance "
                                              "answer size");
            return NULL;
        }
        if (ratio == NULL || PyFloat_AS_DOUBLE(PyTuple_GET_ITEM(res, 1)) >
                             PyFloat_AS_DOUBLE(ratio)) {
            Py_XDECREF(ratio);
            ratio = PyTuple_GET_ITEM(res, 1);
            Py_INCREF(ratio);
        }
        Py_DECREF(res);
    }
    Py_DECREF(lst);

    if (ratio && PyFloat_AS_DOUBLE(ratio))
        CALLMETHOD(searcher, "addResult", "OO", self, ratio);
    Py_XDECREF(ratio);

    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *
Provides_str(ProvidesObject *self)
{
    if (!PyString_Check(self->name)) {
        PyErr_SetString(PyExc_TypeError, "package name is not string");
        return NULL;
    }
    if (self->version != Py_None) {
        if (!PyString_Check(self->version)) {
            PyErr_SetString(PyExc_TypeError, "package version is not string");
            return NULL;
        }
        return PyString_FromFormat("%s = %s", STR(self->name),
                                              STR(self->version));
    }
    Py_INCREF(self->name);
    return self->name;
}

static int
Provides_compare(ProvidesObject *self, ProvidesObject *other)
{
    int rc = -1;
    if (PyObject_IsInstance((PyObject *)other, (PyObject *)&Provides_Type)) {
        if (!PyString_Check(self->name) || !PyString_Check(other->name)) {
            PyErr_SetString(PyExc_TypeError, "Provides name is not string");
            return -1;
        }
        rc = strcmp(STR(self->name), STR(other->name));
        if (rc == 0) {
            rc = strcmp(STR(self->version), STR(other->version));
            if (rc == 0) {
                PyObject *class1 = PyObject_GetAttrString((PyObject *)self,
                                                          "__class__");
                PyObject *class2 = PyObject_GetAttrString((PyObject *)other,
                                                          "__class__");
                if (!class1 || !class2)
                    rc = -1;
                else
                    rc = PyObject_Compare(class1, class2);
                Py_XDECREF(class1);
                Py_XDECREF(class2);
            }
        }
    }
    return rc > 0 ? 1 : ( rc < 0 ? -1 : 0);
}

static PyObject *
Provides__reduce__(ProvidesObject *self, PyObject *_)
{
    PyObject *ret = PyTuple_New(2);
    PyObject *args = PyTuple_New(2);
    if (!ret || !args) return NULL;
    PyTuple_SET_ITEM(ret, 0,
                     PyObject_GetAttrString((PyObject *)self, "__class__"));
    PyTuple_SET_ITEM(ret, 1, args);
    Py_INCREF(self->name);
    Py_INCREF(self->version);
    PyTuple_SET_ITEM(args, 0, self->name);
    PyTuple_SET_ITEM(args, 1, self->version);
    return ret;
}


static PyMethodDef Provides_methods[] = {
    {"getInitArgs", (PyCFunction)Provides_getInitArgs, METH_NOARGS, NULL},
    {"search", (PyCFunction)Provides_search, METH_O, NULL},
    {"__reduce__", (PyCFunction)Provides__reduce__, METH_NOARGS, NULL},
    {NULL, NULL}
};

#define OFF(x) offsetof(ProvidesObject, x)
static PyMemberDef Provides_members[] = {
    {"name", T_OBJECT, OFF(name), 0, 0},
    {"version", T_OBJECT, OFF(version), 0, 0},
    {"packages", T_OBJECT, OFF(packages), 0, 0},
    {"requiredby", T_OBJECT, OFF(requiredby), 0, 0},
    {"upgradedby", T_OBJECT, OFF(upgradedby), 0, 0},
    {"conflictedby", T_OBJECT, OFF(conflictedby), 0, 0},
    {NULL}
};
#undef OFF

statichere PyTypeObject Provides_Type = {
	PyObject_HEAD_INIT(NULL)
	0,			/*ob_size*/
	"smart.cache.Provides",	/*tp_name*/
	sizeof(ProvidesObject), /*tp_basicsize*/
	0,			/*tp_itemsize*/
	(destructor)Provides_dealloc, /*tp_dealloc*/
	0,			/*tp_print*/
	0,			/*tp_getattr*/
	0,			/*tp_setattr*/
	(cmpfunc)Provides_compare, /*tp_compare*/
	PyObject_Str, /*tp_repr*/
	0,			/*tp_as_number*/
	0,			/*tp_as_sequence*/
	0,			/*tp_as_mapping*/
	(hashfunc)_Py_HashPointer, /*tp_hash*/
    0,                      /*tp_call*/
    (reprfunc)Provides_str, /*tp_str*/
    PyObject_GenericGetAttr,/*tp_getattro*/
    PyObject_GenericSetAttr,/*tp_setattro*/
    0,                      /*tp_as_buffer*/
    Py_TPFLAGS_DEFAULT|Py_TPFLAGS_BASETYPE, /*tp_flags*/
    0,                      /*tp_doc*/
    0,                      /*tp_traverse*/
    0,                      /*tp_clear*/
    0,                      /*tp_richcompare*/
    0,                      /*tp_weaklistoffset*/
    0,                      /*tp_iter*/
    0,                      /*tp_iternext*/
    Provides_methods,       /*tp_methods*/
    Provides_members,       /*tp_members*/
    0,                      /*tp_getset*/
    0,                      /*tp_base*/
    0,                      /*tp_dict*/
    0,                      /*tp_descr_get*/
    0,                      /*tp_descr_set*/
    0,                      /*tp_dictoffset*/
    (initproc)Provides_init, /*tp_init*/
    PyType_GenericAlloc,    /*tp_alloc*/
    PyType_GenericNew,      /*tp_new*/
    _PyObject_Del,          /*tp_free*/
    0,                      /*tp_is_gc*/
};

static int
Depends_init(DependsObject *self, PyObject *args)
{
    if (!PyArg_ParseTuple(args, "O!OO", &PyString_Type, &self->name,
                          &self->relation, &self->version))
        return -1;
    Py_INCREF(self->name);
    Py_INCREF(self->relation);
    Py_INCREF(self->version);
    self->packages = PyList_New(0);
    self->providedby = PyTuple_New(0);
    return 0;
}

static void
Depends_dealloc(DependsObject *self)
{
    Py_XDECREF(self->name);
    Py_XDECREF(self->relation);
    Py_XDECREF(self->version);
    Py_XDECREF(self->packages);
    Py_XDECREF(self->providedby);
    self->ob_type->tp_free((PyObject *)self);
}

static PyObject *
Depends_getInitArgs(DependsObject *self, PyObject *args)
{
    PyObject *ret = PyTuple_New(4);
    if (!ret) return NULL;
    PyTuple_SET_ITEM(ret, 0,
                     PyObject_GetAttrString((PyObject *)self, "__class__"));
    Py_INCREF(self->name);
    Py_INCREF(self->relation);
    Py_INCREF(self->version);
    PyTuple_SET_ITEM(ret, 1, self->name);
    PyTuple_SET_ITEM(ret, 2, self->relation);
    PyTuple_SET_ITEM(ret, 3, self->version);
    return ret;
}

static PyObject *
Depends_getMatchNames(DependsObject *self)
{
    PyObject *tup = PyTuple_New(1);
    Py_INCREF(self->name);
    PyTuple_SET_ITEM(tup, 0, self->name);
    return tup;
}

static PyObject *
Depends_matches(DependsObject *self, PyObject *prv)
{
    Py_INCREF(Py_False);
    return Py_False;
}

static PyObject *
Depends_str(DependsObject *self)
{
    if (!PyString_Check(self->name)) {
        PyErr_SetString(PyExc_TypeError, "Package name is not string");
        return NULL;
    }
    if (self->version != Py_None) {
        if (!PyString_Check(self->version) ||
            !PyString_Check(self->relation)) {
            PyErr_SetString(PyExc_TypeError,
                            "Package version or relation is not string");
            return NULL;
        }
        return PyString_FromFormat("%s %s %s", STR(self->name),
                                               STR(self->relation),
                                               STR(self->version));
    }
    Py_INCREF(self->name);
    return self->name;
}

static int
Depends_compare(DependsObject *self, DependsObject *other)
{
    int rc = -1;
    if (PyObject_IsInstance((PyObject *)other, (PyObject *)&Depends_Type)) {
        if (!PyString_Check(self->name) || !PyString_Check(other->name)) {
            PyErr_SetString(PyExc_TypeError, "Depends name is not string");
            return -1;
        }
        rc = strcmp(STR(self->name), STR(other->name));
        if (rc == 0) {
            PyObject *class1 = PyObject_GetAttrString((PyObject *)self,
                                                      "__class__");
            PyObject *class2 = PyObject_GetAttrString((PyObject *)other,
                                                      "__class__");
            if (!class1 || !class2) {
                rc = -1;
            } else {
                rc = PyObject_Compare(class1, class2);
                Py_DECREF(class1);
                Py_DECREF(class2);
            }
        }
    }
    return rc > 0 ? 1 : ( rc < 0 ? -1 : 0);
}

static PyObject *
Depends__reduce__(DependsObject *self, PyObject *_)
{
    PyObject *ret = PyTuple_New(2);
    PyObject *args = PyTuple_New(3);
    if (!ret || !args) return NULL;
    PyTuple_SET_ITEM(ret, 0,
                     PyObject_GetAttrString((PyObject *)self, "__class__"));
    PyTuple_SET_ITEM(ret, 1, args);
    Py_INCREF(self->name);
    Py_INCREF(self->relation);
    Py_INCREF(self->version);
    PyTuple_SET_ITEM(args, 0, self->name);
    PyTuple_SET_ITEM(args, 1, self->relation);
    PyTuple_SET_ITEM(args, 2, self->version);
    return ret;
}

static PyMethodDef Depends_methods[] = {
    {"getInitArgs", (PyCFunction)Depends_getInitArgs, METH_NOARGS, NULL},
    {"getMatchNames", (PyCFunction)Depends_getMatchNames, METH_NOARGS, NULL},
    {"matches", (PyCFunction)Depends_matches, METH_O, NULL},
    {"__reduce__", (PyCFunction)Depends__reduce__, METH_NOARGS, NULL},
    {NULL, NULL}
};

#define OFF(x) offsetof(DependsObject, x)
static PyMemberDef Depends_members[] = {
    {"name", T_OBJECT, OFF(name), 0, 0},
    {"relation", T_OBJECT, OFF(relation), 0, 0},
    {"version", T_OBJECT, OFF(version), 0, 0},
    {"packages", T_OBJECT, OFF(packages), 0, 0},
    {"providedby", T_OBJECT, OFF(providedby), 0, 0},
    {NULL}
};
#undef OFF

statichere PyTypeObject Depends_Type = {
	PyObject_HEAD_INIT(NULL)
	0,			/*ob_size*/
	"smart.cache.Depends",	/*tp_name*/
	sizeof(DependsObject), /*tp_basicsize*/
	0,			/*tp_itemsize*/
	(destructor)Depends_dealloc, /*tp_dealloc*/
	0,			/*tp_print*/
	0,			/*tp_getattr*/
	0,			/*tp_setattr*/
	(cmpfunc)Depends_compare, /*tp_compare*/
	PyObject_Str, /*tp_repr*/
	0,			/*tp_as_number*/
	0,			/*tp_as_sequence*/
	0,			/*tp_as_mapping*/
	(hashfunc)_Py_HashPointer, /*tp_hash*/
    0,                      /*tp_call*/
    (reprfunc)Depends_str, /*tp_str*/
    PyObject_GenericGetAttr,/*tp_getattro*/
    PyObject_GenericSetAttr,/*tp_setattro*/
    0,                      /*tp_as_buffer*/
    Py_TPFLAGS_DEFAULT|Py_TPFLAGS_BASETYPE, /*tp_flags*/
    0,                      /*tp_doc*/
    0,                      /*tp_traverse*/
    0,                      /*tp_clear*/
    0,                      /*tp_richcompare*/
    0,                      /*tp_weaklistoffset*/
    0,                      /*tp_iter*/
    0,                      /*tp_iternext*/
    Depends_methods,        /*tp_methods*/
    Depends_members,        /*tp_members*/
    0,                      /*tp_getset*/
    0,                      /*tp_base*/
    0,                      /*tp_dict*/
    0,                      /*tp_descr_get*/
    0,                      /*tp_descr_set*/
    0,                      /*tp_dictoffset*/
    (initproc)Depends_init, /*tp_init*/
    PyType_GenericAlloc,    /*tp_alloc*/
    PyType_GenericNew,      /*tp_new*/
    _PyObject_Del,          /*tp_free*/
    0,                      /*tp_is_gc*/
};

static int
Loader_init(LoaderObject *self, PyObject *args)
{
    if (!PyArg_ParseTuple(args, ""))
        return -1;
    Py_INCREF(Py_None);
    self->_channel = Py_None;
    self->_packages = PyList_New(0);
    Py_INCREF(Py_False);
    self->_installed = Py_False;
    return 0;
}

static void
Loader_dealloc(LoaderObject *self)
{
    Py_XDECREF(self->_channel);
    Py_XDECREF(self->_packages);
    Py_XDECREF(self->_installed);
    Py_XDECREF(self->_cache);
    self->ob_type->tp_free((PyObject *)self);
}

PyObject *
Loader_getPackages(LoaderObject *self, PyObject *args)
{
    Py_INCREF(self->_packages);
    return self->_packages;
}

PyObject *
Loader_getChannel(LoaderObject *self, PyObject *args)
{
    Py_INCREF(self->_channel);
    return self->_channel;
}

PyObject *
Loader_setChannel(LoaderObject *self, PyObject *channel)
{
    Py_DECREF(self->_channel);
    self->_channel = channel;
    Py_INCREF(self->_channel);
    Py_RETURN_NONE;
}

PyObject *
Loader_getCache(LoaderObject *self, PyObject *args)
{
    Py_INCREF(self->_cache);
    return self->_cache;
}

PyObject *
Loader_setCache(LoaderObject *self, PyObject *cache)
{
    Py_XDECREF(self->_cache);
    self->_cache = NULL;

    if (cache == Py_None)
        Py_RETURN_NONE;

    if (!PyObject_IsInstance(cache, (PyObject *)&Cache_Type)) {
        PyErr_SetString(PyExc_TypeError,
                        "Cache is not an instance of cache.Cache");
        return NULL;
    }

    Py_INCREF(cache);
    self->_cache = cache;
    Py_RETURN_NONE;
}

PyObject *
Loader_getInstalled(LoaderObject *self, PyObject *args)
{
    Py_INCREF(self->_installed);
    return self->_installed;
}

PyObject *
Loader_setInstalled(LoaderObject *self, PyObject *flag)
{
    Py_DECREF(self->_installed);
    Py_INCREF(flag);
    self->_installed = flag;
    Py_RETURN_NONE;
}

PyObject *
Loader_getLoadSteps(LoaderObject *self, PyObject *args)
{
    return PyInt_FromLong(0);
}

PyObject *
Loader_getInfo(LoaderObject *self, PyObject *pkg)
{
    Py_RETURN_NONE;
}

PyObject *
Loader_reset(LoaderObject *self, PyObject *args)
{
    LIST_CLEAR(self->_packages);
    Py_RETURN_NONE;
}

PyObject *
Loader_load(LoaderObject *self, PyObject *args)
{
    Py_RETURN_NONE;
}

PyObject *
Loader_unload(LoaderObject *self, PyObject *args)
{
    return PyObject_CallMethod((PyObject *)self, "reset", NULL);
}

PyObject *
Loader_loadFileProvides(LoaderObject *self, PyObject *args)
{
    Py_RETURN_NONE;
}

static int
mylist(PyObject *obj, PyObject **ret)
{
    if (obj == Py_None)
        *ret = NULL;
    else if (PyList_Check(obj))
        *ret = obj;
    else
        return 0;
    return 1;
}

PyObject *
Loader_buildPackage(LoaderObject *self, PyObject *args)
{
    PyObject *pkgargs;
    PyObject *prvargs;
    PyObject *reqargs;
    PyObject *upgargs;
    PyObject *cnfargs;
    PyObject *callargs;
    
    PyObject *pkg;
    PackageObject *pkgobj;

    PyObject *relpkgs;
    PyObject *lst;

    CacheObject *cache;

    if (!self->_cache) {
        PyErr_SetString(PyExc_TypeError, "Cache not set");
        return NULL;
    }

    cache = (CacheObject *)self->_cache;

    if (!PyArg_ParseTuple(args, "O!O&O&O&O&", &PyTuple_Type, &pkgargs,
                          mylist, &prvargs, mylist, &reqargs,
                          mylist, &upgargs, mylist, &cnfargs))
        return NULL;

    if (PyTuple_GET_SIZE(pkgargs) < 2) {
        PyErr_SetString(PyExc_ValueError, "Invalid pkgargs tuple");
        return NULL;
    }

    /* pkg = pkgargs[0](*pkgargs[1:]) */
    callargs = PyTuple_GetSlice(pkgargs, 1, PyTuple_GET_SIZE(pkgargs));
    pkg = PyObject_CallObject(PyTuple_GET_ITEM(pkgargs, 0), callargs);
    Py_DECREF(callargs);
    if (!pkg) return NULL;

    pkgobj = (PackageObject *)pkg;

    /* relpkgs = [] */
    relpkgs = PyList_New(0);

    /* if prvargs: */
    if (prvargs) {
        int i = 0;
        int len = PyList_GET_SIZE(prvargs);
        /* pkg.provides = [] */
        Py_DECREF(pkgobj->provides);
        pkgobj->provides = PyList_New(len);
        /* for args in prvargs: */
        for (; i != len; i++) {
            PyObject *args = PyList_GET_ITEM(prvargs, i);
            ProvidesObject *prvobj;
            PyObject *prv;
            
            if (!PyTuple_Check(args)) {
                PyErr_SetString(PyExc_TypeError,
                                "Item in prvargs is not a tuple");
                return NULL;
            }

            /* prv = cache._objmap.get(args) */
            prv = PyDict_GetItem(cache->_objmap, args);
            prvobj = (ProvidesObject *)prv;

            /* if not prv: */
            if (!prv) {
                if (!PyTuple_Check(args) || PyTuple_GET_SIZE(args) < 2) {
                    PyErr_SetString(PyExc_ValueError, "Invalid prvargs tuple");
                    return NULL;
                }
                /* prv = args[0](*args[1:]) */
                callargs = PyTuple_GetSlice(args, 1, PyTuple_GET_SIZE(args));
                prv = PyObject_CallObject(PyTuple_GET_ITEM(args, 0), callargs);
                Py_DECREF(callargs);
                if (!prv) return NULL;
                prvobj = (ProvidesObject *)prv;

                /* cache._objmap[args] = prv */
                PyDict_SetItem(cache->_objmap, args, prv);
                Py_DECREF(prv);

                /* cache._provides.append(prv) */
                PyList_Append(cache->_provides, prv);
            }

            /* relpkgs.append(prv.packages) */
            PyList_Append(relpkgs, prvobj->packages);

            /* pkg.provides.append(prv) */
            Py_INCREF(prv);
            PyList_SET_ITEM(pkgobj->provides, i, prv);
        }
    }

    /* if reqargs: */
    if (reqargs) {
        int i = 0;
        int len = PyList_GET_SIZE(reqargs);
        /* pkg.requires = [] */
        Py_DECREF(pkgobj->requires);
        pkgobj->requires = PyList_New(len);
        /* for args in reqargs: */
        for (; i != len; i++) {
            PyObject *args = PyList_GET_ITEM(reqargs, i);
            DependsObject *reqobj;
            PyObject *req;
            
            if (!PyTuple_Check(args)) {
                PyErr_SetString(PyExc_TypeError,
                                "Item in reqargs is not a tuple");
                return NULL;
            }

            /* req = cache._objmap.get(args) */
            req = PyDict_GetItem(cache->_objmap, args);
            reqobj = (DependsObject *)req;

            /* if not req: */
            if (!req) {
                if (!PyTuple_Check(args) || PyTuple_GET_SIZE(args) < 2) {
                    PyErr_SetString(PyExc_ValueError, "Invalid reqargs tuple");
                    return NULL;
                }
                /* req = args[0](*args[1:]) */
                callargs = PyTuple_GetSlice(args, 1, PyTuple_GET_SIZE(args));
                req = PyObject_CallObject(PyTuple_GET_ITEM(args, 0), callargs);
                Py_DECREF(callargs);
                if (!req) return NULL;
                reqobj = (DependsObject *)req;

                /* cache._objmap[args] = req */
                PyDict_SetItem(cache->_objmap, args, req);
                Py_DECREF(req);

                /* cache._requires.append(req) */
                PyList_Append(cache->_requires, req);
            }

            /* relpkgs.append(req.packages) */
            PyList_Append(relpkgs, reqobj->packages);

            /* pkg.requires.append(req) */
            Py_INCREF(req);
            PyList_SET_ITEM(pkgobj->requires, i, req);
        }
    }

    /* if upgargs: */
    if (upgargs) {
        int i = 0;
        int len = PyList_GET_SIZE(upgargs);
        /* pkg.upgrades = [] */
        Py_DECREF(pkgobj->upgrades);
        pkgobj->upgrades = PyList_New(len);
        /* for args in upgargs: */
        for (; i != len; i++) {
            PyObject *args = PyList_GET_ITEM(upgargs, i);
            DependsObject *upgobj;
            PyObject *upg;
            
            if (!PyTuple_Check(args)) {
                PyErr_SetString(PyExc_TypeError,
                                "Item in upgargs is not a tuple");
                return NULL;
            }

            /* upg = cache._objmap.get(args) */
            upg = PyDict_GetItem(cache->_objmap, args);
            upgobj = (DependsObject *)upg;

            /* if not upg: */
            if (!upg) {
                if (!PyTuple_Check(args) || PyTuple_GET_SIZE(args) < 2) {
                    PyErr_SetString(PyExc_ValueError, "Invalid upgargs tuple");
                    return NULL;
                }
                /* upg = args[0](*args[1:]) */
                callargs = PyTuple_GetSlice(args, 1, PyTuple_GET_SIZE(args));
                upg = PyObject_CallObject(PyTuple_GET_ITEM(args, 0), callargs);
                Py_DECREF(callargs);
                if (!upg) return NULL;
                upgobj = (DependsObject *)upg;

                /* cache._objmap[args] = upg */
                PyDict_SetItem(cache->_objmap, args, upg);
                Py_DECREF(upg);

                /* cache._upgrades.append(upg) */
                PyList_Append(cache->_upgrades, upg);
            }

            /* relpkgs.append(upg.packages) */
            PyList_Append(relpkgs, upgobj->packages);

            /* pkg.upgrades.append(upg) */
            Py_INCREF(upg);
            PyList_SET_ITEM(pkgobj->upgrades, i, upg);
        }
    }

    /* if cnfargs: */
    if (cnfargs) {
        int i = 0;
        int len = PyList_GET_SIZE(cnfargs);
        /* pkg.conflicts = [] */
        Py_DECREF(pkgobj->conflicts);
        pkgobj->conflicts = PyList_New(len);
        /* for args in cnfargs: */
        for (; i != len; i++) {
            PyObject *args = PyList_GET_ITEM(cnfargs, i);
            DependsObject *cnfobj;
            PyObject *cnf;
            
            if (!PyTuple_Check(args)) {
                PyErr_SetString(PyExc_TypeError,
                                "Item in cnfargs is not a tuple");
                return NULL;
            }

            /* cnf = cache._objmap.get(args) */
            cnf = PyDict_GetItem(cache->_objmap, args);
            cnfobj = (DependsObject *)cnf;

            /* if not cnf: */
            if (!cnf) {
                if (!PyTuple_Check(args) || PyTuple_GET_SIZE(args) < 2) {
                    PyErr_SetString(PyExc_ValueError, "Invalid cnfargs tuple");
                    return NULL;
                }
                /* cnf = args[0](*args[1:]) */
                callargs = PyTuple_GetSlice(args, 1, PyTuple_GET_SIZE(args));
                cnf = PyObject_CallObject(PyTuple_GET_ITEM(args, 0), callargs);
                Py_DECREF(callargs);
                if (!cnf) return NULL;
                cnfobj = (DependsObject *)cnf;

                /* cache._objmap[args] = cnf */
                PyDict_SetItem(cache->_objmap, args, cnf);
                Py_DECREF(cnf);

                /* cache._conflicts.append(cnf) */
                PyList_Append(cache->_conflicts, cnf);
            }

            /* relpkgs.append(cnf.packages) */
            PyList_Append(relpkgs, cnfobj->packages);

            /* pkg.conflicts.append(cnf) */
            Py_INCREF(cnf);
            PyList_SET_ITEM(pkgobj->conflicts, i, cnf);
        }
    }

    /* found = False */
    int found = 0;
    /* lst = cache._objmap.get(pkgargs) */
    lst = PyDict_GetItem(cache->_objmap, pkgargs);
    /* if lst is not None: */
    if (lst) {
        /* for lstpkg in lst: */
        int i = 0;    
        int len = PyList_GET_SIZE(lst);
        for (; i != len; i++) {
            PyObject *lstpkg = PyList_GET_ITEM(lst, i);
            /* if pkg.equals(lstpkg): */
            PyObject *ret = PyObject_CallMethod(pkg, "equals", "O", lstpkg);
            if (!ret) return NULL;
            if (ret == Py_True) {
                /* pkg = lstpkg */
                Py_DECREF(pkg);
                pkg = lstpkg;
                pkgobj = (PackageObject *)pkg;
                Py_INCREF(pkg);
                /* found = True */
                found = 1;
                /* break */
                break;
            }
            Py_DECREF(ret);
        }
        /* else: */
        if (!found)
            /* lst.append(pkg) */
            PyList_Append(lst, pkg);
    }
    /* else: */
    if (!found) {
        /* cache._objmap[pkgargs] = [pkg] */
        lst = PyList_New(1);
        Py_INCREF(pkg);
        PyList_SET_ITEM(lst, 0, pkg);
        PyDict_SetItem(cache->_objmap, pkgargs, lst);
        Py_DECREF(lst);
    }

    /* if not found: */
    if (!found) {
        int i, len;

        /* cache._packages.append(pkg) */
        PyList_Append(cache->_packages, pkg);

        /* for pkgs in relpkgs: */
        len = PyList_GET_SIZE(relpkgs);
        for (i = 0; i != len; i++) {
            PyObject *pkgs = PyList_GET_ITEM(relpkgs, i);
            /* pkgs.append(pkg) */
            PyList_Append(pkgs, pkg);
        }
    }

    /* This will leak if it returns earlier, but any early
     * returns are serious bugs, so let's KISS here. */
    Py_DECREF(relpkgs);

    /* pkg.installed |= self._installed */
    if (self->_installed == Py_True) {
        Py_DECREF(pkgobj->installed);
        pkgobj->installed = self->_installed;
        Py_INCREF(pkgobj->installed);
    }

    /* self._packages.append(pkg) */
    PyList_Append(self->_packages, pkg);

    return pkg;
}

PyObject *
Loader_buildFileProvides(LoaderObject *self, PyObject *args)
{
    PackageObject *pkgobj;
    PyObject *pkg;
    PyObject *prvargs;
    PyObject *callargs;

    ProvidesObject *prvobj;
    PyObject *prv;

    CacheObject *cache;

    int i;

    if (!self->_cache) {
        PyErr_SetString(PyExc_TypeError, "Cache not set");
        return NULL;
    }
    cache = (CacheObject *)self->_cache;

    if (!PyArg_ParseTuple(args, "OO", &pkg, &prvargs))
        return NULL;

    if (!PyObject_IsInstance(pkg, (PyObject *)&Package_Type)) {
        PyErr_SetString(PyExc_TypeError,
                        "First argument must be a Package instance");
        return NULL;
    }

    pkgobj = (PackageObject *)pkg;

    /* prv = cache._objmap.get(prvargs) */
    prv = PyDict_GetItem(cache->_objmap, prvargs);
    prvobj = (ProvidesObject *)prv;

    /* if not prv: */
    if (!prv) {

        if (!PyTuple_Check(prvargs) || PyTuple_GET_SIZE(prvargs) < 2) {
            PyErr_SetString(PyExc_ValueError, "Invalid prvargs tuple");
            return NULL;
        }

        /* prv = prvargs[0](*prvargs[1:]) */
        callargs = PyTuple_GetSlice(prvargs, 1, PyTuple_GET_SIZE(prvargs));
        prv = PyObject_CallObject(PyTuple_GET_ITEM(prvargs, 0), callargs);
        Py_DECREF(callargs);
        if (!prv) return NULL;
        prvobj = (ProvidesObject *)prv;

        if (!PyObject_IsInstance(prv, (PyObject *)&Provides_Type)) {
            PyErr_SetString(PyExc_TypeError,
                            "Instance must be a Provides subclass");
            return NULL;
        }

        /* cache._objmap[prvargs] = prv */
        PyDict_SetItem(cache->_objmap, prvargs, prv);
        Py_DECREF(prv);

        /* cache._provides.append(prv) */
        PyList_Append(cache->_provides, prv);
    /*
       elif prv in pkg.provides:
           return
    */
    } else {
        int len = PyList_GET_SIZE(pkgobj->provides);
        for (i = 0; i != len; i++) {
            PyObject *lstprv = PyList_GET_ITEM(pkgobj->provides, i);
            if (lstprv == prv)
                Py_RETURN_NONE;
        }
    }

    /* prv.packages.append(pkg) */
    PyList_Append(prvobj->packages, pkg);

    /* pkg.provides.append(prv) */
    PyList_Append(pkgobj->provides, prv);

    /* for req in pkg.requires[:]: */
    for (i = PyList_GET_SIZE(pkgobj->requires)-1; i != -1; i--) {
        DependsObject *reqobj;
        PyObject *req = PyList_GET_ITEM(pkgobj->requires, i);
        reqobj = (DependsObject *)req;
        /* if req.name == name: */
        if (STR(reqobj->name)[0] == '/' &&
            strcmp(STR(reqobj->name), STR(prvobj->name)) == 0) {
            int j;
            /* pkg.requires.remove(req) */
            PyList_SetSlice(pkgobj->requires, i, i+1, NULL);
            /* req.packages.remove(pkg) */
            for (j = PyList_GET_SIZE(reqobj->packages); j != -1; j--) {
                if (PyList_GET_ITEM(reqobj->packages, j) == pkg)
                    PyList_SetSlice(reqobj->packages, j, j+1, NULL);
            }
            /* if not req.packages: */
            if (PyList_GET_SIZE(reqobj->packages) == 0) {
                /* cache._requires.remove(req) */
                for (j = PyList_GET_SIZE(cache->_requires); j != -1; j--) {
                    if (PyList_GET_ITEM(cache->_requires, j) == req)
                        PyList_SetSlice(cache->_requires, j, j+1, NULL);
                }
            }
        }
    }

    Py_RETURN_NONE;
}

static PyObject *
Loader_search(LoaderObject *self, PyObject *searcher)
{
    PyObject *tmp, *lst1, *lst2, *tup, *res, *pat;
    PyObject *globdistance = getGlobDistance();
    PyObject *ratio = NULL;
    PyObject *pkg, *info;
    int i, j, k;

    if (globdistance == NULL)
        return NULL;

    for (i = 0; i != PyList_GET_SIZE(self->_packages); i++) {
        pkg = PyList_GET_ITEM(self->_packages, i);
        info = PyObject_CallMethod((PyObject *)self, "getInfo", "O", pkg);
        if (info == NULL)
            return NULL;
    
        lst1 = PyObject_GetAttrString(searcher, "url");
        if (lst1 == NULL || !PyList_Check(lst1)) {
            PyErr_SetString(PyExc_TypeError, "Invalid url attribute");
            return NULL;
        }
        for (j = 0; j != PyList_GET_SIZE(lst1); j++) {
            tup = PyList_GET_ITEM(lst1, j);
            if (PyTuple_GET_SIZE(tup) != 2) {
                PyErr_SetString(PyExc_ValueError, "Invalid url tuple size");
                return NULL;
            }
            lst2 = PyObject_CallMethod(info, "getReferenceURLs", NULL);
            if (lst2 == NULL)
                return NULL;
            for (k = 0; k != PyList_GET_SIZE(lst2); k++) {
                res = PyObject_CallFunction(globdistance, "OOO",
                                            PyTuple_GET_ITEM(tup, 0),
                                            PyList_GET_ITEM(lst2, k),
                                            PyTuple_GET_ITEM(tup, 1));
                if (res == NULL)
                    return NULL;
                if (PyTuple_GET_SIZE(res) != 2 ||
                    !PyFloat_Check(PyTuple_GET_ITEM(res, 1))) {
                    PyErr_SetString(PyExc_ValueError, "Invalid globdistance "
                                                      "answer size");
                    return NULL;
                }
                if (ratio == NULL ||
                    PyFloat_AS_DOUBLE(PyTuple_GET_ITEM(res, 1)) >
                    PyFloat_AS_DOUBLE(ratio)) {
                    Py_XDECREF(ratio);
                    ratio = PyTuple_GET_ITEM(res, 1);
                    Py_INCREF(ratio);
                }
                Py_DECREF(res);
            }
            Py_DECREF(lst2);
        }
        Py_DECREF(lst1);

        if (ratio && PyFloat_AS_DOUBLE(ratio) == 1) {
            CALLMETHOD(searcher, "addResult", "OO", pkg, ratio);
            Py_DECREF(ratio);
            Py_DECREF(info);
            ratio = NULL;
            continue;
        }


        lst1 = PyObject_GetAttrString(searcher, "path");
        if (lst1 == NULL || !PyList_Check(lst1)) {
            PyErr_SetString(PyExc_TypeError, "Invalid url attribute");
            return NULL;
        }
        for (j = 0; j != PyList_GET_SIZE(lst1); j++) {
            tup = PyList_GET_ITEM(lst1, j);
            if (PyTuple_GET_SIZE(tup) != 2) {
                PyErr_SetString(PyExc_ValueError, "Invalid url tuple size");
                return NULL;
            }
            lst2 = PyObject_CallMethod(info, "getPathList", NULL);
            if (lst2 == NULL)
                return NULL;
            for (k = 0; k != PyList_GET_SIZE(lst2); k++) {
                res = PyObject_CallFunction(globdistance, "OOO",
                                            PyTuple_GET_ITEM(tup, 0),
                                            PyList_GET_ITEM(lst2, k),
                                            PyTuple_GET_ITEM(tup, 1));
                if (res == NULL)
                    return NULL;
                if (PyTuple_GET_SIZE(res) != 2 ||
                    !PyFloat_Check(PyTuple_GET_ITEM(res, 1))) {
                    PyErr_SetString(PyExc_ValueError, "Invalid globdistance "
                                                      "answer size");
                    return NULL;
                }
                if (ratio == NULL ||
                    PyFloat_AS_DOUBLE(PyTuple_GET_ITEM(res, 1)) >
                    PyFloat_AS_DOUBLE(ratio)) {
                    Py_XDECREF(ratio);
                    ratio = PyTuple_GET_ITEM(res, 1);
                    Py_INCREF(ratio);
                }
                Py_DECREF(res);
            }
            Py_DECREF(lst2);
        }
        Py_DECREF(lst1);

        if (ratio && PyFloat_AS_DOUBLE(ratio) == 1) {
            CALLMETHOD(searcher, "addResult", "OO", pkg, ratio);
            Py_DECREF(ratio);
            Py_DECREF(info);
            ratio = NULL;
            continue;
        }


        lst1 = PyObject_GetAttrString(searcher, "group");
        if (lst1 == NULL || !PyList_Check(lst1)) {
            PyErr_SetString(PyExc_TypeError, "Invalid group attribute");
            return NULL;
        }
        for (j = 0; j != PyList_GET_SIZE(lst1); j++) {
            pat = PyList_GET_ITEM(lst1, j);
            tmp = PyObject_CallMethod(info, "getGroup", NULL);
            if (tmp == NULL)
                return NULL;
            res = PyObject_CallMethod(pat, "search", "O", tmp);
            Py_DECREF(tmp);
            if (PyObject_IsTrue(res)) {
                ratio = PyFloat_FromDouble(1);
                Py_DECREF(res);
                break;
            }
            Py_DECREF(res);
        }
        Py_DECREF(lst1);

        if (ratio && PyFloat_AS_DOUBLE(ratio) == 1) {
            CALLMETHOD(searcher, "addResult", "OO", pkg, ratio);
            Py_DECREF(ratio);
            Py_DECREF(info);
            ratio = NULL;
            continue;
        }


        lst1 = PyObject_GetAttrString(searcher, "summary");
        if (lst1 == NULL || !PyList_Check(lst1)) {
            PyErr_SetString(PyExc_TypeError, "Invalid group attribute");
            return NULL;
        }
        for (j = 0; j != PyList_GET_SIZE(lst1); j++) {
            pat = PyList_GET_ITEM(lst1, j);
            tmp = PyObject_CallMethod(info, "getSummary", NULL);
            if (tmp == NULL)
                return NULL;
            res = PyObject_CallMethod(pat, "search", "O", tmp);
            Py_DECREF(tmp);
            if (PyObject_IsTrue(res)) {
                ratio = PyFloat_FromDouble(1);
                Py_DECREF(res);
                break;
            }
            Py_DECREF(res);
        }
        Py_DECREF(lst1);

        if (ratio && PyFloat_AS_DOUBLE(ratio) == 1) {
            CALLMETHOD(searcher, "addResult", "OO", pkg, ratio);
            Py_DECREF(ratio);
            Py_DECREF(info);
            ratio = NULL;
            continue;
        }


        lst1 = PyObject_GetAttrString(searcher, "description");
        if (lst1 == NULL || !PyList_Check(lst1)) {
            PyErr_SetString(PyExc_TypeError, "Invalid description attribute");
            return NULL;
        }
        for (j = 0; j != PyList_GET_SIZE(lst1); j++) {
            pat = PyList_GET_ITEM(lst1, j);
            tmp = PyObject_CallMethod(info, "getDescription", NULL);
            if (tmp == NULL)
                return NULL;
            res = PyObject_CallMethod(pat, "search", "O", tmp);
            Py_DECREF(tmp);
            if (PyObject_IsTrue(res)) {
                ratio = PyFloat_FromDouble(1);
                Py_DECREF(res);
                break;
            }
            Py_DECREF(res);
        }
        Py_DECREF(lst1);

        if (ratio && PyFloat_AS_DOUBLE(ratio))
            CALLMETHOD(searcher, "addResult", "OO", pkg, ratio);
        Py_XDECREF(ratio);
        ratio = NULL;

        Py_DECREF(info);
    }

    Py_INCREF(Py_None);
    return Py_None;
}

#define Loader__stateversion__ 1

static PyObject *
Loader__getstate__(LoaderObject *self, PyObject *args)
{
    PyObject *dict = PyObject_GetAttrString((PyObject *)self, "__dict__");
    PyObject *state = PyDict_New();
    PyObject *self__stateversion__;
    PyMemberDef *members = Loader_Type.tp_members;
    if (!state) return NULL;
    int i = 0;
    PyErr_Clear();
    while (members[i].name) {
        PyObject *obj = PyMember_GetOne((char *)self, &members[i]);
        PyDict_SetItemString(state, members[i].name, obj);
        Py_DECREF(obj);
        i += 1;
    }
    if (dict) {
        PyDict_Update(state, dict);
        Py_DECREF(dict);
    }
    self__stateversion__ = PyObject_GetAttrString((PyObject *)self,
                                                  "__stateversion__");
    if (!self__stateversion__)
        return NULL;
    PyDict_SetItemString(state, "__stateversion__", self__stateversion__);
    Py_DECREF(self__stateversion__);
    return state;
}

static PyObject *
Loader__setstate__(LoaderObject *self, PyObject *state)
{
    PyMemberDef *members = Loader_Type.tp_members;
    PyObject *self__stateversion__;
    PyObject *__stateversion__;
    if (!PyDict_Check(state)) {
        PyErr_SetString(StateVersionError, "");
        return NULL;
    }
    __stateversion__ = PyDict_GetItemString(state, "__stateversion__");
    self__stateversion__ = PyObject_GetAttrString((PyObject *)self,
                                                  "__stateversion__");
    if (!__stateversion__ || !self__stateversion__ ||
        PyObject_Compare(__stateversion__, self__stateversion__) != 0) {
        Py_XDECREF(self__stateversion__);
        PyErr_SetString(StateVersionError, "");
        return NULL;
    }
    Py_DECREF(self__stateversion__);
    PyObject *dict = PyObject_GetAttrString((PyObject *)self, "__dict__");
    if (dict) {
        PyObject *keys = PyDict_Keys(state);
        int i, ilen;
        ilen = PyList_GET_SIZE(keys);
        for (i = 0; i != ilen; i++) {
            PyObject *obj, *key = PyList_GET_ITEM(keys, i);
            const char *name = STR(key);
            int j = 0;
            if (strcmp(name, "__stateversion__") == 0)
                continue;
            obj = PyDict_GetItem(state, key);
            while (members[j].name) {
                if (strcmp(members[j].name, name) == 0) {
                    PyMember_SetOne((char *)self, &members[j], obj);
                    break;
                }
                j++;
            }
            if (!members[j].name)
                PyDict_SetItem(dict, key, obj);
        }
        Py_DECREF(keys);
    } else {
        int i = 0;
        PyErr_Clear();
        while (members[i].name) {
            PyObject *obj = PyDict_GetItemString(state,
                                                 members[i].name);
            if (!obj) {
                PyErr_SetString(StateVersionError, "");
                return NULL;
            }
            PyMember_SetOne((char *)self, &members[i], obj);
            i += 1;
        }
    }
    Py_DECREF(dict);

    Py_INCREF(Py_None);
    return Py_None;
}

static PyMethodDef Loader_methods[] = {
    {"getPackages", (PyCFunction)Loader_getPackages, METH_NOARGS, NULL},
    {"getChannel", (PyCFunction)Loader_getChannel, METH_NOARGS, NULL},
    {"setChannel", (PyCFunction)Loader_setChannel, METH_O, NULL},
    {"getCache", (PyCFunction)Loader_getCache, METH_NOARGS, NULL},
    {"setCache", (PyCFunction)Loader_setCache, METH_O, NULL},
    {"getInstalled", (PyCFunction)Loader_getInstalled, METH_NOARGS, NULL},
    {"setInstalled", (PyCFunction)Loader_setInstalled, METH_O, NULL},
    {"getLoadSteps", (PyCFunction)Loader_getLoadSteps, METH_NOARGS, NULL},
    {"getInfo", (PyCFunction)Loader_getInfo, METH_O, NULL},
    {"reset", (PyCFunction)Loader_reset, METH_NOARGS, NULL},
    {"load", (PyCFunction)Loader_load, METH_NOARGS, NULL},
    {"unload", (PyCFunction)Loader_unload, METH_NOARGS, NULL},
    {"loadFileProvides", (PyCFunction)Loader_loadFileProvides, METH_O, NULL},
    {"buildPackage", (PyCFunction)Loader_buildPackage, METH_VARARGS, NULL},
    {"buildFileProvides", (PyCFunction)Loader_buildFileProvides, METH_VARARGS, NULL},
    {"search", (PyCFunction)Loader_search, METH_O, NULL},
    {"__getstate__", (PyCFunction)Loader__getstate__, METH_NOARGS, NULL},
    {"__setstate__", (PyCFunction)Loader__setstate__, METH_O, NULL},
    {NULL, NULL}
};

#define OFF(x) offsetof(LoaderObject, x)
static PyMemberDef Loader_members[] = {
    {"_channel", T_OBJECT, OFF(_channel), 0, 0},
    {"_cache", T_OBJECT, OFF(_cache), 0, 0},
    {"_packages", T_OBJECT, OFF(_packages), 0, 0},
    {"_installed", T_OBJECT, OFF(_installed), 0, 0},
    {NULL}
};
#undef OFF

statichere PyTypeObject Loader_Type = {
	PyObject_HEAD_INIT(NULL)
	0,			/*ob_size*/
	"smart.cache.Loader",	/*tp_name*/
	sizeof(LoaderObject), /*tp_basicsize*/
	0,			/*tp_itemsize*/
	(destructor)Loader_dealloc, /*tp_dealloc*/
	0,			/*tp_print*/
	0,			/*tp_getattr*/
	0,			/*tp_setattr*/
	0,			/*tp_compare*/
	0,			/*tp_repr*/
	0,			/*tp_as_number*/
	0,			/*tp_as_sequence*/
	0,			/*tp_as_mapping*/
	(hashfunc)_Py_HashPointer, /*tp_hash*/
    0,                      /*tp_call*/
    0,                      /*tp_str*/
    PyObject_GenericGetAttr,/*tp_getattro*/
    PyObject_GenericSetAttr,/*tp_setattro*/
    0,                      /*tp_as_buffer*/
    Py_TPFLAGS_DEFAULT|Py_TPFLAGS_BASETYPE, /*tp_flags*/
    0,                      /*tp_doc*/
    0,                      /*tp_traverse*/
    0,                      /*tp_clear*/
    0,                      /*tp_richcompare*/
    0,                      /*tp_weaklistoffset*/
    0,                      /*tp_iter*/
    0,                      /*tp_iternext*/
    Loader_methods,         /*tp_methods*/
    Loader_members,         /*tp_members*/
    0,                      /*tp_getset*/
    0,                      /*tp_base*/
    0,                      /*tp_dict*/
    0,                      /*tp_descr_get*/
    0,                      /*tp_descr_set*/
    0,                      /*tp_dictoffset*/
    (initproc)Loader_init,  /*tp_init*/
    PyType_GenericAlloc,    /*tp_alloc*/
    PyType_GenericNew,      /*tp_new*/
    _PyObject_Del,          /*tp_free*/
    0,                      /*tp_is_gc*/
};

static int
Cache_init(CacheObject *self, PyObject *args)
{
    if (!PyArg_ParseTuple(args, ""))
        return -1;
    self->_loaders = PyList_New(0);
    self->_packages = PyList_New(0);
    self->_provides = PyList_New(0);
    self->_requires = PyList_New(0);
    self->_upgrades = PyList_New(0);
    self->_conflicts = PyList_New(0);
    self->_objmap = PyDict_New();
    return 0;
}

static void
Cache_dealloc(CacheObject *self)
{
    Py_XDECREF(self->_loaders);
    Py_XDECREF(self->_packages);
    Py_XDECREF(self->_provides);
    Py_XDECREF(self->_requires);
    Py_XDECREF(self->_upgrades);
    Py_XDECREF(self->_conflicts);
    Py_XDECREF(self->_objmap);
    self->ob_type->tp_free((PyObject *)self);
}

PyObject *
Cache_reset(CacheObject *self, PyObject *args)
{
    int i, len;
    len = PyList_GET_SIZE(self->_provides);
    for (i = 0; i != len; i++) {
        ProvidesObject *prvobj;
        PyObject *prv;
        prv = PyList_GET_ITEM(self->_provides, i);
        prvobj = (ProvidesObject *)prv;
        LIST_CLEAR(prvobj->packages);
        if (PyList_Check(prvobj->requiredby))
            LIST_CLEAR(prvobj->requiredby);
        if (PyList_Check(prvobj->upgradedby))
            LIST_CLEAR(prvobj->upgradedby);
        if (PyList_Check(prvobj->conflictedby))
            LIST_CLEAR(prvobj->conflictedby);
    }
    len = PyList_GET_SIZE(self->_requires);
    for (i = 0; i != len; i++) {
        DependsObject *reqobj;
        PyObject *req;
        req = PyList_GET_ITEM(self->_requires, i);
        reqobj = (DependsObject *)req;
        LIST_CLEAR(reqobj->packages);
        if (PyList_Check(reqobj->providedby))
            LIST_CLEAR(reqobj->providedby);
    }
    len = PyList_GET_SIZE(self->_upgrades);
    for (i = 0; i != len; i++) {
        DependsObject *upgobj;
        PyObject *upg;
        upg = PyList_GET_ITEM(self->_upgrades, i);
        upgobj = (DependsObject *)upg;
        LIST_CLEAR(upgobj->packages);
        if (PyList_Check(upgobj->providedby))
            LIST_CLEAR(upgobj->providedby);
    }
    len = PyList_GET_SIZE(self->_conflicts);
    for (i = 0; i != len; i++) {
        DependsObject *cnfobj;
        PyObject *cnf;
        cnf = PyList_GET_ITEM(self->_conflicts, i);
        cnfobj = (DependsObject *)cnf;
        LIST_CLEAR(cnfobj->packages);
        if (PyList_Check(cnfobj->providedby))
            LIST_CLEAR(cnfobj->providedby);
    }
    LIST_CLEAR(self->_packages);
    LIST_CLEAR(self->_provides);
    LIST_CLEAR(self->_requires);
    LIST_CLEAR(self->_upgrades);
    LIST_CLEAR(self->_conflicts);
    PyDict_Clear(self->_objmap);
    Py_RETURN_NONE;
}

PyObject *
Cache_addLoader(CacheObject *self, PyObject *loader)
{
    if (loader != Py_None) {
        int i, len;
        len = PyList_GET_SIZE(self->_loaders);
        for (i = 0; i != len; i++)
            if (loader == PyList_GET_ITEM(self->_loaders, i))
                break;
        if (i == len) {
            PyList_Append(self->_loaders, loader);
            CALLMETHOD(loader, "setCache", "O", self);
        }
    }
    Py_RETURN_NONE;
}

PyObject *
Cache_removeLoader(CacheObject *self, PyObject *loader)
{
    if (loader != Py_None) {
        int i, len;
        len = PyList_GET_SIZE(self->_loaders);
        for (i = len-1; i >= 0; i--)
            if (PyList_GET_ITEM(self->_loaders, i) == loader)
                PyList_SetSlice(self->_loaders, i, i+1, (PyObject *)NULL);
        if (i >= 0) {
            CALLMETHOD(loader, "setCache", "O", Py_None);
            CALLMETHOD(loader, "unload", NULL);
        }
    }
    Py_RETURN_NONE;
}

PyObject *
Cache__reload(CacheObject *self, PyObject *args)
{
    /*
      packages = {}
      provides = {}
      requires = {}
      upgrades = {}
      conflicts = {}
      objmap = self._objmap
    */
    PyObject *packages = PyDict_New();
    PyObject *provides = PyDict_New();
    PyObject *requires = PyDict_New();
    PyObject *upgrades = PyDict_New();
    PyObject *conflicts = PyDict_New();
    PyObject *objmap = self->_objmap;
    int i, ilen;
    if (!packages || !provides || !requires || !conflicts)
        return NULL;

    /* for loader in loaders: */
    ilen = PyList_GET_SIZE(self->_loaders);
    for (i = 0; i != ilen; i++) {
        LoaderObject *loader =
                        (LoaderObject *)PyList_GET_ITEM(self->_loaders, i);
        if (!PyObject_IsInstance((PyObject *)loader,
                                 (PyObject *)&Loader_Type)) {
            PyErr_SetString(PyExc_TypeError,
                            "Loader is not a Loader instance");
            return NULL;
        }

        /* for pkg in loader._packages: */
        int j, jlen;
        jlen = PyList_GET_SIZE(loader->_packages);
        for (j = 0; j != jlen; j++) {
            PackageObject *pkg = (PackageObject *)
                                    PyList_GET_ITEM(loader->_packages, j);
            if (!PyObject_IsInstance((PyObject *)pkg,
                                     (PyObject *)&Package_Type)) {
                PyErr_SetString(PyExc_TypeError,
                                "Package is not a Package instance");
                return NULL;
            }

            /* if pkg in packages: */
            if (PyDict_GetItem(packages, (PyObject *)pkg)) {

                /* pkg.installed |= loader._installed */
                if (loader->_installed == Py_True) {
                    Py_DECREF(pkg->installed);
                    pkg->installed = loader->_installed;
                    Py_INCREF(pkg->installed);
                }

            } else {

                PyObject *args;
                PyObject *lst;
                int k, klen;
                int l, llen;

                /* pkg.installed = loader._installed */
                Py_DECREF(pkg->installed);
                pkg->installed = loader->_installed;
                Py_INCREF(pkg->installed);

                /* packages[pkg] = True */
                PyDict_SetItem(packages, (PyObject *)pkg, Py_True);
                
                /* objmap.setdefault(pkg.getInitArgs(), []).append(pkg) */
                args = PyObject_CallMethod((PyObject *)pkg, "getInitArgs",
                                           NULL);
                if (!args) return NULL;
                lst = PyDict_GetItem(objmap, args);
                if (!lst) {
                    lst = PyList_New(0);
                    PyDict_SetItem(objmap, args, lst);
                    Py_DECREF(lst);
                }
                PyList_Append(lst, (PyObject *)pkg);
                Py_DECREF(args);

                /*
                 for pkgloader in pkg.loaders.keys():
                     if pkgloader not in loaders:
                         del pkg.loaders[pkgloader]
                */
                lst = PyDict_Keys(pkg->loaders);
                klen = PyList_GET_SIZE(lst);
                for (k = 0; k != klen; k++) {
                    PyObject *pkgloader = PyList_GET_ITEM(lst, k);
                    llen = PyList_GET_SIZE(self->_loaders);
                    for (l = 0; l != llen; l++) {
                        if (PyList_GET_ITEM(self->_loaders, l) == pkgloader)
                            break;
                    }
                    if (l == llen)
                        PyDict_DelItem(pkg->loaders, pkgloader);
                }
                
                /*
                   for prv in pkg.provides:
                       prv.packages.append(pkg)
                       if prv not in provides:
                           provides[prv] = True
                           objmap[prv.getInitArgs()] = prv
                */
                if (PyList_Check(pkg->provides)) {
                    klen = PyList_GET_SIZE(pkg->provides);
                    for (k = 0; k != klen; k++) {
                        PyObject *prv = PyList_GET_ITEM(pkg->provides, k);
                        PyList_Append(((ProvidesObject *)prv)->packages,
                                      (PyObject *)pkg);
                        if (!PyDict_GetItem(provides, prv)) {
                            PyDict_SetItem(provides, prv, Py_True);
                            args = PyObject_CallMethod(prv, "getInitArgs",
                                                       NULL);
                            if (!args) return NULL;
                            PyDict_SetItem(objmap, args, prv);
                            Py_DECREF(args);
                        }
                    }
                }
                
                /*
                   for req in pkg.requires:
                       req.packages.append(pkg)
                       if req not in requires:
                           requires[req] = True
                           objmap[req.getInitArgs()] = req
                */
                if (PyList_Check(pkg->requires)) {
                    klen = PyList_GET_SIZE(pkg->requires);
                    for (k = 0; k != klen; k++) {
                        PyObject *req = PyList_GET_ITEM(pkg->requires, k);
                        PyList_Append(((DependsObject *)req)->packages,
                                      (PyObject *)pkg);
                        if (!PyDict_GetItem(requires, req)) {
                            PyDict_SetItem(requires, req, Py_True);
                            args = PyObject_CallMethod(req, "getInitArgs",
                                                       NULL);
                            if (!args) return NULL;
                            PyDict_SetItem(objmap, args, req);
                            Py_DECREF(args);
                        }
                    }
                }

                /*
                   for upg in pkg.upgrades:
                       upg.packages.append(pkg)
                       if upg not in upgrades:
                           upgrades[upg] = True
                           objmap[upg.getInitArgs()] = upg
                */
                if (PyList_Check(pkg->upgrades)) {
                    klen = PyList_GET_SIZE(pkg->upgrades);
                    for (k = 0; k != klen; k++) {
                        PyObject *upg = PyList_GET_ITEM(pkg->upgrades, k);
                        PyList_Append(((DependsObject *)upg)->packages,
                                      (PyObject *)pkg);
                        if (!PyDict_GetItem(upgrades, upg)) {
                            PyDict_SetItem(upgrades, upg, Py_True);
                            args = PyObject_CallMethod(upg, "getInitArgs",
                                                       NULL);
                            if (!args) return NULL;
                            PyDict_SetItem(objmap, args, upg);
                            Py_DECREF(args);
                        }
                    }
                }
                
                /*
                   for cnf in pkg.conflicts:
                       cnf.packages.append(pkg)
                       if cnf not in conflicts:
                           conflicts[cnf] = True
                           objmap[cnf.getInitArgs()] = cnf
                */
                if (PyList_Check(pkg->conflicts)) {
                    klen = PyList_GET_SIZE(pkg->conflicts);
                    for (k = 0; k != klen; k++) {
                        PyObject *cnf = PyList_GET_ITEM(pkg->conflicts, k);
                        PyList_Append(((DependsObject *)cnf)->packages,
                                      (PyObject *)pkg);
                        if (!PyDict_GetItem(conflicts, cnf)) {
                            PyDict_SetItem(conflicts, cnf, Py_True);
                            args = PyObject_CallMethod(cnf, "getInitArgs",
                                                       NULL);
                            if (!args) return NULL;
                            PyDict_SetItem(objmap, args, cnf);
                            Py_DECREF(args);
                        }
                    }
                }


            }
        }
    }


    /* self._packages[:] = packages.keys() */
    Py_DECREF(self->_packages);
    self->_packages = PyDict_Keys(packages);
    Py_DECREF(packages);

    /* self._provides[:] = provides.keys() */
    Py_DECREF(self->_provides);
    self->_provides = PyDict_Keys(provides);
    Py_DECREF(provides);

    /* self._requires[:] = requires.keys() */
    Py_DECREF(self->_requires);
    self->_requires = PyDict_Keys(requires);
    Py_DECREF(requires);

    /* self._upgrades[:] = upgrades.keys() */
    Py_DECREF(self->_upgrades);
    self->_upgrades = PyDict_Keys(upgrades);
    Py_DECREF(upgrades);

    /* self._conflicts[:] = conflicts.keys() */
    Py_DECREF(self->_conflicts);
    self->_conflicts = PyDict_Keys(conflicts);
    Py_DECREF(conflicts);

    Py_INCREF(Py_None);
    return Py_None;
}

PyObject *
Cache_load(CacheObject *self, PyObject *args)
{
    int i, len;
    int total = 1;
    PyObject *prog;
    Cache__reload(self, NULL);
    prog = PyObject_CallMethod(getIface(), "getProgress", "OO",
                               self, Py_False);
    CALLMETHOD(prog, "start", NULL);
    CALLMETHOD(prog, "setTopic", "O", _("Updating cache..."));
    CALLMETHOD(prog, "set", "ii", 0, 1);
    CALLMETHOD(prog, "show", NULL);
    len = PyList_GET_SIZE(self->_loaders);
    for (i = 0; i != len; i++) {
        PyObject *loader = PyList_GET_ITEM(self->_loaders, i);
        if (PyList_GET_SIZE(((LoaderObject *)loader)->_packages) == 0) {
            PyObject *res = PyObject_CallMethod(loader, "getLoadSteps", NULL);
            if (!res) return NULL;
            total += PyInt_AsLong(res);
            Py_DECREF(res);
        }
    }
    CALLMETHOD(prog, "set", "ii", 0, total);
    CALLMETHOD(prog, "show", NULL);
    len = PyList_GET_SIZE(self->_loaders);
    for (i = 0; i != len; i++) {
        PyObject *loader = PyList_GET_ITEM(self->_loaders, i);
        if (PyList_GET_SIZE(((LoaderObject *)loader)->_packages) == 0)
            CALLMETHOD(loader, "load", NULL);
    }
    CALLMETHOD(self, "loadFileProvides", NULL);
    PyDict_Clear(self->_objmap);
    CALLMETHOD(self, "linkDeps", NULL);
    CALLMETHOD(prog, "setDone", NULL);
    CALLMETHOD(prog, "show", NULL);
    CALLMETHOD(prog, "stop", NULL);
    Py_RETURN_NONE;
}

PyObject *
Cache_unload(CacheObject *self, PyObject *args)
{
    int i, len;
    CALLMETHOD(self, "reset", NULL);
    len = PyList_GET_SIZE(self->_loaders);
    for (i = 0; i != len; i++) {
        PyObject *loader = PyList_GET_ITEM(self->_loaders, i);
        CALLMETHOD(loader, "unload", NULL);
    }
    Py_RETURN_NONE;
}

PyObject *
Cache_loadFileProvides(CacheObject *self, PyObject *args)
{
    PyObject *fndict = PyDict_New();
    int i, len;
    len = PyList_GET_SIZE(self->_requires);
    for (i = 0; i != len; i++) {
        DependsObject *req =
            (DependsObject *)PyList_GET_ITEM(self->_requires, i);
        if (STR(req->name)[0] == '/')
            PyDict_SetItem(fndict, req->name, req->name);
    }
    len = PyList_GET_SIZE(self->_loaders);
    for (i = 0; i != len; i++) {
        PyObject *loader = PyList_GET_ITEM(self->_loaders, i);
        CALLMETHOD(loader, "loadFileProvides", "O", fndict);
    }
    Py_RETURN_NONE;
}

PyObject *
Cache_linkDeps(CacheObject *self, PyObject *args)
{
    int i, j, len;
    PyObject *reqnames, *upgnames, *cnfnames;
    PyObject *lst;

    /* reqnames = {} */
    reqnames = PyDict_New();
    /* for req in self._requires: */
    len = PyList_GET_SIZE(self->_requires);
    for (i = 0; i != len; i++) {
        PyObject *req = PyList_GET_ITEM(self->_requires, i);

        /* for name in req.getMatchNames(): */
        PyObject *names = PyObject_CallMethod(req, "getMatchNames", NULL);
        PyObject *seq = PySequence_Fast(names, "getMatchNames() returned "
                                               "non-sequence object");
        int nameslen;
        if (!seq) return NULL;
        nameslen = PySequence_Fast_GET_SIZE(seq);
        for (j = 0; j != nameslen; j++) {
            PyObject *name = PySequence_Fast_GET_ITEM(seq, j);
            
            /* lst = reqnames.get(name) */
            lst = PyDict_GetItem(reqnames, name);

            /* 
               if lst:
                   lst.append(req)
               else:
                   reqnames[name] = [req]
            */
            if (lst) {
                PyList_Append(lst, req);
            } else {
                lst = PyList_New(1);
                Py_INCREF(req);
                PyList_SET_ITEM(lst, 0, req);
                PyDict_SetItem(reqnames, name, lst);
                Py_DECREF(lst);
            }
        }

        Py_DECREF(names);
        Py_DECREF(seq);
    }

    /* upgnames = {} */
    upgnames = PyDict_New();
    /* for upg in self._upgrades: */
    len = PyList_GET_SIZE(self->_upgrades);
    for (i = 0; i != len; i++) {
        PyObject *upg = PyList_GET_ITEM(self->_upgrades, i);

        /* for name in upg.getMatchNames(): */
        PyObject *names = PyObject_CallMethod(upg, "getMatchNames", NULL);
        PyObject *seq = PySequence_Fast(names, "getMatchNames() returned "
                                               "non-sequence object");
        int nameslen;
        if (!seq) return NULL;
        nameslen = PySequence_Fast_GET_SIZE(seq);
        for (j = 0; j != nameslen; j++) {
            PyObject *name = PySequence_Fast_GET_ITEM(seq, j);
            
            /* lst = upgnames.get(name) */
            lst = PyDict_GetItem(upgnames, name);

            /* 
               if lst:
                   lst.append(upg)
               else:
                   upgnames[name] = [upg]
            */
            if (lst) {
                PyList_Append(lst, upg);
            } else {
                lst = PyList_New(1);
                Py_INCREF(upg);
                PyList_SET_ITEM(lst, 0, upg);
                PyDict_SetItem(upgnames, name, lst);
                Py_DECREF(lst);
            }
        }

        Py_DECREF(names);
        Py_DECREF(seq);
    }

    /* cnfnames = {} */
    cnfnames = PyDict_New();
    /* for cnf in self._conflicts: */
    len = PyList_GET_SIZE(self->_conflicts);
    for (i = 0; i != len; i++) {
        PyObject *cnf = PyList_GET_ITEM(self->_conflicts, i);

        /* for name in cnf.getMatchNames(): */
        PyObject *names = PyObject_CallMethod(cnf, "getMatchNames", NULL);
        PyObject *seq = PySequence_Fast(names, "getMatchNames() returned "
                                               "non-sequence object");
        int nameslen;
        if (!seq) return NULL;
        nameslen = PySequence_Fast_GET_SIZE(seq);
        for (j = 0; j != nameslen; j++) {
            PyObject *name = PySequence_Fast_GET_ITEM(seq, j);
            
            /* lst = cnfnames.get(name) */
            lst = PyDict_GetItem(cnfnames, name);

            /* 
               if lst:
                   lst.append(cnf)
               else:
                   cnfnames[name] = [cnf]
            */
            if (lst) {
                PyList_Append(lst, cnf);
            } else {
                lst = PyList_New(1);
                Py_INCREF(cnf);
                PyList_SET_ITEM(lst, 0, cnf);
                PyDict_SetItem(cnfnames, name, lst);
                Py_DECREF(lst);
            }
        }

        Py_DECREF(names);
        Py_DECREF(seq);
    }

    /* for prv in self._provides: */
    len = PyList_GET_SIZE(self->_provides);
    for (i = 0; i != len; i++) {
        ProvidesObject *prv;

        prv = (ProvidesObject *)PyList_GET_ITEM(self->_provides, i);

        /* lst = reqnames.get(prv.name) */
        lst = PyDict_GetItem(reqnames, prv->name);

        /* if lst: */
        if (lst) {
            /* for req in lst: */
            int reqlen = PyList_GET_SIZE(lst);
            for (j = 0; j != reqlen; j++) {
                DependsObject *req = (DependsObject *)PyList_GET_ITEM(lst, j);
                /* if req.matches(prv): */
                PyObject *ret = PyObject_CallMethod((PyObject *)req, "matches",
                                                    "O", (PyObject *)prv);
                if (!ret) return NULL;
                if (PyObject_IsTrue(ret)) {
                    /*
                       if req.providedby:
                           req.providedby.append(prv)
                       else:
                           req.providedby = [prv]
                    */
                    if (PyList_Check(req->providedby)) {
                        PyList_Append(req->providedby, (PyObject *)prv);
                    } else {
                        PyObject *_lst = PyList_New(1);
                        Py_INCREF(prv);
                        PyList_SET_ITEM(_lst, 0, (PyObject *)prv);
                        Py_DECREF(req->providedby);
                        req->providedby = _lst;
                    }

                    /*
                       if prv.requiredby:
                           prv.requiredby.append(prv)
                       else:
                           prv.requiredby = [prv]
                    */
                    if (PyList_Check(prv->requiredby)) {
                        PyList_Append(prv->requiredby, (PyObject *)req);
                    } else {
                        PyObject *_lst = PyList_New(1);
                        Py_INCREF(req);
                        PyList_SET_ITEM(_lst, 0, (PyObject *)req);
                        Py_DECREF(prv->requiredby);
                        prv->requiredby = _lst;
                    }
                }
                Py_DECREF(ret);
            }
        }

        /* lst = upgnames.get(prv.name) */
        lst = PyDict_GetItem(upgnames, prv->name);

        /* if lst: */
        if (lst) {

            /* for upg in lst: */
            int upglen = PyList_GET_SIZE(lst);
            for (j = 0; j != upglen; j++) {
                DependsObject *upg = (DependsObject *)PyList_GET_ITEM(lst, j);
                /* if upg.matches(prv): */
                PyObject *ret = PyObject_CallMethod((PyObject *)upg, "matches",
                                                    "O", (PyObject *)prv);
                if (!ret) return NULL;
                if (PyObject_IsTrue(ret)) {
                    /*
                       if upg.providedby:
                           upg.providedby.append(prv)
                       else:
                           upg.providedby = [prv]
                    */
                    if (PyList_Check(upg->providedby)) {
                        PyList_Append(upg->providedby, (PyObject *)prv);
                    } else {
                        PyObject *_lst = PyList_New(1);
                        Py_INCREF(prv);
                        PyList_SET_ITEM(_lst, 0, (PyObject *)prv);
                        Py_DECREF(upg->providedby);
                        upg->providedby = _lst;
                    }

                    /*
                       if prv.upgradedby:
                           prv.upgradedby.append(prv)
                       else:
                           prv.upgradedby = [prv]
                    */
                    if (PyList_Check(prv->upgradedby)) {
                        PyList_Append(prv->upgradedby, (PyObject *)upg);
                    } else {
                        PyObject *_lst = PyList_New(1);
                        Py_INCREF(upg);
                        PyList_SET_ITEM(_lst, 0, (PyObject *)upg);
                        Py_DECREF(prv->upgradedby);
                        prv->upgradedby = _lst;
                    }
                }
                Py_DECREF(ret);
            }
        }

        /* lst = cnfnames.get(prv.name) */
        lst = PyDict_GetItem(cnfnames, prv->name);

        /* if lst: */
        if (lst) {

            /* for cnf in lst: */
            int cnflen = PyList_GET_SIZE(lst);
            for (j = 0; j != cnflen; j++) {
                DependsObject *cnf = (DependsObject *)PyList_GET_ITEM(lst, j);
                /* if cnf.matches(prv): */
                PyObject *ret = PyObject_CallMethod((PyObject *)cnf, "matches",
                                                    "O", (PyObject *)prv);
                if (!ret) return NULL;
                if (PyObject_IsTrue(ret)) {
                    /*
                       if cnf.providedby:
                           cnf.providedby.append(prv)
                       else:
                           cnf.providedby = [prv]
                    */
                    if (PyList_Check(cnf->providedby)) {
                        PyList_Append(cnf->providedby, (PyObject *)prv);
                    } else {
                        PyObject *_lst = PyList_New(1);
                        Py_INCREF(prv);
                        PyList_SET_ITEM(_lst, 0, (PyObject *)prv);
                        Py_DECREF(cnf->providedby);
                        cnf->providedby = _lst;
                    }

                    /*
                       if prv.conflictedby:
                           prv.conflictedby.append(prv)
                       else:
                           prv.conflictedby = [prv]
                    */
                    if (PyList_Check(prv->conflictedby)) {
                        PyList_Append(prv->conflictedby, (PyObject *)cnf);
                    } else {
                        PyObject *_lst = PyList_New(1);
                        Py_INCREF(cnf);
                        PyList_SET_ITEM(_lst, 0, (PyObject *)cnf);
                        Py_DECREF(prv->conflictedby);
                        prv->conflictedby = _lst;
                    }
                }
                Py_DECREF(ret);
            }
        }
    }

    Py_DECREF(reqnames);
    Py_DECREF(upgnames);
    Py_DECREF(cnfnames);

    Py_RETURN_NONE;
}

PyObject *
Cache_getPackages(CacheObject *self, PyObject *args)
{
    const char *name = NULL;
    PyObject *lst;
    int i, len;
    if (!PyArg_ParseTuple(args, "|s", &name))
        return NULL;
    if (!name) {
        Py_INCREF(self->_packages);
        return self->_packages;
    }
    lst = PyList_New(0);
    len = PyList_GET_SIZE(self->_packages);
    for (i = 0; i != len; i++) {
        PackageObject *pkg =
            (PackageObject*)PyList_GET_ITEM(self->_packages, i);
        if (strcmp(STR(pkg->name), name) == 0)
            PyList_Append(lst, (PyObject *)pkg);
    }
    return lst;
}

PyObject *
Cache_getProvides(CacheObject *self, PyObject *args)
{
    const char *name = NULL;
    PyObject *lst;
    int i, len;
    if (!PyArg_ParseTuple(args, "|s", &name))
        return NULL;
    if (!name) {
        Py_INCREF(self->_provides);
        return self->_provides;
    }
    lst = PyList_New(0);
    len = PyList_GET_SIZE(self->_provides);
    for (i = 0; i != len; i++) {
        ProvidesObject *prv =
            (ProvidesObject*)PyList_GET_ITEM(self->_provides, i);
        if (strcmp(STR(prv->name), name) == 0)
            PyList_Append(lst, (PyObject *)prv);
    }
    return lst;
}

PyObject *
Cache_getRequires(CacheObject *self, PyObject *args)
{
    const char *name = NULL;
    PyObject *lst;
    int i, len;
    if (!PyArg_ParseTuple(args, "|s", &name))
        return NULL;
    if (!name) {
        Py_INCREF(self->_requires);
        return self->_requires;
    }
    lst = PyList_New(0);
    len = PyList_GET_SIZE(self->_requires);
    for (i = 0; i != len; i++) {
        DependsObject *req =
            (DependsObject*)PyList_GET_ITEM(self->_requires, i);
        if (strcmp(STR(req->name), name) == 0)
            PyList_Append(lst, (PyObject *)req);
    }
    return lst;
}

PyObject *
Cache_getUpgrades(CacheObject *self, PyObject *args)
{
    const char *name = NULL;
    PyObject *lst;
    int i, len;
    if (!PyArg_ParseTuple(args, "|s", &name))
        return NULL;
    if (!name) {
        Py_INCREF(self->_upgrades);
        return self->_upgrades;
    }
    lst = PyList_New(0);
    len = PyList_GET_SIZE(self->_upgrades);
    for (i = 0; i != len; i++) {
        DependsObject *upg =
            (DependsObject*)PyList_GET_ITEM(self->_upgrades, i);
        if (strcmp(STR(upg->name), name) == 0)
            PyList_Append(lst, (PyObject *)upg);
    }
    return lst;
}

PyObject *
Cache_getConflicts(CacheObject *self, PyObject *args)
{
    const char *name = NULL;
    PyObject *lst;
    int i, len;
    if (!PyArg_ParseTuple(args, "|s", &name))
        return NULL;
    if (!name) {
        Py_INCREF(self->_conflicts);
        return self->_conflicts;
    }
    lst = PyList_New(0);
    len = PyList_GET_SIZE(self->_conflicts);
    for (i = 0; i != len; i++) {
        DependsObject *cnf =
            (DependsObject*)PyList_GET_ITEM(self->_conflicts, i);
        if (strcmp(STR(cnf->name), name) == 0)
            PyList_Append(lst, (PyObject *)cnf);
    }
    return lst;
}

PyObject *
Cache_search(CacheObject *self, PyObject *searcher)
{
    PyObject *lst, *res;
    int i, j, k;

    lst = PyObject_GetAttrString(searcher, "nameversion");
    if (lst == NULL || !PyList_Check(lst)) {
        PyErr_SetString(PyExc_TypeError, "Invalid provides attribute");
        return NULL;
    }
    if (PyList_GET_SIZE(lst) != 0) {
        for (i = 0; i != PyList_GET_SIZE(self->_packages); i++) {
            PyObject *pkg = PyList_GET_ITEM(self->_packages, i);
            CALLMETHOD(pkg, "search", "O", searcher);
        }
    }
    Py_DECREF(lst);

    lst = PyObject_GetAttrString(searcher, "provides");
    if (lst == NULL || !PyList_Check(lst)) {
        PyErr_SetString(PyExc_TypeError, "Invalid provides attribute");
        return NULL;
    }
    if (PyList_GET_SIZE(lst) != 0) {
        for (i = 0; i != PyList_GET_SIZE(self->_provides); i++) {
            PyObject *prv = PyList_GET_ITEM(self->_provides, i);
            CALLMETHOD(prv, "search", "O", searcher);
        }
    }
    Py_DECREF(lst);

    lst = PyObject_GetAttrString(searcher, "requires");
    if (lst == NULL || !PyList_Check(lst)) {
        PyErr_SetString(PyExc_TypeError, "Invalid requires attribute");
        return NULL;
    }
    for (i = 0; i != PyList_GET_SIZE(lst); i++) {
        ProvidesObject *prv = (ProvidesObject *)PyList_GET_ITEM(lst, i);
        for (j = 0; j != PyList_GET_SIZE(self->_requires); j++) {
            PyObject *req = PyList_GET_ITEM(self->_requires, j);
            PyObject *names = PyObject_CallMethod(req, "getMatchNames", NULL);
            PyObject *seq = PySequence_Fast(names, "getMatchNames() returned "
                                                   "non-sequence object");
            if (seq == NULL) return NULL;
            for (k = 0; k != PySequence_Fast_GET_SIZE(seq); k++) {
                if (strcmp(PyString_AS_STRING(PySequence_Fast_GET_ITEM(seq, k)),
                           PyString_AS_STRING(prv->name)) == 0) {
                    res = PyObject_CallMethod(req, "matches", "O", prv);
                    if (res == NULL)
                        return NULL;
                    if (PyObject_IsTrue(res))
                        CALLMETHOD(searcher, "addResult", "O", req);
                    Py_DECREF(res);
                    break;
                }
            }

            Py_DECREF(names);
            Py_DECREF(seq);
        }
    }
    Py_DECREF(lst);

    lst = PyObject_GetAttrString(searcher, "upgrades");
    if (lst == NULL || !PyList_Check(lst)) {
        PyErr_SetString(PyExc_TypeError, "Invalid upgrades attribute");
        return NULL;
    }
    for (i = 0; i != PyList_GET_SIZE(lst); i++) {
        ProvidesObject *prv = (ProvidesObject *)PyList_GET_ITEM(lst, i);
        for (j = 0; j != PyList_GET_SIZE(self->_upgrades); j++) {
            PyObject *upg = PyList_GET_ITEM(self->_upgrades, j);
            PyObject *names = PyObject_CallMethod(upg, "getMatchNames", NULL);
            PyObject *seq = PySequence_Fast(names, "getMatchNames() returned "
                                                   "non-sequence object");
            if (seq == NULL) return NULL;
            for (k = 0; k != PySequence_Fast_GET_SIZE(seq); k++) {
                if (strcmp(PyString_AS_STRING(PySequence_Fast_GET_ITEM(seq, k)),
                           PyString_AS_STRING(prv->name)) == 0) {
                    res = PyObject_CallMethod(upg, "matches", "O", prv);
                    if (res == NULL)
                        return NULL;
                    if (PyObject_IsTrue(res))
                        CALLMETHOD(searcher, "addResult", "O", upg);
                    Py_DECREF(res);
                    break;
                }
            }

            Py_DECREF(names);
            Py_DECREF(seq);
        }
    }
    Py_DECREF(lst);

    lst = PyObject_GetAttrString(searcher, "conflicts");
    if (lst == NULL || !PyList_Check(lst)) {
        PyErr_SetString(PyExc_TypeError, "Invalid conflicts attribute");
        return NULL;
    }
    for (i = 0; i != PyList_GET_SIZE(lst); i++) {
        ProvidesObject *prv = (ProvidesObject *)PyList_GET_ITEM(lst, i);
        for (j = 0; j != PyList_GET_SIZE(self->_conflicts); j++) {
            PyObject *cnf = PyList_GET_ITEM(self->_conflicts, j);
            PyObject *names = PyObject_CallMethod(cnf, "getMatchNames", NULL);
            PyObject *seq = PySequence_Fast(names, "getMatchNames() returned "
                                                   "non-sequence object");
            if (seq == NULL) return NULL;
            for (k = 0; k != PySequence_Fast_GET_SIZE(seq); k++) {
                if (strcmp(PyString_AS_STRING(PySequence_Fast_GET_ITEM(seq, k)),
                           PyString_AS_STRING(prv->name)) == 0) {
                    res = PyObject_CallMethod(cnf, "matches", "O", prv);
                    if (res == NULL)
                        return NULL;
                    if (PyObject_IsTrue(res))
                        CALLMETHOD(searcher, "addResult", "O", cnf);
                    Py_DECREF(res);
                    break;
                }
            }

            Py_DECREF(names);
            Py_DECREF(seq);
        }
    }
    Py_DECREF(lst);

    res = PyObject_CallMethod(searcher, "needsPackageInfo", NULL);
    if (res == NULL)
        return NULL;
    if (PyObject_IsTrue(res)) {    
        for (i = 0; i != PyList_GET_SIZE(self->_loaders); i++)
            CALLMETHOD(PyList_GET_ITEM(self->_loaders, i),
                       "search", "O", searcher);
    }
    Py_DECREF(res);

    Py_INCREF(Py_None);
    return Py_None;
}


#define Cache__stateversion__ 1

static PyObject *
Cache__getstate__(CacheObject *self, PyObject *args)
{
    PyObject *state = PyDict_New();
    if (!state) return NULL;
    PyDict_SetItemString(state, "__stateversion__",
                         PyInt_FromLong(Cache__stateversion__));
    PyDict_SetItemString(state, "_loaders", self->_loaders);
    PyDict_SetItemString(state, "_packages", self->_packages);
    return state;
}

static PyObject *
Cache__setstate__(CacheObject *self, PyObject *state)
{
    PyObject *provides, *requires, *upgrades, *conflicts;
    int i, ilen;
    int j, jlen;
    
    /*
      if state["__stateversion__"] != self.__stateversion__:
          raise StateVersionError
    */
    PyObject *__stateversion__;
    if (!PyDict_Check(state)) {
        PyErr_SetString(StateVersionError, "");
        return NULL;
    }
    __stateversion__ = PyDict_GetItemString(state, "__stateversion__");
    if (!__stateversion__ || !PyInt_Check(__stateversion__) ||
        PyInt_AsLong(__stateversion__) != Cache__stateversion__) {
        PyErr_SetString(StateVersionError, "");
        return NULL;
    }

    /*
       self->_loaders = state["_loaders"]
       self->_packages = state["_packages"]
    */
    self->_loaders = PyDict_GetItemString(state, "_loaders");
    self->_packages = PyDict_GetItemString(state, "_packages");
    Py_INCREF(self->_loaders);
    Py_INCREF(self->_packages);

    /*
       provides = {}
       requires = {}
       upgrades = {}
       conflicts = {}
    */
    provides = PyDict_New();
    requires = PyDict_New();
    upgrades = PyDict_New();
    conflicts = PyDict_New();

    /* for pkg in self._packages: */
    ilen = PyList_GET_SIZE(self->_packages);
    for (i = 0; i != ilen; i++) {
        PyObject *pkg = PyList_GET_ITEM(self->_packages, i);
        PackageObject *pkgobj = (PackageObject *)pkg;

        /*
           for prv in pkg.provides:
               prv.packages.append(pkg)
               provides[prv] = True
        */
        if (PyList_Check(pkgobj->provides)) {
            jlen = PyList_GET_SIZE(pkgobj->provides);
            for (j = 0; j != jlen; j++) {
                PyObject *prv = PyList_GET_ITEM(pkgobj->provides, j);
                ProvidesObject *prvobj = (ProvidesObject *)prv;
                PyList_Append(prvobj->packages, pkg);
                PyDict_SetItem(provides, prv, Py_True);
            }
        }

        /*
           for req in pkg.requires:
               req.packages.append(pkg)
               requires[req] = True
        */
        if (PyList_Check(pkgobj->requires)) {
            jlen = PyList_GET_SIZE(pkgobj->requires);
            for (j = 0; j != jlen; j++) {
                PyObject *req = PyList_GET_ITEM(pkgobj->requires, j);
                DependsObject *reqobj = (DependsObject *)req;
                PyList_Append(reqobj->packages, pkg);
                PyDict_SetItem(requires, req, Py_True);
            }
        }

        /*
           for upg in pkg.upgrades:
               upg.packages.append(pkg)
               upgrades[upg] = True
        */
        if (PyList_Check(pkgobj->upgrades)) {
            jlen = PyList_GET_SIZE(pkgobj->upgrades);
            for (j = 0; j != jlen; j++) {
                PyObject *upg = PyList_GET_ITEM(pkgobj->upgrades, j);
                DependsObject *upgobj = (DependsObject *)upg;
                PyList_Append(upgobj->packages, pkg);
                PyDict_SetItem(upgrades, upg, Py_True);
            }
        }

        /*
           for cnf in pkg.conflicts:
               cnf.packages.append(pkg)
               conflicts[cnf] = True
        */
        if (PyList_Check(pkgobj->conflicts)) {
            jlen = PyList_GET_SIZE(pkgobj->conflicts);
            for (j = 0; j != jlen; j++) {
                PyObject *cnf = PyList_GET_ITEM(pkgobj->conflicts, j);
                DependsObject *cnfobj = (DependsObject *)cnf;
                PyList_Append(cnfobj->packages, pkg);
                PyDict_SetItem(conflicts, cnf, Py_True);
            }
        }
    }

    /* self._provides = provides.keys() */
    self->_provides = PyDict_Keys(provides);
    Py_DECREF(provides);

    /* self._requires = requires.keys() */
    self->_requires = PyDict_Keys(requires);
    Py_DECREF(requires);

    /* self._upgrades = upgrades.keys() */
    self->_upgrades = PyDict_Keys(upgrades);
    Py_DECREF(upgrades);

    /* self._conflicts = conflicts.keys() */
    self->_conflicts = PyDict_Keys(conflicts);
    Py_DECREF(conflicts);

    /* self._objmap = {} */
    self->_objmap = PyDict_New();
    
    Py_INCREF(Py_None);
    return Py_None;
}

static PyMethodDef Cache_methods[] = {
    {"reset", (PyCFunction)Cache_reset, METH_VARARGS, NULL},
    {"addLoader", (PyCFunction)Cache_addLoader, METH_O, NULL},
    {"removeLoader", (PyCFunction)Cache_removeLoader, METH_O, NULL},
    {"_reload", (PyCFunction)Cache__reload, METH_NOARGS, NULL},
    {"load", (PyCFunction)Cache_load, METH_NOARGS, NULL},
    {"unload", (PyCFunction)Cache_unload, METH_NOARGS, NULL},
    {"loadFileProvides", (PyCFunction)Cache_loadFileProvides, METH_NOARGS, NULL},
    {"linkDeps", (PyCFunction)Cache_linkDeps, METH_VARARGS, NULL},
    {"getPackages", (PyCFunction)Cache_getPackages, METH_VARARGS, NULL},
    {"getProvides", (PyCFunction)Cache_getProvides, METH_VARARGS, NULL},
    {"getRequires", (PyCFunction)Cache_getRequires, METH_VARARGS, NULL},
    {"getUpgrades", (PyCFunction)Cache_getUpgrades, METH_VARARGS, NULL},
    {"getConflicts", (PyCFunction)Cache_getConflicts, METH_VARARGS, NULL},
    {"search", (PyCFunction)Cache_search, METH_O, NULL},
    {"__getstate__", (PyCFunction)Cache__getstate__, METH_NOARGS, NULL},
    {"__setstate__", (PyCFunction)Cache__setstate__, METH_O, NULL},
    {NULL, NULL}
};

#define OFF(x) offsetof(CacheObject, x)
static PyMemberDef Cache_members[] = {
    {"_loaders", T_OBJECT, OFF(_loaders), RO, 0},
    {"_packages", T_OBJECT, OFF(_packages), RO, 0},
    {"_provides", T_OBJECT, OFF(_provides), RO, 0},
    {"_requires", T_OBJECT, OFF(_requires), RO, 0},
    {"_upgrades", T_OBJECT, OFF(_upgrades), RO, 0},
    {"_conflicts", T_OBJECT, OFF(_conflicts), RO, 0},
    {"_objmap", T_OBJECT, OFF(_objmap), RO, 0},
    {NULL}
};
#undef OFF

statichere PyTypeObject Cache_Type = {
	PyObject_HEAD_INIT(NULL)
	0,			/*ob_size*/
	"smart.cache.Cache",	/*tp_name*/
	sizeof(CacheObject), /*tp_basicsize*/
	0,			/*tp_itemsize*/
	(destructor)Cache_dealloc, /*tp_dealloc*/
	0,			/*tp_print*/
	0,			/*tp_getattr*/
	0,			/*tp_setattr*/
	0,			/*tp_compare*/
	0,			/*tp_repr*/
	0,			/*tp_as_number*/
	0,			/*tp_as_sequence*/
	0,			/*tp_as_mapping*/
	(hashfunc)_Py_HashPointer, /*tp_hash*/
    0,                      /*tp_call*/
    0,                      /*tp_str*/
    PyObject_GenericGetAttr,/*tp_getattro*/
    PyObject_GenericSetAttr,/*tp_setattro*/
    0,                      /*tp_as_buffer*/
    Py_TPFLAGS_DEFAULT|Py_TPFLAGS_BASETYPE, /*tp_flags*/
    0,                      /*tp_doc*/
    0,                      /*tp_traverse*/
    0,                      /*tp_clear*/
    0,                      /*tp_richcompare*/
    0,                      /*tp_weaklistoffset*/
    0,                      /*tp_iter*/
    0,                      /*tp_iternext*/
    Cache_methods,         /*tp_methods*/
    Cache_members,         /*tp_members*/
    0,                      /*tp_getset*/
    0,                      /*tp_base*/
    0,                      /*tp_dict*/
    0,                      /*tp_descr_get*/
    0,                      /*tp_descr_set*/
    0,                      /*tp_dictoffset*/
    (initproc)Cache_init,  /*tp_init*/
    PyType_GenericAlloc,    /*tp_alloc*/
    PyType_GenericNew,      /*tp_new*/
    _PyObject_Del,          /*tp_free*/
    0,                      /*tp_is_gc*/
};


static PyMethodDef ccache_methods[] = {
    {NULL, NULL}
};

DL_EXPORT(void)
initccache(void)
{
    PyObject *m, *o;
    Package_Type.ob_type = &PyType_Type;
    Provides_Type.ob_type = &PyType_Type;
    Depends_Type.ob_type = &PyType_Type;
    Loader_Type.ob_type = &PyType_Type;
    Cache_Type.ob_type = &PyType_Type;

    PyType_Ready(&Loader_Type);
    o = PyInt_FromLong(Loader__stateversion__);
    PyDict_SetItemString(Loader_Type.tp_dict, "__stateversion__", o);
    Py_DECREF(o);
    PyType_Ready(&Cache_Type);
    o = PyInt_FromLong(Loader__stateversion__);
    PyDict_SetItemString(Cache_Type.tp_dict, "__stateversion__", o);
    Py_DECREF(o);

    m = Py_InitModule3("ccache", ccache_methods, "");
    Py_INCREF(&Package_Type);
    PyModule_AddObject(m, "Package", (PyObject*)&Package_Type);
    Py_INCREF(&Provides_Type);
    PyModule_AddObject(m, "Provides", (PyObject*)&Provides_Type);
    Py_INCREF(&Depends_Type);
    PyModule_AddObject(m, "Depends", (PyObject*)&Depends_Type);
    Py_INCREF(&Loader_Type);
    PyModule_AddObject(m, "Loader", (PyObject*)&Loader_Type);
    Py_INCREF(&Cache_Type);
    PyModule_AddObject(m, "Cache", (PyObject*)&Cache_Type);
    StateVersionError = PyErr_NewException("ccache.StateVersionError",
                                           NULL, NULL);
    PyModule_AddObject(m, "StateVersionError", StateVersionError);
}
