/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

/**
 * SatelliteCertificateCheck
 * @version $Rev$
 */
public class SatelliteCertificateCheck extends RhnJavaJob {

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctx) throws JobExecutionException {
        LocalizationService ls = LocalizationService.getInstance();

        CertificateManager man = CertificateManager.getInstance();

        if (man.isSatelliteCertInRestrictedPeriod()) {
            String[] dayProgress = man.getDayProgressInRestrictedPeriod();
            String body = ls.getMessage("email.satellitecert.restricted.body",
                    ConfigDefaults.get().getHostname(), dayProgress[0], dayProgress[1]);
            if (ConfigDefaults.get().isSpacewalk()) {
                body += ls.getMessage("email.satellitecert.spwbodyend");
            }
            else {
                body += ls.getMessage("email.satellitecert.satbodyend");
            }
            sendMessage(ls.getMessage("email.satellitecert.expired.subject"),
                    body);
        }
        else if (man.isSatelliteCertExpired()) {
            String body = ls.getMessage("email.satellitecert.expired.body",
                    ConfigDefaults.get().getHostname());
            if (ConfigDefaults.get().isSpacewalk()) {
                body += ls.getMessage("email.satellitecert.spwbodyend");
            }
            else {
                body += ls.getMessage("email.satellitecert.satbodyend");
            }
            sendMessage(ls.getMessage("email.satellitecert.expired.subject"),
                    body);
        }
        else if (man.isSatelliteCertInGracePeriod()) {
            Object[] args = new String[3];
            args[0] = ConfigDefaults.get().getHostname();
            args[1] = new Long(man.getDaysLeftBeforeCertExpiration()).toString();
            args[2] = new Long(CertificateManager.RESTRICTED_PERIOD_IN_DAYS).toString();
            String body = ls.getMessage("email.satellitecert.graceperiod.body", args);
            if (ConfigDefaults.get().isSpacewalk()) {
                body += ls.getMessage("email.satellitecert.spwbodyend");
            }
            else {
                body += ls.getMessage("email.satellitecert.satbodyend");
            }
            sendMessage(ls.getMessage("email.satellitecert.graceperiod.subject"),
                    body);
        }
    }

    protected void sendMessage(String subject, String body) {
        Org org = OrgFactory.getSatelliteOrg();

        Mail mail = getMailer();
        mail.setSubject(subject);
        mail.setBody(body);
        mail.setRecipients(TaskHelper.getAdminEmails(org));

        String from = Config.get().getString("java.customer_service_email",
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
