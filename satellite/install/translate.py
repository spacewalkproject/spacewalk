# rhnTranslate.py                      - Python module to handle translations.
#-----------------------------------------------------------------------------
# Handles language (human) translations.
#
# Copyright (c) 2001-2005, Red Hat Inc.
# All rights reserved.
#
#-----------------------------------------------------------------------------
# $Id: translate.py,v 1.9 2005-07-05 17:50:13 wregglej Exp $

import os
import types
import gettext
import string

if hasattr(gettext, 'GNUTranslations'):
    class RHN_Translations(gettext.GNUTranslations):
        # Defining our own class, since we'd like to save the language we use
        # Determining the language is not very pretty - we parse the file name
        # which is supposed to be something like 
        # .../<lang>/LC_MESSAGES/<domain>.po
        def _parse(self, fp):
            gettext.GNUTranslations._parse(self, fp)
            filename = fp.name
            filename = os.path.normpath(filename)
            # Extract the language
            self.lang = string.split(filename, '/')[-3]

        def getlangs(self):
            # Return all languages
            if not self._fallback or not hasattr(self._fallback, 'getlangs'):
                return [ self.lang, 'C' ]
            # Recursive call
            return [ self.lang ] + self._fallback.getlangs()

class i18n:
    _default_langs = ['en', 'en_US', 'C']
    # Wrapper class that allows us to change languages
    def __init__(self, domain=None, localedir="."):
        self.domain = domain
        self.localedir = localedir
        self.langs = self._default_langs[:]
        self._set_catalog()

    def _set_catalog(self):
        # Set the catalog object
        self.cat = gettext.Catalog(self.domain, localedir=self.localedir, 
            languages=self.langs, fallback=1, class_=RHN_Translations)

    def getlangs(self):
        # List of languages we support
        if not hasattr(self.cat, "getlangs"):
            return [ "C" ]
        return self.cat.getlangs()

    def setlangs(self, langs):
        if isinstance(langs, types.StringType):
            langs = [ langs ]
        langs.extend(self._default_langs)
        self.langs = langs
        self._set_catalog()

    def gettext(self, string):
        return self.cat.gettext(string)

    # reinitialize this catalog
    def set(self, domain=None, localedir=None):
        if domain: self.domain = domain
        if localedir: self.localedir = localedir
        self._set_catalog()

# Old-style gettext
class i18n_old(i18n):
    def _set_catalog(self):
        self.cat = gettext.Catalog(self.domain, localedir=self.localedir)

    def getlangs(self):
        return gettext.lang

    def setlangs(self, langs):
        if isinstance(langs, types.StringType):
            langs = [ langs ]
        # Build the list of languages
        _added_langs = []
        for l in langs:
            _added_langs.extend(gettext._expandLang(l))
        # Adding some defaults
        _added_langs.extend(self._default_langs)
        # Remove duplicates
        h = {}
        del gettext.lang[:]
        for l in _added_langs:
            if l == 'C':
                # We'll add it back later
                continue
            if h.has_key(l):
                # Already loaded it
                continue
            gettext.lang.append(l)
            h[l] = None
        if "C" not in gettext.lang:
            gettext.lang.append("C")
        self._set_catalog()

def N_(str):
    return str

if hasattr(gettext, 'GNUTranslations'):
    cat = i18n()
else:
    cat = i18n_old()
_ = cat.gettext
