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
import com.redhat.rhn.common.messaging.Mail;
import com.redhat.rhn.common.messaging.SmtpMail;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.frontend.dto.ActionMessage;
import com.redhat.rhn.frontend.dto.AwolServer;
import com.redhat.rhn.frontend.dto.OrgIdWrapper;
import com.redhat.rhn.frontend.dto.ReportingUser;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.StopWatch;
import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/**
 * DailySummary task.
 * sends daily report of stats. reaps org suggestions
 * from rhnDailySummaryQueue. Not very "daily" since it runs every
 * 30 seconds.  Need to look at RHN::DailySummaryEngine.  This task
 * queues org emails, mails queued emails, then dequeues the emails.
 * @version $Rev$
 */
public class DailySummary extends SingleThreadedTestableTask {
    
    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */
    public static final String DISPLAY_NAME = "daily_summary";
    private static final int HEADER_SPACER = 10;
    private static final int ERRATA_SPACER = 4;
    private static final String ERRATA_UPDATE = "Errata Update";
    private static final String ERRATA_INDENTION = StringUtils.repeat(" ", ERRATA_SPACER);


    private Mail mail;
    private static Logger log = Logger.getLogger(DailySummary.class);
    
    /**
     * Default constructor
     */
    public DailySummary() {
        this(new SmtpMail());
    }

    /**
     * Constructor takes in a Mailer
     * @param mailer mailer if you don't want to use the default SmtpMail
     */
    public DailySummary(Mail mailer) {
        mail = mailer;
    }
    
    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctxIn, boolean testContextIn)
        throws JobExecutionException {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_DAILY_SUMMARY_QUEUE);
        List results = m.execute();
        
        
        OrgIdWrapper oiw = null;
        for (Iterator itr = results.iterator(); itr.hasNext();) {
            try {
                oiw = (OrgIdWrapper) itr.next();
                if (log.isDebugEnabled()) {
                    log.debug("dealing with org: " + oiw.toLong());
                }
                queueOrgEmails(oiw.toLong());
            }
            catch (Exception e) {
                log.error(e.getMessage(), e);
            }
            finally {
                try {
                    dequeueOrg(oiw.toLong());
                    if (log.isDebugEnabled()) {
                        log.debug("org " + oiw.toLong() + " removed from queue");
                    }
                }
                finally {
                    HibernateFactory.commitTransaction();
                    HibernateFactory.closeSession();
                }
            }
        }        
    }

    /**
     * DO NOT CALL FROM OUTSIDE THIS CLASS. Removes the orgs from the queue
     * table.
     * @param orgId Org Id to be dequeued.
     * @return # of orgs dequeued
     */
    public int dequeueOrg(Long orgId) {
        WriteMode m = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_DEQUEUE_DAILY_SUMMARY);
        Map params = new HashMap();
        params.put("org_id", orgId);
        return m.executeUpdate(params);
    }

    /**
     * DO NOT CALL FROM OUTSIDE THIS CLASS. Queues up the Org Emails for
     * mailing.
     * @param orgId Org Id to be processed.
     */
    public void queueOrgEmails(Long orgId) {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_USERS_WANTING_REPORTS);
        Map params = new HashMap();
        params.put("org_id", orgId);
        
        StopWatch watch = new StopWatch();
        watch.start();
        List users = m.execute(params);
        for (Iterator itr = users.iterator(); itr.hasNext();) {
            ReportingUser ru = (ReportingUser) itr.next();
            // run_user
            List awol = getAwolServers(ru.idAsLong());
            // send email
            List actions = getActionInfo(ru.idAsLong());
            if ((awol == null || awol.size() == 0) && (actions == null || 
                    actions.size() == 0)) {
                log.debug("Skipping ORG " + orgId + " because daily summary info has " + 
                        "changed");
                continue;
            }

            String awolMsg = renderAwolServersMessage(awol);
            String actionMsg = renderActionsMessage(actions);
            
            String emailMsg = prepareEmail(
                    ru.getLogin(), ru.getAddress(), awolMsg, actionMsg);
            
            LocalizationService ls = LocalizationService.getInstance(); 
            mail.setSubject(ls.getMessage(
                    "dailysummary.email.subject", ls.formatDate(new Date())));
            mail.setRecipient(ru.getAddress());
            
            if (log.isDebugEnabled()) {
                log.debug("Sending email to [" + ru.getAddress() + "]");
            }

            mail.setBody(emailMsg);
            TaskHelper.sendMail(mail, log);
        }
        watch.stop();
        if (log.isDebugEnabled()) {
            log.debug("queued emails of org of " + users.size() + 
                " users in " + watch.getTime() + "ms");
        }
    }
    
    /**
     * DO NOT CALL FROM OUTSIDE THIS CLASS. Returns the list of awol servers.
     * @param uid User id whose awol servers are sought.
     * @return the list of recent awol servers.
     */
    public List getAwolServers(Long uid) {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_USERS_AWOL_SERVERS);
        Map params = new HashMap();
        params.put("user_id", uid);
        params.put("checkin_threshold",
                Config.get().getInteger(ConfigDefaults.SYSTEM_CHECKIN_THRESHOLD));
        
        return m.execute(params);
    }
    
    /**
     * DO NOT CALL FROM OUTSIDE THIS CLASS. Returns the list of recent actions.
     * @param uid User id whose recent actions are sought.
     * @return the list of recent actions.
     */
    public List getActionInfo(Long uid) {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_GET_ACTION_INFO);
        Map params = new HashMap();
        params.put("user_id", uid);
        
        return m.execute(params);
    }
    
    /**
     * DO NOT CALL FROM OUTSIDE THIS CLASS. Renders the awol servers message
     * @param servers list of awol servers
     * @return the awol servers message
     */
    public String renderAwolServersMessage(List servers) {
        if (servers == null || servers.isEmpty()) {
            return "";
        }
        /*
         * The Awol message is going to be a table containing a list of systems
         * that have gone AWOL.
         * 
         * All the calculation crap for tables will be done...  how many spaces
         * between columns and the column width for the given data.
         * This means that we will read through the data twice, once to find the
         * longest entries and again to build the return string.
         * 
         * Since this will be going in an email, if the receiver doesn't use
         * monospace fonts *ever* than all this calculation is for nothing.
         */
        LocalizationService ls = LocalizationService.getInstance();
        String sid = ls.getMessage("taskomatic.daily.sid"); //System Id column
        String sname = ls.getMessage("taskomatic.daily.systemname"); //System Name column
        String checkin = ls.getMessage("taskomatic.daily.checkin"); //Last Checkin column
        
        //First we need to figure out how long the width of the columns should be.
        int minDiff = 4; //this is the minimum spaces between header elements
        int sidLength = sid.length() + minDiff;
        int snameLength = sid.length() + minDiff;
        
        //Find the longest entry in the table for both sid and sname.
        for (Iterator itr = servers.iterator(); itr.hasNext();) {
            AwolServer as = (AwolServer) itr.next();
            String currentId = as.getId().toString();
            if (currentId.length() >= sidLength) {
                //extra space so the longest entry doesn't connect to the next column
                sidLength = currentId.length() + 1;
            }
            String currentName = as.getName();
            if (currentName.length() >= snameLength) {
                //extra space so the longest entry doesn't connect to the next column
                snameLength = currentName.length() + 1;
            }
        }
        
        //render the header--  System Id        System Name        LastCheckin
        StringBuffer buf = new StringBuffer();
        buf.append(sid);
        buf.append(StringUtils.repeat(" ", sidLength - sid.length()));
        buf.append(sname);
        buf.append(StringUtils.repeat(" ", snameLength - sname.length()));
        buf.append(checkin);
        buf.append("\n");
        
        //Now render the data in the table
        for (Iterator itr = servers.iterator(); itr.hasNext();) {
            AwolServer as = (AwolServer) itr.next();
            String currentId = as.getId().toString();
            buf.append(currentId);
            buf.append(StringUtils.repeat(" ", sidLength - currentId.length()));
            String currentName = as.getName();
            buf.append(currentName);
            buf.append(StringUtils.repeat(" ", snameLength - currentName.length()));
            buf.append(as.getCheckin());
            buf.append("\n");
        }
        
        //Lastly, create the url for the link in the email.
        StringBuffer url = new StringBuffer();
        if (Config.get().getBoolean(ConfigDefaults.SSL_AVAILABLE)) {
            url.append("https://");
        }
        else {
            url.append("http://");
        }
        url.append(getHostname());
        url.append("/rhn/systems/Inactive.do");
        
        return LocalizationService.getInstance().getMessage(
                "taskomatic.msg.awolservers", buf.toString(), url);
    }
    
    /**
     * DO NOT CALL FROM OUTSIDE THIS CLASS. Renders the actions email message
     * @param actions list of recent actions
     * @return the actions email message
     */
    public String renderActionsMessage(List<ActionMessage> actions) {

        int longestActionLength = HEADER_SPACER;
        int longestStatusLength = 0;
        StringBuffer hdr = new StringBuffer();
        StringBuffer body = new StringBuffer();
        StringBuffer legend = new StringBuffer();
        StringBuffer msg = new StringBuffer();
        LinkedHashSet<String> statusSet = new LinkedHashSet();
        TreeMap<String, HashMap<String, Integer>> nonErrataActions = new TreeMap();
        TreeMap<String, HashMap<String, Integer>> errataActions = new TreeMap();
        TreeMap<String, String> errataSynopsis = new TreeMap();

        legend.append(LocalizationService
                .getInstance().getMessage("taskomatic.daily.errata"));
        legend.append("\n\n");

        for (ActionMessage am : actions) {

            if (!statusSet.contains(am.getStatus())) {
                statusSet.add(am.getStatus());
                if (am.getStatus().length() > longestStatusLength) {
                    longestStatusLength = am.getStatus().length();
                }
            }

            if (am.getType().equals(ERRATA_UPDATE)) {
                String advisoryKey = ERRATA_INDENTION + am.getAdvisory();

                if (!errataActions.containsKey(advisoryKey)) {
                    errataActions.put(advisoryKey, new HashMap());
                    if (advisoryKey.length() + HEADER_SPACER > longestActionLength) {
                        longestActionLength = advisoryKey.length() + HEADER_SPACER;
                    }
                }
                HashMap<String, Integer> counts = errataActions.get(advisoryKey);
                counts.put(am.getStatus(), am.getCount());

                if (!errataSynopsis.containsKey(am.getAdvisory())) {
                    errataSynopsis.put(am.getAdvisory(), am.getSynopsis());
                }
            }
            else {
                if (!nonErrataActions.containsKey(am.getType())) {
                    nonErrataActions.put(am.getType(), new HashMap());
                    if (am.getType().length() + HEADER_SPACER > longestActionLength) {
                        longestActionLength = am.getType().length() + HEADER_SPACER;
                    }
                }
                HashMap<String, Integer> counts = nonErrataActions.get(am.getType());
                counts.put(am.getStatus(), am.getCount());
            }

        }
        
        hdr.append(StringUtils.repeat(" ", longestActionLength));
        for (String status : statusSet) {
            hdr.append(status + StringUtils.repeat(" ", (longestStatusLength +
                    ERRATA_SPACER) - status.length()));
        }

        if (!errataActions.isEmpty()) {
            body.append(ERRATA_UPDATE + ":" + "\n");
        }
        StringBuffer formattedErrataActions = renderActionTree(longestActionLength,
                longestStatusLength, statusSet, errataActions);
        body.append(formattedErrataActions);

        for (String advisory : errataSynopsis.keySet()) {
            legend.append(ERRATA_INDENTION + advisory + ERRATA_INDENTION +
                    errataSynopsis.get(advisory) + "\n");
        }

        StringBuffer formattedNonErrataActions = renderActionTree(longestActionLength,
                longestStatusLength, statusSet, nonErrataActions);
        body.append(formattedNonErrataActions);

        // finally put all this together
        msg.append(hdr.toString());
        msg.append("\n");
        msg.append(body.toString());
        msg.append("\n\n");
        if (!errataSynopsis.isEmpty()) {
            msg.append(legend.toString());
        }
        return msg.toString();
    }
    
    private StringBuffer renderActionTree(int longestActionLength,
            int longestStatusLength, LinkedHashSet<String> statusSet,
            TreeMap<String, HashMap<String, Integer>> actionTree) {
        StringBuffer formattedActions = new StringBuffer();
        for (String actionName : actionTree.keySet()) {
            formattedActions.append(actionName +
                   StringUtils.repeat(" ", (longestActionLength - (actionName.length()))));
            for (String status : statusSet) {
                HashMap<String, Integer> counts = actionTree.get(actionName);
                Integer theCount = counts.get(status);
                if (counts.containsKey(status)) {
                    theCount = counts.get(status);
                }
                else {
                    theCount = 0;
                }
                formattedActions.append(theCount);
                formattedActions.append(StringUtils.repeat(" ", longestStatusLength +
                        ERRATA_SPACER - theCount.toString().length()));
            }
            formattedActions.append("\n");
        }
        return formattedActions;
    }

    /**
     * DO NOT CALL FROM OUTSIDE THIS CLASS. Prepares the email message string
     * @param login users login
     * @param email email address
     * @param awolMsg the awol servers msg
     * @param actionMsg the recent actions message
     * @return the email message string
     */
    public String prepareEmail(
            String login, String email, String awolMsg, String actionMsg) {

        LocalizationService ls = LocalizationService.getInstance();
        String[] args = new String[7];
        args[0] = login;
        args[1] = ls.formatDate(new Date());
        args[2] = actionMsg;
        args[3] = awolMsg;
        args[4] = getHostname();
        // why the hell are these in OrgFactory?
        args[5] = OrgFactory.EMAIL_FOOTER.getValue();
        args[6] = OrgFactory.EMAIL_ACCOUNT_INFO.getValue();
        String msg =  ls.getMessage(
                "dailysummary.email.body", (Object[])args);
        
        // wow, what an ugly @$$ hack, but this requires rewriting
        // the email templating engine which kinda sucks.
        msg = StringUtils.replace(msg, "<login />", login);
        return StringUtils.replace(msg, "<email-address />", email);
    }
    
    private String getHostname() {
        return ConfigDefaults.get().getHostname();
    }
}
