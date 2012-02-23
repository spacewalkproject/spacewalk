#!/usr/bin/env python
#
#
# $Id: setup.py,v 1.3 2004/10/15 01:53:29 taw Exp $

from distutils.core import setup

setup(name = "gzipstream",
      version = "1.7.1",
      description = "Streaming zlib (gzip) support for python",
      long_description = """\
A streaming gzip handler.
gzipstream.GzipStream extends the functionality of the gzip.GzipFile class
to allow the processing of streaming data.
""",
      author = 'Todd Warner',
      author_email = 'taw@redhat.com',
      url = 'http://rhn.redhat.com',
      py_modules = ["gzipstream"],
      license = "GPLv2",
      )
