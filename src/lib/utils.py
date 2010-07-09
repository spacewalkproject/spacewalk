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
# Copyright 2010 Aron Parsons <aron@redhat.com>
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

import logging, os, pickle, re, readline, time, xmlrpclib
from datetime import datetime, timedelta
from tempfile import mkstemp
from textwrap import wrap

__EDITORS = ['vim', 'vi', 'nano', 'emacs']

def parse_arguments(args):
    try:
        parts = args.split()

        # allow simple globbing
        parts = [re.sub('\*', '.*', a) for a in parts]

        return parts
    except IndexError:
        return []


def load_cache(cachefile):
    data = {}
    expire = datetime.now()

    logging.debug('Loading cache from %s' % cachefile)

    if os.path.isfile(cachefile):
        try:
            inputfile = open(cachefile, 'r')
            data = pickle.load(inputfile)
            inputfile.close()
        except IOError:
            logging.error("Couldn't load cache from %s" % cachefile)

        if isinstance(data, list) or isinstance(data, dict):
            if 'expire' in data:
                expire = data['expire']
                del data['expire']
    else:
        logging.debug('%s does not exist' % cachefile)

    return data, expire


def save_cache(cachefile, data, expire = None):
    if expire:
        data['expire'] = expire

    try:
        output = open(cachefile, 'wb')
        pickle.dump(data, output, pickle.HIGHEST_PROTOCOL)
        output.close()
    except IOError:
        logging.error("Couldn't write to %s" % cachefile)

    if 'expire' in data:
        del data['expire']


def tab_completer(options, text):
    return [ o for o in options if re.match(text, o) ]


def filter_results(items, patterns, search = False):
    matches = []
    
    compiled_patterns = []
    for pattern in patterns:
        compiled_patterns.append(re.compile(pattern, re.I))

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


def editor(template = '', delete = False):
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
                logging.error('Editor exited with code %i' % exit_code)
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
                    logging.error('Could not remove %s' % file_name)

            return (contents, file_name)
        except IOError:
            logging.error('Could not read %s' % file_name)
            return ([], '')


def prompt_user(prompt, noblank = False):
    try:
        while True:
            userinput = raw_input('%s ' % prompt)
            if noblank:
                if userinput != '':
                    break
            else:
                break
    except EOFError:
        print
        return ''

    if userinput != '':
        last = readline.get_current_history_length() - 1

        if last >= 0:
            readline.remove_history_item(last)

    return userinput


def format_time(timestamp):
    return re.sub('T', ' ', timestamp)


# parse time input from the userand return xmlrpclib.DateTime
def parse_time_input(userinput = ''):
    timestamp = None

    if userinput == '' or re.match('now', userinput, re.I):
        timestamp = datetime.now()

    # handle YYYMMDDHHMM times
    if not timestamp:
        match = re.match('^(\d{4})(\d{2})(\d{2})(\d{2})?(\d{2})?$', userinput)
       
        if match:
            format = '%Y%m%d'
    
            if len(match.groups()) == 3:
                # YYYYMMDD
                timestamp = time.strptime('%s%s%s' % (match.group(1),
                                                      match.group(2),
                                                      match.group(3)),
                                          format)
            if len(match.groups()) == 4:
                # YYYYMMDDHH
                format += '%H'
    
                timestamp = time.strptime('%s%s%s%s' % (match.group(1),
                                                        match.group(2),
                                                        match.group(3),
                                                        match.group(4)),
                                          format)
            elif len(match.groups()) == 5:
                # YYYYMMDDHHMM
                format += '%H%M'
    
                timestamp = time.strptime('%s%s%s%s%s' % (match.group(1),
                                                          match.group(2),
                                                          match.group(3),
                                                          match.group(4),
                                                          match.group(5)),
                                          format)
    
            if timestamp:
                # 2.5 has a nice little datetime.strptime() function...
                timestamp = datetime(*(timestamp)[0:7])
     
    # handle time differences (e.g., +1m, +2h) 
    if not timestamp:
        match = re.search('^\+?(\d+)(s|m|h|d)$', userinput, re.I)

        if match and len(match.groups()) == 2:
            number = int(match.group(1))
            unit = match.group(2)

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
    else:
        logging.error('Invalid time provided')
        return


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
    else:
        package_names.sort()
        return package_names


def print_errata_summary(errata):
    date_parts = errata.get('date').split()

    if len(date_parts) > 1:
        errata['date'] = date_parts[0]

    print '%s  %s  %s'  % (
          errata.get('advisory_name').ljust(14),
          wrap(errata.get('advisory_synopsis'), 50)[0].ljust(50),
          errata.get('date').rjust(8))


def print_errata_list(errata):
    rhsa = []
    rhea = []
    rhba = []

    for e in errata:
        if re.match('security', e.get('advisory_type'), re.I):
            rhsa.append(e)
        elif re.match('bug fix', e.get('advisory_type'), re.I):
            rhba.append(e)
        elif re.match('enhancement', e.get('advisory_type'), re.I):
            rhea.append(e)
        else:
            logging.warning('%s is an unknown errata type' % (
                            e.get('advisory_name')))
            continue

    if not len(errata): return

    if len(rhsa):
        print 'Security Errata'
        print '---------------'
        for e in rhsa:
            print_errata_summary(e)

    if len(rhba):
        if len(rhsa):
            print

        print 'Bug Fix Errata'
        print '--------------'
        for e in rhba:
            print_errata_summary(e)

    if len(rhea):
        if len(rhsa) or len(rhba):
            print

        print 'Enhancement Errata'
        print '------------------'
        for e in rhea:
            print_errata_summary(e)


def print_action_summary(action, systems=[]):
    print 'ID:         %i' % action.get('id')
    print 'Type:       %s' % action.get('type')
    print 'Scheduler:  %s' % action.get('scheduler')
    print 'Start Time: %s' % format_time(action.get('earliest').value)
    print 'Systems:    %i' % len(systems)


#XXX: Bugzilla 608868
def print_action_output(action):
    print 'System:    %s' % action.get('server_name')
    print 'Completed: %s' % format_time(action.get('timestamp').value)
    print
    print 'Output'
    print '------'
    print action.get('message')
    

def config_channel_order(all_channels=[], new_channels=[]):
    while True:
        print 'Current Selections'
        print '------------------'
        for i in range(len(new_channels)):
            print '%i. %s' % (i + 1, new_channels[i])
  
        print 
        action = prompt_user('a[dd], r[emove], c[lear], d[one]:')

        if re.match('a', action, re.I):
            print 
            print 'Available Configuration Channels'
            print '--------------------------------'
            for c in sorted(all_channels):
                print c

            print
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
            print 'Clearing current selections'
            new_channels = []
            continue
        elif re.match('d', action, re.I):
            break

        print

    return new_channels


def list_locales():
    if not os.path.isdir('/usr/share/zoneinfo'): return []

    zones = []

    for item in os.listdir('/usr/share/zoneinfo'):
        path = os.path.join('/usr/share/zoneinfo', item)

        if os.path.isdir(path):
            try:
                for subitem in os.listdir(path):
                    zones.append(os.path.join(item, subitem))
            except IOError:
                logging.error('Could not read %s' % path)
        else:
            zones.append(item)

    return zones

# vim:ts=4:expandtab:
