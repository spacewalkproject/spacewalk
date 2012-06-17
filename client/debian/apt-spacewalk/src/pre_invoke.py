#!/usr/bin/python
#
# APT::Update::Pre-Invoke hook for updating sources.list
#
# Author:  Simon Lukasik
# Date:    2011-03-14
# License: GPLv2
#
# Copyright (c) 1999--2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


import sys
import os
from urlparse import urlparse
from aptsources import sourceslist
import apt_pkg

# Once we have the up2date stuff in a site-packages,
# we don't have to do path magic
import warnings
warnings.filterwarnings("ignore",
    message='the md5 module is deprecated; use hashlib instead')
sys.path.append('/usr/share/rhn/')
from up2date_client import config
from up2date_client import rhnChannel
from up2date_client import up2dateAuth
from up2date_client import up2dateErrors


def get_channels():
    """Return channels associated with a machine"""
    try:
        channels = ['main']
        for channel in rhnChannel.getChannelDetails():
            if channel['parent_channel']:
                channels.append(channel['label'])
        return channels
    except up2dateErrors.Error:
        return []

def get_server():
    """Spacewalk server fqdn"""
    return urlparse(config.getServerlURL()[0]).netloc

def get_conf_file():
    """Path to spacewalk.list configuration file"""
    apt_pkg.init_config()
    directory = apt_pkg.config.get('Dir::Etc::sourceparts',
        'sources.list.d')
    if not os.path.isabs(directory):
        directory = os.path.join('/etc/apt', directory)
    return os.path.join(directory, 'spacewalk.list')

def update_sources_list():
    sources = sourceslist.SourcesList()
    sw_source = []
    for source in sources.list:
        if source.uri.startswith('spacewalk://'):
            source.set_enabled(False)
            sw_source.append(source)

    if up2dateAuth.getSystemId():
        channels = get_channels()
        if len(channels):
            for source in sw_source:
                sources.remove(source)
            sources.add(type='deb',
                        uri='spacewalk://' + get_server(),
                        dist='channels:',
                        orig_comps=channels,
                        file=get_conf_file()
                        )
    sources.save()

if __name__ == '__main__':
    print "Apt-Spacewalk: Updating sources.list"
    update_sources_list()
