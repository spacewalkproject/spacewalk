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

package com.redhat.rhn.frontend.events;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;

import java.util.List;

/**
 * An event representing an error generated from the web frontend
 *
 * @version $Rev: 59372 $
 */
public class NewUserEvent extends BaseEvent implements EventMessage  {
    
    private static final int NO_CREATOR_INDEX = 0;
    private static final int WITH_CREATOR_INDEX = 2;
    private User accountCreator;
    private String password;
    private String domain;
    private List adminList;
    
    /**
     * format this message as a string
     *   TODO mmccune - fill out the email properly with the entire 
     *                  request values
     * @return Text of email.
     */
    public String toText() {        
        LocalizationService ls = LocalizationService.getInstance();
        //gather information for the email to newUser
        
        Object[] bodyArgs = new Object[8];
        populateBodyArgs(bodyArgs);
        String retval;
        /*
         * If the user is using pam for authentication, then we don't need to confuse the
         * poor user further by mentioning a new password. Just don't mention it.
         */
        if (getUser().getUsePamAuthentication()) {
            retval = ls.getMessage("email.newaccount.pam.body", 
                    getUserLocale(), bodyArgs);
        }
        else {
            if (getAccountCreator() != null) {
                retval = ls.getMessage("email.newaccountbycreator.body", 
                        getUserLocale(), bodyArgs);
            }
            else {
                retval = ls.getMessage("email.newaccount.body", 
                        getUserLocale(), bodyArgs);
            }
        }
        return retval;
    }

    /**
     * This mail event includes a link back to the server.  This method
     * generates the String version of this URL.
     * @return String URL. 
     */
    public String getUrl() {
        //create url for new user
        Config c = Config.get();
        StringBuffer url = new StringBuffer();
        if (ConfigDefaults.get().isSSLAvailable()) {
            url.append("https://");
        }
        else {
            url.append("http://");
        }
        if (c.getString("base_domain") != null) {
            url.append(c.getString("base_domain"));
        }
        else {
            url.append(domain);
        }
        if (c.getString("base_port") != null && !ConfigDefaults.get().isSSLAvailable()) {
            url.append(":");
            url.append(c.getString("base_port"));
        }
        url.append("/");
        return url.toString();
        
    }
    
    /**
     * @return Returns the accountCreator.
     */
    public User getAccountCreator() {
        return accountCreator;
    }

    /**
     * @param accountCreatorIn The accountCreator to set.
     */
    public void setAccountCreator(User accountCreatorIn) {
        this.accountCreator = accountCreatorIn;
    }


    
    /**
     * @return Returns the domain.
     */
    public String getDomain() {
        return domain;
    }


    
    /**
     * @param domainIn The domain to set.
     */
    public void setDomain(String domainIn) {
        this.domain = domainIn;
    }


    
    /**
     * @return Returns the password.
     */
    public String getPassword() {
        return password;
    }


    
    /**
     * @param passwordIn The password to set.
     */
    public void setPassword(String passwordIn) {
        this.password = passwordIn;
    }
    /**
     * @return Returns the password.
     */
    public List getAdmins() {
        return adminList;
    }
    /**
     * @param admins Admins to set.
     */
    public void setAdmins(List admins) {
        this.adminList = admins;
    }
    
    /**
     * Populates the arguments that need to go the body of the message
     * that is sent to the new account.
     * @param bodyArgs
     */
    private void populateBodyArgs(Object[] bodyArgs) {
        if (getAccountCreator() != null) {
            bodyArgs[0] = getAccountCreator().getFirstNames();
            bodyArgs[1] = getAccountCreator().getLastName();
            fillUserInfo(bodyArgs, WITH_CREATOR_INDEX);
        }
        else {
            fillUserInfo(bodyArgs, NO_CREATOR_INDEX);
        }
    }

    private void fillUserInfo(Object[] bodyArgs, int index) {
        bodyArgs[index] = getUser().getLogin();
        bodyArgs[index + 1] = getPassword(); //newUser.getPassword could return encryption
        bodyArgs[index + 2] = getUser().getEmail();
        bodyArgs[index + 3] = getUrl();
        bodyArgs[index + 4] = OrgFactory.EMAIL_FOOTER.getValue();
    }

}

