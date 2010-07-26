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
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.JavaMailException;
import com.redhat.rhn.common.messaging.Mail;
import com.redhat.rhn.common.messaging.SmtpMail;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.impl.PublishedErrata;
import com.redhat.rhn.domain.org.OrgFactory;

import org.apache.commons.lang.StringUtils;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * This is a port of the ErrataEngine taskomatic task
 *
 * @version $Rev.$
 */

public class ErrataMailer extends RhnJavaJob {

    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */
    public static final String DISPLAY_NAME = "errata_engine";

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext context)
        throws JobExecutionException {

        try {
            List results = getErrataToProcess();
            if (results == null || results.size() == 0) {
                if (log.isDebugEnabled()) {
                    log.debug("No errata found...exiting");
                }
            }
            else {
                if (log.isDebugEnabled()) {
                    log.debug("=== Queued up " + results.size() + " errata");
                }
                Map erratas = new HashMap();
                WriteMode cleanUp = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                        TaskConstants.TASK_QUERY_ERRATAMAILER_CLEAN_QUEUE);
                for (Iterator iter = results.iterator(); iter.hasNext();) {
                    Map row = (Map) iter.next();
                    Long errataId = (Long) row.get("errata_id");
                    Long orgId = (Long) row.get("org_id");
                    Long channelId = (Long) row.get("channel_id");
                    markErrataDone(errataId, orgId, channelId);
                    if (!hasProcessedErrata(orgId, errataId, erratas)) {
                        if (log.isDebugEnabled()) {
                            log.debug("Processing errata " + errataId +
                                    " for org " + orgId);
                        }
                        try {
                            sendEmails(errataId, orgId, channelId);
                            if (log.isDebugEnabled()) {
                                log.debug("Finished errata " + errataId +
                                        " for org " + orgId);
                            }
                        }
                        catch (JavaMailException e) {
                            log.error("Error sending mail", e);
                        }
                        try {
                            cleanUp.executeUpdate(Collections.EMPTY_MAP);
                            HibernateFactory.commitTransaction();
                        }
                        catch (Exception e) {
                            log.error("Error cleaning up ErrataMailer queue", e);
                        }
                    }
                }
            }
        }
        catch (Exception e) {
            log.error(e.getMessage(), e);
            throw new JobExecutionException(e);
        }
        finally {
            WriteMode cleanUp = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                    TaskConstants.TASK_QUERY_ERRATAMAILER_CLEAN_QUEUE);
            try {
                cleanUp.executeUpdate(Collections.EMPTY_MAP);
            }
            catch (Exception e) {
                log.error("Error cleaning up ErrataMailer queue", e);
            }
        }

    }

    protected List getErrataToProcess() {
        SelectMode select = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_ERRATAMAILER_FIND_ERRATA);
        Map params = new HashMap();
        params.put("threshold", new Integer(1));
        List results = select.execute(params);
        return results;
    }

    private boolean hasProcessedErrata(Long orgId, Long errataId,
            Map erratas) {
        boolean retval = false;
        List errataIds = (List) erratas.get(orgId);
        if (errataIds == null) {
            errataIds = new LinkedList();
            errataIds.add(errataId);
            erratas.put(orgId, errataIds);
        }
        else {
            retval = errataIds.contains(errataId);
            if (!retval) {
                errataIds.add(errataId);
            }
        }
        return retval;
    }

    private void markErrataDone(Long errataId, Long orgId, Long channelId)
                                                            throws Exception {
        HibernateFactory.getSession();
        WriteMode marker = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_ERRATAMAILER_MARK_ERRATA_DONE);
        Map params = new HashMap();
        params.put("org_id", orgId);
        params.put("errata_id", errataId);
        params.put("channel_id", channelId);
        int rowsUpdated = marker.executeUpdate(params);
        if (log.isDebugEnabled()) {
            log.debug("Marked " + rowsUpdated + " rows complete");
            log.debug("errata_id = " + errataId + " AND channel_id = " + channelId + " AND org_id = " + orgId);
        }
        HibernateFactory.commitTransaction();
        HibernateFactory.closeSession();
    }

    private void sendEmails(Long errataId, Long orgId, Long channelId) throws Exception {
        Errata errata = (Errata) HibernateFactory.getSession().load(PublishedErrata.class,
                new Long(errataId.longValue()));
        populateWorkQueue(errataId, orgId, channelId);
        List users = findTargetUsers();
        if (users == null || users.size() == 0) {
            if (log.isDebugEnabled()) {
                log.debug("No target users found for errata " + errata.getId() +
                        "...skipping");
            }
            return;
        }
        else {
            if (log.isDebugEnabled()) {
                log.debug("Found " + String.valueOf(users.size()) + " target users");
            }
        }

        for (Iterator iter = users.iterator(); iter.hasNext();) {
            Map row = (Map) iter.next();
            String email = (String) row.get("email");
            Long userPK = (Long) row.get("id");
            List servers = findTargetServers(userPK);
            String login = (String) row.get("login");
            String emailBody = formatEmail(login, email, errata, servers);
            Mail mail = new SmtpMail();
            mail.setRecipient(email);
            mail.setHeader("X-RHN-Info",
                    "Autogenerated mail for " + login);
            mail.setHeader("Precedence", "first-class");
            mail.setHeader("Errors-To", "rhn-bounce" +
                    login + "-" + orgId.toString() + "@rhn.redhat.com");
            mail.setBody(emailBody);
            StringBuffer subject = new StringBuffer();
            subject.append(Config.get().getString("web.product_name") + " Errata Alert: ");
            subject.append(errata.getAdvisory()).append(" - ");
            subject.append(errata.getSynopsis());
            mail.setSubject(subject.toString());
            TaskHelper.sendMail(mail, log);
        }
    }

    private List findTargetServers(Long userPK) throws Exception {
        SelectMode mode = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_ERRATAMAILER_FIND_TARGET_SERVERS);
        Map params = new HashMap();
        params.put("user_id", userPK);
        return mode.execute(params);
    }

    protected List findTargetUsers() throws Exception {
        SelectMode mode = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_ERRATAMAILER_FIND_TARGET_USERS);
        return mode.execute(Collections.EMPTY_MAP);
    }

    private void populateWorkQueue(Long errataId, Long orgId, Long channelId)
            throws Exception {
        HibernateFactory.getSession();
        WriteMode queueWriter = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_ERRATAMAILER_FILL_WORK_QUEUE);
        Map params = new HashMap();
        params.put("errata_id", errataId);
        params.put("org_id", orgId);
        params.put("channel_id", channelId);
        int workItemsFound = queueWriter.executeUpdate(params);
        if (log.isDebugEnabled()) {
            log.debug("Queuing " + workItemsFound +  " rows of work");
        }
        HibernateFactory.commitTransaction();
        HibernateFactory.closeSession();
    }

    private String formatEmail(String login,
            String email,
            Errata errata,
            List servers) {
        StringBuffer body = new StringBuffer();

        //Build the hostname with protocol. Used to create urls for the email.
        String host;
        //The protocol from configuration.
        if (ConfigDefaults.get().isSSLAvailable()) {
            host = "https://";
        }
        else {
            host = "http://";
        }
        //Add the hostname
        host = host + ConfigDefaults.get().getHostname();

        //Build the email body
        body.append(getEmailBodySummary(errata, host));
        body.append("\n").append("\n");
        body.append(getEmailBodyAffectedSystems(host, servers));
        body.append("\n").append("\n");
        body.append(getEmailBodyPreferences(host, login, email));

        return body.toString();
    }

    private String getEmailBodySummary(Errata errata, String host) {
        LocalizationService ls = LocalizationService.getInstance();
        Object[] args = new Object[8];

        //Build the errata details url.
        StringBuffer buffy = new StringBuffer();
        buffy.append(host).append("/rhn/errata/details/Details.do?eid=");
        buffy.append(errata.getId().toString());
        args[0] = buffy.toString();

        //Add in the errata information.
        args[1] = errata.getAdvisoryType() == null ? "" : errata.getAdvisoryType();
        args[2] = errata.getAdvisory() == null ? "" : errata.getAdvisory();
        args[3] = errata.getSynopsis() == null ? "" : errata.getSynopsis();
        args[4] = errata.getTopic() == null ? "" : errata.getTopic();
        args[5] = errata.getDescription() == null ? "" : errata.getDescription();
        args[6] = errata.getNotes() == null ? "" : errata.getNotes();
        args[7] = errata.getRefersTo() == null ? "" : errata.getRefersTo();
        return ls.getMessage("email.errata.notification.body.summary", args);
    }

    private String getEmailBodyAffectedSystems(String host, List servers) {
        LocalizationService ls = LocalizationService.getInstance();

        //Render the header of the affected systems section along with helpful text.
        StringBuffer buffy = new StringBuffer();
        buffy.append(ls.getMessage("email.errata.notification.body.affectedheader"));
        buffy.append("\n").append("\n");

        //There is one sentence off on its own that deals with whether there are
        //multiple systems or just one, so this is a separate trans-unit.
        if (servers.size() == 1) {
            buffy.append(ls.getMessage("email.errata.notification.body.onesystem"));
        }
        else {
            buffy.append(ls.getMessage("email.errata.notification.body.numsystems",
                    new Object[] {String.valueOf(servers.size())}));
        }
        buffy.append("\n").append("\n");

        //Now show the table of affected systems and the footer text
        Object[] args = new Object[2];

        //Create the data to show in the table
        //TODO: I'm just copying over code that was here before, but it
        //      seems to me that we should be printing another column to
        //      the table according to the String Resource bundle.
        StringWriter writer = new StringWriter();
        PrintWriter printWriter = new PrintWriter(writer, true);
        for (Iterator iter = servers.iterator(); iter.hasNext();) {
            Map row = (Map) iter.next();
            String release = (String) row.get("release");
            printWriter.print(release);
            for (int i = 0; i < (11 - release.length()); i++) {
                printWriter.print(' ');
            }
            String arch = (String) row.get("arch");
            printWriter.print(arch);
            for (int i = 0; i < (11 - arch.length()); i++) {
                printWriter.print(' ');
            }
            printWriter.println((String) row.get("name"));
        }
        printWriter.flush();
        args[0] = writer.toString();
        //URL for the system list
        args[1] = host + "/rhn/systems/Overview.do";
        buffy.append(ls.getMessage("email.errata.notification.body.affected", args));
        return buffy.toString();
    }

    private String getEmailBodyPreferences(String host, String login, String email) {
        LocalizationService ls = LocalizationService.getInstance();
        Object[] args = new Object[3];

        //URL for user preferences
        args[0] = host + "/rhn/account/UserPreferences.do";
        //custom email footer
        args[1] = OrgFactory.EMAIL_FOOTER.getValue();

        //custom account info
        args[2] = OrgFactory.EMAIL_ACCOUNT_INFO.getValue();

        //This is so ugly! For some reason we support these 'macros' for
        //account info only. But we made them look like XML tags as if spaces
        //didn't matter. However, spaces do matter. <sigh />
        args[2] = StringUtils.replace(args[2].toString(),
                "<login />",
                login);
        args[2] = StringUtils.replace(args[2].toString(),
                "<email-address />",
                email);

        return ls.getMessage("email.errata.notification.body.preferences", args);
    }
}
