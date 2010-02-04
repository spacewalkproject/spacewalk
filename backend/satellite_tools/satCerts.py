#!/usr/bin/python
#
# Cert-related functions
#   - RHN certificate
#   - SSL CA certificate
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

## language imports
from string import strip
from time import strftime, strptime
import os

## other rhn imports
from server import rhnSQL
from server.rhnServer import satellite_cert
from common.rhnTB import fetchTraceback
from common.rhnConfig import RHNOptions

#
# RHN certificate section
#

class NoOrgIdError(Exception):
    "missing org id error"

class CertGenerationMismatchError(Exception):
    "the certificate that is stored in the db is a different generation"

class CertVersionMismatchError(Exception):
    def __init__(self, old_version, new_version):
        self.message = "the versions of current and new certificate do not match, [%s] vs. [%s]" % (old_version, new_version)
    def __str__(self):
          return self.message

class NoFreeEntitlementsError(Exception):
    def __init__(self, label, quantity):
          self.label = label
          self.quantity = quantity
          self.message = \
          "Error: You do not have enough unused %s entitlements in the base org. You will need at least %s free entitlements, based on your current consumption. Please un-entitle the remaining systems for the activation to proceed." % (self.label, self.quantity)
          self.args = [self.message]

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
    if not rows:
        raise NoOrgIdError("Unable to look up org_id")
    return rows


_queryLookupOrgId = rhnSQL.Statement("""
    SELECT id
      FROM web_customer
""")

def get_org_id():
    """
     Fetch base org id
    """
    rows = get_all_orgs()
    return rows[0]['id']

def create_first_org(owner):
    """ create first org_id if needed
        Always returns the org_id
        Will not commit
    """

    try:
        return get_org_id()
    except NoOrgIdError:
        # gotta create one first org then
        p = rhnSQL.Procedure("create_first_org")
        # copying logic from validate-sat-cert.pl
        # I.e., setting their org_id password to the pid cubed.
        #       That password is not used by anything.
        pword = str(long(os.getpid())**3)
        # do it!
        p(owner, pword)
        # Now create the first private channel family
        create_first_private_chan_family()
        verify_family_permissions()
    return get_org_id()

_query_get_slot_types = rhnSQL.Statement("""
    select sg.group_type slot_type_id, sgt.label slot_name
      from rhnServerGroup sg,
           rhnServerGroupType sgt
     where sg.org_id = :org_id
       and sg.group_type = sgt.id
""")

_query_get_allorg_slot_types = rhnSQL.Statement("""
    select sg.org_id,sg.group_type as slot_type_id, 
           sgt.label as slot_name, sg.max_members, sg.current_members
      from rhnServerGroup sg,
           rhnServerGroupType sgt
     where sg.group_type = sgt.id
""")


def set_slots_from_cert(cert):
    """ populates database with entitlements from an RHN certificate
        "cert" is a satellite_cert.SatelliteCert() object
        NOTE: should only be called by storeRhnCert()
    """

    org_id = get_org_id()
    activate_system_entitlement = rhnSQL.Procedure(
                                "rhn_entitlements.activate_system_entitlement")
    org_service_proc = rhnSQL.Procedure("rhn_entitlements.modify_org_service")
    slot_table = rhnSQL.Table("rhnServerGroupType", "label")
    # Fetch all available entitlements; the ones that are not present in the
    # cert will have to be set to zero
    h = rhnSQL.prepare(_query_get_allorg_slot_types)
    h.execute()
    row = h.fetchall_dict()
    
    sys_ent_counts = {}
    extra_slots = {}
    curr_sys_ent_counts = {}
    for entry in row:
        ent_label = entry['slot_name']
        orgid = entry['org_id']

        sys_ent_counts[(ent_label, orgid)] = entry['max_members']
        curr_sys_ent_counts[(ent_label, orgid)] = entry['current_members']
        extra_slots[entry['slot_type_id']] = ent_label

    sys_ent_total_max = {}
    for (ent_name, org_id_in), max_members in sys_ent_counts.items():
        # compute total max_member could in db
        if not sys_ent_total_max.has_key(ent_name):
            sys_ent_total_max[ent_name] = max_members
        else:
            sys_ent_total_max[ent_name] += max_members
        

    for slot_type in cert.get_slot_types():
        slots = cert.get_slots(slot_type)

        db_label = slots.get_db_label()

        quantity = slots.get_quantity()

        # Do not pass along a NULL quantity - NULL for
        # rhnServerGroup.max_members means 'no maximum' BZ #160046

        if not quantity:
            quantity = 0

        slot_type_id = None
        if slot_table.has_key(db_label):
            slot_type_id = slot_table[db_label]['id']

        # Take it out of extra_slots
        if slot_type_id and extra_slots.has_key(slot_type_id):
            del extra_slots[slot_type_id]

        if sys_ent_total_max.has_key(db_label) and \
             sys_ent_total_max[db_label] is not None:
	     # Do the math only if the slot already exists
             if sys_ent_total_max[db_label] > int(quantity):
	         # If cert count is lower than existing db slot
                 purge_count = sys_ent_total_max[db_label] - int(quantity)
                 quantity = sys_ent_counts[(db_label, 1)] - purge_count
                  
             else:
	         # If cert is higher take the extra count and add to max
                 quantity = sys_ent_counts[(db_label, 1)] + \
                            (int(quantity) - sys_ent_total_max[db_label])

        try:
            # Set the counts now
            activate_system_entitlement(org_id, db_label, quantity)
        except rhnSQL.sql_base.SQLSchemaError, e:
            if e[0] == 20290:
                free_count = sys_ent_counts[(db_label, 1)] - quantity
                raise NoFreeEntitlementsError(db_label, free_count)
            else:
                raise

        # Now set the customer type
        if quantity:
            org_service_proc(org_id, slots.get_slot_name(), 'Y')
        else:
            # This shouldn't happen - a cert with zero slots. But adding it
            # just in case...
            org_service_proc(org_id, slots.get_slot_name(), 'N')

    # For any other type of slot, set quantity to zero
    for slot_type_id, db_label in extra_slots.items():
        slot_name = cert.lookup_slot_by_db_label(db_label)
        activate_system_entitlement(org_id, db_label, 0)
        org_service_proc(org_id, slot_name, 'N')

    # NOTE: must rhnSQL.commit() in calling function.

def storeRhnCert(cert, check_generation=0, check_version=0):
    """ Pushes an RHN cert into the database, in rhnSatelliteCert
        "cert" is the raw RHN Certificate as a string.
    """

    label = 'rhn-satellite-cert'
    cert = strip(cert)

    # sanity check
    # satellite_cert.ParseException can be thrown
    sc = satellite_cert.SatelliteCert()
    sc.load(cert)

    # gotta make sure there is a first org_id
    create_first_org(owner=sc.owner)

    # dates: formatted for DB
    expires = strftime(sc.datesFormat_db,
                       strptime(sc.expires, sc.datesFormat_cert))
    issued = strftime(sc.datesFormat_db,
                      strptime(sc.issued, sc.datesFormat_cert))

    version = 0
    certAlreadyUploadedYN = 0

    # First, find out the right next version for this cert
    row = retrieve_db_cert()
    if row:
        db_cert = row['cert']
        db_issued = row['issued']
        db_expires = row['expires']
        version = row['version']
        if db_cert == cert and issued == db_issued and expires == db_expires:
            # cert is already uploaded and the expiration dates match
            certAlreadyUploadedYN = 1
        else:
            # cert is not uploaded *or* the expirations are out of whack
            version = version + 1

            if check_generation or check_version:
                # Load the stored cert
                stored_sc = satellite_cert.SatelliteCert()
                stored_sc.load(db_cert)
                if check_generation and stored_sc.generation != sc.generation:
                    raise CertGenerationMismatchError()

                if check_version:
                    old_version = getattr(stored_sc, 'satellite-version')
                    new_version = getattr(sc, 'satellite-version')
                    if old_version != new_version:
                        raise CertVersionMismatchError(old_version, new_version)

    if not certAlreadyUploadedYN:
        # bug 145491 update the cunstomer's name (should be harmless)
        wc_up = rhnSQL.prepare(_query_update_web_customer)
        wc_up.execute(owner=sc.owner)

        wu_up = rhnSQL.prepare(_query_update_web_user)
        wu_up.execute(owner=sc.owner)

        # XXX bug 145491, there may be further work here for rhnchannelfamily, 
        # but only if it actually affects rhn's behaviour (because it's a real 
        # bitch to fix because the channel family's name column is *based* on 
        # the certificate owner

        h = rhnSQL.prepare(_query_insert_cert)
        h.execute(label=label, version=version, expires=expires, issued=issued)

        # Oracle aparently needs a separate query to update the cert blob:
        h.update_blob("rhnSatelliteCert", "cert", 
            "WHERE label = :label AND version = :version", cert, label=label,
            version=version)

    # always reset the slots
    set_slots_from_cert(sc)

    cfg = RHNOptions('web')
    cfg.parse()
    if cfg.get('is_monitoring_backend') == 1:
        org_id = get_org_id()
        push_monitoring_configs(org_id)

    rhnSQL.commit()

_query_update_dates = rhnSQL.Statement("""
    UPDATE rhnSatelliteCert
       SET issued = :issued, expires = :expires
     WHERE label = :label
           AND ((version is null and :version is null)
                OR version = :version)
""")

_query_latest_version = rhnSQL.Statement("""
    SELECT COALESCE(version, 0) as version, version as orig_version, cert,
        TO_CHAR(issued, 'YYYY-MM-DD HH24:MI:SS') as issued,
        TO_CHAR(expires, 'YYYY-MM-DD HH24:MI:SS') as expires
    FROM rhnSatelliteCert
    WHERE label = :label
    ORDER BY CASE WHEN version IS NULL
        THEN 0 
        ELSE version
    END, version
    DESC
""")
def retrieve_db_cert(label='rhn-satellite-cert'):
    h = rhnSQL.prepare(_query_latest_version)
    h.execute(label=label)
    row = h.fetchone_dict()
    if not row:
        return None
    row['cert'] = rhnSQL.read_lob(row['cert'])
    return row

_query_insert_cert = rhnSQL.Statement("""
    INSERT into rhnSatelliteCert 
           (label, version, cert, expires, issued)
    VALUES (:label, :version, empty_blob(),
            TO_DATE(:expires, 'YYYY-MM-DD HH24:MI:SS'), 
            TO_DATE(:issued, 'YYYY-MM-DD HH24:MI:SS'))
""")

_query_update_web_customer = rhnSQL.Statement("""
    UPDATE web_customer
    SET name = :owner
    WHERE id = 1
""")

_query_update_web_user = rhnSQL.Statement("""
    UPDATE web_user_personal_info
    SET company = :owner
""")

_query_update_rhnchannelfamily = rhnSQL.Statement("""
    UPDATE rhnchannelfamily
    SET name = :owner
    WHERE org_id = 1
""")

#
# Monitoring Scout Config Push section
# Stuff needed to push scout configs after a successful sat-cert activation
# see BZ# 163392 for more info

def push_monitoring_configs(org_id):
    push_configs_proc = rhnSQL.Procedure("rhn_install_org_satellites")

    h = rhnSQL.prepare(_query_get_sat_clusters)
    h.execute(customer_id=org_id)
    rows = h.fetchall_dict()
    if not rows:
        #since we've not found any scouts, just do nothing
        pass
    else: 
        for row in rows:
            push_configs_proc(org_id, row['recid'], '1')

        print "Pushing scout configs to all monitoring scouts"
        

_query_get_sat_clusters = rhnSQL.Statement("""
    SELECT recid
      FROM rhn_Sat_Cluster
     WHERE customer_id = :customer_id
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

    cert = strip(open(caCert, 'rb').read())

    h = rhnSQL.prepare(_querySelectCryptoCertInfo)
    h.execute(description=description, org_id=org_id)
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
        #print 'found existing certificate - id:', rhn_cryptokey_id
        ## NUKE IT!
        if deleteRowYN:
            #print 'found a cert, nuking it! id:', rhn_cryptokey_id
            h = rhnSQL.prepare('delete rhnCryptoKey where id=:rhn_cryptokey_id')
            h.execute(rhn_cryptokey_id=rhn_cryptokey_id)
            #rhnSQL.commit()
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
    #print 'no cert found, new one with id:', rhn_cryptokey_id
    h = rhnSQL.prepare(_queryInsertCryptoCertInfo)
    # ...insert
    h.execute(rhn_cryptokey_id=rhn_cryptokey_id,
              description=description, org_id=org_id)
    return rhn_cryptokey_id


def _lobUpdate_rhnCryptoKey(rhn_cryptokey_id, caCert):
    """ writes/updates the cert as a lob """

    cert = strip(open(caCert, 'rb').read())

    # Use our update blob wrapper to accomodate differences between Oracle
    # and PostgreSQL:
    h = rhnSQL.cursor()
    try:
        h.update_blob("rhnCryptoKey", "key", "WHERE id = :rhn_cryptokey_id",
            cert, rhn_cryptokey_id=rhn_cryptokey_id)
    except:
        # didn't go in!
        raise CaCertInsertionError("ERROR: CA certificate failed to be "
                                   "inserted into the database")


def store_rhnCryptoKey(description, caCert, verbosity=0):
    """ stores CA cert in rhnCryptoKey
        uses:
            _checkCertMatch_rhnCryptoKey
            _delete_rhnCryptoKey - not currently used
            _insertPrep_rhnCryptoKey
            _lobUpdate_rhnCryptoKey
    """

    org_ids = get_all_orgs()
    for org_id in org_ids:
        org_id = org_id['id']
        try:
            ## look for a cert match in the database
            rhn_cryptokey_id = _checkCertMatch_rhnCryptoKey(caCert, description,
                                                          org_id, deleteRowYN=1,
                                                          verbosity=verbosity)
            if rhn_cryptokey_id is None:
                # nothing to do - cert matches
                continue
            ## insert into the database
            if rhn_cryptokey_id == -1:
                rhn_cryptokey_id = _insertPrep_rhnCryptoKey(rhn_cryptokey_id,
                                                            description, org_id)
            ## write/update
            _lobUpdate_rhnCryptoKey(rhn_cryptokey_id, caCert)
            rhnSQL.commit()
        except rhnSQL.sql_base.SQLError:
            raise CaCertInsertionError(
                "...the traceback: %s" % fetchTraceback())


_querySelectCryptoCertInfo = rhnSQL.Statement("""
    SELECT ck.id, ck.description, ckt.label as type_label, ck.key
      FROM rhnCryptoKeyType ckt,
           rhnCryptoKey ck
     WHERE ckt.label = 'SSL'
       AND ckt.id = ck.crypto_key_type_id
       AND ck.description = :description
       AND ck.org_id = :org_id
""")

_queryInsertCryptoCertInfo = rhnSQL.Statement("""
    INSERT into rhnCryptoKey
           (id, org_id, description, crypto_key_type_id, key)
    SELECT :rhn_cryptokey_id, :org_id, :description, ckt.id, empty_blob()
      FROM rhnCryptoKeyType ckt
     WHERE ckt.label = 'SSL'
""")


def _test_storeRhnCert(rhnCert):
    storeRhnCert(rhnCert)

def _test_store_rhnCryptoKey(caCert):
    description = 'RHN-ORG-TRUSTED-SSL-CERT'
    store_rhnCryptoKey(description, caCert)

def create_first_private_chan_family():
       """
       Check to see if org has a channelfamily associated with it.
       If not, Create one.
       """
       _lookup_chfam = """
          SELECT 1 from rhnChannelFamily
           WHERE label='private-channel-family-1'
       """
       h = rhnSQL.prepare(_lookup_chfam)
       row = h.execute()
       # some extra check for upgrades
       if row:
           # Already exists, move on
           return
       _query_create_chfam = """
          INSERT INTO  rhnChannelFamily
                 (id, name, label, org_id, product_url)
          VALUES (sequence_nextval('rhn_channel_family_id_seq'), :name, :label, :org, :url)

       """
       h = rhnSQL.prepare(_query_create_chfam)
       try:
           h.execute(name='Private Channel Family 1', \
                     label='private-channel-family-1', \
                     org=1, url='First Org Created')
       except rhnSQL.SQLError, e:
           # if we're here that means we're voilating something
           raise e
           

def verify_family_permissions(orgid=1):
    """
     Verify channel family permissions for first org
    """
    _query_lookup_cfid = """
        SELECT  CF.id
          FROM  rhnChannelFamily CF
         WHERE  CF.org_id = :orgid
        AND NOT  EXISTS (
                   SELECT  1
                     FROM  rhnPrivateChannelFamily PCF
                    WHERE  PCF.org_id = CF.org_id
                      AND  PCF.channel_family_id = CF.id)
        ORDER BY  CF.id
    """

    h = rhnSQL.prepare(_query_lookup_cfid)
    h.execute(orgid = orgid)
    cfid = h.fetchone_dict()
    if not cfid:
        return

    _query_create_priv_chfam = """
        INSERT INTO  rhnPrivateChannelFamily
            (channel_family_id, org_id, max_members, current_members)
        VALUES  (:id, :org_id, NULL, 0)
    """
    
    h = rhnSQL.prepare(_query_create_priv_chfam)
    h.execute(id=cfid['id'], org_id=orgid)


if __name__ == '__main__':
    from common import initCFG, CFG
    
    initCFG('server.satellite')
    print 'database: %s' % CFG.DEFAULT_DB
    rhnSQL.initDB(CFG.DEFAULT_DB)

    #_test_storeRhnCert(open('rhn.cert').read())
    _test_store_rhnCryptoKey('ca.crt')

    # NOTE!!! This has be seg-faulting on exit, specifically upon closeDB()
    #         Bugzilla: 127324

    print "end of __main__"
    rhnSQL.closeDB()
    print "we have closed the database"

