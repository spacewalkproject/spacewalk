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
package com.redhat.rhn.manager.user;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.validator.RequiredConstraint;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.Address;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.events.NewUserEvent;

import org.apache.commons.lang.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.SortedSet;
import java.util.regex.Pattern;

import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;

/**
 * A command to create or edit users
 * @version $Rev$
 */
public class CreateUserCommand {

    private User user;
    private Org org;
    private Address addr;
    private boolean makeOrgAdmin;
    private boolean makeSatAdmin;
    
    private List<ValidatorError> errors;
    private List<ValidatorError> passwordErrors;

    /*
     * Why we need passwordErrors.
     * The setPassword method on UserImpl encrypts passwords (If configured to do so). 
     * If we don't validate the password before we set it, we will only ever be able 
     * to get to the encrypted password back which will always be valid.
     */
    
    /**
     * Constructor... creates an empty user object
     */
    public CreateUserCommand() {
        user = UserFactory.createUser();
    }
    
    /**
     * Validates the user object. Checks login and email attributes.
     * @return an Object array of ValidatorErrors.
     */
    public ValidatorError[] validate() {
        errors = new ArrayList(); //clear validation errors
        
        if (passwordErrors != null) {
            errors.addAll(passwordErrors); //add any password validation errors
        }
        validateEmail();
        validateLogin();
        validatePrefix();
        
        return (ValidatorError[]) errors.toArray(new ValidatorError[0]);
    }
    
    /**
     * Publishes a new user event to the message queue
     * @param accountCreator The person whom created the user
     * @param admins Org admins
     * @param domain The servername for this server (used to build url).
     * @param password The user's password. It must be explicitly passed in
     * seperate from the user because the password associated with the User object
     * might be encrypted, thus useless for this method
     */
    public void publishNewUserEvent(User accountCreator, 
                                    List admins, 
                                    String domain, 
                                    String password) {
        NewUserEvent userevt = new NewUserEvent();
        userevt.setAccountCreator(accountCreator);
        userevt.setAdmins(admins);
        userevt.setPassword(password);
        userevt.setDomain(domain);
        userevt.setUser(this.user);
        MessageQueue.publish(userevt);
    }

    /**
     * Saves the new user object (along with the Org and Address).
     */
    public void storeNewUser() {
        /*
         * Ok, this is a bloody ugly hack, but since the pl/sql used by 
         * UserFactory.saveNewUser() is shared and the use pam authentication seems to be
         * the only thing affected by it, we are going to work around it here. 
         * 
         * The Create_New_User function in the db creates an entry in rhnUserInfo with the
         * default values. This means that anything stored in User.personalInfo gets 
         * reset. We need to be able to update the use_pam_authentication column in this 
         * table, so save the value, save the user, then set the attribute back to what it
         * was before we called UserManager.createUser(). This will ensure that what was 
         * selected on the form is what gets stored with the user (since hibernate will 
         * then be taking care of the db values).
         * 
         * We really need to a) divorce ourselves from www and oracle apps b) get rid of the
         * application/business logic stored in pl/sql functions in the db and c) clean up
         * the dirty hacks like this that are throughout our code. We shouldn't have to work
         * around the db in our code.
         */
        boolean usePam = user.getUsePamAuthentication(); //save what we got from the form
        user = UserManager.createUser(user, org, addr);
        if (this.makeOrgAdmin) {
            user.addRole(RoleFactory.ORG_ADMIN);
        }
        if (this.makeSatAdmin) {
            user.addRole(RoleFactory.SAT_ADMIN);
        }
        user.setUsePamAuthentication(usePam); //set it back
        UserManager.storeUser(user); //save the user via hibernate
    }
    
    
    /**
     * Private helper method to validate the user's email address. Puts errors into the
     * errors list.
     */
    private void validateEmail() {
        // Make sure user and email are not null
        if (user == null || user.getEmail() == null) {
            errors.add(new ValidatorError("error.addr_invalid", "null"));
            return;
        }
        
        // Make sure set email is valid
        try {
            new InternetAddress(user.getEmail()).validate();
        }
        catch (AddressException e) {
            errors.add(new ValidatorError("error.addr_invalid", user.getEmail()));
        }
    }
    
    /**
     * Private helper method to validate the user's login. Puts errors into the errors List.
     */
    private void validateLogin() {
        int max = Config.get().getInt("max_user_len");
        if (user == null) {
            errors.add(new ValidatorError("error.minlogin", "null"));
            return;
        }
        String login = StringUtils.defaultString(user.getLogin());
        /*
         * Check for login minimum length
         * Since login.getBytes().length >= login.length(), just check for min length
         */
        if (login.length() < Config.get().getInt("min_user_len")) {
            errors.add(new ValidatorError("error.minlogin", 
                               Config.get().getString("min_user_len")));
            return;
        }
        /*
         * Check for login maximum length
         * Since we are allowing utf8 input, but not supporting it in the db, we need to 
         * check the length of the bytes here as well. 
         * TODO: Do better error checking here once the db and code is fully localized and
         * we are supporting it on logins
         */
        else if (login.length() > max || login.getBytes().length > max) {
            errors.add(new ValidatorError("error.maxlogin", login));
            return;
        }
        
        // validate using the webui code.  I must say that RequiredConstraint
        // is a stupid place for hiding username validation.  But nevertheless
        // I will continue to propogate this crap until we want to revisit
        // validation.
        RequiredConstraint rc = new RequiredConstraint("CreateUserCommand");
        if (!rc.isValidUserName(login)) {
            errors.add(new ValidatorError("errors.username", login));
            return;
        }
        
        // Make sure desiredLogin isn't taken already
        try {
            UserFactory.lookupByLogin(login);
            errors.add(new ValidatorError("error.login_already_taken", login));
        }
        catch (LookupException le) {
            // User is not taken 
            // so we can coolly add him. 
        }
        
    }
    
    /**
     * Private helper method to validate the user's prefix. Puts errors into the
     * errors list.
     */
    private void validatePrefix() {
        if (user.getPrefix() != null) {
            // Make sure whether prefix is valid, if it is set
            SortedSet validPrefixes = LocalizationService.getInstance().availablePrefixes();
            if (!validPrefixes.contains(user.getPrefix())) {
                errors.add(new ValidatorError(
                        "Invalid prefix [" + user.getPrefix() + "]. Must be one of " +
                        validPrefixes.toString()));
            }
        }
    }

    /**
     * Private helper method to validate the password. This happens when the setPassword
     * method of this class is called. Puts errors into the passwordErrors list.
     * @param passwordIn The password to check.
     */
    private void validatePassword(String passwordIn) {
        if (passwordIn == null || passwordIn.length() < 5) {
            passwordErrors.add(new ValidatorError("error.minpassword", "5"));
        }

        // Newlines and tab characters can slip through the API much easier than the UI:
        if (Pattern.compile("[\\t\\n]").matcher(passwordIn).find()) {
            passwordErrors.add(new ValidatorError("error.invalidpasswordcharacters"));
        }

        else if (passwordIn.length() > 64) {
            passwordErrors.add(new ValidatorError("error.maxpassword", 
                                                  user.getPassword()));
        }
    }
    
    /***** User accessors *****/
    
    /**
     * @param companyIn The company sent
     */
    public void setCompany(String companyIn) {
        user.setCompany(companyIn);
    }
    
    /**
     * @param emailIn The email to set
     */
    public void setEmail(String emailIn) {
        user.setEmail(emailIn);
    }
    
    /**
     * @param loginIn The login to set
     */
    public void setLogin(String loginIn) {
        user.setLogin(loginIn);
    }
    
    /**
     * @param passwordIn The password to set
     */
    public void setPassword(String passwordIn) {
        passwordErrors = new ArrayList(); //init password errors list
        validatePassword(passwordIn);
        user.setPassword(passwordIn);
    }
    
    /**
     * @param prefixIn The prefix to set
     */
    public void setPrefix(String prefixIn) {
        user.setPrefix(prefixIn);
    }
    
    /**
     * @param firstNamesIn The first names to set
     */
    public void setFirstNames(String firstNamesIn) {
        user.setFirstNames(firstNamesIn);
    }
    
    /**
     * @param lastNameIn The last name to set
     */
    public void setLastName(String lastNameIn) {
        user.setLastName(lastNameIn);
    }
    
    /**
     * @param phoneIn The phone to set
     */
    public void setPhone(String phoneIn) {
        user.setPhone(phoneIn);
    }
    
    /**
     * @param faxIn The fax to set
     */
    public void setFax(String faxIn) {
        user.setFax(faxIn);
    }
           
    /**
     * @param val Should this user use pam authentication?
     */
    public void setUsePamAuthentication(boolean val) {
        user.setUsePamAuthentication(val);
    }

    /**
     * Setter for the org object. 
     * @param orgIn the org to set
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }
    
    /**
     * Sets the Address object
     * @param addrIn The address to set
     */
    public void setAddress(Address addrIn) {
        this.addr = addrIn;
    }
    
    /**
     * @param val Should this user be an org admin?
     */
    public void setMakeOrgAdmin(boolean val) {
        this.makeOrgAdmin = val;
    }
        
    /**
     * @return The user object
     */
    public User getUser() {
        return this.user;
    }
    
    /**
     * 
     * @param val Should this user be a sat admin?
     */
    public void setMakeSatAdmin(boolean val) {
        this.makeSatAdmin = val;
    }
}
