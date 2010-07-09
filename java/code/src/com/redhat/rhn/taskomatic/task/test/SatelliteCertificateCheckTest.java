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
package com.redhat.rhn.taskomatic.task.test;

import com.redhat.rhn.common.messaging.Mail;
import com.redhat.rhn.common.messaging.test.MockMail;
import com.redhat.rhn.manager.satellite.test.CertificateManagerTest;
import com.redhat.rhn.taskomatic.task.SatelliteCertificateCheck;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.quartz.JobExecutionException;

/**
 * SatelliteCertificateCheckTest
 * @version $Rev$
 */
public class SatelliteCertificateCheckTest extends RhnBaseTestCase {

    private MockMail mailer = new MockMail();

    public void testExecuteForExpire() throws Exception {

        CertificateManagerTest.expireSatelliteCertificate();

        SatelliteCertificateCheck check = new SatelliteCertificateCheck() {
            protected Mail getMailer() {
                return mailer;
            }
        };

        try {
            check.execute(null);
        }
        catch (JobExecutionException e) {
            e.printStackTrace();
        }

        assertNotNull(mailer.getBody());
    }

    public void testExecuteForGracePeriod() throws Exception {

        CertificateManagerTest.activateGracePeriod();

        SatelliteCertificateCheck check = new SatelliteCertificateCheck() {
            protected Mail getMailer() {
                return mailer;
            }
        };

        try {
            check.execute(null);
        }
        catch (JobExecutionException e) {
            e.printStackTrace();
        }

        assertNotNull(mailer.getBody());
    }
}
