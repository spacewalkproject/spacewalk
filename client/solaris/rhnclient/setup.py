#!/usr/bin/python
#
#
# $Id: setup.py.in,v 1.3 2003/11/16 06:12:48 taw Exp $

from distutils.core import setup
from spacewalk.common.rhnConfig import CFG, initCFG
initCFG('web')

setup(name = "rhnclient",
      version = "5.5.2",
      description = CFG.PRODUCT_NAME + " Client Utilities and Libraries",
      long_description = CFG.PRODUCT_NAME + """\
 Client Utilities
Includes: rhn_check, action handler, and modules to allow
client packages to communicate with RHN.""",

      author = 'Joel Martin',
      author_email = 'jmartin@redhat.com',
      url = 'http://rhn.redhat.com',
      packages = ["rhn.actions", "rhn.client"],
      license = "GPL",

      )
