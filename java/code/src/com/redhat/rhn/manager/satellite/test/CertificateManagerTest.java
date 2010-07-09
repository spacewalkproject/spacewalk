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
package com.redhat.rhn.manager.satellite.test;

import com.redhat.rhn.domain.satellite.CertificateFactory;
import com.redhat.rhn.domain.satellite.SatelliteCertificate;
import com.redhat.rhn.manager.satellite.CertificateManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;

/**
 * SatelliteManagerTest
 * @version $Rev$
 */
public class CertificateManagerTest extends RhnBaseTestCase {

    public void testIsSatelliteCertExpired() throws Exception {

        CertificateManager man = CertificateManager.getInstance();

        expireSatelliteCertificate();
        assertTrue(man.isSatelliteCertExpired());

        renewSatelliteCertificate();
        assertFalse(man.isSatelliteCertExpired());
    }

    public void testIsSatelliteCertInGracePeriod() throws Exception {

        CertificateManager man = CertificateManager.getInstance();

        activateGracePeriod();
        assertTrue(man.isSatelliteCertInGracePeriod());

        renewSatelliteCertificate();
        assertFalse(man.isSatelliteCertInGracePeriod());

        expireSatelliteCertificate();
        assertFalse(man.isSatelliteCertInGracePeriod());
    }

    /**
     * Changes the satellite's certificate such that it is expired for the
     * duration of the test
     * @throws Exception
     */
    public static void expireSatelliteCertificate() throws Exception {
        SatelliteCertificate sc = CertificateFactory.lookupNewestCertificate();
        /* set the expiration date to one millisecond after THE EPOCH */
        sc.setExpires(new Date(1));
        TestUtils.saveAndFlush(sc);
    }

    /**
     * Change the satellite's certificate such that it is in a grace period
     * for the duration of the test
     * @throws Exception
     */
    public static void activateGracePeriod() throws Exception {
        SatelliteCertificate sc = CertificateFactory.lookupNewestCertificate();
        /* set the expiration date two days in the past */
        sc.setExpires(new Date(System.currentTimeMillis() - 48 * 60 * 60 * 1000));
        TestUtils.saveAndFlush(sc);
    }

    /**
     * Change the satellite's certificate such that it is not in a grace period
     * or expired for the duration of the test
     */
    public static void renewSatelliteCertificate() throws Exception {
        SatelliteCertificate sc = CertificateFactory.lookupNewestCertificate();
        /* set the expiration date three days in the future */
        sc.setExpires(new Date(System.currentTimeMillis() + 72 * 60 * 60 * 1000));
        TestUtils.saveAndFlush(sc);
    }
 }
