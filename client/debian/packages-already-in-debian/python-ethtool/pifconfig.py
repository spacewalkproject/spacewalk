#! /usr/bin/python
# -*- python -*-
# -*- coding: utf-8 -*-
# Copyright (C) 2008--2013 Red Hat, Inc.
#
#   Arnaldo Carvalho de Melo <acme@redhat.com>
#
#   This application is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; version 2.
#
#   This application is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.

import getopt, ethtool, sys

def usage():
	print '''Usage:
  pifconfig <interface>
'''

def flags2str(flags):
	string = ""
	if flags & ethtool.IFF_UP:
		string += "UP "
	if flags & ethtool.IFF_BROADCAST:
		string += "BROADCAST "
	if flags & ethtool.IFF_DEBUG:
		string += "DEBUG "
	if flags & ethtool.IFF_LOOPBACK:
		string += "LOOPBACK "
	if flags & ethtool.IFF_POINTOPOINT:
		string += "POINTOPOINT "
	if flags & ethtool.IFF_NOTRAILERS:
		string += "NOTRAILERS "
	if flags & ethtool.IFF_RUNNING:
		string += "RUNNING "
	if flags & ethtool.IFF_NOARP:
		string += "NOARP "
	if flags & ethtool.IFF_PROMISC:
		string += "PROMISC "
	if flags & ethtool.IFF_ALLMULTI:
		string += "ALLMULTI "
	if flags & ethtool.IFF_MASTER:
		string += "MASTER "
	if flags & ethtool.IFF_SLAVE:
		string += "SLAVE "
	if flags & ethtool.IFF_MULTICAST:
		string += "MULTICAST "
	if flags & ethtool.IFF_PORTSEL:
		string += "PORTSEL "
	if flags & ethtool.IFF_AUTOMEDIA:
		string += "AUTOMEDIA "
	if flags & ethtool.IFF_DYNAMIC:
		string += "DYNAMIC "

	return string.strip()

def show_config(device):
	ipaddr = ethtool.get_ipaddr(device)
	netmask = ethtool.get_netmask(device)
	flags = ethtool.get_flags(device)
	print '%-9.9s' % device,
	if not (flags & ethtool.IFF_LOOPBACK):
		print "HWaddr %s" % ethtool.get_hwaddr(device),
	print '''
          inet addr:%s''' % ipaddr,
	if not (flags & (ethtool.IFF_LOOPBACK | ethtool.IFF_POINTOPOINT)):
		print "Bcast:%s" % ethtool.get_broadcast(device),
	print '''  Mask:%s
	  %s
''' % (netmask, flags2str(flags))

def main():
	global all_devices

	try:
		opts, args = getopt.getopt(sys.argv[1:],
					   "h",
					   ("help",))
	except getopt.GetoptError, err:
		usage()
		print str(err)
		sys.exit(2)

	for o, a in opts:
		if o in ("-h", "--help"):
			usage()
			return

	active_devices = ethtool.get_active_devices()
	for device in active_devices:
		show_config(device)

if __name__ == '__main__':
    main()
