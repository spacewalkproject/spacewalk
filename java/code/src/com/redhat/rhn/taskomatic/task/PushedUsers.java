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
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.Mail;
import com.redhat.rhn.common.messaging.SmtpMail;
import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;

/**
 * PushedUsers
 * This task is the web side of the entitlement pushing code from Bala. Basically, 
 * customers (not contacts) are created in CRM and pushed to our side, along with an 
 * entry in web_customer_notification. We send emails to the entries in this table with
 * links that let them create an account into the org in question. This way users get to
 * pick their own username, password, etc.
 * @version $Rev$
 */
public class PushedUsers extends SingleThreadedTask {
    
    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */    
    public static final String DISPLAY_NAME = "pushed_users";
    
    private static final String REGISTER_URL =  
        Config.get().getString("web.pushed_users_acct_url");
    private static final String RHN_REDIRECT_URL = 
        Config.get().getString("web.pushed_users_redirect_url");

    private static Logger log = Logger.getLogger(PushedUsers.class);
    
    /**
     * {@inheritDoc}
     */
    protected void run(JobExecutionContext contextIn) throws JobExecutionException {

        SelectMode m = ModeFactory.getMode("Task_queries", "users_to_be_notified");
        DataResult peeps = m.execute(new HashMap()); //in honor of ksmith

        // loop through users
        for (Iterator itr = peeps.iterator(); itr.hasNext();) {
            Map peep = (Map) itr.next();
            Long orgid = (Long) peep.get("org_id");
            Long userid = (Long) peep.get("id");
            String email = (String) peep.get("contact_email_address");
            String name = (String) peep.get("name");
            Long customerNumber = (Long) peep.get("oracle_customer_number");
            
            Org org = OrgFactory.lookupById(orgid);
            if (org == null || userid == null || email == null || 
                name == null || customerNumber == null) {
                log.error("Skipping user: " + userid + " email: " + email +
                          "because all required fields [org, userid, email, name, " + 
                          "customerNumber] could not be found.");
                if (log.isDebugEnabled()) {
                    StringBuffer msg = new StringBuffer();
                    msg.append("Org ID: ").append(orgid).append("\n");
                    msg.append("User ID: ").append(userid).append("\n");
                    msg.append("Email: ").append(email).append("\n");
                    msg.append("Name: ").append(name).append("\n");
                    msg.append("Customer Number: ").append(customerNumber).append("\n");
                    log.debug(msg.toString());
                }
                //don't do anything. we need all of this information to continue.
                continue;
            }
            
            //get the list of admin email addrs
            String[] adminEmails = TaskHelper.getAdminEmails(org);
            
            if (log.isInfoEnabled()) {
                log.info("processing org_id " + orgid + ", email " + email);
            }
            
            /*
             * javax.mail can send lots of exceptions. Catch them all here and log the
             * error. 
             */
            try {
                //send the mail
                sendNotificationEmail(org, name, customerNumber, email, adminEmails);
                
                //delete the user from web_customer_notification if message was sent
                deleteUser(userid);
            }
            catch (Exception e) {
                log.error("Exception while sending notification email: " +
                          "id: " + userid + " email: " + email);
                log.error(e.getMessage(), e);
            }
        }        
    }
    
    /*
     * Builds the url to be embedded in the email message. This is the link
     * the user will click to finish creating the user. 
     */
    private String getUrl(Long orgid) {
        String checksum = SessionSwap.encodeData(orgid.toString());
        
        String finalURL = REGISTER_URL + "?checksum=" + checksum;
        try {
            finalURL = finalURL + "&redirect=" + encode(RHN_REDIRECT_URL);
        } 
        catch (UnsupportedEncodingException e) {
            log.error("Exception while encoding the redirect url:" + RHN_REDIRECT_URL);
            log.error(e.getMessage(), e);
        }
        log.info("URL : " + finalURL);
        return finalURL; 
    }
    
    private String encode(String string) throws UnsupportedEncodingException {
        return URLEncoder.encode(string, "UTF-8");
    }
    
    /*
     * Removes a users entry from the web_contact_notification table
     */
    private void deleteUser(Long id) {
        WriteMode m = ModeFactory.getWriteMode("Task_queries", "remove_user_from_wcn");
        Map params = new HashMap();
        params.put("user_id", id);
        m.executeUpdate(params);
    }
    
    /*
     * Composes and sends the notification email to the user.
     */
    private void sendNotificationEmail(Org org, String name, Long customerNumber,
                                       String email, String[] adminEmails) {
        try {
            LocalizationService ls = LocalizationService.getInstance();
            Mail mail = getMailer();
            mail.setSubject(ls.getMessage("email.newuser.bala.subject"));
            
            // vvv ANOTHER HACK ALERT!
            // In order to satisfy customer service and bugzilla: #191431
            // I have to get the german translation of the footer.  IF not
            // found then don't do anything.
            Object[] args = new String[1];
            args[0] = Config.get().getString("web.pushed_users_footer_url");
            String footer = ls.getMessage("email.newuser.bala.footer", Locale.GERMAN, args);
            
            // use the same arguments because the URLs are the same
            String footer2 = ls.getMessage(
                    "email.newuser.bala.footer2", Locale.FRENCH, args);
            // ^^^ ANOTHER HACK ALERT!
            
            String[] bodyArgs = new String[4];
            bodyArgs[0] = name;
            bodyArgs[1] = customerNumber.toString();
            bodyArgs[2] = getUrl(org.getId());
            bodyArgs[3] = Config.get().getString("web.pushed_users_support_url");
       
            // HACK continued
            // moving body initialization up so we can append the
            // two footers necessary for this email.
            String body = ls.getMessage("email.newuser.bala.body", (Object[])bodyArgs);
            if (!StringUtils.isEmpty(footer)) {
                // rest of HACK
                body = body + "\n" + footer;
            }
            
            if (!StringUtils.isEmpty(footer2)) {
                // rest of HACK
                body = body + "\n" + footer2;
            }
            
            mail.setBody(body);
            mail.setRecipient(email);
            mail.setCCRecipients(adminEmails);
            if (Config.get().getString("pushed_users_bcc") != null) {
                //convert to array
                String[] bccArray = {Config.get().getString("pushed_users_bcc")};
                mail.setBCCRecipients(bccArray);
            }
            mail.setFrom("customerservice@redhat.com");
            mail.setHeader("X-RHN-Info", "backend_pushed_user");
            TaskHelper.sendMail(mail, log);
        }
        catch (Throwable t) {
            log.error(t.getMessage(), t);
        }
    }
    
    /**
     * @return Returns a Mail object
     */
    protected Mail getMailer() {
        return new SmtpMail();
    }
}
