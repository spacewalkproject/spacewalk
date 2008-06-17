#!/usr/bin/python
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
# This module contains all the logic necessary to manipulate the clients' RPM
# transactions
#

# XXX This file is no longer used

import time

from common import log_debug
from server import rhnSQL

def add_transactions(server, timestamp, transaction_hash):
    server_id = server.server['id']
    log_debug(3, server_id, timestamp)

    arches = {}
    names = {}
    evrs = {}
    ops = {'insert' : 'added', 'delete' : 'removed'}
    packages = {}
    transactions = {}
    for t, dict in transaction_hash.items():
        trans_id = dict['tid']
        trans_elements = {}
        for db_op, op in ops.items():
            for p in dict[op]:
                name, version, release, epoch, arch = p[:5]
                # Stringify
                name = str(name)
                version = str(version)
                release = str(release)
                arch = str(arch)
                if epoch is None:
                    epoch = ''
                else:
                    epoch = str(epoch)
                # Populate the hashes
                names[name] = None
                evrs[(epoch, version, release)] = None
                arches[arch] = None
                # And the big one now
                key = (name, (epoch, version, release), arch, db_op)
                packages[key] = None
                trans_elements[key] = None
        transactions[trans_id] = (t, trans_elements)
    # We now have all the stuff we need; proceed with looking up the values
    # from the hashes
    lookup_operations(ops)
    lookup_names(names)
    lookup_evrs(evrs)
    lookup_arches(arches)
    # Now look up packages and return what has to be added
    # The side-effect is to also populate the packages hash with IDs
    packages_to_add = lookup_packages(packages, names, evrs, arches, ops)
    # Now add the packages
    add_packages(packages_to_add)
    del packages_to_add

    # We now have the packages in the database, and we have the ids too

    # Get the transactions we currently store for this server
    db_trans = current_db_transactions(server_id)

    transactions_seq = rhnSQL.Sequence('rhn_transaction_id_seq')

    added_transactions = []
    updated_transactions = []
    deleted_transactions = []
    inserted_elements = []
    deleted_elements = []

    # Iterate over the transactions
    for trans_id, (timestamp, trans_elements) in transactions.items():
        timestamp = timestamp2dbtime(timestamp)
        if db_trans.has_key(trans_id):
            # present both in the database and in the incoming transaction

            # Verify the timestamp
            db_id, db_timestamp, db_trans_elements = db_trans[trans_id]
            if (timestamp != db_timestamp):
                # Update the transaction timestamp
                updated_transactions.append((db_id, timestamp))
            
            # Verify the transaction elements as well
            for package in trans_elements.keys():
                # Find the package id
                package_id = packages[package]
                if db_trans_elements.has_key(package_id):
                    # We already have it
                    del db_trans_elements[package_id]
                    continue
                # We have to insert it
                inserted_elements.append((db_id, package_id))

            # Whatever else left in the DB hash has to be deleted
            for package_id in db_trans_elements.keys():
                deleted_elements.append((db_id, package_id))

            # Delete this transaction ID from the DB hash
            # (everything left in db_trans at the end of the for loop will be
            # deleted)
            del db_trans[trans_id]
            continue

        # The DB does not have this transaction ID, we have to add it
        db_id = transactions_seq.next()
        added_transactions.append((db_id, server_id, timestamp, trans_id))
        # Also add the transaction elements
        for package in trans_elements.keys():
            # Find the package id
            package_id = packages[package]
            inserted_elements.append((db_id, package_id))
            

    # Delete everything else that's left in the database
    for trans_id, (db_id, db_timestamp, db_trans_elements) in db_trans.items():
        for package_id in db_trans_elements.keys():
            deleted_elements.append((db_id, package_id))
        deleted_transactions.append(db_id)

    log_debug(5, "Added transactions", added_transactions)
    log_debug(5, "Updated transactions", updated_transactions)
    log_debug(5, "Deleted transactions", deleted_transactions)
    log_debug(5, "Inserted elements", inserted_elements)
    log_debug(5, "Deleted elements", deleted_elements)

    # Do the database operations now
    delete_elements(deleted_elements)
    delete_transactions(deleted_transactions)
    insert_transactions(added_transactions)
    update_transactions(updated_transactions)
    insert_elements(inserted_elements)

    # And commit
    rhnSQL.commit()

# Helper functions

### Lookup
def lookup_arches(arch_hash):
    arch_table = rhnSQL.Table('rhnPackageArch', 'label', local_cache=1)
    for k in arch_hash.keys():
        row = arch_table[k]
        if not row:
            raise Exception("Unsupported architecture", k)
        arch_hash[k] = row['id']

def lookup_names(names_hash):
    h = rhnSQL.prepare("select LOOKUP_PACKAGE_NAME(:name) id from dual")
    for k in names_hash.keys():
        h.execute(name=k)
        row = h.fetchone_dict()
        # row should always be non-null
        names_hash[k] = row['id']

def lookup_evrs(evrs_hash):
    h = rhnSQL.prepare("select LOOKUP_EVR(:epoch, :version, :release) id from dual")
    for epoch, version, release in evrs_hash.keys():
        h.execute(epoch=epoch, version=version, release=release)
        row = h.fetchone_dict()
        # row should always be non-null
        evrs_hash[(epoch, version, release)] = row['id']

def lookup_operations(ops_hash):
    ops_table = rhnSQL.Table("rhnTransactionOperation", "label")
    for k in ops_hash.keys():
        row = ops_table[k]
        if not row:
            raise Exception("Unsupported operation", k)
        ops_hash[k] = row['id']

# Looks up packages in rhnTransactionPackage
def lookup_packages(packages_hash, names_hash, evrs_hash, arches_hash, ops_hash):
    h = rhnSQL.prepare("""
        select id
        from rhnTransactionPackage
        where operation = :operation
        and name_id = :name_id
        and evr_id = :evr_id
        and package_arch_id = :package_arch_id
    """)
    to_add = []
    seq = rhnSQL.Sequence('rhn_transpack_id_seq')
    for name, evr, arch, op in packages_hash.keys():
        # Convert from string to ID
        name_id = names_hash[name]
        evr_id = evrs_hash[evr]
        package_arch_id = arches_hash[arch]
        operation = ops_hash[op]
        # Now look it up
        h.execute(name_id = name_id, evr_id = evr_id, 
            package_arch_id = package_arch_id, operation = operation)
        row = h.fetchone_dict()
        if row:
            # We already have it in the DB
            packages_hash[(name, evr, arch, op)] = row['id']
            continue
        # No row in the DB, we have to add it
        package_id = seq.next()
        packages_hash[(name, evr, arch, op)] = package_id;
        to_add.append((package_id, operation, name_id, evr_id, package_arch_id))
    return to_add

# Return the current transactions for this server id
def current_db_transactions(server_id):
    h = rhnSQL.prepare("""
        select t.id transaction_id, te.transaction_package_id, 
            t.rpm_trans_id, 
            TO_CHAR(t.timestamp, 'YYYY-MM-DD HH24:MI:SS') timestamp
        from rhnTransaction t, rhnTransactionElement te
        where t.server_id = :server_id
        and t.id = te.transaction_id (+)
    """)
    h.execute(server_id=server_id)
    dict = {}
    for row in h.fetchall_dict() or []:
        rpm_trans_id = row['rpm_trans_id']
        if not dict.has_key(rpm_trans_id):
            dict[rpm_trans_id] = [row['transaction_id'], row['timestamp'], {}]
        transaction_package_id = row['transaction_package_id']
        if transaction_package_id:
            dict[rpm_trans_id][2][transaction_package_id] = None
    return dict

# DML operations on the tables we're interested in
def add_packages(arr):
    if not arr:
        # Nothing to do
        return 0
    # Convert from row-based to column-based, to allow the bulk insert to do
    # its magic
    fields = ['id', 'operation', 'name_id', 'evr_id', 'package_arch_id']
    dict = transpose_array(arr, fields)
    
    h = rhnSQL.prepare("""
        insert into rhnTransactionPackage 
        (id, operation, name_id, evr_id, package_arch_id)
        values (:id, :operation, :name_id, :evr_id, :package_arch_id)""")
    return apply(h.executemany, (), dict)

def insert_transactions(arr):
    if not arr:
        # Nothing to do
        return 0
    h = rhnSQL.prepare("""
        insert into rhnTransaction (id, server_id, timestamp, rpm_trans_id)
        values (:id, :server_id, TO_DATE(:timestamp, 'YYYY-MM-DD HH24:MI:SS'),
            :rpm_trans_id)
    """)
    fields = ['id', 'server_id', 'timestamp', 'rpm_trans_id']
    dict = transpose_array(arr, fields)
    return apply(h.executemany, (), dict)

def delete_transactions(arr):
    if not arr:
        # Nothing to do
        return 0
    h = rhnSQL.prepare("""
        delete from rhnTransaction where id = :id
    """)
    return h.executemany(id=arr)

def update_transactions(arr):
    if not arr:
        # Nothing to do
        return 0
    h = rhnSQL.prepare("""
        update rhnTransaction 
        set timestamp = TO_DATE(:timestamp, 'YYYY-MM-DD HH24:MI:SS')
        where id = :id""")
    fields = ["id", "timestamp"]
    dict = transpose_array(arr, fields)
    return apply(h.executemany, (), dict)

def insert_elements(arr):
    if not arr:
        # Nothing to do
        return 0
    h = rhnSQL.prepare("""
        insert into rhnTransactionElement 
        (transaction_id, transaction_package_id)
        values (:transaction_id, :transaction_package_id)
    """)
    dict = transpose_array(arr, ["transaction_id", "transaction_package_id"])
    return apply(h.executemany, (), dict)

def delete_elements(arr):
    if not arr:
        # Nothing to do
        return 0
    h = rhnSQL.prepare("""
        delete from rhnTransactionElement 
        where transaction_id = :transaction_id
        and transaction_package_id = :transaction_package_id
    """)
    dict = transpose_array(arr, ["transaction_id", "transaction_package_id"])
    return apply(h.executemany, (), dict)

# Misc functions

# Transposes an array and returns a dictionary, keyed on the column (field)
# names
def transpose_array(arr, fields):
    dict = {}
    for f in fields:
        dict[f] = []
    for p in arr:
        for i in range(len(p)):
            field_name = fields[i]
            dict[field_name].append(p[i])
    return dict

# Returns the timestamp in a format the database can unserstand
def timestamp2dbtime(timestamp):
    timestamp = int(timestamp)
    return time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(timestamp))
