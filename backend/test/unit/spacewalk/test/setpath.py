import sys
import os
import os.path
import unittest

PYTHON_PATH_SETUP = False

def setup_python_path():
    """
    Configure the Python path to run the backend tests from a source checkout.
    Can be called many times in a test run, but should only actually do
    something the first time.
    """
    global PYTHON_PATH_SETUP
    if PYTHON_PATH_SETUP:
        print "PYTHONPATH already configured, skipping."
        return
    print "Configuring PYTHONPATH..."
    if not os.environ.has_key('SPACEWALK_GIT'):
        raise Exception("SPACEWALK_GIT environment variable not set")

    gitdir = os.path.expanduser(os.environ['SPACEWALK_GIT'])
    sys.path.insert(0, os.path.join(gitdir, "client/rhel/rhnlib/"))
    sys.path.insert(0, os.path.join(gitdir, "backend"))
    PYTHON_PATH_SETUP = True

setup_python_path()




