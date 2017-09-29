# Retrieve action method name given queued action information.
#
# Client code for Update Agent
# Copyright (c) 1999--2016 Red Hat, Inc.  Distributed under GPLv2.
#
# An allowable xmlrpc method is retrieved given a base location, a
# hierarchical route to the class/module, and method name.
#

import os
import string
import sys

from rhn.tb import raise_with_tb

try: # python2
    from types import ClassType
except ImportError: # python3
    ClassType = type

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


def getMethod(methodName, baseClass):
    #"""
    #Retreive method given methodName, path to base of tree, and class/module
    #route/label.
    #"""
    # First split the method name
    methodNameComps = baseClass.split('.') + methodName.split('.')
    # Sanity checks
    sanity(methodNameComps)
    # Look for the module, start with the most specific
    for index in range(len(methodNameComps), 0, -1):
        modulename = '.'.join(methodNameComps[:index])
        try:
            actions = __import__(modulename)
        except ImportError:
            # does not exist, try next one
            continue
        except Exception:
            raise_with_tb(GetMethodException("Could not import module %s" % modulename))
        # found one, skip the rest
        break
    else:
        # no module found. die
        raise GetMethodException("Action %s could not be imported" % methodName)

    # The position of the file
    fIndex = index

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
                    '.'.join(methodNameComps[:index]), comp))
            className = getattr(className, comp)
            #print(type(className))
            continue
        # A file or method
        # We look for the special __rhnexport__ array
        if not hasattr(className, '__rhnexport__'):
            raise GetMethodException("Class %s is not RHN-compliant" % \
                '.'.join(methodNameComps[:index]))
        export = getattr(className, '__rhnexport__')
        if comp not in export:
            raise GetMethodException("Class %s does not export '%s'" % (
                '.'.join(methodNameComps[:index]), comp))
        className = getattr(className, comp)
        if type(className) is ClassType:
            # Try to instantiate it
            className = className()
        #print(type(className))

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
        print("----Running method %s: " % m)
        try:
            method = getMethod(m, 'Actions')
        except GetMethodException:
            e = sys.exc_info()[1]
            print("Error getting the method %s: %s" % (m,
                ''.join(map(str, e.args))))
        else:
            method()
#-----------------------------------------------------------------------------

