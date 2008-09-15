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
#include <ctype.h>

#define BLOCKSIZE 16384

#define STR(obj) PyString_AS_STRING(obj)

staticforward PyTypeObject TagFile_Type;

typedef struct {
    PyDictObject dict;
    PyObject *_fileobj;
    char *_filename;
    FILE *_file;
    long  _offset;
    char *_buf;
    int   _bufread;
    int   _bufsize;
} TagFileObject;

static int
TagFile_init(TagFileObject *self, PyObject *args)
{
    PyObject *file;
    PyObject *noargs = PyTuple_New(0);
    if (PyDict_Type.tp_init((PyObject *)self, noargs, NULL) < 0)
        return -1;
    Py_DECREF(noargs);
    if (!PyArg_ParseTuple(args, "O", &file))
        return -1;
    if (PyString_Check(file)) {
        self->_filename = strdup(STR(file));
        self->_file = fopen(self->_filename, "r");
        if (!self->_file) {
            PyErr_SetFromErrnoWithFilename(PyExc_IOError, self->_filename);
            return -1;
        }
    } else {
        PyObject *attr;
        attr = PyObject_GetAttrString(file, "read");
        if (!attr)
            return -1;
        attr = PyObject_GetAttrString(file, "seek");
        if (!attr)
            return -1;
        Py_INCREF(file);
        self->_fileobj = file;
    }
    return 0;
}

static void
TagFile_dealloc(TagFileObject *self)
{
    if (self->_fileobj) {
        Py_DECREF(self->_fileobj);
    } else {
        free(self->_filename);
        free(self->_buf);
        if (self->_file)
            fclose(self->_file);
    }
    ((PyObject *)self)->ob_type->tp_free((PyObject *)self);
}

static PyObject *
TagFile__getstate__(TagFileObject *self, PyObject *args)
{
    if (self->_fileobj) {
        PyErr_SetString(PyExc_ValueError, "Can't pickle TagFile instance "
                                          "constructed with file object");
        return NULL;
    }
    return PyString_FromString(self->_filename);
}

static PyObject *
TagFile__setstate__(TagFileObject *self, PyObject *state)
{
    if (!PyString_Check(state)) {
        PyErr_SetString(PyExc_TypeError, "TagFile expects string as state");
        return NULL;
    }
    self->_filename = strdup(STR(state));
    self->_file = fopen(self->_filename, "r");
    if (!self->_file) {
        PyErr_SetFromErrnoWithFilename(PyExc_IOError, self->_filename);
        return NULL;
    }
    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *
TagFile_setOffset(TagFileObject *self, PyObject *offset)
{
    if (!PyInt_Check(offset)) {
        PyErr_SetString(PyExc_ValueError, "Invalid offset");
        return NULL;
    }
    self->_bufread = 0;
    self->_offset = PyInt_AsLong(offset);
    if (self->_fileobj) {
        PyObject *res = PyObject_CallMethod(self->_fileobj,
                                            "seek", "O", offset);
        if (!res)
            return NULL;
        Py_DECREF(res);
    } else {
        if (fseek(self->_file, self->_offset, SEEK_SET) == -1) {
            PyErr_SetFromErrnoWithFilename(PyExc_IOError, self->_filename);
            return NULL;
        }
    }
    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *
TagFile_getOffset(TagFileObject *self, PyObject *args)
{
    return PyInt_FromLong(self->_offset);
}

static PyObject *
TagFile_advanceSection(TagFileObject *self, PyObject *args)
{
    int sectionstart, sectionend;
    int keystart, keyend;
    int valuestart, valueend;
    int read, pos;
    int valuepos;
    int c, skip;
    int eof = 0;

    PyObject *key, *value;

    PyDict_Clear((PyObject *)&self->dict);

    /* Ensure we have a whole section in the buffer. */
    sectionstart = pos = 0;
    skip = 1;
    for (;;) {

        if (pos+1 >= self->_bufread) {
            /* We need more data. */
            if (self->_bufread >= self->_bufsize-256) {
                /* We need more space. */
                self->_bufsize += BLOCKSIZE;
                self->_buf = (char *)realloc(self->_buf, self->_bufsize);
                if (!self->_buf)
                    return PyErr_NoMemory();
            }
            if (self->_fileobj) {
                PyObject *res;
                res = PyObject_CallMethod(self->_fileobj, "read", "i",
                                          self->_bufsize-self->_bufread-2);
                if (!res)
                    return NULL;
                if (!PyString_Check(res)) {
                    PyErr_SetString(PyExc_ValueError,
                                    "file.read() returned non-string");
                    Py_DECREF(res);
                    return NULL;
                }
                read = PyString_GET_SIZE(res);
                if (read > self->_bufsize-self->_bufread-2) {
                    PyErr_SetString(PyExc_ValueError,
                                    "file.read() returned more data than "
                                    "requested");
                    Py_DECREF(res);
                    return NULL;
                }
                if (read == 0)
                    eof = 1;
                else
                    memcpy(self->_buf+self->_bufread,
                           PyString_AS_STRING(res), read);
                Py_DECREF(res);
            } else {
                read = fread(self->_buf+self->_bufread, sizeof(char),
                             self->_bufsize-self->_bufread-2, self->_file);
                if (feof(self->_file)) {
                    eof = 1;
                } else if (ferror(self->_file)) {
                    PyErr_SetFromErrnoWithFilename(PyExc_IOError,
                                                   self->_filename);
                    return NULL;
                }
            }
            if (eof) {
                *(self->_buf+pos+read) = '\n';
                *(self->_buf+pos+read+1) = '\n';
                read += 2;
            }
            self->_bufread += read;
        }

        /* Skip invalid lines. */
        if (skip) {
            while (pos != self->_bufread) {
                if (*(self->_buf+pos) == ':') {
                    int tmppos = pos;
                    while (tmppos > 0 && *(self->_buf+tmppos-1) != '\n')
                        tmppos -= 1;
                    if (!isspace(*(self->_buf+tmppos))) {
                        pos = tmppos;
                        break;
                    }
                }
                pos += 1;
            }
            if (pos != self->_bufread) {
                sectionstart = pos;
                skip = 0;
            } else if (eof) {
                sectionstart = sectionend = pos;
                goto found;
            } else {
                continue;
            }
        }

        while (pos+1 < self->_bufread) {
            if (*(self->_buf+pos) == '\n' && *(self->_buf+pos+1) == '\n') {
                sectionend = pos+2;
                goto found;
            }
            pos += 1;
        }
    }

found:

    pos = sectionstart;

restart:

    while (pos != sectionend) {

        keystart = pos;
        keyend = -1;

        for (;;) {
            c = *(self->_buf+pos);
            switch (c) {
                case '\n':
                    pos += 1;
                    goto restart;
                case ':':
                    if (keyend == -1)
                        keyend = pos;
                    pos += 1;
                    goto exitkeyloop;
                case ' ':
                case '\t':
                    break;
                default:
                    *(self->_buf+pos) = tolower(c);
                    keyend = pos+1;
                    break;
            }
            pos += 1;
        }

exitkeyloop:

        *(self->_buf+keyend) = '\0';

        while (*(self->_buf+pos) == ' ' || *(self->_buf+pos) == '\t')
            pos += 1;

        valuestart = pos;
        valuepos = pos;
        valueend = pos;

        for (;;) {
            c = *(self->_buf+pos);
            switch (c) {
                case '\n':
                    pos += 1;
                    c = *(self->_buf+pos);
                    if (c == '\n' || !isspace(c))
                        goto exitvalueloop;
                    *(self->_buf+valuepos++) = '\n';
                    if (*(self->_buf+pos+1) == '.' &&
                        *(self->_buf+pos+2) == '\n')
                        pos += 1;
                    break;
                case ' ':
                case '\t':
                    *(self->_buf+valuepos++) = c;
                    break;
                default:
                    *(self->_buf+valuepos++) = c;
                    valueend = valuepos;
                    break;
            }
            pos += 1;
        }

exitvalueloop:

        *(self->_buf+valueend) = '\0';

        key = PyString_FromString(self->_buf+keystart);
        value = PyString_FromString(self->_buf+valuestart);
        PyDict_SetItem((PyObject *)&self->dict, key, value);
        Py_DECREF(key);
        Py_DECREF(value);

    }

    memmove(self->_buf, self->_buf+sectionend, self->_bufread-sectionend);
    self->_bufread -= sectionend;
    self->_offset += sectionend;

    return PyBool_FromLong(PyDict_Size((PyObject *)&self->dict));
}

static PyMethodDef TagFile_methods[] = {
    {"__getstate__", (PyCFunction)TagFile__getstate__, METH_NOARGS, NULL},
    {"__setstate__", (PyCFunction)TagFile__setstate__, METH_O, NULL},
    {"getOffset", (PyCFunction)TagFile_getOffset, METH_NOARGS, NULL},
    {"setOffset", (PyCFunction)TagFile_setOffset, METH_O, NULL},
    {"advanceSection", (PyCFunction)TagFile_advanceSection, METH_NOARGS, NULL},
    {NULL, NULL}
};

statichere PyTypeObject TagFile_Type = {
	PyObject_HEAD_INIT(NULL)
	0,			/*ob_size*/
	"smart.util.tagfile.TagFile",	/*tp_name*/
	sizeof(TagFileObject), /*tp_basicsize*/
	0,			/*tp_itemsize*/
	(destructor)TagFile_dealloc, /*tp_dealloc*/
	0,			/*tp_print*/
	0,			/*tp_getattr*/
	0,			/*tp_setattr*/
	0,			/*tp_compare*/
	0,          /*tp_repr*/
	0,			/*tp_as_number*/
	0,			/*tp_as_sequence*/
	0,			/*tp_as_mapping*/
	0,          /*tp_hash*/
    0,                      /*tp_call*/
    0,                      /*tp_str*/
    0,                      /*tp_getattro*/
    0,                      /*tp_setattro*/
    0,                      /*tp_as_buffer*/
    Py_TPFLAGS_DEFAULT|Py_TPFLAGS_BASETYPE, /*tp_flags*/
    0,                      /*tp_doc*/
    0,                      /*tp_traverse*/
    0,                      /*tp_clear*/
    0,                      /*tp_richcompare*/
    0,                      /*tp_weaklistoffset*/
    0,                      /*tp_iter*/
    0,                      /*tp_iternext*/
    TagFile_methods,        /*tp_methods*/
    0,                      /*tp_members*/
    0,                      /*tp_getset*/
    0,                      /*tp_base*/
    0,                      /*tp_dict*/
    0,                      /*tp_descr_get*/
    0,                      /*tp_descr_set*/
    0,                      /*tp_dictoffset*/
    (initproc)TagFile_init, /*tp_init*/
    0,                      /*tp_alloc*/
    0,                      /*tp_new*/
    0,                      /*tp_free*/
    0,                      /*tp_is_gc*/
};

static PyMethodDef ctagfile_methods[] = {
    {NULL, NULL}
};

DL_EXPORT(void)
initctagfile(void)
{
    PyObject *m;
    TagFile_Type.tp_base = &PyDict_Type;
    if (PyType_Ready(&TagFile_Type) < 0)
        return;
    m = Py_InitModule3("ctagfile", ctagfile_methods, "");
    Py_INCREF(&TagFile_Type);
    PyModule_AddObject(m, "TagFile", (PyObject *)&TagFile_Type);
}

/* vim:ts=4:sw=4:et
*/
