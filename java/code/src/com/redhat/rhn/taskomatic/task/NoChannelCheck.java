/**
 * Copyright (c) 2009 Red Hat, Inc.
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
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.Mail;
import com.redhat.rhn.common.messaging.SmtpMail;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * NoChannelCheck
 * This task looks through the system database and finds systems 
 * that have no channels associated with them. It then emails 
 * the first admin it can find in the systems' organization
 * and informs him of the status of the machine.
 * @version $Rev$
 */
public class NoChannelCheck extends SingleThreadedTask {
    
    private static Logger log;
    private Mail mail;
    private boolean mailSent;
    
    public static final String DISPLAY_NAME = "server_channel_check";
    
  /**
    * Intended for normal usage. Class uses SmtpMail for 
    * mailing purposes by default
    */
    public NoChannelCheck() {
        this(new SmtpMail());
    }
    
   /**
     * Intended for testing purposes. 
     * @param mailer Mail object to be used for mailing. Typically a MockMail object
     */
    public NoChannelCheck(Mail mailer) {
        mail = mailer;
        log = Logger.getLogger(NoChannelCheck.class);
        mailSent = false;
    }
    
    /**
     * {@inheritDoc}
     */
    protected void run(JobExecutionContext arg0) throws JobExecutionException {
        
        List results = getListOfUnchannelledServers();
        if (log.isDebugEnabled()) {
            int size = 0;
            if (results != null) {
                size = results.size();
            }
            log.debug("Found " + size + " unchanneled servers");
        }
        if (results != null) {
            Iterator i = results.iterator();
            //go through the list of unchanneled servers and process each one
            while (i.hasNext()) {
                Map row = (Map) i.next();
                
                processUnchannelledServer((Long) row.get("id"), 
                                          (Long) row.get("org_id"), 
                                          (String) row.get("name"));
            }
        }
    }
    
    /**
     * return list of Map instances containing 
     * id, org_id, and name
     * @return List of UnchanneledServers (server with no base channel)
     */
    protected List getListOfUnchannelledServers() {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME, 
                TaskConstants.TASK_QUERY_NOCHANNEL_FIND_ORGS);

        return m.execute();
    }
    
    /**
     * @return true if any mail has been successfully sent yet
     */
    public boolean hasSentMail() {
        return mailSent;
    }

   /**
     * proccess a given request
     */
    private void processUnchannelledServer(Long serverId, Long orgId, String serverName) 
                throws JobExecutionException {
        if (orgId == null || serverId == null || serverName == null) {
            log.error("Skipping " + serverId + " because all required fields" +
                      "[org_id, server_id, name] could not be found");    
            return;
        }

        if (log.isDebugEnabled()) {
            log.debug("Processing (server_id, org_id, servername) (" +
                    serverId + ", " + orgId + ", " + serverName + ")");
        }
        
        Org org = OrgFactory.lookupById(orgId);
        
        //search the org's active admin list for a user with a valid email
        String email = findMailableUsers(org.getActiveOrgAdmins());
        
        //we don't email if we cannot find a mailable user for the system
        if (email == null) {
            log.warn("Skipping " + serverId + " because no mailable user" +
                      " could be found");
            return;
        }
        
        //make sure email errors are caught
        try {
            sendNotificationEmail(serverName, email);
            mailSent = true;
        }
        catch (Exception e) {
            log.error("Exception while sending notification email: " +
                      "org_id: " + orgId + " email: " + email);
            log.error(e.getMessage(), e);
        }

    }
    
   /**
     * we cycle through the list of admins passed in until we find a valid user
     * with a valid email
     */
    private String findMailableUsers(List activeAdmins) {
        // need to protect against a null list.
        if (activeAdmins == null) {
            return null;
        }
        
        for (Iterator itr = activeAdmins.iterator(); itr.hasNext();) {
            User admin = (User) itr.next();
            
            if (admin != null && admin.getEmail() != null) {
                return admin.getEmail();
            }
        }
        
        return null;
    }
    
   /**
     * mail's given email address using the email.unchanneledsystem templates
     */
    private void sendNotificationEmail(String serverName, String email) {
        LocalizationService ls = LocalizationService.getInstance();
        
        if (log.isDebugEnabled()) {
            log.debug("send notification for [" + serverName +
                      "] to [" + email + "]");
        }
        mail.setSubject(ls.getMessage("email.unchanneledsystem.subject"));
        mail.setRecipient(email);
        mail.setBody(ls.getMessage("email.unchanneledsystem.body", serverName));
      
        String from = Config.get().getString(
                "web.customer_service_email");

        if (from == null || "".equals(from)) {
            log.warn("web.customer_service_email configuration " + 
                     "entry not set, using dev-null@redhat.com");
            from = "dev-null@redhat.com";
        }
        mail.setFrom(from);
        mail.setHeader("X-RHN-Info", "backend_no_channel_check");
        TaskHelper.sendMail(mail, log);
    }
}
