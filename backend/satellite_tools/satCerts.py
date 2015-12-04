#
# Cert-related functions
#   - RHN certificate
#   - SSL CA certificate
#
# Copyright (c) 2008--2015 Red Hat, Inc.
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

# language imports
import sys

# other rhn imports
from spacewalk.server import rhnSQL
from spacewalk.common.rhnTB import fetchTraceback

def get_all_orgs():
    """ Fetch org_id. Create first org_id if needed.
        owner only needed if no org_id present
        NOTE: this is duplicated elsewhere (backend.py)
              but I need the error differientiation of (1) too many orgs
              and (2) no orgs. backend.py does not differientiate.
    """

    # Get the org id
    h = rhnSQL.prepare(_queryLookupOrgId)
    h.execute()
    rows = h.fetchall_dict()
    return rows or []


_queryLookupOrgId = rhnSQL.Statement("""
    SELECT id
      FROM web_customer
""")

#
# SSL CA certificate section
#


class CaCertInsertionError(Exception):
    pass


def _checkCertMatch_rhnCryptoKey(caCert, description, org_id, deleteRowYN=0,
                                 verbosity=0):
    """ is there an CA SSL certificate already in the database?
        If yes:
            return ID:
              -1, then no cert in DB
              None if they are identical (i.e., nothing to do)
              0...N if cert is in database

        if found, optionally deletes the row and returns -1
        Used ONLY by: store_rhnCryptoKey(...)
    """

    cert = open(caCert, 'rb').read().strip()

    if org_id:
        h = rhnSQL.prepare(_querySelectCryptoCertInfo)
        h.execute(description=description, org_id=org_id)
    else:
        h = rhnSQL.prepare(_querySelectCryptoCertInfoNullOrg)
        h.execute(description=description)

    row = h.fetchone_dict()
    rhn_cryptokey_id = -1
    if row:
        if cert == rhnSQL.read_lob(row['key']):
            # match found, nothing to do
            if verbosity:
                print "Nothing to do: certificate to be pushed matches certificate in database."
            return
        # there can only be one (bugzilla: 120297)
        rhn_cryptokey_id = int(row['id'])
        # print 'found existing certificate - id:', rhn_cryptokey_id
        # NUKE IT!
        if deleteRowYN:
            # print 'found a cert, nuking it! id:', rhn_cryptokey_id
            h = rhnSQL.prepare('delete from rhnCryptoKey where id=:rhn_cryptokey_id')
            h.execute(rhn_cryptokey_id=rhn_cryptokey_id)
            # rhnSQL.commit()
            rhn_cryptokey_id = -1
    return rhn_cryptokey_id


def _insertPrep_rhnCryptoKey(rhn_cryptokey_id, description, org_id):
    """ inserts a row given that a cert is not already in the database
        lob rewrite occurs later during update.
        Used ONLY by: store_rhnCryptoKey(...)
    """

    # NOTE: due to a uniqueness constraint on description
    #       we can't increment and reinsert a row, so we only
    #       do so if the row does not exist.
    #       bugzilla: 120297 - and no I don't like it.
    rhn_cryptokey_id_seq = rhnSQL.Sequence('rhn_cryptokey_id_seq')
    rhn_cryptokey_id = rhn_cryptokey_id_seq.next()
    # print 'no cert found, new one with id:', rhn_cryptokey_id
    h = rhnSQL.prepare(_queryInsertCryptoCertInfo)
    # ...insert
    h.execute(rhn_cryptokey_id=rhn_cryptokey_id,
              description=description, org_id=org_id)
    return rhn_cryptokey_id


def _lobUpdate_rhnCryptoKey(rhn_cryptokey_id, caCert):
    """ writes/updates the cert as a lob """

    cert = open(caCert, 'rb').read().strip()

    # Use our update blob wrapper to accomodate differences between Oracle
    # and PostgreSQL:
    h = rhnSQL.cursor()
    try:
        h.update_blob("rhnCryptoKey", "key", "WHERE id = :rhn_cryptokey_id",
                      cert, rhn_cryptokey_id=rhn_cryptokey_id)
    except:
        # didn't go in!
        raise CaCertInsertionError("ERROR: CA certificate failed to be "
                                   "inserted into the database"), None, sys.exc_info()[2]


def store_rhnCryptoKey(description, caCert, verbosity=0):
    """ stores CA cert in rhnCryptoKey
        uses:
            _checkCertMatch_rhnCryptoKey
            _delete_rhnCryptoKey - not currently used
            _insertPrep_rhnCryptoKey
            _lobUpdate_rhnCryptoKey
    """

    org_ids = get_all_orgs()
    org_ids.append({'id': None})
    for org_id in org_ids:
        org_id = org_id['id']
        try:
            # look for a cert match in the database
            rhn_cryptokey_id = _checkCertMatch_rhnCryptoKey(caCert, description,
                                                            org_id, deleteRowYN=1,
                                                            verbosity=verbosity)
            if rhn_cryptokey_id is None:
                # nothing to do - cert matches
                continue
            # insert into the database
            if rhn_cryptokey_id == -1:
                rhn_cryptokey_id = _insertPrep_rhnCryptoKey(rhn_cryptokey_id,
                                                            description, org_id)
            # write/update
            _lobUpdate_rhnCryptoKey(rhn_cryptokey_id, caCert)
            rhnSQL.commit()
        except rhnSQL.sql_base.SQLError:
            raise CaCertInsertionError(
                "...the traceback: %s" % fetchTraceback()), None, sys.exc_info()[2]


_querySelectCryptoCertInfo = rhnSQL.Statement("""
    SELECT ck.id, ck.description, ckt.label as type_label, ck.key
      FROM rhnCryptoKeyType ckt,
           rhnCryptoKey ck
     WHERE ckt.label = 'SSL'
       AND ckt.id = ck.crypto_key_type_id
       AND ck.description = :description
       AND ck.org_id = :org_id
""")

_querySelectCryptoCertInfoNullOrg = rhnSQL.Statement("""
    SELECT ck.id, ck.description, ckt.label as type_label, ck.key
      FROM rhnCryptoKeyType ckt,
           rhnCryptoKey ck
     WHERE ckt.label = 'SSL'
       AND ckt.id = ck.crypto_key_type_id
       AND ck.description = :description
       AND ck.org_id is NULL
""")

_queryInsertCryptoCertInfo = rhnSQL.Statement("""
    INSERT into rhnCryptoKey
           (id, org_id, description, crypto_key_type_id, key)
    SELECT :rhn_cryptokey_id, :org_id, :description, ckt.id, empty_blob()
      FROM rhnCryptoKeyType ckt
     WHERE ckt.label = 'SSL'
""")

def _test_store_rhnCryptoKey(caCert):
    description = 'RHN-ORG-TRUSTED-SSL-CERT'
    store_rhnCryptoKey(description, caCert)

if __name__ == '__main__':
    rhnSQL.initDB()

    _test_store_rhnCryptoKey('ca.crt')

    # NOTE!!! This has be seg-faulting on exit, specifically upon closeDB()
    #         Bugzilla: 127324

    print "end of __main__"
    rhnSQL.closeDB()
    print "we have closed the database"
