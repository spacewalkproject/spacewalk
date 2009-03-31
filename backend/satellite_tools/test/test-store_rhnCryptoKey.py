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
""" delete's certificate from database
    inserts new certificate into database
    reinserts new certificate into database w/o deleting certificate

    In this test case:
    org_id = 1
    description = 'RHN-ORG-TRUSTED-SSL-CERT'
    
"""

import os

from server import rhnSQL
from common import initCFG, CFG

from satellite_tools.satCerts import store_rhnCryptoKey
from satellite_tools.satCerts import _querySelectCryptoCertInfo

print "NOTE: has to be performed on an RHN Satellite or server"

description = 'RHN-ORG-TRUSTED-SSL-CERT'

initCFG('server.satellite')
rhnSQL.initDB(CFG.DEFAULT_DB)

def deleteCertRow():
    # get rhn_cryptokey_id (there can only be one, bugzilla: 120297)
    h = rhnSQL.prepare(_querySelectCryptoCertInfo)
    h.execute(description=description, org_id=1)
    row = h.fetchone_dict()
    if row:
        rhn_cryptokey_id = int(row['id'])
        print 'found a cert, nuking it! id:', rhn_cryptokey_id
        h = rhnSQL.prepare('delete rhnCryptoKey where id=:rhn_cryptokey_id')
        h.execute(rhn_cryptokey_id=rhn_cryptokey_id)
        rhnSQL.commit()

# bugzilla: 127324 - segfaults if you remove next line (if no delete in
#                    the store_rhnCryptoKey function)
#deleteCertRow()

print 'store CA cert once'
open('XXXca.crt', 'wb').write('X'*5031)
store_rhnCryptoKey(description, 'XXXca.crt')
os.unlink('XXXca.crt')

print 'store new one without deleting old one! Should just work.'
open('XXXca.crt', 'wb').write('Y'*5031)
store_rhnCryptoKey(description, 'XXXca.crt')
os.unlink('XXXca.crt')


