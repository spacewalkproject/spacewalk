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
package com.redhat.rhn.taskomatic.task;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.Mail;
import com.redhat.rhn.common.messaging.SmtpMail;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.manager.satellite.CertificateManager;

import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

/**
 * SatelliteCertificateCheck
 * @version $Rev$
 */
public class SatelliteCertificateCheck extends SingleThreadedTask {

    private static Logger log = Logger.getLogger(SatelliteCertificateCheck.class);

    public static final String DISPLAY_NAME = "satcert_check";

    /**
     * {@inheritDoc}
     */
    protected void run(JobExecutionContext ctx) throws JobExecutionException {
        LocalizationService ls = LocalizationService.getInstance();

        CertificateManager man = CertificateManager.getInstance();

        if (man.isSatelliteCertExpired()) {
           sendMessage(ls.getMessage("email.satellitecert.expired.subject"),
                       ls.getMessage("email.satellitecert.expired.body",
                               ConfigDefaults.get().getHostname()));
        }
        else if (man.isSatelliteCertInGracePeriod()) {
            long daysUntilExpiration = (man.getGracePeriodEndDate().getTime()  -
                    System.currentTimeMillis()) /
                    86400000;

            Object[] args = new String[2];
            args[0] = ConfigDefaults.get().getHostname();
            args[1] = new Long(daysUntilExpiration).toString();
            sendMessage(ls.getMessage("email.satellitecert.graceperiod.subject"),
                        ls.getMessage("email.satellitecert.graceperiod.body", args));
        }
    }

    protected void sendMessage(String subject, String body) {
        Org org = OrgFactory.getSatelliteOrg();

        Mail mail = getMailer();
        mail.setSubject(subject);
        mail.setBody(body);
        mail.setRecipients(TaskHelper.getAdminEmails(org));

        String from = Config.get().getString("web.customer_service_email",
                                             "dev-null@redhat.com");

        mail.setFrom(from);
        mail.setHeader("X-RHN-Info", "backend_satellite_certificate_check");
        try {
            TaskHelper.sendMail(mail, log);
        }
        catch (Exception e) {
          log.error("Exception while sending notification email: " +
                    "org_id: " + org.getId());
          log.error(e.getMessage(), e);
        }

    }

    /**
     * @return Returns a Mail object
     */
    protected Mail getMailer() {
        return new SmtpMail();
    }

}
