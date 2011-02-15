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
import sys
from spacewalk.common import rhn_memusage
from spacewalk.server.rhnServer import satellite_cert

def main():
    for i in range(1000):
        if not (i % 100):
            print rhn_memusage.mem_usage()
        test()

def test():
    c = satellite_cert.SatelliteCert()
    c.load(CERT)

CERT = """
<rhn-cert version="0.1">
  <rhn-cert-field name="product">RHN-SATELLITE-001</rhn-cert-field>
  <rhn-cert-field name="owner">Mihai Ibanescu</rhn-cert-field>
  <rhn-cert-field name="issued">2004-03-04 10:37:26</rhn-cert-field>
  <rhn-cert-field name="expires">2005-03-04 03:23:05</rhn-cert-field>
  <rhn-cert-field name="slots">10000</rhn-cert-field>
  <rhn-cert-field name="provisioning-slots">100</rhn-cert-field>
  <rhn-cert-field name="nonlinux-slots">100</rhn-cert-field>
  <rhn-cert-field name="channel-families" quantity="10000" family="rh-advanced-server"/>
  <rhn-cert-field name="channel-families" quantity="25" family="rhn-proxy"/>
  <rhn-cert-field name="channel-families" quantity="25" family="rhn-tools"/>
  <rhn-cert-field name="channel-families" quantity="25" family="rhel-i386-as-extras"/>
  <rhn-cert-field name="channel-families" quantity="25" family="rh-ent-linux-i386-es-2.1"/>
  <rhn-cert-field name="channel-families" quantity="25" family="rhel-i386-es-extras"/>
  <rhn-cert-field name="channel-families" quantity="25" family="rh-ent-linux-i386-ws-2.1"/>
  <rhn-cert-field name="channel-families" quantity="25" family="rhel-x86_64-as"/>
  <rhn-cert-field name="channel-families" quantity="25" family="rhel-x86_64-as-extras"/>
  <rhn-cert-field name="channel-families" quantity="25" family="rhel-x86_64-ws"/>
  <rhn-cert-field name="channel-families" quantity="25" family="rhel-x86_64-ws-extras"/>
  <rhn-cert-field name="satellite-version">3.6</rhn-cert-field>
  <rhn-cert-signature>
-----BEGIN PGP SIGNATURE-----
This is not a real signature...
-----END PGP SIGNATURE-----
</rhn-cert-signature>
</rhn-cert>
"""

if __name__ == '__main__':
    sys.exit(main() or 0)
