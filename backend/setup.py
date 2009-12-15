#!/usr/bin/python
#
# setup of spacewalk-backend-libs
#

from distutils.core import setup
import os

setup(name = os.environ["PYTHON_MODULE_NAME"],
      version = os.environ["PYTHON_MODULE_VERSION"],
      description = "Python libraries for the Spacewalk project",
      long_description = """A collection of python modules used by the
Spacewalk (http://spacewalk.redhat.com) software.""",
      url = 'http://spacewalk.redhat.com',
      packages = ["spacewalk", "spacewalk/common"],
      license = "GPL",
      )
