/*
 * Copyright (C) 2009--2013 Red Hat, Inc.
 *
 * David Sommerseth <davids@redhat.com>
 *
 * This application is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; version 2.
 *
 * This application is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 */

/**
 * @file   etherinfo_ipv6_obj.c
 * @author David Sommerseth <davids@redhat.com>
 * @date   Thu Jul 29 17:51:28 2010
 *
 * @brief  Python ethtool.etherinfo class functions.
 *
 */

#include <Python.h>
#include "structmember.h"

#include <netlink/route/rtnl.h>
#include "etherinfo_struct.h"
#include "etherinfo.h"


/**
 * ethtool.etherinfo_ipv6addr deallocator - cleans up when a object is deleted
 *
 * @param self etherinfo_ipv6addr_py object structure
 */
void _ethtool_etherinfo_ipv6_dealloc(etherinfo_ipv6addr_py *self)
{
	if( self->addrdata ) {
		free_ipv6addresses(self->addrdata);
	}
	self->ob_type->tp_free((PyObject*)self);
}


/**
 * ethtool.etherinfo_ipv6addr function, creating a new etherinfo object
 *
 * @param type
 * @param args
 * @param kwds
 *
 * @return Returns in PyObject with the new object on success, otherwise NULL
 */
PyObject *_ethtool_etherinfo_ipv6_new(PyTypeObject *type, PyObject *args, PyObject *kwds)
{
	etherinfo_ipv6addr_py *self;

	self = (etherinfo_ipv6addr_py *)type->tp_alloc(type, 0);
	return (PyObject *)self;
}


/**
 * ethtool.etherinfo_ipv6addr init (constructor) method.  Makes sure the object is initialised correctly.
 *
 * @param self
 * @param args
 * @param kwds
 *
 * @return Returns 0 on success.
 */
int _ethtool_etherinfo_ipv6_init(etherinfo_ipv6addr_py *self, PyObject *args, PyObject *kwds)
{
	static char *etherinfo_kwlist[] = {"etherinfo_ipv6_ptr", NULL};
	PyObject *ethinf_ptr = NULL;

	if( !PyArg_ParseTupleAndKeywords(args, kwds, "O", etherinfo_kwlist, &ethinf_ptr)) {
		PyErr_SetString(PyExc_AttributeError, "Invalid data pointer to constructor");
		return -1;
	}
	self->addrdata = (struct ipv6address *) PyCObject_AsVoidPtr(ethinf_ptr);
	return 0;
}

/**
 * ethtool.etherinfo_ipv6addr function for retrieving data from a Python object.
 *
 * @param self
 * @param attr_o  contains the object member request (which element to return)
 *
 * @return Returns a PyObject with the value requested on success, otherwise NULL
 */
PyObject *_ethtool_etherinfo_ipv6_getter(etherinfo_ipv6addr_py *self, PyObject *attr_o)
{
	PyObject *ret;
	char *attr = PyString_AsString(attr_o);

	if( !self || !self->addrdata ) {
		PyErr_SetString(PyExc_AttributeError, "No data available");
		return NULL;
	}

	if( strcmp(attr, "address") == 0 ) {
		ret = RETURN_STRING(self->addrdata->address);
	} else if( strcmp(attr, "netmask") == 0 ) {
		ret = PyInt_FromLong(self->addrdata->netmask);
	} else if( strcmp(attr, "scope") == 0 ) {
		char scope[66];

		rtnl_scope2str(self->addrdata->scope, scope, 66);
		ret = PyString_FromString(scope);
	} else {
		ret = PyObject_GenericGetAttr((PyObject *)self, attr_o);
	}
	return ret;
}


/**
 * ethtool.etherinfo_ipv6addr function for setting a value to a object member.  This feature is
 * disabled by always returning -1, as the values are read-only by the user.
 *
 * @param self
 * @param attr_o
 * @param val_o
 *
 * @return Returns always -1 (failure).
 */
int _ethtool_etherinfo_ipv6_setter(etherinfo_ipv6addr_py *self, PyObject *attr_o, PyObject *val_o)
{
	PyErr_SetString(PyExc_AttributeError, "etherinfo_ipv6addr member values are read-only.");
	return -1;
}


/**
 * Creates a human readable format of the information when object is being treated as a string
 *
 * @param self
 *
 * @return Returns a PyObject with a string with all of the information
 */
PyObject *_ethtool_etherinfo_ipv6_str(etherinfo_ipv6addr_py *self)
{
	char scope[66];

	if( !self || !self->addrdata ) {
		PyErr_SetString(PyExc_AttributeError, "No data available");
		return NULL;
	}

	rtnl_scope2str(self->addrdata->scope, scope, 64);
	return PyString_FromFormat("[%s] %s/%i",
				   scope,
				   self->addrdata->address,
				   self->addrdata->netmask);
}


/**
 * This is required by Python, which lists all accessible methods
 * in the object.  But no methods are provided.
 *
 */
static PyMethodDef _ethtool_etherinfo_ipv6_methods[] = {
    {NULL}  /**< No methods defined */
};

/**
 * Defines all accessible object members
 *
 */
static PyMemberDef _ethtool_etherinfo_ipv6_members[] = {
    {"address", T_OBJECT_EX, offsetof(etherinfo_ipv6addr_py, addrdata), 0,
     "IPv6 address"},
    {"netmask", T_OBJECT_EX, offsetof(etherinfo_ipv6addr_py, addrdata), 0,
     "IPv6 netmask"},
    {"scope", T_OBJECT_EX, offsetof(etherinfo_ipv6addr_py, addrdata), 0,
     "IPv6 IP address scope"},
    {NULL}  /* End of member list */
};

/**
 * Definition of the functions a Python class/object requires.
 *
 */
PyTypeObject ethtool_etherinfoIPv6Type = {
    PyObject_HEAD_INIT(NULL)
    0,                         /*ob_size*/
    "ethtool.etherinfo_ipv6addr", /*tp_name*/
    sizeof(etherinfo_ipv6addr_py), /*tp_basicsize*/
    0,                         /*tp_itemsize*/
    (destructor)_ethtool_etherinfo_ipv6_dealloc,/*tp_dealloc*/
    0,                         /*tp_print*/
    0,                         /*tp_getattr*/
    0,                         /*tp_setattr*/
    0,                         /*tp_compare*/
    0,                         /*tp_repr*/
    0,                         /*tp_as_number*/
    0,                         /*tp_as_sequence*/
    0,                         /*tp_as_mapping*/
    0,                         /*tp_hash */
    0,                         /*tp_call*/
    (reprfunc)_ethtool_etherinfo_ipv6_str,        /*tp_str*/
    (getattrofunc)_ethtool_etherinfo_ipv6_getter, /*tp_getattro*/
    (setattrofunc)_ethtool_etherinfo_ipv6_setter, /*tp_setattro*/
    0,                         /*tp_as_buffer*/
    Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE, /*tp_flags*/
    "IPv6 address information", /* tp_doc */
    0,		               /* tp_traverse */
    0,		               /* tp_clear */
    0,		               /* tp_richcompare */
    0,		               /* tp_weaklistoffset */
    0,		               /* tp_iter */
    0,		               /* tp_iternext */
    _ethtool_etherinfo_ipv6_methods,            /* tp_methods */
    _ethtool_etherinfo_ipv6_members,            /* tp_members */
    0,                         /* tp_getset */
    0,                         /* tp_base */
    0,                         /* tp_dict */
    0,                         /* tp_descr_get */
    0,                         /* tp_descr_set */
    0,                         /* tp_dictoffset */
    (initproc)_ethtool_etherinfo_ipv6_init,     /* tp_init */
    0,                         /* tp_alloc */
    _ethtool_etherinfo_ipv6_new,                /* tp_new */
};

