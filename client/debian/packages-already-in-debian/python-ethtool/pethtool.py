#! /usr/bin/python
# -*- python -*-
# -*- coding: utf-8 -*-
#   Copyright (C) 2008 Red Hat Inc.
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
	print '''Usage: pethtool [OPTIONS] [<interface>]
	-h|--help               Give this help list
	-c|--show-coalesce      Show coalesce options
	-C|--coalesce		Set coalesce options
		[adaptive-rx on|off]
                [adaptive-tx on|off]
                [rx-usecs N]
                [rx-frames N]
                [rx-usecs-irq N]
                [rx-frames-irq N]
                [tx-usecs N]
                [tx-frames N]
                [tx-usecs-irq N]
                [tx-frames-irq N]
                [stats-block-usecs N]
                [pkt-rate-low N]
                [rx-usecs-low N]
                [rx-frames-low N]
                [tx-usecs-low N]
                [tx-frames-low N]
                [pkt-rate-high N]
                [rx-usecs-high N]
                [rx-frames-high N]
                [tx-usecs-high N]
                [tx-frames-high N]
                [sample-interval N]	
	-i|--driver             Show driver information
	-k|--show-offload       Get protocol offload information
	-K|--offload            Set protocol offload
		[ tso on|off ]'''

tab = ""

def printtab(msg):
	print tab + msg

all_devices = []

ethtool_coalesce_msgs = (
	( "stats-block-usecs",
	  "stats_block_coalesce_usecs" ),
	( "sample-interval",
	  "rate_sample_interval" ),
	( "pkt-rate-low",
	  "pkt_rate_low"),
	( "pkt-rate-high",
	  "pkt_rate_high"),
	( "\n" ),
	( "rx-usecs",
	  "rx_coalesce_usecs"),
	( "rx-frames",
	  "rx_max_coalesced_frames"),
	( "rx-usecs-irq",
	  "rx_coalesce_usecs_irq"),
	( "rx-frames-irq",
	  "rx_max_coalesced_frames_irq"),
	( "\n" ),
	( "tx-usecs",
	  "tx_coalesce_usecs"),
	( "tx-frames",
	  "tx_max_coalesced_frames"),
	( "tx-usecs-irq",
	  "tx_coalesce_usecs_irq"),
	( "tx-frames-irq",
	  "tx_max_coalesced_frames_irq"),
	( "\n" ),
	( "rx-usecs-low",
	  "rx_coalesce_usecs_low"),
	( "rx-frame-low",
	  "rx_max_coalesced_frames_low"),
	( "tx-usecs-low",
	  "tx_coalesce_usecs_low"),
	( "tx-frame-low",
	  "tx_max_coalesced_frames_low"),
	( "\n" ),
	( "rx-usecs-high",
	  "rx_coalesce_usecs_high"),
	( "rx-frame-high",
	  "rx_max_coalesced_frames_high"),
	( "tx-usecs-high",
	  "tx_coalesce_usecs_high"),
	( "tx-frame-high",
	  "tx_max_coalesced_frames_high"),
)

def get_coalesce_dict_entry(ethtool_name):
	if ethtool_name == "adaptive-rx":
		return "use_adaptive_rx_coalesce"

	if ethtool_name == "adaptive-tx":
		return "use_adaptive_tx_coalesce"

	for name in ethtool_coalesce_msgs:
		if name[0] == ethtool_name:
			return name[1]

	return None

def show_coalesce(interface, args = None):
	printtab("Coalesce parameters for %s:" % interface)
	try:
		coal = ethtool.get_coalesce(interface)
	except IOError:
		printtab("  NOT supported!")
		return

	printtab("Adaptive RX: %s  TX: %s" % (coal["use_adaptive_rx_coalesce"] and "on" or "off",
					      coal["use_adaptive_tx_coalesce"] and "on" or "off"))

	printed = [ "use_adaptive_rx_coalesce",
		    "use_adaptive_tx_coalesce" ]
	for tunable in ethtool_coalesce_msgs:
		if tunable[0] == '\n':
			print
		else:
			printtab("%s: %s" % (tunable[0], coal[tunable[1]]))
			printed.append(tunable[1])

	coalkeys = coal.keys()
	if len(coalkeys) != len(printed):
		print
		for tunable in coalkeys:
			if tunable not in printed:
				printtab("%s %s" % (tunable, coal[tunable]))
				
def set_coalesce(interface, args):
	try:
		coal = ethtool.get_coalesce(interface)
	except IOError:
		printtab("Interrupt coalescing NOT supported on %s!" % interface)
		return

	changed = False
	args = [a.lower() for a in args]
	for arg, value in [ ( args[i], args[i + 1] ) for i in range(0, len(args), 2) ]:
		real_arg = get_coalesce_dict_entry(arg)
		if not real_arg:
			continue
		if value == "on":
			value = 1
		elif value == "off":
			value = 0
		else:
			try:
				value = int(value)
			except:
				continue
		if coal[real_arg] != value:
			coal[real_arg] = value
			changed = True

	if not changed:
		return

	ethtool.set_coalesce(interface, coal)

def show_offload(interface, args = None):
	try:
		sg = ethtool.get_sg(interface) and "on" or "off"
	except IOError:
		sg = "not supported"

	try:
		tso = ethtool.get_tso(interface) and "on" or "off"
	except IOError:
		tso = "not supported"

	try:
		ufo = ethtool.get_ufo(interface) and "on" or "off"
	except IOError:
		ufo = "not supported"

	try:
		gso = ethtool.get_gso(interface) and "on" or "off"
	except IOError:
		gso = "not supported"

	printtab("scatter-gather: %s" % sg)
	printtab("tcp segmentation offload: %s" % tso)
	printtab("udp fragmentation offload: %s" % ufo)
	printtab("generic segmentation offload: %s" % gso)

def set_offload(interface, args):
	cmd, value = [a.lower() for a in args]

	if cmd == "tso":
		value = value == "on" and 1 or 0
		try:
			ethtool.set_tso(interface, value)
		except:
			pass

ethtool_ringparam_msgs = (
	( "Pre-set maximums", ),
	( "RX:\t\t", "rx_max_pending" ),
	( "RX Mini:\t", "rx_mini_max_pending" ),
	( "RX Jumbo:\t", "rx_jumbo_max_pending" ),
	( "TX:\t\t", "tx_max_pending" ),
	( "Current hardware settings", ),
	( "RX:\t\t", "rx_pending" ),
	( "RX Mini:\t", "rx_mini_pending" ),
	( "RX Jumbo:\t", "rx_jumbo_pending" ),
	( "TX:\t\t", "tx_pending" ),
)

def show_ring(interface, args = None):
	printtab("Ring parameters for %s:" % interface)
	try:
		ring = ethtool.get_ringparam(interface)
	except IOError:
		printtab("  NOT supported!")
		return

	printed = []
	for tunable in ethtool_ringparam_msgs:
		if len(tunable) == 1:
			printtab("%s:" % tunable[0])
		else:
			printtab("%s %s" % (tunable[0], ring[tunable[1]]))
			printed.append(tunable[1])

	ringkeys = ring.keys()
	if len(ringkeys) != len(printed):
		print
		for tunable in ringkeys:
			if tunable not in printed:
				printtab("%s %s" % (tunable, ring[tunable]))

ethtool_ringparam_map = {
	"rx":	    "rx_pending",
	"rx-mini":  "rx_mini_pending",
	"rx-jumbo": "rx_jumbo_pending",
	"tx":	    "tx_pending",
}

def set_ringparam(interface, args):
	try:
		ring = ethtool.get_ringparam(interface)
	except IOError:
		printtab("ring parameters NOT supported on %s!" % interface)
		return

	changed = False
	args = [a.lower() for a in args]
	for arg, value in [ ( args[i], args[i + 1] ) for i in range(0, len(args), 2) ]:
		if not ethtool_ringparam_map.has_key(arg):
			continue
		try:
			value = int(value)
		except:
			continue
		real_arg = ethtool_ringparam_map[arg]
		if ring[real_arg] != value:
			ring[real_arg] = value
			changed = True

	if not changed:
		return

	ethtool.set_ringparam(interface, ring)

def show_driver(interface, args = None):
	try:
		driver = ethtool.get_module(interface)
	except IOError:
		driver = "not implemented"

	try:
		bus = ethtool.get_businfo(interface)
	except IOError:
		bus = "not available"

	printtab("driver: %s" % driver)
	printtab("bus-info: %s" % bus)

def run_cmd(cmd, interface, args):
	global tab, all_devices

	active_devices = ethtool.get_active_devices()
	if not interface:
		tab = "  "
		for interface in all_devices:
			inactive = " (not active)"
			if interface in active_devices:
				inactive = ""
			print "%s%s:" % (interface, inactive)
			cmd(interface, args)
	else:
		cmd(interface, args)

def run_cmd_noargs(cmd, args):
	if args:
		run_cmd(cmd, args[0], None)
	else:
		global all_devices
		all_devices = ethtool.get_devices()
		run_cmd(cmd, None, None)

def main():
	global all_devices

	try:
		opts, args = getopt.getopt(sys.argv[1:],
					   "hcCgGikK",
					   ("help",
					    "show-coalesce",
					    "coalesce",
					    "show-ring",
					    "set-ring",
					    "driver",
					    "show-offload",
					    "offload"))
	except getopt.GetoptError, err:
		usage()
		print str(err)
		sys.exit(2)

	if not opts:
		usage()
		sys.exit(0)

	for o, a in opts:
		if o in ("-h", "--help"):
			usage()
			return
		elif o in ("-c", "--show-coalesce"):
			run_cmd_noargs(show_coalesce, args)
			break
		elif o in ("-i", "--driver"):
			run_cmd_noargs(show_driver, args)
			break
		elif o in ("-k", "--show-offload"):
			run_cmd_noargs(show_offload, args)
			break
		elif o in ("-g", "--show-ring"):
			run_cmd_noargs(show_ring, args)
			break
		elif o in ("-K", "--offload",
			   "-C", "--coalesce",
			   "-G", "--set-ring"):
			all_devices = ethtool.get_devices()
			if len(args) < 2:
				usage()
				sys.exit(1)

			if args[0] not in all_devices:
				interface = None
			else:
				interface = args[0]
				args = args[1:]

			if o in ("-K", "--offload"):
				cmd = set_offload
			elif o in ("-C", "--coalesce"):
				cmd = set_coalesce
			elif o in ("-G", "--set-ring"):
				cmd = set_ringparam

			run_cmd(cmd, interface, args)
			break

if __name__ == '__main__':
    main()
