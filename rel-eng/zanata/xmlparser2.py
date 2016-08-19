#!/usr/bin/python
#
# Copyright (c) 2015--2016 Red Hat, Inc.
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
xmlparser2 - a tool for massaging zanata output to minimize diffs to
existing localization files in the spacewalk codebase
"""

import os
import sys
import codecs
import re
from optparse import OptionParser
from xml.dom.minidom import parseString

#import pdb; pdb.set_trace()

#lang, in_dir, new_dir = sys.argv[1:4]
def setupOptions():
    usage = 'usage: %prog [options]'
    parser = OptionParser(usage=usage)
    parser.add_option('-l', '--language', action='store', dest='lang',
                      metavar='LANG',
                      help='We will fix StringResource_<LANG>.xml file in this run')
    parser.add_option('-i', '--input-dir', action='store', dest='in_dir',
                      metavar='IN_DIR',
                      help='Where are we looking for StringResource_<LANG>.xml file?')
    parser.add_option('-o', '--output-dir', action='store', dest='new_dir',
                      metavar='OUT_DIR',
                      help='Where should we write StringResource_<LANG>.xml.new file?')
    return parser

def check_required(opts, pars):
    err = ''
    if not opts.lang:
        err += '--language is REQUIRED '
    if not opts.in_dir:
        err += '--input-dir is REQUIRED '
    if not opts.new_dir:
        err += '--output-dir is REQUIRED'

    if err:
        pars.error(err)
        sys.exit(1)

# Parse a given XLIFF file
def parse_file(fn):
    #open the xml file for reading:
    f = open(fn, 'r')
    data = f.read()
    f.close()

    #parse the xml you got from the file
    dom = parseString(data)
    #retrieve <tag>data</tag> that the parser finds with name tagName
    units = dom.getElementsByTagName('trans-unit')

    sources = {}
    targets = {}
    trans_units = {}
    id_list = []
    for unit in units:
        id = unit.getAttribute('id')
        source = unit.getElementsByTagName('source')[0].toxml()
        try:
            target = unit.getElementsByTagName('target')[0].toxml()
        except IndexError:
            target = ''
        sources[id] = source
        targets[id] = target
        trans_units[id] = unit
        id_list.append(id)

    return sources, targets, trans_units, id_list

def check_source_match(sources1, sources2):
    " check that en sources mantch lang sources "
    missing   = []
    different = []
    for i, s in sources1.items():
        if not sources2.has_key(i):
           missing.append(i)
        elif sources2[i] != s:
           different.append(i)

    print " MISSING KEYS:"
    for i in missing:
        print "      %s: %s" % (i.encode("utf-8"), sources1[i].encode("utf-8"))

    print " DIFFERENT KEYS:"
    for i in different:
        print "  en: %s: %s" % (i.encode("utf-8"), sources1[i].encode("utf-8"))
        print "lang: %s: %s" % (i.encode("utf-8"), sources2[i].encode("utf-8"))

    return missing, different

# Create a new version of localized file based on src en_US and dest <LANG>
def process_one_lang_file(lang, src, dest):
    en_sources, en_targets, en_units, en_id_list         = parse_file(src)
    lang_sources, lang_targets, lang_units, lang_id_list = parse_file(dest)
    lang_missing, lang_different = check_source_match(en_sources, lang_sources)

    f_in = codecs.open(src, 'r', 'utf-8')
    data = f_in.read()
    f_in.close()

    #                        1                   2            3                                  4                           5         6
    prog = re.compile('(<trans-unit id=".*">)\n(\s*)(<source>.*</source>)\n(\s+<context-group name=".*">.*</context-group>\n)?(\s*)(</trans-unit>)', re.S)
    for i in en_id_list:
        if not lang_sources.has_key(i):
            print " MISSING KEY: %s" % i
            continue
        if not lang_targets.has_key(i):
            print " NOT TRANSLATED: %s" % i
            continue
        en_unit = en_units[i].toxml().replace('&quot;','"')
        if en_unit.find('<target>') > -1:
            new_unit = en_unit.replace(en_targets[i], lang_targets[i])
        else:
            m = prog.match(en_unit)
            if m:
                #print 'REGEX MATCH'
                new_unit = m.group(1) + '\n' + m.group(2) + m.group(3) + '\n' + (m.group(4) if m.group(4) else '') + m.group(2) + lang_targets[i] + '\n' + m.group(5) + m.group(6)
            else:
                #print 'NO REGEX MATCH'
                new_unit = en_unit.replace('</trans-unit>',
                                        '  ' + lang_targets[i] + '\n</trans-unit>')

        #print "EN_UNIT  [%s]\nNEW_UNIT [%s]" % (en_unit, new_unit)

        data = data.replace(en_unit, new_unit)
        data = data.replace('<!-- vim: set et ts=2 sw=2 ai: -->\n','')
        data = data.replace('<file source-language="en" datatype="plaintext" original="">',
            '<file source-language="en" datatype="plaintext" original="" target-language="%s">' % lang)
    return data

# Write dta to new filename
def write_new_file(newfile, dta):
    f_new = codecs.open(newfile, 'w', 'utf-8')
    f_new.write(dta)
    f_new.close()

def parse(lang, in_dir, new_dir):
    # fn_en   - StringResource_en_US.xml
    # fn_lang - StringResource_de.xml - translated strings from zanata
    # fn_new  - StringResource_de.xml.new - newly created file using fn_en
    #           as a template with translated strings added from fn_lang
    fn_lang = "%s/StringResource_%s.xml" % (in_dir, lang)
    if not os.path.isfile(fn_lang):
      print "No file %s - exiting..." % fn_lang
      return

    fn_en   = "%s/StringResource_en_US.xml" % in_dir
    fn_new  = "%s/StringResource_%s.xml.new" % (new_dir, lang)

    print "EN vs. %s:"  % lang
    outstr = process_one_lang_file(lang, fn_en, fn_lang)
    write_new_file(fn_new, outstr)

if __name__ == '__main__':
    parser = setupOptions()
    (options, args) = parser.parse_args()
    check_required(options, parser)

    parse(options.lang, options.in_dir, options.new_dir)

    sys.exit(0)
