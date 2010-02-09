/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.domain.satellite.test;

import com.redhat.rhn.domain.satellite.CertificateFactory;
import com.redhat.rhn.domain.satellite.SatelliteCertificate;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * SatelliteFactoryTest
 * @version $Rev$
 */
public class CertificateFactoryTest extends RhnBaseTestCase {

    public void testLookupNewestCertificate() throws Exception {
        
        SatelliteCertificate sc = CertificateFactory.lookupNewestCertificate();
        assertNotNull(sc);
        assertNotNull(sc.getExpires());
        assertNotNull(sc.getVersion());
        assertNotNull(sc.getCert());
        assertNotNull(sc.getIssued());
        assertNotNull(sc.getCreated());
        assertNotNull(sc.getModified());
        
    }
}
