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

import com.redhat.rhn.common.conf.UserDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.regex.Pattern;

import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;

/**
 * UpdateUserCommand
 * @version $Rev$
 */
public class UpdateUserCommand {
    
    private User user;
    private String unencryptedPassword;
    private String email;
    private String prefix;
    private String firstNames;
    private String lastName;
    private List validPrefixes;
    private boolean unencryptedPasswordChanged = false;
    private boolean emailChanged = false;
    private boolean prefixChanged = false;
    private boolean firstNamesChanged = false;
    private boolean lastNameChanged = false;
    private boolean needsUpdate = false;
    
    /**
     * Constructor
     * @param userToUpdate User that will get updated.
     */
    public UpdateUserCommand(User userToUpdate) {
        if (userToUpdate == null) {
            throw new IllegalArgumentException("Null user not acceptable");
        }

        user = userToUpdate;
        unencryptedPassword = null;
        email = null;
        prefix = null;
        firstNames = null;
        lastName = null;

        buildValidPrefixes();
    }
    
    private void buildValidPrefixes() {
        Iterator i = LocalizationService.getInstance().availablePrefixes().iterator();
        validPrefixes = new LinkedList();
        while (i.hasNext()) {
            validPrefixes.add(i.next());
        }
    }
    
    /**
     * Updates the user's password, email, prefix, first and last names.
     * @return The user updated.
     */
    public User updateUser() {
        if (needsUpdate) {
            validateEmail();
            validatePassword();
            validatePrefix();
            safePopulateUser();
            
            // ok update it
            UserManager.storeUser(user);
        }
        return user;
    }
    
    private void safePopulateUser() {
        if (firstNamesChanged) {
            user.setFirstNames(firstNames);
        }
        
        if (lastNameChanged) {
            user.setLastName(lastName);
        }
        
        if (emailChanged) {
            user.setEmail(email);
        }
        
        if (prefixChanged) {
            user.setPrefix(prefix);
        }
        
        if (unencryptedPasswordChanged) {
            user.setPassword(unencryptedPassword);
        }
    }
    
    /**
     * Private helper method to validate the password. This happens when the setPassword
     * method of this class is called. Puts errors into the passwordErrors list.
     */
    private void validatePassword() {
        if (!unencryptedPasswordChanged) {
            return; // nothing to verify
        }

        String password = getUnencryptedPassword();
        if (password == null || password.length() < 
                                    UserDefaults.get().getMinPasswordLength()) {
            throw new IllegalArgumentException(LocalizationService.getInstance().
                    getMessage("error.minpassword",
                                    UserDefaults.get().getMinPasswordLength()));
        }
        else if (password.length() > UserDefaults.get().getMaxPasswordLength()) {
            throw new IllegalArgumentException(LocalizationService.getInstance().
                    getMessage("error.maxpassword"));
        }
        
        // Newlines and tab characters can slip through the API much easier than the UI:
        if (Pattern.compile("[\\t\\n]").matcher(password).find()) {
            throw new IllegalArgumentException(
                "Password contains tab or newline characters.");
        }

    }
    
    private void validatePrefix() {
        if (prefixChanged && !validPrefixes.contains(prefix)) {
            throw new IllegalArgumentException(
                    "Invalid prefix [" + prefix + "]. Must be one of " +
                    validPrefixes.toString());
        }
    }
    
    /**
     * Private helper method to validate the user's email address. Puts errors into the
     * errors list.
     */
    private void validateEmail() {
        if (!emailChanged) {
            return; // nothing to verify
        }
        // Make sure user and email are not null
        if (email == null) {
            throw new IllegalArgumentException("Email address is null");
        }
        
        // Make email is not over the max length
        if (user.getEmail().length() > UserDefaults.get().getMaxEmailLength()) {
            throw new IllegalArgumentException(String.format(
                    "Email address specified [%s] is too long", user.getEmail()));
        }
        
        // Make sure set email is valid
        try {
            new InternetAddress(email).validate();
        }
        catch (AddressException e) {
            throw new IllegalArgumentException(
                    "Email address invalid. Cause: " + e.toString());
        }
    }
    
    /**
     * @param passwordIn The password to set
     */
    public void setPassword(String passwordIn) {
        if (!StringUtils.equals(passwordIn, user.getPassword())) {
            unencryptedPasswordChanged = true;
            needsUpdate = true;
            unencryptedPassword = passwordIn;
        }
    }
    
    private String getUnencryptedPassword() {
        return unencryptedPassword;
    }
    
    /**
     * @param emailIn The email to set
     */
    public void setEmail(String emailIn) {
        if (!StringUtils.equals(emailIn, user.getEmail())) {
            emailChanged = true;
            needsUpdate = true;
            email = emailIn;
        }
    }
    
    /**
     * @param prefixIn The prefix to set
     */
    public void setPrefix(String prefixIn) {
        if (!StringUtils.equals(prefixIn, user.getPrefix())) {
            prefixChanged = true;
            needsUpdate = true;
            prefix = prefixIn;
        }
    }
    
    /**
     * @param firstNamesIn The first names to set
     */
    public void setFirstNames(String firstNamesIn) {
        if (!StringUtils.equals(firstNamesIn, user.getFirstNames())) {
            firstNamesChanged = true;
            needsUpdate = true;
            firstNames = firstNamesIn;
        }
    }
    
    /**
     * @param lastNameIn The last name to set
     */
    public void setLastName(String lastNameIn) {
        if (!StringUtils.equals(lastNameIn, user.getLastName())) {
            lastNameChanged = true;
            needsUpdate = true;
            lastName = lastNameIn;
        }
    }
}
