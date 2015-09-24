# Retrieve action method name given queued action information.
#
# Client code for Update Agent
# Copyright (c) 1999--2015 Red Hat, Inc.  Distributed under GPLv2.
#
# An allowable xmlrpc method is retrieved given a base location, a
# hierarchical route to the class/module, and method name.
#

import os
import string
import sys
from types import ClassType


class GetMethodException(Exception):
    """Exception class"""
    pass


def sanity(methodNameComps):
    #"""
    # Verifies if all the components have proper names
    #"""
    # Allowed characters in each string
    alpha = string.ascii_lowercase + string.ascii_uppercase
    allowedChars = alpha + string.digits + '_'
    for comp in methodNameComps:
        if not len(comp):
            raise GetMethodException("Empty method component")
        for c in comp:
            if c not in allowedChars:
                raise GetMethodException(
                    "Invalid character '%s' in the method name" % c)
        # Can only begin with a letter
        if comp[0] not in alpha:
            raise GetMethodException(
                "Method names should start with an alphabetic character")


def getMethod(methodName, abspath, baseClass):
    #"""
    #Retreive method given methodName, path to base of tree, and class/module
    #route/label.
    #"""
    # First split the method name
    methodNameComps = string.split(baseClass, '.') + string.split(methodName, '.')
    # Sanity checks
    sanity(methodNameComps)
    # Build the path to the file
    path = abspath
    for index in range(len(methodNameComps)):
        comp = methodNameComps[index]
        path = "%s/%s" % (path, comp)
        # If this is a directory, fine...
        if os.path.isdir(path):
            # Okay, go on
            continue
        # Try to load this as a file
        for extension in ['py', 'pyc', 'pyo']:
            if os.path.isfile("%s.%s" % (path, extension)):
                # Yes, this is a file
                break
        else:
            # No dir and no file. Die
            raise GetMethodException("Action %s could not be found" % methodName)
        break
    else:
        # Only directories. This can't happen
        raise GetMethodException("Very wrong")

    # The position of the file
    fIndex = index + 1
    # Now build the module name
    modulename = string.join(methodNameComps[:fIndex], '.')
    # And try to import it
    try:
        actions = __import__(modulename)
    except ImportError:
        raise GetMethodException("Could not import module %s" % modulename), None, sys.exc_info()[2]

    className = actions
    # Iterate through the list of components and try to load that specific
    # module/method
    for index in range(1, len(methodNameComps)):
        comp = methodNameComps[index]
        if index < fIndex:
            # This is a directory or a file we have to load
            if not hasattr(className, comp):
                # Hmmm... Not there
                raise GetMethodException("Class %s has no attribute %s" % (
                    string.join(methodNameComps[:index], '.'), comp))
            className = getattr(className, comp)
            #print type(className)
            continue
        # A file or method
        # We look for the special __rhnexport__ array
        if not hasattr(className, '__rhnexport__'):
            raise GetMethodException("Class %s is not RHN-compliant" % \
                string.join(methodNameComps[:index], '.'))
        export = getattr(className, '__rhnexport__')
        if comp not in export:
            raise GetMethodException("Class %s does not export '%s'" % (
                string.join(methodNameComps[:index], '.'), comp))
        className = getattr(className, comp)
        if type(className) is ClassType:
            # Try to instantiate it
            className = className()
        #print type(className)

    return className


#-----------------------------------------------------------------------------
if __name__ == '__main__':
    # Two valid ones and a bogus one
    methods = [
        'a.b.c.d.e.f',
        'a.b.c.d.e.foo.h',
        'a.b.c.d.e.g.h',
        'a.b.d.d.e.g.h',
        'a.b.d.d._e.g.h',
        'a.b.d.d.e_.g.h',
        'a.b.d.d.e-.g.h',
        'a.b.d.d..g.h',
    ]

    for m in methods:
        print "----Running method %s: " % m
        try:
            method = getMethod(m, '.', 'Actions')
        except GetMethodException:
            e = sys.exc_info()[1]
            print "Error getting the method %s: %s" % (m,
                string.join(map(str, e.args)))
        else:
            method()
#-----------------------------------------------------------------------------

