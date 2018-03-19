#
# Licensed under the GNU General Public License Version 3
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Copyright 2013 Aron Parsons <aronparsons@gmail.com>
# Copyright (c) 2011--2018 Red Hat, Inc.
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

# wildcard import
# pylint: disable=W0401,W0614

# unused argument
# pylint: disable=W0613

# invalid function name
# pylint: disable=C0103

import logging
import os
import pickle
import re
import readline
import shlex
import sys
import time
import argparse

try:
    from xmlrpc import client as xmlrpclib
except ImportError:
    import xmlrpclib
from collections import deque
from datetime import datetime, timedelta
from difflib import unified_diff
from tempfile import mkstemp
from textwrap import wrap
from subprocess import Popen, PIPE

try:
    import json
except ImportError:
    import simplejson as json  # python < 2.6

import rpm

from spacecmd.argumentparser import SpacecmdArgumentParser

__EDITORS = ['vim', 'vi', 'nano', 'emacs']


def get_argument_parser():
    return SpacecmdArgumentParser()

def parse_command_arguments(command_args, argument_parser, glob=True):
    try:
        parts = shlex.split(command_args)

        # allow simple globbing
        if glob:
            parts = [re.sub(r'\*', '.*', a) for a in parts]

        argument_parser.add_argument('leftovers', nargs='*',
                                     help=argparse.SUPPRESS)
        opts = argument_parser.parse_args(args=parts)
        if opts.leftovers:
            leftovers = opts.leftovers
        else:
            leftovers = []
        return leftovers, opts
    except IndexError:
        return None, None


# check if any named options were passed to the function, and if so,
# declare that the function is non-interactive
# note: because we do it this way, default options are not passed into
# OptionParser, as it would make determining if any options were passed
# too complex
def is_interactive(options):
    for key in options.__dict__:
        if options.__dict__[key]:
            return False

    return True


def load_cache(cachefile):
    data = {}
    expire = datetime.now()

    logging.debug('Loading cache from %s', cachefile)

    if os.path.isfile(cachefile):
        try:
            inputfile = open(cachefile, 'rb')
            data = pickle.load(inputfile)
            inputfile.close()
        except EOFError:
            # If cache generation is interrupted (e.g by ctrl-c) you can end up
            # with an EOFError exception due to the partial picked file
            # So we catch this error and remove the corrupt partial file
            # If you don't do this then spacecmd will fail with an unhandled
            # exception until the partial file is manually removed
            logging.warning("Loading cache file %s failed", cachefile)
            logging.warning("Cache generation was probably interrupted," +
                            "removing corrupt %s", cachefile)
            os.remove(cachefile)
        except IOError:
            logging.error("Couldn't load cache from %s", cachefile)

        if isinstance(data, (list, dict)):
            if 'expire' in data:
                expire = data['expire']
                del data['expire']
    else:
        logging.debug('%s does not exist', cachefile)

    return data, expire


def save_cache(cachefile, data, expire=None):
    if expire:
        data['expire'] = expire

    try:
        output = open(cachefile, 'wb')
        pickle.dump(data, output, pickle.HIGHEST_PROTOCOL)
        output.close()
    except IOError:
        logging.error("Couldn't write to %s", cachefile)

    if 'expire' in data:
        del data['expire']


def tab_completer(options, text):
    return [o for o in options if re.match(text, o)]


def filter_results(items, patterns, search=False):
    matches = []

    compiled_patterns = []
    for pattern in patterns:
        if search:
            compiled_patterns.append(re.compile(pattern, re.I))
        else:
            # If in "match" mode, we don't want to match substrings
            compiled_patterns.append(re.compile("^" + pattern + "$", re.I))

    for item in items:
        for pattern in compiled_patterns:
            if search:
                result = pattern.search(item)
            else:
                result = pattern.match(item)

            if result:
                matches.append(item)
                break

    return matches


def editor(template='', delete=False):
    # create a temporary file
    (descriptor, file_name) = mkstemp(prefix='spacecmd.')

    if template and descriptor:
        try:
            handle = os.fdopen(descriptor, 'w')
            handle.write(template)
            handle.close()
        except IOError:
            logging.warning('Could not open the temporary file')

    # use the user's specified editor
    if 'EDITOR' in os.environ:
        if __EDITORS[0] != os.environ['EDITOR']:
            __EDITORS.insert(0, os.environ['EDITOR'])

    success = False
    for editor_cmd in __EDITORS:
        try:
            exit_code = os.spawnlp(os.P_WAIT, editor_cmd,
                                   editor_cmd, file_name)

            if exit_code == 0:
                success = True
                break
            else:
                logging.error('Editor exited with code %i', exit_code)
        except OSError:
            pass

    if not success:
        logging.error('No editors found')
        return ''

    if os.path.isfile(file_name) and exit_code == 0:
        try:
            # read the session (format = username:session)
            handle = open(file_name, 'r')
            contents = handle.read()
            handle.close()

            if delete:
                try:
                    os.remove(file_name)
                    file_name = ''
                except OSError:
                    logging.error('Could not remove %s', file_name)

            return (contents, file_name)
        except IOError:
            logging.error('Could not read %s', file_name)
            return ([], '')


def prompt_user(prompt, noblank=False, multiline=False):
    try:
        while True:
            if multiline:
                print(prompt)
                userinput = sys.stdin.read()
            else:
                try:
                    # python 2 must call raw_input() because input()
                    # also evaluates the user input and that causes
                    # problems.
                    userinput = raw_input('%s ' % prompt)
                except NameError:
                    # python 3 replaced raw_input() with input()...
                    # it no longer evaulates the user input.
                    userinput = input('%s ' % prompt)
            if noblank:
                if userinput != '':
                    break
            else:
                break
    except EOFError:
        print()
        return ''

    if userinput != '':
        last = readline.get_current_history_length() - 1

        if last >= 0:
            readline.remove_history_item(last)

    return userinput


# parse time input from the user and return xmlrpclib.DateTime
def parse_time_input(userinput=''):
    timestamp = None

    if userinput == '' or re.match('now', userinput, re.I):
        timestamp = datetime.now()

    # handle YYYMMDDHHMM times
    if not timestamp:
        match = re.match(r'^(\d{4})(\d{2})(\d{2})(\d{2})?(\d{2})?(\d{2})?$', userinput)

        if match:
            date_format = '%Y%m%d'

            # YYYYMMDD
            if not match.group(4) and not match.group(5):
                timestamp = time.strptime('%s%s%s' % (match.group(1),
                                                      match.group(2),
                                                      match.group(3)),
                                          date_format)
            # YYYYMMDDHH
            elif not match.group(5):
                date_format += '%H'

                timestamp = time.strptime('%s%s%s%s' % (match.group(1),
                                                        match.group(2),
                                                        match.group(3),
                                                        match.group(4)),
                                          date_format)
            # YYYYMMDDHHMM
            elif not match.group(6):
                date_format += '%H%M'

                timestamp = time.strptime('%s%s%s%s%s' % (match.group(1),
                                                          match.group(2),
                                                          match.group(3),
                                                          match.group(4),
                                                          match.group(5)),
                                          date_format)
            # YYYYMMDDHHMMSS
            else:
                date_format += '%H%M%S'

                timestamp = time.strptime('%s%s%s%s%s%s' % (match.group(1),
                                                            match.group(2),
                                                            match.group(3),
                                                            match.group(4),
                                                            match.group(5),
                                                            match.group(6)),
                                          date_format)
            if timestamp:
                # 2.5 has a nice little datetime.strptime() function...
                timestamp = datetime(*(timestamp)[0:7])

    # handle time differences (e.g., +1m, +2h)
    if not timestamp:
        match = re.search(r'^(\+|-)?(\d+)(s|m|h|d)$', userinput, re.I)

        if match and len(match.groups()) >= 2:
            sign = match.group(1)
            number = int(match.group(2))
            unit = match.group(3)

            if sign == '-':
                number = -number

            if re.match('s', unit, re.I):
                delta = timedelta(seconds=number)
            elif re.match('m', unit, re.I):
                delta = timedelta(minutes=number)
            elif re.match('h', unit, re.I):
                delta = timedelta(hours=number)
            elif re.match('d', unit, re.I):
                delta = timedelta(days=number)

            timestamp = datetime.now() + delta

    if timestamp:
        return xmlrpclib.DateTime(timestamp.timetuple())

    logging.error('Invalid time provided')
    return


# Compares 2 package objects (dicts) and returns the newest one.
# If the objects are the same, we return None
def latest_pkg(pkg1, pkg2, version_key='version',
               release_key='release', epoch_key='epoch'):
    # Sometimes empty epoch is a space, sometimes its an empty string, which
    # breaks the comparison, strip it here to fix
    t1 = (pkg1[epoch_key].strip(), pkg1[version_key], pkg1[release_key])
    t2 = (pkg2[epoch_key].strip(), pkg2[version_key], pkg2[release_key])

    result = rpm.labelCompare(t1, t2) # pylint: disable=no-member
    if result == 1:
        return pkg1
    if result == -1:
        return pkg2

    return None

# build a proper RPM name from the various parts


def build_package_names(packages):
    single = False

    if not isinstance(packages, list):
        packages = [packages]
        single = True

    package_names = []
    for p in packages:
        package = '%s-%s-%s' % (
            p.get('name'), p.get('version'), p.get('release'))

        if p.get('epoch') != ' ' and p.get('epoch') != '':
            package += ':%s' % p.get('epoch')

        if p.get('arch'):
            # system.listPackages uses AMD64 instead of x86_64
            arch = re.sub('AMD64', 'x86_64', p.get('arch'))

            package += '.%s' % arch
        elif p.get('arch_label'):
            package += '.%s' % p.get('arch_label')

        package_names.append(package)

    if single:
        return package_names[0]

    package_names.sort()
    return package_names


def print_errata_summary(erratum):
    # Workaround - recent spacewalk lacks the "date" key
    # on some listErrata calls
    if erratum.get('date') is None:
        erratum['date'] = erratum.get('issue_date')
    if erratum['date'] is None:
        erratum['date'] = "no_date"
    date_parts = erratum['date'].split()

    if len(date_parts) > 1:
        erratum['date'] = date_parts[0]

    print('%s  %s  %s' % (
        erratum.get('advisory_name').ljust(14),
        wrap(erratum.get('advisory_synopsis'), 50)[0].ljust(50),
        erratum.get('date').rjust(8)))


def print_errata_list(errata):
    rhsa = []
    rhea = []
    rhba = []

    for erratum in errata:
        if re.match('security', erratum.get('advisory_type'), re.I):
            rhsa.append(erratum)
        elif re.match('bug fix', erratum.get('advisory_type'), re.I):
            rhba.append(erratum)
        elif re.match('product enhancement', erratum.get('advisory_type'), re.I):
            rhea.append(erratum)
        else:
            logging.warning('%s is an unknown errata type',
                            erratum.get('advisory_name'))
            continue

    if not errata:
        return

    if rhsa:
        print('Security Errata')
        print('---------------')
        for erratum in rhsa:
            print_errata_summary(erratum)

    if rhba:
        if rhsa:
            print()

        print('Bug Fix Errata')
        print('--------------')
        for erratum in rhba:
            print_errata_summary(erratum)

    if rhea:
        if rhsa or rhba:
            print()

        print('Enhancement Errata')
        print('------------------')
        for erratum in rhea:
            print_errata_summary(erratum)


def config_channel_order(all_channels=None, new_channels=None):
    all_channels = all_channels or []
    new_channels = new_channels or []
    while True:
        print('Current Selections')
        print('------------------')
        for i, new_channel in enumerate(new_channels, 1):
            print('%i. %s' % (i, new_channel))

        print()
        action = prompt_user('a[dd], r[emove], c[lear], d[one]:')

        if re.match('a', action, re.I):
            print()
            print('Available Configuration Channels')
            print('--------------------------------')
            for c in sorted(all_channels):
                print(c)

            print()
            channel = prompt_user('Channel:')

            if channel not in all_channels:
                logging.warning('Invalid channel')
                continue

            try:
                rank = int(prompt_user('New Rank:'))

                if channel in new_channels:
                    new_channels.remove(channel)

                new_channels.insert(rank - 1, channel)
            except IndexError:
                logging.warning('Invalid rank')
                continue
            except ValueError:
                logging.warning('Invalid rank')
                continue
        elif re.match('r', action, re.I):
            channel = prompt_user('Channel:')

            if channel not in all_channels:
                logging.warning('Invalid channel')
                continue

            new_channels.remove(channel)
        elif re.match('c', action, re.I):
            print('Clearing current selections')
            new_channels = []
            continue
        elif re.match('d', action, re.I):
            break

        print()

    return new_channels


def list_locales():
    if not os.path.isdir('/usr/share/zoneinfo'):
        return []

    zones = []

    for item in os.listdir('/usr/share/zoneinfo'):
        path = os.path.join('/usr/share/zoneinfo', item)

        if os.path.isdir(path):
            try:
                for subitem in os.listdir(path):
                    zones.append(os.path.join(item, subitem))
            except IOError:
                logging.error('Could not read %s', path)
        else:
            zones.append(item)

    return zones


# find the longest string in a list
def max_length(items, minimum=0):
    max_size = 1
    for item in items:
        if len(item) > max_size:
            max_size = len(item)

    if max_size < minimum:
        max_size = minimum

    return max_size


# read in a file
def read_file(filename):
    handle = open(filename, 'r')
    contents = handle.read()
    handle.close()

    return contents


def parse_str(s, type_to=None):
    """
    Similar to 'read :: Read a => String -> a' in Haskell.

    >>> parse_str('1234567', int)
    1234567
    >>> parse_str('1234567')
    1234567
    >>> parse_str('abcXYZ012')
    'abcXYZ012'
    >>> d = dict(channelLabel="foo-i386-5")
    >>> d = parse_str('{"channelLabel": "foo-i386-5"}')
    >>> assert d["channelLabel"] == 'foo-i386-5'

    """
    try:
        if type_to is not None and isinstance(type_to, type):
            return type_to(s)

        if re.match(r'[1-9]\d*', s):
            return int(s)

        if re.match(r'{.*}', s):
            return json.loads(s)  # retry with json module

        return str(s)

    except ValueError:
        return str(s)


def parse_list_str(list_s, sep=","):
    """
    simple parser for a list of items separated with "," (comma) or given
    separator chars.

    >>> assert parse_list_str("") == []
    >>> assert parse_list_str("a,b") == ["a", "b"]
    >>> assert parse_list_str("a,b,") == ["a", "b"]
    >>> assert parse_list_str("a:b:", ":") == ["a", "b"]
    """
    return [p for p in list_s.split(sep) if p]


def parse_api_args(args, sep=','):
    """
    Simple JSON-like expression parser.

    :param args: a list of strings may be separated with sep, and each
                 string represents parameters passed to API later.
    :type args:  `str`

    :param sep: A char to separate paramters in `args`
    :type sep:  `str`

    :rtype:  rpc arg objects, [arg] :: [string]

    >>> parse_api_args('')
    []
    >>> parse_api_args('1234567')
    [1234567]
    >>> parse_api_args('abcXYZ012')
    ['abcXYZ012']

    >>> assert parse_api_args('{"channelLabel": "foo-i386-5"}')[0]["channelLabel"] == "foo-i386-5"

    >>> (i, s, d) = parse_api_args('1234567,abcXYZ012,{"channelLabel": "foo-i386-5"}')
    >>> assert i == 1234567
    >>> assert s == "abcXYZ012"
    >>> assert d["channelLabel"] == "foo-i386-5"

    >>> (i, s, d) = parse_api_args('[1234567,"abcXYZ012",{"channelLabel": "foo-i386-5"}]')
    >>> assert i == 1234567
    >>> assert s == "abcXYZ012"
    >>> assert d["channelLabel"] == "foo-i386-5"
    """
    if not args:
        return []

    try:
        x = json.loads(args)
        ret = x if isinstance(x, list) else [x]

    except ValueError:
        ret = [parse_str(a) for a in parse_list_str(args, sep)]

    return ret


def json_dump(obj, fp, indent=4, **kwargs):
    json.dump(obj, fp, ensure_ascii=False, indent=indent, **kwargs)


def json_dump_to_file(obj, filename):
    json_data = json.dumps(obj, indent=4, sort_keys=True)

    if json_data is None:
        logging.error("Could not generate json data object!")
        return False

    try:
        fd = open(filename, 'w')
        fd.write(json_data)
        fd.close()
    except IOError as E:
        logging.error("Could not open file %s for writing, permissions?",
                      filename)
        print(E.strerror)
        return False

    return True


def json_read_from_file(filename):
    try:
        data = open(filename).read()
        try:
            jsondata = json.loads(data)
            return jsondata
        except ValueError:
            print("could not read in data from %s" % filename)
    except IOError:
        print("could not open file %s for reading, check permissions?" % filename)
        return None


def get_string_diff_dicts(string1, string2, sep="-"):
    """
    compares two strings and determine, if one string can be transformed into the other by simple string replacements.

    If these strings are closly related, it returns two dictonaries of regular expressions.

    The first dictionary can be used to transfrom type 1 strings into type 2 strings.
    The second dictionary vice versa.

    These replacements blocks must be separated by "-".

    Example:
    string1: rhel6-x86_64-dev-application1
    string2: rhel6-x86_64-qas-application1

    Result:
    dict1: {'(^|-)dev(-|$)': '\\1DIFF(dev|qas)\\2'}
    dict2: {'(^|-)qas(-|$)': '\\1DIFF(dev|qas)\\2'}
    """
    replace1 = {}
    replace2 = {}

    if string1 == string2:
        logging.info("Skipping usage of common strings: both strings are equal")
        return [None, None]
    substrings1 = deque(string1.split(sep))
    substrings2 = deque(string2.split(sep))

    while substrings1 and substrings2:
        sub1 = substrings1.popleft()
        sub2 = substrings2.popleft()
        if sub1 == sub2:
            # equal, nothing to do
            pass
        else:
            # TODO: replace only if len(sub1) == len(sub2) ?
            replace1['(^|-)' + sub1 + '(-|$)'] = r'\1' + "DIFF(" + sub1 + "|" + sub2 + ")" + r'\2'
            replace2['(^|-)' + sub2 + '(-|$)'] = r'\1' + "DIFF(" + sub1 + "|" + sub2 + ")" + r'\2'
    if substrings1 or substrings2:
        logging.info("Skipping usage of common strings: number of substrings differ")
        return [None, None]
    return [replace1, replace2]


def replace(line, replacedict):
    if replacedict:
        for source in replacedict:
            line = re.sub(source, replacedict[source], line)
    return line


def get_normalized_text(text, replacedict=None, excludes=None):
    # parts of the data inside the spacewalk component information
    # are not really differences between two instances.
    # Therefore parts of the data will be modified before the diff:
    # - specific lines, starting with a defined keyword, will be excluded
    # - specific character sequences will be replaced with the same text in both instances.
    # Example:
    # we want to compare two related activationkeys:
    # "1-rhel6-x86_64-dev" and "1-rhel6-x86_64-prd"
    # ("dev" for "development" and "prd" for "production").
    # We assume that the "dev" activationkey "1-rhel6-x86_64-dev"
    # has references to other "dev" components,
    # while the "prd" activationkey "1-rhel6-x86_64-prd"
    # has references to other "prd" components.
    # Therefore we replace all occurrences of "dev" in "1-rhel6-x86_64-dev"
    # and all occurrences of "prd" in "1-rhel6-x86_64-prd"
    # with the common string "DIFF(dev|prd)".
    # What differences are to be replaced is guessed
    # from the name differences of there components.
    # This will not work always, but it help in a lot of cases.

    normalized_text = []
    if text:
        for st in text:
            for line in st.split("\n"):
                if not excludes:
                    normalized_text.append(replace(line, replacedict))
                # We do it this way instead of passing a tuple to
                # line.startswith to allow compatibility with python 2.4
                elif not [e for e in excludes if line.startswith(e)]:
                    normalized_text.append(replace(line, replacedict))
                else:
                    logging.debug("excluding line: " + line)
    return normalized_text


def diff(source_data, target_data, source_channel, target_channel):
    return list(unified_diff(source_data, target_data, source_channel, target_channel))


def file_is_binary(self, path):
    """Tries to determine whether the file is a binary.
       Assumes binary if it can't categorize the file as plaintext"""
    try:
        process = Popen(["file", "-b", "--mime-type", path], stdout=PIPE)
        output = process.communicate()[0]
        exit_code = process.wait()
        if exit_code != 0:
            return True

        if output.startswith("text/"):
            return False
    except OSError:
        pass
    return True


def string_to_bool(input_string):
    if not isinstance(input_string, bool):
        return input_string.lower().rstrip(' ') == 'true'
    return input_string
