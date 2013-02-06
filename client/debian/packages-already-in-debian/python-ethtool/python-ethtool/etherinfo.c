/* etherinfo.c - Retrieve ethernet interface info via NETLINK
 *
 * Copyright (C) 2009-2011 Red Hat Inc.
 *
 * David Sommerseth <davids@redhat.com>
 * Parts of this code is based on ideas and solutions in iproute2
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

#include <Python.h>
#include <bits/sockaddr.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <asm/types.h>
#include <sys/socket.h>
#include <netlink/route/rtnl.h>
#include <assert.h>
#include <errno.h>
#include <pthread.h>
#include "etherinfo_struct.h"
#include "etherinfo.h"

pthread_mutex_t nlc_counter_mtx = PTHREAD_MUTEX_INITIALIZER;

/*
 *
 *   Internal functions for working with struct etherinfo
 *
 */

/**
 * Simple macro which makes sure the destination string is freed if used earlier.
 *
 * @param dst Destination pointer
 * @param src Source pointer
 *
 */
#define SET_STR_VALUE(dst, src) {	 \
	if( dst ) {		 \
		free(dst);	 \
	};			 \
	dst = strdup(src);	 \
	}


/**
 * Frees the memory used by a struct ipv6address pointer chain.  All elements are freed
 *
 * @param ptr  Pointer to a struct ipv6address chain.
 */
void free_ipv6addresses(struct ipv6address *ptr) {
	struct ipv6address *ipv6ptr = ptr;

	while( ipv6ptr ) {
		struct ipv6address *tmp = ipv6ptr->next;

		if( ipv6ptr->address ) {
			free(ipv6ptr->address);
			ipv6ptr->address = NULL;
		}
		memset(ipv6ptr, 0, sizeof(struct ipv6address));
		free(ipv6ptr);
		ipv6ptr = tmp;
	}
}

/**
 * Frees the memory used by struct etherinfo, including all struct ipv6address children.
 *
 * @param ptr Pointer to a struct etherninfo element
 */
void free_etherinfo(struct etherinfo *ptr)
{
	if( ptr == NULL ) { // Just for safety
		return;
	}

	free(ptr->device);

	if( ptr->hwaddress ) {
		free(ptr->hwaddress);
	}
	if( ptr->ipv4_address ) {
		free(ptr->ipv4_address);
	}
	if( ptr->ipv4_broadcast ) {
		free(ptr->ipv4_broadcast);
	}
	if( ptr->ipv6_addresses ) {
		free_ipv6addresses(ptr->ipv6_addresses);
	}
	free(ptr);
}


/**
 * Add a new IPv6 address record to a struct ipv6address chain
 *
 * @param addrptr    Pointer to the current IPv6 address chain.
 * @param addr       IPv6 address, represented as char * string
 * @param netmask    IPv6 netmask, as returned by libnl rtnl_addr_get_prefixlen()
 * @param scope      IPV6 address scope, as returned by libnl rtnl_addr_get_scope()
 *
 * @return Returns a new pointer to the chain containing the new element
 */
struct ipv6address * etherinfo_add_ipv6(struct ipv6address *addrptr, const char *addr, int netmask, int scope) {
	struct ipv6address *newaddr = NULL;

	newaddr = calloc(1, sizeof(struct ipv6address)+2);
	if( !newaddr ) {
		fprintf(stderr, "** ERROR ** Could not allocate memory for a new IPv6 address record (%s/%i [%i])",
			addr, netmask, scope);
		return addrptr;
	}

	SET_STR_VALUE(newaddr->address, addr);
	newaddr->netmask = netmask;
	newaddr->scope = scope;
	newaddr->next = addrptr;
	return newaddr;
}


/**
 *  libnl callback function.  Does the real parsing of a record returned by NETLINK.  This function
 *  parses LINK related packets
 *
 * @param obj   Pointer to a struct nl_object response
 * @param arg   Pointer to a struct etherinfo element where the parse result will be saved
 */
static void callback_nl_link(struct nl_object *obj, void *arg)
{
	struct etherinfo *ethi = (struct etherinfo *) arg;
	struct rtnl_link *link = (struct rtnl_link *) obj;
	struct nl_addr *addr = rtnl_link_get_addr(link);
	unsigned int i, len;
	unsigned char *binaddr;
	char hwaddr[130], *ptr;

	if( (ethi == NULL) || (ethi->hwaddress != NULL) || (addr == NULL) ) {
		return;
	}

	binaddr = nl_addr_get_binary_addr(addr);
	memset(&hwaddr, 0, 130);
	len = 20;
	ptr = (char *)&hwaddr;
	for( i = 0; i < 6; i++ ) {
		if( i == 0 ) {
			snprintf(ptr, len, "%02X", *(binaddr+i));
			len -= 2;
			ptr += 2;
		} else {
			snprintf(ptr, len, ":%02X", *(binaddr+i));
			len -= 3;
			ptr += 3;
		}
	}
	SET_STR_VALUE(ethi->hwaddress, hwaddr);
}


/**
 *  libnl callback function.  Does the real parsing of a record returned by NETLINK.  This function
 *  parses ADDRESS related packets
 *
 * @param obj   Pointer to a struct nl_object response
 * @param arg   Pointer to a struct etherinfo element where the parse result will be saved
 */
static void callback_nl_address(struct nl_object *obj, void *arg)
{
	struct etherinfo *ethi = (struct etherinfo *) arg;
	struct nl_addr *addr;
	char ip_str[66];
	int family;

	if( ethi == NULL ) {
		return;
	}

	addr = rtnl_addr_get_local((struct rtnl_addr *)obj);
	family = nl_addr_get_family(addr);
	switch( family ) {
	case AF_INET:
	case AF_INET6:
		memset(&ip_str, 0, 66);
		inet_ntop(family, nl_addr_get_binary_addr(addr), (char *)&ip_str, 64);

		if( family == AF_INET ) {
			struct nl_addr *brdcst = rtnl_addr_get_broadcast((struct rtnl_addr *)obj);
			char brdcst_str[66];

			SET_STR_VALUE(ethi->ipv4_address, ip_str);
			ethi->ipv4_netmask = rtnl_addr_get_prefixlen((struct rtnl_addr*) obj);

			if( brdcst ) {
				memset(&brdcst_str, 0, 66);
				inet_ntop(family, nl_addr_get_binary_addr(brdcst), (char *)&brdcst_str, 64);
				SET_STR_VALUE(ethi->ipv4_broadcast, brdcst_str);
			}
		} else {
			ethi->ipv6_addresses = etherinfo_add_ipv6(ethi->ipv6_addresses,
								  ip_str,
								  rtnl_addr_get_prefixlen((struct rtnl_addr*) obj),
								  rtnl_addr_get_scope((struct rtnl_addr*) obj));
		}
		return;
	default:
		return;
	}
}



/*
 *
 *   Exported functions - API frontend
 *
 */

/**
 * Dumps the contents of a struct etherinfo element to file
 *
 * @param fp   FILE pointer where to dump
 * @param ptr  Pointer to a struct etherinfo element
 */
void dump_etherinfo(FILE *fp, struct etherinfo *ptr)
{

	fprintf(fp, "*** Interface [%i] %s  ", ptr->index, ptr->device);
	if( ptr->hwaddress ) {
		fprintf(fp, "MAC address: %s", ptr->hwaddress);
	}
	fprintf(fp, "\n");
	if( ptr->ipv4_address ) {
		fprintf(fp, "\tIPv4 Address: %s/%i",
			ptr->ipv4_address, ptr->ipv4_netmask);
		if( ptr->ipv4_broadcast ) {
			fprintf(fp, "  -  Broadcast: %s", ptr->ipv4_broadcast);
		}
		fprintf(fp, "\n");
	}
	if( ptr->ipv6_addresses ) {
		struct ipv6address *ipv6 = ptr->ipv6_addresses;

		fprintf(fp, "\tIPv6 addresses:\n");
		for(; ipv6; ipv6 = ipv6->next) {
			char scope[66];

			rtnl_scope2str(ipv6->scope, scope, 64);
			fprintf(fp, "\t		       [%s] %s/%i\n",
				scope, ipv6->address, ipv6->netmask);
		}
	}
	fprintf(fp, "\n");
}


/**
 * Query NETLINK for ethernet configuration
 *
 * @param ethinf Pointer to an available struct etherinfo element.  The 'device' member
 *               must contain a valid string to the device to query for information
 * @param nlc    Pointer to the libnl handle, which is used for the query against NETLINK
 * @param query  What to query for.  Must be NLQRY_LINK or NLQRY_ADDR.
 *
 * @return Returns 1 on success, otherwise 0.
 */
int get_etherinfo(struct etherinfo_obj_data *data, nlQuery query)
{
	struct nl_cache *link_cache;
	struct nl_cache *addr_cache;
	struct rtnl_addr *addr;
	struct rtnl_link *link;
	struct etherinfo *ethinf = NULL;
	int ret = 0;

	if( !data || !data->ethinfo ) {
		return 0;
	}
	ethinf = data->ethinfo;

	/* Open a NETLINK connection on-the-fly */
	if( !open_netlink(data) ) {
		PyErr_Format(PyExc_RuntimeError,
			     "Could not open a NETLINK connection for %s",
			     ethinf->device);
		return 0;
	}

	/* Find the interface index we're looking up.
	 * As we don't expect it to change, we're reusing a "cached"
	 * interface index if we have that
	 */
	if( ethinf->index < 0 ) {
		link_cache = rtnl_link_alloc_cache(*data->nlc);
		ethinf->index = rtnl_link_name2i(link_cache, ethinf->device);
		if( ethinf->index < 0 ) {
			return 0;
		}
		nl_cache_free(link_cache);
	}

	/* Query the for requested info vai NETLINK */
	switch( query ) {
	case NLQRY_LINK:
		/* Extract MAC/hardware address of the interface */
		link_cache = rtnl_link_alloc_cache(*data->nlc);
		link = rtnl_link_alloc();
		rtnl_link_set_ifindex(link, ethinf->index);
		nl_cache_foreach_filter(link_cache, (struct nl_object *)link, callback_nl_link, ethinf);
		rtnl_link_put(link);
		nl_cache_free(link_cache);
		ret = 1;
		break;

	case NLQRY_ADDR:
		/* Extract IP address information */
		addr_cache = rtnl_addr_alloc_cache(*data->nlc);
		addr = rtnl_addr_alloc();
		rtnl_addr_set_ifindex(addr, ethinf->index);

                /* Make sure we don't have any old IPv6 addresses saved */
                if( ethinf->ipv6_addresses ) {
                        free_ipv6addresses(ethinf->ipv6_addresses);
                        ethinf->ipv6_addresses = NULL;
                }

                /* Retrieve all address information */
		nl_cache_foreach_filter(addr_cache, (struct nl_object *)addr, callback_nl_address, ethinf);
		rtnl_addr_put(addr);
		nl_cache_free(addr_cache);
		ret = 1;
		break;

	default:
		ret = 0;
	}
	return ret;
}


/**
 * Connects to the NETLINK interface.  This will be called
 * for each etherinfo object being generated, and it will
 * keep a separate file descriptor open for each object
 *
 * @param data etherinfo_obj_data structure
 *
 * @return Returns 1 on success, otherwise 0.
 */
int open_netlink(struct etherinfo_obj_data *data)
{
	if( !data ) {
		return 0;
	}

	/* Reuse already established NETLINK connection, if a connection exists */
	if( *data->nlc ) {
		/* If this object has not used NETLINK earlier, tag it as a user */
		if( !data->nlc_active ) {
			pthread_mutex_lock(&nlc_counter_mtx);
			(*data->nlc_users)++;
			pthread_mutex_unlock(&nlc_counter_mtx);
		}
		data->nlc_active = 1;
		return 1;
	}

	/* No earlier connections exists, establish a new one */
	*data->nlc = nl_handle_alloc();
	nl_connect(*data->nlc, NETLINK_ROUTE);
	if( (*data->nlc != NULL) ) {
		/* Force O_CLOEXEC flag on the NETLINK socket */
		if( fcntl(nl_socket_get_fd(*data->nlc), F_SETFD, FD_CLOEXEC) == -1 ) {
			fprintf(stderr,
				"**WARNING** Failed to set O_CLOEXEC on NETLINK socket: %s\n",
				strerror(errno));
		}

		/* Tag this object as an active user */
		pthread_mutex_lock(&nlc_counter_mtx);
		(*data->nlc_users)++;
		pthread_mutex_unlock(&nlc_counter_mtx);
		data->nlc_active = 1;
		return 1;
	} else {
		return 0;
	}
}


/**
 * Closes the NETLINK connection.  This should be called automatically whenever
 * the corresponding etherinfo object is deleted.
 *
 * @param ptr  Pointer to the pointer of struct nl_handle, which contains the NETLINK connection
 */
void close_netlink(struct etherinfo_obj_data *data)
{
	if( !data || !(*data->nlc) ) {
		return;
	}

	/* Untag this object as a NETLINK user */
	data->nlc_active = 0;
	pthread_mutex_lock(&nlc_counter_mtx);
	(*data->nlc_users)--;
	pthread_mutex_unlock(&nlc_counter_mtx);

	/* Don't close the connection if there are more users */
	if( *data->nlc_users > 0) {
		return;
	}

	/* Close NETLINK connection */
	nl_close(*data->nlc);
	nl_handle_destroy(*data->nlc);
	*data->nlc = NULL;
}
