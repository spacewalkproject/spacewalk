"""Export allowable xmlrpc actions and do_call method"""
    
# RHN Action exporter
# Copyright (c) 1999-2005 Red Hat, Inc.  Distributed under GPL.
# $Id$

def do_call(method, params):
    """Find and execute an allowable xmlrpc method.
    <method> format is "ACTION_FILE.METHOD_NAME"."""

    parts = method.split(".")
    if len(parts) != 2: 
        raise AttributeError("Invalid action syntax: '%s'" % method)
    try:
        func = getattr(globals()[parts[0]], parts[1])
    except:
        raise AttributeError("Action '%s' not found" % method)
    return apply(func, params)


class Action:
    def __init__(self, module):
        # Action module must contain __rhnexport__
        for export in getattr(module, "__rhnexport__"):
            setattr(self, export, getattr(module, export))


def setup():
    import os, sys
    
    actions_dir = os.path.dirname(sys.modules[__name__].__file__) or '.'
    if actions_dir not in sys.path:
        sys.path.append(actions_dir)
    #if __debug__: print "actions_dir: %s" % actions_dir

    for file in [x[:-3] for x in os.listdir(actions_dir) if x.endswith(".py")]:
        if file == "__init__": continue
        try:
            # Import each python file
            mod = __import__(file, globals())
            del globals()[file]
            # Create a namespace for it
            globals()[file] = Action(mod)
            #if __debug__: print "SUCCESS importing action module: %s" % file
        except Exception, e:
            # Remove incomplete imports
            if file in globals():
                del globals()[file]
            #if __debug__: print "FAILURE importing action module: %s, %s" % (file, str(e))
            continue

    # Clean-up module namespace
    del globals()["setup"]
    del globals()["Action"]


# preload all available actions modules and action mehtods on import
if __name__ != "__main__":
    setup()

