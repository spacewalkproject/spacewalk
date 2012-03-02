# -*- coding: utf-8 -*-
from distutils.core import setup, Extension

setup (name = 'pciutils',
       version = '1.7.3',
       description = 'Interface to pciutils',
       author = 'Miroslav Suchý',
       author_email = 'msuchy@redhat.com',
       license = 'GPLv2',
       url = 'https://fedorahosted.org/spacewalk/wiki/Projects/python-hwdata',
       py_modules = ['hwdata'])
