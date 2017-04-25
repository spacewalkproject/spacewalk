#!/usr/bin/python
#
# Copyright (c) 2016 Red Hat, Inc.
#
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

"""
poparser - a tool for massaging zanata output to minimize diffs to
existing localization files in the spacewalk codebase
"""

import os
import sys
from optparse import OptionParser
import polib
import git

repo = git.Repo('.')

def setupOptions():
    usage = 'usage: %prog [options]'
    parser = OptionParser(usage=usage)
    parser.add_option('-l', '--language', action='store', dest='lang',
                      metavar='LANG',
                      help='We will fix <LANG>.po file in this run')
    parser.add_option('-i', '--input-dir', action='store', dest='inDir',
                      metavar='IN_DIR',
                      help='Where are we looking for <LANG>.po file?')
    parser.add_option('-o', '--output-dir', action='store', dest='newDir',
                      metavar='OUT_DIR',
                      help='Where should we write <LANG>.po.new file?')
    return parser

def checkRequired(opts, pars):
    err = ''
    if not opts.lang:
        err += '--language is REQUIRED '
    if not opts.inDir:
        err += '--input-dir is REQUIRED '
    if not opts.newDir:
        err += '--output-dir is REQUIRED'

    if err:
        pars.error(err)
        sys.exit(1)

# Parse a given po file
def parseFile(fn):
    data = polib.pofile(fn)
    return data

def getPoEntry(po, msgid):
    for entry in po:
        if entry.msgid == msgid:
            return entry

def checkSourceMatch(source, target, targetFn):
    " check that en template match lang sources "
    missingTarget = []
    missingSource = []

    for entry in source:
        if not entry in target:
            missingTarget.append(entry)

    for entry in target:
        if not entry in source and not entry in target.obsolete_entries():
            missingSource.append(entry)

    if missingTarget or missingSource:
        print "ERROR - %s:" % targetFn
        print "  ENTRIES IN SOURCE:"
        print "    %d" % len(source)

        print "  ENTRIES IN TARGET:"
        print "    %d, %d untranslated" % (len(target), len(target.untranslated_entries()))

        print "  MISSING KEYS IN SOURCE: %d" % len(missingSource)
        for i in missingSource:
            msgid = i.msgid.encode("utf-8").encode('string_escape')[:90]
            print "    %s" % msgid
            print "  --"

        print "  MISSING KEYS IN TARGET: %d" % len(missingTarget)
        for i in missingTarget:
            msgid = i.msgid.encode("utf-8").encode('string_escape')[:90]
            print "    %s" % msgid
            print "  --"
        return False
    else:
        print "OK - %s" % targetFn
        return True

# Create a new version of localized file based on src en_US template and dest <LANG>
def processOneLangFile(templateFn, langFn, newFn):
    templatePo = parseFile(templateFn)
    langPo = parseFile(langFn)
    if not checkSourceMatch(templatePo, langPo, langFn):
        sys.exit(2)

    langPo.metadata['Project-Id-Version'] = "Spacewalk"

    # Get original version
    try:
        repo.index.checkout(langFn, force=True)
    except git.exc.CheckoutError as e:
        print "%s: git.exc.CheckoutError" % langFn
        return

    # Load currend HEAD version of translation file
    oldLangPo = parseFile(langFn)

    # First, filter all obsolete entries in new file if there are any
    for item in langPo.obsolete_entries():
        langPo.remove(item)

    # And now copy obsoletes from old file
    # Zanata files do not have them
    for item in oldLangPo.obsolete_entries():
        langPo.append(item)

    langPo.save(newFn)

def getTemplateFilename(directory):
    for f in os.listdir(directory):
        if f.endswith(".pot"):
            return f

def parse(lang, inDir, newDir):
    templateFn   = "%s/%s" % (inDir, getTemplateFilename(inDir))

    langFn = "%s/%s.po" % (inDir, lang)
    if not os.path.isfile(langFn):
      print "OK - %s - not found." % langFn
      return

    newFn = "%s/%s.po.new" % (newDir, lang)
    processOneLangFile(templateFn, langFn, newFn)

if __name__ == '__main__':
    parser = setupOptions()
    (options, args) = parser.parse_args()
    checkRequired(options, parser)

    parse(options.lang, options.inDir, options.newDir)

    sys.exit(0)
