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
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.Mail;
import com.redhat.rhn.common.messaging.SmtpMail;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.InetAddress;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * TaskHelper
 * Helper class to provide common functionality to tasks
 * @version $Rev$
 */
public class TaskHelper {

    /**
     * private constructor
     */
    private TaskHelper() {
    }

    /**
     * Logs the daemon state
     * @param label The label of the daeomon we're logging.
     */
    public static void logDaemonState(String label) {
        Map params = new HashMap();
        params.put("label", label);

        //Remove any entries from rhnDaemonState if they exist
        WriteMode m = ModeFactory.getWriteMode("General_queries",
                                               "remove_daemon_state");
        m.executeUpdate(params);

        //Add new entry
        m = ModeFactory.getWriteMode("General_queries", "add_daemon_state");
        m.executeUpdate(params);
    }

    /**
     * Send an error email to the Satellite admin
     * @param logger to log any errors to
     * @param messageBody to send.
     */
    public static void sendErrorEmail(Logger logger, String messageBody) {
        Config c = Config.get();
        LocalizationService ls = LocalizationService.getInstance();
        String[] recipients = null;
        if (c.getString("web.traceback_mail").equals("")) {

            recipients = new String[1];
            recipients[0] = "root@localhost";
        }
        else {
            recipients = c.getStringArray("web.traceback_mail");
        }
        SmtpMail mail = new SmtpMail();
        mail.setRecipients(recipients);
        StringBuffer subject = new StringBuffer();
        subject.append(ls.getMessage("web traceback subject", Locale.getDefault()));
        try {
            subject.append(InetAddress.getLocalHost().getHostName());
        }
        catch (Throwable t) {
            subject.append("Taskomatic");
        }
        mail.setSubject(subject.toString());
        mail.setBody(messageBody);
        try {
            sendMail(mail, logger);
        }
        catch (Throwable t) {
            logger.error(t);
        }

    }

    /**
     * Sends stacktrace via email
     * @param logger caller's logger
     * @param error error being thrown
     */
    public static void sendErrorMail(Logger logger, Throwable error) {
        StringWriter writer = new StringWriter();
        PrintWriter pw = new PrintWriter(writer);
        error.printStackTrace(pw);
        pw.flush();
        sendErrorEmail(logger, writer.toString());
    }

    /**
     * Sends mail and logs the mail message if debug logging is enabled
     * @param mail - message to be sent
     * @param logger - logger assigned to the caller
     */
    public static void sendMail(Mail mail, Logger logger) {
        if (logger != null && logger.isDebugEnabled()) {
            logger.debug("Sending mail message:\n" + mail.toString());
        }
        mail.send();
    }

    /**
     * @param org The org in question
     * @return Returns a list of email addresses for the org_admins in the given org.
     */
    public static String[] getAdminEmails(Org org) {
        List admins = org.getActiveOrgAdmins();
        String[] emails = new String[admins.size()];
        //go through the user objects and extract the email addrs
        int i = 0;
        for (Iterator itr = admins.iterator(); itr.hasNext(); i++) {
            User admin = (User) itr.next();
            emails[i] = admin.getEmail();
        }

        return emails;
    }
}
