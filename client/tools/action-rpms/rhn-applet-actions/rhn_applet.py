#!/usr/bin/python
#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
import sys
import string
import re

sys.path.append("/usr/share/rhn")
from up2date_client import config
from up2date_client import up2dateAuth

from rhn import rpclib

__rhnexport__ = [
    'use_satellite'
    ]

APPLET_CONF = '/etc/sysconfig/rhn/rhn-applet'

def _get_config():
    """send back a cross platform structure containing cfg info"""
    return config.initUp2dateConfig()

cfg = _get_config()

def _get_uuid_config():
    cfg = config.UuidConfig()
    cfg.load()
    # Fix the permissions on the up2date uuid file too - should be world
    # readable
    if os.path.exists(cfg.fileName):
        os.chmod(cfg.fileName, 0644)
    return cfg

def _create_server_obj(server_url):
    
    enable_proxy = read_cfg_val(cfg, 'enableProxy')
    enable_proxy_auth = read_cfg_val(cfg, 'enableProxyAuth')
    proxy_host = None
    proxy_user = None
    proxy_password = None
    
    if enable_proxy:
        proxy_host = self._local_config.get('httpProxy')
                                                                                       
        if enable_proxy_auth:
            proxy_user = read_cfg_val(cfg, 'proxyUser')
            proxy_password = read_cfg_val(cfg, 'proxyPassword')
                                                                                       
    ca = read_cfg_val(cfg, 'sslCACert')
        
    if type(ca) == type(""):
        ca = [ca]
 
    ca_certs = ca or ["/usr/share/rhn/RHNS-CA-CERT"]

    lang = None
    for env in 'LANGUAGE', 'LC_ALL', 'LC_MESSAGES', 'LANG':
        if os.environ.has_key(env):
            if not os.environ[env]:
                # sometimes unset
                continue
            lang = string.split(os.environ[env], ':')[0]
            lang = string.split(lang, '.')[0]
            break


    server = rpclib.Server(server_url,
                           proxy=proxy_host,
                           username=proxy_user,
                           password=proxy_password)
                                                                                       
    #server.set_transport_flags(encoding="gzip", transfer="binary")
                                                                                       
    if lang:
        server.setlang(lang)
                                                                                       
    for ca_cert in ca_certs:
        if not os.access(ca_cert, os.R_OK):
            raise Exception("could not find cert %s" % ca_cert)
                                                                                       
        server.add_trusted_cert(ca_cert)

    return server


def read_cfg_val(obj, key):
    """ return obj[key] or None if key does not exist"""
    if obj.has_key(key):
        return obj[key]
    return None
        
def update_applet_cfg():

    # get up2date's conf vals...
    server_url = read_cfg_val(cfg, 'serverURL')
    new_ca = read_cfg_val(cfg, 'sslCACert')

    if type(server_url) == type([]):
        server_url = server_url[0]

    # TODO: applet needs to support failover 
    # for now patch the ca
    if type(new_ca) == type([]):
        new_ca_buf = "%s" % (string.join(map(str, new_ca), ';'))
    else:
        new_ca_buf = new_ca

    # determine the new needed values
    new_url = re.sub(r"(http[s]?://.*?)/.*$", r"\1/APPLET", server_url)

    backup_filename = APPLET_CONF + ".bak"
    new_filename = APPLET_CONF + ".new"

    # slurp in the current conf to snag the uuid
    contents = open(APPLET_CONF, "r").read()

    up2date_uuid_cfg = _get_uuid_config()
    uuid = read_cfg_val(up2date_uuid_cfg, "rhnuuid")
    
    try:        
        # 2. create new file
        fd = os.open(new_filename, os.O_RDWR | os.O_CREAT | os.O_EXCL, 0644)
        new_file = os.fdopen(fd, 'w')
        new_file.seek(0)

        seen_ca_cert = 0
        
        for line in string.split(contents, "\n"):
            if line.startswith('server_url='):                
                new_file.write("server_url=%s\n\n" % new_url)
                continue
            
            if line.startswith('uuid='):
              if uuid:
                  # Use the up2date uuid instead
                  new_file.write("uuid=%s\n\n" % uuid)
                  continue
              # Load the applet's uuid
              uuid = (string.split(line, '='))[1]
              new_file.write(line + '\n\n')
              continue
            
            if line.startswith('use_ca_cert='):
              seen_ca_cert = 1
              new_file.write("use_ca_cert=%s\n" % new_ca_buf)
              continue

        if new_ca and not seen_ca_cert:
            new_file.write("use_ca_cert=%s\n" % new_ca_buf)

        new_file.close()
        
        # 3. rename current to backup
        os.rename(APPLET_CONF, backup_filename)
        # 4. rename new to current
        os.rename(new_filename, APPLET_CONF)
        # 5. unlink backup
        os.unlink(backup_filename)
    except Exception:
        # failure, restore from backup and error out
        os.rename(backup_filename, APPLET_CONF)
        raise
    return (new_url, uuid)


def use_satellite():
    """updates rhn-applet's config w/ up2date's server_url value, and ties uuid w/ systemid"""

    try:
        (new_url, uuid) = update_applet_cfg()
    except Exception, e:
        return (1, "unable to update rhn-applet config file:  %s" % e, {})

    try:
        server = _create_server_obj(new_url)
        server.applet.tie_uuid(up2dateAuth.getSystemId(), uuid)
    except Exception, e:
        return (1, "unable to tie rhn-applet uuid to systemid:  %s" % e, {})

    
    return (0, "rhn-applet now configured to use %s" % new_url, {})


def main():
    print use_satellite()

if __name__ == "__main__":
    main()
