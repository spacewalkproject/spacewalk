#include <Python.h>
#include <rpmlib.h>

#include <fcntl.h>

#define _RPMTS_INTERNAL
#include <rpmte.h>
#include <rpmts.h>

typedef struct rpmtsObject_s {
    PyObject_HEAD
    PyObject *md_dict;
    rpmts       ts;
    /* Other unneeded fields */
} rpmtsObject;

PyObject *rpmmi_Wrap(rpmdbMatchIterator mi);
long tagNumFromPyObject(PyObject *item);

static PyObject *
dbMatch(PyObject *self, PyObject *args, PyObject *kwds)
{
    rpmtsObject *s;
    PyObject *TagN = NULL;
    PyObject *Key = NULL;
    char *key = NULL;
    unsigned int ikey;
    int len = 0;
    int tag = RPMDBI_PACKAGES;
    char * kwlist[] = {"ts", "tagNumber", "key", NULL};

    if (!PyArg_ParseTupleAndKeywords(args, kwds, "O|OO:Match", kwlist,
                                     &s, &TagN, &Key))
        return NULL;

    if (TagN && (tag = tagNumFromPyObject (TagN)) == -1) {
        PyErr_SetString(PyExc_TypeError, "unknown tag type");
        return NULL;
    }

    if (Key) {
        if (PyString_Check(Key)) {
            key = PyString_AsString(Key);
            len = PyString_Size(Key);
        } else if (PyInt_Check(Key)) {
            ikey = PyInt_AsLong(Key);
            key = (char *)&ikey;
            len = sizeof(ikey);
        } else {
            PyErr_SetString(PyExc_TypeError, "unknown key type");
            return NULL;
        }
    }

    if (s->ts->rdb == NULL) {
        int rc = rpmtsOpenDB(s->ts, O_RDONLY);
        if (rc || s->ts->rdb == NULL) {
            PyErr_SetString(PyExc_TypeError, "rpmdb open failed");
            return NULL;
        }
    }

    return rpmmi_Wrap(rpmtsInitIterator(s->ts, tag, key, len));
}

static PyMethodDef rpmhelper_methods[] = {
    {"dbMatch", (PyCFunction)dbMatch, METH_VARARGS|METH_KEYWORDS, NULL},
    {NULL, NULL}
};

DL_EXPORT(void)
initrpmhelper(void)
{
    PyObject *m;
    m = Py_InitModule3("rpmhelper", rpmhelper_methods, "");
}

/* vim:ts=4:sw=4:et
*/
