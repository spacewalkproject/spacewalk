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

from spacecmd.utils import *

def help_package_details(self):
    print 'package_details: Show the details of a software package'
    print 'usage: package_details PACKAGE ...'

def complete_package_details(self, text, line, beg, end):
    return tab_completer(self.get_package_names(True), text)

def do_package_details(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_package_details()
        return

    add_separator = False

    self.generate_package_cache()

    for package in args:
        if add_separator: print self.SEPARATOR
        add_separator = True

        package_id = self.get_package_id(package)

        if not package_id:
            logging.warning('%s is not a valid package' % package)
            continue

        details = self.client.packages.getDetails(self.session, package_id)

        channels = \
            self.client.packages.listProvidingChannels(self.session, package_id)

        print 'Name:    %s' % details.get('name')
        print 'Version: %s' % details.get('version')
        print 'Release: %s' % details.get('release')
        print 'Epoch:   %s' % details.get('epoch')
        print 'Arch:    %s' % details.get('arch_label')

        print
        print 'Description: '
        print '\n'.join(wrap(details.get('description')))

        print
        print 'File:    %s' % details.get('file')
        print 'Size:    %s' % details.get('size')
        print 'MD5:     %s' % details.get('md5sum')

        print
        print 'Available From'
        print '--------------'
        print '\n'.join(sorted([c.get('label') for c in channels]))

####################

def help_package_search(self):
    print 'package_search: Find packages that meet the given criteria'
    print 'usage: package_search NAME|QUERY'
    print
    print 'Example: package_search kernel'
    print
    print 'Advanced Search:'
    print 'Available Fields: name, epoch, version, release, arch, ' + \
          'description, summary'
    print 'Example: name:kernel AND version:2.6.18 AND -description:devel'

def do_package_search(self, args, doreturn = False):
    if not len(args):
        self.help_package_search()
        return

    fields = ('name', 'epoch', 'version', 'release',
              'arch', 'description', 'summary')

    packages = []
    advanced = False

    for f in fields:
        if re.match('%s:' % f, args):
            logging.debug('Using advanced search')
            advanced = True
            break

    if advanced:
        packages = self.client.packages.search.advanced(self.session, args)
        packages = build_package_names(packages)
    else:
        # for non-advanced searches, use local regex instead of
        # the APIs for searching; this is done because the fuzzy
        # search on the server gives a lot of garbage back
        self.generate_package_cache()
        packages = filter_results(self.get_package_names(True),
                                  [ args ], search = True)

    if doreturn:
        return packages
    else:
        print '\n'.join(sorted(packages))

####################

def help_package_remove(self):
    print 'package_remove: Remove a package from Satellite'
    print 'usage: package_remove PACKAGE ...'

def complete_package_remove(self, text, line, beg, end):
    return tab_completer(self.get_package_names(True), text)

def do_package_remove(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_package_remove()
        return

    packages = args

    to_remove = filter_results(self.get_package_names(True), packages)

    if not len(to_remove): return

    print 'Packages'
    print '--------'
    print '\n'.join(sorted(to_remove))

    if not self.user_confirm('Remove these packages [y/N]:'): return

    for package in to_remove:
        package_id = self.get_package_id(package)

        try:
            self.client.packages.removePackage(self.session, package_id)
        except:
            logging.error('Failed to remove package ID %i' % package_id)
   
    # regenerate the package cache after removing these packages         
    self.generate_package_cache(True)

####################

def help_package_listorphans(self):
    print 'package_listorphans: List packages that are not in a channel'
    print 'usage: package_listorphans'

def do_package_listorphans(self, args, doreturn=False):
    packages = self.client.channel.software.listPackagesWithoutChannel(\
                                            self.session)

    packages = build_package_names(packages)

    if doreturn:
        return packages
    else:
        if len(packages):
            print '\n'.join(sorted(packages))

####################

def help_package_removeorphans(self):
    print 'package_removeorphans: Remove packages that are not in a channel'
    print 'usage: package_removeorphans'

def do_package_removeorphans(self, args):
    packages = \
        self.client.channel.software.listPackagesWithoutChannel(self.session)

    if not len(packages):
        logging.warning('No orphaned packages')
        return

    print 'Packages'
    print '--------'
    print '\n'.join(sorted(build_package_names(packages)))

    if not self.user_confirm('Remove these packages [y/N]:'): return

    for package in packages:
        try:
            self.client.packages.removePackage(self.session, package.get('id'))
        except:
            logging.error('Failed to remove package ID %i' % package.get('id'))
        
# vim:ts=4:expandtab:
