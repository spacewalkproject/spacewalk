/* etherinfo.h - Retrieve ethernet interface info via NETLINK
 *
 * Copyright (C) 2009--2013 Red Hat, Inc.
 *
 * David Sommerseth <davids@redhat.com>
 *
 * This application is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; version 2.
 *
 * This application is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 */

#ifndef _ETHERINFO_H
#define _ETHERINFO_H

#include <netlink/addr.h>
#include <netlink/netlink.h>
#include <netlink/handlers.h>
#include <netlink/route/link.h>
#include <netlink/route/addr.h>
#include <arpa/inet.h>

typedef enum {NLQRY_LINK, NLQRY_ADDR} nlQuery; /**<  Supported query types in the etherinfo code */

int get_etherinfo(struct etherinfo_obj_data *data, nlQuery query);
void free_etherinfo(struct etherinfo *ptr);
void dump_etherinfo(FILE *, struct etherinfo *);

void free_ipv6addresses(struct ipv6address *ptr);

int open_netlink(struct etherinfo_obj_data *);
void close_netlink(struct etherinfo_obj_data *);

#endif
