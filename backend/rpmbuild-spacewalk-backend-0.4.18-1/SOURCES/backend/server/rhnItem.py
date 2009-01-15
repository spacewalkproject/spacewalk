#
# Copyright (c) 2008 Red Hat, Inc.
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
# 

import string

from common import rhnFault
import rhnSQL

# The main class for representing an RHN Item, or sku.
class rhnItem:
    def __init__(self, name):

        # corrosponds to rh_product.item_code
        self.name = string.upper(name)

        # These vars represent the columns on the mapping tables in the db.
        self.channel_families = {}
        self.roles = {}
        self.services = {}
        self.paid = 'P'

    # TODO: Can we refactor the 3 add_* functions into a single function?
    ## 
    # Adds a service to an Item.
    # A service is either:
    #   provisioning_entitled
    #   enterprise_entitled
    #   sw_mgr_entitled
    #   monitoring_entitled
    #   nonlinux_entitled
    def add_service(self, name, quantity):

        if quantity != '' and quantity != None:
            quantity = int(quantity)

        # If the item already has a service of this name, issue a warning.
        # TODO: throw an exception based on a passed in option instead.
        if self.services.has_key(name):
            print "Warning: %s has more than one entry for service %s. " % (
                self.name, name ),
            if quantity == '':
                print "Setting to null."
            else:
                print "Setting to %s." % (quantity,)
                
        # Add the service to our member dict
        self.services[name] = quantity

        # if verbose >= 3:
            # print "  adding %s %s services to %s" % (
                # quantity, name, self.name)

    ## 
    # Similiar to add_service, except this is for user group types
    def add_role(self, name, quantity):
        if quantity != '' and quantity != None:
            quantity = int(quantity)

        if self.roles.has_key(name):
            print "Warning: %s has more than one entry for role %s. " % (
                self.name, name ),
            if quantity == '':
                print "Setting to null."
            else:
                print "Setting to %s." % (quantity,)

        self.roles[name] = quantity

        # if verbose >= 3:
            # print "  adding %s %s roles to %s" % (
                # quantity, name, self.name)

    ## 
    # Similiar to add_service, except this is for channel families.
    def add_channel_family(self, name, quantity):
        if quantity != '':
            quantity = int(quantity)

        if self.channel_families.has_key(name):
            print "Warning: %s has more than one entry for family %s. " % (
                self.name, name ),
            if quantity == '':
                print "Setting to null."
            else:
                print "Setting to %s." % (quantity,)

        self.channel_families[name] = quantity

        # if verbose >= 3:
            # print "  adding %s %s channel families to %s" % (
                # quantity, name, self.name)

    # TODO: refactor these into a single function.
    ## 
    # These next three functions display the entitlements
    # for the item.
    def __show_channel_family(self, name, label, quantity, paid):
        return "1,\"%s\",\"%s\",,,%s,\"%s\"\n" % (name, label, quantity, paid)

    def __show_service(self, name, label, quantity, paid):
        return "1,\"%s\",,\"%s\",,%s,\"%s\"\n" % (name, label, quantity, paid)

    def __show_role(self, name, label, quantity, paid):
        return "1,\"%s\",,,\"%s\",%s,\"%s\"\n" % (name, label, quantity, paid)

    ##
    # Formats the output of an item's entitlements all pretty.
    def show(self, item):

        results = ''

        # Cycle through each of the types of entitlements, and append the
        # output to results.
        for label in item.channel_families.keys():
            results = results + item.__show_channel_family(
                item.name, label, item.channel_families[label], item.paid )
        for label in item.services.keys():
            results = results + item.__show_service(
                item.name, label, item.services[label], item.paid )
        for label in item.roles.keys():
            results = results + item.__show_role(
                item.name, label, item.roles[label], item.paid )

        return results

    def diff(self, other):
        results = ''
        families = {}
        for label in [] + self.channel_families.keys() \
                + other.channel_families.keys():
            families[label] = 1

        for label in families.keys():
            if not self.channel_families.has_key(label):
                self.channel_families[label] = None
                
            if not other.channel_families.has_key(label):
                other.channel_families[label] = None

            different = 0
            if self.paid != other.paid:
                different = 1
            if self.channel_families[label] != other.channel_families[label]:
                different = 1

            if different:
                if not self.channel_families[label] is None:
                    results = results + "-%s" % (self.__show_channel_family(
                        self.name, label, self.channel_families[label],
                        self.paid ),)
                if not other.channel_families[label] is None:
                    results = results + "+%s" % (self.__show_channel_family(
                        other.name, label, other.channel_families[label],
                        other.paid ),)
            else:
                results = results + " %s" % (self.__show_channel_family(
                        self.name, label, self.channel_families[label],
                        self.paid ),)

        services = {}
        for label in [] + self.services.keys() + other.services.keys():
            services[label] = 1

        for label in services.keys():
            if not self.services.has_key(label):
                self.services[label] = None
                
            if not other.services.has_key(label):
                other.services[label] = None

            different = 0
            if self.paid != other.paid:
                different = 1
            if self.services[label] != other.services[label]:
                different = 1

            if different:
                if not self.services[label] is None:
                    results = results + "-%s" % (self.__show_service(
                        self.name, label, self.services[label], self.paid),)
                if not other.services[label] is None:
                    results = results + "+%s" % (self.__show_service(
                        other.name, label, other.services[label], other.paid),)
            else:
                results = results + " %s" % (self.__show_service(
                        self.name, label, self.services[label], self.paid),)

        roles = {}
        for label in [] + self.roles.keys() + other.roles.keys():
            roles[label] = 1

        for label in roles.keys():
            if not self.roles.has_key(label):
                self.roles[label] = None
                
            if not other.roles.has_key(label):
                other.roles[label] = None

            different = 0
            if self.paid != other.paid:
                different = 1
            if self.roles[label] != other.roles[label]:
                different = 1

            if different:
                if not self.roles[label] is None:
                    results = results + "-%s" % (self.__show_role(
                        self.name, label, self.roles[label], self.paid ),)
                if not other.roles[label] is None:
                    results = results + "+%s" % (self.__show_role(
                        other.name, label, other.roles[label], other.paid ),)
            else:
                results = results + " %s" % (self.__show_role(
                    self.name, label, self.roles[label], self.paid ),)

        return results


def get_item_from_db(sku = None):
    retlist = []

    h = None
    args = {}
    q = """\
        select  * from (
        select  rp.item_code item_code, 'S' type,
                sgt.label label, ssgm.quantity quantity,
                ssgm.paid paid
        from    rh_product rp, rhnServerGroupType sgt,
                rhnServiceServerGroupMap ssgm
        where   ssgm.product_id = rp.product_id
            and ssgm.group_type = sgt.id
        union all
        select  rp.item_code, 'R', ugt.label, sugm.quantity, sugm.paid
        from    rh_product rp, rhnUserGroupType ugt,
                rhnServiceUserGroupMap sugm
        where   sugm.product_id = rp.product_id
            and sugm.group_type = ugt.id
        union all
        select  rp.item_code, 'C', cf.label, scfm.quantity, ''
        from    rh_product rp, rhnChannelFamily cf,
                rhnServiceChannelFamilyMap scfm
        where   scfm.product_id = rp.product_id
            and scfm.family_id = cf.id
        )
        """
    if sku:
        q = q + " where item_code = :sku"
        args['sku'] = sku
    q = q + " order by item_code, type"

    h = rhnSQL.prepare(q)
    apply(h.execute, (), args)
    last_item_code = None
    item = None

    for row in h.fetchall_dict() or []:
        if row['item_code'] != last_item_code:
            if item and last_item_code:
                retlist.append(item)
            last_item_code = row['item_code']
            item = rhnItem(row['item_code'])
        if row['paid']:
            item.paid = row['paid']
        if row['quantity'] and (not row['quantity'] == ''):
            row['quantity'] = int(row['quantity'])
        if row['type'] == 'S':
            item.add_service(row['label'], row['quantity'])
        if row['type'] == 'R':
            item.add_role(row['label'], row['quantity'])
        if row['type'] == 'C':
            item.add_channel_family(row['label'], row['quantity'])
    if item:
        retlist.append(item)
    return retlist

##
# Creates a dictionary object called items that represents the input
# we are passed in, which is a csv from the client.
#
# The keys of items is the SKU, the values are rhnItems objects.
#
def create_from_lines(lines):

    items = {}

    for line in lines:
        if not line['SKU']:
            continue
        sku = string.upper(line['SKU'])
        del line['SKU']
        if not items.has_key(sku):
            items[sku] = rhnItem(sku)
        item = items[sku]
        
        if line['paid?']:
            item.paid = line['paid?']
        if line['channel']:
            item.add_channel_family(line['channel'], line['qty'])
        if line['service']:
            item.add_service(line['service'], line['qty'])
        if line['role']:
            item.add_role(line['role'], line['qty'])

        # do we really need this?
        items[sku] = item

    return items

def map_item_entitlements(item):

    # Clear all the old mappings for item
    sqlCall("rhn_ep.clear_item_mappings")(item.name)

    ##
    # For each of roles, services, and channel families, cycle through
    # each and call the appropriate stored procedure to update the mappings
    # for the item
    #
    for role in item.roles.keys():
        try:
            sqlCall("rhn_ep.item_add_usergroup")( item.name, role, 
                    item.roles[role], item.paid )
        except rhnSQL.sql_base.SQLSchemaError, e:
            if e[0] == 20248:
                raise rhnFault(5001, "Invalid item code '%s'" % item.name)
            elif e[0] == 20264:
                raise rhnFault(5002, "Invalid user role '%s'" % role + \
                               "while processing '%s'" % item.name)
            else:
                raise

    for service in item.services.keys():
        try:
            sqlCall("rhn_ep.item_add_servergroup")( item.name, service,
                     item.services[service], item.paid )
        except rhnSQL.sql_base.SQLSchemaError, e:
            if e[0] == 20248:
                raise rhnFault(5001, "Invalid item code '%s'" % item.name)
            elif e[0] == 20249:
                raise rhnFault(5003, "Invalid server group '%s' " % service + \
                               "while processing '%s'" % item.name)
            else:
                raise

    for family in item.channel_families.keys():
        try:
            sqlCall("rhn_ep.item_add_channel_family")( item.name, family,
                    item.channel_families[family] )
        except rhnSQL.sql_base.SQLSchemaError, e:
            if e[0] == 20248:
                raise rhnFault(5001, "Invalid item code '%s'" % item.name)
            elif e[0] == 20250:
                raise rhnFault(5004, "Invalid channel family '%s' " % family + \
                               "while processing '%s'" % item.name)
            else:
                raise

    return 
    
    
##
# Wrapper for rhn_ep.count_repoll_orgs.
# Returns the number of orgs affected by a repoll of item
#
def count_orgs_affected(item):

    count_orgs = sqlCall("rhn_ep.count_repoll_orgs", rhnSQL.types.STRING())
    count = count_orgs(item)

    return count

##
# Wrapper around rhn_ep.entitlement_queue_pending
# Returns the number of orgs in the entitlement queue
#
def queue_pending():

    pending = sqlCall("rhn_ep.entitlement_queue_pending", 
                      rhnSQL.types.STRING())

    return pending()

##
# Wrapper around rhn_ep.schedule_product_repoll
# Enqueues all orgs into the entitlement queue that are affected by
# a repoll of item
#
def queue_item(item):

    queue = sqlCall("rhn_ep.schedule_product_repoll")
    queue(item)

    return

##
# A wrapper class for making a sql func/proc call.
# TODO: Is this needed?
#
# No it ain/t. get rid of it
class sqlCall:
    def __init__(self, name, type=None):
        self.name = name
        self.type = type

        if self.type is None:
            self.proc = rhnSQL.Procedure(name)
        else:
            self.proc = rhnSQL.Function(name, type)

    def __call__(self, *args):
        return apply(self.proc, args, {})
