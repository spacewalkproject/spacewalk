#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

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
            #pkilambi:bug#158561,170819,170821: the gettext object in python 2.2.3 has no attribute
            #_fallback so add a check if __dict__ has key
            #if not self._fallback or not hasattr(self._fallback, 'getlangs'):
            if not self.__dict__.has_key("_fallback") or not self._fallback or not hasattr(self._fallback, 'getlangs'):
                return [ self.lang, 'C' ]
            # Recursive call
            return [ self.lang ] + self._fallback.getlangs()

class i18n:
    _default_langs = ['en', 'en_US', 'C']
    # Wrapper class that allows us to change languages
    def __init__(self, domain=None, localedir="/usr/share/rhn/locale"):
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
        # Filter "C" - we will add it ourselves later anyway
        langs = filter(lambda x: x != 'C', langs)
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
        # Aargh - on python 1.5, gettext removes os and string - so subsequent
        # calls to _expandLang fail - so add the string module back
        gettext.string = string
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
