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
package com.redhat.rhn.manager.monitoring;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.monitoring.notification.ContactGroup;
import com.redhat.rhn.domain.monitoring.notification.Method;
import com.redhat.rhn.domain.monitoring.notification.MethodType;
import com.redhat.rhn.domain.monitoring.notification.NotificationFactory;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

/**
 * ModifyMethodCommand - class for encapsulating business
 * logic around creating Notification Methods.
 * @version $Rev$
 */
public class ModifyMethodCommand {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger.getLogger(ModifyMethodCommand.class);

    private User user;
    private Method method;

    /**
     * Create a new Command with specified User.  Used when
     * CREATING a new Method.
     *
     * @param userIn User who owns this NotificationMethod
     */
    public ModifyMethodCommand(User userIn) {
        this.user = userIn;
        this.method = new Method();
        this.method.setUser(userIn);
        this.method.setFormat(NotificationFactory.FORMAT_DEFAULT);
        ContactGroup contactGroup = NotificationFactory.createContactGroup(userIn);
        this.method.setContactGroup(contactGroup);
    }

    /**
     * Create a new ModifyMethodCommand with the ID of an existing Notification
     * Method.  Used for EDITING an existing Method.
     *
     * @param userIn is requesting the lookup of the existing Method.  Not necessarily
     * the user who owns the Method itself.
     * @param methodId id of the Method
     */
    public ModifyMethodCommand(User userIn, Long methodId) {
        this.method = NotificationFactory.lookupMethod(methodId, userIn);
        /*this.contactGroup = NotificationFactory.
            lookupContactGroupByName(this.method.getMethodName());*/
        this.user = this.method.getUser();
    }


    /**
     * Get the Method associated with the command.
     * @return Returns the method.
     */
    public Method getMethod() {
        return method;
    }


    /**
     * Get the User
     * @return Returns the user.
     */
    public User getUser() {
        return user;
    }

    /**
     * Set the name of the method.
     * @param nameIn of the Method
     */
    public void setMethodName(String nameIn) {
        if (logger.isDebugEnabled()) {
            logger.debug("setMethodName(String nameIn=" + nameIn + ") - start");
        }

        this.method.setMethodName(nameIn);
        this.method.getContactGroup().setContactGroupName(nameIn);

        if (logger.isDebugEnabled()) {
            logger.debug("setMethodName(String) - end");
        }
    }

    /**
     * Persist the Method
     * @param currentUser The user/admin storing this method.  Usually not the user
     * associated with the Notification Method and instead is the one who initiated
     * the save.
     * @return ValidatorError if the currentUser is in the wrong state or is
     * missing a field.
     */
    public ValidatorError storeMethod(User currentUser) {
        if (logger.isDebugEnabled()) {
            logger.debug("storeMethod(User currentUser=" + currentUser +
                    ") - start");
        }
        String dest = null;

        if (this.method.getType().equals(NotificationFactory.TYPE_EMAIL)) {
            dest = this.method.getEmailAddress();
        }
        else if (this.method.getType().equals(NotificationFactory.TYPE_PAGER)) {
            dest = this.method.getPagerEmail();
        }
        if (StringUtils.isEmpty(dest)) {
            ValidatorError returnValidatorError = new ValidatorError(
                    "errors.required", LocalizationService.getInstance()
                            .getMessage("method-form.jspf.name"));
            if (logger.isDebugEnabled()) {
                logger.debug("storeMethod(User) - end - return value=" +
                        returnValidatorError);
            }
            return returnValidatorError;
        }
        // Verify the passed in name to make sure they aren't trying
        // to save a new (or existing) Method with a name that is
        // already taken.
        Method lookedUp = NotificationFactory.lookupMethodByNameAndUser(
                this.method.getMethodName(), this.method.getUser().getId());
        if (lookedUp != null &&
                lookedUp.getMethodName().equals(this.method.getMethodName())) {
            // now check to see if the found Method has the same ID (is the same)
            // as the one in the Command:
            if (this.method.getId() == null ||
                    lookedUp.getId().longValue() != this.method.getId().longValue()) {
                ValidatorError returnValidatorError = new ValidatorError(
                        "method.nametaken", this.method.getMethodName());
                if (logger.isDebugEnabled()) {
                    logger.debug("storeMethod(User) - end - return value=" +
                            returnValidatorError);
                }
                return returnValidatorError;
            }
        }

        NotificationFactory.saveContactGroup(currentUser, this.method.getContactGroup());
        NotificationFactory.saveMethod(this.method, currentUser);


        if (logger.isDebugEnabled()) {
            logger.debug("storeMethod(User) - end - return value=" + null);
        }
        return null;
    }

    /**
     * Set the methodType
     * @param typeIn to use
     */
    public void setType(MethodType typeIn) {
        if (logger.isDebugEnabled()) {
            logger.debug("setType(MethodType typeIn=" + typeIn + ") - start");
        }

        this.method.setType(typeIn);


        if (logger.isDebugEnabled()) {
            logger.debug("setType(MethodType) - end");
        }
    }

    /**
     * Set the email destination on this Method
     * @param emailIn to set
     */
    public void setEmail(String emailIn) {
        if (logger.isDebugEnabled()) {
            logger.debug("setEmail(String emailIn=" + emailIn + ") - start");
        }

        if (this.method.getType() == null) {
            throw new IllegalStateException("Please set the " +
                    "MethodType before calling setEmail()");
        }
        if (this.method.getType().equals(NotificationFactory.TYPE_EMAIL)) {
            this.method.setEmailAddress(emailIn);
        }
        else if (this.method.getType().equals(NotificationFactory.TYPE_PAGER)) {
            this.method.setPagerEmail(emailIn);
        }
        else if (this.method.getType().equals(NotificationFactory.TYPE_SNMP)) {
            throw new IllegalArgumentException("MethodType must be Pager or Email " +
                    "to be able to set the EmailAddress");
        }

        if (logger.isDebugEnabled()) {
            logger.debug("setEmail(String) - end");
        }
    }

    /**
     * Translate the passed in string into a concrete class instance of MethodType
     * @param selectedType the current String representation of the Type selected
     */
    public void updateMethodType(String selectedType) {
        if (logger.isDebugEnabled()) {
            logger.debug("updateMethodType(String selectedType=" + selectedType +
                    ") - start");
        }

        if (NotificationFactory.TYPE_EMAIL.getMethodTypeName().equals(selectedType)) {
            this.method.setType(NotificationFactory.TYPE_EMAIL);
        }
        else if (NotificationFactory.TYPE_GROUP.getMethodTypeName().equals(selectedType)) {
            this.method.setType(NotificationFactory.TYPE_GROUP);
        }
        else if (NotificationFactory.TYPE_PAGER.getMethodTypeName().equals(selectedType)) {
            this.method.setType(NotificationFactory.TYPE_PAGER);
            this.method.setPagerSplitLongMessages("0");
        }
        else if (NotificationFactory.TYPE_SNMP.getMethodTypeName().equals(selectedType)) {
            this.method.setType(NotificationFactory.TYPE_SNMP);
        }
        else {
            throw new IllegalArgumentException("SelectedType doesnt " +
                    "match any known MethodTypes: " + selectedType);
        }

        if (logger.isDebugEnabled()) {
            logger.debug("updateMethodType(String) - end");
        }
    }

}
