#!/usr/bin/python
from distutils.core import setup, Extension
import os

try:
    from rpm import _rpm as rpmmodule
except ImportError:
    import rpm as rpmmodule
rpmmoduledir = os.path.dirname(rpmmodule.__file__)

setup(name="rpmhelper",
      version = "0.1",
      description = "",
      author = "Gustavo Niemeyer",
      author_email = "niemeyer@conectiva.com",
      license = "GPL",
      url = "http://smartpm.org",
      long_description = "",
      ext_modules = [
                     Extension("rpmhelper", ["rpmhelper.c"],
                               include_dirs=["/usr/include/rpm"],
                               runtime_library_dirs=[rpmmoduledir],
                               extra_link_args=[rpmmodule.__file__],
                               )
                    ],
      )

