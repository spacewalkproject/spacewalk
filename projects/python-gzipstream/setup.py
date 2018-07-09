#!/usr/bin/python
#
#

from distutils.core import setup

setup(name = "gzipstream",
      version = "2.8.6",
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
