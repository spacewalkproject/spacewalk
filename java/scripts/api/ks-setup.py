#!/usr/bin/python
from config import *
from random import choice
import os.path
import optparse
import string
import subprocess
"""
A quick hacky script to quickly creates a profile/distro/channel and activation key
Basically this is useful after you clear the DB and quickly want to setup your stuff..
It expects the following variables set in sat_config.py
SATELLITE_HOST
SATELLITE_LOGIN
SATELLITE_PASSWORD
"""

SUFFIX = "".join([choice(string.letters) for i in range(5)]).lower()

def uniquify(name):
    return name + SUFFIX

def execute(command, shell=True, ignore_rc=False):
    if subprocess.call(command, shell = shell) != 0:
        if not ignore_rc:
            sys.stderr.write("\n -- ERROR:  command '%s' failed.  Setup aborted.\n" % command)
            sys.exit(1)

def setup(parser):
    default = '/distro'
    parser.add_option("-d","--distro", dest="distro",
                                default=default,
                                help="Rhel 5 Distro Path example [/engarchive/released/RHEL-5-Server/U3/i386/os] - default '%s'" % default)

    default = os.path.join(os.path.abspath('.') , 'spacewalk-koan.rpm')
    parser.add_option("-k","--koan", dest="koan",
                                default=default,
                                help="Spacewalk Koan rpm location , if not present build it from /spacewalk/client/tools/spacewalk-koan - default '%s'" % default)

    default = 'fedora'
    parser.add_option("-p","--prefix", dest="prefix",
                                default=default,
                                help="prefix for channel names/ activaiton key name etc] - default '%s'" % default)

def main():
    parser = optparse.OptionParser()
    setup(parser)
    (options, args) = parser.parse_args()

    key = login()
    #create custom channel
    channel = uniquify(options.prefix)
    print channel
    client.channel.software.create(key, channel,uniquify( options.prefix.lower() + "-channel"), options.prefix.title() + " channel","channel-ia32","")

    #upload the spacewalk koan rpm
    execute("sudo /usr/bin/rhnpush -u %s -p %s -c %s  --nosig --server=http://%s/APP %s" % (SATELLITE_LOGIN, SATELLITE_PASSWORD, channel, SATELLITE_HOST, options.koan))

    #create activation key

    act_key = client.activationkey.create(key, uniquify(options.prefix.lower()),
                        uniquify(options.prefix.title() + " Key"), channel, [], False)
    print act_key
    #create the distro
    distro = uniquify(options.prefix.lower())
    client.kickstart.tree.create(key, distro,
                            options.distro, channel, "rhel_5" )

    #create the profile
    profile = uniquify(options.prefix.lower())
    client.kickstart.import_raw_file(key, profile, 'para_host',distro, "Foo" )

    client.auth.logout(key)

if __name__== "__main__":
    main()
